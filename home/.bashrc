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

#
#  prompts, environment, etc.
#
function scm_branch {
    if [[ -a ${PWD}/.git ]] ; then
        echo " ($(cat ${PWD}/.git/HEAD | cut -d/ -f3))"
    fi
}

if [[ ${EMACS} == 't' ]] ; then
    #  don't use xterm escapes in emacs
    export PS1='\[\e[31;1m\]\W|$?\[\e[0m\]\$ '
elif [[ -a /etc/debian_version ]] ; then
    if [[ ${BASH_VERSION} == "3.1.17(1)-release" ]] ; then
        # bash 3.1.17's non-printing character tokens \[\e ... \] are (apparently) broken
        export PS1="\e]0;\h:\w\a\e[31;1m\W|\$?\e[0m \$ "
    else
        export PS1="\[\e]0;\h:\w\$(scm_branch)\a\e[31;1m\]\W|\$?\[\e[0m\]\$ "
    fi
else
    export PS1="\[\e]0;\h:\w\a\e[31;1m\]\W|\$?\$ \[\e[0m\]"
fi
export TZ="America/New_York"
export PATH=${PATH}:${HOME}/bin

#
#  cached values (for use in scripts?)
#
export HOST=$(hostname)

#
#  application-related
#
# export X=xterm # this is short enough to be bad. commented out.
export EDITOR="emacs -nw"
export VISUAL=$EDITOR
export CVSEDITOR=$EDITOR
export CVS_RSH=ssh
export LESS="-i -j5 -M -x4 -R"
# export LESSCHARSET="latin1"
export VALGRIND_OPTS="--num-callers=50 --error-limit=no"

#
#  custom stuff
#
export MY_LSARGS="-F --color=auto"

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

alias  mypids="ps -fu ${LOGNAME}"
alias  mp="ps -fu ${LOGNAME}"
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

alias p-dig="proxychains dig @4.2.2.2 +tcp +short $*"

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
