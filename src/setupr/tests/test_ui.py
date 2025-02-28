"""Tests for UI components."""

import pytest
from rich.text import Text
from textual.widgets import Input
from textual.containers import ScrollableContainer
from textual.app import App, ComposeResult
from textual.css.query import NoMatches
from textual.pilot import Pilot

from setupr.main import SetuprApp, MainContent
from setupr.ui.widgets import PackageCard, DetailPanel, CategoryList
from setupr.core.package_data import PackageMetadata

class TestApp(App):
    """Test application fixture."""
    def compose(self) -> ComposeResult:
        yield MainContent()

class MainContentApp(App):
    """Test application for MainContent."""
    
    CSS_PATH = None  # Disable CSS loading for tests
    
    def compose(self) -> ComposeResult:
        yield MainContent()

@pytest.mark.asyncio
async def test_main_content():
    """Test main content layout."""
    app = MainContentApp()
    async with app.run_test() as pilot:
        await pilot.pause()
        
        # Check search input exists
        search = pilot.app.query_one("#search_input")
        assert isinstance(search, Input)
        
        # Check package grid exists
        grid = pilot.app.query_one("#grid-content")
        assert isinstance(grid, ScrollableContainer)

class PackageCardApp(App):
    """Test application for PackageCard."""
    
    CSS_PATH = None  # Disable CSS loading for tests
    
    def __init__(self, card: PackageCard):
        self.card = card
        super().__init__()
    
    def compose(self) -> ComposeResult:
        yield self.card

@pytest.mark.asyncio
async def test_package_card():
    """Test package card widget."""
    card = PackageCard.create(
        pkg_name="test-pkg",
        display_name="Test Package",
        description="A test package",
        size="1.2 MB",
        status="not-installed",
        category="Development"
    )
    
    # Test direct render output
    output = card.render()
    assert isinstance(output, Text)
    assert "Test Package" in str(output)
    assert "1.2 MB" in str(output)
    assert "◯ Not Installed" in str(output)
    
    # Test mounting and interactions
    app = PackageCardApp(card)
    async with app.run_test() as pilot:
        await pilot.pause()  # Let the app initialize
        
        # Test selection
        card.selected = True
        await pilot.pause()
        assert "selected" in card.classes
        
        card.selected = False
        await pilot.pause()
        assert "selected" not in card.classes

@pytest.mark.asyncio
async def test_detail_panel():
    """Test detail panel widget."""
    panel = DetailPanel()
    
    # Test empty state render
    output = panel.render()
    assert isinstance(output, Text)
    assert "No package selected" in str(output)
    
    # Test with app context
    async with TestApp().run_test() as pilot:
        await pilot.app.mount(panel)
        await pilot.pause()
        
        # Test package details update
        package_info = {
            'display_name': 'Test Package',
            'category': 'Development',
            'size': '1.2 MB',
            'status': 'Not Installed',
            'description': 'A test package description'
        }
        panel.current_package = package_info
        await pilot.pause()
        
        output = panel.render()
        rendered_text = str(output)
        assert 'Test Package' in rendered_text
        assert 'Development' in rendered_text
        assert '1.2 MB' in rendered_text
        assert 'Not Installed' in rendered_text
        assert 'A test package description' in rendered_text
        
        # Test progress update
        panel.current_progress = 50
        panel.current_status = "Installing..."
        panel.current_details = "Downloading packages..."
        await pilot.pause()
        
        output = panel.render()
        rendered_text = str(output)
        assert "50%" in rendered_text or "50" in rendered_text
        assert "Installing..." in rendered_text
        assert "Downloading packages..." in rendered_text

@pytest.mark.asyncio
async def test_category_list():
    """Test category list widget."""
    category_list = CategoryList()
    
    # Test initial render
    output = category_list.render()
    assert isinstance(output, Text)
    assert "Categories" in str(output)
    assert "All Packages" in str(output)
    assert "Development" in str(output)
    
    # Test with app context
    async with TestApp().run_test() as pilot:
        await pilot.app.mount(category_list)
        await pilot.pause()
        
        # Test category selection
        category_list.selected_category = "Development"
        await pilot.pause()
        output = category_list.render()
        rendered_text = str(output)
        assert "Development" in rendered_text

@pytest.mark.asyncio
async def test_setupr_app():
    """Test main application functionality."""
    async with SetuprApp().run_test() as pilot:
        await pilot.pause()
        
        # Test initial state
        assert pilot.app.selected_category == "All"
        assert len(pilot.app.selected_packages) == 0
        assert not pilot.app.is_loading
        
        # Test pane layout
        assert pilot.app.query_one("#left-pane")
        assert pilot.app.query_one("#center-pane")
        assert pilot.app.query_one("#right-pane")
        
        # Test category selection
        pilot.app.selected_category = "Development"
        await pilot.pause()
        assert pilot.app.selected_category == "Development"
        
        # Test package selection
        pkg = PackageMetadata(
            pkg_name="test-pkg",
            display_name="Test Package",
            category="Development"
        )
        pilot.app.packages["test-pkg"] = pkg
        pilot.app.selected_packages.append("test-pkg")
        await pilot.pause()
        
        # Check detail panel exists
        detail_panel = pilot.app.query_one(DetailPanel)
        assert detail_panel is not None
        
        # Test search focus
        await pilot.app.action_search_focus()
        await pilot.pause()
        search = pilot.app.query_one("#search_input")
        assert search.has_focus
        # Test theme related classes
        assert "-light-mode" in pilot.app.classes or "-dark-mode" in pilot.app.classes
        initial_classes = set(pilot.app.classes)
        
        # Toggle theme
        await pilot.app.action_toggle_theme()
        await pilot.pause()
        
        # Check that classes have changed
        assert set(pilot.app.classes) != initial_classes
