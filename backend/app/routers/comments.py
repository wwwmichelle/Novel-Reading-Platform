from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentResponse
from app.schemas.common import PageResponse
from app.services.comment_service import comment_service

router = APIRouter()


@router.get("/books/{book_id}/comments", response_model=PageResponse[CommentResponse])
async def list_comments(
    book_id: str,
    page: int = Query(1, ge=1),
    page_size: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    db: Session = Depends(get_db),
):
    return await comment_service.list_comments(db, book_id, page=page, page_size=page_size)


@router.post("/books/{book_id}/comments", response_model=CommentResponse, status_code=201)
async def create_comment(
    book_id: str,
    req: CommentCreate,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await comment_service.create_comment(db, book_id, user, req)


@router.delete("/comments/{comment_id}")
async def delete_comment(
    comment_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await comment_service.delete_comment(db, comment_id, user)