#! /bin/tcsh -f

foreach Mon (01 02 03 04 05 06 07 08 09 10 11 12)
echo "MONTH : $Mon"
foreach var (UVEL VVEL TEMP SALT SSH) #02 03 04 05 06 07 08 09 10 11 12)
echo "VAR : $var"
foreach pert (2 4 6 8 10 12 14 csi np tol.10 tol.11 tol.12 tol.14 tol.16)
printf  "\t%6s     " "${pert}"
grep "${var}: RMSZ score " ./validationtest-${Mon}-${pert}.log |awk '{ print  $6}'
end
end
end
