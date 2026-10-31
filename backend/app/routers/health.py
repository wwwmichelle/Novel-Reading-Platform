from fastapi import APIRouter, Request
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.db.session import get_db

router = APIRouter()


@router.get("/health")
async def health_check():
    from app.core.config import settings
    from app.adapters.registry import get_adapter

    db_status = "ok"
    datasource_status = "unknown"
    datasource_mode = settings.DATA_SOURCE_MODE

    try:
        from app.db.session import SessionLocal
        db = SessionLocal()
        try:
            db.execute(text("SELECT 1"))
            db_status = "ok"
        finally:
            db.close()
    except Exception:
        db_status = "error"

    try:
        adapter = get_adapter()
        health = await adapter.health_check()
        datasource_status = health.get("status", "unknown")
    except Exception:
        datasource_status = "error"

    overall = "ok" if db_status == "ok" and datasource_status != "error" else "degraded"
    return {
        "status": overall,
        "database": db_status,
        "datasource": datasource_status,
        "datasource_mode": datasource_mode,
    }