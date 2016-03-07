#!/bin/sh
CONTROL_FILE=$1
shift
SVNREF=0
while test -n "$1"; do
	R=$(LC_ALL=C svn info "$1" | awk -F: '/^Last Changed Rev:/{print $2}')
	test $SVNREF -lt $R && SVNREF=$R
	shift
done
SVNREF=$(echo $SVNREF) # strip whitespace
sed -i "s/@VER@/${SVNREF}/" $CONTROL_FILE
