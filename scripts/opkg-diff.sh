#!/bin/bash
#
# opkg-diff.sh: script to show the differences between two packages
#
#	Copyright (C) 2011 Stefan Seyfried
#	Released under the GNU General Public License (GPL) Version 2
#	or, at your option, any later version
#
ME=${0##*/}

if [ $1 = '-k' ]; then
	KEEP=true
	shift
else
	KEEP=false
fi

OLD=$1
NEW=$2

if test -z "$NEW"; then
	NEW=$OLD
	OLD=${OLD/\/opkg//opkg/.old}
	CNT=${OLD%.opk}
	CNT=${CNT##*-}
	CNT=$((CNT-1))
	OLD=${OLD%-*}
	OLD=${OLD}-${CNT}.opk
	if test -e $OLD; then
		ls $OLD $NEW
	else
		echo "old package for $NEW doesn't seem to exist."; echo
		NEW=
	fi
fi

if test -z "$NEW"; then
	echo "usage: $ME oldpackage.opk newpackage.opk"
	echo
	exit 1
fi

# make absolute paths...
case $OLD in
	/*) ;;
	*)  OLD=$PWD/$OLD ;;
esac
case $NEW in
	/*) ;;
	*)  NEW=$PWD/$NEW ;;
esac

equal=true
if $KEEP; then
	TMPD=opkg-diff
	rm -fr $TMPD
	mkdir $TMPD
else
	TMPD=$(mktemp -d ${ME}.XXXXXX)
	trap 'rm -rf $TMPD' EXIT
fi
pushd $TMPD > /dev/null
mkdir {old,new}{root,CONTROL}
ar p $OLD control.tar.gz | tar -xzpf - -C oldCONTROL
ar p $OLD data.tar.gz    | tar -xzpf - -C oldroot
ar p $NEW control.tar.gz | tar -xzpf - -C newCONTROL
ar p $NEW data.tar.gz    | tar -xzpf - -C newroot
#
# check for symlink differences, diff does not like dangling symlinks
NEWLINKS=$(cd newroot && find . -type l | sort > .links)
OLDLINKS=$(cd oldroot && find . -type l | sort > .links)
if test "$NEWLINKS" != "$OLDLINKS"; then # the trivial case... list of links differs
	echo "package content differs: links..." >&2
	diff -u {old,new}root/.links
	equal=false
fi
rm {old,new}root/.links
first=true
for link in $NEWLINKS; do # less trivial check if link targets differ
	test $(readlink oldroot/$link) = $(readlink newroot/$link) && continue || true
	if $first; then
		echo "package content differs: link targets..." >&2
		first=false;
		equal=false
		fi
	echo "link: $link -> old: $(readlink oldroot/$link) new: $(readlink newroot/$link)"
done
oldver=$(awk '/^Version:/ {print $2}' oldCONTROL/control)
newver=$(awk '/^Version:/ {print $2}' newCONTROL/control)
oldver=${oldver%-*} # strip build rev
newver=${newver%-*}
sed -i '/^Version:/d' {old,new}CONTROL/control # do not diff versions
# remove symlinks, already checked above.
find {old,new}root -type l | xargs --no-run-if-empty rm
if ! diff -r {old,new}root > /dev/null; then
	echo "package content differs..." >&2
	diff -ru {old,new}root
	equal=false
fi
if test "$oldver" != "$newver"; then
	echo "package version differs: $oldver -> $newver" >&2
	equal=false
fi
if ! diff -r {old,new}CONTROL > /dev/null; then
	echo "package metadata differs..." >&2
	diff -ru {old,new}CONTROL
	equal=false
fi
if $equal; then
	echo "package content and metadata is identical" >&2
fi

popd > /dev/null
# $TMPD is removed by exit hook

