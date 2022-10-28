#!/bin/bash

INSTALL_DIR=$(pwd)/bin

git clone https://github.com/llvm/llvm-project
cd llvm-project
mkdir build
cd build

CMAKE_ARGS=(
    -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}"
    -DCMAKE_BUILD_TYPE=Release
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra"
    ../llvm
    )

cmake "${CMAKE_ARGS[@]}"
make install
