#! /bin/bash

set -e

FUZZERS_HOME=$PWD/fuzzers

if [ -z "$1" ]; then
    echo "No fuzzer specified."
    exit 1
fi


mkdir -p $FUZZERS_HOME


case "$1" in
    "titan")
        git clone https://github.com/5hadowblad3/Titan.git "$FUZZERS_HOME/titan"
        ;;
    *)
        echo "Unknown fuzzer: $1"
        exit 1
        ;;
esac