from uuid import uuid4

from sqlalchemy import String, CheckConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class Category(Base, TimestampMixin):
    __tablename__ = "categories"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    name: Mapped[str] = mapped_column(String(50), nullable=False)

    __table_args__ = (
        CheckConstraint("name != ''", name="ck_category_name_nonempty"),
        Index("ix_categories_name_unique", "name", unique=True),
    )