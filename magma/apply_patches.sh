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

base_patch_file="$TARGET/patches/bugs/${1%%-*}.patch"
if [ ! -f "$base_patch_file" ]; then
    echo "Patch file $base_patch_file not found."
    exit 1
fi
patch -p1 -d "$TARGET/repo" < "$base_patch_file"

spec_patch_file="$TARGET/patches/specs/${1}.patch"
if [ ! -f "$spec_patch_file" ]; then
    echo -e "\e[31mPatch file $spec_patch_file not found. Only applying base patch.\e[0m"
fi
patch -p1 -d "$TARGET/repo" < "$spec_patch_file"
