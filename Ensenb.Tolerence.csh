#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv CASEROOT $GSCRATCH

setenv CASE_PFX perturb.g40.T.year
setenv OCASE $CASEROOT/$CASE_PFX



#foreach tol (10 11 12 14 16) #91
foreach tol (10_5 9_5 9 )

  set CASE1_NAME=$CASE_PFX.tol.$tol
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
  
  echo "maxiterations = 5000"   >> user_nl_pop2
  #echo "convergencecriterion = 1.0e-$tol"   >> user_nl_pop2
  ./preview_namelists
  
  # Adjust walltime, account number and ptile in clone
  cp $WORK/1001-01-01-00000/* $CASE1/run
  
  #CHECK RUN
  sed -i "s/ 4:00/ 6:00/g" $CASE1/*.run
  #sed -i "s/ regular/ premium/g" $CASE1/*.run
  sed -i "s/ptile=15/ptile=16/g" $CASE1/*.run
  
  # Only submit the cloned case if --nosubmit is off
  #./$CASE1_NAME.submit
end
    
