from datetime import datetime
from uuid import uuid4

from sqlalchemy import String, ForeignKey, UniqueConstraint, Index, DateTime, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class Bookshelf(Base, TimestampMixin):
    __tablename__ = "bookshelf"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    book_id: Mapped[str] = mapped_column(String(36), nullable=False)
    last_read_chapter_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    last_read_time: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    __table_args__ = (
        UniqueConstraint("user_id", "book_id", name="uq_bookshelf_user_book"),
        Index("ix_bookshelf_user_id", "user_id"),
    )