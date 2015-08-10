#!/bin/bash
#BSUB -n 1 
#BSUB -q regular
#BSUB -R "span[ptile=2]"
#BSUB -a poe
#BSUB -N
#BSUB -x
#BSUB -o pop.%J.stdout
#BSUB -e pop.%J.stdout
#BSUB -J popens
#BSUB -P P93300612
#BSUB -W 0:10
#BSUB -u huyong@ucar.edu

export MP_LABELIO=yes;
export MP_COREFILE_FORMAT=lite
#export MP_DEBUG_TIMEOUT_COMMAND=~/bin/timeout_debug.sh
#mpirun.lsf python pyEnsSumPop.py --verbose --indir /glade/scratch/haiyingx/pop_ensemble_data/ --sumfile /glade/scratch/haiyingx/pop.ens.sum.2.nc --nyear 1 --nmonth 12 --npert 40 --jsonfile pop_ensemble.json  --mpi_enable --nbin 40 --rand --nrand 30
echo $enssize $randid
mpirun.lsf python pyEnsSumPop.py --verbose --indir /glade/scratch/huyong/verify/Mon12_Ens/ --sumfile /glade/scratch/huyong/verify/EnsSize/pop.$enssize.ens.sum.$randid.nc --nyear 1 --nmonth 12 --npert 70 --jsonfile pop_ensemble.json  --mpi_enable --nbin 40 --rand --nrand $enssize --jsondir /glade/scratch/huyong/verify/EnsSize/ --seq $randid


