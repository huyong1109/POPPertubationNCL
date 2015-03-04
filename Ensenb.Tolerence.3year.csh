#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv CASEROOT $GSCRATCH

setenv CASE_PFX perturb.g40.T.year
setenv OCASE $CASEROOT/$CASE_PFX



foreach tol (10 11 12 14 16) #91

  set CASE1_NAME=$CASE_PFX.tol.$tol
  set CASE1=$CASEROOT/$CASE1_NAME
  
  
  # Edit env_build in cloned case
  cd $CASE1

  rm $CASE1/run/*.nc 
  cp $WORK/1001-01-01-00000/* $CASE1/run
  
  
  # Only submit the cloned case if --nosubmit is off
  ./$CASE1_NAME.submit
end
    
