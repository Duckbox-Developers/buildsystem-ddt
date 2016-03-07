#!/bin/bash
#
# adopted from openWRT's ipkg-make-index.sh
set -e

pkg_dir=$1

if [ -z $pkg_dir ] || [ ! -d $pkg_dir ]; then
	echo "Usage: opkg-make-index <package_directory>"
	exit 1
fi

which md5sum 2>&1 >/dev/null || alias md5sum=md5

for pkg in `find $pkg_dir -type d -name '.?*' -prune -o -name '*.opk' -print | sort`; do
	echo "Generating index for package $pkg" >&2
	file_size=$(stat -c %s $pkg)
	md5sum=$(md5sum < $pkg)
	# Take pains to make variable value sed-safe
	sed_safe_pkg=${pkg#./}			# remove leading ./ if present
	sed_safe_pkg=${sed_safe_pkg//\//\\\/}	# replace / with \/
	ar p $pkg control.tar.gz|tar --wildcards -xzOf- './control' | \
		sed -e "s/^Description:/Filename: $sed_safe_pkg\\
Size: $file_size\\
MD5Sum: ${md5sum%% *}\\
Description:/"
	echo ""
done
