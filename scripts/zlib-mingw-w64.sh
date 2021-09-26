#!/bin/bash

# wget http://ppa.launchpad.net/mingw-packages/ppa/ubuntu/pool/main/z/zlib-mingw-w64-cross/zlib-mingw-w64-cross_1.2.3.4.dfsg-0ubuntu2_all.deb
# dpkg -i zlib-mingw-w64-cross_1.2.3.4.dfsg-0ubuntu2_all.deb


echo "Section: misc
Priority: optional
Standards-Version: 3.9.2

Package: mingw-zlib-compatability-fix
Depends: mingw-w64-i686-dev,mingw-w64-x86-64-dev
Provides: mingw-w64-dev
Description: Fix for zlib
 The zlib package for mingw-w64 requires mingw-w64-dev, which is not available.
 It works perfectly fine with mingw-w64-i686-dev and mingw-w64-x86-64-dev installed.
 This cheaps, and lets it work." > zlib-fix

# equivs-build zlib-fix
# dpkg -i mingw-zlib-compatability-fix_1.0_all.deb