#!/bin/bash

VERSION=6.8.9-3

cd /opt
wget http://www.imagemagick.org/download/ImageMagick-$VERSION.tar.gz
tar -xzf ImageMagick-$VERSION.tar.gz
rm ImageMagick-$VERSION.tar.gz
cd ImageMagick-$VERSION
./configure
make
make check && make install

