import importlib
import psycopg2.extras
from backend.core.database import get_db_connection

TOOL_REGISTRY = {}
OPENAI_DB_TOOLS = []

def load_tools_from_db():
    registry = {}
    openai_tools = []
    
    from backend.core.config import settings
    try:
        conn = psycopg2.connect(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            dbname=settings.DB_NAME,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD
        )
        cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        cursor.execute("""
            SELECT name, module, function_name, description, parameters 
            FROM tool_registry 
            WHERE active = TRUE
        """)
        tools = cursor.fetchall()
        
        for tool in tools:
            try:
                module = importlib.import_module(tool["module"])
                func = getattr(module, tool["function_name"])
                registry[tool["name"]] = func
                
                openai_tools.append({
                    "type": "function",
                    "function": {
                        "name": tool["name"],
                        "description": tool["description"],
                        "parameters": tool["parameters"] or {"type": "object", "properties": {}}
                    }
                })
            except Exception as e:
                print(f"Failed to load tool {tool['name']}: {e}")
                
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error loading tools from database: {e}")

    return registry, openai_tools

def initialize_tools():
    registry, openai_tools = load_tools_from_db()
    TOOL_REGISTRY.clear()
    TOOL_REGISTRY.update(registry)
    OPENAI_DB_TOOLS.clear()
    OPENAI_DB_TOOLS.extend(openai_tools)

def reload_tools():
    initialize_tools()
