#!/bin/bash

VERSION=24.5
PREFIX=~/bin/emacs-${VERSION}

wget http://ftpmirror.gnu.org/emacs/emacs-${VERSION}.tar.gz
tar -xzf emacs-${VERSION}.tar.gz
rm -f emacs-${VERSION}.tar.gz
cd emacs-${VERSION}
./configure --prefix ${PREFIX} --with-x-toolkit=lucid
make -j10 && make install
