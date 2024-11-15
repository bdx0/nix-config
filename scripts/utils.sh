#!/bin/bash

function note() {
  NOTE_DIR="$HOME/notes"
  NOTE_NAME=$(if [ "${1:-}" == "" ]; then echo ""; else echo "_${1}"; fi)
  TIMESTAMP="$(date +%Y%m%d%H%M)"

  nvim "${NOTE_DIR}/\$daily/${TIMESTAMP}${NOTE_NAME}.md"
}

function _zshrc() {
  # https://github.com/c-neto/ansible-configure-fedora/blob/main/files/dotfiles/.zshrc
  # >>> reference: https://carlosneto.dev/blog/2024/2024-02-08-starship-zsh/

  # list files with details
  alias ll="ls -larht"

  # show confirm prompt
  alias rm="rm -i"

  # documents shortcut
  alias cdd='cd "$HOME/Documents"'

  # show all history lines
  alias history="history 1"

  # alias for kubectl plugins
  alias kubectx="kubectl-ctx"
  alias kubens="kubectl-ns"

  # set the locale of the shell
  export LANG="en_US.UTF-8"

  # define VSCode as the default text editor
  export EDITOR="code -w"

  # include user-specific binaries and scripts
  export PATH="$HOME/.local/bin:$PATH"

  # add Rust binaries to the PATH
  export PATH="$PATH:$HOME/.cargo/bin"

  # add Go binaries to the PATH
  export PATH="$PATH:$HOME/go/bin"

  # system wide cli
  export PATH="$PATH:/usr/local/bin"

  # include Krew binaries for managing kubectl plugins
  export PATH="$PATH:$HOME/.krew/bin"

  # add bundle cli binaries of the rancher desktop
  export PATH="$PATH:$HOME/.rd/bin"

  # colorize "kubectl diff" command outputs
  export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"

  # specify characters considered as word boundaries for command line navigation
  export WORDCHARS=""

  # set the location and filename of the history file
  export HISTFILE="$HOME/.zsh_history"

  # set the maximum number of lines to be saved in the history file
  export HISTSIZE="100000"
  export SAVEHIST="$HISTSIZE"

  # fzf parameters used in all widgets - configure layout and wrapped the preview results (useful in large command rendering)
  export FZF_DEFAULT_OPTS="--height 100% --layout reverse --preview-window=wrap"

  # CTRL + R: put the selected history command in the preview window - "{}" will be replaced by item selected in fzf execution runtime
  export FZF_CTRL_R_OPTS="--preview 'echo {}'"

  # ALT + C: set "fd-find" as directory search engine instead of "find" and exclude venv of the results during searching
  export FZF_ALT_C_COMMAND="fd --type directory --ignore-file $HOME/.my-custom-zsh/.fd-fzf-ignore"

  # ALT + C: put the tree command output based on item selected
  export FZF_ALT_C_OPTS="--preview 'tree -C {}'"

  # CTRL + T: set "fd-find" as search engine instead of "find" and exclude .git for the results
  export FZF_CTRL_T_COMMAND="fd --exclude .git --ignore-file $HOME/.my-custom-zsh/.fd-fzf-ignore"

  # CTRL + T: put the file content if item select is a file, or put tree command output if item selected is directory
  export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && tree -C {} || bat --color=always --style=numbers {}'"

  # disable CTRL + S and CTRL + Q
  stty -ixon

  # enable comments "#" expressions in the prompt shell
  setopt INTERACTIVE_COMMENTS

  # append new history entries to the history file
  setopt APPEND_HISTORY

  # save each command to the history file as soon as it is executed
  setopt INC_APPEND_HISTORY

  # ignore recording duplicate consecutive commands in the history
  setopt HIST_IGNORE_DUPS

  # ignore commands that start with a space in the history
  setopt HIST_IGNORE_SPACE

  # >>> bindkey tip: to discovery the code of your keys, execute "$ cat -v" and press the key, the code will be printed in your shell.

  # use the ZLE (zsh line editor) in emacs mode. Useful to move the cursor in large commands
  bindkey -e

  # navigate words using Ctrl + arrow keys
  # >>> CRTL + right arrow | CRTL + left arrow
  bindkey "^[[1;5C" forward-word
  bindkey "^[[1;5D" backward-word

  # search history using Up and Down keys
  # >>> up arrow | down arrow
  bindkey "^[[A" history-beginning-search-backward
  bindkey "^[[B" history-beginning-search-forward

  # jump to the start and end of the command line
  # >>> CTRL + A | CTRL + E
  bindkey "^A" beginning-of-line
  bindkey "^E" end-of-line
  # >>> Home | End
  bindkey "^[[H" beginning-of-line
  bindkey "^[[F" end-of-line

  # navigate menu for command output
  zstyle ':completion:*:*:*:*:*' menu select
  bindkey '^[[Z' reverse-menu-complete

  # delete characters using the "delete" key
  bindkey "^[[3~" delete-char

  # fzf alias: CTRL + SPACE -> (ALT + C)
  bindkey "^@" fzf-cd-widget

  # fzf alias: CTRL + F -> (CTRL + T)
  bindkey "^F" fzf-file-widget

  # >>> load ZSH plugin

  # enable kubectl plugin autocompletion
  autoload -Uz compinit
  compinit
  source "$HOME/.my-custom-zsh/kubectl.plugin.zsh"
  source <(kubectl completion zsh)

  # load zsh-autosuggestions
  source "$HOME/.my-custom-zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"

  # load zsh-syntax-highlighting
  source "$HOME/.my-custom-zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # load fzf keybindings and completions
  eval "$(fzf --zsh)"

  # start Starship prompt
  eval "$(starship init zsh)"

}

