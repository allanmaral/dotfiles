# -------------------------------- #
# Instal Prerequisites
#   (macOS only for now)
# -------------------------------- #

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install coreutils
brew install stow
brew install tmux
brew install neovim
brew install sqlite

# Install asdf
if ! [ -d ~/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
fi

# Install Tmux Plugin Manager
if ! [ -d ~/.tmux/plugins/tpm ]; then
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install nvm
if ! command -v nvm &> /dev/null; then
  PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash'
fi

# Install go
asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
asdf install golang 1.22.1
asdf global golang 1.22.1
asdf shell golang 1.22.1


# -------------------------------- #
# Stow dotfiles
# -------------------------------- #
stow git
stow zsh
stow tmux