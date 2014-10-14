#! /bin/csh -f 
# This script is used to submit ensemble cases
# contains Temperature and Salinity perturbation of e-14, 4-12 and so on.

setenv ARCHIVE /glade/scratch/huyong/archive


setenv CASE_PFX perturb.TS.g40.year
setenv OUTPUT  $ARCHIVE/$CASE_PFX.OUTPUT

mkdir $OUTPUT

foreach pert (14 12 10 8 6 4 2)

    set CASE1=$CASE_PFX.$pert
    cp $ARCHIVE/$CASE1/ocn/hist/*  $OUTPUT/

end
    