function source_if_exists() {
  if test -r "$1"; then
    source "$1"
  fi
}

function get_path() {
  file=${1:-bash}
  echo "https://gist.githubusercontent.com/bdx0/c98d53543817529d860f465ef0696e50/raw/$file"
}
function get_p10k_configure() {
  # curl -sLS https://github.com/sarthakvk/powerlevel10k-config/raw/master/.p10k.zsh -o .p10k.zsh
  read_script .p10k.zsh >${HOME}/.p10k.zsh
}
function update() {
  sudo apt update && sudo apt upgrade && sudo apt dist-upgrade && sudo apt autoremove && sudo apt auto-clean
}

function read_script() {
  file=${1:-bash}
  url="$(get_path $file)"
  curl -sLS -H 'Cache-Control: no-cache, no-store' -H 'Pragma: no-cache' -H 'Expires: 0' $url
}

function load_multipass() {
  echo "load multipass script"
  source <(read_script multipass.bash)
}

function load_bash() {
  echo "load bash script"
  source <(read_script bash)
}

function rmdir() {
  local folder=$1
  [[ -d $folder ]] && rm -rf $folder && echo "remove folder: $folder"
}

function podclear() {
  # sudo gem install cocoapods-deintegrate cocoapods-clean
  crm ~/.pub-cache/hosted
  crm ~/.cocoapods
  crm ~/Library/Caches/CocoaPods
  crm Pods
  crm .symlinks
  crm Podfile.lock
  crm ~/Library/Developer/Xcode/DerivedData/*
  pod cache clean --all
  pod deintegrate
  pod repo update
  pod setup
  pod install
}

function flget() {
  local rootdir=$(git rev-parse --show-toplevel)
  cd $rootdir
  find . -name 'pubspec.yaml' | xargs -n 1 dirname | xargs -I {} zsh -c 'cd {}; pwd; flutter pub get'
}

function open_xcode() {
  open *.xcworkspace || open *.xcodeproj
}

function flutter_open_ios_xcode() {
  # local rootdir=$(git rev-parse --show-toplevel)
  # cd $rootdir
  # local projs=$(find . -name 'pubspec.yaml' | xargs -n 1 dirname | xargs -I {} zsh -c 'cd {}; pwd')
  # for p in $projs; do
  # 	echo $p
  # cd $p
  if [[ -d "ios" ]]; then
    pushd ios
    open_xcode
    popd
  fi
  # done
}

function sys_deep_clean() {
  rm -fr ~/Library/Caches/CocoaPods/
  rm -fr ~/.cocoapods/repos/master/
  rm -fr Pods/
}

function getip() {
  hostname=${1:-google.com}
  # echo $hostname
  # ping -c1 $hsotname | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p'
  ping $hostname -c3 | head -1 | grep -Eo '[0-9.]{4,}'
}

function mp4_ytdl() {
  url=${1:-""}
  if [ $url"" == "" ]; then
    echo "Please, input url"
  else
    # yt-dlp $url -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    yt-dlp $url -Sext:mp4:m4a
  fi
}
function xv_ytdl() {
  url=${1:-""}
  if [ $url"" == "" ]; then
    echo "Please, input url"
  else
    # yt-dlp $url -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    yt-dlp --proxy socks5://bobo.local:9050 $url -Sext:mp4:m4a
  fi
}

function xv_ytdl_batch() {
  file=${1:-""}
  if [ $file"" == "" ]; then
    echo "Please, input file path"
  else
    yt-dlp --proxy socks5://localhost:9050 -a $file -Sext:mp4:m4a
  fi
}

function mp3_ytdl() {
  url=${1:-""}
  if [ $url"" == "" ]; then
    echo "Please, input url"
  else
    # yt-dlp $url -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    yt-dlp $url -Sext:mp4:m4a --extract-audio --audio-format mp3
  fi
}

function purge_mac_node() {
  brew uninstall --ignore-dependencies node
  brew uninstall --force node
}

function script() {
  script_dir=$(pi pwd)/scripts
  script_name=${1:-cli}
  [ -n "$1" ] && shift
  PYENV_VERSION=3.9.15 python $script_dir/$script_name.py $*
}

function cleanup_dirs() {
  script $0 $*
}

function countfile() {
  find $1 -type f | wc -l
}

function install_ark() {
  curl -sLS https://get.arkade.dev | sudo sh
}

function adev() {
  poetry add ansible
  poetry add -D black flake8 mypy pytest pytest-cov
}

function pdev() {
  poetry add numpy
  poetry add -D black flake8 mypy pytest pytest-cov
}
function crm() {
  local folder=$1
  [[ -d $folder ]] && rm -rf $folder && echo "remove folder: $folder"
}

function podclear() {
  # sudo gem install cocoapods-deintegrate cocoapods-clean
  crm ~/.pub-cache/hosted
  crm ~/.cocoapods
  crm ~/Library/Caches/CocoaPods
  crm Pods
  crm .symlinks
  crm Podfile.lock
  crm ~/Library/Developer/Xcode/DerivedData/*
  pod cache clean --all
  pod deintegrate
  pod repo update
  pod setup
  pod install
}

function flget() {
  local rootdir=$(git rev-parse --show-toplevel)
  cd $rootdir
  find . -name 'pubspec.yaml' | xargs -n 1 dirname | xargs -I {} zsh -c 'cd {}; pwd; flutter pub get'
}

function open_xcode() {
  open *.xcworkspace || open *.xcodeproj
}

function flutter_open_ios_xcode() {
  # local rootdir=$(git rev-parse --show-toplevel)
  # cd $rootdir
  # local projs=$(find . -name 'pubspec.yaml' | xargs -n 1 dirname | xargs -I {} zsh -c 'cd {}; pwd')
  # for p in $projs; do
  # 	echo $p
  # cd $p
  if [[ -d "ios" ]]; then
    pushd ios
    open_xcode
    popd
  fi
  # done
}

function sys_deep_clean() {
  rm -fr ~/Library/Caches/CocoaPods/
  rm -fr ~/.cocoapods/repos/master/
  rm -fr Pods/
}

function getip() {
  hostname=${1:-google.com}
  # echo $hostname
  # ping -c1 $hsotname | sed -nE 's/^PING[^(]+\(([^)]+)\).*/\1/p'
  ping $hostname -c3 | head -1 | grep -Eo '[0-9.]{4,}'
}

