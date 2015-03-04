#!/bin/csh -f
setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv MYRUNS $GSCRATCH

#setenv CASE1 $MYRUNS/perturb.g40.T.year.tol.9  # tol = 5.0e-10
#setenv CASE1 $MYRUNS/perturb.g40.T.year.tol.10_5  # tol = 5.0e-10
#setenv CASE1 $MYRUNS/perturb.g40.T.year.vmixvvc  # const_vvc = 0.25 ==> 2.5
#setenv CASE1 $MYRUNS/perturb.g40.T.year.vmixvdc  # const_vdc = 0.25 ==> 2.5
#setenv CASE1 $MYRUNS/perturb.g40.T.year.tidalmix  # ltidal_mixing = .true. ==> .false.
#setenv CASE1 $MYRUNS/perturb.g40.T.year.vmixrich # vmix_choice = 'kpp' ==> 'rich'
#setenv CASE1 $MYRUNS/perturb.g40.T.year.vmixconst # vmix_choice = 'kpp' ==> 'const'
#setenv CASE1 $MYRUNS/perturb.g40.T.year.tadvect  # tadvect_ctype = 'upwind3' ==> 'lw_lim'
setenv CASE1 $MYRUNS/perturb.g40.T.year.convectdiff2  # convectdiff *5
#setenv CASE1 $MYRUNS/perturb.g40.T.year.P384  # decomposition

cd $CCSMROOT/scripts
./create_newcase -mach yellowstone -res ne30_g16_rx1 -compset G_NORMAL_YEAR -case $CASE1
cd $CASE1
source $CASE1/Tools/ccsm_getenv

#cp ~/TEMPLATE/models/atm/datm/bld/namelist_files/namelist_defaults_datm.xml $CODEROOT/atm/datm/bld/namelist_files/

./xmlchange -file env_mach_pes.xml -id NTASKS_ATM -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_LND -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_ICE -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_OCN -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_CPL -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_GLC -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_ROF -val 96 
./xmlchange -file env_mach_pes.xml -id NTASKS_WAV -val 96 

./xmlchange -file env_mach_pes.xml -id NTHRDS_ATM -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_LND -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_ICE -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_OCN -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_CPL -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_GLC -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_ROF -val 1
./xmlchange -file env_mach_pes.xml -id NTHRDS_WAV -val 1

./xmlchange -file env_run.xml -id RUN_TYPE -val hybrid
./xmlchange -file env_run.xml -id RUN_REFCASE -val g.e12.G.T62_g16.001
./xmlchange -file env_run.xml -id RUN_REFDATE -val 1001-01-01


./xmlchange -file env_run.xml -id STOP_OPTION -val nyears
./xmlchange -file env_run.xml -id STOP_N -val 3

./cesm_setup
#echo "tadvect_ctype = 'standard'"   >> user_nl_pop2  # change advection scheme
#echo "vmix_choice = 'const'"   >> user_nl_pop2  # vmix
#echo "vmix_choice = 'rich'"   >> user_nl_pop2  # vmix
#echo "ltidal_mixing = .false." >> user_nl_pop2 # tidal_mixing 
echo "convect_diff = 20000.0" >> user_nl_pop2 # convect_diff
#echo "const_vdc = 2.5" >> user_nl_pop2 # vmix const_vdc
#echo "const_vvc = 2.5" >> user_nl_pop2 # vmix const_vvc
#echo "convergencecriterion = 5.0e-10"   >> user_nl_pop2
#echo "convergencecriterion = 1.0e-9"   >> user_nl_pop2
echo "maxiterations = 5000"   >> user_nl_pop2
./preview_namelists

$CASE1/*.build 

#CHECK IF THE LOG FILE EXISTS
#ls $LOGDIR
cp $WORK/1001-01-01-00000/* $CASE1/run

#CHECK RUN
#sed -i "s/ 4:00/ 6:00/g" $CASE1/*.run
#sed -i "s/ regular/ premium/g" $CASE1/*.run
sed -i "s/ P00000000/ P93300012/g" $CASE1/*.run
#sed -i "s/ptile=15/ptile=16/g" $CASE1/*.run

bsub < $CASE1/*.run

