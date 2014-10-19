#! /bin/tcsh -f
#BSUB -n 12
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o TS.stdout.%J
#BSUB -e TS.stderr.%J
#BSUB -J Pert_TS
#BSUB -W 12:00
#BSUB -P P07010002


foreach Mon (01  06  12)
    #./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.TS.h.$Mon-6-np.nc -pop_out $SCR/archive -casename perturb.TS.g40.year -casesuffix pop.h.0001-$Mon.nc -n 6 -defpert filesuff.in -defvar defvar.in -month -verbose  &
    ./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.TS.h.$Mon-csi-3-np.nc -pop_out $SCR/archive -casename perturb.TS.g40.year -casesuffix pop.h.0001-$Mon.nc -n 9 -defpert filesuff.in -defvar defvar.in -month -verbose  &
end

