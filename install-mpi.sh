#!/bin/sh
# This configuration file was taken orignally from https://trac.mpich.org/projects/armci-mpi which was taken originally from the mpi4py project
# <http://mpi4py.scipy.org/>, and then modified for Julia

set -e
set -x

TRAVIS_ROOT="$1"
 
if [ ! -d "$TRAVIS_ROOT/open-mpi" ]; then
   wget --no-check-certificate https://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.2.tar.bz2
   tar -xjf openmpi-1.10.2.tar.bz2
   cd openmpi-1.10.2
   mkdir build && cd build
   ../configure CFLAGS="-w" --prefix=$TRAVIS_ROOT/open-mpi \
               --without-verbs --without-fca --without-mxm --without-ucx \
               --without-portals4 --without-psm --without-psm2 \
               --without-libfabric --without-usnic \
               --without-udreg --without-ugni --without-xpmem \
               --without-alps \
               --without-sge --without-loadleveler --without-tm \
               --without-lsf --without-slurm \
               --without-pvfs2 \
               --without-cuda --disable-oshmem \
               --disable-mpi-fortran --disable-oshmem-fortran \
               --disable-libompitrace \
               --disable-mpi-io  --disable-io-romio \
               --disable-static
   make -j4
   make install
else
   echo "Open-MPI already installed"
fi

export PATH=$TRAVIS_ROOT/open-mpi/bin:$PATH