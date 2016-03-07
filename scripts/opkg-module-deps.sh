#!/bin/bash
# (bash is necessary because POSIX does not mandate string replace func)
#
# helper script to put all module names into the opkg control file

TARGET_DIR="$1"
CONTROL="$2"

cd ${TARGET_DIR}/lib/modules
MODS=$(echo $(find . -name '*.ko' -type f |sort| sed 's#^.*/##'))
MODS=${MODS// /, }
sed -i "s#@MODULE_PROV@#${MODS}#" "$CONTROL"
