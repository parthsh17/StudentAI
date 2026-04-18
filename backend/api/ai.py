from fastapi import APIRouter, Depends
from backend.models.schemas import QueryRequest
from backend.core.database import get_db_connection
from backend.core.security import get_current_user
from backend.orchestrator.planner import process_query_with_tools
from backend.cache.redis_client import redis_cache
from pydantic import BaseModel
from typing import Optional
import json

router = APIRouter(prefix="/ai", tags=["ai"])

class AIResponse(BaseModel):
    response: str
    widget: Optional[dict] = None

@router.post("/query", response_model=AIResponse)
def ai_query(
    request: QueryRequest,
    db=Depends(get_db_connection),
    current_user: dict = Depends(get_current_user)
):
    reg_no = current_user["register_no"]
    history_key = f"chat_history:{reg_no}"
    
    #Load history
    history_str = redis_cache.get(history_key)
    history = json.loads(history_str) if history_str else []
    
    #Run Orchestrator
    orchestrator_result = process_query_with_tools(request.query, reg_no, db, history)
    final_answer = orchestrator_result["response"]
    widget_data = orchestrator_result.get("widget")
    
    #Save History
    history.append({"role": "user", "content": request.query})
    history.append({"role": "assistant", "content": final_answer})
    
    history = history[-10:]
    redis_cache.set(history_key, json.dumps(history), ex=1800) #30 min TTL
    
    return AIResponse(response=final_answer, widget=widget_data)

@router.post("/clear_history")
def clear_history(current_user: dict = Depends(get_current_user)):
    reg_no = current_user["register_no"]
    redis_cache.client.delete(f"chat_history:{reg_no}") if redis_cache.client else None
    return {"status": "History cleared"}