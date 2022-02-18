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
#  completion
#
. ~/.git-completion.bash

#
#  cached values (for use in scripts?)
#
export HOST=$(hostname -s)

#
#  it's-a-me
#
export TZ="America/New_York" # home sweet home
export PATH=${PATH}:${HOME}/bin

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

#
#  application-related
#
export LESS="-i -j5 -M -x4 -R"
if [[ `which lesspipe` != "" ]] ; then
  eval "$(lesspipe)" # for reading .gz files and such
fi
export PAGER=less
export LC_COLLATE=C # so sort acts the way i want it to

alias bat="batcat"
export BAT_THEME="TwoDark"

export BROWSER="google-chrome"

if [[ $I_AM_A_MAC == 1 ]] ; then
  # for emacsclient
  export PATH=${PATH}:/Applications/Emacs.app//Contents/MacOS/bin-x86_64-10_10
fi
export EDITOR="emacsclient -c"
export GIT_EDITOR=$EDITOR
export VISUAL=$EDITOR
alias ed="ed -p '*'"
alias ec="emacsclient -n"
function en {
  # see terminfo section in bin/dev-machine-recipe
  TERM=xterm-24bits emacsclient -nw $*
}

if [[ `which nproc` != "" ]] ; then
  export NUM_PROCESSORS=$(nproc)
elif [[ -a /proc/cpuinfo ]] ; then
  export NUM_PROCESSORS=$(grep -c processor /proc/cpuinfo)
elif [[ $I_AM_A_MAC -eq 1 && -e /usr/sbin/sysctl ]] ; then
  export NUM_PROCESSORS=$(sysctl -n hw.ncpu)
fi

if [[ -z "${NUM_PROCESSORS}" ]] ; then
  export NUM_PROCESSORS=1
else
  export NUM_PROCESSORS=$(($NUM_PROCESSORS - 1))
fi

export MAKEFLAGS=-j${NUM_PROCESSORS}

#
#  bash options
#
set -o emacs
set -o notify  #  asynchronous job notification
export IGNOREEOF=1
export INPUTRC="~/.inputrc"

#
#  local config (should be before aliases)
#
if test -a ~/.bashrc_local ; then
  . ~/.bashrc_local
fi

#
#  PS1 using starship
#
function ps1_working_directory {
  if [[ -n "${GOPATH}" && $PWD =~ "${GOPATH}/src" ]] ; then
    echo "(${gvm_go_name}) $(realpath --relative-to "${GOPATH}/src" "${PWD}")"
  elif [[ $PWD == $HOME ]] ; then
    echo "~"
  elif [[ $PWD =~ "${HOME}/" ]] ; then
    echo "~/$(realpath --relative-to "${HOME}" "${PWD}")"
  else
    echo $PWD
  fi
}
function set_window_title {
  echo -ne "\033]0;$HOST:$(ps1_working_directory)\007"
}
if [[ "$INSIDE_EMACS" == "" ]] ; then
  starship_precmd_user_func=set_window_title
else
  unset starship_precmd_user_func
fi

if [[ `which starship` != "" ]] ; then
  eval "$(starship init bash)"
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
export VALGRIND_OPTS="--num-callers=50 --error-limit=no"
alias valgrind-m="valgrind --leak-check=yes --show-reachable=yes"
alias valgrind-ruby="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no"
alias valgrind-ruby-mem0="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=00 --free-fill=00"
alias valgrind-ruby-mem="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=6D --free-fill=66"

#
#  ruby dev
#
alias be="bundle exec"
alias bi="bundle install"
export JRUBY_OPTS="${JRUBY_OPTS} --dev"

#
#  docker things - from https://www.calazan.com/docker-cleanup-commands/
#
function dockerdocker {
  image=$1
  shift
  pwd=$(pwd)
  docker run -it --mount=type=bind,source=${pwd},target=/$(basename $pwd) $image $*
}

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

function make-targets {
  if [ -n $1 ] ; then
    file=$1
  else
    file=Makefile
  fi
  grep '^[^#[:space:]].*:' $file | cut -d: -f1
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
#  crap added by other packages, or for other packages
#
# rbenv
if [[ -d $HOME/.rbenv ]] ; then
  export PATH="${HOME}/.rbenv/bin:${PATH}"
  eval "$(rbenv init -)"
fi

# gvm!
[[ -s "/home/flavorjones/.gvm/scripts/gvm" ]] && source "/home/flavorjones/.gvm/scripts/gvm"
unset DYLD_LIBRARY_PATH

# direnv
which direnv > /dev/null && eval "$(direnv hook bash)"

# dircolors
if [[ -f ~/.dir_colors/dircolors ]] ; then
  eval `dircolors ~/.dir_colors/dircolors`
fi

# ugh npm
if [[ -d ${HOME}/.npm-global ]] ; then
  export NPM_CONFIG_PREFIX=${HOME}/.npm-global
  export PATH=${PATH}:${NPM_CONFIG_PREFIX}/bin
fi

# Added by Krypton
export GPG_TTY=$(tty)

# shopify/ejson
export EJSON_KEYDIR=${HOME}/.config/ejson/keys

# shopify dev
if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
  source /opt/dev/dev.sh
fi
