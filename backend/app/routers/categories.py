from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.schemas.book import BookSummary
from app.schemas.category import CategoryBrief
from app.schemas.common import PageResponse
from app.services.category_service import category_service

router = APIRouter()


@router.get("", response_model=list[CategoryBrief])
async def list_categories(db: Session = Depends(get_db)):
    return await category_service.list_categories(db)


@router.get("/{category_id}/books", response_model=PageResponse[BookSummary])
async def list_books_by_category(
    category_id: str,
    page: int = Query(1, ge=1),
    page_size: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    db: Session = Depends(get_db),
):
    return await category_service.list_books_by_category(db, category_id, page=page, page_size=page_size)