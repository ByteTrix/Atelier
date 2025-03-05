# Setupr

## To-Do

  -add whatsapp and its icon
  -add some custom config for specific pkgs and theme options
  -add a box says some installations failed because if one pkg failed the prompt says installation failed
  -change the readme file
  -Test all the installation without INSTALLING

![Setupr Banner](https://raw.githubusercontent.com/ByteTrix/Setupr/v2/.github/assets/banner.png)

## Features

- 🚀 **Two Installation Modes**:
  - **Automatic (Beginner Mode)**: Quick setup with recommended defaults
  - **Advanced (Interactive Mode)**: Full control over tool selection

- 💾 **Configuration Management**:
  - Auto-save configs to your Downloads folder
  - Upload existing configs from Downloads
  - Share configurations between machines
  - Version-controlled setups (`setupr_config_YYYYMMDD_HHMMSS.json`)

- 🛠️ **Comprehensive Tool Categories**:
  - Programming Languages (Python, Node.js, Go, Rust, Ruby)
  - IDEs & Text Editors (VS Code, Emacs, etc.)
  - CLI Tools (zoxide, fzf, ripgrep, etc.)
  - Containers (Docker, kubectl)
  - Browsers (Chrome, Firefox, Brave)
  - Productivity Apps (Notion, Obsidian, VLC, Xournal++, Localsend, WhatsApp, Spotify, Dropbox, Todoist, Telegram, Ulauncher, Syncthing)
  - Development Tools

- ⚡ **Enhanced Installation Experience**:
  - Parallel execution and progress tracking for installations
  - Interactive menus with more options for users

## Quick Start

```bash
wget -qO- https://raw.githubusercontent.com/ByteTrix/Setupr/v2.2/boot.sh | sudo bash
```

## Configuration Guide

### Creating a New Configuration

1. Run the installer:
   ```bash
   ./install.sh
   ```

2. Choose your installation mode and select tools
3. Your configuration will be automatically saved to:
   ```
   ~/Downloads/setupr_config_YYYYMMDD_HHMMSS.json
   ```

### Using an Existing Configuration

1. Place your configuration file in your Downloads folder
2. Run the installer:
   ```bash
   ./install.sh
   ```
3. Select "Yes" when asked "Do you want to upload a configuration file?"
4. Choose your configuration from the list

### Configuration File Format

Configurations are saved as JSON files:
```json
{
  "mode": "Advanced (Full Interactive Mode)",
  "timestamp": "2025-03-04T14:54:11Z",
  "packages": [
    "languages/python",
    "languages/nodejs",
    "cli/ripgrep",
    "browsers/chrome"
  ]
}
```

### Sharing Configurations

1. Find your saved configuration in `~/Downloads/setupr_config_*.json`
2. Share the file with team members
3. They can place it in their Downloads folder
4. Run Setupr and select the configuration when prompted

## Installation Options

### Programming Languages
- Python 3 with pip and venv
- Node.js and npm
- Go
- Rust (via rustup)
- Ruby and Bundler

### CLI Tools
- Zoxide (Enhanced cd)
- Fd (Improved file search)
- Ripgrep (Fast code search)
- Tree (Directory viewer)
- And many more...

### IDEs & Editors
- Visual Studio Code
- Emacs
- Geany
- IntelliJ IDEA CE

### Containers & Cloud
- Docker
- Docker Compose
- kubectl

### Browsers
- Google Chrome
- Firefox
- Brave Browser

### Productivity Apps
- Notion (All-in-one workspace)
- Obsidian (Knowledge base & notes)
- VLC Media Player (Versatile media player)
- Xournal++ (Note taking & PDF annotation)
- Localsend (Local network file sharing)
- WhatsApp (Messaging client)
- Spotify (Music streaming)
- Dropbox (Cloud storage & sync)
- Todoist (Task management)
- Telegram (Secure messaging)
- Ulauncher (Application launcher)
- Syncthing (Decentralized file sync)

### Additional Tools
- Git configurations
- Shell enhancements
- System utilities
- Development tools

## Common Tasks

### Creating Team Configurations

1. Set up your development environment
2. Share the generated config from Downloads
3. Team members can use it for consistent setups

### Managing Multiple Configs

- Keep different configs for different projects
- Use timestamp-based naming for version control
- Share specific configs for different team roles

### Automated Setup

For automated deployments:
1. Create a base configuration
2. Copy to Downloads on target machine
3. Run Setupr with the config

## Contributing

We welcome contributions! Please check our [Contributing Guide](CONTRIBUTING.md) for details.

## Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Join our community discussions
- Check our documentation wiki

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by ByteTrix
