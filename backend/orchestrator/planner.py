from backend.orchestrator.llm import analyze_query
from backend.orchestrator.loader import TOOL_REGISTRY
from backend.cache.redis_client import redis_cache
from backend.core.config import settings
from openai import OpenAI
import json
import hashlib
import re

_ALLOWED_KEYWORDS = [
    "hostel", "room", "dues", "leave", "days remaining", "allocation",
    "accommodation", "warden", "laundry", "food",
    "attendance", "absent", "present", "session", "bunk",
]

_OFF_TOPIC_REPLY = (
    "I can only assist with university related queries. "
    "Please ask something related to your university data."
)

def _is_valid_academic_query(query: str, history: list = None) -> bool:
    """Return True if the query or its recent history contains at least one recognised academic keyword."""
    context = query
    if history:
        history_pieces = []
        for m in history[-4:]:
            if isinstance(m, dict):
                content = m.get("content")
                if content is None:
                    history_pieces.append("")
                elif isinstance(content, str):
                    history_pieces.append(content)
                else:
                    history_pieces.append(json.dumps(content))
            else:
                history_pieces.append(str(m))
        context += " " + " ".join(history_pieces)
    normalised = context.lower()
    normalised = re.sub(r"[^\w\s]", " ", normalised)
    return any(keyword in normalised for keyword in _ALLOWED_KEYWORDS)

def _get_enrolled_subjects(register_no, db_conn):
    """Fetch subjects enrolled by the student."""
    try:
        import psycopg2.extras
        cur = db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cur.execute("""
            SELECT c.course_code, c.name as course_name
            FROM enrollment e
            JOIN course_offering co ON e.offering_id = co.offering_id
            JOIN course c ON co.course_id = c.course_id
            WHERE e.register_no = %s
            ORDER BY c.course_code;
        """, (register_no,))
        records = cur.fetchall()
        cur.close()
        return [{"code": r["course_code"], "name": r["course_name"]} for r in records]
    except Exception:
        return []

def get_cache_key(register_no: str, function_name: str, args: dict) -> str:
    hash_str = json.dumps(args, sort_keys=True)
    return f"tool_cache:{register_no}:{function_name}:{hashlib.md5(hash_str.encode()).hexdigest()}"