function mp4_ytdl() {
  url=${1:-""}
  if [ $url"" == "" ]; then
    echo "Please, input url"
  else
    # yt-dlp $url -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    yt-dlp $url -Sext:mp4:m4a
  fi
}

function mp3_ytdl() {
  url=${1:-""}
  if [ $url"" == "" ]; then
    echo "Please, input url"
  else
    # yt-dlp $url -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
    yt-dlp $url -Sext:mp4:m4a --extract-audio --audio-format mp3
  fi
}

function purge_mac_node() {
  brew uninstall --ignore-dependencies node
  brew uninstall --force node
}

function script() {
  script_dir=$(pi pwd)/scripts
  script_name=${1:-cli}
  [ -n "$1" ] && shift
  PYENV_VERSION=3.9.15 python $script_dir/$script_name.py $*
}

function cleanup_dirs() {
  script $0 $*
}

function countfile() {
  find $1 -type f | wc -l
}

function install_ark() {
  curl -sLS https://get.arkade.dev | sudo sh
}

function make_alias() {
  alias vi=nvim
  alias vim=nvim
  alias v=nvim
  alias g=git
  alias c="script"
  # alias c='PYENV_VERSION=3.9.15  python cli.py'

  # alias history="history -dDi" # show timestamps, elapsed time
  # alias hist="history -dDi" # show timestamps, elapsed time
  alias cls=clear
  alias pary=paru
  # alias gut=git
  # Visual + interactive modes
  alias rm="rm -ivr"
  alias cp="cp -ivr"
  alias mv="mv -iv"
  alias mkdir="mkdir -pv"
  alias rmdir="rmdir -pv"

  alias myip="curl http://ipecho.net/plain; echo"
  alias brewup="brew update; brew upgrade;  brew cleanup; brew doctor"
  # alias flutter="fvm flutter"
  alias fl="fvm flutter"
  alias fld="fvm dart"
  alias flxc="flutter_open_ios_xcode"
  # alias docker=podman
  # alias docker-compose=podman-compose
  alias pov='poetry version $(git describe --tags --abbrev=0)'
  # alias po='poetry run'
  # alias pp='poetry run python'
  alias ap='ansible-playbook'
  alias apv='ansible-playbook --syntax-check --ask-vault-pass --vault-password-file vault.yml'
  alias apm='ansible-playbook main.yml'
  alias agu='ansible-galaxy collection install -r requirements.yml'
  alias agl='ansible-galaxy collection list'
  alias ave='ansible-vault edit vault.yml'
  alias xc='open_xcode'
  alias s="kitty +kitten ssh"
  alias m="dart pub global run melos"
  alias dkcu='docker-compose up --build'
  alias re='code ~/code/Workspace/rever.code-workspace'
  alias rdata='redis-cli -a "redis@361*"'
  alias pi="PYENV_VERSION=3.9.15 pycli"
  alias pexec='PYENV_VERSION=3.9.15 pyenv exec'
  alias po='PYENV_VERSION=3.9.15 poetry'
  alias spi="sudo -E env PYENV_VERSION=3.9.15 pycli"
  alias pe="PYENV_VERSION=3.9.15 pycli pve"
  alias pii="PYENV_VERSION=3.9.15 pyenv exec python -m pip install -U -e ."
  alias dkc='docker-compose'
  alias drun="docker run -it --rm "
  alias d1="docker --context r01"
  alias dc1="docker-compose --context r01"
  alias d2="docker --context r02"
  alias dc2="docker-compose --context r02"

  alias vi=nvim
  alias vim=nvim
  alias g=git
  alias c="script"
  # alias c='PYENV_VERSION=3.9.15  python cli.py'

  # alias history="history -dDi" # show timestamps, elapsed time
  alias cls=clear
  alias pary=paru
  # alias gut=git
  # Visual + interactive modes
  alias rm="rm -ivr"
  alias cp="cp -ivr"
  alias mv="mv -iv"
  alias mkdir="mkdir -pv"
  alias rmdir="rmdir -pv"

  alias myip="curl http://ipecho.net/plain; echo"
  alias brewup="brew update; brew upgrade;  brew cleanup; brew doctor"
  # alias flutter="fvm flutter"
  alias fl="fvm flutter"
  alias fld="fvm dart"
  alias flxc="flutter_open_ios_xcode"
  # alias docker=podman
  # alias docker-compose=podman-compose
  alias pov='poetry version $(git describe --tags --abbrev=0)'
  # alias po='poetry run'
  # alias pp='poetry run python'
  alias ap='ansible-playbook'
  alias apv='ansible-playbook --syntax-check --ask-vault-pass --vault-password-file vault.yml'
  alias apm='ansible-playbook main.yml'
  alias agu='ansible-galaxy collection install -r requirements.yml'
  alias agl='ansible-galaxy collection list'
  alias ave='ansible-vault edit vault.yml'
  alias xc='open_xcode'
  alias s="kitty +kitten ssh"
  alias m="dart pub global run melos"
  alias dkcu='docker-compose up --build'
  alias re='code ~/code/Workspace/rever.code-workspace'
  alias rdata='redis-cli -a "redis@361*"'
  alias pi="PYENV_VERSION=3.9.15 pycli"
  alias pexec='PYENV_VERSION=3.9.15 pyenv exec'
  alias po='PYENV_VERSION=3.9.15 poetry'
  alias spi="sudo -E env PYENV_VERSION=3.9.15 pycli"
  alias pe="PYENV_VERSION=3.9.15 pycli pve"
  alias pii="PYENV_VERSION=3.9.15 pyenv exec python -m pip install -U -e ."
  alias dkc='docker-compose'
  alias drun="docker run -it --rm "
  alias d1="docker --context r01"
  alias dc1="docker-compose --context r01"
  alias d2="docker --context r02"
  alias dc2="docker-compose --context r02"

  alias k="kubectl"
  alias ns="kubectl config set-context --current --namespace"
  alias ns="kubectl config set-context --current --namespace"
  alias kurrent="kubectl config view --minify -o \"jsonpath={..namespace}\" | xargs -I %s echo \"Current Namespace: %s\""
  alias nodetop="k get nodes | grep Ready | cut -d\" \" -f1 | xargs kubectl describe node | grep -E \"Name: |cpu |memory \""

  # direnv
  alias da="direnv allow"
}

