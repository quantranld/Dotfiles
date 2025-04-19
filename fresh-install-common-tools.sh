#!/bin/bash

# Update package lists
sudo apt update

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Git
if command_exists git; then
    echo "Git is already installed"
else
    echo "Installing Git..."
    sudo apt install -y git
    git config --global user.email "qmenq07@gmail.com"
    git config --global user.name "QuanTran"
fi

# Install Visual Studio Code
if command_exists code; then
    echo "Visual Studio Code is already installed"
else
    echo "Installing Visual Studio Code..."
    sudo apt install -y software-properties-common apt-transport-https wget
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main"
    sudo apt update
    sudo apt install -y code
fi

# Install .NET SDK (last two LTS versions: 6.0 and 8.0 as of April 2025)
if command_exists dotnet; then
    echo ".NET SDK is already installed"
else
    echo "Installing .NET SDK..."
    wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt update
    sudo apt install -y dotnet-sdk-8.0
fi

# Install NVM (Node Version Manager) and latest LTS Node.js
if [ -d "$HOME/.nvm" ]; then
    echo "NVM is already installed"
else
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo "Installing latest Node.js LTS..."
    nvm install --lts
fi

# Install Pyenv (Python Version Manager) and latest stable Python
if command_exists pyenv; then
    echo "Pyenv is already installed"
else
    echo "Installing Pyenv..."
    sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    curl https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    echo "Installing latest stable Python..."
    pyenv install 3.12.3
    pyenv global 3.12.3
fi

# Install Rust
if command_exists rustc; then
    echo "Rust is already installed"
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Install lazygit
if command_exists lazygit; then
    echo "lazygit is already installed"
else
    echo "Installing lazygit..."
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
fi
# Install lazygit
apt-get install ripgrep

echo "Installation complete!"

# Grant execute permission to this script
chmod +x "$0"
