from datetime import datetime

from pydantic import BaseModel


class BookshelfItem(BaseModel):
    id: str
    book_id: str
    book_title: str = ""
    book_author: str = ""
    cover_url: str | None = None
    last_read_chapter_id: str | None = None
    last_read_chapter_title: str | None = None
    last_read_time: datetime | None = None
    added_at: datetime

    model_config = {"from_attributes": True}