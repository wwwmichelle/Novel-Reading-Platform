from sqlalchemy import select, func, insert
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.bookshelf import Bookshelf
from app.models.book import Book
from app.models.chapter import Chapter


class CRUDBookshelf(CRUDBase):
    def add(self, db: Session, user_id: str, book_id: str) -> Bookshelf | None:
        existing = self.get_by_user_and_book(db, user_id, book_id)
        if existing:
            return existing
        item = Bookshelf(user_id=user_id, book_id=book_id)
        db.add(item)
        try:
            db.commit()
            db.refresh(item)
            return item
        except IntegrityError:
            db.rollback()
            return self.get_by_user_and_book(db, user_id, book_id)

    def get_by_user_and_book(self, db: Session, user_id: str, book_id: str) -> Bookshelf | None:
        return db.execute(
            select(Bookshelf).where(Bookshelf.user_id == user_id, Bookshelf.book_id == book_id)
        ).scalar_one_or_none()

    def list_by_user(self, db: Session, user_id: str) -> list[Bookshelf]:
        return db.execute(
            select(Bookshelf)
            .where(Bookshelf.user_id == user_id)
            .order_by(Bookshelf.updated_at.desc())
        ).scalars().all()

    def remove(self, db: Session, user_id: str, book_id: str) -> bool:
        item = self.get_by_user_and_book(db, user_id, book_id)
        if item:
            db.delete(item)
            db.commit()
            return True
        return False

    def update_last_read(self, db: Session, user_id: str, book_id: str, chapter_id: str, last_read_time):
        item = self.get_by_user_and_book(db, user_id, book_id)
        if item:
            item.last_read_chapter_id = chapter_id
            item.last_read_time = last_read_time
            db.commit()
            db.refresh(item)
        return item


crud_bookshelf = CRUDBookshelf(Bookshelf)