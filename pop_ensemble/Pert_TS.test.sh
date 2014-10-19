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


foreach Mon (01 02 03 04 05 06 07 08 09 10 11 12)
    ./create_ensemble.sh  -out_file ./perturb.TS.h.$Mon.nc -pop_out $SCR/archive -casename perturb.TS.g40.year -casesuffix pop.h.0001-$Mon.nc -n 7 -defpert filesuff.in -defvar defvar.in -month -verbose  > ./log
end