function git_setup() {
  git config --global user.name "Dương Bảo Duy"
  git config --global user.email "baoduy.duong0206@gmail.com"
  git config --global pull.rebase "false"
  git config --global alias.trymerge "merge --no-commit --no-ff"
  git config --global alias.tm "trymerge"
  git config --global alias.dotfiles "clone git@github.com:bdx0/dotfiles.git"
}

function make_exports() {
  # export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
  export PATH="$ANDROID_HOME/cmake/3.22.1/bin:$PATH"
  # export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/Contents/Home
  export PATH="$PATH:$HOME/.pub-cache/bin"
  export PATH="$PATH:$HOME/fvm/default/bin"

  if command -v nvim 1>/dev/null 2>&1; then
    export EDITOR="$(command -v nvim)"
    export VISUAL="$(command -v nvim)"
  fi

  # Created by `pipx` on 2022-10-25 09:16:18
  export PATH="$PATH:$HOME/.local/bin"

  # export KUBECONFIG=~/.kube/config
  # export KUBECONFIG=~/code/py/pycli/kubeconfig
  if command -v brew 1>/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    export NVM_PREFIX="$(brew --prefix nvm)"
    [ -s "$NVM_PREFIX/nvm.sh" ] && \. "$NVM_PREFIX/nvm.sh"                                       # This loads nvm
    [ -s "$NVM_PREFIX/etc/bash_completion.d/nvm" ] && \. "$NVM_PREFIX/etc/bash_completion.d/nvm" # This loads nvm bash_completion
    # For VSCode
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

    # For VSCode Insiders
    defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false

    # For VSCodium
    defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false

    # To enable global key-repeat
    # this is helpful if you're using Vim in a PWA like code-server
    defaults write -g ApplePressAndHoldEnabled -bool false
  fi

  export PATH=$PATH:$HOME/.arkade/bin/

}

