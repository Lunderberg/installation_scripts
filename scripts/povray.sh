#!/bin/bash

# sudo apt install autoconf automake libboost-dev libboost-date-time-dev libboost-thread-dev zlib1g-dev libpng12-dev libjpeg8-dev libtiff5-dev libopenexr-dev

set -euo pipefail

compile_dir=/opt/povray

function make_and_cd() {
    mkdir -p "$compile_dir"
    cd "$compile_dir"
}

function download_source() {
    if [ ! -f 3.7-stable.zip ]; then
        wget https://github.com/POV-Ray/povray/archive/3.7-stable.zip
    fi

    if [ ! -d povray-3.7-stable ]; then
        unzip 3.7-stable.zip
    fi
    cd povray-3.7-stable
}

function configure_povray() {
    cd unix
    ./prebuild.sh
    cd ..
    ./configure COMPILED_BY="Eric Lunderberg"
}

make_and_cd
download_source
configure_povray
time make -j3
#sudo make install
