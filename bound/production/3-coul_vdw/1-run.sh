#!/bin/bash
#
# Note that you might have to adapt this script in order to use it on your
# machine or cluster. In particular, the name of the Gromacs executable will
# depend on your installation: e.g. gmx, gmx_avx, gmx_sse
# Also, if you run this on your machine it might take several hours, and
# you might want to decide not to use all available cores you have.

gmx=gmx

if compgen -G "lambda.*" > /dev/null; then
        echo "Run folders are presents " 
else
        echo "Missing run folders !!! " 
        bash mk_dir.sh
fi



#if grep -q vba.itp complex.top; then
#    echo "!!!! VBA is active !!!!"
#    exit
#fi

for d in lambda.*/; do
  d1=$(basename $d)
  lam="${d1##*.}"
#  if [ $lam -eq 7 ]; then 
  cd $d
  mkdir ENMIN
  cd ENMIN
  $gmx grompp -f ../../MDP/ENMIN/enmin.$lam.mdp -c ../../complex.gro -p ../../complex.top -o enmin.tpr -maxwarn 1 -r ../../complex.gro
  $gmx mdrun -v -stepout 1000 -s enmin.tpr -deffnm enmin 

  cd ../
  mkdir NVT
  cd NVT
  $gmx grompp -f ../../MDP/NVT/nvt.$lam.mdp -c ../ENMIN/enmin.gro -p ../../complex.top -o nvt.tpr -maxwarn 1 -r ../ENMIN/enmin.gro
  $gmx mdrun -stepout 1000 -s nvt.tpr -deffnm nvt -v 

  cd ../
  mkdir NPT
  cd NPT
  $gmx grompp -f ../../MDP/NPT/npt.$lam.mdp -c ../NVT/nvt.gro -t ../NVT/nvt.cpt -p ../../complex.top -o npt.tpr -maxwarn 1 -r ../NVT/nvt.gro
  $gmx mdrun -stepout 1000 -s npt.tpr -deffnm npt -v 


  cd ../
  mkdir PROD
  cd PROD
  $gmx grompp -f ../../MDP/PROD/prod.$lam.mdp -c ../NPT/npt.gro -t ../NPT/npt.cpt -p ../../complex.top -o prod.tpr -maxwarn 1
  $gmx mdrun -stepout 1000 -s prod.tpr -deffnm prod -dhdl dhdl -v 

  cd ../../
#  fi
done