function mac_antigen() {

  plugins=(
    git
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-dircolors-solarized
    conda-zsh-completion
    brew
    poetry
    # zsh-direnv
    zsh-pyenv
    kubeenv
    # autodotenv
  )

  if ! [ -f $(brew --prefix)/share/antigen/antigen.zsh ]; then
    brew install antigen || sleep 10
  fi

  if [ -f $(brew --prefix)/share/antigen/antigen.zsh ]; then
    source $(brew --prefix)/share/antigen/antigen.zsh
    antigen_apply
  fi

}

function mac_init() {
  # eval "$(/opt/homebrew/bin/brew shellenv)"
  if command -v /opt/homebrew/bin/brew 1>/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    echo "Automation install brew command"
    # sleep 10
    # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  pyenv_cmd="$HOME/.pyenv/bin/pyenv"
  if ! command -v $pyenv_cmd 1>/dev/null 2>&1; then
    echo "Install pyenv"
    curl -L https://pyenv.run | bash
  fi

  # PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

  if command -v $pyenv_cmd 1>/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
  if ! [ -f "$(brew --prefix autoenv)/activate.sh" ]; then
    brew install 'autoenv'
  fi
  source $(brew --prefix autoenv)/activate.sh

  if command -v direnv 1>/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
  fi
  if command -v goenv 1>/dev/null 2>&1; then
    eval "$(goenv init -)"
  fi

  mac_antigen
}

