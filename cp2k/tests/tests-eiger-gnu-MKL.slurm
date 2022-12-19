#!/bin/bash -l
#SBATCH --job-name="cp2k-tests-eiger-gnu-MKL"
#SBATCH --account="csstaff"
#SBATCH --time=02:00:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=3
#SBATCH --cpus-per-task=4
#SBATCH --partition=normal
#SBATCH --constraint=mc

date
hostname

# Generated with https://user.cscs.ch/access/running/jobscript_generator/

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export CRAY_CUDA_MPS=1

module load cray
module load PrgEnv-gnu
module load cray-fftw3
source /opt/intel/mkl/bin/mklvars.sh intel64 lp64 # MKL

# https://user.cscs.ch/computing/applications/cp2k/
ulimit -s unlimited

# https://www.cp2k.org/dev:regtesting

export MPICH_OFI_STARTUP_CONNECT=1
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}
export OMP_PROC_BIND=close
export OMP_PLACES=cores

CP2K_BASE_DIR="${HOME}/git/cp2k/"
CP2K_TEST_DIR="${SCRATCH}/cp2k-regtests/"

CP2K_ARCH="local"
CP2K_VERSION="psmp"

NTASKS_SINGLE_TEST=2
NNODES_SINGLE_TEST=1 # Change to >1 to run tests on multiple nodes

SRUN_CMD="srun --cpu-bind=verbose,cores --ntasks-per-node 2"

mkdir -p "${CP2K_TEST_DIR}"
cd "${CP2K_TEST_DIR}"

CP2K_REL_DIR=$(realpath --relative-to="${CP2K_TEST_DIR}" "${CP2K_BASE_DIR}")

# Make sure CP2K knows where test data is
# This is fundamental if using the new CMake installation
export CP2K_DATA_DIR="${CP2K_REL_DIR}/data/"

export cp2k_run_prefix="${SRUN_CMD} -N ${NNODES_SINGLE_TEST} -n ${NTASKS_SINGLE_TEST}"

"${CP2K_REGEST_SCRIPT_DIR:-${CP2K_BASE_DIR}/tools/regtesting}/do_regtest" \
  -arch "${CP2K_ARCH}" \
  -version "${CP2K_VERSION}" \
  -nobuild \
  -mpiranks ${NTASKS_SINGLE_TEST} \
  -ompthreads ${OMP_NUM_THREADS} \
  -maxtasks ${SLURM_NTASKS} \
  -cp2kdir "${CP2K_REL_DIR}" \
 |& tee "${CP2K_TEST_DIR}/${CP2K_ARCH}.${CP2K_VERSION}.log"



