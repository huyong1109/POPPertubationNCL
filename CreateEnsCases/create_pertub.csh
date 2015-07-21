#! /bin/csh -f 

foreach pert ( `seq 1 1 60` )
  #echo "pert : $pert"
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
  #echo $pert $ptlim
  printf "%2s\t%s\n" $ippt $ptlim
end 
