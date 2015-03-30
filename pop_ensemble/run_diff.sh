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


#foreach pert (csi 2 4 6 8 10 12 14)
#### ------ for T perturbation ------ ####
#./create_diff.sh  -out_file ./rmse_T_$pert.nc -pop_out $SCR/archive/perturb.g40.T.year.$pert -pop_out1 $SCR/archive/perturb.g40.T.year.np/  -casename perturb.g40.T.year.$pert -casename1 perturb.g40.T.year.np  -n 12 -defpert diffsuff.in -defvar defvar.in -month -verbose 
#end

#### ------ for TS perturbation ------ ####
#foreach pert (csi 3 4 6 8 10 12 14)
#./create_diff.sh  -out_file ./rmse_TS_$pert.nc -pop_out $SCR/archive/perturb.TS.g40.year.$pert -pop_out1 $SCR/archive/perturb.TS.g40.year.np/  -casename perturb.TS.g40.year.$pert -casename1 perturb.TS.g40.year.np  -n 12 -defpert diffsuff.in -defvar defvar.in -month -verbose 

#### ------ for TS -14 perturbation ------ ####
#foreach pert (91 71 51 41 21)
#./create_diff.sh  -out_file $WORK/NCOUT/rmse_TS14_$pert.nc -pop_out $SCR/archive/perturb.TS.g40.year.14.$pert -pop_out1 $SCR/archive/perturb.TS.g40.year.np/  -casename perturb.TS.g40.year.14.$pert -casename1 perturb.TS.g40.year.np  -n 12 -defpert diffsuff.in -defvar defvar.in -month -verbose 

#### ------ for T -14 perturbation ------ ####
#./create_diff.sh  -out_file $WORK/NCOUT/rmse_T14_$pert.nc -pop_out $SCR/archive/perturb.g40.T.year.14.$pert -pop_out1 $SCR/archive/perturb.g40.T.year.np/  -casename perturb.g40.T.year.14.$pert -casename1 perturb.g40.T.year.np  -n 12 -defpert diffsuff.in -defvar defvar.in -month -verbose 

#### ------ for TS -14 perturbation ------ ####
#foreach pert (01 41 csi)
#./create_diff.sh  -out_file $WORK/NCOUT/rmse_TS14_$pert.nc -pop_out $SCR/archive/perturb.TS.g40.year.14.$pert -pop_out1 $SCR/archive/perturb.TS.g40.year.np/  -casename perturb.TS.g40.year.14.$pert -casename1 perturb.TS.g40.year.np  -n 12 -defpert diffsuff.in -defvar defvar.in -month -verbose 

#### ------ for T -14 perturbation ------ ####
#./create_diff.sh  -out_file $WORK/NCOUT/5year_rmse_T14_$pert.nc -pop_out $SCR/archive/perturb.g40.T.year5.$pert -pop_out1 $SCR/archive/perturb.g40.T.year5.00/  -casename perturb.g40.T.year5.$pert -casename1 perturb.g40.T.year5.00  -n 60 -defpert diffsuff.in -defvar defvar.in -month -verbose 


#### ------ for TOL : -10 ~ -16------ ####
foreach pert (year.tol.10 year.tol.11 year.tol.12 year year.tol.14 year.csi)

#### ------ for T -14 perturbation ------ ####
./create_diff.sh  -out_file $WORK/NCOUT/rmse_tol16_opensea/rmse_TOL_$pert.nc -pop_out $SCR/archive/perturb.g40.T.$pert -pop_out1 $SCR/archive/perturb.g40.T.year.tol.16/  -casename perturb.g40.T.$pert -casename1 perturb.g40.T.year.tol.16  -n 36 -defpert diffsuff.in -defvar defvar.in -month -verbose  &

end
