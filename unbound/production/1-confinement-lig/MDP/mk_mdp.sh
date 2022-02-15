#!/bin/bash
# makes multiple mdp files substituting '$LAMBDA$'
# ./mklambdas.sh vwd|coul|restraints
# $1 = which lambda vector

rm -rf ENMIN/ NPT/ NVT/ PROD/
#ligname=$(awk '{if (NR==2) {print $4} }' ../ref_ligand.pdb)
#ligname=$(awk '/\[ molecules \]/{getline; getline; print $1}'  ../ligand.top)
ligname=""
t="bonded" 

for mdp in *.mdp
do
	#Nlambdas=`cat $mdp | grep $1-lambdas | wc -w`
	Nlambdas=`cat $mdp | grep $t-lambdas | wc -w`
	Nlambdas=`expr $Nlambdas - 2`

	filename=$(basename "$mdp")
	filename="${filename%.*}"

	newdirname=`printf $filename | tr '[:lower:]' '[:upper:]'`
	newdir=`printf "%s" $newdirname`
	echo "Making directory $newdirname"
	mkdir -p ${PWD}/$newdirname

	i=0
	while [ $i -lt $Nlambdas ]
	do
	    	new_filename=`printf "%s.%02d.mdp" $filename $i`
	    	echo "Writing file $new_filename"

    		sed "s/\\\$LAMBDA\\\$/${i}/" $mdp > $newdirname/$new_filename
    		sed -i "s/XXXX/${ligname}/" $newdirname/$new_filename
	    	i=`expr $i + 1`
	done
done
