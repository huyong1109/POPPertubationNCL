#!/bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature perturbation of -5.0e-14 ~ 5.0e-14.

setenv CCSMROOT /glade/p/work/huyong/cesm1_2_2
setenv MYRUNS /glade/scratch/huyong

setenv CASE_PFX gT62.g16.pert
setenv OCASE $MYRUNS/gT62.g16  # orignal case

foreach pert (`seq 21 1 60`)
  if ( $pert <= 30 ) then 
      set j=`expr $pert + 9`
      set ippt=`/usr/bin/printf "%2.2d" $j`
      set ptlim="0.${ippt}e-13"
      set ippt=`/usr/bin/printf "%2.2d" $pert`
  else
      set j=`expr $pert - 21`
      set ippt=`/usr/bin/printf "%2.2d" $j`
      set ptlim="-0.${ippt}e-13"
      set ippt=`/usr/bin/printf "%2.2d" $pert`
  endif
  echo $ippt  $ptlim

  set CASE1_NAME=$CASE_PFX$ippt
  set CASE1=$MYRUNS/$CASE1_NAME
  
  # # Create clone
  #  cd $CCSMROOT/scripts
  #  ./create_clone -case $CASE1 -clone $OCASE # Copy $CASE to $CASE1
  #  #echo "./create_clone -case $CASE1 -clone $OCASE # Copy $CASE to $CASE1 "
  #  
  #  
  #  # Get value for EXEROOT from $CASE
  #  # Note return string is "EXEROOT = $EXEROOT"
  #  cd $OCASE
  #  set EXE=`./xmlquery EXEROOT -valonly`
  #  set EXEROOT=`echo $EXE | sed 's/^EXEROOT = //'`
  #  echo $EXEROOT
  #  
  #  # Edit env_build in cloned case
    cd $CASE1
  #  ./xmlchange -file env_build.xml -id EXEROOT -val $EXEROOT
  #  ./xmlchange -file env_build.xml -id BUILD_COMPLETE -val TRUE
  #  ./cesm_setup
  #  
  #  
  #  # Change pertlim in clone
  #  
  #  sed -i  "/init_ts_perturb = /d" user_nl_pop2
  #  echo  "init_ts_perturb = $ptlim" >> user_nl_pop2
  #  ./preview_namelists
  #  
  #  # Adjust walltime, account number and ptile in clone
  #  #cp ~/1001-01-01-00000/* $CASE1/run
  #  
  #  #CHECK RUN
  #  sed -i "s/ 8:00/ 4:00/g" $CASE1/*.run
  #  #sed -i "s/ P00000000/ P93300612/g" $CASE1/*.run
  #  #sed -i "s/ P07010002/ P93300612/g" $CASE1/*.run
  #  sed -i "s/ptile=15/ptile=16/g" $CASE1/*.run
  #  
  #  # Only submit the cloned case if --nosubmit is off
  ./$CASE1_NAME.submit
end
    
