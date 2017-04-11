#!/bin/bash

set -e -o pipefail -u

#########################################################
################ CONFIGURATION SECTION ##################
#########################################################

SRC_DIR=/scratch/Programs/python-build
INST_DIR=/scratch/Programs/python

# The version to be installed.
# Should be of form X.Y.Z
VERSION=3.6.0

# Number of threads to be used when compiling
THREADS=10

#########################################################
################ FUNCTION_DEFINITIONS ###################
#########################################################

function initialize() {
    mkdir -p "$SRC_DIR"
}

function download_tarball() {
    cd "$SRC_DIR"
    if [ ! -d Python-$VERSION ]; then
        local url=https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
        wget $url
        tar -xzf Python-$VERSION.tgz
    fi
    cd Python-$VERSION
}

function configure() {
    ./configure --enable-optimizations --prefix=/scratch/Programs/python
}

function compile() {
    make -j$THREADS
}

function install() {
    make install
}

initialize
download_tarball
configure
compile
install
