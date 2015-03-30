#! /bin/tcsh -f
#BSUB -n 32
#BSUB -P P93300612
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J validation
#BSUB -W 12:00

#foreach casesuf  ( 2 4 6 8 10 12 14 csi np tol.10 tol.11 tol.12 tol.14 tol.16)  #(14.35) #
#foreach casesuf  ( year.csi year  year.tol.10 year.tol.11 year.tol.12 year.tol.14 year.tol.16)  #(14.35) #
foreach casesuf  (year.P192 ) #vmixvvc ) #vmixvdc ) #year.P96b40x33 ) # year.P96b20x16 ) # year.P48 ) # year.convectdiff ) # year.tadvect year.P384 
foreach year (1 2 3 )
foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
##foreach day (13 )#02 03 04 05 06 07 08 09 10 11 12 12 14 15)
##./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.$month-14-np.nc -month -verbose  > ./validation/validationtest-$month-$casesuf-7cases.log &
##./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.mon$month-14-np-21cases.nc -month -verbose  > ./validation/validationtest-$month-$casesuf-21cases.log &
##./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/global_rmsz/perturb.T.h.mon$month-14-np-41cases.nc -month -verbose  > ./validation/validationtest-$month-$casesuf-41cases.log  
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/global_rmsz/perturb.T.h.mon$month-14-np-41cases.nc -month -verbose  > ./validation_opensea/validationtest-$month-$casesuf-41cases.log  &
./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.$casesuf/ocn/hist/perturb.g40.T.$casesuf.pop.h.000$year-$month.nc -ensemble $WORK/NCOUT/3years_opensea/perturb.T.h.$year-$month-14-np-40cases.nc -month -verbose  > ./validation_opensea_3years/validationtest-$year-$month-$casesuf-41cases.log  &
end
end
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/global_rmsz/perturb.T.h.mon$month-14-np-41cases.nc -month -verbose  > ./validation_region/validationtest-$month-$casesuf-41cases.log  &

##./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-01-$day.nc -ensemble $WORK/NCOUT/rmsz/perturb.T.h.day$day-14-np.nc -month -verbose  > ./validation/validationtest-day$day-$casesuf.log 
end

#foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
#foreach casesuf  (14.11 14.15 14.21 14.25 14.31 14.35 14.41 14.45 14.5 14.51 14.55 14.61 14.65 14.71 14.75 14.81 14.85 14.91 14.95 14.3 14.8 14.13 14.18 14.23 14.28 14.33 14.38 14.43 14.48 14.53 14.58 14.63 14.68 14.73 14.78 14.83 14.88 14.93 14.98 )
##foreach casesuf  (14.41)
##foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
##./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/global_rmsz/perturb.T.h.mon$month-14-np-41cases.nc -month -verbose #> ./validation_opensea/validationtest-$month-$casesuf-41cases.log  &
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.0001-$month.nc -ensemble $WORK/NCOUT/global_rmsz/perturb.T.h.mon$month-14-np-41cases.nc -month -verbose > ./validation_seas/validationtest-$month-$casesuf-41cases.log  &
#end
#end

#### 3 years ####
#foreach month (12 ) #02 03 04 05 06 07 08 09 10 11 12)
#foreach year (1 2 3 ) #2 3 )
#foreach casesuf  (14.11 14.15 14.21 14.25 14.31 14.35 14.41 14.45 14.5 14.51 14.55 14.61 14.65 14.71 14.75 14.81 14.85 14.91 14.95 14.3 14.8 14.13 14.18 14.23 14.28 14.33 14.38 14.43 14.48 14.53 14.58 14.63 14.68 14.73 14.78 14.83 14.88 14.93 14.98 )
#
#./validation_test.sh -pop_out $SCR/archive/perturb.g40.T.year.$casesuf/ocn/hist/perturb.g40.T.year.$casesuf.pop.h.000$year-$month.nc -ensemble $WORK/NCOUT/3years/perturb.T.h.$year-$month-14-np-41cases.nc -month -verbose > ./validation_opensea_3years/validationtest-$year-$month-$casesuf-41cases.log  
#end
#end
#end
