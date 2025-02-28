"""Tests for core package management functionality."""

import pytest
from unittest.mock import AsyncMock, MagicMock
import asyncio

from setupr.core.package_data import (
    PackageMetadata,
    get_package_by_name,
    search_packages,
    get_all_packages,
    get_category_packages,
    PACKAGE_CATEGORIES
)
from setupr.core.package_manager import (
    PackageManager,
    AptPackageManager,
    InstallProgress
)

# Package Data Tests

def test_package_metadata():
    """Test PackageMetadata class."""
    pkg = PackageMetadata(
        pkg_name="test-pkg",
        display_name="Test Package",
        category="Development",
        description="A test package",
        size="1.2 MB",
        installed=True
    )
    
    assert pkg.pkg_name == "test-pkg"
    assert pkg.display_name == "Test Package"
    assert pkg.category == "Development"
    assert pkg.description == "A test package"
    assert pkg.size == "1.2 MB"
    assert pkg.installed is True
    assert pkg.category_icon == "🔧"  # Development category icon
    assert "development tools" in pkg.category_description.lower()

def test_get_package_by_name():
    """Test package lookup by name."""
    # Test existing package
    pkg = get_package_by_name("git")
    assert pkg is not None
    assert pkg.pkg_name == "git"
    assert pkg.display_name == "Git"
    assert pkg.category == "Development"
    
    # Test non-existent package
    pkg = get_package_by_name("nonexistent-package")
    assert pkg is None

def test_search_packages():
    """Test package search functionality."""
    # Test search by package name
    results = search_packages("git")
    assert any(p.pkg_name == "git" for p in results)
    assert any(p.pkg_name == "git-lfs" for p in results)
    
    # Test search by display name
    results = search_packages("visual")
    assert any(p.pkg_name == "code" for p in results)
    assert any(p.display_name == "Visual Studio Code" for p in results)
    
    # Test search by category
    results = search_packages("database")
    assert any(p.category == "Databases" for p in results)
    
    # Test empty search
    results = search_packages("nonexistentxyz")
    assert len(results) == 0

def test_get_all_packages():
    """Test retrieving all packages."""
    packages = get_all_packages()
    total_packages = sum(len(cat["packages"]) for cat in PACKAGE_CATEGORIES.values())
    
    assert len(packages) == total_packages
    assert all(isinstance(p, PackageMetadata) for p in packages)

def test_get_category_packages():
    """Test retrieving packages by category."""
    # Test specific category
    dev_packages = get_category_packages("Development")
    assert len(dev_packages) == len(PACKAGE_CATEGORIES["Development"]["packages"])
    assert all(p.category == "Development" for p in dev_packages)
    
    # Test "All" category
    all_packages = get_category_packages("All")
    assert len(all_packages) == len(get_all_packages())
    
    # Test non-existent category
    invalid_packages = get_category_packages("NonExistentCategory")
    assert len(invalid_packages) == 0

# Package Manager Tests

class MockAptPackageManager(AptPackageManager):
    """Mock APT package manager for testing."""
    
    async def _mock_process(self, returncode=0, stdout="", stderr=""):
        mock_process = AsyncMock()
        mock_process.returncode = returncode
        mock_process.communicate.return_value = (stdout.encode(), stderr.encode())
        mock_process.stdout = AsyncMock()
        mock_process.stdout.readline = AsyncMock(return_value=b"")
        return mock_process

    async def get_package_size(self, package: str) -> str:
        """Mock implementation using hardcoded test data."""
        mock_output = """Package: test-package
Version: 1.0.0
Size: 1.2 MB
Description: Test package
 This is a longer description of the test package
 that spans multiple lines."""
        for line in mock_output.split("\n"):
            if line.startswith("Size:"):
                return line.split(":", 1)[1].strip()
        return "Unknown"

    async def get_package_description(self, package: str) -> str:
        """Mock implementation using hardcoded test data."""
        mock_output = """Package: test-package
Version: 1.0.0
Size: 1.2 MB
Description: Test package
 This is a longer description of the test package
 that spans multiple lines."""
        for line in mock_output.split("\n"):
            if line.startswith("Description:"):
                return line.split(":", 1)[1].strip()
        return "No description available"

@pytest.fixture
def mock_apt_manager(monkeypatch):
    """Fixture for mocked APT package manager."""
    manager = MockAptPackageManager()
    
    async def mock_subprocess(*args, **kwargs):
        if "dpkg" in args[0]:
            return await manager._mock_process(0, "ii  package")
        elif "apt" in args[0] and "show" in args[0]:
            return await manager._mock_process(0, """Package: test-package
Version: 1.0.0
Size: 1.2 MB
Description: Test package
 This is a longer description of the test package
 that spans multiple lines.""")
        elif "which" in args[0]:
            return await manager._mock_process(0)
        elif "pkexec" in args[0]:
            process = await manager._mock_process(0)
            process.stdout.readline = AsyncMock(side_effect=[
                b"Progress: [50%]\n",
                b"Progress: [100%]\n",
                b""
            ])
            return process
        return await manager._mock_process(1)
    
    monkeypatch.setattr(asyncio, "create_subprocess_exec", mock_subprocess)
    return manager

@pytest.mark.asyncio
async def test_package_installation_check(mock_apt_manager):
    """Test package installation check."""
    assert await mock_apt_manager.is_installed("test-package")

@pytest.mark.asyncio
async def test_package_info():
    """Test package info retrieval with both real and mock packages."""
    # Test with real git package
    manager = AptPackageManager()
    size = await manager.get_package_size("git")
    desc = await manager.get_package_description("git")
    
    # Should get valid values from the real package
    assert size != "Unknown"
    assert desc != "No description available"
    assert "MB" in size or "kB" in size
    assert desc.strip() != ""

    # Test with mock package
    mock_manager = MockAptPackageManager()
    size = await mock_manager.get_package_size("test-package")
    desc = await mock_manager.get_package_description("test-package")
    
    # Should match expected mock values
    assert size == "1.2 MB"
    assert desc == "Test package"

@pytest.mark.asyncio
async def test_package_installation(mock_apt_manager):
    """Test package installation process."""
    progress_updates = []
    
    def progress_callback(progress: InstallProgress):
        progress_updates.append(progress)
    
    success, message = await mock_apt_manager.install_packages(
        ["test-package"],
        progress_callback
    )
    
    assert success is True
    assert message == "Installation completed successfully"
    assert len(progress_updates) == 2
    assert progress_updates[0].percentage == 50
    assert progress_updates[1].percentage == 100