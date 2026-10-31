class TestAuth:
    def test_register_success(self, client):
        resp = client.post("/api/v1/auth/register", json={"username": "newuser", "password": "pass123456"})
        assert resp.status_code == 201
        data = resp.json()
        assert data["username"] == "newuser"
        assert data["role"] == "user"
        assert "password_hash" not in data

    def test_register_duplicate(self, client):
        client.post("/api/v1/auth/register", json={"username": "dupuser", "password": "pass123456"})
        resp = client.post("/api/v1/auth/register", json={"username": "dupuser", "password": "pass123456"})
        assert resp.status_code == 409
        assert resp.json()["code"] == "USERNAME_EXISTS"

    def test_login_success(self, client):
        client.post("/api/v1/auth/register", json={"username": "loginuser", "password": "pass123456"})
        resp = client.post("/api/v1/auth/login", json={"username": "loginuser", "password": "pass123456"})
        assert resp.status_code == 200
        data = resp.json()
        assert "access_token" in data
        assert "refresh_token" in data

    def test_login_wrong_password(self, client):
        client.post("/api/v1/auth/register", json={"username": "wpuser", "password": "pass123456"})
        resp = client.post("/api/v1/auth/login", json={"username": "wpuser", "password": "wrongpass"})
        assert resp.status_code == 401
        assert resp.json()["code"] == "INVALID_CREDENTIALS"

    def test_login_nonexistent_user(self, client):
        resp = client.post("/api/v1/auth/login", json={"username": "ghost", "password": "pass123456"})
        assert resp.status_code == 401

    def test_get_current_user(self, client, auth_headers):
        resp = client.get("/api/v1/auth/me", headers=auth_headers)
        assert resp.status_code == 200
        assert resp.json()["username"] == "testuser"

    def test_get_current_user_no_token(self, client):
        resp = client.get("/api/v1/auth/me")
        assert resp.status_code == 401

    def test_refresh_token(self, client):
        client.post("/api/v1/auth/register", json={"username": "refuser", "password": "pass123456"})
        resp = client.post("/api/v1/auth/login", json={"username": "refuser", "password": "pass123456"})
        refresh = resp.json()["refresh_token"]
        resp2 = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh})
        assert resp2.status_code == 200
        assert "access_token" in resp2.json()

    def test_logout(self, client, auth_headers):
        resp = client.post("/api/v1/auth/logout", headers=auth_headers)
        assert resp.status_code == 200