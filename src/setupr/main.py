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
    "Development": [
        "git", "python3", "nodejs", "vscode", "docker", "docker-compose",
        "build-essential", "cmake", "golang", "openjdk-17-jdk", "maven",
        "npm", "yarn", "rust-all", "gcc", "g++", "gdb", "make"
    ],
    "IDEs & Editors": [
        "code", "sublime-text", "vim", "neovim", "emacs",
        "pycharm-community", "intellij-idea-community", "android-studio"
    ],
    "Databases": [
        "postgresql", "mysql-server", "mongodb-org", "redis-server",
        "sqlite3", "postgresql-client", "mysql-client"
    ],
    "Development Tools": [
        "curl", "wget", "htop", "tmux", "screen", "zsh",
        "git-lfs", "jq", "postman", "wireshark"
    ],
    "Containers & Cloud": [
        "docker", "docker-compose", "kubectl", "awscli",
        "google-cloud-sdk", "azure-cli", "terraform"
    ],
    "Web Servers": [
        "nginx", "apache2", "certbot"
    ],
    "System Tools": [
        "htop", "neofetch", "timeshift", "gparted", "synaptic",
        "net-tools", "openssh-server", "gnome-tweaks"
    ],
    "Utilities": [
        "firefox", "chromium-browser", "telegram-desktop",
        "spotify-client", "discord", "slack", "zoom"
    ]
}

class PackagesLoaded(Message):
    """Posted when packages are loaded."""
    def __init__(self, packages: Dict[str, Dict]) -> None:
        self.packages = packages
        super().__init__()

class SetuprApp(App):
    CSS_PATH = "main.css"  # Path relative to this module's directory
    TITLE = f"Setupr – System: {distro.name(pretty=True)}"

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
        self.selected_category = "All"

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
        # Show initial package list
        self.selected_category = "All"
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
        """Load package information asynchronously."""
        packages = {}
        for category, package_list in PACKAGE_CATEGORIES.items():
            for pkg_name in package_list:
                # Check if package is installed
                is_installed = self._check_package_installed(pkg_name)
                size = self._get_package_size(pkg_name)
                
                packages[pkg_name] = {
                    "name": pkg_name,
                    "category": category,
                    "description": self._get_package_description(pkg_name),
                    "installed": is_installed,
                    "size": size
                }
        
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
            pkg_info = self.packages.get(item.pkg_name, {})
            details = [
                f"Name: {item.pkg_name}",
                f"Status: {item.pkg_status}",
                f"Size: {item.pkg_size}",
                f"Category: {pkg_info.get('category', 'Unknown')}",
                "",
                "Description:",
                item.pkg_description
            ]
            self.query_one("#details").update("\n".join(details))

    def update_package_list(self, filter_text: str = "") -> None:
        """Update the package list based on category and search filter."""
        list_view = self.query_one("#package_list")
        list_view.clear()

        # Get package list based on category
        packages_to_show = []
        if self.selected_category == "All":
            # For "All" category, combine all packages
            for packages in PACKAGE_CATEGORIES.values():
                packages_to_show.extend(packages)
            # Remove duplicates while preserving order
            packages_to_show = list(dict.fromkeys(packages_to_show))
        else:
            # For specific category
            packages_to_show = PACKAGE_CATEGORIES.get(self.selected_category, [])

        # Filter by search text if any
        if filter_text:
            packages_to_show = [
                pkg for pkg in packages_to_show
                if filter_text.lower() in pkg.lower()
            ]

        # Create PackageItem for each package
        for pkg_name in sorted(packages_to_show):  # Sort for consistent order
            pkg_info = self.packages.get(pkg_name, {})
            
            if pkg_info:  # If we have package info
                list_view.append(
                    PackageItem(
                        pkg_name,
                        pkg_info.get("description", "Loading..."),
                        pkg_info.get("size", "Unknown"),
                        "Installed" if pkg_info.get("installed", False) else "Not Installed"
                    )
                )
            else:  # Show loading state
                list_view.append(
                    PackageItem(
                        pkg_name,
                        "Loading package information...",
                        "Loading...",
                        "Checking..."
                    )
                )
        
        # Update window title with category
        if self.selected_category == "All":
            self.sub_title = "All Packages"
        else:
            self.sub_title = f"Category: {self.selected_category}"

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


