#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv CASEROOT $GSCRATCH

setenv CASE_PFX perturb.g40.T.3year
setenv OCASE $CASEROOT/perturb.g40.T.year


#(1 5 71 51 41 21 91) ! done
#() done
foreach pert ( 5 ) #11 31 61 81 25 35 45 55 65 75 85 95 3 8 13 18 23 28 33 38 43 48 53 58 63 68 73 78 83 88 93 98)
  echo "pert : $pert"
  if ( $pert == 0 ) then 
    ptlim=0.0
  else if ( $pert < 51 ) then
      set j=`expr $pert + 9 `
      echo $j
      set ippt=`/usr/bin/printf "%2.2d" $j`
      set ptlim="0.${ippt}e-13"
  else
      set j=`expr $pert - 41`
      echo $j
      set ippt=`/usr/bin/printf "%2.2d" $j`
      set ptlim="-0.${ippt}e-13"
  endif
  echo $ptlim

  set CASE1_NAME=$CASE_PFX.14.$pert
  set CASE1=$CASEROOT/$CASE1_NAME
  
  # Create clone
  cd $CCSMROOT/scripts
  ./create_clone -case $CASE1 -clone $OCASE # Copy $CASE to $CASE1
  #echo "./create_clone -case $CASE1 -clone $OCASE # Copy $CASE to $CASE1 "
  
  
  # Get value for EXEROOT from $CASE
  # Note return string is "EXEROOT = $EXEROOT"
  cd $OCASE
  set EXE=`./xmlquery EXEROOT -valonly`
  set EXEROOT=`echo $EXE | sed 's/^EXEROOT = //'`
  echo $EXEROOT
  
  # Edit env_build in cloned case
  cd $CASE1
  ./xmlchange -file env_build.xml -id EXEROOT -val $EXEROOT
  ./xmlchange -file env_build.xml -id BUILD_COMPLETE -val TRUE
  ./cesm_setup
  
  
  # Change pertlim in clone
  
  echo  "init_ts_perturb = $ptlim" >> user_nl_pop2
  ./preview_namelists
  
  # Adjust walltime, account number and ptile in clone
  cp ~/1001-01-01-00000/* $CASE1/run
  
  #CHECK RUN
  sed -i "s/ 4:00/ 6:00/g" $CASE1/*.run
  sed -i "s/ P00000000/ P93300612/g" $CASE1/*.run
  sed -i "s/ P07010002/ P93300612/g" $CASE1/*.run
  sed -i "s/ptile=15/ptile=16/g" $CASE1/*.run
  
  # Only submit the cloned case if --nosubmit is off
  ./$CASE1_NAME.submit
end
    
