from uuid import uuid4

from sqlalchemy import String, ForeignKey, CheckConstraint, Index
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin


class SyncRecord(Base, TimestampMixin):
    __tablename__ = "sync_records"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    object_type: Mapped[str] = mapped_column(String(50), nullable=False)
    direction: Mapped[str] = mapped_column(String(20), nullable=False)
    result: Mapped[str] = mapped_column(String(20), nullable=False)
    detail: Mapped[str | None] = mapped_column(String(500), nullable=True)

    __table_args__ = (
        CheckConstraint("object_type IN ('bookshelf', 'reading_progress')", name="ck_sync_object_type"),
        CheckConstraint("direction IN ('upload', 'download')", name="ck_sync_direction"),
        CheckConstraint("result IN ('success', 'failure', 'conflict')", name="ck_sync_result"),
        Index("ix_sync_records_user_time", "user_id", "created_at"),
    )