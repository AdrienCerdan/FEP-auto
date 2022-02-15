#!/bin/bash
#
# Note that you might have to adapt this script in order to use it on your
# machine or cluster. In particular, the name of the Gromacs executable will
# depend on your installation: e.g. gmx, gmx_avx, gmx_sse
# Also, if you run this on your machine it might take several hours, and
# you might want to decide not to use all available cores you have.

gmx=/home/acerdan/Softwares/gromacs-2020.4/build/bin/gmx


for d in lambda.*/; do
  d1=$(basename $d)
  lam="${d1##*.}"
#  if [ $lam -lt 7 ]; then
  cd $d
  cd PROD
  $gmx mdrun  -deffnm prod  -cpi prod.cpt -append -nsteps 200000 -v -dhdl dhdl 
  cd ../../
#  fi
done
