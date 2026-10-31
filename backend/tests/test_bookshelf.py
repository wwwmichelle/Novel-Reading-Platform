class TestBookshelf:
    def test_bookshelf_requires_auth(self, client):
        resp = client.get("/api/v1/bookshelf")
        assert resp.status_code == 401

    def test_add_book(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        resp = client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        assert resp.status_code == 201

    def test_add_duplicate_idempotent(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        resp2 = client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        assert resp2.status_code == 201
        shelf = client.get("/api/v1/bookshelf", headers=auth_headers).json()
        assert len([i for i in shelf if i["book_id"] == book_id]) == 1

    def test_list_bookshelf(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        resp = client.get("/api/v1/bookshelf", headers=auth_headers)
        assert resp.status_code == 200
        assert len(resp.json()) > 0

    def test_remove_book(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        resp = client.delete(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)
        assert resp.status_code == 200

    def test_user_isolation(self, client, auth_headers):
        books = client.get("/api/v1/books").json()
        book_id = books["items"][0]["id"]
        client.post(f"/api/v1/bookshelf/{book_id}", headers=auth_headers)

        client.post("/api/v1/auth/register", json={"username": "iso_user", "password": "pass123456"})
        login2 = client.post("/api/v1/auth/login", json={"username": "iso_user", "password": "pass123456"})
        headers2 = {"Authorization": f"Bearer {login2.json()['access_token']}"}
        shelf2 = client.get("/api/v1/bookshelf", headers=headers2).json()
        assert len(shelf2) == 0
def test_retired_catalogue_entries_are_preserved_without_blank_shelf_cards(client, auth_headers, db_session):
    from app.models.bookshelf import Bookshelf

    user = client.get('/api/v1/auth/me', headers=auth_headers).json()
    item = Bookshelf(user_id=user['id'], book_id='retired-catalogue-book')
    db_session.add(item)
    db_session.commit()
    response = client.get('/api/v1/bookshelf', headers=auth_headers)
    assert response.status_code == 200
    assert all(book['book_id'] != 'retired-catalogue-book' for book in response.json())
    assert db_session.query(Bookshelf).filter_by(id=item.id).count() == 1
