##########
#  bashrc file
##########

stty erase ^?

export HOST=$(hostname)
export LESS="-i -j5 -M -x4"

export EDITOR=emacs
export VISUAL=emacs
export CVSEDITOR="emacs -nw"
export PS1="\w/\$ "
## sample prefix so machine and env var are displayed in xterm title
#export PS1="\[\e]0;\h | \${DEFAULT_MWSERVICE} | \${BUILD_ROOT}\a\e[31;1m\]${PS1}\[\e[0m\]"

export VALGRIND_OPTS="--num-callers=50 --error-limit=no"

export X=xterm
export MY_LSARGS="-F"

export IGNOREEOF=1

set -o emacs
set -o notify  #  asynchronous job notification

export INPUTRC="~/.inputrc"

if test "x${TEMP}" = "x" ; then
    export TEMP=${HOME}/tmp
fi

#
# ~/local/
#
if test -a ~/local ; then
    export PATH=${HOME}/local/bin:${PATH}
#    export MANPATH=${MANPATH}:${HOME}/local/man
#    export INFOPATH=${INFOPATH:+${INFOPATH}:}${HOME}/local/info
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
alias  whence="whence -v"

alias  al="alias"
alias  unal="unalias"
alias  fun="functions"
alias  unfun="unset -f"

alias  em="( emacs & )"
alias  edit="emacs"
alias  ed="/usr/bin/ed -p '*'"

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
	sig=${1}
	shift
	pkill -${sig} -u ${LOGNAME} ${@}
}

function see {
  #
  #  my version of lookat that takes full pathname
  #  also keeps recently looked-at files in ${MY_TEMP}
  #
  if [[ ! -a ${1},v ]] ; then
    print "see: cannot find file ${1},v"
  else
    file=$( basename ${1} )
    rm -f ${MY_TEMP}/${file}
    co -p ${1} > ${MY_TEMP}/${file}
    vi -R ${MY_TEMP}/${file}
  fi
}

function seep {
  #
  #  puts copy of checked-in file to stdout
  #
  co -p ${1}
}

function  getenv {
  env | grep ${*};
}

function  l {
  eval ${*} | $PAGER;
}

function  pids {
  ps -fu ${1}
}

function lsort {
  ls -l ${*} | sort -rn +4 -5
}

function  lse {
  ##########
  #  Function to 'ls -l' an executable in search path via 'which'.
  ##########
  ls -lF $( which ${@} )
}

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

