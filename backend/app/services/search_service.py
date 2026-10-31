from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.core.exceptions import ValidationException
from app.schemas.book import BookSummary


class SearchService:
    async def search(self, db: Session, keyword: str, *, scope: str = "both", page: int = 1, page_size: int = 20) -> dict:
        kw = keyword.strip()
        if not kw:
            raise ValidationException(code="EMPTY_KEYWORD", message="搜索关键词不能为空")
        if len(kw) > 100:
            raise ValidationException(code="KEYWORD_TOO_LONG", message="搜索关键词过长")
        if scope not in ("title", "author", "both"):
            raise ValidationException(code="INVALID_SCOPE", message="搜索范围无效")
        adapter = get_adapter()
        result = await adapter.search(kw, scope=scope, page=page, page_size=page_size)
        items = [BookSummary(
            id=b["id"], title=b["title"], author=b["author"],
            cover_url=b.get("cover_url"), serial_status=b.get("serial_status", "ongoing"),
            latest_chapter_title=b.get("latest_chapter_title"), is_demo=b.get("is_demo", False),
            source_url=b.get("source_url"), source_name=b.get("source_name"),
            reading_mode=b.get("reading_mode", "internal"), updated_at=b.get("updated_at"),
        ) for b in result["items"]]
        total = result["total"]
        total_pages = (total + page_size - 1) // page_size if total > 0 else 0
        return {
            "items": items, "total": total, "page": page,
            "page_size": page_size, "total_pages": total_pages,
            "is_empty": result.get("is_empty", total == 0),
        }


search_service = SearchService()