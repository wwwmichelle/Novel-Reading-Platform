from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.exceptions import ValidationException
from app.db.session import get_db
from app.schemas.book import BookDetail, BookSummary, ChapterBrief, ChapterContent
from app.schemas.common import PageResponse
from app.services.book_service import book_service

router = APIRouter()


def _validate_pagination(page: int, page_size: int):
    if page < 1:
        raise ValidationException(code="INVALID_PAGINATION", message="页码必须大于0")
    if page_size < 1 or page_size > settings.MAX_PAGE_SIZE:
        raise ValidationException(code="INVALID_PAGINATION", message=f"每页数量必须在1-{settings.MAX_PAGE_SIZE}之间")


@router.get("", response_model=PageResponse[BookSummary])
async def list_books(
    page: int = Query(1, ge=1),
    page_size: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    db: Session = Depends(get_db),
):
    _validate_pagination(page, page_size)
    return await book_service.list_books(db, page=page, page_size=page_size)


@router.get("/recent")
async def list_recent_books(
    limit: int = Query(10, ge=1, le=50),
    db: Session = Depends(get_db),
):
    return await book_service.list_recent_books(db, limit=limit)


@router.get("/{book_id}", response_model=BookDetail)
async def get_book(book_id: str, db: Session = Depends(get_db)):
    return await book_service.get_book(db, book_id)


@router.get("/{book_id}/chapters", response_model=list[ChapterBrief])
async def list_chapters(book_id: str, db: Session = Depends(get_db)):
    return await book_service.list_chapters(db, book_id)


@router.get("/{book_id}/chapters/{chapter_id}", response_model=ChapterContent)
async def get_chapter(book_id: str, chapter_id: str, db: Session = Depends(get_db)):
    return await book_service.get_chapter(db, book_id, chapter_id)