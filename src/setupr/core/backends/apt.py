"""APT package manager backend."""

import asyncio
import subprocess
from typing import List, Optional, Callable, Any

from setupr.core.backends.package_base import Package, PackageBackend
from setupr.core.backends.package_base import load_sample_packages


class AptBackend(PackageBackend):
    """Backend for APT package manager (Debian, Ubuntu)."""
    
    async def get_packages(self) -> List[Package]:
        """Get a list of available packages from APT."""
        # In a real implementation, we would parse output from 'apt list'
        # For demo purposes, return sample data
        return load_sample_packages()
    
    async def install_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Install a package using APT."""
        await self.simulate_progress("Installing", package_name, progress_callback)
        
        # In a real implementation, we would execute:
        # cmd = ["apt-get", "install", "-y", package_name]
        # subprocess.run(cmd, check=True)
        
        return True
    
    async def remove_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Remove a package using APT."""
        await self.simulate_progress("Removing", package_name, progress_callback)
        
        # In a real implementation, we would execute:
        # cmd = ["apt-get", "remove", "-y", package_name]
        # subprocess.run(cmd, check=True)
        
        return True
    
    async def update_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Update a package using APT."""
        await self.simulate_progress("Updating", package_name, progress_callback)
        
        # In a real implementation, we would execute:
        # cmd = ["apt-get", "upgrade", "-y", package_name]
        # subprocess.run(cmd, check=True)
        
        return True
