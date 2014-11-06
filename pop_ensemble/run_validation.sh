#! /bin/tcsh -f
#BSUB -n 12
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J validation
#BSUB -W 1:00
#BSUB -P P07010002

foreach casesuf  (12 tol.16)# ( 2 4 6 8 10 12 14 csi np tol.10 tol.11 tol.12 tol.14 tol.16) 
#foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
foreach day (13 )#02 03 04 05 06 07 08 09 10 11 12 12 14 15)
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.$month-14-np.nc -month -verbose  > ./validation/validationtest-$month-$casesuf.log &
./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-01-$day.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.day$day-14-np.nc -month -verbose  > ./validation/validationtest-day$day-$casesuf.log 
end
end
