#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
##

# TODO filter patches by target config.yaml
find "$TARGET/patches/setup" -name "*.patch" | \
while read patch; do
    patch -p1 -d "$TARGET/repo" < "$patch"
done

if [ -z "$1" ]; then
    echo "No patch name provided."
    exit 1
fi

# apply base patch
base_patch_file="$TARGET/patches/bugs/${1%%-*}.patch"
if [ ! -f "$base_patch_file" ]; then
    echo "Patch file $base_patch_file not found."
    exit 1
fi
patch -p1 -d "$TARGET/repo" < "$base_patch_file"
echo "Base patch file $base_patch_file applied."

# apply fuzzing patch
fuzzing_patch_file="$TARGET/patches/specs/${1}.patch"
if [ -f "$fuzzing_patch_file" ]; then
    patch -p1 -d "$TARGET/repo" < "$fuzzing_patch_file"
    echo "Fuzzing patch file $fuzzing_patch_file applied."
fi
