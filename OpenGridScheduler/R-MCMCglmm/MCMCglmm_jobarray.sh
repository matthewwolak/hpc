#!/bin/bash -l
# Run MCMCglmm model simulation on cluster (multiple chains in parallel)
# Run as an array

###################
# SET THESE OPTIONS
#AS DESIRED
###################

#Export current environment variables
#$ -V

# Merge stdout and stderr
#$ -j y

# Set working directory as current working directory
#$ -cwd

# Job status e-mail recipient
##$ -M foo@bar
# What e-mails to send
##$ -m eas

####################################
#SGE DIRECTIVES - Always set these #
####################################
# Expected runtime=hours:mins:seconds, eg 24:00:00
#$ -l h_rt=48:00:00

# Expected hard memory limit (per slot)
#$ -l h_vmem=4G

#How many tasks to schedule at once? Please note that the total may be limited on your cluster. 
#$ -tc 100


###################
# MY SCRIPTS
###################

echo "Starting on : $(date)"
echo "Running on node : $(hostname)"
echo "Current directory : $(pwd)"
echo "Current job ID : $JOB_ID"


./parMaxMCMC-R.sh $SGE_TASK_ID $SGE_TASK_LAST


echo "Finishing on : $(date)"
