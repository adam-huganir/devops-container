
function is-interactive { [[ "$-" == "*i*" ]] ; }

# path stuff
export PYENV_ROOT="$HOME/.pyenv"
export OMZ_HOME=$HOME/.oh-my-zsh
export NVM_DIR="$HOME/.nvm"
export EDITOR="lvim"

export GCLOUD_HOME="$HOME/.local/google-cloud-sdk"

export PATH="$HOME/.local/bin:$PYENV_ROOT/bin:$GCLOUD_HOME/bin:$PATH"

# init pyenv
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# load nvm
source "$NVM_DIR/nvm.sh"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=${ZSH_THEME:-"agnostic"}

## History
HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=50000
SAVEHIST=100000

plugins=(
  command-not-found
  docker
  fast-syntax-highlighting
  fd
  gh
  git
  gitignore
  httpie
  isodate
  kubectx
  kubetail
  nmap
  pip
  poetry
  terraform
  ufw
  z
  zsh-autosuggestions
  zsh-completions
)
source "$ZSH/oh-my-zsh.sh"
FAST_HIGHLIGHT[use_brackets]=1  # brackets work correctly

# Completions and interactive code
if is-interactive; then
    source "$HOME/.fzf.zsh"
    source "$GCLOUD_HOME/completion.zsh.inc"
    source "$NVM_DIR/bash_completion"
    source <(helm completion zsh)
    source <(istioctl completion zsh)
    source <(kn completion zsh)
    source <(kubectl completion zsh)
    source <(poe _zsh_completion)
    source <(skaffold completion zsh)
    source <(stern --completion zsh)
    eval "$(register-python-argcomplete pipx)"
fi

compinit
