#! /bin/tcsh -f
foreach casesuf  (14 14.51 csi) #14.21 14.51 14.71 14.91 csi)
#foreach filesuf  (01 02 03 04 05 06 07 08 09 10 11 12)
#foreach filesuf  (04 05  10 11)
foreach filesuf  (07 )
foreach varname  (SALT ) #(SSH UVEL VVEL TEMP SALT)
foreach direction  (z_t )#lat lon)
foreach val  (0 4 10 40) #50)
    #### ------ for T -14 perturbation ------ ####
    ./slice.sh  -casesuf $casesuf -filesuf $filesuf -varname $varname  -direction $direction -val $val

end
end
end
end
end
