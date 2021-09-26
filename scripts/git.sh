#!/bin/bash

VERSION=2.4.5
PREFIX=${HOME}/bin/git-${VERSION}

wget https://github.com/git/git/archive/v${VERSION}.tar.gz
tar -xzf v${VERSION}.tar.gz
rm -f v${VERSION}.tar.gz
cd git-${VERSION}
make configure
./configure --prefix=${PREFIX}
make -j10 && make install
