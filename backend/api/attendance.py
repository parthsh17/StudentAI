from fastapi import APIRouter, Depends, HTTPException
from backend.core.database import get_db_connection
from backend.core.security import get_current_user
from backend.services.attendance_service import get_detailed_attendance

router = APIRouter(prefix="/attendance", tags=["attendance"])

@router.get("/")
def get_student_attendance(
    current_user: dict = Depends(get_current_user),
    db = Depends(get_db_connection)
):
    register_no = current_user["register_no"]
    result = get_detailed_attendance(register_no, db)
    
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
        
    return result
