# 🚀 zsh-tkube

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zsh Shell](https://img.shields.io/badge/zsh-shell-blue.svg)](https://www.zsh.org/)
[![Teleport](https://img.shields.io/badge/teleport-compatible-green.svg)](https://goteleport.com/)

A [Zsh shell](https://www.zsh.org/) plugin for quickly logging into Kubernetes clusters via [Teleport](https://goteleport.com/) with intelligent autocompletion and environment-based configuration.

## ✨ Features

- 🚀 **Quick login**: `tkube <env> <cluster>` shortcut for `tsh kube login`
- 🔐 **Auto-authentication**: Automatically authenticate to Teleport if needed
- 🌍 **Environment-aware**: Support for multiple environments (`prod`, `test`, `dev`, etc.)
- 🔍 **Smart autocompletion**: Auto-complete commands, environments and cluster names
- ⚙️ **Easy configuration**: Simple array configuration following Zsh best practices
- 📦 **Plugin manager compatible**: Works with Oh My Zsh, Zinit, Antigen, and other managers
- 🎯 **Error handling**: Clear error messages and usage hints
- 📋 **Built-in help**: Comprehensive help system with `tkube help`

## 🛠️ Requirements

- [Zsh shell](https://www.zsh.org/) 5.0+
- [Teleport CLI (`tsh`)](https://goteleport.com/docs/installation/)
- [jq](https://stedolan.github.io/jq/) (for cluster name autocompletion)

## 📦 Installation

### Via Oh My Zsh

1. Clone this repository into Oh My Zsh custom plugins directory:
```zsh
git clone https://github.com/lidin10/zsh-tkube.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/tkube
```

2. Add to your plugins list in `~/.zshrc`:
```zsh
plugins=(... tkube)
```


### Manual Installation

1. Clone this repository:
```zsh
git clone https://github.com/lidin10/zsh-tkube.git ~/.zsh/plugins/tkube
```

2. Add to your `~/.zshrc`:
```zsh
source ~/.zsh/plugins/zsh-tkube/tkube.plugin.zsh
```

## ⚙️ Configuration

Configure your Teleport environments by setting Zsh variables in your `~/.zshrc`:

```zsh
# Define environments as array: env_name proxy_address env_name proxy_address ...
TKUBE_ENVS=(
    prod teleport.prod.company.com:443
    test teleport.test.company.com:443
    dev teleport.dev.company.com:443
    staging teleport.staging.company.com:443
)

# Auto-login configuration (default: true)
TKUBE_AUTO_LOGIN=true   # Enable automatic Teleport authentication
# TKUBE_AUTO_LOGIN=false  # Disable auto-login, manual 'tsh login' required
```

## 🚀 Usage

### Basic Usage

```zsh
# Login to a cluster in production environment
tkube prod my-cluster

# Login to a cluster in test environment
tkube test development-cluster
```

### Help and Information Commands

```zsh
# Show detailed help
tkube help

# Show available environments and authentication status
tkube status

# Show version and dependency information
tkube version
```

### With Autocompletion

1. Type `tkube ` and press `Tab` to see available commands and environments
2. Type `tkube prod ` and press `Tab` to see available clusters in the prod environment

### Adding New Environments

```zsh
# Add a new environment to existing configuration
TKUBE_ENVS+=(staging teleport.staging.company.com:443)

# Or completely redefine all environments
TKUBE_ENVS=(
    prod teleport.prod.company.com:443
    test teleport.test.company.com:443
    dev teleport.dev.company.com:443
    staging teleport.staging.company.com:443
)
```

## 📁 Project Structure

```
zsh-tkube/
├── tkube.plugin.zsh     # Main plugin file with all functions
├── _tkube               # Zsh completion file
├── LICENSE              # MIT License
└── README.md           # This file
```

## 🔧 How It Works

1. **Environment Resolution**: The plugin searches through the `$TKUBE_ENVS` array to find the Teleport proxy address
2. **Authentication Check**: Verifies if you're authenticated to the Teleport proxy using `tsh status`
3. **Auto-Login**: If not authenticated and auto-login is enabled, automatically runs `tsh login --proxy=<proxy>`
4. **Cluster Connection**: Executes `tsh --proxy=<proxy> kube login <cluster>` 
5. **Autocompletion**: Dynamically fetches cluster names from Teleport using `tsh kube ls --format=json`

## 🐛 Troubleshooting

### "Unknown environment" error
Make sure you've configured the environments correctly in the array:
```zsh
TKUBE_ENVS+=(myenv teleport.myenv.com:443)
```

### Authentication issues
If you want to disable auto-login and handle authentication manually:
```zsh
TKUBE_AUTO_LOGIN=false
tsh login --proxy=your-proxy.com  # Manual login
```

### Auto-login not working
Ensure you have proper network access to the Teleport proxy and check if MFA is required.

### Autocompletion not working
Ensure `jq` is installed and `tsh` is properly authenticated:
```zsh
# Install jq
brew install jq  # macOS
sudo apt install jq  # Ubuntu/Debian

# Check tsh authentication
tsh status
```

### No clusters found
Verify your Teleport connection and permissions:
```zsh
tsh --proxy=your-proxy.com kube ls
```

### Completion not loading
Make sure the completion file is in your fpath. You can check with:
```zsh
echo $fpath
```

If using a plugin manager, it should handle this automatically. For manual installation, add:
```zsh
fpath=(~/.zsh/plugins/zsh-tkube $fpath)
autoload -U compinit
compinit
```

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Commit your changes: `git commit -m 'Add amazing feature'`
3. Push to the branch: `git push origin feature/amazing-feature`
4. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Zsh shell](https://www.zsh.org/) for the powerful shell experience
- [Teleport](https://goteleport.com/) for secure infrastructure access
- [Oh My Zsh](https://ohmyz.sh/) and other plugin managers for the ecosystem
- [fish-tkube](https://github.com/lidin10/fish-tkube) for the original inspiration

---

<div align="center">
Made with ❤️ for the Zsh shell community
</div>
