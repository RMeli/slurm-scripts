#!/bin/bash
#SBATCH --partition=normal
#SBATCH --nodes 2
#SBATCH --uenv-file=/scratch/e1000/rmeli/squashfs/cp2k-dlaf-cuda.squashfs

module use /user-environment/modules
module --ignore-cache load blaspp camp cosma cray-mpich-gcc cuda dbcsr doxygen \
    fftw fmt gcc git googletest intel-mkl lapackpp libint libxc libxsmm \
    mimalloc pika-algorithms pika pkgconf python spglib umpire whip

hostname
mpichversion
nvidia-smi

ctest
ctest --rerun-failed --verbose
