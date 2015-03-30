#! /bin/tcsh -f
#BSUB -n  32
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J Pert_T-6
#BSUB -W 12:00
#BSUB -P P07010002


#foreach time (01 02 03 04 05 06 07 08 09 10 11 12) #month
##foreach time (02 03 04 05 06 07 08 09 10 11 12 13 14 15) #day
##./create_ensemble.sh  -out_file $WORK/NCOUT/perturb.T.h.$Mon-6-np.nc -pop_out $SCR/archive -casename perturb.g40.T.year -casesuffix pop.h.0001-$Mon.nc -n 6 -defpert filesuff.in -defvar defvar.in -month -verbose &
##./create_ensemble.sh  -out_file $WORK/NCOUT/5years/perturb.T.h.$time-14-np-7cases.nc -pop_out $SCR/archive  -casename perturb.g40.T.year5 -casesuffix pop.h.0001-$time.nc -n 7 -defpert filesuff.T.in -defvar defvar.in -month -verbose   # for 5 years 7cases
##create_ensemble.sh  -out_file $WORK/NCOUT/perturb.T.h.$Mon-cs-csi.nc -pop_out $SCR/archive -casename perturb.g40.T.year -casesuffix pop.h.0001-$Mon.nc -n 2 -defpert filesuff.in -defvar defvar.in -month -verbose 
##./create_ensemble.sh  -out_file $WORK/NCOUT/rmsz/perturb.T.h.day$time-14-np-5cases.nc -pop_out $SCR/archive  -casename perturb.g40.T.year -casesuffix pop.h.0001-01-$time.nc -n 7 -defpert filesuff.T.in -defvar defvar.in -month -verbose  # for days
##./create_ensemble.sh  -out_file $WORK/NCOUT/rmsz/perturb.T.h.mon$time-14-np-21cases.nc -pop_out $SCR/archive  -casename perturb.g40.T.year -casesuffix pop.h.0001-$time.nc -n 21 -defpert filesuff.T.in -defvar defvar.in -month -verbose  & # for days 
#./create_ensemble.sh  -out_file $WORK/NCOUT/global_rmsz/perturb.T.h.mon$time-14-np-41cases.nc -pop_out $SCR/archive  -casename perturb.g40.T.year -casesuffix pop.h.0001-$time.nc -n 41 -defpert filesuff.T.in -defvar defvar.in -month -verbose  &		# for month
#end

# for 3 years
foreach year ( 3 ) #month
foreach time (01 02 03 04 05 06 07 08 09 10 11 12) #month
#./create_ensemble.sh  -out_file $WORK/NCOUT/3years_opensea/perturb.T.h.$year-$time-14-np-40cases.nc -pop_out $SCR/archive  -casename perturb.g40.T.year -casesuffix pop.h.000$year-$time.nc -n 40  -defpert filesuff.T.in -defvar defvar.in -month -verbose  & 
./create_ensemble.sh  -out_file $WORK/NCOUT/3years_opensea/perturb.T.h.$year-$time-14-np-40cases_POP_VDC_CICE.nc -pop_out $SCR/archive  -casename perturb.g40.T.year -casesuffix pop.h.000$year-$time.nc -n 40  -defpert filesuff.T.in -defvar defvar.in -month -verbose 



end 
end 
