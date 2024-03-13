# -------------------------------- #
# Instal Prerequisites
#   (macOS only for now)
# -------------------------------- #

# Install Homebrew
if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

brew install stow
brew install tmux
brew install neovim
brew install sqlite

# -------------------------------- #
# Stow dotfiles
# -------------------------------- #
stow git
stow zsh
stow tmux