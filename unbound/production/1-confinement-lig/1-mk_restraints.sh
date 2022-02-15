kk=1000

#echo -e '0 & !a H*\n name 3 lig_noH\n q' | gmx make_ndx -f ref_ligand.pdb -o index_lig.ndx
echo -e '0\n name 3 lig_H\n q' | gmx make_ndx -f ref-ligand.pdb -o index_lig.ndx


#echo -e 'lig_noH\n q' | gmx genrestr -f ref_ligand.pdb  -n index_lig.ndx -constr -o posre.itp
echo -e 'lig_H\n q' | gmx genrestr -f ref-ligand.pdb  -n index_lig.ndx -constr -o posre.itp

sed -i 's/constraints/bonds/g' posre.itp

echo | awk -v var="$kk" '{print var}'

awk ' {if (NR<4) { print}}' posre.itp  > posre_fix.itp
awk ' {if (NR==4) {$5="dist"; $6="k"; print}}' posre.itp >> posre_fix.itp
awk -v var="$kk" '{if (NR>4) { $3=6; $5=var;print}}' posre.itp >> posre_fix.itp


awk ' {if (NR<4) { print}}' posre_fix.itp > posre_FEP.itp
awk ' {if (NR==4) {$5="distA"; $6="kA"; $7="distB"; $8="kB" ; print}}' posre_fix.itp >> posre_FEP.itp
awk -v var="$kk" '{if (NR>4) { $3=6; $5=0; $6=$4 ; $7=var ;print}}'  posre_fix.itp >> posre_FEP.itp


if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    ligname=$(awk '/\[ molecules \]/{getline; getline;print $1}'  ligand.top)
    echo "default LIGNAME = $ligname"
else
    echo "Argument found!"
    echo "Ligname will be: $1"
    ligname=$1
fi



if grep -q posre_lig.itp complex.top; then
    echo "found, do nothing"
else
    echo "not found, will add the restraints to complex.top"
    sed -i --follow-symlinks "/${ligname}.itp/a \#include \"posre_lig.itp\"" ligand.top
fi

