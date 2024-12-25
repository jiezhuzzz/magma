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

# copy generated function level fuzzing targets list
fuzzing_targets_file="$TARGET/patches/fuzzing_targets/$1.txt"
if [ -f "$fuzzing_targets_file" ]; then
    cp "$fuzzing_targets_file" "$TARGET/repo/fuzzing_targets.txt"
fi

base_patch_file="$TARGET/patches/bugs/${1%%-*}.patch"
if [ ! -f "$base_patch_file" ]; then
    echo "Patch file $base_patch_file not found."
    exit 1
fi
patch -p1 -d "$TARGET/repo" < "$base_patch_file"
echo "Base patch file $base_patch_file applied."
