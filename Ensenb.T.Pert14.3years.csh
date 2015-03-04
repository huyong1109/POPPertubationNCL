#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv GSCRATCH /glade/scratch/huyong
setenv CASEROOT $GSCRATCH
setenv CASE_PFX perturb.g40.T.year
setenv OCASE $CASEROOT/$CASE_PFX.14.5


#(1 5 71 51 41 21 91) ! done
#(11 31 61 81 25 35 45 55 65 75 85 95) done
#(3 8 13 18 23 28 33 38 43 48 53 58 63 68 73 78 83 88 93 98)
foreach pert (11 15 31 61 81 25 35 45 55 65 75 85 95 71 51 41 21 91 3 8 13 18 23 28 33 38 43 48 53 58 63 68 73 78 83 88 93 98)
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
  
  # Edit env_build in cloned case
  cd $CASE1
  ./xmlchange -file env_run.xml -id STOP_OPTION -val nyears
  ./xmlchange -file env_run.xml -id STOP_N -val 3
  ./cesm_setup
  echo "tavg_file_freq_opt = 'nmonth' 'nmonth' 'once'" >> user_nl_pop2
  echo "tavg_freq_opt = 'nmonth' 'nday' 'once'" >> user_nl_pop2
  ./preview_namelists
  
  
  #CHECK RUN
  #sed -i "s/ P07010002/ P93300612/g" $CASE1/*.run
  #sed -i "s/ptile=15/ptile=16/g" $CASE1/*.run
  
  # Only submit the cloned case if --nosubmit is off
  ./$CASE1_NAME.submit
end
    
