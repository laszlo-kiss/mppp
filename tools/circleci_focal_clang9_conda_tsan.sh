#!/usr/bin/env bash

# Echo each command
set -x

# Exit on error.
set -e

# Core deps.
sudo apt-get install build-essential wget clang

# Install conda+deps.
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
export deps_dir=$HOME/local
export PATH="$HOME/miniconda/bin:$PATH"
bash miniconda.sh -b -p $HOME/miniconda
conda config --add channels conda-forge
conda config --set channel_priority strict
conda_pkgs="cmake gmp mpfr libflint arb mpc"
conda create -q -p $deps_dir -y
source activate $deps_dir
conda install $conda_pkgs -y

# Create the build dir and cd into it.
mkdir build
cd build

# clang build.
CC=clang CXX=clang++ cmake ../ -DCMAKE_PREFIX_PATH=$deps_dir -DCMAKE_BUILD_TYPE=Debug -DMPPP_BUILD_TESTS=YES -DMPPP_WITH_MPFR=yes -DMPPP_WITH_MPC=yes -DMPPP_WITH_ARB=yes -DMPPP_WITH_QUADMATH=yes -DCMAKE_CXX_FLAGS="-fsanitize=thread" -DMPPP_QUADMATH_INCLUDE_DIR=/usr/lib/gcc/x86_64-linux-gnu/9/include/ -DMPPP_QUADMATH_LIBRARY=/usr/lib/gcc/x86_64-linux-gnu/9/libquadmath.so -DMPPP_ENABLE_IPO=yes
make VERBOSE=1
# Run the tests.
ctest -V -j2

set +e
set +x
