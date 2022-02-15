#!/bin/bash

#..SOFTWARE
gmx=gmx

#..LOCAL variables
itop=complex.top
ipdb=complex.gro

cp $itop bound.top
#..PREPARE simulation BOX
echo "0" | $gmx editconf -f ${ipdb} -o cubic-box.gro -bt cubic -d 1.2 -c -princ

#..SOLVATE
$gmx solvate -p bound.top -cp cubic-box.gro -cs spc216.gro -o cubic-box-solv.gro 

#..IONIZE
$gmx grompp -f MDP/ions.mdp -c cubic-box-solv.gro -p bound.top -o ions.tpr -maxwarn 1

#
ogro=cubic-box-solv-ions.gro
echo "SOL" | $gmx genion -s ions.tpr -o ${ogro} -p bound.top -pname NA -nname CL -neutral -conc 0.150

echo q | $gmx make_ndx -f ${ogro}

#..RUN DYNAMICS
$gmx grompp -f MDP/mini.mdp -c ${ogro} -p bound.top -o mini.tpr -maxwarn 2
$gmx mdrun -v -deffnm mini 
$gmx grompp -f MDP/nvt.mdp -c mini.gro -p bound.top -o nvt.tpr -maxwarn 2
$gmx mdrun -v -deffnm nvt -update gpu 
$gmx grompp -f MDP/npt.mdp -c nvt.gro -t nvt.cpt -p bound.top -o npt.tpr -maxwarn 2
$gmx mdrun -v -deffnm npt -update gpu
$gmx grompp -f MDP/prod.mdp  -c nvt.gro -t nvt.cpt -p bound.top -o prod.tpr -maxwarn 2
$gmx mdrun -v -deffnm prod -update gpu

#..Re-center traj
echo "2 System" |\
$gmx trjconv -f prod.xtc -s prod.tpr -o noPBC.xtc -pbc mol -ur compact -center
echo "2 System" |\
$gmx trjconv -f noPBC.xtc -s prod.tpr -o prod-center.xtc -fit rot+trans



#..CLEAN
#rm \#*
#rm TMP
exit
