#!/bin/bash

WINOPTS="toolset=gcc target-os=windows variant=release threading=multi threadapi=win32 --user-config=user-config.jam -sNO_BZIP2=1 --layout=tagged"
WITHOUTS="--without-mpi --without-python"

cd /opt
if [ ! -f boost_1_56_0.tar.gz ]; then
		wget http://downloads.sourceforge.net/project/boost/boost/1.56.0/boost_1_56_0.tar.gz
fi

# Compile native version, install to /usr/local
cd /opt
tar -xzf boost_1_56_0.tar.gz
cd boost_1_56_0
./bootstrap.sh
./b2 install
cd /opt
rm -rf boost_1_56_0

# Compile win32 version, install to /usr/local/boost-w32
cd /opt
tar -xzf boost_1_56_0.tar.gz
cd boost_1_56_0
echo "using gcc : : i686-w64-mingw32-g++
  :
	<rc>i686-w64-mingw32-windres
	<archiver>i686-w64-mingw32-ar
	<ranlib>i686-w64-mingw32-ranlib
;" > user-config.jam
./bootstrap.sh

./b2 $WINOPTS $WITHOUTS link=shared runtime-link=shared --prefix=/usr/local/boost-w32 install
./b2 $WINOPTS $WITHOUTS link=static runtime-link=static --prefix=/usr/local/boost-w32 install
cd /opt
rm -rf boost_1_56_0

#Compile win64 version, install to /usr/local/boost-w64
cd /opt
tar -xzf boost_1_56_0.tar.gz
cd boost_1_56_0
echo "using gcc : : x86_64-w64-mingw32-g++
  :
	<rc>x86_64-w64-mingw32-windres
	<archiver>x86_64-w64-mingw32-ar
	<ranlib>x86_64-w64-mingw32-ranlib
;" > user-config.jam
./bootstrap.sh

./b2 $WINOPTS $WITHOUTS link=shared runtime-link=shared --prefix=/usr/local/boost-w64 install
./b2 $WINOPTS $WITHOUTS link=static runtime-link=static --prefix=/usr/local/boost-w64 install
cd /opt
rm -rf boost_1_56_0

cd /opt
#rm -f boost_1_56_0.tar.gz
