#/bin/sh

#-- Run MCMCglmm model simulation on cluster (multiple chains in parallel)
#-- Run as an array of jobs

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

cp ./MCMCglmm_jobarray.sh "./MCMCglmm_jobarray"$TIMESTAMP".sh"
cp ./parMCMC-R.sh "./parMCMC_"$TIMESTAMP"-R.sh"

qsub -F $TIMESTAMP "./MCMCglmm_jobarray"$TIMESTAMP".sh"


