#!/bin/bash

# sudo apt install libxaw7-dev libjpeg-dev libpng-dev libgif-dev libtiff-dev gnutls-dev libncurses-dev libgif-dev

VERSION=27.1
#PREFIX=~/bin/emacs-${VERSION}
PREFIX=/opt/emacs-${VERSION}

wget http://ftpmirror.gnu.org/emacs/emacs-${VERSION}.tar.gz
tar -xzf emacs-${VERSION}.tar.gz
rm -f emacs-${VERSION}.tar.gz
cd emacs-${VERSION}
./configure --prefix ${PREFIX} --with-x-toolkit=lucid
make -j10
sudo make install
