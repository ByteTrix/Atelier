"""Package manager core functionality."""

import os
import asyncio
import distro
from pathlib import Path
from typing import List, Dict, Optional, Callable, Any

from setupr.core.backends.package_base import Package, PackageBackend
from setupr.core.backends.apt import AptBackend
from setupr.core.backends.dnf import DnfBackend
from setupr.core.backends.pacman import PacmanBackend


class PackageManager:
    """Main package manager handling different backends based on the distribution."""
    
    def __init__(self):
        """Initialize the package manager with the appropriate backend."""
        self.backend = self._detect_backend()
        self.packages: List[Package] = []
        self.categories = [
            "Featured", "Developer", "Graphics", "Internet", 
            "Office", "Media", "System"
        ]
    
    def _detect_backend(self) -> PackageBackend:
        """Detect the appropriate backend based on the Linux distribution."""
        dist_id = distro.id()
        
        if dist_id in ['debian', 'ubuntu', 'linuxmint', 'pop']:
            return AptBackend()
        elif dist_id in ['fedora', 'rhel', 'centos', 'rocky']:
            return DnfBackend()
        elif dist_id in ['arch', 'manjaro', 'endeavouros']:
            return PacmanBackend()
        else:
            # Default to APT for demonstration
            return AptBackend()
    
    async def refresh_packages(self) -> None:
        """Refresh the package list from the backend."""
        self.packages = await self.backend.get_packages()
    
    async def search_packages(self, query: str) -> List[Package]:
        """Search for packages matching the query."""
        if not query:
            return self.packages
        
        return [pkg for pkg in self.packages if query.lower() in pkg.name.lower() or 
                (pkg.description and query.lower() in pkg.description.lower())]
    
    async def install_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Install a package and report progress."""
        return await self.backend.install_package(package_name, progress_callback)
    
    async def remove_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Remove a package and report progress."""
        return await self.backend.remove_package(package_name, progress_callback)
    
    async def update_package(self, package_name: str, progress_callback: Optional[Callable[[str, float], Any]] = None) -> bool:
        """Update a package and report progress."""
        return await self.backend.update_package(package_name, progress_callback)
    
    def get_packages_by_category(self, category: str) -> List[Package]:
        """Get packages filtered by category."""
        if category == "Featured":
            # For demo, just return top rated packages
            return sorted(self.packages, key=lambda pkg: pkg.rating or 0, reverse=True)[:10]
        
        # For real implementation, we would have category metadata
        # For demo, let's just assign some packages to categories based on name
        category_keywords = {
            "Developer": ["code", "editor", "ide", "python", "java", "gcc", "git"],
            "Graphics": ["gimp", "inkscape", "blender", "photo", "image", "draw"],
            "Internet": ["firefox", "chrome", "browser", "mail", "thunderbird", "wget"],
            "Office": ["libreoffice", "office", "document", "calc", "pdf"],
            "Media": ["vlc", "music", "video", "audio", "mpv", "player"],
            "System": ["admin", "monitor", "system", "disk", "cpu", "util"]
        }
        
        if category in category_keywords:
            keywords = category_keywords[category]
            return [pkg for pkg in self.packages if any(kw in pkg.name.lower() for kw in keywords)]
        
        return []


# Load sample data for demonstration
def load_sample_packages() -> List[Package]:
    """Load sample package data for demonstration."""
    return [
        Package(name="VS Code", version="1.85.1", size_mb=65, rating=4.5, description="Modern code editor with intelligent features, syntax highlighting, and Git integration.", installed=True),
        Package(name="PyCharm", version="2023.2", size_mb=450, rating=4.5, description="Professional IDE for Python development with advanced tools and features.", installed=False),
        Package(name="Sublime", version="4.0", size_mb=20, rating=4.0, description="Lightweight and fast text editor with powerful features and extensibility.", installed=False),
        Package(name="Atom", version="1.60.0", size_mb=120, rating=3.5, description="Hackable text editor for the 21st Century with collaborative features.", installed=False),
        Package(name="Neovim", version="0.9.1", size_mb=15, rating=5.0, description="Hyperextensible Vim-based text editor focused on extensibility and usability.", installed=True),
        Package(name="Emacs", version="28.2", size_mb=35, rating=4.5, description="Extensible, customizable, free/libre text editor with built-in lisp interpreter.", installed=False),
        Package(name="Kate", version="22.12.3", size_mb=18, rating=3.5, description="KDE Advanced Text Editor with features for developers.", installed=False),
        Package(name="Geany", version="2.0", size_mb=12, rating=4.0, description="Small and lightweight IDE with basic features for many languages.", installed=False),
        Package(name="Brackets", version="2.1", size_mb=80, rating=3.5, description="Modern, lightweight text editor with visual tools focused on web development.", installed=False),
        Package(name="Gedit", version="44.0", size_mb=10, rating=3.0, description="Official text editor of the GNOME desktop environment.", installed=False),
        Package(name="Eclipse", version="4.26", size_mb=300, rating=3.5, description="Extensible IDE supporting multiple programming languages and frameworks.", installed=False),
        Package(name="WebStorm", version="2023.2", size_mb=400, rating=4.5, description="Specialized IDE for JavaScript and web development with rich features.", installed=False),
    ]
