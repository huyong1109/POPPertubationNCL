#! /bin/tcsh -f
#BSUB -n 12
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J Pert_T-6
#BSUB -W 12:00
#BSUB -P P07010002


foreach Mon (01  06  12)
#./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.T.h.$Mon-6-np.nc -pop_out $SCR/archive -casename perturb.g40.T.year -casesuffix pop.h.0001-$Mon.nc -n 6 -defpert filesuff.in -defvar defvar.in -month -verbose &
./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.T.h.$Mon-csi-2-np.nc -pop_out $SCR/archive -pop_out1 $SCR/archive -casename perturb.g40.T.year -casesuffix pop.h.0001-$Mon.nc -n 9 -defpert filesuff.T.in -defvar defvar.in -month -verbose &
#./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.T.h.$Mon-cs-csi.nc -pop_out $SCR/archive -casename perturb.g40.T.year -casesuffix pop.h.0001-$Mon.nc -n 2 -defpert filesuff.in -defvar defvar.in -month -verbose 
end
