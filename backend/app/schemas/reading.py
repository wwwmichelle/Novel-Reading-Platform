from datetime import datetime

from pydantic import BaseModel, Field


class ProgressReport(BaseModel):
    chapter_id: str
    chapter_order: int
    scroll_position: float = Field(0.0, ge=0.0, le=1.0)
    client_timestamp: datetime


class ReadingProgressResponse(BaseModel):
    book_id: str
    chapter_id: str
    chapter_order: int
    scroll_position: float
    updated_at: datetime

    model_config = {"from_attributes": True}