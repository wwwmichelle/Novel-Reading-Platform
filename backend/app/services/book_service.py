from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.core.exceptions import NotFoundException
from app.schemas.book import BookDetail, BookSummary, ChapterBrief, ChapterContent


class BookService:
    async def list_books(self, db: Session, *, page: int = 1, page_size: int = 20) -> dict:
        adapter = get_adapter()
        result = await adapter.list_books(page=page, page_size=page_size)
        items = [BookSummary(
            id=b["id"], title=b["title"], author=b["author"],
            cover_url=b.get("cover_url"), serial_status=b.get("serial_status", "ongoing"),
            latest_chapter_title=b.get("latest_chapter_title"), is_demo=b.get("is_demo", False),
            source_url=b.get("source_url"), source_name=b.get("source_name"),
            reading_mode=b.get("reading_mode", "internal"), updated_at=b.get("updated_at"),
        ) for b in result["items"]]
        total = result["total"]
        total_pages = (total + page_size - 1) // page_size if total > 0 else 0
        return {"items": items, "total": total, "page": page, "page_size": page_size, "total_pages": total_pages}

    async def list_recent_books(self, db: Session, *, limit: int = 10) -> dict:
        adapter = get_adapter()
        result = await adapter.list_recent_books(limit=limit)
        items = [BookSummary(
            id=b["id"], title=b["title"], author=b["author"],
            cover_url=b.get("cover_url"), serial_status=b.get("serial_status", "ongoing"),
            latest_chapter_title=b.get("latest_chapter_title"), is_demo=b.get("is_demo", False),
            source_url=b.get("source_url"), source_name=b.get("source_name"),
            reading_mode=b.get("reading_mode", "internal"), updated_at=b.get("updated_at"),
        ) for b in result["items"]]
        return {"items": items, "total": len(items)}

    async def get_book(self, db: Session, book_id: str) -> BookDetail:
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})
        return BookDetail(
            id=book["id"], title=book["title"], author=book["author"],
            cover_url=book.get("cover_url"), description=book.get("description"),
            serial_status=book.get("serial_status", "ongoing"),
            latest_chapter_title=book.get("latest_chapter_title"),
            is_demo=book.get("is_demo", False),
            categories=book.get("categories", []),
            source_url=book.get("source_url"), source_name=book.get("source_name"),
            reading_mode=book.get("reading_mode", "internal"), updated_at=book.get("updated_at"),
        )

    async def list_chapters(self, db: Session, book_id: str) -> list[ChapterBrief]:
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})
        chapters = await adapter.list_chapters(book_id)
        return [ChapterBrief(**ch) for ch in chapters]

    async def get_chapter(self, db: Session, book_id: str, chapter_id: str) -> ChapterContent:
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})
        chapter = await adapter.get_chapter(book_id, chapter_id)
        if not chapter:
            raise NotFoundException(code="CHAPTER_NOT_FOUND", message="章节不存在", detail={"chapter_id": chapter_id})
        return ChapterContent(**chapter)


book_service = BookService()