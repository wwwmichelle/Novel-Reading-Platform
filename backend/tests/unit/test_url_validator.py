import pytest

from app.adapters.url_validator import validate_url


class TestUrlValidator:
    @pytest.mark.parametrize(
        "url",
        [
            "https://api.example.com/books",
            "http://example.com",
            "https://example.com:8443/api/v1",
            "https://8.8.8.8/api",
        ],
    )
    def test_valid_public_urls(self, url):
        assert validate_url(url) is True

    @pytest.mark.parametrize(
        "url",
        [
            "http://localhost/api",
            "http://127.0.0.1/api",
            "http://127.1.2.3/api",
            "http://10.1.2.3/api",
            "http://172.16.0.5/api",
            "http://192.168.1.10/api",
            "http://169.254.1.1/api",
            "http://0.0.0.0/api",
            "ftp://example.com",
            "file:///etc/passwd",
            "",
            "not-a-url",
        ],
    )
    def test_invalid_unsafe_urls(self, url):
        assert validate_url(url) is False

    def test_non_string_input(self):
        assert validate_url(None) is False
        assert validate_url(123) is False