#/bin/sh

#-- Run MCMCglmm model simulation on cluster (multiple chains in parallel)
#-- Run as an array of jobs
#-- XXX !! USING A RESERVATION !! XXX

RESNAME="<< INSERT NAME HERE, e.g 'xxx0001_s11' >>" # Group for the reservation
RESID="<< INSERT NUMBER HERE, e.g., 123456' >>"	    # Number of the reservation
TIMESTAMP=$(date +%Y%m%d_%H%M%S)



echo
echo "Listing current reservations"
echo
showres | grep $RESNAME*
echo

read -p $'Press <ENTER> to continue with reservation ID: '$RESID' OR type new ID ' key
if [[ $key = "" ]]; then
    echo "You pressed Enter: using reservation ID: "$RESID
  else
    echo "Using reservation ID '$key' instead"
    RESID=$key
  fi

cp ./MCMCglmm_jobarray.sh "./MCMCglmm_jobarray"$TIMESTAMP".sh"
cp ./parMCMC-R.sh "./parMCMC_"$TIMESTAMP"-R.sh"

qsub -q gen28 -W x=FLAGS:ADVRES:$RESNAME.$RESID -F $TIMESTAMP ./MCMCglmm_jobarray$TIMESTAMP.sh


