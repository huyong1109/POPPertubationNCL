#! /bin/tcsh -f
#BSUB -n 16
#BSUB -P P93300612
#BSUB -q geyser
#BSUB -N
#BSUB -a poe
#BSUB -o T.stdout.%J
#BSUB -e T.stderr.%J
#BSUB -J validation
#BSUB -W 12:00

#### 3 years ####
foreach year (3 ) #2 3 )
foreach month (01 02 03 04 05 06 07 08 09 10 11 12)
bsub -n 16 -P P93300612 -q geyser -N -a poe -o T.stdout.%J -e T.stderr.%J -J validation -W 12:00  < ./run_validation.sh  $year $month
end
end
