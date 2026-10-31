import pytest

from app.adapters.real import RealDataAdapter, is_allowed_source_url, load_catalogue


def test_curated_catalogue_has_unique_literature_titles_and_real_sources():
    adapter = RealDataAdapter()
    assert len(adapter.books) == 30
    assert len({book["id"] for book in adapter.books}) == 30
    assert len({book["title"] for book in adapter.books}) == 30
    assert {book["title"] for book in adapter.books} >= {"呐喊", "骆驼祥子", "围城", "活着"}
    assert all(book["reading_mode"] == "external" for book in adapter.books)
    assert all(is_allowed_source_url(book["source_url"]) for book in adapter.books)
    assert all("qimao.com" not in book["source_url"] for book in adapter.books)


@pytest.mark.parametrize("url", [
    "https://www.dedao.cn/ebook/detail?id=abc123",
    "https://e.dangdang.com/touch/products/1900717559.html",
])
def test_accepts_official_book_pages(url):
    assert is_allowed_source_url(url)


@pytest.mark.parametrize("url", [
    "javascript:alert(1)", "http://www.dedao.cn/ebook/detail?id=abc",
    "https://www.dedao.cn.evil.com/ebook/detail?id=abc",
    "https://evil.com@www.dedao.cn/ebook/detail?id=abc",
    "https://www.dedao.cn/ebook/detail?id=abc&redirect=https://evil.com",
    "https://e.dangdang.com/touch/products/../evil.html",
])
def test_rejects_untrusted_source_links(url):
    assert not is_allowed_source_url(url)
