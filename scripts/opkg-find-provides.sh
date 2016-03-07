#!/bin/bash
#
# find provides of libraries in packages

OBJDUMP=${OBJDUMP:-objdump}
ROOT="$1"

# provides, in case a library is in there...
PROV=$(find $ROOT -type f -print0 | \
	xargs -0 $OBJDUMP -p | \
	awk '/^  SONAME/{print $2}' | \
	sort -u)

# strip whitespace
PROV=$(echo $PROV)
# add commas
echo ${PROV// /, }