function linux_init() {
  get_p10k_configure
  linux_antigen
}

function antigen_apply() {
  antigen use oh-my-zsh
  antigen bundle git
  antigen bundle command-not-found
  antigen bundle autojump
  antigen bundle brew
  antigen bundle common-aliases
  antigen bundle compleat
  antigen bundle git-extras
  antigen bundle git-flow
  antigen bundle npm
  antigen bundle osx
  antigen bundle web-search
  antigen bundle z
  antigen bundle sunlei/zsh-ssh
  # antigen bundle nocttuam/autodotenv

  # antigen bundle ptavares/zsh-direnv
  antigen bundle mattberther/zsh-pyenv
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-history-substring-search

  antigen bundle esc/conda-zsh-completion

  antigen bundle solacens/kubeenv

  #antigen theme denysdovhan/spaceship-prompt
  #antigen theme robbyrussell
  antigen theme romkatv/powerlevel10k

  antigen apply
}

function linux_antigen() {

  plugins=(
    git
    z
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-dircolors-solarized
    conda-zsh-completion
    brew
    poetry
    # zsh-direnv
    zsh-pyenv
    zsh-ssh
    # autodotenv
  )
  antigen_path=$HOME/.cache/antigen.zsh

  if ! [ -f $antigen_path ]; then
    curl -L git.io/antigen >$antigen_path
  fi

  if [ -f $antigen_path ]; then
    source $antigen_path
    antigen_apply

  fi

}

function kcdebug() {
  kubectl run -i --rm --tty debug --image=busybox --restart=Never -- sh
}

function kcnode() {
  kubectl get node -A
}

function kcpod() {
  kubectl get pod -A -o wide
}

# shopt -s histappend
# export HISTFILESIZE=
# shopt -s histappend
# PROMPT_COMMAND="history -n; history -a"
# unset HISTFILESIZE
# export HISTTIMEFORMAT="[%F %T] "
# export HISTFILE=~/.zhistory
# export HISTSIZE=100000
# export SAVEHIST=100000

# echo "script loading ..."
# # append a session's history on shell exit
# export HISTFILESIZE=
# export HISTTIMEFORMAT="[%F %T] "
# export HISTFILE=~/.zhistory
# export HISTSIZE=100000
# export SAVEHIST=100000
# initialize
# antigen
# make_alias
# echo "script loaded"

### Usage
# function load_script() {
#     curl -sLS -H 'Cache-Control: no-cache, no-store' -H 'Pragma: no-cache' -H 'Expires: 0' https://gist.githubusercontent.com/bdx0/a58a6d3a8bc4f894c54d657de1d2449c/raw/bash
# }

# if ping -c 2 -W 5 google.com 1>/dev/null 2>&1; then
#     echo "Connected!"
#     # source <(curl -sLS -H 'Cache-Control: no-cache, no-store' -H 'Pragma: no-cache' -H 'Expires: 0' https://gist.githubusercontent.com/bdx0/a58a6d3a8bc4f894c54d657de1d2449c/raw/bash)
#     source <(load_script)
# fi

# if ping -c 2 -W 5 google.com 1>/dev/null 2>&1
# then
#     # echo -en '\E[47;32m'"\033[1mS\033[0m"
#     echo "Connected!"
# else
#     # echo -en '\E[47;31m'"\033[1mZ\033[0m"
#     echo "Not Connected!"
# fi

# if [ ping -c 2 -W 5 google.com 1>/dev/null 2>&1 ]
# then
#     # echo -en '\E[47;32m'"\033[1mS\033[0m"
#     echo "Connected!"
#     eval "$(curl -sLS https://gist.githubusercontent.com/bdx0/a58a6d3a8bc4f894c54d657de1d2449c/raw/bash)"
# else
#     # echo -en '\E[47;31m'"\033[1mZ\033[0m"
#     echo "Not Connected!"
# fi

function dashboard_admin_pw() {
  microk8s kubectl get secret admin-user -n kube-system -o jsonpath={".data.token"} | base64 -d
  # microk8s kubectl -n kube-system describe secret $(microk8s kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
}

