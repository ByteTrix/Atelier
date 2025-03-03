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
from textual.css.query import NoMatches
import time

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

class LoadingIndicator(Static):
    """Widget to show loading progress."""
    
    def __init__(self):
        super().__init__()
        self.progress = 0
    
    def compose(self):
        with Vertical(classes="loading-container"):
            yield Label("Loading packages...", id="loading-text")
            yield Static("", id="loading-progress")
    
    def update_progress(self, progress: int):
        """Update the loading progress bar."""
        self.progress = progress
        
        try:
            progress_bar = self.query_one("#loading-progress")
            progress_bar.update(f"[{'#' * int(progress / 2)}{' ' * (50 - int(progress / 2))}] {progress}%")
        except NoMatches:
            pass
    
    def update_error(self, error_message: str):
        """Show an error message instead of the progress bar."""
        try:
            self.query_one("#loading-text").update("Error loading packages")
            self.query_one("#loading-progress").update(error_message)
        except NoMatches:
            pass

class NoResultsIndicator(Static):
    """Widget shown when no packages match the current filters."""
    
    def compose(self):
        with Vertical(classes="no-results"):
            yield Label("No packages found", classes="no-results-title")
            yield Label("Try adjusting your search or category filters", classes="no-results-help")

class PackageCard(Static):
    """Card displaying information about a package."""
    
    def __init__(
        self,
        pkg_name: str,
        display_name: str,
        description: str,
        size: str,
        status: str,
        category: str,
    ) -> None:
        super().__init__()
        self.pkg_name = pkg_name
        self.display_name = display_name
        self.description = description
        self.size = size
        self.status = status
        self.category = category
        self.selected = False
    
    def compose(self):
        status_class = f"status-{self.status}"
        
        with Horizontal(classes="package-card"):
            with Vertical(classes="package-info"):
                yield Label(self.display_name, classes="package-name")
                yield Label(self.description, classes="package-description")
                
            with Vertical(classes="package-meta"):
                yield Label(self.size, classes="package-size")
                yield Label(self.status, classes=f"package-status {status_class}")
    
    def on_click(self):
        self.selected = not self.selected
        if self.selected:
            self.add_class("selected")
        else:
            self.remove_class("selected")
        
        self.emit_no_wait(PackageSelected(self))

class CategoryButton(Button):
    """A button representing a package category."""
    def __init__(self, category: str, count: int = 0) -> None:
        super().__init__(f"{category} ({count})" if count > 0 else category)
        self.category = category
    
    def on_click(self) -> None:
        self.app.query(".category-button").remove_class("selected")
        self.add_class("selected")
        self.emit_no_wait(CategorySelected(self.category))

class CategoryList(Static):
    """Widget that displays a list of package categories."""
    
    def __init__(self) -> None:
        super().__init__()
        self.categories = {
            "All": 0,
            "Development": 0,
            "Languages": 0,
            "Libraries": 0,
            "Frameworks": 0,
            "Databases": 0,
            "Tools": 0,
            "Cloud": 0,
            "Other": 0
        }
    
    def compose(self):
        yield Label("Categories", classes="section-title")
        with Vertical(id="category-list"):
            for category, count in self.categories.items():
                button = CategoryButton(category, count)
                if category == "All":
                    button.add_class("selected")
                button.add_class("category-button")
                yield button
    
    def update_counts(self, category_counts):
        self.categories.update(category_counts)
        
        try:
            category_list = self.query_one("#category-list")
            category_list.remove_children()
            
            for category, count in self.categories.items():
                button = CategoryButton(category, count)
                if category == self.app._current_category:
                    button.add_class("selected")
                button.add_class("category-button")
                category_list.mount(button)
        except NoMatches:
            pass

class DetailPanel(Static):
    """Panel that displays details about a selected package."""
    
    def __init__(self):
        super().__init__()
        self.current_package = None
        self.progress = 0
        self.progress_status = ""
        self.progress_details = ""
    
    def compose(self):
        yield Label("Package Details", classes="section-title")
        
        with Vertical(id="package-details", classes="detail-panel"):
            yield Label("Select a package to view details", id="no-selection")
            
            with Vertical(id="details-content", classes="hidden"):
                yield Label("", id="detail-name", classes="detail-title")
                yield Label("", id="detail-category", classes="detail-meta")
                yield Label("", id="detail-size", classes="detail-meta")
                yield Label("", id="detail-status", classes="detail-meta")
                yield Label("", id="detail-description", classes="detail-description")
        
        yield Label("Installation Progress", classes="section-title")
        
        with Vertical(id="progress-panel", classes="progress-panel"):
            yield Label("No active installation", id="progress-status")
            yield Static("", id="progress-bar")
            yield Label("", id="progress-details")
    
    def update_package(self, package_data):
        """Update the panel with package details."""
        self.current_package = package_data
        
        # Update UI with package details
        try:
            self.query_one("#no-selection").add_class("hidden")
            self.query_one("#details-content").remove_class("hidden")
            
            self.query_one("#detail-name").update(package_data["display_name"])
            self.query_one("#detail-category").update(f"Category: {package_data['category']}")
            self.query_one("#detail-size").update(f"Size: {package_data['size']}")
            self.query_one("#detail-status").update(f"Status: {package_data['status']}")
            self.query_one("#detail-description").update(package_data["description"])
        except NoMatches:
            pass
    
    def update_progress(self, progress: int, status: str, details: str = ""):
        """Update the installation progress display."""
        self.progress = progress
        self.progress_status = status
        self.progress_details = details
        
        try:
            # Update progress bar
            progress_bar = self.query_one("#progress-bar")
            progress_bar.update(f"[{'#' * int(progress / 5)}{' ' * (20 - int(progress / 5))}] {progress}%")
            
            # Update status and details
            self.query_one("#progress-status").update(status)
            self.query_one("#progress-details").update(details)
        except NoMatches:
            pass
