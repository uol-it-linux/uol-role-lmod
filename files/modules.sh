########################################################################
. /etc/profile.d/00-modulepath.sh

#  This is the system wide source file for setting up modules
########################################################################

if [ -z "${LMOD_ALLOW_ROOT_USE+x}" ]; then
  LMOD_ALLOW_ROOT_USE=yes
fi

( [ -n "${USER_IS_ROOT:-}" ] || ( [ "${LMOD_ALLOW_ROOT_USE:-}" != yes ] && [ $(id -u) = 0 ] ) ) && return


if [ -z "${MODULEPATH_ROOT:-}" ]; then
  export USER=${USER-${LOGNAME}}  # make sure $USER is set
  export LMOD_sys=`uname`

  export MODULEPATH_ROOT="/usr/share/modulefiles"
  MODULEPATH_INIT="/usr/share/lmod/lmod/init/.modulespath"
  if [ -f ${MODULEPATH_INIT} ]; then
     for str in $(cat ${MODULEPATH_INIT} | sed 's/#.*$//'); do   # Allow end-of-line comments.
        for dir in $str; do
            if [ -d $dir ]; then
                export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $dir)
            fi
        done
     done
  else
     export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys $MODULEPATH_ROOT/Core)
     export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core)
  fi

  #################################################################
  # Prepend any directories in LMOD_SITE_MODULEPATH to $MODULEPATH
  #################################################################

  if [ -n "${LMOD_SITE_MODULEPATH:-}" ]; then
    OLD_IFS=$IFS
    IFS=:
    for dir in $LMOD_SITE_MODULEPATH; do
      export MODULEPATH=$(/usr/share/lmod/lmod/libexec/addto MODULEPATH $dir)
    done
    IFS=$OLD_IFS
  fi

  export BASH_ENV=/usr/share/lmod/lmod/init/bash

  #
  # If MANPATH is empty, Lmod is adding a trailing ":" so that
  # the system MANPATH will be found
  if [ -z "${MANPATH:-}" ]; then
    export MANPATH=:
  fi
  export MANPATH=$(/usr/share/lmod/lmod/libexec/addto MANPATH /usr/share/lmod/lmod/share/man)
fi

findExec ()
{
  Nm=$1
  confPath=$2
  execNm=$3
  eval $Nm=$confPath
  if [ ! -x $confPath ]; then
    if [ -x /bin/$execNm ]; then
       eval $Nm=/bin/$execNm
    elif [ -x /usr/bin/$execNm ]; then
       eval $Nm=/usr/bin/$execNm
    fi
  fi
  unset Nm confPath execNm
}

findExec READLINK_CMD /usr/bin/readlink  readlink
findExec PS_CMD       /usr/bin/ps        ps
findExec EXPR_CMD     /usr/bin/expr      expr
findExec BASENAME_CMD /usr/bin/basename  basename

unset -f findExec

if [ -f /proc/$$/exe ]; then
  my_shell=$($READLINK_CMD /proc/$$/exe)
else
  my_shell=$($PS_CMD -p $$ -ocomm=)
fi
my_shell=$($EXPR_CMD    "$my_shell" : '-*\(.*\)')
my_shell=$($BASENAME_CMD $my_shell)

case ${my_shell} in
   bash|zsh|sh) ;;
   ksh*) my_shell="ksh";;
   *) my_shell="sh";;
esac

if [ -f /usr/share/lmod/lmod/init/$my_shell ]; then
   .    /usr/share/lmod/lmod/init/$my_shell >/dev/null # Module Support
else
   .    /usr/share/lmod/lmod/init/sh        >/dev/null # Module Support
fi
unset my_shell PS_CMD EXPR_CMD BASENAME_CMD MODULEPATH_INIT LMOD_ALLOW_ROOT_USE READLINK_CMD

# Local Variables:
# mode: shell-script
# indent-tabs-mode: nil
# End: