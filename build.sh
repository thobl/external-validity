#!/usr/bin/env bash

# building with cmake
build() {
  BUILD_DIR=$1
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
  cmake ..
  make
  cd -
}

# build our C++ code
build code/release/
