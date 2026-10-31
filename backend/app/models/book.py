from uuid import uuid4

from sqlalchemy import String, Text, Boolean, CheckConstraint, Index, Table, Column, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin


book_categories = Table(
    "book_categories",
    Base.metadata,
    Column("book_id", String(36), ForeignKey("books.id", ondelete="CASCADE"), primary_key=True),
    Column("category_id", String(36), ForeignKey("categories.id", ondelete="CASCADE"), primary_key=True),
)


class Book(Base, TimestampMixin):
    __tablename__ = "books"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    title: Mapped[str] = mapped_column(String(200), nullable=False)
    author: Mapped[str] = mapped_column(String(100), nullable=False)
    cover_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    serial_status: Mapped[str] = mapped_column(String(20), nullable=False, default="ongoing")
    latest_chapter_title: Mapped[str | None] = mapped_column(String(200), nullable=True)
    source_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("data_sources.id"), nullable=True)
    external_id: Mapped[str | None] = mapped_column(String(200), nullable=True)
    is_demo: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    categories = relationship("Category", secondary=book_categories, lazy="selectin")

    __table_args__ = (
        CheckConstraint("serial_status IN ('ongoing', 'completed')", name="ck_book_serial_status"),
        Index("ix_books_updated_at_desc", "updated_at"),
        Index("ix_books_source_id", "source_id"),
        Index("ix_books_title", "title"),
        Index("ix_books_author", "author"),
    )