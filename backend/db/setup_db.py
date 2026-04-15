import psycopg2
import json
from backend.core.config import settings

def setup_database():
    try:
        conn = psycopg2.connect(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            dbname=settings.DB_NAME,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD
        )
        conn.autocommit = True
        cursor = conn.cursor()

        # Create tool_registry table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tool_registry (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100) UNIQUE,
                module VARCHAR(200),
                function_name VARCHAR(100),
                description TEXT,
                parameters JSONB,
                active BOOLEAN DEFAULT TRUE
            );
        """)

        print("Created tool_registry table if it didn't exist.")

        # Seed initial data
        tools_to_seed = [
            {
                "name": "hostel_get_remaining_days",
                "module": "backend.services.hostel_service",
                "function_name": "get_remaining_days",
                "description": "Get the number of days left in the student's hostel stay.",
                "parameters": {"type": "object", "properties": {}}
            },
            {
                "name": "hostel_apply_leave",
                "module": "backend.services.hostel_service",
                "function_name": "apply_leave",
                "description": "Apply for hostel leave.",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "start_date": {"type": "string", "description": "YYYY-MM-DD"},
                        "end_date": {"type": "string", "description": "YYYY-MM-DD"},
                        "reason": {"type": "string", "description": "Reason for leave"}
                    },
                    "required": ["start_date", "end_date", "reason"]
                }
            },
            {
                "name": "hostel_get_details",
                "module": "backend.services.hostel_service",
                "function_name": "get_hostel_details",
                "description": "Get hostel allocation details for the student including hostel name, room number, and pending dues.",
                "parameters": {"type": "object", "properties": {}}
            },
            {
                "name": "exam_get_next_exam",
                "module": "backend.services.exam_service",
                "function_name": "get_next_exam",
                "description": "Get the next upcoming exam for the student including course name, date, and type.",
                "parameters": {"type": "object", "properties": {}}
            }
        ]

        for t in tools_to_seed:
            cursor.execute("""
                INSERT INTO tool_registry (name, module, function_name, description, parameters, active)
                VALUES (%s, %s, %s, %s, %s, TRUE)
                ON CONFLICT (name) DO UPDATE 
                SET module = EXCLUDED.module,
                    function_name = EXCLUDED.function_name,
                    description = EXCLUDED.description,
                    parameters = EXCLUDED.parameters,
                    active = TRUE;
            """, (t["name"], t["module"], t["function_name"], t["description"], json.dumps(t["parameters"])))
            
        print("Seeded tools successfully.")
        
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error setting up database: {e}")

if __name__ == "__main__":
    setup_database()
