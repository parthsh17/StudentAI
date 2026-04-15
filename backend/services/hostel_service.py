import psycopg2.extras
from datetime import date
from typing import Dict, Any

class HostelService:
    def __init__(self, db_conn):
        self.db = db_conn

    def get_remaining_days(self, register_no: str) -> str:
        cursor = self.db.cursor(cursor_factory=psycopg2.extras.DictCursor)
        try:
            cursor.execute(
                "SELECT end_date FROM hostel_allocation WHERE register_no = %s AND end_date >= CURRENT_DATE",
                (register_no,)
            )
            record = cursor.fetchone()
            if not record or not record['end_date']:
                return "You do not have an active hostel allocation with an end date."
            
            days_left = (record['end_date'] - date.today()).days
            return f"You have {max(0, days_left)} days remaining in the hostel."
        finally:
            cursor.close()

    def apply_leave(self, register_no: str, start_date: str, end_date: str, reason: str = "personal") -> str:
        cursor = self.db.cursor()
        try:
            cursor.execute(
                """
                INSERT INTO hostel_leave (register_no, start_date, end_date, reason, status)
                VALUES (%s, %s, %s, %s, 'pending') RETURNING leave_id
                """,
                (register_no, start_date, end_date, reason)
            )
            self.db.commit()
            return f"Leave applied successfully from {start_date} to {end_date}."
        except Exception as e:
            self.db.rollback()
            return f"Failed to apply leave: {str(e)}"
        finally:
            cursor.close()

    def get_hostel_details(self, register_no: str) -> str:
        cursor = self.db.cursor(cursor_factory=psycopg2.extras.DictCursor)
        try:
            cursor.execute(
                """
                SELECT h.name as hostel_name, ha.room_number, ha.dues 
                FROM hostel_allocation ha
                JOIN hostel h ON h.hostel_id = ha.hostel_id
                WHERE ha.register_no = %s AND (ha.end_date IS NULL OR ha.end_date >= CURRENT_DATE)
                """,
                (register_no,)
            )
            record = cursor.fetchone()
            if not record:
                return "You do not have an active hostel allocation."
            
            return f"Hostel: {record['hostel_name']} | Room: {record['room_number']} | Pending Dues: ${record['dues'] or 0}"
        finally:
            cursor.close()

# Adapter functions for the LLM Tool Registry (which passes db_conn via kwargs)
def get_remaining_days(register_no: str, **kwargs) -> Dict[str, Any]:
    db_conn = kwargs.get("db_conn")
    service = HostelService(db_conn)
    return {"message": service.get_remaining_days(register_no)}

def apply_leave(register_no: str, start_date: str, end_date: str, reason: str = "personal", **kwargs) -> Dict[str, Any]:
    db_conn = kwargs.get("db_conn")
    service = HostelService(db_conn)
    return {"message": service.apply_leave(register_no, start_date, end_date, reason)}

def get_hostel_details(register_no: str, **kwargs) -> Dict[str, Any]:
    db_conn = kwargs.get("db_conn")
    service = HostelService(db_conn)
    return {"message": service.get_hostel_details(register_no)}
