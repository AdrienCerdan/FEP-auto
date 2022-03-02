#!/bin/bash
#SBATCH -A 
#SBATCH --job-name=dlambda           # nom du job
#SBATCH --ntasks=1                   # nombre total de taches (= nombre de GPU ici)
#SBATCH --gres=gpu:1                 # nombre de GPU (1/4 des GPU)
#SBATCH --cpus-per-task=10           # nombre de coeurs CPU par tache (1/4 du noeud 4-GPU)
#SBATCH --time=02:00:00              # temps maximum d'execution demande (HH:MM:SS)
#SBATCH --output=gpu_mono%j.out      # nom du fichier de sortie
#SBATCH --error=gpu_mono%j.out       # nom du fichier d'erreur (ici commun avec la sortie)
 
# nettoyage des modules charges en interactif et herites par defaut
module purge
 
# chargement des modules
#module load gcc/8.3.1 cuda/10.2 cmake/3.18.0
#gmx=/linkhome/rech/genicb01/ucp63ff/gromacs-2021/build/bin/gmx

module load gromacs/2020.4-cuda 

gmx=gmx

# echo des commandes lancees
set -x
 
# execution du code
d=dlambda
d1=$(basename $d)
lam="${d1##*.}"
cd $d
mkdir ENMIN
cd ENMIN
$gmx grompp   -f ../../MDP/ENMIN/enmin.$lam.mdp -c ../../complex.gro -p ../../complex.top -o enmin.tpr -maxwarn 1
$gmx mdrun -v -stepout 1000 -s enmin.tpr -deffnm enmin -ntmpi 1 -ntomp 10 

cd ../
mkdir NVT
cd NVT
$gmx  grompp   -f ../../MDP/NVT/nvt.$lam.mdp -c ../ENMIN/enmin.gro -p ../../complex.top -o nvt.tpr -maxwarn 1
$gmx mdrun -stepout 1000 -s nvt.tpr -deffnm nvt -v  -ntmpi 1 -ntomp 10 

cd ../
mkdir NPT
cd NPT
$gmx  grompp   -f ../../MDP/NPT/npt.$lam.mdp -c ../NVT/nvt.gro -t ../NVT/nvt.cpt -p ../../complex.top -o npt.tpr -maxwarn 1
$gmx  mdrun -stepout 1000 -s npt.tpr -deffnm npt  -v  -ntmpi 1 -ntomp 10 

cd ../
mkdir PROD
cd PROD
$gmx  grompp   -f ../../MDP/PROD/prod.$lam.mdp -c ../NPT/npt.gro -t ../NPT/npt.cpt -p ../../complex.top -o prod.tpr -maxwarn 1
$gmx  mdrun -stepout 1000 -s prod.tpr -deffnm prod  -dhdl dhdl -v -ntmpi 1 -ntomp 10 

cd ../../
