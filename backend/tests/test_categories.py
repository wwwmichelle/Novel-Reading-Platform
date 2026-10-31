class TestCategories:
    def test_list_categories(self, client):
        resp = client.get("/api/v1/categories")
        assert resp.status_code == 200
        cats = resp.json()
        assert len(cats) > 0

    def test_books_by_category(self, client):
        cats = client.get("/api/v1/categories").json()
        cat_id = cats[0]["id"]
        resp = client.get(f"/api/v1/categories/{cat_id}/books")
        assert resp.status_code == 200
        data = resp.json()
        assert "items" in data

    def test_nonexistent_category(self, client):
        resp = client.get("/api/v1/categories/nonexistent-cat/books")
        assert resp.status_code == 200
        data = resp.json()
        assert data["total"] == 0