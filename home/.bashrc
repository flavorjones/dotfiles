########## -*- sh -*-
#  bashrc file
##########
#
if [ -f /etc/bashrc ]; then
    . /etc/bashrc # redhat
fi
if [[ -e /etc/SuSE-release ]] ; then
    test -z "$PROFILEREAD" && . /etc/profile # suse, obviously
fi

# system types
if [[ $OSTYPE =~ "darwin" ]] ; then
    export I_AM_A_MAC=1
    export I_AM_LINUX=0
else
    export I_AM_A_MAC=0
    export I_AM_LINUX=1
fi
if [[ $OSTYPE == "cygwin" ]] ; then
    export I_AM_CYGWIN=1
else
    export I_AM_CYGWIN=0
fi

# git stuff
export GIT_PS1_SHOWDIRTYSTATE=1
. ~/.git-completion.bash

#
#  prompts, environment, etc.
#
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

#
#  shortened working directory
#
function ps1_working_directory {
  if [[ $PWD =~ "${GOPATH}/src" ]] ; then
    echo "(${gvm_go_name}) $(realpath --relative-to ${GOPATH}/src ${PWD})"
  elif [[ $PWD == $HOME ]] ; then
    echo "~"
  elif [[ $PWD =~ "${HOME}/" ]] ; then
    echo "~/$(realpath --relative-to ${HOME} ${PWD})"
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
export REALLY_BRIEF_PS1="\n\$ "

if [[ ${EMACS} == 't' ]] ; then
    #  don't use xterm escapes in emacs
    export PS1=$REGULAR_PS1
else
    export PS1="${XTERM_PS1}${REGULAR_PS1}"
fi
export TZ="America/New_York"
export PATH=${PATH}:${HOME}/bin:${HOME}/.emacs.d

#
#  cached values (for use in scripts?)
#
export HOST=$(hostname)

#
#  application-related
#
# export X=xterm # this is short enough to be bad. commented out.
# export EDITOR="emacs -nw"
export EDITOR="emacsclient -c"
export GIT_EDITOR=$EDITOR
export VISUAL=$EDITOR
export CVSEDITOR=$EDITOR
export PAGER=less
export CVS_RSH=ssh
export LESS="-i -j5 -M -x4 -R"
export BROWSER="google-chrome"
# export LESSCHARSET="latin1"
export VALGRIND_OPTS="--num-callers=50 --error-limit=no"
export LC_COLLATE=C # so sort acts the way i want it to
if [[ -a /proc/cpuinfo ]] ; then
  export NUM_PROCESSORS=$(grep -c processor /proc/cpuinfo)
else
  export NUM_PROCESSORS=1
fi
export MAKEFLAGS=-j${NUM_PROCESSORS}

#
#  custom stuff
#
if [[ $I_AM_A_MAC == 1 ]] ; then
    export MY_LSARGS="-F -G"
else
    export MY_LSARGS="-F --color=auto --time-style=long-iso"
fi

#
#  svn, cvs environments
#
export MONKEYCVS=":ext:mike@monkey.csa.net:/home/mike/cvsrep"
export MONKEYSVN="svn+ssh://mike@monkey.csa.net/home/mike/svnrep"

#
#  bash options
#
export IGNOREEOF=1
set -o emacs
set -o notify  #  asynchronous job notification
export INPUTRC="~/.inputrc"

#
#  tmp directory
#
# can't remember why i need this.
# if test "x${TEMP}" = "x" ; then
#     if ! test -d /tmp/${USER} ; then
#         mkdir /tmp/${USER}
#     fi
#     export TEMP=/tmp/${USER}
# fi

#
# ~/local/
#
if test -a ${HOME}/local ; then
    export PATH=${HOME}/local/bin:${PATH}
    export LD_LIBRARY_PATH=${HOME}/local/lib:${LD_LIBRARY_PATH}
    export MANPATH=${MANPATH}:${HOME}/local/man
    export INFOPATH=${INFOPATH:+${INFOPATH}:}${HOME}/local/info
fi

#
#  overrides for cygwin
#
if [[ $OSTYPE == "cygwin" ]] ; then
    export EDITOR="emacs -nw"
    export VISUAL=$EDITOR
    export CVSEDITOR=$EDITOR
fi

##########
#  local stuff (should be before aliases)
##########
if test -a ~/.bashrc_local ; then
    . ~/.bashrc_local
fi


##########
#  aliases
##########
alias  ls="ls \${MY_LSARGS}"
alias  lsa="ls -a \${MY_LSARGS}"
alias  lsal="ls -al \${MY_LSARGS}"
alias  lsl="ls -l \${MY_LSARGS}"

alias  cp="cp -i"
alias  mv="mv -i"
alias  jobs="jobs -l"
alias  df="df -k"

alias  em="( emacs & )"
alias  edit=$EDITOR
alias  ed="ed -p '*'"

alias  psme="ps -fu ${LOGNAME}"
function psg {
    pgrep -f ${*} | xargs --no-run-if-empty ps --pid
}

alias  pingme="ping -s ${DISPLAY%:*}"

alias  flock="chmod 444"
alias  funlock="chmod 664"  #  644
alias  dlock="chmod 555"
alias  dunlock="chmod 775"  #  755
alias  fyeo="chmod g-r-w-x,o-r-w-x"

alias  pu="pushd"
alias  po="popd"

alias  valgrind-m="valgrind --leak-check=yes --show-reachable=yes"
alias  valgrind-ruby="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no"
alias  valgrind-ruby-mem0="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=00 --free-fill=00"
alias  valgrind-ruby-mem="valgrind --num-callers=50 --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --freelist-vol=100000000 --malloc-fill=6D --free-fill=66"

alias  wget-site="wget -rkp -l inf -c --html-extension --no-parent '$1'"
alias  wget-site-full="wget -m -c -r -p -k --html-extension '$1'"
alias  wget-subsite="wget -rkp -l inf -c --html-extension --no-parent --no-host-directories --no-directories '$1'"

alias pc="proxychains $*"
alias pc-dig="proxychains dig @4.2.2.2 +tcp +short $*"

alias be="bundle exec"
alias bi="bundle install"

if [[ $I_AM_LINUX == 1 ]] ; then
    alias open="gnome-open"
fi

alias xc="xclip -selection clipboard"

if which colordiff > /dev/null ; then
    function diff {
        colordiff ${*} | $PAGER
    }
fi

function mykill {
# arg1: signal, arg2: proc name
    sig=${1}
    shift
    pkill -${sig} -u ${LOGNAME} ${@}
}

function  getenv {
  env | grep ${*};
}

#  pipe output into pager
function rl {
  ${*} 2>&1 | $PAGER;
}

function pids {
  ps -fu ${1}
}

function lsort {
  ls -l ${*} | sort -rn +4 -5
}

function  lse {
  ##########
  #  Function to 'ls -l' an executable in search path via 'which'.
  ##########
  foo=$( which ${@} )
  if test "x${foo}" != "x" ; then
    ls -lF $foo
  else
    echo "${@} not found"
  fi
}

function cvsdiff {
  cvs -q diff -w -b ${@}
}
function cvsdiffu {
  cvs -q diff -w -b -u ${@}
}
function cvsconflict {
    ## needs to be tested
    FILES=$(find . -regex '.*/CVS/Entries' -print)
    fgrep "Result" $FILES
}

function svndiff {
    svn diff --diff-cmd diff -x "-uwb" ${@}
}

function dtime {
    # "info date" for more info
    date -d "1970-01-01 UTC $1 seconds" +"%Y-%m-%d %T %z"
}

function fork {
    ($@ &)
}

function forkx {
    (xterm -e "$@" &)
}

function findsrc {
    if [[ "x$1" == "x" ]] ; then
        dir="."
    else
        dir="$1"
    fi
    find $dir -name '*.h' -or -name '*.hpp' -or -name '*.c' -or -name '*.cpp' -or -name '*.f' -or -name '*.f90' -or -name '*.cc' -or -name '*.H' -or -name '*.C' -or -name '*rb' -or -name '*rhtml'
}

#
#  ############### defunct functions and aliases below here ###############
#

alias  al="alias"
alias  unal="unalias"

# these leftover from my ksh days
alias  whence="whence -v"
alias  fun="functions"
alias  unfun="unset -f"
alias  ec="emacsclient -n"

## docker things - from https://www.calazan.com/docker-cleanup-commands/
# Kill all running containers.
alias dockerkillall='docker kill $(docker ps -q)'

# Delete all stopped containers.
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images.
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images.
alias dockerclean='dockercleanc || true && dockercleani'

# calendar assistant FTW
alias ca="calendar-assistant"


function  backup {
  ##########
  #  make a backup file of home directory
  #  skip compile-type files, bloomberg binary executables, directories,
  #  and the previous tar file.
  ##########
  backup_file=~/tar/${LOGNAME}.tar
  backup_list=~/tar/${LOGNAME}.list
  cd ~

  echo "making list of files to be backed up ..."
  find . ! -name "*.o" ! -name "*.tsk" \
         ! -name "*.lg" ! -name "*.err" \
         ! -name "lib*.a" \
         ! -name "*${LOGNAME}.tar*" \
         ! -type d  -print | tee ${backup_list}

  echo "backing up total of $( cat ${backup_list} | wc -l ) files ..."

  tar cvfF ${backup_file} ${backup_list}

  if [[ -a ${backup_file}.gz ]] ; then
    mv -f ${backup_file}.gz ${backup_file}.bak.gz
  fi
  gzip -v ${backup_file}
}

#
#  function to do 'rcsdiff' between this file and prod version
#  usage: mydiff <file> <library>
#
function mydiff {
  if [[ ${#} -lt 2 ]] ; then
    echo "usage: mydiff <file> <library>"
    return 1
  fi
  FILE=${1}
  DIR=${2}
  rcsdiff -w -b ${FILE} /bbsrc/${DIR}/${FILE},v
  return 0
}
function mydiffu {
  if [[ ${#} -lt 2 ]] ; then
    echo "usage: mydiff <file> <library>"
    return 1
  fi
  FILE=${1}
  DIR=${2}
  rcsdiff -w -b -u /bbsrc/${DIR}/${FILE},v ${FILE}
  return 0
}

function rx {
  #
  #  opens xterm on any machine.
  #
  if [[ ${#} -lt 1 ]] ; then
    echo "usage: rx <machine> [xresources]"
    return 1
  fi
  MACH=${1}
    shift
  ( xterm -si -title "${MACH}" -geometry 82x24 ${@} -e ssh ${MACH} & )

  return 0
}

function awkp {
    narg=$1
    awk "{print \$$1}"
}

# find "no scm"
function findns {
    path=$1
    shift
    find $path -not -path "*/.svn/*" -and -not -path '*/.git/*' $@
}

# jruby dev
export JRUBY_OPTS="${JRUBY_OPTS} --dev"

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


##########
#  crap added by other things
##########
# rbenv!
[[ -d "$HOME/.rbenv" ]] && eval "$(rbenv init -)"

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
