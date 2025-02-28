"""Package data and metadata handling."""

from typing import Dict, Optional

PACKAGE_CATEGORIES: Dict[str, Dict] = {
    "Development": {
        "packages": {
            "git": "Git",
            "python3": "Python",
            "nodejs": "Node.js",
            "vscode": "Visual Studio Code",
            "docker": "Docker",
            "docker-compose": "Docker Compose",
            "build-essential": "Build Essential Tools",
            "cmake": "CMake",
            "golang": "Go Language",
            "openjdk-17-jdk": "Java Development Kit 17",
            "maven": "Apache Maven",
            "npm": "Node Package Manager",
            "yarn": "Yarn Package Manager",
            "rust-all": "Rust Language",
            "gcc": "GNU C Compiler",
            "g++": "GNU C++ Compiler",
            "gdb": "GNU Debugger",
            "make": "GNU Make"
        },
        "description": "Essential development tools and languages",
        "icon": "🔧"
    },
    "IDEs & Editors": {
        "packages": {
            "code": "Visual Studio Code",
            "sublime-text": "Sublime Text",
            "vim": "Vim Editor",
            "neovim": "Neovim",
            "emacs": "Emacs Editor",
            "pycharm-community": "PyCharm Community",
            "intellij-idea-community": "IntelliJ IDEA Community",
            "android-studio": "Android Studio"
        },
        "description": "Code editors and integrated development environments",
        "icon": "📝"
    },
    "Databases": {
        "packages": {
            "postgresql": "PostgreSQL",
            "mysql-server": "MySQL Server",
            "mongodb-org": "MongoDB",
            "redis-server": "Redis",
            "sqlite3": "SQLite",
            "postgresql-client": "PostgreSQL Client",
            "mysql-client": "MySQL Client"
        },
        "description": "Database management systems and clients",
        "icon": "🗄️"
    },
    "Development Tools": {
        "packages": {
            "curl": "cURL",
            "wget": "Wget",
            "htop": "System Monitor",
            "tmux": "Terminal Multiplexer",
            "screen": "Screen",
            "zsh": "Z Shell",
            "git-lfs": "Git Large File Storage",
            "jq": "JSON Processor",
            "postman": "Postman API Platform",
            "wireshark": "Network Protocol Analyzer"
        },
        "description": "Additional tools for development workflow",
        "icon": "🛠️"
    },
    "Containers & Cloud": {
        "packages": {
            "docker": "Docker",
            "docker-compose": "Docker Compose",
            "kubectl": "Kubernetes CLI",
            "awscli": "AWS CLI",
            "google-cloud-sdk": "Google Cloud SDK",
            "azure-cli": "Azure CLI",
            "terraform": "Terraform"
        },
        "description": "Container and cloud infrastructure tools",
        "icon": "☁️"
    },
    "Web Servers": {
        "packages": {
            "nginx": "NGINX Web Server",
            "apache2": "Apache Web Server",
            "certbot": "Let's Encrypt Client"
        },
        "description": "Web servers and SSL certificate management",
        "icon": "🌐"
    },
    "System Tools": {
        "packages": {
            "htop": "System Monitor",
            "neofetch": "System Information Tool",
            "timeshift": "System Restore Tool",
            "gparted": "Partition Editor",
            "synaptic": "Package Manager",
            "net-tools": "Network Tools",
            "openssh-server": "SSH Server",
            "gnome-tweaks": "GNOME Customization"
        },
        "description": "System monitoring and management utilities",
        "icon": "⚙️"
    },
    "Utilities": {
        "packages": {
            "firefox": "Firefox Browser",
            "chromium-browser": "Chromium Browser",
            "telegram-desktop": "Telegram",
            "spotify-client": "Spotify",
            "discord": "Discord",
            "slack": "Slack",
            "zoom": "Zoom"
        },
        "description": "General purpose applications",
        "icon": "🔨"
    }
}

class PackageMetadata:
    """Package metadata container."""
    def __init__(
        self,
        pkg_name: str,
        display_name: str,
        category: str,
        description: str = "",
        size: str = "Unknown",
        installed: bool = False,
        status: str = "available"
    ):
        self.pkg_name = pkg_name
        self.display_name = display_name
        self.category = category
        self.description = description
        self.size = size
        self.installed = installed
        self.status = "installed" if installed else status

    @property
    def name(self) -> str:
        """Get package name (alias for pkg_name)."""
        return self.pkg_name

    @property
    def category_icon(self) -> str:
        """Get the icon for the package's category."""
        return PACKAGE_CATEGORIES.get(self.category, {}).get("icon", "📦")

    @property
    def category_description(self) -> str:
        """Get the description for the package's category."""
        return PACKAGE_CATEGORIES.get(self.category, {}).get("description", "")

def get_package_by_name(pkg_name: str) -> Optional[PackageMetadata]:
    """Get package metadata by package name."""
    for category, data in PACKAGE_CATEGORIES.items():
        if pkg_name in data["packages"]:
            return PackageMetadata(
                pkg_name=pkg_name,
                display_name=data["packages"][pkg_name],
                category=category
            )
    return None

def search_packages(query: str) -> list[PackageMetadata]:
    """Search for packages across all categories."""
    results = []
    query = query.lower()
    
    for category, data in PACKAGE_CATEGORIES.items():
        for pkg_name, display_name in data["packages"].items():
            if (query in pkg_name.lower() or 
                query in display_name.lower() or 
                query in category.lower() or 
                query in data["description"].lower()):
                
                results.append(PackageMetadata(
                    pkg_name=pkg_name,
                    display_name=display_name,
                    category=category,
                    description=data["description"]
                ))
    
    return results

def get_all_packages() -> list[PackageMetadata]:
    """Get all available packages."""
    packages = []
    for category, data in PACKAGE_CATEGORIES.items():
        for pkg_name, display_name in data["packages"].items():
            packages.append(PackageMetadata(
                pkg_name=pkg_name,
                display_name=display_name,
                category=category,
                description=data["description"]
            ))
    return packages

def get_category_packages(category: str) -> list[PackageMetadata]:
    """Get all packages in a specific category."""
    if category == "All":
        return get_all_packages()
        
    packages = []
    if category in PACKAGE_CATEGORIES:
        data = PACKAGE_CATEGORIES[category]
        for pkg_name, display_name in data["packages"].items():
            packages.append(PackageMetadata(
                pkg_name=pkg_name,
                display_name=display_name,
                category=category,
                description=data["description"]
            ))
    return packages