from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_current_user
from app.db.session import get_db
from app.models.user import User
from app.schemas.reading import ProgressReport, ReadingProgressResponse
from app.services.reading_service import reading_service

router = APIRouter()


@router.put("/{book_id}", response_model=ReadingProgressResponse)
async def report_progress(
    book_id: str,
    req: ProgressReport,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await reading_service.report_progress(db, user, book_id, req)


@router.get("/{book_id}", response_model=ReadingProgressResponse)
async def get_progress(
    book_id: str,
    db: Session = Depends(get_db),
    user: User = Depends(get_current_user),
):
    return await reading_service.get_progress(db, user, book_id)