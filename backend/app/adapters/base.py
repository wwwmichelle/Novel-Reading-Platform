from abc import ABC, abstractmethod
from datetime import datetime


class DataSourceAdapter(ABC):
    @abstractmethod
    async def list_books(self, *, page: int = 1, page_size: int = 20) -> dict: ...

    @abstractmethod
    async def list_recent_books(self, *, limit: int = 10) -> dict: ...

    @abstractmethod
    async def get_book(self, book_id: str) -> dict | None: ...

    @abstractmethod
    async def list_chapters(self, book_id: str) -> list[dict]: ...

    @abstractmethod
    async def get_chapter(self, book_id: str, chapter_id: str) -> dict | None: ...

    @abstractmethod
    async def search(self, keyword: str, *, scope: str = "both", page: int = 1, page_size: int = 20) -> dict: ...

    @abstractmethod
    async def list_categories(self) -> list[dict]: ...

    @abstractmethod
    async def list_books_by_category(self, category_id: str, *, page: int = 1, page_size: int = 20) -> dict: ...

    @abstractmethod
    async def health_check(self) -> dict: ...