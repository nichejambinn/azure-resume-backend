from typing import Generator

import pytest
from playwright.sync_api import Playwright, APIRequestContext

@pytest.fixture(scope="session")
def api_request_context(playwright: Playwright) -> Generator[APIRequestContext, None, None]:
    request_context = playwright.request.new_context(
        base_url="https://resumeapp-engorge.azurewebsites.net"
    )
    yield request_context
    request_context.dispose()

def test_returns_value(api_request_context: APIRequestContext) -> None:
    call = api_request_context.post("/api/inc_visitors")
    assert call.ok

    count = int(call.json())

    # the response data should be non-zero
    assert count > 0

def test_updates_database(api_request_context: APIRequestContext) -> None:
    first_call = api_request_context.post("/api/inc_visitors")
    second_call = api_request_context.post("/api/inc_visitors")
    assert first_call.ok and second_call.ok

    # the second call should be one greater than the first
    assert int(second_call.json()) == int(first_call.json()) + 1
