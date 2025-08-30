#!/bin/bash

if [ "$(id -u)" = "0" ]; then
	echo "You are running as root. Do not do this."
	exit 1
fi

ARCHIVE=$HOME/Archive
mkdir -p $ARCHIVE

if [ ! -e $ARCHIVE/Python-2.7.18.tar.xz ]; then
	wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz -O $ARCHIVE/Python-2.7.18.tar.xz
fi

echo "Build of Python 2.7.18..."

sudo apt-get -y install libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

[ -e $HOME/Python-2.7.18 ] && rm -rf $HOME/Python-2.7.18
cd $HOME
tar xJf $ARCHIVE/Python-2.7.18.tar.xz
cd $HOME/Python-2.7.18
./configure --enable-optimizations
make && sudo make install && cd $HOME && rm -rf $HOME/Python-2.7.18 && echo "Build and Install of Python 2.7.18 - Done."
