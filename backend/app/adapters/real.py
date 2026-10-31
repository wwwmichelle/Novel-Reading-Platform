"""Curated Chinese modern and contemporary literature, linked to official ebook pages.

Bibliographic entries and original introductions are maintained in the packaged
catalogue. No copyrighted full text is copied or promised as freely available.
"""
import json
from pathlib import Path
import re

from app.adapters.base import DataSourceAdapter
from app.adapters.id_mapper import map_external_id

CATEGORIES = [
    {"id": "long", "name": "长篇小说"},
    {"id": "short", "name": "中短篇小说"},
    {"id": "essay", "name": "散文诗歌"},
    {"id": "drama", "name": "戏剧文学"},
]


def is_allowed_source_url(value: str) -> bool:
    return bool(re.fullmatch(
        r"https://(?:www\.dedao\.cn/ebook/detail\?id=[A-Za-z0-9]+|"
        r"e\.dangdang\.com/touch/products/[0-9]+\.html)", value
    ))


def load_catalogue(path: Path) -> list[dict]:
    records = json.loads(path.read_text(encoding="utf-8"))
    category_names = {item["id"]: item["name"] for item in CATEGORIES}
    slugs = set()
    books = []
    for item in records:
        if item["slug"] in slugs or not is_allowed_source_url(item["source_url"]):
            raise ValueError("Duplicate book or unsupported source URL")
        slugs.add(item["slug"])
        books.append({
            "id": map_external_id("chinese-literature", item["slug"]),
            "title": item["title"], "author": item["author"],
            "cover_url": item.get("cover_url"), "serial_status": "completed",
            "description": item["description"] + "\n来源：" + item["source_name"] + "。可在源站查看版本、试读或阅读；完整阅读条件以源站为准。",
            "categories": [category_names[item["category"]]],
            "latest_chapter_title": None, "is_demo": False,
            "updated_at": "2026-11-01T00:00:00+08:00",
            "source_name": item["source_name"], "source_url": item["source_url"],
            "reading_mode": "external",
        })
    if len(books) != 30:
        raise ValueError("Expected 30 literature titles")
    return books


class RealDataAdapter(DataSourceAdapter):
    def __init__(self):
        self.books = load_catalogue(Path(__file__).with_name("literature_catalogue.json"))

    @staticmethod
    def _page(books, page, page_size):
        return {"items": books[(page - 1) * page_size:page * page_size], "total": len(books),
                "page": page, "page_size": page_size, "is_empty": not books}

    async def list_books(self, *, page=1, page_size=20):
        return self._page(self.books, page, page_size)

    async def list_recent_books(self, *, limit=10):
        return {"items": self.books[:limit], "total": len(self.books[:limit])}

    async def get_book(self, book_id):
        return next((book for book in self.books if book["id"] == book_id), None)

    async def list_chapters(self, book_id):
        return []

    async def get_chapter(self, book_id, chapter_id):
        return None

    async def search(self, keyword, *, scope="both", page=1, page_size=20):
        fields = ("title", "author") if scope == "both" else (scope,)
        books = [book for book in self.books if any(keyword.casefold() in book[field].casefold() for field in fields)]
        return self._page(books, page, page_size)

    async def list_categories(self):
        return CATEGORIES

    async def list_books_by_category(self, category_id, *, page=1, page_size=20):
        category = next((item for item in CATEGORIES if item["id"] == category_id), None)
        books = [book for book in self.books if category and category["name"] in book["categories"]]
        return self._page(books, page, page_size)

    async def health_check(self):
        return {"status": "ok", "mode": "real", "source": "中国现当代文学精选（得到电子书、当当读书）",
                "books": len(self.books), "reading_mode": "external"}
