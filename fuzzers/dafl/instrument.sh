#!/bin/bash
set -ex

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##

# Copied from dafl run-smake

mkdir -p /benchmark/smake-out
export CC="clang"
export CXX="clang++"
export CMAKE_EXPORT_COMPILE_COMMANDS=1

program=$(basename "$TARGET")
binary=$PATCH

"$MAGMA/build.sh"

### Program: libtiff

#tiffcp
if [ $program == "libtiff" ]; then
    if [ $binary == "tiffcp" ]; then
        tmp="/benchmark/$program"
        mkdir $tmp
        cp -r "$TARGET/repo" $tmp
        cd "$tmp/repo"
        yes | "$FUZZER/smake/smake" --init
        ./autogen.sh
        ./configure --disable-shared --prefix="$WORK"
        make -j$(nproc) clean
        "$FUZZER/smake/smake" -j $(nproc)
        cp -r sparrow/tools/$binary /benchmark/smake-out/$program-$binary || exit 1
        python3 "$FUZZER/scripts/"
    fi
fi

# With afl_driver

# export LIBS="$LIBS -l:afl_driver.o -lstdc++"

### Program: libpng
program="libpng"
binaries="libpng_read_fuzzer"
cd "$TARGET/repo"
autoreconf -f -i
./configure --with-libpng-prefix=MAGMA_ --disable-shared
yes | "$FUZZER/smake/smake" --init
make -j$(nproc) clean
make -j $(nproc) libpng16.la

sed -i '$a libpng_read_fuzzer: contrib/oss-fuzz/libpng_read_fuzzer.cc\n\t$(CXX) $(CXXFLAGS) -std=c++11 -I. \\\n\t\tcontrib/oss-fuzz/libpng_read_fuzzer.cc \\\n\t\t-o $(OUT)/libpng_read_fuzzer \\\n\t\t$(LDFLAGS) .libs/libpng16.a $(LIBS) -lz' Makefile
"$FUZZER/smake/smake" -j $(nproc) libpng_read_fuzzer

export CMAKE_EXPORT_COMPILE_COMMANDS=0

"$TARGET/build.sh"

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.