function git_init() {
  git config --global user.name "Dương Bảo Duy"
  git config --global user.email "baoduy.duong0206@gmail.com"
  git config --global pull.rebase "false"
  git config --global alias.trymerge "merge --no-commit --no-ff"
  git config --global alias.tm "trymerge"
  git config --global alias.dotfiles "clone git@github.com:bdx0/dotfiles.git"
}

function alias_init() {
  alias e=nvim
  alias g=git
  alias c="[[ -f '.c'] && bash .c"
  alias hist="history -dDi" # show timestamps, elapsed time
  alias cls=clear
  # Visual + interactive modes
  alias rm="rm -ivr"
  alias cp="cp -ivr"
  alias mv="mv -iv"
  alias mkdir="mkdir -pv"
  alias rmdir="rmdir -pv"

  alias myip="curl http://ipecho.net/plain; echo"
  alias brew_doctor="brew update; brew upgrade;  brew cleanup; brew doctor"
  # alias flutter="fvm flutter"
  alias sk="kitty +kitten ssh"
  alias sw="wezterm ssh"
  alias k="kubectl"
  alias ns="kubectl config set-context --current --namespace"
  alias ns="kubectl config set-context --current --namespace"
  alias kurrent="kubectl config view --minify -o \"jsonpath={..namespace}\" | xargs -I %s echo \"Current Namespace: %s\""
  alias nodetop="k get nodes | grep Ready | cut -d\" \" -f1 | xargs kubectl describe node | grep -E \"Name: |cpu |memory \""

  # direnv
  alias da="direnv allow"

  # alias config="$(which git) --git-dir='$HOME/code/GitHub/dotfiles/.git' --work-tree='$HOME'"
  # alias bare="$(which git) --git-dir='/tmp/test_repo' --work-tree='$HOME'"
  # alias bare-ui="GIT_DIR=/tmp/test_repo' GIT_WORK_TREE='$HOME' $(which tig) "
  # alias bare-ui="GIT_DIR=/tmp/test_repo' GIT_WORK_TREE='$HOME' $(which tig) "
  # alias bare-ui="GIT_DIR=/tmp/test_repo' GIT_WORK_TREE='$HOME' $(which tig) "

  # alias dot="GIT_DIR='$HOME/.config/dotfiles.git' GIT_WORK_TREE='$HOME' $(which tig)"
}

function open_tig() {
  GIT_DIR='$HOME/.config/dotfiles.git'
  GIT_WORK_TREE='$HOME'
  if [ -d $GIT_DIR ]; then
    echo "$GIT_DIR don't exit"
    return
  fi
  $(which tig)
}

function export_init() {
  export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
  # export ANDROID_HOME="$HOME/Library/Android/sdk"
  # export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH"
  # export PATH="$ANDROID_HOME/cmake/3.22.1/bin:$PATH"
  # export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/Contents/Home
  # export PATH="$PATH:$HOME/.pub-cache/bin"
  # export PATH="$PATH:$HOME/fvm/default/bin"

  if command -v nvim 1>/dev/null 2>&1; then
    export EDITOR="$(command -v nvim)"
    export VISUAL="$(command -v nvim)"
  fi

  # Created by `pipx` on 2022-10-25 09:16:18
  export PATH="$PATH:$HOME/.local/bin"

  # export KUBECONFIG=~/.kube/config
  # export KUBECONFIG=~/code/py/pycli/kubeconfig
  if command -v brew 1>/dev/null 2>&1; then
    export NVM_DIR="$HOME/.nvm"
    export NVM_PREFIX="$(brew --prefix nvm)"
    [ -s "$NVM_PREFIX/nvm.sh" ] && \. "$NVM_PREFIX/nvm.sh"                                       # This loads nvm
    [ -s "$NVM_PREFIX/etc/bash_completion.d/nvm" ] && \. "$NVM_PREFIX/etc/bash_completion.d/nvm" # This loads nvm bash_completion
    # For VSCode
    defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

    # For VSCode Insiders
    defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false

    # For VSCodium
    defaults write com.visualstudio.code.oss ApplePressAndHoldEnabled -bool false

    # To enable global key-repeat
    # this is helpful if you're using Vim in a PWA like code-server
    defaults write -g ApplePressAndHoldEnabled -bool false
  fi

  export PATH=$PATH:$HOME/.arkade/bin/

  [[ -s "/Users/dd/.gvm/scripts/gvm" ]] && source "/Users/dd/.gvm/scripts/gvm"
  export PATH=$HOME/.arkade/bin/:$PATH
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  # Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
  export PATH="$PATH:$HOME/.rvm/bin:$HOME/.cargo/bin"
  export DENO_INSTALL="$HOME/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
  export PATH="$HOME/.local/bin:$PATH"

}

