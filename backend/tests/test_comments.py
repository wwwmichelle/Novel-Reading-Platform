class TestComments:
    def test_list_comments_public(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.get(f"/api/v1/books/{book_id}/comments")
        assert resp.status_code == 200

    def test_create_comment_requires_auth(self, client):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.post(f"/api/v1/books/{book_id}/comments", json={"content": "test"})
        assert resp.status_code == 401

    def test_create_comment_success(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.post(f"/api/v1/books/{book_id}/comments", json={"content": "好书推荐"}, headers=auth_headers)
        assert resp.status_code == 201
        assert resp.json()["content"] == "好书推荐"

    def test_comment_xss_sanitized(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.post(f"/api/v1/books/{book_id}/comments", json={"content": "<script>alert(1)</script>好书"}, headers=auth_headers)
        assert resp.status_code == 201
        assert "<script>" not in resp.json()["content"]

    def test_delete_own_comment(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        create_resp = client.post(f"/api/v1/books/{book_id}/comments", json={"content": "to delete"}, headers=auth_headers)
        comment_id = create_resp.json()["id"]
        del_resp = client.delete(f"/api/v1/comments/{comment_id}", headers=auth_headers)
        assert del_resp.status_code == 200

    def test_delete_other_user_comment(self, client, auth_headers):
        client.post("/api/v1/auth/register", json={"username": "user2", "password": "pass123456"})
        login2 = client.post("/api/v1/auth/login", json={"username": "user2", "password": "pass123456"})
        headers2 = {"Authorization": f"Bearer {login2.json()['access_token']}"}

        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        create_resp = client.post(f"/api/v1/books/{book_id}/comments", json={"content": "user2 comment"}, headers=headers2)
        comment_id = create_resp.json()["id"]

        del_resp = client.delete(f"/api/v1/comments/{comment_id}", headers=auth_headers)
        assert del_resp.status_code == 403