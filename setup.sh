# -------------------------------- #
# Instal Prerequisites
#   (macOS only for now)
# -------------------------------- #

# Install Homebrew
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    echo >> /Users/allan/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/allan/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew update
brew install coreutils
brew install stow
brew install tmux
brew install neovim
brew install sqlite
brew install pyenv
brew install llvm
brew install lld
brew install ripgrep

# Install Oh My Zsh
if ! [ -f $HOME/.oh-my-zsh/oh-my-zsh.sh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Clone and install the spaceship theme
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
fi

# Install asdf
if ! [ -d ~/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshenv
  . "$HOME/.asdf/asdf.sh"
fi

# Install Tmux Plugin Manager
if ! [ -d ~/.tmux/plugins/tpm ]; then
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install nvm
if ! command -v nvm &> /dev/null; then
  PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
fi

# Install deno
if ! command -v deno &> /dev/null; then
    asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
    asdf install deno latest
    asdf global deno latest
    asdf local deno latest
fi

# Install node
if ! command -v node &> /dev/null; then
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs 22.13.1
    asdf global deno 22.13.1
    asdf local deno 22.13.1
fi

# Install go
if ! command -v go &> /dev/null; then
    asdf plugin add golang https://github.com/asdf-community/asdf-golang.git
    asdf install golang 1.23.5
    asdf global golang 1.23.5
    asdf shell golang 1.23.5
fi

# Install zig
if ! command -v zig &> /dev/null; then
    asdf plugin add zig https://github.com/zigcc/asdf-zig.git
    asdf install zig 0.13.0
    asdf global zig 0.13.0
    asdf shell zig 0.13.0
fi

# Install Rust
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

# -------------------------------- #
# Stow dotfiles
# -------------------------------- #
stow git
stow zsh
stow tmux
stow nvim
stow ghostty
