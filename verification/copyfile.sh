#!/bin/bash

#/glade/scratch/huyong/archive/gT62.g16.pert01/ocn/hist/gT62.g16.pert01.pop.h.0001-01.nc
enssize="70"
filelist="gT62.g16.pert"
casename=".pop.h."
dirname="/glade/scratch/huyong/archive/"
destname="/glade/scratch/huyong/verify/Mon12_Ens/"
subdir="/ocn/hist/"


mkdir  $destname
j=0
for i in $(seq $enssize)
do

   
   #for year in "0001" "0002" "0003"
   for year in "0001"
   do 
      #for mon in "01" "02" "03" "04" "05" "06" "07" "08" "09" "10" "11" "12"
      for mon in "12" 
      do
         if [ $j -lt 10 ]
         then
            str="000"$j
         else
            str="00"$j
         fi
         if [ $i -lt 10 ]
         then
            istr="0"$i
         else
            istr=$i
         fi
         echo "ln -s" $dirname$filelist$istr$subdir$filelist$istr$casename$year-$mon.nc $destname$filelist$str$casename$year-$mon.nc
         ln -s $dirname$filelist$istr$subdir$filelist$istr$casename$year-$mon.nc $destname$filelist$str$casename$year-$mon.nc
      done
   done
   j=$((j+1))
done
