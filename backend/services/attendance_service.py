import psycopg2.extras

def get_detailed_attendance(register_no: str, db_conn) -> dict:
    """
    Get the detailed attendance records including total overall attendance and 
    a breakdown of present, absent, and percentage for each individual subject.
    """
    cursor = db_conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    try:
        # Subject-wise attendance query
        cursor.execute("""
            SELECT 
                c.course_code,
                c.name as course_name,
                COUNT(a.attendance_id) as total_sessions,
                SUM(CASE WHEN a.status = 'PRESENT' THEN 1 ELSE 0 END) as present_sessions
            FROM enrollment e
            JOIN course_offering co ON e.offering_id = co.offering_id
            JOIN course c ON co.course_id = c.course_id
            JOIN attendance a ON a.enrollment_id = e.enrollment_id
            WHERE e.register_no = %s
            GROUP BY c.course_code, c.name
            ORDER BY c.course_code;
        """, (register_no,))
        
        subject_records = cursor.fetchall()
        
        if not subject_records:
            return {"status": "No attendance records found for your account."}
        
        subjects = []
        overall_total = 0
        overall_present = 0
        
        for record in subject_records:
            tot = int(record['total_sessions'])
            pres = int(record['present_sessions'] or 0)
            absent = tot - pres
            pct = (pres / tot) * 100 if tot > 0 else 0
            
            overall_total += tot
            overall_present += pres
            
            subjects.append({
                "course_code": record['course_code'],
                "course_name": record['course_name'],
                "total": tot,
                "present": pres,
                "absent": absent,
                "percentage": f"{round(pct, 2)}%"
            })
            
        overall_pct = (overall_present / overall_total) * 100 if overall_total > 0 else 0
        
        return {
            "overall": {
                "total_sessions": overall_total,
                "present_sessions": overall_present,
                "absent_sessions": overall_total - overall_present,
                "attendance_percentage": f"{round(overall_pct, 2)}%"
            },
            "subjects": subjects
        }
    except Exception as e:
        return {"error": str(e)}
    finally:
        cursor.close()
