<p align="center">
  <img src="https://github.com/ByteTrix/Setupr/blob/v2.2/assets/banner.png?raw=true" alt="Setupr Banner">
</p>

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

> 🚀 Fast, flexible, Set up your entire development workspace in minutes, not hours.
.

## 🌟 Why Setupr?

Setupr provides a streamlined, interactive way to set up your Linux development environment. With parallel installations and smart configuration management, you can get your workspace ready in minutes.

### Key Highlights

- **🎯 Interactive UI**: Beautiful terminal interface powered by `gum`
- **⚡ Parallel Processing**: Fast, concurrent package installations
- **🔄 Config Management**: Save and share your workspace setups
- **🎨 Multiple Modes**: Auto-install or pick your tools

## 🚀 Quick Start

```bash
wget -qO- https://raw.githubusercontent.com/ByteTrix/Setupr/v2.2/boot.sh | sudo bash
```

## 📋 Project Roadmap

Check our [Todo List](Todo.md) to see what features and improvements are planned for upcoming releases!

## 💫 Installation Modes

1. **🚀 Auto Install (Recommended)**
   - Uses curated defaults from recommended-config.json
   - Perfect for quick setups

2. **🔨 Interactive Installation**
   - Choose your tools through an interactive menu
   - Full control over selections

3. **⚙️ Save Configuration**
   - Create custom configurations
   - Export to JSON for team sharing

4. **📂 Load Configuration**
   - Import existing configurations
   - Perfect for team standardization

## 📦 Available Categories

### 👨‍💻 Development Languages
- Python Development Suite
- Node.js Development Stack
- Java Development Kit (JDK)
- Ruby Development Tools
- Go Programming Language
- Rust Development Tools
- PHP Development Stack
- Perl Programming Suite
- Swift Development Tools
- Kotlin Development Kit

### 🛠️ Code Editors & IDEs
- Visual Studio Code
- Sublime Text
- NeoVim
- PyCharm Community
- IntelliJ IDEA Community
- Android Studio
- Vim

### 🌐 Web Browsers
- Firefox
- Google Chrome
- Brave
- Opera

### ⚙️ Developer Tools
- Docker & Docker Compose
- Postman
- GitKraken
- DBeaver

### 💬 Communication Apps
- Slack
- Discord
- Microsoft Teams
- Telegram
- Signal

### 🎨 Media & Creative
- VLC Media Player
- OBS Studio
- GIMP
- Inkscape
- Kdenlive
- Spotify

### 📝 Productivity Tools
- LibreOffice
- Obsidian
- Notion
- Bitwarden

### 🖥️ Command Line Tools
- Tmux
- Ripgrep
- FZF
- Bat
- Exa
- JQ
- Htop
- NCDU

## ⚙️ Configuration Management

### Creating New Config

```bash
./install.sh
# Choose "⚙️ Save Configuration"
```

Your configuration is saved as:
```
~/Downloads/{name}-setupr.json
```

### Loading Existing Config

```bash
./install.sh
# Choose "📂 Load Configuration"
```

### Config Format

```json
{
  "name": "dev-setup",
  "description": "Development environment configuration",
  "timestamp": "2025-03-06 23:30:00",
  "packages": [
    "python3:apt",
    "nodejs:apt",
    "code:vscode",
    "docker:apt"
  ]
}
```

## 🤝 Team Usage

### Standardizing Environments

1. Create base configuration
2. Export {name}-setupr.json
3. Share with team
4. Team imports via Load Configuration

### Best Practices

- Create role-specific configs (frontend, backend, etc.)
- Document custom configurations
- Test configs in clean environments
- Keep configurations version controlled

## 🆘 Support

- 📝 [Documentation Wiki](https://github.com/ByteTrix/Setupr/wiki)
- 💬 [Community Discussions](https://github.com/ByteTrix/Setupr/discussions)
- 🐛 [Issue Tracker](https://github.com/ByteTrix/Setupr/issues)

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

MIT License - see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ by [ByteTrix](https://github.com/ByteTrix)
