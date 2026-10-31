from datetime import datetime, timedelta, timezone

import pytest
from jose import jwt

from app.core.config import settings
from app.core.exceptions import AuthException
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)


class TestPasswordHashing:
    def test_hash_is_not_plaintext(self):
        hashed = hash_password("secret123")
        assert hashed != "secret123"
        assert hashed.startswith("$2")

    def test_verify_correct_password(self):
        hashed = hash_password("secret123")
        assert verify_password("secret123", hashed) is True

    def test_verify_wrong_password(self):
        hashed = hash_password("secret123")
        assert verify_password("wrong-password", hashed) is False

    def test_hash_is_salted(self):
        assert hash_password("same-password") != hash_password("same-password")


class TestTokens:
    def test_access_token_payload(self):
        payload = decode_token(create_access_token("user-1", "admin"))
        assert payload["sub"] == "user-1"
        assert payload["type"] == "access"
        assert payload["role"] == "admin"

    def test_refresh_token_has_no_role(self):
        payload = decode_token(create_refresh_token("user-1"))
        assert payload["sub"] == "user-1"
        assert payload["type"] == "refresh"
        assert "role" not in payload

    def test_invalid_token_raises_auth_error(self):
        with pytest.raises(AuthException):
            decode_token("this-is-not-a-jwt")

    def test_expired_token_raises_auth_error(self):
        now = datetime.now(timezone.utc)
        payload = {
            "sub": "user-1",
            "type": "access",
            "iat": now - timedelta(hours=2),
            "exp": now - timedelta(hours=1),
        }
        token = jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
        with pytest.raises(AuthException):
            decode_token(token)

    def test_token_signed_with_wrong_secret_raises(self):
        now = datetime.now(timezone.utc)
        payload = {"sub": "user-1", "type": "access", "exp": now + timedelta(minutes=5)}
        token = jwt.encode(payload, "a-different-secret-key-value", algorithm=settings.JWT_ALGORITHM)
        with pytest.raises(AuthException):
            decode_token(token)