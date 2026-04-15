from pydantic import BaseModel
from typing import Optional

class LoginRequest(BaseModel):
    register_no: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str

class LeaveRequest(BaseModel):
    start_date: str
    end_date: str
    reason: str

class LeaveResponse(BaseModel):
    status: str
    message: str

class QueryRequest(BaseModel):
    query: str
