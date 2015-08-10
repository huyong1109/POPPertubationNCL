#!/bin/bash

for i in "20" "30" "40" "50" "60"
#for i in "10" 
do 
	export enssize=$i
	for j in $(seq 100)
	do 
		export randid=$j
		bsub < ./test_pop_CECT.sh 
	done
done
