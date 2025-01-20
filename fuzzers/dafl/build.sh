#!/bin/bash
set -ex

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
##

# Build Sparrow since CC changes in building DAFL
cd $FUZZER/sparrow
git checkout dafl
export OPAMYES=1

sed -i '/^opam init/ s/$/ --disable-sandboxing/' build.sh
sed -i 's/opam install apron clangml/opam install conf-libclang.12 apron clangml/' build.sh

# No CIL for our project
sed -i 's|opam pin add cil https://github.com/prosyslab/cil.git -n|opam pin add cil https://github.com/prosyslab/cil.git#8e87fe45 -n|' build.sh
./build.sh
opam install ppx_compare yojson ocamlgraph memtrace lymp clangml conf-libclang.12 batteries apron conf-mpfr cil linenoise claml

eval $(opam env)
make clean
make


# Build fuzzer
if [ ! -d "$FUZZER/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

cd "$FUZZER/repo"
CC=clang make -j $(nproc)
CC=clang make -j $(nproc) -C llvm_mode

# compile afl_driver.cpp
"./afl-clang-fast++" $CXXFLAGS -std=c++11 -c "afl_driver.cpp" -fPIC -o "$OUT/afl_driver.o"
