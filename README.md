# hpc - High Performance Computing

This repository contains templates and example code used for cluster computing and other high performance computing applications. The code is nested in two levels reflecting two different HPC clusters and particularly their scheduler and management software configurations. The software and clusters are:

  - The `Open Grid Scheduler` on [Maxwell](https://www.abdn.ac.uk/staffnet/working-here/hpc.php) at the University of Aberdeen, Scotland, UK

  - The `Torque/Moab` resource manager/scheduler (Torque is an open source fork of [OpenPBS](http://www.mcs.anl.gov/research/projects/openpbs/)) on [Hopper](https://hpcportal.auburn.edu/hpc/index.php) at Auburn University, AL, USA

## R Statistical Software on the HPC
Much of the code focuses on parallel computing in conjunction with the [R](https://cran.r-project.org/) statistical program.

### R-MCMCglmm
Bayesian generalized linear mixed models using Markov chain Monte Carlo, where the code in this directory is used to split up the MCMC chain and run numerous parallel chains as an array of jobs. Post-processing R code then checks and combines the chains to form a single posterior distribution of model parameters.
