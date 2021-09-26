#!/bin/bash

#sudo apt-get install yasm libfaac-dev libx264-dev

cd /opt
if [ ! -d ffmpeg-2.4.2 ]; then
		wget http://ffmpeg.org/releases/ffmpeg-2.4.2.tar.bz2
		tar -xjf ffmpeg-2.4.2.tar.bz2
		rm -f ffmpeg-2.4.2.tar.bz2
fi
cd ffmpeg-2.4.2
./configure --enable-libfreetype --enable-nonfree --enable-libfaac --enable-gpl --enable-libx264
make -j3 && make install