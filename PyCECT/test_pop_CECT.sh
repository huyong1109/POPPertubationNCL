#!/bin/bash
#BSUB -n 1 
#BSUB -q regular
#BSUB -R "span[ptile=2]"
#BSUB -a poe
##BSUB -N
#BSUB -x
#BSUB -o pop.%J.stdout
#BSUB -e pop.%J.stdout
#BSUB -J poptest
#BSUB -P P93300612
#BSUB -W 0:10
#BSUB -u huyong@ucar.edu

export MP_LABELIO=yes;
export MP_COREFILE_FORMAT=lite
#export MP_DEBUG_TIMEOUT_COMMAND=~/bin/timeout_debug.sh
#mpirun.lsf python pyCECT.py --sumfile /glade/scratch/haiyingx/pop.ens.sum.nc --indir /glade/scratch/haiyingx/test_pop_data/ --popens --jsonfile pop_ensemble.json --mpi_enable --outfile /glade/scratch/haiyingx/testcase.result
#mpirun.lsf python pyCECT.py --sumfile /glade/p/work/huyong/verify/pop.30ens.openseas.nc --indir /glade/p/work/huyong/verify/30ENS --popens --jsonfile pop_ensemble.json --mpi_enable --outfile /glade/scratch/haiyingx/testcase30.result
mpirun.lsf python pyCECT.py --sumfile /glade/scratch/huyong/verify/EnsSize/pop.$enssize.ens.sum.$randid.nc --indir /glade/scratch/huyong/verify/testcases/ --popens --jsonfile pop_ensemble.json --mpi_enable --outfile /glade/scratch/huyong/verify/testcase.$enssize.$randid.result --casejson /glade/scratch/huyong/verify/random_testcase.json --npick 10

