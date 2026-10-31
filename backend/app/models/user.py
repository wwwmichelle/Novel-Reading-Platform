from uuid import uuid4

from sqlalchemy import String, CheckConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class User(Base, TimestampMixin):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    username: Mapped[str] = mapped_column(String(50), nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    role: Mapped[str] = mapped_column(String(20), nullable=False, default="user")

    __table_args__ = (
        CheckConstraint("role IN ('user', 'admin')", name="ck_user_role"),
        CheckConstraint("length(username) >= 3", name="ck_user_username_len"),
        Index("ix_users_username_unique", "username", unique=True),
    )