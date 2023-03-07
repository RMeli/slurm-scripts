#!/bin/bash -l
#SBATCH --job-name=cp2k-h2o-32
#SBATCH --time=00:30:00
#SBATCH --nodes=2
#SBATCH --partition=normal # Use CPU partition instead

cp2k_root_dir=${SCRATCH}/git/cp2k
cp2k_build_dir=${cp2k_root_dir}/build-dlaf-cpu

# ---

cp2k_exe=${cp2k_build_dir}/bin/cp2k

export CP2K_DATA_DIR=${cp2k_root_dir}/data

export MPICH_MAX_THREAD_SAFETY=multiple
export MIMALLOC_EAGER_COMMIT_DELAY=0
export MIMALLOC_LARGE_OS_PAGES=1

ulimit -s unlimited

hostname
nvidia-smi
mpichversion

#export OMP_DISPLAY_ENV=VERBOSE
#printenv | grep OMP
#printenv | grep SLURM

srun -u -n 2 -c 9 \
    --cpu-bind=mask_cpu:ff00000000000000ff000000000000,ff00000000000000ff00000000000000,ff00000000000000ff0000,ff00000000000000ff000000,ff00000000000000ff,ff00000000000000ff00,ff00000000000000ff00000000,ff00000000000000ff0000000000 \
    ${cp2k_exe} -i H2O-32.inp