def process_query_with_tools(query: str, register_no: str, db_conn, history: list = None) -> dict:
    """
    Orchestrates the AI process:
    ...
    Returns: {"response": str, "widget": dict | None}
    """
    if history is None:
        history = []
        
    clean_query = query.lower().strip()
    
    if clean_query == "attendance":
        subjects = _get_enrolled_subjects(register_no, db_conn)
        return {
            "response": "Here are the attendance actions you can take:",
            "widget": {
                "type": "attendance",
                "title": "Attendance Dashboard",
                "actions": [
                    {"label": "Total Attendance", "query": "what is my total attendance"},
                    {"label": "Total Absentees", "query": "how many total absents do i have"},
                    {"label": "Subject Wise Attendance", "type": "menu", "options": [
                        {"label": s["name"], "query": f"what is my attendance in {s['name']}"} for s in subjects
                    ]},
                    {"label": "Subject Wise Absentees", "type": "menu", "options": [
                        {"label": s["name"], "query": f"how many absents in {s['name']}"} for s in subjects
                    ]}
                ]
            }
        }
        
    if clean_query == "hostel" or clean_query == "i want to join the hostel":
        from backend.services.hostel_service import HostelService
        service = HostelService(db_conn)
        allocation = service.get_hostel_details(register_no)
        
        if allocation:
            return {
                "response": "Here is your hostel dashboard:",
                "widget": {
                    "type": "hostel",
                    "title": "My Hostel",
                    "actions": [
                        {"label": "Status & Details", "query": "give me my hostel allocation details"},
                        {"label": "Pending Dues", "query": "what are my current hostel dues"},
                        {"label": "Apply for Leave", "query": "i want to apply for hostel leave"},
                        {"label": "Days Left", "query": "how many days are left in my hostel stay"}
                    ]
                }
            }
        else:
            hostels = service.get_all_hostels()
            return {
                "response": "It looks like you haven't joined a hostel yet. How would you like to proceed?",
                "widget": {
                    "type": "hostel_onboarding",
                    "title": "Join Hostel",
                    "actions": [
                        {"label": "Join Hostel", "type": "link", "url": "/hostel-join"},
                        {"label": "Check Hostels", "type": "menu", "options": [
                            {"label": h["name"], "query": f"tell me about {h['name']}"} for h in hostels
                        ]}
                    ]
                }
            }

    if "apply" in clean_query and "leave" in clean_query and "from" not in clean_query:
        return {
            "response": "Please fill in the details below to apply for your hostel leave:",
            "widget": {
                "type": "form",
                "title": "Apply for Leave",
                "fields": [
                    {
                        "name": "type", 
                        "label": "Leave Type", 
                        "type": "select", 
                        "options": ["Home Visit", "Sick Leave", "Local Outing", "Other"]
                    },
                    {
                        "name": "start_date", 
                        "label": "Start Date", 
                        "type": "date"
                    },
                    {
                        "name": "end_date", 
                        "label": "End Date", 
                        "type": "date"
                    },
                    {
                        "name": "reason", 
                        "label": "Reason", 
                        "type": "textarea", 
                        "placeholder": "Explain the reason for your leave..."
                    }
                ],
                "submit_label": "Submit Application",
                "submit_query": "apply for leave with type {type}, from {start_date} to {end_date} for {reason}"
            }
        }

    if not _is_valid_academic_query(query, history):
        return {"response": _OFF_TOPIC_REPLY, "widget": None}

    message = analyze_query(query, history)

    if not message and not isinstance(message, dict):
        return {"response": "LLM integration requires OPENAI_API_KEY to be set in environment.", "widget": None}

    if not message.tool_calls:
        return {"response": message.content, "widget": None}
    
    tool_results = []
    
    for tool_call in message.tool_calls:
        function_name = tool_call.function.name
        
        try:
            arguments = json.loads(tool_call.function.arguments)
        except Exception:
            arguments = {}
            
        if function_name in TOOL_REGISTRY:
            func = TOOL_REGISTRY[function_name]
            
            #Redis cache fetch
            cache_key = get_cache_key(register_no, function_name, arguments)
            cached_result = redis_cache.get(cache_key)
            
            if cached_result:
                print(f"Cache hit for {function_name}")
                result = json.loads(cached_result)
            else:
                try:
                    arguments["register_no"] = register_no
                    arguments["db_conn"] = db_conn  
                    result = func(**arguments)
                    
                    redis_cache.set(cache_key, json.dumps(result), ex=300)
                except Exception as e:
                    result = f"Error executing tool: {e}"
            
            tool_results.append({
                "tool_call_id": tool_call.id,
                "role": "tool",
                "name": function_name,
                "content": str(result)
            })
        else:
            tool_results.append({
                "tool_call_id": tool_call.id,
                "role": "tool",
                "name": function_name,
                "content": f"Tool {function_name} not found in active registry."
            })

    client = OpenAI(api_key=settings.OPENAI_API_KEY)
    final_response_messages = [
        {"role": "system", "content": (
            "You are a helpful university assistant. You have already executed the required tools and received "
            "their results. Your job now is to synthesize the tool results into a single, clear, and concise "
            "natural language response for the student.\n\n"
            "Rules:\n"
            "- Be friendly and student-focused\n"
            "- Present tool results in a readable format (use bullet points or short sentences)\n"
            "- When presenting complex data like subject-wise attendance, always output it as a Markdown table (chart layout) so it is clear and structured.\n"
            "- If a tool returned an error, explain it simply without technical jargon\n"
            "- Do NOT make up information not present in the tool results\n"
            "- Do NOT call additional tools — just summarize what you have"
        )},
        {"role": "user", "content": query},
        message
    ]
    
    sanitized_history = []
    for m in history:
        if isinstance(m, dict):
            content = m.get("content")
            if content is not None and not isinstance(content, (str, list)):
                content = json.dumps(content)
            sanitized_history.append({"role": m["role"], "content": content})
        else:
            sanitized_history.append(m)
            
    final_response_messages = final_response_messages[:1] + sanitized_history + final_response_messages[1:] + tool_results

    final_resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=final_response_messages
    )

    return {"response": final_resp.choices[0].message.content, "widget": None}
