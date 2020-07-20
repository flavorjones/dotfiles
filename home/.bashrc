# -*- sh -*-

#
#  system types 
#
if [[ $OSTYPE =~ "darwin" ]] ; then
  export I_AM_A_MAC=1
  export I_AM_LINUX=0
else
  export I_AM_A_MAC=0
  export I_AM_LINUX=1
fi

#
#  git stuff
#
export GIT_PS1_SHOWDIRTYSTATE=1
. ~/.git-completion.bash

#
#  prompts, environment, etc.
#
[[ -s /etc/bash_completion ]] && source /etc/bash_completion

function ps1_haxxor_info {
  prompt=""

  if [[ $rvm_path != "" ]] ; then
    prompt="${prompt} $(rvm-prompt)"
  fi

  if [[ $GVM_ROOT != "" ]] ; then
    prompt="${prompt} $(gvm-prompt)"
  fi

  prompt="${prompt} $(__git_ps1)"

  echo $prompt
}

function ps1_working_directory {
  if [[ $PWD =~ "${GOPATH}/src" ]] ; then
    echo "(${gvm_go_name}) $(realpath --relative-to "${GOPATH}/src" "${PWD}")"
  elif [[ $PWD == $HOME ]] ; then
    echo "~"
  elif [[ $PWD =~ "${HOME}/" ]] ; then
    echo "~/$(realpath --relative-to "${HOME}" "${PWD}")"
  else
    echo $PWD
  fi
}

shift_to_titlebar='\[\e]0;'
shift_to_tty='\a\]'
color="34" # blue
color_bold_text='\[\e[${color};1;7m\]'
color_text='\[\e[0;${color};1m\]'
regular_text='\[\e[0m\]'
export XTERM_PS1="${shift_to_titlebar}\$(ps1_working_directory)${shift_to_tty}"
export REGULAR_PS1="\n${color_text}\h \$(ps1_haxxor_info)\n${color_bold_text}\W${color_text} \$ ${regular_text}"
export BRIEF_PS1="\n${color_text}\h \$ ${regular_text}"
export REALLY_BRIEF_PS1="\n${color_text}\$ ${regular_text}"

if [[ "${INSIDE_EMACS}" != '' ]] ; then
  export PS1=$REGULAR_PS1
else
  export PS1="${XTERM_PS1}${REGULAR_PS1}"
fi

#
#  cached values (for use in scripts?)
#
export HOST=$(hostname)

#
#  it's-a-me
#
export TZ="America/New_York" # home sweet home
export PATH=${PATH}:${HOME}/bin:${HOME}/.emacs.d

#
#  application-related
#
if [[ $I_AM_A_MAC == 1 ]] ; then
  # for emacsclient
  export PATH=${PATH}:/Applications/Emacs.app//Contents/MacOS/bin-x86_64-10_10
fi

export EDITOR="emacsclient -c"
export GIT_EDITOR=$EDITOR
export VISUAL=$EDITOR
export PAGER=less
export BROWSER="google-chrome"

export LESS="-i -j5 -M -x4 -R"
# export LESSCHARSET="latin1"
export LC_COLLATE=C # so sort acts the way i want it to

if [[ -a /proc/cpuinfo ]] ; then
  export NUM_PROCESSORS=$(grep -c processor /proc/cpuinfo)
else
  export NUM_PROCESSORS=1
fi

export MAKEFLAGS=-j${NUM_PROCESSORS}
export VALGRIND_OPTS="--num-callers=50 --error-limit=no"

#
#  bash options
#
set -o emacs
set -o notify  #  asynchronous job notification
export IGNOREEOF=1
export INPUTRC="~/.inputrc"

#
#  ~/local/ and ~/.local/
#
for localdir in ${HOME}/local ${HOME}/.local ; do
  if test -a ${localdir} ; then
    export PATH=${localdir}/bin:${PATH}
    export LD_LIBRARY_PATH=${localdir}/lib:${LD_LIBRARY_PATH}
    export MANPATH=${MANPATH}:${localdir}/man
    export INFOPATH=${INFOPATH:+${INFOPATH}:}${localdir}/info
  fi
done

# jruby dev
export JRUBY_OPTS="${JRUBY_OPTS} --dev"

# more jruby dev - see https://github.com/jruby/jruby/issues/4834
export JAVA_OPTS="$(echo --add-opens=java.base/{java.lang,java.security,java.util,java.security.cert,java.util.zip,java.lang.reflect,java.util.regex,java.net,java.io,java.lang,javax.crypto}=ALL-UNNAMED) --illegal-access=warn"


#
#  local config (should be before aliases)
#
if test -a ~/.bashrc_local ; then
  . ~/.bashrc_local
fi


#########################################
#  aliases
#
if [[ $I_AM_A_MAC == 1 ]] ; then
  export MY_LSARGS="-F -G"
else
  export MY_LSARGS="-F --color=auto --time-style=long-iso"
fi
alias ls="ls \${MY_LSARGS}"
alias lsa="ls -a \${MY_LSARGS}"
alias lsal="ls -al \${MY_LSARGS}"
alias lsl="ls -l \${MY_LSARGS}"

