#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv CCSMROOT /glade/p/cesm/cseg/collections/cesm1_2_0
setenv GSCRATCH /glade/scratch/huyong

setenv CASEROOT $GSCRATCH

setenv CASE_PFX perturb.g40.T.year
setenv OCASE $CASEROOT/$CASE_PFX


foreach pert (12 10 8 6 4 2)

    set CASE1_NAME=$CASE_PFX.$pert
    set CASE1=$CASEROOT/$CASE1_NAME


    # Edit env_build in cloned case
    cd $CASE1
  ./xmlchange -file env_run.xml -id STOP_OPTION -val nyears
  ./xmlchange -file env_run.xml -id STOP_N -val 3
  ./cesm_setup
  echo "tavg_file_freq_opt = 'nmonth' 'nmonth' 'once'" >> user_nl_pop2
  echo "tavg_freq_opt = 'nmonth' 'nday' 'once'" >> user_nl_pop2
  ./preview_namelists
    

    # Only submit the cloned case if --nosubmit is off
    ./$CASE1_NAME.submit
end
    
