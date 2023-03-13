# -*- shell-script -*-
########################################################################
#  This is the system wide source file for setting up
#  modules:
#
########################################################################

set MY_NAME="/usr/share/lmod/lmod/init/cshrc"

if ( ! $?LMOD_ALLOW_ROOT_USE ) then
  set LMOD_ALLOW_ROOT_USE=yes
endif

set my_id = `id -u`
if ( $LMOD_ALLOW_ROOT_USE != yes && $my_id == 0 ) then
  exit
endif

if ( ! $?MODULEPATH_ROOT ) then
    if ( $?USER) then
        setenv USER $LOGNAME
    endif

    set UNAME = `uname`
    setenv LMOD_sys             $UNAME
    setenv MODULEPATH_ROOT      "/usr/share/modulefiles"
    set MODULEPATH_INIT = "/usr/share/lmod/lmod/init/.modulespath"
    if ( -f $MODULEPATH_INIT ) then
       	foreach str (`cat $MODULEPATH_INIT | sed 's/#.*$//'`)	# Allow end-of-line comments.
	   foreach dir ( $str )
              if ( -d $dir ) then
                 setenv MODULEPATH `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $dir`
              endif
           end
	end
    else
       setenv MODULEPATH `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH $MODULEPATH_ROOT/$LMOD_sys $MODULEPATH_ROOT/Core`
       setenv MODULEPATH `/usr/share/lmod/lmod/libexec/addto --append MODULEPATH /usr/share/lmod/lmod/modulefiles/Core`
    endif

    #################################################################
    # Prepend any directories in LMOD_SITE_MODULEPATH to $MODULEPATH
    #################################################################
    if ( $?LMOD_SITE_MODULEPATH ) then
       setenv MODULEPATH `/usr/share/lmod/lmod/libexec/addto MODULEPATH $LMOD_SITE_MODULEPATH`
    endif
       
    setenv BASH_ENV      "/usr/share/lmod/lmod/init/bash"

    #
    # If MANPATH is empty, Lmod is adding a trailing ":" so that
    # the system MANPATH will be found
    if ( ! $?MANPATH ) then
      setenv MANPATH :
    endif
    setenv MANPATH `/usr/share/lmod/lmod/libexec/addto MANPATH /usr/share/lmod/lmod/share/man`

endif

unset LMOD_ALLOW_ROOT_USE my_id UNAME LMOD_sys MODULEPATH_INIT

if ( -f  /usr/share/lmod/lmod/init/csh  ) then
  source /usr/share/lmod/lmod/init/csh
endif

# Local Variables:
# mode: shell-script
# indent-tabs-mode: nil
# End: