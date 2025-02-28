"""System utilities and package name mappings."""

import distro
from typing import Dict, Optional

# Package name mappings between distributions
PACKAGE_MAPPINGS: Dict[str, Dict[str, str]] = {
    "ubuntu": {  # Base mapping (ubuntu package names)
        "git": "git",
        "python3": "python3",
        "nodejs": "nodejs",
        "docker": "docker.io",
        "docker-compose": "docker-compose",
        "vscode": "code",
        "postgresql": "postgresql",
        "nginx": "nginx",
        "vim": "vim",
    },
    "fedora": {
        "docker.io": "docker-ce",
        "code": "code",  # From VSCode repo
        "build-essential": "gcc gcc-c++ make",
    },
    "arch": {
        "docker.io": "docker",
        "python3": "python",
        "code": "code",  # From AUR
        "build-essential": "base-devel",
    }
}

def get_native_package_name(package: str, target_distro: Optional[str] = None) -> str:
    """Convert package name to distribution-specific name."""
    if target_distro is None:
        target_distro = distro.id()
    
    # If no mapping exists for this distro, return original name
    if target_distro not in PACKAGE_MAPPINGS:
        return package
        
    # Get package mapping for this distro
    distro_map = PACKAGE_MAPPINGS[target_distro]
    
    # Return mapped name if it exists, otherwise return original
    return distro_map.get(package, package)

def get_distribution_info() -> Dict[str, str]:
    """Get current distribution information."""
    return {
        "id": distro.id(),
        "name": distro.name(pretty=True),
        "version": distro.version(pretty=True),
        "codename": distro.codename(),
    }

def check_pkexec() -> bool:
    """Check if pkexec is available."""
    try:
        import shutil
        return shutil.which("pkexec") is not None
    except:
        return False

def format_size(size_bytes: int) -> str:
    """Format size in bytes to human readable string."""
    for unit in ["B", "KB", "MB", "GB"]:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} TB"