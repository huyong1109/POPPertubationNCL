#! /bin/tcsh -f
foreach casesuf  (14 14.21 14.51 14.71 14.91 csi)
foreach filesuf  (01 02 03 04 05 06 07 08 09 10 11 12)
    set varname=SSH
    #### ------ for T -14 perturbation ------ ####
    ./compare.sh  -casesuf $casesuf -filesuf $filesuf -varname $varname 

end
end
