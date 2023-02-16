#!/bin/bash
#SBATCH --partition=nvgpu
#SBATCH --uenv-file=/scratch/e1000/rmeli/squashfs/cp2k-dlaf-cuda.squashfs

# Spack stack: https://github.com/RMeli/spack-stack-alps

miniapp=miniapp/miniapp_eigensolver

module use /user-environment/modules
module --ignore-cache load intel-mkl

nvidia-smi

ldd ${miniapp}
#./libtree_x86_64 ${miniapp} # https://github.com/haampie/libtree

${miniapp}
