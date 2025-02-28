"""Modern Development Package Installer"""

import asyncio
import logging
from typing import Optional

from textual.app import App, ComposeResult
from textual.containers import Horizontal, Vertical, Container, ScrollableContainer
from textual.widgets import Header, Static, Input
from textual.binding import Binding
from textual.widget import Widget

from setupr.core.package_data import get_all_packages as get_packages
from setupr.core.package_manager import install_package
from setupr.core.system import get_distribution_info
from setupr.ui.widgets import (
    PackageCard, CategoryList, DetailPanel, LoadingIndicator, NoResultsIndicator,
    CategorySelected, PackageSelected
)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MainContent(Widget):
    """Main content container for the application."""
    
    def compose(self) -> ComposeResult:
        with Container():
            with Container(id="search-container"):
                yield Input(placeholder="Search packages...", id="search_input")
            with ScrollableContainer(id="grid-content"):
                yield LoadingIndicator()

class SetuprApp(App):
    """A modern package installer GUI."""
    
    def __init__(self) -> None:
        """Initialize the application."""
        super().__init__()
        
        # Get system info
        distro_info = get_distribution_info()
        self.TITLE = f"Development Package Installer – {distro_info['name']}"
        
        # Setup bindings
        self.BINDINGS = [
            Binding("q", "quit", "Quit"),
            Binding("i", "install_selected", "Install Selected"),
            ("s", "search_focus", "Search"),
            Binding("t", "toggle_theme", "Toggle Theme"),
            ("/", "search_focus", "Search"),
        ]
        
        # Initialize state
        self._dark_mode = True
        self._search_query = ""
        self._current_category = "All"
        self._is_loading = True
        
        self.selected_packages = []
        self.packages = {}
        
        # Set initial theme
        self.add_class("-dark-mode")
    
    @property
    def selected_category(self):
        return self._current_category

    @selected_category.setter
    def selected_category(self, value):
        self._current_category = value

    @property
    def is_loading(self):
        return self._is_loading

    def compose(self) -> ComposeResult:
        """Compose the application layout."""
        yield Header()
        
        with Horizontal():
            # Left Panel - Categories
            with Container(classes="pane", id="left-pane"):
                yield CategoryList()
            
            # Center Panel - Package Grid
            with Container(classes="pane", id="center-pane"):
                # Use MainContent for the center panel content
                yield MainContent()
            
            # Right Panel - Details & Progress
            with Container(classes="pane", id="right-pane"):
                yield DetailPanel()
    
    async def action_toggle_theme(self) -> None:
        """Toggle between light and dark theme."""
        self._dark_mode = not self._dark_mode
        if self._dark_mode:
            self.add_class("-dark-mode")
            self.remove_class("-light-mode")
        else:
            self.add_class("-light-mode")
            self.remove_class("-dark-mode")

    async def on_mount(self) -> None:
        """Handle application mount."""
        logger.info("Application mounted initializing...")
        self.query_one("#search_input", Input).focus()
        
        try:
            # Load packages
            logger.info("Getting package list...")
            packages = get_packages()
            logger.info(f"Found {len(packages)} packages to load")
            
            # Load packages gradually
            package_grid = self.query_one("#grid-content")
            loading_indicator = package_grid.query_one(LoadingIndicator)
            
            for i, pkg in enumerate(packages, 1):
                try:
                    card = PackageCard(
                        pkg_name=pkg.name,
                        display_name=pkg.display_name,
                        description=pkg.description,
                        size=pkg.size,
                        status=pkg.status,
                        category=pkg.category
                    )
                    package_grid.mount(card)
                    logger.debug(f"Loaded package: {pkg.name} ({i}/{len(packages)})")
                    
                    # Update loading progress
                    loading_indicator.update_progress(int((i / len(packages)) * 100))
                    
                    # Give UI time to update
                    if i % 10 == 0:
                        await asyncio.sleep(0)
                
                except Exception as e:
                    logger.error(f"Error creating card for {pkg.name}: {e}")
            
            # Remove loading indicator and update state
            loading_indicator.remove()
            self._is_loading = False
            self.packages = {pkg.name: pkg for pkg in packages}
            logger.info(f"Finished loading {len(packages)} packages")
            logger.debug(f"Displaying {len(packages)} packages")
            
        except Exception as e:
            logger.error(f"Failed to load packages: {e}")
            # Show error in UI
            package_grid = self.query_one("#grid-content")
            loading_indicator = package_grid.query_one(LoadingIndicator)
            loading_indicator.update_error(f"Failed to load packages: {e}")
        
        finally:
            self._is_loading = False
    
    def on_input_changed(self, event: Input.Changed) -> None:
        """Handle search input changes."""
        self._search_query = event.value.lower()
        self._filter_packages()
    
    def on_category_list_category_selected(self, event: CategorySelected) -> None:
        """Handle category selection."""
        self._current_category = event.category
        self._filter_packages()
    
    def on_package_card_package_selected(self, event: PackageSelected) -> None:
        """Handle package selection."""
        card = event.package_card
        self.query_one(DetailPanel).update_package({
            'display_name': card.display_name,
            'category': card.category,
            'size': card.size,
            'status': card.status,
            'description': card.description
        })
    
    def _filter_packages(self) -> None:
        """Filter packages based on search query and category."""
        if self._is_loading:
            return
        
        package_grid = self.query_one("#grid-content", ScrollableContainer)
        cards = package_grid.query(PackageCard)
        
        # Show/hide cards based on filters
        visible_count = 0
        for card in cards:
            show = True
            
            # Apply category filter
            if self._current_category != "All" and card.category != self._current_category:
                show = False
            
            # Apply search filter
            if self._search_query and not any(
                self._search_query in x.lower()
                for x in [card.pkg_name, card.display_name, card.description]
            ):
                show = False
            
            card.display = show
            if show:
                visible_count += 1
        
        # Show "No Results" if needed
        no_results = package_grid.query(NoResultsIndicator)
        if visible_count == 0 and not no_results:
            package_grid.mount(NoResultsIndicator())
        elif visible_count > 0 and no_results:
            no_results.first().remove()
    
    async def action_search_focus(self) -> None:
        """Focus the search input."""
        search_input = self.query_one("#search_input", Input)
        self.call_after_refresh(search_input.focus)
    
    async def action_install_selected(self) -> None:
        """Install selected packages."""
        detail_panel = self.query_one(DetailPanel)
        cards = self.query(PackageCard)
        selected = [card for card in cards if card.selected and card.display]
        
        for card in selected:
            # Update UI
            detail_panel.update_progress(0, "Installing...", f"Installing {card.display_name}")
            card.status = "installing"
            
            try:
                # Install package
                await install_package(card.pkg_name, 
                    progress_callback=lambda p: detail_panel.update_progress(p, "Installing...", f"Installing {card.display_name}"))
                
                # Update UI on success
                card.status = "installed"
                card.selected = False
                detail_panel.update_progress(100, "Complete", f"Installed {card.display_name}")
            
            except Exception as e:
                # Update UI on failure
                card.status = "failed"
                detail_panel.update_progress(0, "Failed", f"Failed to install {card.display_name}: {e}")
                logger.error(f"Failed to install {card.pkg_name}: {e}")

def run():
    """Run the application."""
    app = SetuprApp()
    app.run()

if __name__ == "__main__":
    run()
