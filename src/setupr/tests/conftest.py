"""Shared pytest fixtures."""

import pytest
import asyncio
from unittest.mock import AsyncMock

from setupr.core.package_manager import AptPackageManager

class MockProcessManager:
    """Mock process manager for testing."""
    
    def __init__(self, returncode=0, stdout="", stderr=""):
        self.returncode = returncode
        self.stdout = stdout.encode()
        self.stderr = stderr.encode()
    
    async def create_process(self, *args, **kwargs):
        """Create a mock process."""
        process = AsyncMock()
        process.returncode = self.returncode
        process.communicate.return_value = (self.stdout, self.stderr)
        process.stdout = AsyncMock()
        process.stdout.readline = AsyncMock(return_value=b"")
        return process

@pytest.fixture
def mock_process():
    """Fixture for creating mock processes."""
    return MockProcessManager()

@pytest.fixture
def event_loop():
    """Create and provide event loop for async tests."""
    loop = asyncio.new_event_loop()
    yield loop
    loop.close()

@pytest.fixture
def pkg_manager():
    """Provide a package manager instance."""
    return AptPackageManager()