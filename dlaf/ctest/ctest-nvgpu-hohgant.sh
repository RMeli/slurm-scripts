#!/bin/bash
#SBATCH --partition=nvgpu
#SBATCH --nodes=2
#SBATCH --hint=multithread
#SBATCH --uenv-file=/scratch/e1000/rmeli/squashfs/dlaf-mkl-cuda.squashfs

# Before SBATCHing this script:
#   squashfs-run /scratch/e1000/rmeli/squashfs/dlaf-mkl-cuda.squashfs bash
#   export SPACK_SYSTEM_CONFIG_PATH=/user-environment/config
#   spack -e /scratch/e1000/rmeli/git/my-spack/envs/dlaf-mkl-cuda build-env -- bash

export MPICH_MAX_THREAD_SAFETY=multiple
export MIMALLOC_EAGER_COMMIT_DELAY=0
export MIMALLOC_LARGE_OS_PAGES=1

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

# DLA-Future needs to be compiled with -DDLAF_CI_RUNNER_USES_MPIRUN=on
srun -u -n 1 --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
    ./gpu2ranks ctest -L RANK_1
srun -u -n 2 --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
    ./gpu2ranks ctest -L RANK_2
srun -u -n 4 --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
    ./gpu2ranks ctest -L RANK_4
#srun -u -n 6 --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
#    ./gpu2ranks ctest -L RANK_6
srun -u -n 6 --cpu-bind=mask_cpu:ffff000000000000ffff000000000000,ffff000000000000ffff00000000,ffff000000000000ffff0000,ffff000000000000ffff \
    ./gpu2ranks ctest -V -L RANK_6
