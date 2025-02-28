# Setupr - Modern Package Installer

A modern terminal UI package installer for Linux systems with an intuitive three-pane layout and sleek design.

## Features

- 🎯 Clean, modern three-pane interface
- 🔍 Global search across all packages
- 📦 Category-based package organization
- 💻 Real-time installation progress
- 🖥️ Terminal output integration
- 🎨 Modern, responsive design
- 🚀 Multi-distribution support

## Layout

```
┌─────────────┬────────────────────┬─────────────┐
│  Categories │    Package Grid    │  Details    │
│             │                    │    Panel    │
│ [Development│ ┌──┐ ┌──┐ ┌──┐     │            │
│  IDEs       │ │  │ │  │ │  │     │ Package    │
│  Databases  │ └──┘ └──┘ └──┘     │ Details    │
│  Tools      │ ┌──┐ ┌──┐ ┌──┐     │            │
│  Cloud      │ │  │ │  │ │  │     │ Progress   │
│  Web        │ └──┘ └──┘ └──┘     │ Terminal   │
└─────────────┴────────────────────┴─────────────┘
```

## Installation

```bash
pip install setupr
```

## Usage

```bash
setupr
```

### Keyboard Shortcuts

- `/` or `s`: Focus search
- `i`: Install selected packages
- `q`: Quit application

## Development

### Requirements
- Python 3.7+
- Textual library
- distro library

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/yourusername/setupr.git
cd setupr

# Install dependencies
pip install -e .
```

### Project Structure

```
src/setupr/
├── __init__.py
├── main.py              # Main app entry point
├── main.css            # Main CSS styles
├── ui/
│   ├── __init__.py
│   ├── widgets.py      # Custom widgets
│   └── views.py        # Main view components
├── core/
│   ├── __init__.py
│   ├── package_manager.py     # Package management
│   ├── package_data.py       # Package metadata
│   └── system.py            # System utilities
└── utils/
    ├── __init__.py
    └── helpers.py          # Helper functions
```

## Features

### Package Management
- Cross-distribution support (apt, dnf, pacman)
- Asynchronous package operations
- Progress tracking
- Error handling

### User Interface
- Modern card-based design
- Real-time updates
- Smooth animations
- Responsive layout
- Dark/light theme support

### Search and Filtering
- Global search across all packages
- Category filtering
- Advanced search options
- Quick filters

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
