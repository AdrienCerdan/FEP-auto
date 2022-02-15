#!/bin/bash

if [ ! -d "MDP/PROD" ]; then
	cd MDP/
	./mk_mdp.sh
	cd ../
fi



i=0
name="lambda"
Nlambdas=$(ls MDP/PROD/* |  wc -l )
while [ $i -lt $Nlambdas ]
do
	new_dirname=`printf "%s.%02d" $name $i`	
	echo "mkdir: $new_dirname"
	mkdir -p ${PWD}/$new_dirname
	i=`expr $i + 1`
done
