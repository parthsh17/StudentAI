from backend.orchestrator.llm import analyze_query
from backend.orchestrator.loader import TOOL_REGISTRY
from backend.cache.redis_client import redis_cache
from backend.core.config import settings
from openai import OpenAI
import json
import hashlib

def get_cache_key(register_no: str, function_name: str, args: dict) -> str:
    hash_str = json.dumps(args, sort_keys=True)
    return f"tool_cache:{register_no}:{function_name}:{hashlib.md5(hash_str.encode()).hexdigest()}"

def process_query_with_tools(query: str, register_no: str, db_conn):
    """
    Orchestrates the AI process:
    1. Query LLM to get intent and tool calls
    2. Check Redis cache before executing tools
    3. Execute the tools dynamically by injecting register_no
    4. Return structured output or feed results back to LLM for final answer
    """
    message = analyze_query(query)
    
    if not message and not isinstance(message, dict):
        return "LLM integration requires OPENAI_API_KEY to be set in environment."

    if not message.tool_calls:
        return message.content
    
    tool_results = []
    
    for tool_call in message.tool_calls:
        function_name = tool_call.function.name
        
        try:
            arguments = json.loads(tool_call.function.arguments)
        except Exception:
            arguments = {}
            
        if function_name in TOOL_REGISTRY:
            func = TOOL_REGISTRY[function_name]
            
            # Redis cache fetch
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
            "- If a tool returned an error, explain it simply without technical jargon\n"
            "- Do NOT make up information not present in the tool results\n"
            "- Do NOT call additional tools — just summarize what you have"
        )},
        {"role": "user", "content": query},
        message
    ] + tool_results

    final_resp = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=final_response_messages
    )

    return final_resp.choices[0].message.content
