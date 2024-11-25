#!/bin/bash -e

mkdir -p work

# Function to build docker images
build_images() {
    local suffix=$1
    echo -e "Build Docker Images"
    FUZZER=titan TARGET=libpng PATCH=PNG007$suffix ./build.sh
    FUZZER=titan TARGET=libtiff PATCH=TIF007$suffix ./build.sh
    FUZZER=titan TARGET=libsndfile PATCH=SND017$suffix ./build.sh
}

# Function to run campaigns
run_campaigns() {
    local suffix=$1
    local targets=("libpng:libpng_read_fuzzer:PNG007" "libtiff:tiff_read_rgba_fuzzer:TIF007" "libsndfile:sndfile_fuzzer:SND017")
    
    for target in "${targets[@]}"; do
        IFS=':' read -r lib program patch <<< "$target"
        for i in {1..5}; do
            folder="work/titan-$lib-$patch$suffix-$i"
            mkdir -p "$folder"
            echo -e "Run Campaign $i in $folder"
            nohup env FUZZER=titan \
                     TARGET=$lib \
                     PROGRAM=$program \
                     SHARED=./$folder \
                     PATCH=$patch$suffix \
                     POLL=5 \
                     TIMEOUT=16h \
                     ./start.sh "$folder/campaign.log" 2>&1 &
            pid=$!
            echo $pid > "$folder/campaign.pid"
        done
    done
}

# Run original campaigns
build_images ""
run_campaigns ""

# Modify instrument.sh for functional campaigns
sed -i 's/MAGMA_LOG/"volatile int dummy"/g' ../../fuzzers/titan/instrument.sh

# Run functional campaigns
build_images "-func"
run_campaigns "-func"

# Run specification campaigns
build_images "-spec"
run_campaigns "-spec"
