from sqlalchemy import select, func, delete
from sqlalchemy.orm import Session

from app.crud.base import CRUDBase
from app.models.comment import Comment


class CRUDComment(CRUDBase):
    def list_by_book(self, db: Session, book_id: str, *, skip: int = 0, limit: int = 20):
        stmt = (
            select(Comment)
            .where(Comment.book_id == book_id)
            .order_by(Comment.created_at.desc())
            .offset(skip)
            .limit(limit)
        )
        return db.execute(stmt).scalars().all()

    def count_by_book(self, db: Session, book_id: str) -> int:
        return db.execute(
            select(func.count()).select_from(Comment).where(Comment.book_id == book_id)
        ).scalar_one()

    def list_all(self, db: Session, *, skip: int = 0, limit: int = 20, book_id: str | None = None):
        stmt = select(Comment).order_by(Comment.created_at.desc())
        if book_id:
            stmt = stmt.where(Comment.book_id == book_id)
        stmt = stmt.offset(skip).limit(limit)
        return db.execute(stmt).scalars().all()

    def count_all(self, db: Session, *, book_id: str | None = None) -> int:
        stmt = select(func.count()).select_from(Comment)
        if book_id:
            stmt = stmt.where(Comment.book_id == book_id)
        return db.execute(stmt).scalar_one()

    def get_by_id_and_user(self, db: Session, comment_id: str, user_id: str) -> Comment | None:
        return db.execute(
            select(Comment).where(Comment.id == comment_id, Comment.user_id == user_id)
        ).scalar_one_or_none()


crud_comment = CRUDComment(Comment)