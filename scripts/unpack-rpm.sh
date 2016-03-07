#!/bin/bash
# unpack rpms fairly portable
#
# exit on any error
set -e

CPIO_OPTS="--extract --unconditional --preserve-modification-time --make-directories"
TEMPROOT="$1"
RELOCATE="$2"
TARGETDIR="$3"
shift 3
FILES=$@

if test -z "$1"; then
	echo "need temproot, relocate, target and RPM."
	exit 1
fi
ROOT=$(mktemp -d --tmpdir=${TEMPROOT} unpack-rpm.XXXXXX)
cd $ROOT
for f in $FILES; do
	printf "%60.60s: " "${f##*/}"
	rpm2cpio $f | cpio ${CPIO_OPTS}
done

if ! test -d $TARGETDIR; then
	install -d $TARGETDIR
fi

# force overwriting for "reinstall"
cp -a $ROOT/$RELOCATE/* $TARGETDIR/

# clean up after myself
rm -fr $ROOT
