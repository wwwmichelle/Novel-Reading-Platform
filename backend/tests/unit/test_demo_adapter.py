import pytest

from app.adapters.demo import DemoDataAdapter


@pytest.fixture
def adapter():
    return DemoDataAdapter()


class TestDemoAdapterBooks:
    async def test_list_books_returns_all_demo_books(self, adapter):
        result = await adapter.list_books(page=1, page_size=50)
        assert result["total"] == 6
        assert len(result["items"]) == 6

    async def test_pagination_slices_without_overlap(self, adapter):
        page1 = await adapter.list_books(page=1, page_size=2)
        page2 = await adapter.list_books(page=2, page_size=2)
        assert len(page1["items"]) == 2
        assert len(page2["items"]) == 2
        ids1 = {b["id"] for b in page1["items"]}
        ids2 = {b["id"] for b in page2["items"]}
        assert ids1.isdisjoint(ids2)

    async def test_book_ids_are_unique(self, adapter):
        result = await adapter.list_books(page=1, page_size=50)
        ids = [b["id"] for b in result["items"]]
        assert len(ids) == len(set(ids))

    async def test_all_books_are_marked_demo(self, adapter):
        result = await adapter.list_books(page=1, page_size=50)
        assert all(b["is_demo"] is True for b in result["items"])

    async def test_get_book_detail(self, adapter):
        books = await adapter.list_books(page=1, page_size=50)
        book_id = books["items"][0]["id"]
        book = await adapter.get_book(book_id)
        assert book is not None
        assert book["id"] == book_id
        assert book["chapters"]

    async def test_get_book_unknown_returns_none(self, adapter):
        assert await adapter.get_book("not-exist") is None

    async def test_recent_books_respects_limit(self, adapter):
        result = await adapter.list_recent_books(limit=3)
        assert len(result["items"]) == 3
        assert result["total"] == 3


class TestDemoAdapterChapters:
    async def test_chapters_are_ordered(self, adapter):
        books = await adapter.list_books(page=1, page_size=50)
        book_id = books["items"][0]["id"]
        chapters = await adapter.list_chapters(book_id)
        assert [c["order"] for c in chapters] == list(range(len(chapters)))

    async def test_first_chapter_has_no_prev(self, adapter):
        books = await adapter.list_books(page=1, page_size=50)
        book_id = books["items"][0]["id"]
        chapters = await adapter.list_chapters(book_id)
        first = await adapter.get_chapter(book_id, chapters[0]["id"])
        assert first["prev_chapter_id"] is None
        assert first["next_chapter_id"] == chapters[1]["id"]

    async def test_last_chapter_has_no_next(self, adapter):
        books = await adapter.list_books(page=1, page_size=50)
        book_id = books["items"][0]["id"]
        chapters = await adapter.list_chapters(book_id)
        last = await adapter.get_chapter(book_id, chapters[-1]["id"])
        assert last["next_chapter_id"] is None
        assert last["prev_chapter_id"] == chapters[-2]["id"]

    async def test_chapter_content_not_empty(self, adapter):
        books = await adapter.list_books(page=1, page_size=50)
        book_id = books["items"][0]["id"]
        chapters = await adapter.list_chapters(book_id)
        chapter = await adapter.get_chapter(book_id, chapters[0]["id"])
        assert chapter["content"]
        assert chapter["word_count"] == len(chapter["content"])

    async def test_chapter_of_unknown_book_returns_none(self, adapter):
        assert await adapter.get_chapter("not-exist", "chapter-x") is None


class TestDemoAdapterSearch:
    async def test_search_by_title(self, adapter):
        result = await adapter.search("山海", scope="title")
        assert result["total"] == 1
        assert "山海" in result["items"][0]["title"]

    async def test_search_by_author(self, adapter):
        result = await adapter.search("陶渊明", scope="author")
        assert result["total"] == 1
        assert result["items"][0]["author"] == "陶渊明"

    async def test_search_both_scope(self, adapter):
        result = await adapter.search("佚名", scope="both")
        assert result["total"] >= 1

    async def test_search_no_result_is_empty(self, adapter):
        result = await adapter.search("绝对不存在的关键词zzz", scope="both")
        assert result["total"] == 0
        assert result["is_empty"] is True

    async def test_search_title_scope_ignores_author_match(self, adapter):
        result = await adapter.search("陶渊明", scope="title")
        assert result["total"] == 0


class TestDemoAdapterCategories:
    async def test_list_categories(self, adapter):
        categories = await adapter.list_categories()
        assert len(categories) == 6
        assert all("id" in c and "name" in c for c in categories)

    async def test_books_by_category(self, adapter):
        result = await adapter.list_books_by_category("cat-wuxia")
        assert result["total"] >= 1
        assert all("武侠" in b["categories"] for b in result["items"])

    async def test_books_by_unknown_category_is_empty(self, adapter):
        result = await adapter.list_books_by_category("cat-not-exist")
        assert result["total"] == 0
        assert result["is_empty"] is True

    async def test_health_check(self, adapter):
        health = await adapter.health_check()
        assert health["status"] == "ok"
        assert health["mode"] == "demo"