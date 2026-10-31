from datetime import datetime

from pydantic import BaseModel


class BookSummary(BaseModel):
    id: str
    title: str
    author: str
    cover_url: str | None = None
    serial_status: str = "ongoing"
    latest_chapter_title: str | None = None
    source_url: str | None = None
    source_name: str | None = None
    reading_mode: str = "internal"
    is_demo: bool = False
    updated_at: datetime

    model_config = {"from_attributes": True}


class BookDetail(BaseModel):
    id: str
    title: str
    author: str
    cover_url: str | None = None
    description: str | None = None
    serial_status: str = "ongoing"
    latest_chapter_title: str | None = None
    source_url: str | None = None
    source_name: str | None = None
    reading_mode: str = "internal"
    is_demo: bool = False
    categories: list[str] = []
    updated_at: datetime

    model_config = {"from_attributes": True}


class ChapterBrief(BaseModel):
    id: str
    title: str
    order: int
    word_count: int = 0

    model_config = {"from_attributes": True}


class ChapterContent(BaseModel):
    id: str
    title: str
    content: str
    order: int
    word_count: int = 0
    prev_chapter_id: str | None = None
    next_chapter_id: str | None = None
    is_demo: bool = False

    model_config = {"from_attributes": True}