import os
import json
from typing import Dict, List
import distro
import subprocess
from textual import on, work, events
from textual.app import App, ComposeResult
from textual.message import Message
from textual.containers import Horizontal, VerticalScroll, Vertical
from textual.widgets import Header, Footer, Static, Input, ListView, Button, Label
from textual.binding import Binding
from rich.text import Text
from setupr.ui.widgets import PackageItem

PACKAGE_CATEGORIES = {
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
        "description": "Essential development tools and languages"
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
        "description": "Code editors and integrated development environments"
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
        "description": "Database management systems and clients"
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
        "description": "Additional tools for development workflow"
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
        "description": "Container and cloud infrastructure tools"
    },
    "Web Servers": {
        "packages": {
            "nginx": "NGINX Web Server",
            "apache2": "Apache Web Server",
            "certbot": "Let's Encrypt Client"
        },
        "description": "Web servers and SSL certificate management"
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
        "description": "System monitoring and management utilities"
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
        "description": "General purpose applications"
    }
}

class PackagesLoaded(Message):
    """Posted when packages are loaded."""
    def __init__(self, packages: Dict[str, Dict]) -> None:
        self.packages = packages
        super().__init__()

class SetuprApp(App):
    CSS_PATH = "main.css"  # Path relative to this module's directory
    TITLE = f"Development Package Installer – {distro.name(pretty=True)}"

    BINDINGS = [
        Binding("q", "quit", "Quit", show=True),
        Binding("up", "cursor_up", "Move Up", show=False),
        Binding("down", "cursor_down", "Move Down", show=False),
        Binding("enter", "toggle_package", "Toggle", show=True),
        Binding("i", "install_selected", "Install Selected", show=True),
        Binding("s", "search_focus", "Search", show=True),
        Binding("/", "search_focus", "Search", show=False),
    ]

    def __init__(self):
        super().__init__()
        self.packages: Dict[str, Dict] = {}
        self.package_cache: Dict[str, Dict] = {}
        self.selected_category = "All"
        self.selected_package = None
        self.is_loading = False

    def compose(self) -> ComposeResult:
        """Compose the UI layout."""
        yield Header(show_clock=True)
        
        yield Horizontal(
            # Sidebar: Categories & Search
            Vertical(
                Static("Categories:", classes="section-title"),
                *[Button(cat, classes="category-button") for cat in ["All"] + list(PACKAGE_CATEGORIES.keys())],
                Input(placeholder="Search packages... (Press '/')", id="search_input"),
                Button("Install Selected", variant="primary", id="install_btn"),
                id="sidebar"
            ),
            # Main Content: Package list & Details pane
            Horizontal(
                VerticalScroll(
                    ListView(id="package_list")
                ),
                Vertical(
                    Static("Package Details", classes="section-title"),
                    Static(id="details", expand=True),
                    id="details_container"
                ),
                id="main_content"
            )
        )
        yield Footer()

    def on_mount(self) -> None:
        """Initialize the app when mounted."""
        # Show initial empty state
        self.selected_category = "All"
        self.query_one("#details").update("Select a package to view details")
        
        # Initialize the package list with loading state
        self.update_package_list()
        
        # Start loading package details in background
        self.load_packages()
        
        # Focus the package list
        self.query_one("#package_list").focus()

    @on(Button.Pressed)
    def handle_button_pressed(self, event: Button.Pressed) -> None:
        """Handle button presses."""
        if event.button.has_class("category-button"):
            # Convert Text object to string
            category = str(event.button.label).strip()
            self.selected_category = category
            # Update package list immediately
            self.update_package_list()

    @work(thread=True)
    def load_packages(self) -> None:
        """Load package information asynchronously using cache."""
        packages = {}
        self.is_loading = True
        
        for category, category_data in PACKAGE_CATEGORIES.items():
            category_desc = category_data["description"]
            for pkg_name, common_name in category_data["packages"].items():
                # First check cache
                if pkg_name in self.package_cache:
                    packages[pkg_name] = self.package_cache[pkg_name]
                    continue

                # Check if package is installed first (faster operation)
                is_installed = self._check_package_installed(pkg_name)
                
                # Create initial entry with basic info
                initial_info = {
                    "name": common_name,
                    "pkg_name": pkg_name,
                    "category": category,
                    "category_description": category_desc,
                    "description": f"Loading details for {pkg_name}...",
                    "installed": is_installed,
                    "size": "Loading..."
                }
                
                packages[pkg_name] = initial_info
                self.package_cache[pkg_name] = initial_info
                self.post_message(PackagesLoaded(packages.copy()))
                
                # Then load detailed info
                size = self._get_package_size(pkg_name)
                apt_description = self._get_package_description(pkg_name)
                
                # If apt_description is not available, use category description
                description = apt_description
                if description == "No description available":
                    description = f"{category_desc} ({pkg_name})"
                
                # Update with full info
                detailed_info = {
                    "name": common_name,
                    "pkg_name": pkg_name,
                    "category": category,
                    "category_description": category_desc,
                    "description": description,
                    "installed": is_installed,
                    "size": size
                }
                
                packages[pkg_name] = detailed_info
                self.package_cache[pkg_name] = detailed_info

        self.is_loading = False
        self.post_message(PackagesLoaded(packages))

    @on(PackagesLoaded)
    def handle_packages_loaded(self, message: PackagesLoaded) -> None:
        """Handle when packages are loaded."""
        self.packages = message.packages
        self.update_package_list()

    def _check_package_installed(self, package: str) -> bool:
        """Check if a package is installed."""
        try:
            result = subprocess.run(
                ["dpkg", "-l", package],
                capture_output=True,
                text=True
            )
            return "ii" in result.stdout
        except:
            return False

    def _get_package_size(self, package: str) -> str:
        """Get the package size."""
        try:
            result = subprocess.run(
                ["apt", "show", package],
                capture_output=True,
                text=True
            )
            for line in result.stdout.split("\n"):
                if "Size:" in line:
                    size = line.split(":")[1].strip()
                    return size
        except:
            pass
        return "Unknown"

    def _get_package_description(self, package: str) -> str:
        """Get the package description."""
        try:
            result = subprocess.run(
                ["apt", "show", package],
                capture_output=True,
                text=True
            )
            description = ""
            in_description = False
            for line in result.stdout.split("\n"):
                if line.startswith("Description:"):
                    description = line.split(":", 1)[1].strip()
                    in_description = True
                elif in_description and line.startswith(" "):
                    description += " " + line.strip()
                elif in_description:
                    break
            return description or "No description available"
        except:
            return "No description available"

    def on_list_view_selected(self, event: ListView.Selected) -> None:
        """Update details when a package is selected."""
        item = event.item
        if isinstance(item, PackageItem):
            if self.selected_package == item.pkg_name:
                # If clicking the same package, clear details
                self.selected_package = None
                self.query_one("#details").update("Select a package to view details")
            else:
                # Show details for newly selected package
                self.selected_package = item.pkg_name
                pkg_info = self.packages.get(item.pkg_name, {})
                category = pkg_info.get('category', 'Unknown')
                
                if self.is_loading and pkg_info.get('description', '').startswith('Loading'):
                    details = ["Loading package details..."]
                else:
                    details = [
                        f"🔍 Package: {pkg_info.get('name', item.pkg_name)}",
                        f"📦 Status: {item.pkg_status}",
                        f"💾 Size: {item.pkg_size}",
                        f"🏷️ Category: {category}",
                        "",
                        "📝 Category Description:",
                        PACKAGE_CATEGORIES.get(category, {}).get('description', 'No category description'),
                        "",
                        "ℹ️ Package Description:",
                        pkg_info.get('description', 'No description available')
                    ]
                self.query_one("#details").update("\n".join(details))

    def update_package_list(self, filter_text: str = "") -> None:
        """Update the package list based on category and search filter."""
        list_view = self.query_one("#package_list")
        list_view.clear()

        # Get package list based on category
        packages_to_show = set()  # Use set for faster lookups
        if self.selected_category == "All":
            # For "All" category, combine all packages
            for category_data in PACKAGE_CATEGORIES.values():
                packages_to_show.update(category_data["packages"].keys())
        else:
            # For specific category
            category_data = PACKAGE_CATEGORIES.get(self.selected_category, {})
            packages_to_show.update(category_data.get("packages", {}).keys())

        # Filter by search text if any
        if filter_text:
            filter_text = filter_text.lower()
            filtered_packages = set()
            for pkg_name in packages_to_show:
                pkg_info = self.packages.get(pkg_name, {})
                display_name = pkg_info.get("name", pkg_name)
                if (filter_text in pkg_name.lower() or 
                    filter_text in display_name.lower()):
                    filtered_packages.add(pkg_name)
            packages_to_show = filtered_packages

        # Sort packages for consistent display
        packages_to_show = sorted(packages_to_show)

        # Create PackageItem for each package
        for pkg_name in packages_to_show:
            pkg_info = self.packages.get(pkg_name, {})
            is_installed = pkg_info.get("installed", False)
            display_name = pkg_info.get("name", pkg_name)
            
            list_view.append(
                PackageItem(
                    pkg_name=pkg_name,
                    name=display_name,
                    description="",  # No description in list view
                    size="",  # Size shown in details panel
                    status="Installed" if is_installed else "Not Installed"
                )
            )
        
        # Update window title
        count = len(packages_to_show)
        if self.selected_category == "All":
            self.sub_title = f"All Packages ({count})"
        else:
            self.sub_title = f"{self.selected_category} ({count})"

    @on(Input.Changed, "#search_input")
    def on_search_changed(self, event: Input.Changed) -> None:
        """Handle search input changes."""
        self.update_package_list(event.value)

    def action_search_focus(self) -> None:
        """Focus the search input."""
        self.query_one("#search_input").focus()

    def action_toggle_package(self) -> None:
        """Toggle the selected package's checkbox."""
        focused = self.focused
        if isinstance(focused, PackageItem):
            checkbox = focused.query_one("Checkbox")
            checkbox.toggle()

    @on(Button.Pressed, "#install_btn")
    def handle_install(self) -> None:
        """Handle the install button press."""
        self.action_install_selected()

    def action_install_selected(self) -> None:
        """Install selected packages."""
        selected_packages = []
        list_view = self.query_one("#package_list")
        
        for item in list_view.children:
            if isinstance(item, PackageItem):
                checkbox = item.query_one("Checkbox")
                if checkbox.value:
                    selected_packages.append(item.pkg_name)
        
        if selected_packages:
            self.install_packages(selected_packages)

    @work(thread=True)
    def install_packages(self, packages: List[str]) -> None:
        """Install the selected packages using apt."""
        details = self.query_one("#details", Static)
        details.update("Installing packages...\n\n" + " ".join(packages))
        
        try:
            # First check if pkexec is available
            subprocess.run(["which", "pkexec"], check=True, capture_output=True)
            
            cmd = ["pkexec", "apt", "install", "-y"] + packages
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            stdout, stderr = process.communicate()
            
            if process.returncode == 0:
                success_msg = [
                    "✅ Installation completed successfully!",
                    "",
                    "Installed packages:",
                    "- " + "\n- ".join(packages),
                    "",
                    stdout.strip() if stdout.strip() else "No additional output"
                ]
                details.update("\n".join(success_msg))
                self.load_packages()  # Refresh package status
            else:
                error_msg = [
                    "❌ Installation failed!",
                    "",
                    "Failed to install the following packages:",
                    "- " + "\n- ".join(packages),
                    "",
                    "Error output:",
                    stderr.strip() if stderr.strip() else "No error details available"
                ]
                details.update("\n".join(error_msg))
        except FileNotFoundError:
            error_msg = [
                "❌ System Error:",
                "",
                "pkexec not found. Please install policykit-1:",
                "sudo apt install policykit-1"
            ]
            details.update("\n".join(error_msg))
        except Exception as e:
            error_msg = [
                "❌ Installation Error:",
                "",
                str(e),
                "",
                "Please ensure you have the necessary permissions",
                "and the package manager is not in use."
            ]
            details.update("\n".join(error_msg))

def run():
    app = SetuprApp()
    app.run()

if __name__ == "__main__":
    run()
