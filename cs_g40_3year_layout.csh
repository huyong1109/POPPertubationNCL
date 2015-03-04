#!/bin/csh -f
setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv MYRUNS $GSCRATCH

setenv CASE1 $MYRUNS/perturb.g40.T.year.P192  # decomposition
#setenv CASE1 $MYRUNS/perturb.g40.T.year.P96b40x33  # decomposition
#setenv CASE1 $MYRUNS/perturb.g40.T.year.P96b20x16  # decomposition

cd $CCSMROOT/scripts
./create_newcase -mach yellowstone -res ne30_g16_rx1 -compset G_NORMAL_YEAR -case $CASE1
cd $CASE1
source $CASE1/Tools/ccsm_getenv

#cp ~/TEMPLATE/models/atm/datm/bld/namelist_files/namelist_defaults_datm.xml $CODEROOT/atm/datm/bld/namelist_files/

./xmlchange -file env_mach_pes.xml -id NTASKS_ATM -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_LND -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_ICE -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_OCN -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_CPL -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_GLC -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_ROF -val 192 
./xmlchange -file env_mach_pes.xml -id NTASKS_WAV -val 192 

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

##### P96 block 20x16
#./xmlchange -file env_build.xml -id POP_AUTO_DECOMP -val false
#./xmlchange -file env_build.xml -id POP_BLCKX -val 20
#./xmlchange -file env_build.xml -id POP_BLCKY -val 16
#./xmlchange -file env_build.xml -id POP_NX_BLOCKS -val 16
#./xmlchange -file env_build.xml -id POP_NY_BLOCKS -val 24
#./xmlchange -file env_build.xml -id POP_MXBLCKS -val 4
#./xmlchange -file env_build.xml -id POP_DECOMPTYPE -val cartesian

#### uneven block 
#./xmlchange -file env_build.xml -id POP_AUTO_DECOMP -val false
#./xmlchange -file env_build.xml -id POP_BLCKX -val 40
#./xmlchange -file env_build.xml -id POP_BLCKY -val 33
#./xmlchange -file env_build.xml -id POP_NX_BLOCKS -val 8
#./xmlchange -file env_build.xml -id POP_NY_BLOCKS -val 12
#./xmlchange -file env_build.xml -id POP_MXBLCKS -val 1
#./xmlchange -file env_build.xml -id POP_DECOMPTYPE -val cartesian

./cesm_setup
#echo "tadvect_ctype = 'standard'"   >> user_nl_pop2  # change advection scheme
#echo "vmix_choice = 'const'"   >> user_nl_pop2  # vmix
#echo "vmix_choice = 'rich'"   >> user_nl_pop2  # vmix
#echo "ltidal_mixing = .false." >> user_nl_pop2 # tidal_mixing 
#echo "convect_diff = 100000.0" >> user_nl_pop2 # convect_diff
#echo "const_vdc = 2.5" >> user_nl_pop2 # vmix const_vdc
#echo "const_vvc = 2.5" >> user_nl_pop2 # vmix const_vvc
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

