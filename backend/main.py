from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from backend.api import auth, hostel, ai, admin, attendance
from backend.orchestrator.loader import initialize_tools, reload_tools
from backend.cache.redis_client import redis_cache

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    redis_cache.connect()
    initialize_tools()
    yield
    # Shutdown
    pass

app = FastAPI(title="StudentAI", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5173",
        "http://localhost:5174",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(hostel.router)
app.include_router(ai.router)
app.include_router(admin.router)
app.include_router(attendance.router)

@app.get("/")
def root():
    return {"message": "Welcome to StudentAI"}

@app.post("/reload-tools")
def reload_tools_endpoint():
    reload_tools()
    return {"status": "reloaded"}
