#/bin/sh

#-- Run MCMCglmm model simulation on cluster (multiple chains in parallel)
#-- Run as an array of jobs

#--------------------
#-- SET THESE OPTIONS
#-- AS DESIRED
#--------------------

#-- Export current environment variables
#PBS -V

#-- join both output and error files
#PBS -j oe

#-- Set working directory as current working directory
#PBS -d .

#-- To whom should e-mails be sent regarding job status
#-- NOTE - WARNING for an array this could be for every job in the array
#-- So if running an array of size 100, then you could get 100 e-mails for each
#--PBS -M foo@bar

#-- Indicate if\when you want to receive email about your job
#-- The directive below sends email if the job is (a) aborted, 
#-- when it (b) begins, and when it (e) ends
#-- PBS -m eas

#-- Give the job a name (default is name of script file)
#PBS -N MCMCarray



#-----------------------
#-- SET BELOW OPTIONS
#-- FOR EACH SUBMISSION
#-----------------------

#-- Expected runtime/walltime=hours:mins:seconds, eg 24:00:00
#PBS -l walltime=1:00:00

#-- How many tasks to schedule at once?
#-- Set a variable that is passed to the jobs
#PBS -v ARRAY_TOT=10

#-- Array integer IDs
#PBS -t 1-10

#-- Number of nodes and cores you want to use
#-- Hopper's standard compute nodes have a total of 20 (or 24) cores each (max ppn=20)
#PBS -l nodes=10:ppn=1

#-- Expected memory limit (per processor)
#PBS -l mem=2gb



#----------------
# MY SCRIPTS
#----------------

echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $PBS_JOBID"
echo "Array ID : $PBS_ARRAYID"
echo "Total array size : $ARRAY_TOT"


./parMCMC-R.sh $PBS_ARRAYID $ARRAY_TOT >> $(pwd)/ao.$PBS_ARRAYID


echo "Finishing on : $(date)"