alias cp="cp -i"
alias mv="mv -i"
alias jobs="jobs -l"
alias df="df -k"

alias edit=$EDITOR
alias ed="ed -p '*'"
alias ec="emacsclient -n"

alias flock="chmod 444"
alias funlock="chmod 664"  #  644
alias dlock="chmod 555"
alias dunlock="chmod 775"  #  755
alias fyeo="chmod g-r-w-x,o-r-w-x"

#
#  general dev
#
#alias git=git-together # https://github.com/kejadlen/git-together
#export GIT_TOGETHER_NO_SIGNOFF=1 # https://github.com/pivotal/git-author

#
#  C dev
#
alias valgrind-m="valgrind --leak-check=yes --show-reachable=yes"
alias valgrind-ruby="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no"
alias valgrind-ruby-mem0="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=00 --free-fill=00"
alias valgrind-ruby-mem="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=6D --free-fill=66"

#
#  ruby dev
#
alias be="bundle exec"
alias bi="bundle install"

#
#  docker things - from https://www.calazan.com/docker-cleanup-commands/
#
alias dockerkillall='docker kill $(docker ps -q)'
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'
alias dockerclean='dockercleanc || true && dockercleani'

# calendar assistant FTW
alias ca="calendar-assistant"

# what processes are accessing the network?
# "preload.js" is signal
alias netps='sudo netstat -nputw | egrep -v " [0-9]+/(slack|dropbox|chrome|zoom|Telegram|Discord|preload.js)[ $]"'

if [[ $I_AM_LINUX == 1 ]] ; then
  alias open="xdg-open"
fi

alias xc="xclip -selection clipboard"

function psg {
  pgrep -f ${*} | xargs --no-run-if-empty ps -F --pid
}

function psk {
  psg ${*}
  pkill -f ${*}
}

function epochtime {
  # "info date" for more info
  date -d "1970-01-01 UTC $1 seconds" +"%Y-%m-%d %T %z"
}

function awkp {
  narg=$1
  awk "{print \$$1}"
}

function notify-do {
  $@
  status=$?
  if [[ $status -eq 0 ]] ; then
    notify-send --urgency=low --icon=stock_yes "success: '$*'"
  else
    notify-send --urgency=low --icon=stock_no "error: '$*'"
  fi
}

function gocd {
  name=$1
  importpath="${GOPATH}/src/${name}"
  if [[ -d ${importpath} ]] ; then
    echo ${importpath}
    cd ${importpath}
  elif echo ${name} | grep "/" > /dev/null ; then
    results=$(find "${GOPATH}/src" -path "*/${name}" | head -1)
    if [[ -d $results ]] ; then
      echo ${results}
      cd ${results}
    else
      echo "ERROR: could not find a match for '${name}'"
    fi
  else
    results=$(find "${GOPATH}/src" -name "${name}" -prune | head -1)
    if [[ -d $results ]] ; then
      echo ${results}
      cd ${results}
    else
      echo "ERROR: could not find a match for '${name}'"
    fi
  fi
}


#
#  kubernetes hacks - thanks to colin humphreys
#
if [[ `which kubectl` != "" ]] ; then
  alias k=kubectl
  alias ka='kubectl apply'
  alias kaf='kubectl apply -f'
  alias kg='kubectl get'
  alias kc='kubectl config'
  alias kd='kubectl describe'
  alias kga='kubectl get all --all-namespaces'
  alias kge='kubectl get events'
  function kns() {
    kubectl config set-context --current --namespace=$1
  }

  if [[ `which kapp` != "" ]] ; then
    alias kf='kapp deploy -a auto-kapp-$(date +%s) -f'
  fi

  if [[ `which kind` != "" ]] ; then
    alias kind-create='kind create cluster && kind-kubeconfig'
    alias kind-delete='kind delete cluster'
    alias kind-reset='kind-delete && kind-create'
    alias kind-kubeconfig='export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"'
  fi

  source <(kubectl completion bash)
fi

#
#  crap added by other packages
#
### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# rvm!
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# added by travis gem
[ -f /home/flavorjones/.travis/travis.sh ] && source /home/flavorjones/.travis/travis.sh

# gvm!
[[ -s "/home/flavorjones/.gvm/scripts/gvm" ]] && source "/home/flavorjones/.gvm/scripts/gvm"
unset DYLD_LIBRARY_PATH

# direnv
which direnv > /dev/null && eval "$(direnv hook bash)"

# dircolors
if [[ -f ~/.dir_colors/dircolors ]] ; then
  eval `dircolors ~/.dir_colors/dircolors`
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f /home/flavorjones/tmp/google-cloud-sdk/path.bash.inc ]; then
  source '/home/flavorjones/tmp/google-cloud-sdk/path.bash.inc'
fi

# The next line enables shell command completion for gcloud.
if [ -f /home/flavorjones/tmp/google-cloud-sdk/completion.bash.inc ]; then
  source '/home/flavorjones/tmp/google-cloud-sdk/completion.bash.inc'
fi

# ugh npm
export NPM_CONFIG_PREFIX=~/.npm-global
export PATH=${PATH}:${NPM_CONFIG_PREFIX}/bin

# Added by Krypton
export GPG_TTY=$(tty)
