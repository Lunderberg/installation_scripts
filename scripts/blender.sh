#!/bin/bash

VERSION=2.70a

# apt-get install python3.4-dev libavformat-dev libswscale-dev libfftw3-dev libavdevice-dev libjpeg-turbo8-dev

cd /opt
wget http://mirror.cs.umn.edu/blender.org/source/blender-$VERSION.tar.gz
tar -xzf blender-$VERSION.tar.gz
rm -f blender-$VERSION.tar.gz
cd blender-$VERSION
scons BF_PYTHON_INC=/usr/include/python3.4m