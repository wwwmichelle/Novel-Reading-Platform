from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.deps import require_admin
from app.db.session import get_db
from app.models.user import User
from app.schemas.category import CategoryCreate, CategoryUpdate
from app.schemas.comment import CommentResponse
from app.schemas.common import PageResponse
from app.services.admin_service import admin_service

router = APIRouter()


@router.post("/categories")
async def create_category(
    req: CategoryCreate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    return await admin_service.create_category(db, req.name, admin)


@router.put("/categories/{category_id}")
async def update_category(
    category_id: str,
    req: CategoryUpdate,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    return await admin_service.update_category(db, category_id, req.name, admin)


@router.delete("/categories/{category_id}")
async def delete_category(
    category_id: str,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    return await admin_service.delete_category(db, category_id, admin)


@router.get("/comments", response_model=PageResponse[CommentResponse])
async def list_all_comments(
    page: int = Query(1, ge=1),
    page_size: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    book_id: str | None = Query(None),
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    return await admin_service.list_all_comments(db, page=page, page_size=page_size, book_id=book_id)


@router.delete("/comments/{comment_id}")
async def delete_comment(
    comment_id: str,
    db: Session = Depends(get_db),
    admin: User = Depends(require_admin),
):
    return await admin_service.delete_comment(db, comment_id, admin)


@router.get("/datasources/status")
async def datasource_status(
    admin: User = Depends(require_admin),
):
    return await admin_service.datasource_status()