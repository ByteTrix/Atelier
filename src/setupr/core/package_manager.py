"""Package management abstraction layer."""

import abc
import subprocess
from typing import List, Optional, Tuple
import distro
import asyncio
from dataclasses import dataclass

@dataclass
class InstallProgress:
    """Package installation progress information."""
    package: str
    percentage: float
    status: str
    details: str

class PackageManager(abc.ABC):
    """Abstract base class for package managers."""
    
    @abc.abstractmethod
    async def is_installed(self, package: str) -> bool:
        """Check if a package is installed."""
        pass
    
    @abc.abstractmethod
    async def get_package_size(self, package: str) -> str:
        """Get the installed/download size of a package."""
        pass
    
    @abc.abstractmethod
    async def get_package_description(self, package: str) -> str:
        """Get the description of a package."""
        pass
    
    @abc.abstractmethod
    async def install_packages(
        self,
        packages: List[str],
        progress_callback: callable
    ) -> Tuple[bool, str]:
        """Install packages and report progress."""
        pass

class AptPackageManager(PackageManager):
    """Debian/Ubuntu package manager implementation."""
    
    async def is_installed(self, package: str) -> bool:
        """Check if a package is installed using dpkg."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "dpkg", "-l", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            return "ii" in stdout.decode()
        except:
            return False
    
    async def get_package_size(self, package: str) -> str:
        """Get package size using apt show."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "apt", "show", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            print(f"\nDEBUG Package: {package}")
            print("DEBUG Output:", repr(output))
            
            for line in output.split("\n"):
                print("DEBUG Line:", repr(line))
                # Check for all possible size field formats
                if any(line.startswith(prefix) for prefix in ["Size:", "Installed-Size:", "Download-Size:"]):
                    size = line.split(":", 1)[1].strip()
                    print("DEBUG Found size:", repr(size))
                    return size
            print("DEBUG No size found")
            return "Unknown"
        except Exception as e:
            print("DEBUG Error:", str(e))
            return "Unknown"
    
    async def get_package_description(self, package: str) -> str:
        """Get package description using apt show."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "apt", "show", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            lines = output.split("\n")
            for i, line in enumerate(lines):
                if line.startswith("Description:"):
                    # Get the first line of description
                    return line.split(":", 1)[1].strip()
            return "No description available"
        except:
            return "No description available"
    
    async def install_packages(
        self,
        packages: List[str],
        progress_callback: callable
    ) -> Tuple[bool, str]:
        """Install packages using pkexec apt install."""
        try:
            # First check if pkexec is available
            proc = await asyncio.create_subprocess_exec(
                "which", "pkexec",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await proc.communicate()
            
            if proc.returncode != 0:
                return False, "pkexec not found. Please install policykit-1"
            
            # Start installation
            cmd = ["pkexec", "apt", "install", "-y"] + packages
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            # Monitor progress
            progress = 0
            while True:
                line = await proc.stdout.readline()
                if not line:
                    break
                    
                line = line.decode().strip()
                if "Progress:" in line:
                    try:
                        progress = int(line.split("[")[1].split("%")[0])
                    except:
                        pass
                
                progress_callback(InstallProgress(
                    package=", ".join(packages),
                    percentage=progress,
                    status="Installing...",
                    details=line
                ))
            
            # Get final result
            stdout, stderr = await proc.communicate()
            success = proc.returncode == 0
            
            if success:
                return True, "Installation completed successfully"
            else:
                return False, stderr.decode()
                
        except Exception as e:
            return False, str(e)

class DnfPackageManager(PackageManager):
    """Fedora/RHEL package manager implementation."""
    
    async def is_installed(self, package: str) -> bool:
        """Check if a package is installed using rpm."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "rpm", "-q", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await proc.communicate()
            return proc.returncode == 0
        except:
            return False
    
    async def get_package_size(self, package: str) -> str:
        """Get package size using dnf info."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "dnf", "info", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            for line in output.split("\n"):
                if "Size" in line or "Download size" in line:
                    return line.split(":", 1)[1].strip()
            return "Unknown"
        except:
            return "Unknown"
    
    async def get_package_description(self, package: str) -> str:
        """Get package description using dnf info."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "dnf", "info", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            lines = output.split("\n")
            description = []
            in_description = False
            
            for line in lines:
                if line.startswith("Description"):
                    in_description = True
                    continue
                elif in_description and line.strip():
                    description.append(line.strip())
                elif in_description and not line.strip():
                    break
            
            return " ".join(description) if description else "No description available"
        except:
            return "No description available"
    
    async def install_packages(
        self,
        packages: List[str],
        progress_callback: callable
    ) -> Tuple[bool, str]:
        """Install packages using pkexec dnf install."""
        try:
            # Check for pkexec
            proc = await asyncio.create_subprocess_exec(
                "which", "pkexec",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await proc.communicate()
            
            if proc.returncode != 0:
                return False, "pkexec not found. Please install polkit"
            
            # Start installation
            cmd = ["pkexec", "dnf", "install", "-y"] + packages
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            # Monitor progress
            progress = 0
            while True:
                line = await proc.stdout.readline()
                if not line:
                    break
                    
                line = line.decode().strip()
                # Try to estimate progress from DNF output
                if "Downloading Packages" in line:
                    progress = 25
                elif "Testing Transaction" in line:
                    progress = 50
                elif "Running Transaction" in line:
                    progress = 75
                elif "Complete!" in line:
                    progress = 100
                
                progress_callback(InstallProgress(
                    package=", ".join(packages),
                    percentage=progress,
                    status="Installing...",
                    details=line
                ))
            
            # Get final result
            stdout, stderr = await proc.communicate()
            success = proc.returncode == 0
            
            if success:
                return True, "Installation completed successfully"
            else:
                return False, stderr.decode()
                
        except Exception as e:
            return False, str(e)

class PacmanPackageManager(PackageManager):
    """Arch Linux package manager implementation."""
    
    async def is_installed(self, package: str) -> bool:
        """Check if a package is installed using pacman."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "pacman", "-Q", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await proc.communicate()
            return proc.returncode == 0
        except:
            return False
    
    async def get_package_size(self, package: str) -> str:
        """Get package size using pacman."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "pacman", "-Si", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            for line in output.split("\n"):
                if "Installed Size" in line:
                    return line.split(":", 1)[1].strip()
            return "Unknown"
        except:
            return "Unknown"
    
    async def get_package_description(self, package: str) -> str:
        """Get package description using pacman."""
        try:
            proc = await asyncio.create_subprocess_exec(
                "pacman", "-Si", package,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            stdout, _ = await proc.communicate()
            output = stdout.decode()
            
            lines = output.split("\n")
            description = []
            in_description = False
            
            for line in lines:
                if line.startswith("Description"):
                    description.append(line.split(":", 1)[1].strip())
                    in_description = True
                elif in_description and line.strip():
                    description.append(line.strip())
                elif in_description and not line.strip():
                    break
            
            return " ".join(description) if description else "No description available"
        except:
            return "No description available"
    
    async def install_packages(
        self,
        packages: List[str],
        progress_callback: callable
    ) -> Tuple[bool, str]:
        """Install packages using pkexec pacman."""
        try:
            # Check for pkexec
            proc = await asyncio.create_subprocess_exec(
                "which", "pkexec",
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            await proc.communicate()
            
            if proc.returncode != 0:
                return False, "pkexec not found. Please install polkit"
            
            # Start installation
            cmd = ["pkexec", "pacman", "-S", "--noconfirm"] + packages
            proc = await asyncio.create_subprocess_exec(
                *cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            # Monitor progress
            progress = 0
            while True:
                line = await proc.stdout.readline()
                if not line:
                    break
                    
                line = line.decode().strip()
                # Try to estimate progress from pacman output
                if "resolving dependencies" in line.lower():
                    progress = 25
                elif "checking conflicts" in line.lower():
                    progress = 50
                elif "downloading " in line.lower():
                    progress = 75
                elif "installing " in line.lower():
                    progress = 90
                
                progress_callback(InstallProgress(
                    package=", ".join(packages),
                    percentage=progress,
                    status="Installing...",
                    details=line
                ))
            
            # Get final result
            stdout, stderr = await proc.communicate()
            success = proc.returncode == 0
            
            if success:
                return True, "Installation completed successfully"
            else:
                return False, stderr.decode()
                
        except Exception as e:
            return False, str(e)

def get_package_manager() -> PackageManager:
    """Get the appropriate package manager for the current system."""
    system = distro.id()
    
    if system in ["ubuntu", "debian", "linuxmint"]:
        return AptPackageManager()
    elif system in ["fedora", "rhel", "centos"]:
        return DnfPackageManager()
    elif system == "arch":
        return PacmanPackageManager()
    else:
        # Default to apt for now
        return AptPackageManager()

async def install_package(package_name: str, progress_callback: callable = None) -> None:
    """Install a package using the appropriate package manager."""
    pkg_mgr = get_package_manager()
    
    if not progress_callback:
        progress_callback = lambda x: None
        
    try:
        success, message = await pkg_mgr.install_packages([package_name], progress_callback)
        if not success:
            raise RuntimeError(message)
    except Exception as e:
        raise RuntimeError(f"Failed to install {package_name}: {str(e)}")