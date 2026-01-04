# -------------------------------- #
# Setup Oh My Zsh
# -------------------------------- #

export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="spaceship"

SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  exec_time     # Execution time
  line_sep      # Line break
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SUFFIX=" "

plugins=(git asdf)

source $ZSH/oh-my-zsh.sh

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

# Load Plugins
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions


# -------------------------------- #
# Setup Node
# -------------------------------- #
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# -------------------------------- #
# Configure Ruby Gems
# -------------------------------- #
export PATH=/opt/homebrew/opt/ruby/bin:/opt/homebrew/lib/ruby/gems/3.0.0/bin:$PATH
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"


# -------------------------------- #
# Configure go
# -------------------------------- #
export DEFAULT_GOVERSION="1.25.0"
export GOROOT="$HOME/.asdf/installs/golang/$DEFAULT_GOVERSION/go"
export GOPATH="$HOME/go/go$DEFAULT_GOVERSION"
export PATH=$GOPATH/bin:$PATH

function go-reshim() {
    asdf reshim golang
    mkdir -p ~/go/$(go env GOVERSION)
    export GOROOT="$(dirname $(dirname $(asdf which go)))"
    export GOPATH="$HOME/go/$(go env GOVERSION)"
    export PATH=$(echo $PATH | sed "s#$HOME/go/go[0-9]\.[0-9]\{1,5\}\.[0-9]\{1,5\}/bin#$GOPATH/bin#") # Replace the current go version in path
}

# -------------------------------- #
# configure zig
# -------------------------------- #
export ZLSPATH="$HOME/.zig/zls/zig-out/bin"
export PATH=$ZLSPATH:$PATH

# -------------------------------- #
# LLVM
# -------------------------------- #
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"


# -------------------------------- #
# Python
# -------------------------------- #

# export PYENV_ROOT="$HOME/.pyenv"
# if [[ -d $PYENV_ROOT/bin ]]; then
#     export PATH="$PYENV_ROOT/bin:$PATH"
# fi
# eval "$(pyenv init -)"

# -------------------------------- #
# Alias
# -------------------------------- #

alias vim=nvim
alias ll='ls -lah'

# Go to App Masters projects
function cdam() {
    cd ~/Documents/Projects/app-masters
}

# Ask politely to stop a process
function please_stop() {
    lsof -t -i "tcp:$1" | xargs sudo kill -15
}

# Terminates a process with extreme prejudice
function death_to() {
    lsof -t -i "tcp:$1" | xargs sudo kill -9
}

# Create or attach to a session
function tmn() {
    tmux new -A -s "$1"
}

function tma() {
    if [ -z "${1}" ]; then
        tmux attach
    else
        tmux attach -t "$1"
    fi
}

# Avoid "to many files open" error
ulimit -n 10240

# -------------------------------- #
# Java / sdkman
# -------------------------------- #

# export SDKMAN_DIR="$HOME/.sdkman"
# [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
#
# export ANDROID_HOME=~/.android/sdk
# export PATH=$PATH:$ANDROID_HOME/emulator
# export PATH=$PATH:$ANDROID_HOME/tools
# export PATH=$PATH:$ANDROID_HOME/tools/bin
# export PATH=$PATH:$ANDROID_HOME/platform-tools

export PATH="$HOME/.local/bin:$PATH"
