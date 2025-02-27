# Setupr

A modern terminal UI for bulk installing Linux applications, built with Python and Textual.

![Setupr UI Demo](./docs/setupr-demo.png)

## Features

- 🎨 Modern, intuitive terminal user interface
- 📦 Real-time package information and status
- 🔍 Quick search and category filtering
- ✨ Bulk package installation
- 🎯 Smart error handling and user feedback
- ⌨️ Keyboard-driven navigation

## Requirements

- Python 3.8 or higher
- Linux-based system with `apt` package manager
- `pkexec` for privilege escalation
- Python packages (installed automatically):
  - textual>=0.47.1
  - distro>=1.9.0
  - pkginfo>=1.9.6

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/setupr.git
cd setupr
```

2. Install using pip:
```bash
pip install -r requirements.txt
```

Or using Poetry:
```bash
poetry install
```

## Usage

Run the application:
```bash
python -m setupr.main
```

### Keyboard Shortcuts

- `q` - Quit the application
- `/` or `s` - Focus search
- `↑`/`↓` - Navigate package list
- `Enter` - Toggle package selection
- `i` - Install selected packages

### Features

1. **Package Categories**
   - Development: git, python3, nodejs, vscode, docker
   - Multimedia: vlc, gimp, audacity, obs-studio, kdenlive
   - Utilities: firefox, chromium, telegram-desktop, spotify, discord
   - System Tools: htop, neofetch, timeshift, gparted, synaptic

2. **Real-time Package Information**
   - Installation status
   - Package size
   - Detailed descriptions
   - Category grouping

3. **Search and Filter**
   - Quick search functionality
   - Category-based filtering
   - Live search results

4. **Bulk Installation**
   - Select multiple packages
   - One-click installation
   - Progress tracking
   - Error handling

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
