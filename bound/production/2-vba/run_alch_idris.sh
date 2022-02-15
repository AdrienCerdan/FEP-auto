#!/bin/bash

if compgen -G "lambda.*" > /dev/null; then
        echo "Run folders are presents " 
else
        echo "Missing run folders !!! " 
        bash mk_dir.sh
fi




if grep -q vba.itp complex.top; then
    echo "VBA is active"
else
    echo "!!!! VBA is not active !!!!"
    exit
fi


for d in lambda.*; do
	d1=$(basename $d)
        lam="${d1##*.}"
#        if [ $lam -eq 4 ]; then
	echo $d
	sed "s/dlambda/${d}/g" alch_idris.slurm > TMP 
	sbatch TMP
#	fi
done
