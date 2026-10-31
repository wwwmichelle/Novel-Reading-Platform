import pytest

from app.adapters import id_mapper


@pytest.fixture(autouse=True)
def clean_mapping():
    id_mapper.clear_mapping()
    yield
    id_mapper.clear_mapping()


class TestIdMapper:
    def test_mapping_is_deterministic(self):
        first = id_mapper.map_external_id("demo", "book-1")
        second = id_mapper.map_external_id("demo", "book-1")
        assert first == second

    def test_mapping_is_valid_uuid(self):
        from uuid import UUID

        value = id_mapper.map_external_id("demo", "book-1")
        assert str(UUID(value)) == value

    def test_same_external_id_different_source_differs(self):
        assert id_mapper.map_external_id("demo", "1") != id_mapper.map_external_id("real", "1")

    def test_get_internal_id_returns_none_when_unmapped(self):
        assert id_mapper.get_internal_id("demo", "missing") is None

    def test_get_internal_id_after_mapping(self):
        internal = id_mapper.map_external_id("demo", "book-7")
        assert id_mapper.get_internal_id("demo", "book-7") == internal

    def test_clear_mapping(self):
        id_mapper.map_external_id("demo", "book-9")
        id_mapper.clear_mapping()
        assert id_mapper.get_internal_id("demo", "book-9") is None