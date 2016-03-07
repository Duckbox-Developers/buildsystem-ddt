#!/bin/bash
#
# find requirements of binaries in packages

OBJDUMP=${OBJDUMP:-objdump}
ROOT="$1"

# requires
DEPS=$(find $ROOT -type f -print0 | \
	xargs -0 $OBJDUMP -p | \
	awk '/^  NEEDED/{print $2}' | \
	sort -u)
# provides, in case a library is in there...
PROV=$(find $ROOT -type f -print0 | \
	xargs -0 $OBJDUMP -p | \
	awk '/^  SONAME/{print $2}' | \
	sort -u)

# filter out our self-provides;
for D in $PROV; do
	DEPS=${DEPS/$D}
done

# strip whitespace
DEPS=$(echo $DEPS)
# add commas
echo ${DEPS// /, }
