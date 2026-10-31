class TestSearch:
    def test_search_by_title(self, client):
        resp = client.get("/api/v1/search?keyword=山海")
        assert resp.status_code == 200
        assert resp.json()["total"] > 0

    def test_search_by_author(self, client):
        resp = client.get("/api/v1/search?keyword=佚名&scope=author")
        assert resp.status_code == 200

    def test_search_empty_keyword(self, client):
        resp = client.get("/api/v1/search?keyword=")
        assert resp.status_code in (400, 422)

    def test_search_no_result(self, client):
        resp = client.get("/api/v1/search?keyword=不存在的书名xyz123")
        assert resp.status_code == 200
        assert resp.json()["total"] == 0

    def test_search_pagination(self, client):
        resp = client.get("/api/v1/search?keyword=的&page=1&page_size=2")
        assert resp.status_code == 200