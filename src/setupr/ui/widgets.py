from textual.widgets import ListItem, Checkbox, Static, Label
from textual.containers import Horizontal, Vertical
from textual.app import ComposeResult
from rich.text import Text
from textual.reactive import reactive

class PackageItem(ListItem):
    """A list item representing a package with installation status, name, and description."""
    
    pkg_name = reactive("")
    pkg_description = reactive("")
    pkg_size = reactive("Unknown")
    pkg_status = reactive("Not Installed")
    
    def __init__(self, name: str, description: str = "", size: str = "Unknown", status: str = "Not Installed") -> None:
        super().__init__()
        self.pkg_name = name
        self.pkg_description = description
        self.pkg_size = size
        self.pkg_status = status

    def compose(self) -> ComposeResult:
        """Create a more detailed package item with status indicators."""
        yield Horizontal(
            Checkbox(id=f"check_{self.pkg_name.lower().replace(' ', '_')}"),
            Vertical(
                Label(Text(self.pkg_name, style="bold")),
                Label(Text(self.pkg_description, style="dim")),
                Horizontal(
                    Label(Text(f"Size: {self.pkg_size}", style="italic")),
                    Label(Text(self.pkg_status, style="green" if self.pkg_status == "Installed" else "yellow")),
                    classes="package-details"
                ),
                classes="package-info"
            ),
            classes="package-item"
        )
