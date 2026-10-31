from sqlalchemy import select
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.reading_progress import ReadingProgress


class CRUDReadingProgress(CRUDBase):
    def upsert(
        self,
        db: Session,
        user_id: str,
        book_id: str,
        *,
        chapter_id: str,
        chapter_order: int,
        scroll_position: float,
    ) -> ReadingProgress:
        existing = self.get_by_user_and_book(db, user_id, book_id)
        if existing:
            existing.chapter_id = chapter_id
            existing.chapter_order = chapter_order
            existing.scroll_position = scroll_position
            db.commit()
            db.refresh(existing)
            return existing
        else:
            progress = ReadingProgress(
                user_id=user_id,
                book_id=book_id,
                chapter_id=chapter_id,
                chapter_order=chapter_order,
                scroll_position=scroll_position,
            )
            db.add(progress)
            db.commit()
            db.refresh(progress)
            return progress

    def get_by_user_and_book(self, db: Session, user_id: str, book_id: str) -> ReadingProgress | None:
        return db.execute(
            select(ReadingProgress).where(
                ReadingProgress.user_id == user_id,
                ReadingProgress.book_id == book_id,
            )
        ).scalar_one_or_none()


crud_reading_progress = CRUDReadingProgress(ReadingProgress)