from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.core.exceptions import NotFoundException, ValidationException
from app.crud.bookshelf import crud_bookshelf
from app.crud.reading_progress import crud_reading_progress
from app.models.reading_progress import ReadingProgress
from app.models.user import User
from app.schemas.reading import ProgressReport, ReadingProgressResponse


class ReadingService:
    async def report_progress(self, db: Session, user: User, book_id: str, req: ProgressReport) -> ReadingProgressResponse:
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})
        chapter = await adapter.get_chapter(book_id, req.chapter_id)
        if not chapter:
            raise NotFoundException(code="CHAPTER_NOT_FOUND", message="章节不存在", detail={"chapter_id": req.chapter_id})

        existing = crud_reading_progress.get_by_user_and_book(db, user.id, book_id)
        if existing:
            existing_time = existing.updated_at
            if existing_time.tzinfo is None:
                existing_time = existing_time.replace(tzinfo=timezone.utc)
            if req.client_timestamp < existing_time:
                pass
            elif req.client_timestamp == existing_time:
                if req.chapter_order <= existing.chapter_order:
                    pass
                else:
                    progress = crud_reading_progress.upsert(
                        db, user.id, book_id,
                        chapter_id=req.chapter_id, chapter_order=req.chapter_order,
                        scroll_position=req.scroll_position,
                    )
                    crud_bookshelf.update_last_read(db, user.id, book_id, req.chapter_id, datetime.now(timezone.utc))
                    return ReadingProgressResponse(
                        book_id=book_id, chapter_id=progress.chapter_id,
                        chapter_order=progress.chapter_order, scroll_position=progress.scroll_position,
                        updated_at=progress.updated_at,
                    )
            else:
                progress = crud_reading_progress.upsert(
                    db, user.id, book_id,
                    chapter_id=req.chapter_id, chapter_order=req.chapter_order,
                    scroll_position=req.scroll_position,
                )
                crud_bookshelf.update_last_read(db, user.id, book_id, req.chapter_id, datetime.now(timezone.utc))
                return ReadingProgressResponse(
                    book_id=book_id, chapter_id=progress.chapter_id,
                    chapter_order=progress.chapter_order, scroll_position=progress.scroll_position,
                    updated_at=progress.updated_at,
                )
            return ReadingProgressResponse(
                book_id=book_id, chapter_id=existing.chapter_id,
                chapter_order=existing.chapter_order, scroll_position=existing.scroll_position,
                updated_at=existing.updated_at,
            )
        else:
            progress = crud_reading_progress.upsert(
                db, user.id, book_id,
                chapter_id=req.chapter_id, chapter_order=req.chapter_order,
                scroll_position=req.scroll_position,
            )
            crud_bookshelf.update_last_read(db, user.id, book_id, req.chapter_id, datetime.now(timezone.utc))
            return ReadingProgressResponse(
                book_id=book_id, chapter_id=progress.chapter_id,
                chapter_order=progress.chapter_order, scroll_position=progress.scroll_position,
                updated_at=progress.updated_at,
            )

    async def get_progress(self, db: Session, user: User, book_id: str) -> ReadingProgressResponse:
        progress = crud_reading_progress.get_by_user_and_book(db, user.id, book_id)
        if not progress:
            raise NotFoundException(code="PROGRESS_NOT_FOUND", message="暂无阅读进度", detail={"book_id": book_id})
        return ReadingProgressResponse(
            book_id=book_id, chapter_id=progress.chapter_id,
            chapter_order=progress.chapter_order, scroll_position=progress.scroll_position,
            updated_at=progress.updated_at,
        )


reading_service = ReadingService()