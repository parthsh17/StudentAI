from fastapi import APIRouter, Depends
from backend.models.schemas import QueryRequest
from backend.core.database import get_db_connection
from backend.core.security import get_current_user
from backend.orchestrator.planner import process_query_with_tools
from pydantic import BaseModel

router = APIRouter(prefix="/ai", tags=["ai"])

class AIResponse(BaseModel):
    response: str

@router.post("/query", response_model=AIResponse)
def ai_query(
    request: QueryRequest,
    db=Depends(get_db_connection),
    current_user: dict = Depends(get_current_user)
):
    final_answer = process_query_with_tools(request.query, current_user["register_no"], db)
    return AIResponse(response=final_answer)
 