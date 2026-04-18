import json
import psycopg2.extras
from fastapi import APIRouter, Depends, HTTPException

from backend.core.config import settings
from backend.core.security import create_access_token, get_current_admin
from backend.core.database import get_db_connection
from backend.models.schemas import AdminLoginRequest, ToolCreate, ToolUpdate
from backend.orchestrator.loader import reload_tools

router = APIRouter(prefix="/admin", tags=["admin"])

@router.post("/login")
def admin_login(request: AdminLoginRequest):
    if (request.username != settings.ADMIN_USERNAME or
            request.password != settings.ADMIN_PASSWORD):
        raise HTTPException(status_code=401, detail="Invalid admin credentials")
    token = create_access_token(data={"role": "admin", "username": request.username})
    return {"access_token": token, "token_type": "bearer"}

@router.get("/tools")
def list_tools(
    db=Depends(get_db_connection),
    _=Depends(get_current_admin)
):
    cursor = db.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    try:
        cursor.execute(
            "SELECT id, name, module, function_name, description, parameters, active "
            "FROM tool_registry ORDER BY id"
        )
        return [dict(row) for row in cursor.fetchall()]
    finally:
        cursor.close()


@router.post("/tools", status_code=201)
def create_tool(
    tool: ToolCreate,
    db=Depends(get_db_connection),
    _=Depends(get_current_admin)
):
    cursor = db.cursor()
    try:
        cursor.execute(
            """
            INSERT INTO tool_registry (name, module, function_name, description, parameters, active)
            VALUES (%s, %s, %s, %s, %s, %s) RETURNING id
            """,
            (tool.name, tool.module, tool.function_name,
             tool.description, json.dumps(tool.parameters), tool.active)
        )
        new_id = cursor.fetchone()[0]
        db.commit()
        reload_tools()
        return {"id": new_id, "message": "Tool created and registry reloaded"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()


@router.put("/tools/{tool_id}")
def update_tool(
    tool_id: int,
    tool: ToolUpdate,
    db=Depends(get_db_connection),
    _=Depends(get_current_admin)
):
    cursor = db.cursor()
    try:
        cursor.execute(
            """
            UPDATE tool_registry
            SET name=%s, module=%s, function_name=%s,
                description=%s, parameters=%s, active=%s
            WHERE id=%s
            """,
            (tool.name, tool.module, tool.function_name,
             tool.description, json.dumps(tool.parameters), tool.active, tool_id)
        )
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Tool not found")
        db.commit()
        reload_tools()
        return {"message": "Tool updated and registry reloaded"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()


@router.patch("/tools/{tool_id}/toggle")
def toggle_tool(
    tool_id: int,
    db=Depends(get_db_connection),
    _=Depends(get_current_admin)
):
    cursor = db.cursor()
    try:
        cursor.execute(
            "UPDATE tool_registry SET active = NOT active WHERE id=%s RETURNING active",
            (tool_id,)
        )
        row = cursor.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail="Tool not found")
        db.commit()
        reload_tools()
        return {"active": row[0], "message": "Status toggled and registry reloaded"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()


@router.delete("/tools/{tool_id}", status_code=200)
def delete_tool(
    tool_id: int,
    db=Depends(get_db_connection),
    _=Depends(get_current_admin)
):
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM tool_registry WHERE id=%s", (tool_id,))
        if cursor.rowcount == 0:
            raise HTTPException(status_code=404, detail="Tool not found")
        db.commit()
        reload_tools()
        return {"message": "Tool deleted and registry reloaded"}
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=400, detail=str(e))
    finally:
        cursor.close()
