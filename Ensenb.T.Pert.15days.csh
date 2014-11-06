#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv CASEROOT $GSCRATCH

setenv CASE_PFX perturb.g40.T.year
setenv OCASE $CASEROOT/$CASE_PFX



#foreach pert #(6 8 10 12 14 14.21 14.41 14.51 14.71 14.91 csi tol.10 tol.11 tol.12 tol.14 tol.16  )

  #set CASE1_NAME=${CASE_PFX}.$pert
  set CASE1_NAME=${CASE_PFX}
  set CASE1=$CASEROOT/$CASE1_NAME
  
  
  
  # Edit env_build in cloned case
  cd $CASE1
  # ten days run
  ./xmlchange -file env_run.xml -id STOP_OPTION -val ndays
  ./xmlchange -file env_run.xml -id STOP_N -val 15
  
  
  $CASE1/*.build 
  # Change pertlim in clone
  
  sed -i "s/ P07010002/ P93300612/g" $CASE1/*.run
  echo "tavg_file_freq_opt = 'nday' 'nday' 'once'" >> user_nl_pop2
  echo "tavg_freq_opt = 'nday' 'nday' 'once'" >> user_nl_pop2
  ./preview_namelists
  
  # Only submit the cloned case if --nosubmit is off
  ./$CASE1_NAME.submit

#end
    
