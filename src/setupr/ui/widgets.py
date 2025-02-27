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
    
    display_name = reactive("")

    def __init__(self, pkg_name: str, name: str = "", description: str = "", size: str = "Unknown", status: str = "Not Installed") -> None:
        super().__init__()
        self.pkg_name = pkg_name
        self.display_name = name or pkg_name
        self.pkg_description = description
        self.pkg_size = size
        self.pkg_status = status

    def compose(self) -> ComposeResult:
        """Create a simple text-based package item."""
        yield Horizontal(
            Checkbox(id=f"check_{self.pkg_name.lower().replace(' ', '_')}"),
            Label(Text(self.display_name,
                style="bold" if self.pkg_status == "Installed" else "")),
            classes="package-item"
        )
