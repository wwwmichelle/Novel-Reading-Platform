from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.schemas.book import BookSummary
from app.schemas.common import PageResponse
from app.services.search_service import search_service

router = APIRouter()


@router.get("", response_model=PageResponse[BookSummary])
async def search(
    keyword: str = Query(..., min_length=1, max_length=100),
    scope: str = Query("both", pattern="^(title|author|both)$"),
    page: int = Query(1, ge=1),
    page_size: int = Query(settings.DEFAULT_PAGE_SIZE, ge=1, le=settings.MAX_PAGE_SIZE),
    db: Session = Depends(get_db),
):
    return await search_service.search(db, keyword, scope=scope, page=page, page_size=page_size)