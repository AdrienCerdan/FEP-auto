#!/bin/bash

gmx=gmx

if [ -z $1 ]; then
        echo "Parameter 1 is empty"
	echo "Use:"
	echo " ./1-measure-vba-gmx.sh avg"
	echo "or"
	echo "./1-measure-vba-gmx.sh cluster"
        exit 0
else
	avg=$1
fi

python pick.py && echo "picking finished"


L1=$(head -n 1 vba-auto.dat | awk -F, '{print $1}')
L2=$(head -n 1 vba-auto.dat | awk -F, '{print $2}')
L3=$(head -n 1 vba-auto.dat | awk -F, '{print $3}')
P1=$(head -n 1 vba-auto.dat | awk -F, '{print $4}')
P2=$(head -n 1 vba-auto.dat | awk -F, '{print $5}')
P3=$(head -n 1 vba-auto.dat | awk -F, '{print $6}')


if [ $avg == "avg" ]
then
	
	echo "Computing AVG"
	TRJ="../../build/prod-center.xtc"
	$gmx distance -f $TRJ -s ../../build/prod.tpr -oav -oallstat  -select "atomnr $L1 plus atomnr $P1"
else
	echo "Computing from cluster center"
	TRJ="../../build/ref-complex.gro"
	$gmx distance -f $TRJ -oav -oallstat  -select "atomnr $L1 plus atomnr $P1"
fi
	
cp templates/angles.ndx.template angles.ndx

sed -i "s/L1111/$L1/g" angles.ndx
sed -i "s/L2222/$L2/g" angles.ndx
sed -i "s/L3333/$L3/g" angles.ndx
sed -i "s/P1111/$P1/g" angles.ndx
sed -i "s/P2222/$P2/g" angles.ndx
sed -i "s/P3333/$P3/g" angles.ndx


echo 0 | $gmx angle -f $TRJ -n angles.ndx -od A1.xvg
echo 1 | $gmx angle -f $TRJ -n angles.ndx -od A2.xvg
echo 2 | $gmx angle -f $TRJ -n angles.ndx -od D1.xvg -type dihedral
echo 3 | $gmx angle -f $TRJ -n angles.ndx -od D2.xvg -type dihedral
echo 4 | $gmx angle -f $TRJ -n angles.ndx -od D3.xvg -type dihedral


R1=$(tail -n 1 diststat.xvg | awk '{print $2}')
A1=$(grep "average angle" A1.xvg | awk '{print $5}' | sed 's/\\.*//')
A2=$(grep "average angle" A2.xvg | awk '{print $5}' | sed 's/\\.*//')
D1=$(grep "average angle" D1.xvg | awk '{print $5}' | sed 's/\\.*//')
D2=$(grep "average angle" D2.xvg | awk '{print $5}' | sed 's/\\.*//')
D3=$(grep "average angle" D3.xvg | awk '{print $5}' | sed 's/\\.*//')



echo "==========="
echo $R1
echo $A1
echo $A2
echo $D1
echo $D2
echo $D3


cp templates/template_vba.txt vba_FEP.itp

sed -i "s/L1111/$L1/g" vba_FEP.itp
sed -i "s/L2222/$L2/g" vba_FEP.itp
sed -i "s/L3333/$L3/g" vba_FEP.itp
sed -i "s/P1111/$P1/g" vba_FEP.itp
sed -i "s/P2222/$P2/g" vba_FEP.itp
sed -i "s/P3333/$P3/g" vba_FEP.itp


sed -i "s/R1111/$R1/g" vba_FEP.itp
sed -i "s/A1111/$A1/g" vba_FEP.itp
sed -i "s/A2222/$A2/g" vba_FEP.itp
sed -i "s/D1111/$D1/g" vba_FEP.itp
sed -i "s/D2222/$D2/g" vba_FEP.itp
sed -i "s/D3333/$D3/g" vba_FEP.itp


cp templates/template_vba_fix.txt vba_fix.itp

sed -i "s/L1111/$L1/g" vba_fix.itp
sed -i "s/L2222/$L2/g" vba_fix.itp
sed -i "s/L3333/$L3/g" vba_fix.itp
sed -i "s/P1111/$P1/g" vba_fix.itp
sed -i "s/P2222/$P2/g" vba_fix.itp
sed -i "s/P3333/$P3/g" vba_fix.itp


sed -i "s/R1111/$R1/g" vba_fix.itp
sed -i "s/A1111/$A1/g" vba_fix.itp
sed -i "s/A2222/$A2/g" vba_fix.itp
sed -i "s/D1111/$D1/g" vba_fix.itp
sed -i "s/D2222/$D2/g" vba_fix.itp
sed -i "s/D3333/$D3/g" vba_fix.itp


if grep -q vba.itp complex.top; then
    echo "found, do nothing"
else
    echo "not found, will add restraints to complex.top"
    echo " " >> complex.top
    echo "#include \"vba.itp\" " >> complex.top
fi
