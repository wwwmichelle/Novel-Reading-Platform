from datetime import datetime, timezone


class TestReadingProgress:
    def test_report_requires_auth(self, client):
        resp = client.put("/api/v1/reading-progress/book1", json={
            "chapter_id": "ch1", "chapter_order": 0, "scroll_position": 0.5,
            "client_timestamp": datetime.now(timezone.utc).isoformat(),
        })
        assert resp.status_code == 401

    def test_report_progress(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        chapters = client.get(f"/api/v1/books/{book_id}/chapters").json()
        ch_id = chapters[0]["id"]
        resp = client.put(f"/api/v1/reading-progress/{book_id}", json={
            "chapter_id": ch_id, "chapter_order": 0, "scroll_position": 0.3,
            "client_timestamp": datetime.now(timezone.utc).isoformat(),
        }, headers=auth_headers)
        assert resp.status_code == 200

    def test_get_progress(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        chapters = client.get(f"/api/v1/books/{book_id}/chapters").json()
        ch_id = chapters[0]["id"]
        client.put(f"/api/v1/reading-progress/{book_id}", json={
            "chapter_id": ch_id, "chapter_order": 0, "scroll_position": 0.5,
            "client_timestamp": datetime.now(timezone.utc).isoformat(),
        }, headers=auth_headers)
        resp = client.get(f"/api/v1/reading-progress/{book_id}", headers=auth_headers)
        assert resp.status_code == 200
        assert resp.json()["chapter_id"] == ch_id

    def test_progress_not_found(self, client, auth_headers):
        resp = client.get("/api/v1/reading-progress/nonexistent-book", headers=auth_headers)
        assert resp.status_code == 404