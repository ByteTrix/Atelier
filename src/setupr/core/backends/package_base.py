"""Base classes for package management."""

import asyncio
from typing import List, Optional, Callable, Any
from dataclasses import dataclass


@dataclass
class Package:
    """Base class representing a software package."""
    name: str
    version: str
    size_mb: float
    rating: Optional[float] = None
    description: Optional[str] = None
    installed: bool = False
    update_available: bool = False
    category: Optional[str] = None


class PackageBackend:
    """Base class for package manager backends."""
    
    async def get_packages(self) -> List[Package]:
        """Get a list of available packages."""
        raise NotImplementedError("Subclasses must implement get_packages")
    
    async def install_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Install a package."""
        raise NotImplementedError("Subclasses must implement install_package")
    
    async def remove_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Remove a package."""
        raise NotImplementedError("Subclasses must implement remove_package")
    
    async def update_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Update a package."""
        raise NotImplementedError("Subclasses must implement update_package")
    
    async def simulate_progress(self, operation: str, package_name: str, progress_callback: Optional[Callable[[str, float], Any]]) -> None:
        """Simulate operation progress for demonstration."""
        if progress_callback:
            for i in range(0, 101, 10):
                message = f"{operation} {package_name}..."
                progress_callback(message, i / 100.0)
                await asyncio.sleep(0.2)
