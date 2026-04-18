from pydantic import BaseModel
from typing import Optional, Any

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

# Admin schemas
class AdminLoginRequest(BaseModel):
    username: str
    password: str

class ToolCreate(BaseModel):
    name: str
    module: str
    function_name: str
    description: str
    parameters: dict = {}
    active: bool = True

class ToolUpdate(BaseModel):
    name: str
    module: str
    function_name: str
    description: str
    parameters: dict = {}
    active: bool = True

class ToolResponse(BaseModel):
    id: int
    name: str
    module: str
    function_name: str
    description: str
    parameters: Optional[Any] = None
    active: bool
