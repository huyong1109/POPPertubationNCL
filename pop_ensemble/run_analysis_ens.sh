#! /bin/tcsh -f
#BSUB -n 12
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J validation
#BSUB -W 6:00
#BSUB -P P07010002

setenv NCL_VALID_LIB_DIR $PWD/ncl_library
foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
#ncl analysis_ensemble.ncl  ens_file=\"$WORK/NCOUT_nodz/rmsz/perturb.T.h.mon$month-14-np-21cases.nc\" # >> ./validation/analysis-41cases.log 
ncl analysis_ensemble.ncl  ens_file=\"$WORK/NCOUT_nodz/rmsz/perturb.T.h.$month-14-np.nc\" # >> ./validation/analysis-41cases.log 
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-01-$day.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.day$day-14-np.nc -month -verbose  > ./validation/validationtest-day$day-$casesuf.log 
end
