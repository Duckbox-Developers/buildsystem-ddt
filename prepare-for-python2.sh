#!/bin/bash

if [ "$(id -u)" = "0" ]; then
	echo "You are running as root. Do not do this."
	exit 1
fi

# make sure defines have not already been defined
UBUNTU=
FEDORA=
SUSE=
GENTOO=

# Try to detect the distribution
if `which lsb_release > /dev/null 2>&1`; then
	case `lsb_release -s -i` in
		Debian*) UBUNTU=1; INSTALL="apt-get -y install";;
		Fedora*) FEDORA=1; INSTALL="yum install -y";;
		CentOS*) FEDORA=1; INSTALL="yum install -y";;
		SUSE*)   SUSE=1;   INSTALL="zypper install -y";;
		Ubuntu*) UBUNTU=1; INSTALL="apt-get -y install";;
		LinuxM*) UBUNTU=2; INSTALL="apt-get -y install";;
		Gentoo)  GENTOO=1; INSTALL="emerge -uN";;
	esac
fi

# Not detected by lsb_release, try release files
if [ -z "$FEDORA$GENTOO$SUSE$UBUNTU" ]; then
	if   [ -f /etc/redhat-release ]; then FEDORA=1; INSTALL="yum install -y";
	elif [ -f /etc/fedora-release ]; then FEDORA=1; INSTALL="yum install -y";
	elif [ -f /etc/centos-release ]; then FEDORA=1; INSTALL="yum install -y";
	elif [ -f /etc/SuSE-release ];   then SUSE=1;   INSTALL="zypper install -n";
	elif [ -f /etc/debian_version ]; then UBUNTU=1; INSTALL="apt-get -y install";
	elif [ -f /etc/gentoo-release ]; then GENTOO=1; INSTALL="emerge -uN"
	fi
fi

# still not detected, display error and let the user manually install
if [ -z "$FEDORA$GENTOO$SUSE$UBUNTU" ]; then
	echo
	echo "Cannot determine which OS distribution you use,"
	echo "or your distribution is not (yet) supported."
	echo "Please report this fact in the proper forum(s)"
	echo
	echo "Try installing the following packages: "
	# determine probable distribution, based on package system,
	# Suse should be last because the others may also have rpm installed.
	{ `which apt-get > /dev/null 2>&1` && UBUNTU=1; } || \
	{ `which yum     > /dev/null 2>&1` && FEDORA=1; } || \
	{ `which dnf     > /dev/null 2>&1` && FEDORA=1; } || \
	{ `which emerge  > /dev/null 2>&1` && GENTOO=1; } || \
	SUSE=2
	INSTALL="echo "
fi

PACKAGES="\
	libncursesw5-dev \
	libssl-dev \
	libsqlite3-dev \
	tk-dev \
	libgdbm-dev \
	libc6-dev \
	libbz2-dev \
";

ARCHIVE=$HOME/Archive
mkdir -p $ARCHIVE

if [ ! -e $ARCHIVE/Python-2.7.18.tar.xz ]; then
	wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz -O $ARCHIVE/Python-2.7.18.tar.xz
fi

echo "Build of Python 2.7.18..."

sudo $INSTALL $PACKAGES

[ -e $HOME/Python-2.7.18 ] && rm -rf $HOME/Python-2.7.18
cd $HOME
tar xJf $ARCHIVE/Python-2.7.18.tar.xz
cd $HOME/Python-2.7.18
./configure --enable-optimizations
make && sudo make install && cd $HOME && rm -rf $HOME/Python-2.7.18 && echo "Build and Install of Python 2.7.18 - Done."
