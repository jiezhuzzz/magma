#!/bin/bash

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
##

mkdir -p "$SHARED/findings"

export AFLGO=$FUZZER/repo

mkdir obj-aflgo; mkdir obj-aflgo/temp
export SUBJECT=$PWD; export TMP_DIR=$PWD/obj-aflgo/temp
export CC=$AFLGO/afl-clang-fast; export CXX=$AFLGO/afl-clang-fast++
export LDFLAGS=-lpthread




export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
"$FUZZER/repo/afl-fuzz" -m 100M -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
    $FUZZARGS -- "$OUT/$PROGRAM" $ARGS 2>&1
