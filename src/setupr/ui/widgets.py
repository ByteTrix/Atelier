"""Custom UI widgets for the package installer."""

from textual.app import ComposeResult
from textual.containers import Horizontal, Vertical, Container, ScrollableContainer
from textual.widgets import Static, Button, Label, ProgressBar
from textual.reactive import reactive
from textual.widget import Widget
from textual.message import Message
from textual.binding import Binding
from textual.geometry import Size
from rich.text import Text

class PackageSelected(Message):
    """Event sent when a package is selected."""
    def __init__(self, package_card: 'PackageCard') -> None:
        self.package_card = package_card
        super().__init__()

class CategorySelected(Message):
    """Event sent when a category is selected."""
    def __init__(self, category: str) -> None:
        self.category = category
        super().__init__()

class LoadingIndicator(Widget):
    """A loading indicator widget with progress bar."""
    
    # Reactive state
    progress = reactive(0)
    error_message = reactive("")
    
    DEFAULT_CSS = """
    LoadingIndicator {
        width: 100%;
        height: auto;
        padding: 1;
    }
    LoadingIndicator .loading-text {
        text-align: center;
        margin-bottom: 1;
    }
    LoadingIndicator .error-text {
        color: red;
        text-align: center;
    }
    """
    
    def compose(self) -> ComposeResult:
        """Compose the loading indicator."""
        yield Static("Loading packages...", classes="loading-text")
        yield ProgressBar()
        yield Static("", classes="error-text", id="error-message")
    
    def watch_progress(self, value: int) -> None:
        """Watch progress value changes."""
        if value < 0:
            value = 0
        elif value > 100:
            value = 100
            
        progress_bar = self.query_one(ProgressBar)
        progress_bar.progress = value / 100
        
        loading_text = self.query_one(".loading-text", Static)
        loading_text.update(f"Loading packages... {value}%")
    
    def update_progress(self, value: int) -> None:
        """Update the progress value."""
        self.progress = value
    
    def update_error(self, message: str) -> None:
        """Display an error message."""
        self.error_message = message
        error_display = self.query_one("#error-message")
        error_display.update(message)
        
        # Hide progress bar and show error in red
        self.progress = 0
        loading_text = self.query_one(".loading-text", Static)
        loading_text.update("Error loading packages")

class NoResultsIndicator(Static):
    """A no results indicator widget."""
    
    def render(self) -> Text:
        """Return a Text object for rendering."""
        return Text("No packages found")

class PackageCard(Widget):
    """A modern card-style package item."""
    
    # Reactive attributes
    pkg_name = reactive("")
    display_name = reactive("")
    description = reactive("")
    package_size = reactive("Unknown")  # Renamed from size to avoid conflict
    status = reactive("not-installed")
    category = reactive("")
    selected = reactive(False)
    
    DEFAULT_CSS = """
    PackageCard {
        background: $surface;
        border: solid $primary;
        margin: 0 0 1 0;
        padding: 1;
        width: 100%;
        min-height: 5;
        height: auto;
    }
    PackageCard:hover {
        background: $boost;
        border: solid $accent;
    }
    PackageCard.selected {
        border: solid $accent;
        background: $boost;
    }
    PackageCard .header {
        margin-bottom: 1;
    }
    PackageCard .package-name {
        text-style: bold;
    }
    PackageCard .status-badge {
        margin-left: 2;
        color: $text;
        text-align: right;
    }
    PackageCard .package-description {
        color: $text-muted;
        margin: 1 0;
    }
    PackageCard .package-size {
        color: $text-muted;
        text-align: right;
    }
    """
    @property
    def size(self) -> Size:
        """Override to provide proper size dimensions."""
        # Minimum size plus padding
        return Size(self.container_size.width or 40, 6)

    def get_content_height(self, container: Size, viewport: Size, width: int) -> int:
        """Get content height."""
        # Allow content to expand based on description
        base_height = 6  # Minimum height
        if self.description:
            # Add extra height for description
            lines = (len(self.description) + 99) // 100  # Description is truncated at 100 chars
            base_height += lines
        return base_height
    
    def __init__(self) -> None:
        """Initialize the package card."""
        super().__init__()
        self.add_class("package-card")
        
        # Default values
        self.pkg_name = ""
        self.display_name = ""
        self.description = ""
        self.package_size = "Unknown"
        self.status = "not-installed"
        self.category = ""
        self.selected = False
    
    @classmethod
    def create(
        cls,
        *,  # Force keyword arguments
        pkg_name: str,
        display_name: str = "",
        description: str = "",
        size: str = "Unknown",
        status: str = "not-installed",
        category: str = ""
    ) -> "PackageCard":
        """Create a new PackageCard with the given attributes."""
        card = cls()
        card.pkg_name = pkg_name
        card.display_name = display_name or pkg_name
        card.description = description
        card.package_size = size
        card.status = status
        card.category = category
        return card
    
    def compose(self) -> ComposeResult:
        """Compose package card content."""
        # Status indicator
        status_text = {
            "installed": "✓ Installed",
            "not-installed": "◯ Not Installed",
            "installing": "⟳ Installing",
            "failed": "✕ Failed"
        }.get(self.status, self.status)
        
        # Create card content
        with Container():
            # Header
            with Horizontal(classes="header"):
                yield Label(self.display_name, classes="package-name")
                yield Static(status_text, classes=f"status-badge {self.status}")
            
            # Description
            if self.description:
                desc = self.description[:100] + "..." if len(self.description) > 100 else self.description
                yield Static(desc, classes="package-description")
            
            # Footer
            yield Static(f"Size: {self.package_size}", classes="package-size")

    def watch_selected(self, selected: bool) -> None:
        """Watch selected state changes."""
        if selected:
            self.add_class("selected")
        else:
            self.remove_class("selected")
    
    async def on_click(self) -> None:
        """Handle click event."""
        self.selected = not self.selected
        self.post_message(PackageSelected(self))
    
    def render(self) -> Text:
        """Return a Text object for rendering."""
        text = Text()
        text.append(self.display_name)
        
        # Add status with proper symbol
        status_text = {
            "installed": "✓ Installed",
            "not-installed": "◯ Not Installed",
            "installing": "⟳ Installing",
            "failed": "✕ Failed"
        }.get(self.status, self.status)
        text.append(f"\n{status_text}")
        
        if self.description:
            text.append(f"\n{self.description[:100]}")
        text.append(f"\nSize: {self.package_size}")
        return text

