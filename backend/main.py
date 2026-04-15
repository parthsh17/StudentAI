from fastapi import FastAPI
from contextlib import asynccontextmanager
from backend.api import auth, hostel, ai
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

app.include_router(auth.router)
app.include_router(hostel.router)
app.include_router(ai.router)

@app.get("/")
def root():
    return {"message": "Welcome to StudentAI"}

@app.post("/reload-tools")
def reload_tools_endpoint():
    reload_tools()
    return {"status": "reloaded"}
