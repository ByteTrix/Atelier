Setupr - Modern Terminal Package Manager

A sleek, efficient terminal UI package manager for Linux systems that combines powerful functionality with an intuitive interface. Setupr provides a modern experience for managing software while respecting terminal space constraints.

<img alt="Setupr" src="https://img.shields.io/badge/Setupr-v0.1.0-blue">
<img alt="Python" src="https://img.shields.io/badge/Python-3.7+-green">
<img alt="License" src="https://img.shields.io/badge/License-MIT-yellow">

## Features
🚀 Space-Efficient Design - Maximizes visibility of packages and information
🔍 Powerful Search - Find packages instantly with real-time filtering
📊 Smart Organization - Logical categorization of packages
🔄 Real-time Updates - See installation progress as it happens
📱 Responsive Layout - Works well on various terminal sizes
🌈 Visual Indicators - Clear status and selection feedback
🖥️ Terminal Integration - View actual command output during operations
🌐 Cross-Distribution - Works on various Linux distributions


## Interface Layout
┌─────────────┬──────────────────────────────────┬─────────────────────────────┐
│ Setupr      │               [🔍 Search...]     │         🌙 ⚙️ ❔            │
├─────────────┬──────────────────────────────────┼─────────────────────────────┤
│ CATEGORIES  │ ▲                                │ DETAILS                     │
├─────────────┤ ►VS Code     1.85.1    65MB [4.5]│                             │
│ ● Featured  │ ○PyCharm     2023.2   450MB [4.5]│ VS Code                     │
│ ○ Developer │ ○Sublime     4.0       20MB [4.0]│ Version: 1.85.1             │
│ ○ Graphics  │ ○Atom        1.60.0   120MB [3.5]│                             │
│ ○ Internet  │ ○Neovim      0.9.1     15MB [5.0]│ Modern code editor with     │
│ ○ Office    │ ○Emacs       28.2      35MB [4.5]│ intelligent features,       │
│ ○ Media     │ ○Kate        22.12.3   18MB [3.5]│ syntax highlighting,        │
│ ○ System    │ ○Geany       2.0       12MB [4.0]│ and Git integration.        │
│             │ ○Brackets    2.1       80MB [3.5]│                             │
│ FILTERS     │ ○Gedit       44.0      10MB [3.0]│ Size: 65MB                  │
├─────────────┤ ○Eclipse     4.26     300MB [3.5]│ Rating: 4.5/5               │
│ ☑ Free      │ ○WebStorm    2023.2   400MB [4.5]│                             │
│ ☐ Propriet. │ ▼                                │ [      INSTALL      ]       │
│ ☑ Installed │                                  │                             │
│ ☑ Updates   │                                  ├─────────────────────────────┤
│             │ STATUS: Installing VS Code...    │ TERMINAL                    │
│ SORT BY     │ ████████▒▒ 80% - Downloading     │                             │
├─────────────┤                                  │ $ apt-get install code      │
│ • Popular   │                                  │                             │
│ ○ A-Z       │                                  │ Fetching dependencies...    │
│ ○ Size      │                                  │ Processing triggers... ▋    │
└─────────────┴──────────────────────────────────┴─────────────────────────────┘

## Design Philosophy

Setupr's interface is crafted with these core principles:

1. **Information Density** - Show more packages while maintaining readability
2. **Visual Clarity** - Clear indicators for selection, status, and progress
3. **Contextual Details** - Package information appears when needed
4. **Efficient Navigation** - Quick keyboard shortcuts for fast workflow
5. **Real-time Feedback** - See what's happening as it happens

## Installation

```bash
# Install from PyPI
pip install setupr

# Or install development version
git clone https://github.com/username/setupr.git
cd setupr
pip install -e .
```

## Usage

Launch the application:

```bash
setupr
```

### Keyboard Shortcuts

| Key      | Action                   |
|----------|--------------------------|
| `/` or `s` | Focus search           |
| `↑` / `↓`  | Navigate package list  |
| `Enter`    | Select package         |
| `i`        | Install selected       |
| `u`        | Update selected        |
| `r`        | Remove selected        |
| `Tab`      | Switch panes           |
| `t`        | Toggle theme           |
| `f`        | Toggle filters         |
| `q`        | Quit application       |
| `?`        | Show help              |

## Package Management Features

- **Smart Dependency Resolution** - Automatically handles dependencies
- **Conflict Detection** - Identifies and resolves package conflicts
- **Multiple Sources** - Install from repositories, Flatpaks, and more
- **Package Health** - Shows popularity, update frequency, and ratings
- **History Tracking** - Records installation and update history
- **System Integration** - Respects system package manager preferences

## Technical Details

Setupr is built using:

- **Textual** - Rich TUI framework for Python
- **Rich** - Terminal formatting library
- **asyncio** - For non-blocking operations
- **Package Manager Libraries** - Integrations with apt, dnf, pacman, etc.

## Project Structure

```
setupr/
├── src/
│   └── setupr/
│       ├── __init__.py
│       ├── main.py              # Main entry point
│       ├── ui/
│       │   ├── __init__.py
│       │   ├── app.py           # Core application
│       │   ├── widgets/         # Custom UI components
│       │   └── styles/          # CSS styling
│       ├── core/
│       │   ├── __init__.py
│       │   ├── package_manager.py
│       │   └── backends/        # Package manager integrations
│       └── utils/
│           └── __init__.py
├── tests/
├── docs/
├── pyproject.toml
└── README.md
```

## Development

### Requirements

- Python 3.7+
- Textual library
- distro library

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/username/setupr.git
cd setupr

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install development dependencies
pip install -e ".[dev]"

# Run the application in development mode
python -m setupr --dev
```

### Running Tests

```bash
pytest tests/
```

## Distribution Support

Setupr supports multiple package managers:

- 📦 **apt** - Debian, Ubuntu, and derivatives
- 📦 **dnf** - Fedora, RHEL, and derivatives
- 📦 **pacman** - Arch Linux and derivatives
- 📦 **zypper** - openSUSE
- 📦 **flatpak** - Cross-distribution packages
- 📦 **snap** - Universal Linux packages

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- The Textual team for their amazing TUI framework
- All Linux package manager developers
- Contributors and testers who helped refine the design

---

Made with ❤️ by the Setupr team