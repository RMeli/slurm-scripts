#!/bin/bash
#SBATCH --partition=nvgpu
#SBATCH --nodes=2
#SBATCH --hint=multithread
#SBATCH --uenv-file=/scratch/e1000/rmeli/squashfs/dlaf-mkl-cuda.squashfs

export CUDA_VISIBLE_DEVICES=$SLURM_LOCALID
export MPICH_MAX_THREAD_SAFETY=multiple

export MIMALLOC_EAGER_COMMIT_DELAY=0
export MIMALLOC_LARGE_OS_PAGES=1

source $SCRATCH/spack/share/spack/setup-env.sh
export SPACK_SYSTEM_CONFIG_PATH=/user-environment/config

spack -e myenv build-env dla-future -- bash

hostname
nvidia-smi
mpichversion

# gpu2ranks
cat > gpu2ranks <<EOF
#!/bin/bash
# Restrict visible GPUs when using multiple ranks per node with slurm.

set -eu

export CUDA_VISIBLE_DEVICES=\$SLURM_LOCALID

eval "\$@"
EOF
chmod +x gpu2ranks

srun -u --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
    ./gpu2ranks ctest
