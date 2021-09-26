#!/bin/bash

# Exit on error, pipelines fail sensibly, undeclared variable is an error
set -e -o pipefail -u

#########################################################
################ CONFIGURATION SECTION ##################
#########################################################

# The directory into which one should install.
# Subdirectories bin/lib/src will be made here
BASE_DIR=/opt/gcc

# The version to be installed.
# Should be of form X.Y.Z
VERSION=8.4.0

# The suffix to append to all executable names
# If unset, will be -$VERSION
SUFFIX=

# Which languages should be compiled
# Comma-separated list of all,ada,c,c++,fortran,go,java,jit,lto,objc,obj-c++
LANGUAGES=c,c++

# Number of threads to be used when compiling
THREADS=8

#########################################################
################ FUNCTION_DEFINITIONS ###################
#########################################################


# Accepts one argument, returns whether the directory given is in ldd's search path
function is_in_libpath() {
    local QUERY_DIR=$(readlink -f $1)

    local LIB_DIRS=$(/sbin/ldconfig -v 2> /dev/null | grep -v ^$'\t' | sed -e 's/:$//')
    local LIB_DIRS=$(echo "$LIB_DIRS" | xargs -n1 readlink -f)

    echo "$LIB_DIRS" | grep "^$QUERY_DIR$" &> /dev/null
    return $?
}

function initialize() {
    BIN_DIR=$BASE_DIR/bin
    LIB_DIR=$BASE_DIR/lib
    SRC_DIR=$BASE_DIR/src/$VERSION
    OBJ_DIR=$SRC_DIR/objdir

    if is_in_libpath $LIB_DIR; then
        CONFIG_BIN_DIR=$BASE_DIR/bin
    else
        CONFIG_BIN_DIR=$BASE_DIR/.bin
    fi

    if [ "$SUFFIX" = "" ]; then
        SUFFIX=-$VERSION
    fi
}

# Check out $VERSION from the gcc repository.
function git_checkout() {
    if [ ! -d $BASE_DIR/src/$VERSION ]; then
        mkdir -p $BASE_DIR/src
        local GIT_BRANCH=releases/gcc-$VERSION
        git clone --depth 1 -b $GIT_BRANCH git://gcc.gnu.org/git/gcc.git $BASE_DIR/src/$VERSION
    fi
}

# Download the dependencies
function download_deps() {
    local SRC_DIR=$BASE_DIR/src/$VERSION
    if [ ! -L $SRC_DIR/gmp -o \
         ! -L $SRC_DIR/mpc -o \
         ! -L $SRC_DIR/mpfr -o \
         ! -L $SRC_DIR/isl ]; then
        (cd $SRC_DIR && ./contrib/download_prerequisites)
    fi
}

# Run configure, if not already done
function configure_makefile() {
    if [ ! -f $OBJ_DIR/Makefile ]; then
        (
            mkdir -p $OBJ_DIR
            cd $OBJ_DIR;
            ../configure \
                --prefix=$BASE_DIR \
                --bindir=$CONFIG_BIN_DIR \
                --program-suffix=$SUFFIX \
                --enable-threads \
                --enable-languages=$LANGUAGES \
                --disable-multilib
        )
    fi
}

function build_gcc() {
    (
        cd $OBJ_DIR
        make -j$THREADS
        make install
    )
}

function add_rpath_flag() {
    local BIN_NAME="$1"

    local OUTPUT_EXE=$BASE_DIR/bin/$BIN_NAME

    # Check whether this is named something that we need to wrap
    if ! echo "$BIN_NAME" | grep -e c++ -e g++ -e gfortran -e cpp &> /dev/null; then
        # gcc-ar, gcc-ranlib, and gcc-nm should not be wrapped
        # gcc anywhere else should be
        if ! echo "$BIN_NAME" | grep -P 'gcc(?!(-ar|-nm|-ranlib))' &> /dev/null; then
            ln -sf ../.bin/$BIN_NAME $OUTPUT_EXE
            return
        fi
    fi

    read -d '' FILE_CONTENTS <<EOF || true
#!/bin/bash

# Get directory of script
SCRIPT=\$(readlink -f "\$0")
DIR=\$(dirname \$SCRIPT)


# Pass all arguments to the actual binary
\$DIR/../.bin/$BIN_NAME -Wl,-rpath=\$DIR/../lib -Wl,-rpath=\$DIR/../lib64 \${@:1}
EOF

    mkdir -p $(dirname $OUTPUT_EXE)
    echo "$FILE_CONTENTS" > $OUTPUT_EXE
    chmod 755 $OUTPUT_EXE
}

# Check whether the lib_dir is already in a search path
# If not, then make bash scripts to add "-Wl,-rpath=$LIB_DIR" to compiler flags.
function rpath_script_if_necessary() {
    if ! is_in_libpath $LIB_DIR; then
        for EXE in $(ls $CONFIG_BIN_DIR); do
            add_rpath_flag $EXE
        done
    fi
}

#########################################################
##################### ACTUAL WORK #######################
#########################################################

initialize
git_checkout
download_deps
configure_makefile
build_gcc
rpath_script_if_necessary
