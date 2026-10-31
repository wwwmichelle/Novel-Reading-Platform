from datetime import datetime

from pydantic import BaseModel, Field, field_validator
import bleach


class CommentCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=1000)

    @field_validator("content")
    @classmethod
    def sanitize_content(cls, v: str) -> str:
        cleaned = bleach.clean(v, tags=[], attributes={}, strip=True)
        cleaned = cleaned.strip()
        if not cleaned:
            raise ValueError("评论内容不能为空")
        return cleaned


class CommentResponse(BaseModel):
    id: str
    book_id: str
    user_id: str
    username: str = ""
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}