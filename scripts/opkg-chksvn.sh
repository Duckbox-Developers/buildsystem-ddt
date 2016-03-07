#!/bin/sh
[ "$1" -a "$2" ] || exit 1
# exit on any error
set -e
export LC_ALL=C
CONTROL="$1"
TO_CHECK="$2"
SVNREV=$(svn info "$2" | grep "^Last Changed Rev:")
CTLREV=$(grep ^Version: $CONTROL/control)
SVNREV=${SVNREV#*:}
CTLREV=${CTLREV#*:}
CTLREV=${CTLREV%-*}
# strip whitespace...
SVNREV=$(echo $SVNREV)
CTLREV=$(echo $CTLREV)
[ $SVNREV = $CTLREV ] && exit 0
echo "SVN Revision '$SVNREV' does not match control file revision '$CTLREV'"
exit 1
