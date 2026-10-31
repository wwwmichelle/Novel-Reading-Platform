from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.schemas.book import BookSummary
from app.schemas.category import CategoryBrief


class CategoryService:
    async def list_categories(self, db: Session) -> list[CategoryBrief]:
        adapter = get_adapter()
        cats = await adapter.list_categories()
        return [CategoryBrief(id=c["id"], name=c["name"]) for c in cats]

    async def list_books_by_category(self, db: Session, category_id: str, *, page: int = 1, page_size: int = 20) -> dict:
        adapter = get_adapter()
        result = await adapter.list_books_by_category(category_id, page=page, page_size=page_size)
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


category_service = CategoryService()