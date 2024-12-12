#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
##

# TODO filter patches by target config.yaml
find "$TARGET/patches/setup" -name "*.patch" | \
while read patch; do
    echo "Applying $patch"
    name=${patch##*/}
    name=${name%.patch}
    sed "s/%MAGMA_BUG%/$name/g" "$patch" | patch -p1 -d "$TARGET/repo"
done

if [ -z "$1" ]; then
    echo "No patch name provided."
    exit 1
fi

patch_file="$TARGET/patches/direct/$1.patch"
if [ ! -f "$patch_file" ]; then
    echo "Patch file $patch_file not found."
    exit 1
fi

echo "Applying bug patch: $patch_file"
name=${1%.patch}
sed "s/%MAGMA_BUG%/$name/g" "$patch_file" | patch -p1 -d "$TARGET/repo"