##########
#  bashrc file
##########
#
#  prompts, environment, etc.
#
export PS1="\[\e]0;\h\a\e[31;1m\]\w/\$ \[\e[0m\]"
export TZ="America/New_York"
export PATH=${PATH}:${HOME}/bin

#
#  cached values (for use in scripts?)
#
export HOST=$(hostname)

#
#  application-related
#
export X=xterm
export EDITOR="emacs -nw"
export VISUAL="emacs -nw"
export CVSEDITOR="emacs -nw"
export CVS_RSH=ssh
export LESS="-i -j5 -M -x4"
export VALGRIND_OPTS="--num-callers=50 --error-limit=no"

#
#  custom stuff
#
export MY_LSARGS="-F"

#
#  cvs environments
#
export MONKEYCVS=":ext:mike@monkey.csa.net:/home/mike/cvsrep"

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
alias  edit="emacs"
alias  ed="ed -p '*'"

alias  mypids="ps -fu ${LOGNAME}"
alias  allpids="ps -ef"
alias  pingme="ping -s ${DISPLAY%:*}"

alias  flock="chmod 444"
alias  funlock="chmod 664"  #  644
alias  dlock="chmod 555"
alias  dunlock="chmod 775"  #  755
alias  fyeo="chmod g-r-w-x,o-r-w-x"

alias  pu="pushd"
alias  po="popd"

alias  valgrind-m="valgrind --leak-check=yes --show-reachable=yes"

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


#
#  ############### defunct functions and aliases below here ###############
#

alias  al="alias"
alias  unal="unalias"

# these leftover from my ksh days
alias  whence="whence -v"
alias  fun="functions"
alias  unfun="unset -f"

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


function fork {
    ($@ &)
}


function forkx {
    (xterm -e "$@" &)
}
