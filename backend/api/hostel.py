from fastapi import APIRouter, Depends
from backend.core.database import get_db_connection
from backend.core.security import get_current_user
from backend.services.hostel_service import HostelService
from backend.models.schemas import LeaveRequest, LeaveResponse
from pydantic import BaseModel

router = APIRouter(prefix="/hostel", tags=["hostel"])

class DaysResponse(BaseModel):
    message: str

class DetailsResponse(BaseModel):
    details: str

@router.get("/remaining-days", response_model=DaysResponse)
def get_remaining_days(
    db=Depends(get_db_connection), 
    current_user: dict = Depends(get_current_user)
):
    service = HostelService(db)
    msg = service.get_remaining_days(current_user["register_no"])
    return DaysResponse(message=msg)

@router.get("/details", response_model=DetailsResponse)
def get_hostel_details(
    db=Depends(get_db_connection),
    current_user: dict = Depends(get_current_user)
):
    service = HostelService(db)
    details = service.get_hostel_details(current_user["register_no"])
    return DetailsResponse(details=details)

@router.post("/leave", response_model=LeaveResponse)
def apply_leave(
    leave: LeaveRequest,
    db=Depends(get_db_connection),
    current_user: dict = Depends(get_current_user)
):
    service = HostelService(db)
    msg = service.apply_leave(
        current_user["register_no"],
        leave.start_date,
        leave.end_date,
        leave.reason
    )
    return LeaveResponse(status="pending", message=msg)
