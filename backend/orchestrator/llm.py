from openai import OpenAI
from backend.core.config import settings
from backend.orchestrator.loader import OPENAI_DB_TOOLS
import json

def analyze_query(query: str):
    """
    Sends the user query to the LLM and asks it to use tools if needed to fulfill the request.
    Returns the message object which might contain tool_calls.
    """
    if not settings.OPENAI_API_KEY:
        return None

    client = OpenAI(api_key=settings.OPENAI_API_KEY)
    
    if not OPENAI_DB_TOOLS:
        tools_args = {}
    else:
        tools_args = {"tools": OPENAI_DB_TOOLS, "tool_choice": "auto"}

    response = client.chat.completions.create(
        model="gpt-4o-mini",  
        messages=[
            {"role": "system", "content": (
                "You are an AI assistant responsible for understanding user queries and selecting appropriate "
                "backend tools to fulfill them. You do NOT directly answer questions unless no tool is applicable.\n\n"

                "## AVAILABLE CAPABILITIES\n"
                "You are given a list of tools dynamically. Each tool has a name, description, and parameters.\n"
                "You must: select the most relevant tool(s), extract required arguments, and return structured tool calls.\n\n"

                "## CORE RESPONSIBILITIES\n\n"

                "### 1. Intent Detection\n"
                "- Identify the domain (hostel, attendance, exam, curriculum, etc.)\n"
                "- Identify the specific intent (e.g., remaining days, apply leave)\n\n"

                "### 2. Tool Mapping\n"
                "- Match user intent to the best available tool\n"
                "- Use tool descriptions for semantic matching, not just keywords\n\n"

                "### 3. Multi-Intent Handling\n"
                "If a query contains multiple requests, return ALL relevant tool calls in a list.\n\n"

                "### 4. Argument Extraction\n"
                "- Extract parameters from user input and normalize values where possible\n"
                "- Example: 'Apply leave for Saturday' → convert to {start_date: YYYY-MM-DD, end_date: YYYY-MM-DD}\n\n"

                "### 5. Missing Information\n"
                "If required parameters are missing, ask for clarification instead of guessing.\n\n"

                "### 6. Tool Selection Rules\n"
                "- Prefer specific tools over generic ones\n"
                "- Do NOT guess or assume unavailable tools\n"
                "- Use ONLY tools provided in the current tool list\n\n"

                "### 7. No Tool Scenario\n"
                "If no tool applies, respond with: {\"response\": \"I cannot perform this action currently.\"}\n\n"

                "## IMPORTANT RULES\n"
                "DO NOT: generate natural language answers when tools exist, assume tool names not provided, "
                "or call inactive/unknown tools.\n"
                "ALWAYS: use tool descriptions for reasoning, handle multiple intents, return structured JSON only.\n\n"

                "You act as a semantic router and planner, not a chatbot. "
                "Your job is to convert natural language into a structured tool execution plan."
            )},
            {"role": "user", "content": query}
        ],
        **tools_args
    )
    
    return response.choices[0].message
