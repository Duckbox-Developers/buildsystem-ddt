#!/bin/bash
#
# first argument: control file to edit
CONTROL_FILE=$1
shift
# second argument: top level git dir (or only dir)
cd "$1"
shift
# optional third, fourth, ... arguments: subdirs
if test -z "$1"; then
	A="."
else
	A="$1"
fi
shift
LASTCOMMIT=$(git log --no-abbrev --pretty=format:'%h' -n 1 $A $@)
GITREV=$(git describe $LASTCOMMIT)
GITREV=$(echo $GITREV) # strip whitespace
GITREV=${GITREV%-g*}   # strip -gabcdef
sed -i "s/@VER@/${KVER:-}${KVER:+-}${GITREV}/" $CONTROL_FILE
