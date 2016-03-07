#!/bin/sh
[ "$1" ] || exit 1
# exit on any error
set -e

GIT_REPO="$1"
GIT_HASH=$(cd $GIT_REPO && git log --pretty=format:'%h' -n 1)
GIT_BRANCH=$(cd $GIT_REPO && git rev-parse --abbrev-ref HEAD)
echo "$GIT_BRANCH"_"$GIT_HASH"
