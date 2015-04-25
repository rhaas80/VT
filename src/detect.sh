#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors


################################################################################
# Set default libraries to link if nothing provided by user
################################################################################
: ${VT_LIBS=VT dwarf elf vtunwind}

################################################################################
# Search
################################################################################

if [ -z "${VT_DIR}" ]; then
    echo "BEGIN MESSAGE"
    echo "VT selected, but VT_DIR not set. Checking some places..."
    echo "END MESSAGE"
    
    # We look in these directories
    DIRS="/usr /usr/local /opt/local ${HOME} c:/packages/VT"
    # look into each directory
    for dir in $DIRS; do
        # libraries might have different file extensions
        for libext in a so dylib; do
            # libraries can be in /lib or /lib64
            for libdir in lib64 lib; do
                # These files must exist
                FILES="include/VT.h $(for lib in ${VT_LIBS}; do echo ${libdir}/lib${lib}.${libext}; done)"
                # assume this is the one and check all needed files
                VT_DIR="$dir"
                for file in $FILES; do
                    # discard this directory if one file was not found
                    if [ ! -r "$dir/$file" ]; then
                        unset VT_DIR
                        break
                    fi
                done
                # don't look further if all files have been found
                if [ -n "$VT_DIR" ]; then
                    break
                fi
           done
           # don't look further if all files have been found
           if [ -n "$VT_DIR" ]; then
               break
           fi
        done
        # don't look further if all files have been found
        if [ -n "$VT_DIR" ]; then
            break
        fi
    done
    
    if [ -z "$VT_DIR" ]; then
        echo "BEGIN MESSAGE"
        echo "Did not find VT"
        echo "END MESSAGE"
    else
        echo "BEGIN MESSAGE"
        echo "Found VT in ${VT_DIR}"
        echo "END MESSAGE"
    fi
fi



################################################################################
# Configure Cactus
################################################################################

# VT_LIBS and VT_DIR are already, set remaining uset options based on them
: ${VT_INC_DIRS="${VT_DIR}/include"}
: ${VT_LIB_DIRS="${VT_DIR}/lib"}

: ${VT_INC_DIRS="$(${CCTK_HOME}/lib/sbin/strip-incdirs.sh ${VT_DIR})"}
: ${VT_LIB_DIRS="$(${CCTK_HOME}/lib/sbin/strip-libdirs.sh ${VT_DIR})"}

# Pass options to Cactus
echo "BEGIN MAKE_DEFINITION"
echo "VT_DIR            = ${VT_DIR}"
echo "VT_INC_DIRS       = ${VT_INC_DIRS}"
echo "VT_LIB_DIRS       = ${VT_LIB_DIRS}"
echo "VT_LIBS           = ${VT_LIBS}"
echo "END MAKE_DEFINITION"

echo 'INCLUDE_DIRECTORY $(VT_INC_DIRS)'
echo 'LIBRARY_DIRECTORY $(VT_LIB_DIRS)'
echo 'LIBRARY           $(VT_LIBS)'
