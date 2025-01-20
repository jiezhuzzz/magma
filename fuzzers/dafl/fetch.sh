#!/bin/bash
set -ex

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

git clone --no-checkout https://github.com/prosyslab/DAFL "$FUZZER/repo"
git -C "$FUZZER/repo" checkout a6fcc56c2d10c4cdef51f64927af8df3d309551b  # need to be checked
#wget -O "$FUZZER/repo/afl_driver.cpp" \
#    "https://cs.chromium.org/codesearch/f/chromium/src/third_party/libFuzzer/src/afl/afl_driver.cpp"
cp "$FUZZER/src/afl_driver.cpp" "$FUZZER/repo/afl_driver.cpp"

# sparrow
git clone --no-checkout https://github.com/prosyslab/sparrow "$FUZZER/sparrow"
git -C "$FUZZER/sparrow" checkout 0422e320d39f2001cb1dbd85edb6488e048fbb6d

# smake
git clone --no-checkout https://github.com/prosyslab/smake "$FUZZER/smake"
git -C "$FUZZER/smake" checkout 4820d08fc1e43555c2be842984d9a7043d42d07b
