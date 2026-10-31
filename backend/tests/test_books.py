class TestBooks:
    def test_list_books(self, client):
        resp = client.get("/api/v1/books")
        assert resp.status_code == 200
        data = resp.json()
        assert "items" in data
        assert "total" in data
        assert data["total"] > 0

    def test_list_books_pagination(self, client):
        resp = client.get("/api/v1/books?page=1&page_size=2")
        assert resp.status_code == 200
        data = resp.json()
        assert len(data["items"]) <= 2

    def test_list_recent_books(self, client):
        resp = client.get("/api/v1/books/recent?limit=5")
        assert resp.status_code == 200
        data = resp.json()
        assert "items" in data

    def test_get_book_detail(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.get(f"/api/v1/books/{book_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["id"] == book_id
        assert "title" in data

    def test_get_book_not_found(self, client):
        resp = client.get("/api/v1/books/nonexistent-id")
        assert resp.status_code == 404
        assert resp.json()["code"] == "BOOK_NOT_FOUND"

    def test_list_chapters(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.get(f"/api/v1/books/{book_id}/chapters")
        assert resp.status_code == 200
        chapters = resp.json()
        assert len(chapters) > 0

    def test_get_chapter(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        chapters = client.get(f"/api/v1/books/{book_id}/chapters").json()
        chapter_id = chapters[0]["id"]
        resp = client.get(f"/api/v1/books/{book_id}/chapters/{chapter_id}")
        assert resp.status_code == 200
        data = resp.json()
        assert data["id"] == chapter_id
        assert "content" in data

    def test_chapter_prev_next(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        chapters = client.get(f"/api/v1/books/{book_id}/chapters").json()
        first = client.get(f"/api/v1/books/{book_id}/chapters/{chapters[0]['id']}").json()
        assert first["prev_chapter_id"] is None
        assert first["next_chapter_id"] is not None
        last = client.get(f"/api/v1/books/{book_id}/chapters/{chapters[-1]['id']}").json()
        assert last["next_chapter_id"] is None

    def test_demo_flag(self, client):
        resp = client.get("/api/v1/books")
        data = resp.json()
        assert all(item["is_demo"] == True for item in data["items"])