function pyenv_init() {
  pyenv_cmd="$HOME/.pyenv/bin/pyenv"
  if ! command -v $pyenv_cmd 1>/dev/null 2>&1; then
    echo "Install pyenv"
    curl -L https://pyenv.run | bash
  fi

  if command -v $pyenv_cmd 1>/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
  fi
}

function goenv_init() {
  if command -v goenv 1>/dev/null 2>&1; then
    eval "$(goenv init -)"
  fi
}

function mac_install_antigen() {
  if ! [ -f $(brew --prefix)/share/antigen/antigen.zsh ]; then
    brew install antigen || sleep 10
  fi

  if [ -f $(brew --prefix)/share/antigen/antigen.zsh ]; then
    source $(brew --prefix)/share/antigen/antigen.zsh
  fi
}

function antigen_init() {
  mac_install_antigen

  antigen use oh-my-zsh
  antigen bundle git
  antigen bundle command-not-found
  antigen bundle autojump
  antigen bundle brew
  antigen bundle common-aliases
  antigen bundle compleat
  antigen bundle git-extras
  antigen bundle git-flow
  antigen bundle npm
  antigen bundle osx
  antigen bundle web-search
  antigen bundle z
  antigen bundle sunlei/zsh-ssh
  antigen bundle mattberther/zsh-pyenv
  antigen bundle zsh-users/zsh-autosuggestions
  antigen bundle zsh-users/zsh-completions
  antigen bundle zsh-users/zsh-syntax-highlighting
  antigen bundle zsh-users/zsh-history-substring-search
  antigen bundle solacens/kubeenv

  antigen apply
}

function mac_install_yabai() {
  # set codesigning certificate name here (default: yabai-cert)
  export YABAI_CERT=

  # stop yabai
  yabai --stop-service

  # reinstall yabai (remove old service file because homebrew changes binary path)
  yabai --uninstall-service
  brew reinstall koekeishiya/formulae/yabai
  codesign -fs "${YABAI_CERT:-yabai-cert}" "$(brew --prefix yabai)/bin/yabai"

  # finally, start yabai
  yabai --start-service
}

function mac_install_skhd() {
  brew install koekeishiya/formulae/skhd
  skhd --start-service
}

function mac_install_smartjump() {
  # brew install antigen || sleep 10
  brew install zoxide
  brew install fzf
  brew install autojump

}

function smartjump_init() {
  source <(fzf --zsh)
  eval "$(zoxide init zsh)"
  [[ -f "$(brew --prefix autojump)/etc/profile.d/autojump.sh" ]] && . "$(brew --prefix autojump)/etc/profile.d/autojump.sh"
}

function dotfiles_init() {
  export PROMPT_COMMAND="history -n; history -a"
  export HISTTIMEFORMAT="[%F %T] "
  export HISTFILE=~/.zhistory
  export HISTSIZE=100000
  export SAVEHIST=100000
  pyenv_init
  goenv_init
  git_init
  alias_init
  export_init
  antigen_init
  smartjump_init
}

function virt_reset_install() {
  brew remove libvirt virt-manager virt-viewer libvirt-glib and libvirt-python
  brew untap arthurk/homebrew-virt-manager
  brew untap jeffreywildman/homebrew-virt-manager

  brew install libvirt
  # brew tap arthurk/homebrew-virt-manager
  brew tap jeffreywildman/homebrew-virt-manager
  brew install virt-manager virt-viewer
  brew services list
  echo "run this: brew services start libvirt"
}

function virt_bobo() {
  virt-manager -c "qemu+ssh://root@bobo/system" --debug
  # virt-manager -c "qemu+ssh://bobo/system?socket=/var/run/libvirt/libvirt-sock"
}

function virt_goku() {
  virt-manager -c "qemu+ssh://root@goku/system" --debug
  # virt-manager -c "qemu+ssh://bobo/system?socket=/var/run/libvirt/libvirt-sock"
}

[ -x "$(which neofetch)" ] && neofetch
