from sqlalchemy.orm import Session

from app.adapters.registry import get_adapter
from app.core.exceptions import NotFoundException
from app.crud.bookshelf import crud_bookshelf
from app.models.bookshelf import Bookshelf
from app.models.chapter import Chapter
from app.models.user import User
from app.schemas.bookshelf import BookshelfItem


class BookshelfService:
    async def add_book(self, db: Session, user: User, book_id: str) -> dict:
        adapter = get_adapter()
        book = await adapter.get_book(book_id)
        if not book:
            raise NotFoundException(code="BOOK_NOT_FOUND", message="图书不存在", detail={"book_id": book_id})
        crud_bookshelf.add(db, user.id, book_id)
        return {"message": "已加入书架"}

    async def list_bookshelf(self, db: Session, user: User) -> list[BookshelfItem]:
        items = crud_bookshelf.list_by_user(db, user.id)
        result = []
        for item in items:
            adapter = get_adapter()
            book = await adapter.get_book(item.book_id)
            # Keep retired catalogue records in storage, without rendering broken cards.
            if not book:
                continue
            chapter_title = None
            if item.last_read_chapter_id:
                chapters = await adapter.list_chapters(item.book_id)
                ch = next((c for c in chapters if c["id"] == item.last_read_chapter_id), None)
                if ch:
                    chapter_title = ch["title"]
            result.append(BookshelfItem(
                id=item.id, book_id=item.book_id,
                book_title=book["title"] if book else "",
                book_author=book["author"] if book else "",
                cover_url=book.get("cover_url") if book else None,
                last_read_chapter_id=item.last_read_chapter_id,
                last_read_chapter_title=chapter_title,
                last_read_time=item.last_read_time,
                added_at=item.created_at,
            ))
        return result

    async def remove_book(self, db: Session, user: User, book_id: str) -> dict:
        removed = crud_bookshelf.remove(db, user.id, book_id)
        if not removed:
            raise NotFoundException(code="NOT_IN_BOOKSHELF", message="该图书不在书架中", detail={"book_id": book_id})
        return {"message": "已移出书架"}


bookshelf_service = BookshelfService()