#!/bin/bash

#..SOFTWARE
gmx=gmx

#..LOCAL variables
id=lig

#..PREPARE simulation BOX
ipdb=${id}.gro
echo "0" | $gmx editconf -f ${ipdb} -o cubic-box.gro -bt cubic -d 1.0 -c -princ

#..SOLVATE
cp ${id}.top unbound.top
itop=unbound.top
$gmx solvate -p ${itop} -cp cubic-box.gro -cs spc216.gro -o cubic-box-solv.gro 

#..IONIZE
$gmx grompp -f MDP/ions.mdp -c cubic-box-solv.gro -p ${itop} -o ions.tpr -maxwarn 2 
#
ogro=cubic-box-solv-ions.gro
echo "SOL" | $gmx genion -s ions.tpr -o ${ogro} -p ${itop} -pname NA -nname CL -neutral -conc 0.150

#..RUN DYNAMICS
$gmx grompp -f MDP/mini.mdp -c ${ogro} -p ${itop} -o mini.tpr -maxwarn 2
$gmx mdrun -v -deffnm mini  
$gmx grompp -f MDP/nvt.mdp -c mini.gro -p ${itop} -o nvt.tpr -maxwarn 2
$gmx mdrun -v -deffnm nvt -update gpu
$gmx grompp -f MDP/npt.mdp -c nvt.gro -t nvt.cpt -p ${itop} -o npt.tpr -maxwarn 2
$gmx mdrun -v -deffnm npt -update gpu
$gmx grompp -f MDP/prod.mdp  -c nvt.gro -t nvt.cpt -p ${itop} -o prod.tpr -maxwarn 2
$gmx mdrun -v -deffnm prod -update gpu


ligname=$(awk '/\[ molecules \]/{getline; getline; print $1}'  ../../INPUT/lig.top)
echo  'q' | gmx make_ndx -f prod.gro -o index.ndx
id=$(grep "\[" index.ndx  | sed -n "/${ligname}/q;p" | wc -l)

#..Re-center traj
echo "${id} System" |\
$gmx trjconv -f prod.xtc -s prod.tpr -o noPBC.xtc -pbc mol -ur compact -center
echo "${id} System" |\
$gmx trjconv -f noPBC.xtc -s prod.tpr -o prod-center.xtc -fit rot+trans



#..CLEAN
#rm \#*
#rm TMP
exit