class CategoryList(Widget):
    """Left panel showing package categories."""
    
    CATEGORIES = [
        ("All", "All Packages 📦"),
        ("Development", "Development 🔧"),
        ("IDEs & Editors", "IDEs & Editors 📝"),
        ("Databases", "Databases 🗄️"),
        ("Development Tools", "Dev Tools 🛠️"),
        ("Containers & Cloud", "Cloud & Containers ☁️"),
        ("Web Servers", "Web Servers 🌐"),
        ("System Tools", "System Tools ⚙️"),
        ("Utilities", "Utilities 🔨")
    ]
    
    # Reactive state
    selected_category = reactive("All")
    
    def compose(self) -> ComposeResult:
        """Compose the category list."""
        yield Static("Categories", classes="section-title")
        with ScrollableContainer(classes="category-list"):
            for category_id, label in self.CATEGORIES:
                yield Button(label, classes="category-btn", id=f"cat-{category_id.lower()}")
    
    def watch_selected_category(self, new_category: str) -> None:
        """Watch for category changes and update button states."""
        for button in self.query(".category-btn"):
            if button.id == f"cat-{new_category.lower()}":
                button.add_class("-selected")
            else:
                button.remove_class("-selected")
    
    async def on_button_pressed(self, event: Button.Pressed) -> None:
        """Handle category button presses."""
        category = event.button.id.replace("cat-", "").replace("-", " ").title()
        if category.lower() == "all":
            category = "All"
        
        self.selected_category = category
        self.post_message(CategorySelected(category))
    
    def render(self) -> Text:
        """Return a Text object for rendering."""
        text = Text("Categories\n")
        for category_id, label in self.CATEGORIES:
            style = "bold" if category_id == self.selected_category else ""
            text.append(f"\n{label}", style=style)
        return text

class DetailPanel(Widget):
    """Right panel showing package details and installation progress."""
    
    # Reactive state
    current_package = reactive(None)
    current_progress = reactive(0.0)
    current_status = reactive("")
    current_details = reactive("")
    
    def compose(self) -> ComposeResult:
        """Compose the detail panel layout."""
        with Container(classes="detail-panel"):
            # Package info section
            with ScrollableContainer(classes="panel-section", id="package-info"):
                yield Static("Package Details", classes="section-title")
                yield Static("", id="details-content", classes="details-text")
            
            # Installation progress section
            with Container(classes="panel-section", id="install-progress"):
                yield Static("Installation Progress", classes="section-title")
                progress_bar = ProgressBar(id="progress-bar")
                progress_bar.progress = 0
                yield progress_bar
                yield Static("", id="progress-status", classes="status-text")
                yield Static("", id="progress-details", classes="details-text")
            
            # Terminal output section
            with ScrollableContainer(classes="panel-section", id="terminal-output"):
                yield Static("Terminal Output", classes="section-title")
                yield Static("", id="terminal-content", classes="terminal-text")
    
    def update_package(self, pkg_info: dict) -> None:
        """Update package details."""
        self.current_package = pkg_info if pkg_info else None
        content = "No package selected"
        
        if pkg_info:
            content = (
                f"{pkg_info['display_name']}\n\n"
                f"Category: {pkg_info['category']}\n"
                f"Size: {pkg_info['size']}\n"
                f"Status: {pkg_info['status']}\n\n"
                f"Description:\n{pkg_info['description']}"
            )
        
        self.query_one("#details-content").update(content)
    
    def update_progress(
        self,
        progress: float,
        status: str,
        details: str
    ) -> None:
        """Update installation progress."""
        self.current_progress = progress
        self.current_status = status
        self.current_details = details
        
        # Update the actual progress bar widget if it exists
        progress_bar = self.query_one("#progress-bar", ProgressBar)
        if progress_bar:
            progress_bar.progress = progress / 100  # Assuming progress is in percentage (0-100)
        
        # Update status and details text widgets
        status_widget = self.query_one("#progress-status", Static)
        if status_widget:
            status_widget.update(status)
        
        details_widget = self.query_one("#progress-details", Static)
        if details_widget:
            details_widget.update(details)
        
    def render(self) -> Text:
        """Return a Text object for rendering."""
        text = Text()
        
        if self.current_package is None:
            text.append("No package selected")
        else:
            text.append(self.current_package['display_name'])
            text.append("\n\n")
            text.append(f"Category: {self.current_package.get('category', '')}\n")
            text.append(f"Size: {self.current_package.get('size', 'Unknown')}\n")
            text.append(f"Status: {self.current_package.get('status', 'Unknown')}\n")
            
            # Show progress information if available
            if self.current_progress > 0 or self.current_status:
                text.append(f"\nProgress: {self.current_progress}%\n")
                if self.current_status:
                    text.append(f"Status: {self.current_status}\n")
                if self.current_details:
                    text.append(f"Details: {self.current_details}\n")
            
            text.append("\n")
            if 'description' in self.current_package:
                text.append("Description:\n")
                text.append(self.current_package['description'])
                
        return text
