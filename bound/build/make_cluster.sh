gmx=gmx


if [ $# -eq 0 ]
  then
    echo "Usage: ./make_cluster.sh  # run default ligand and cuttof"
    echo "Usage: ./make_cluster.sh  \$cutoff \$ligname # run with user specific cutoff for clustering and specific ligname"

    echo "No arguments supplied"
    ligname=$(awk '/\[ molecules \]/{getline; getline; getline; print $1}'  bound.top)
    cutoff=0.08
    echo "default LIGNAME = $ligname"
    echo "default cutoff clustering = $cutoff"
elif [ $# -eq 1 ]
  then
    echo "User specified cutoff:"
    echo $1
    cutoff=$1
    echo "cutoff clustering = $cutoff"
    ligname=$(awk '/\[ molecules \]/{getline; getline; getline; print $1}'  bound.top)
    echo "default LIGNAME = $ligname"
else
   echo "User specified cutoff:"
   echo $1
   cutoff=$1
   echo "cutoff clustering = $cutoff"
   echo "User specified ligname:"
   echo $2
   ligname=$2
   echo "LIGNAME = $ligname"
fi

# test if protein exist

echo  "q" | $gmx make_ndx -f prod.gro -o index_cluster.ndx
prot=$(grep " Protein " index_cluster.ndx | wc -l)
if [ $prot -eq 0 ]
	then
	echo "Welcome in the world of Host-Guest where proteins do not exist..."
	ligname=$(awk '/\[ molecules \]/{getline; getline; getline; print $1}'  bound.top)
	recname=$(awk '/\[ molecules \]/{getline; getline;  print $1}'  bound.top)

	#echo -e "\n q" | gmx make_ndx -f prod.gro -o index_cluster.ndx
	id=$(grep "\[" index_cluster.ndx  | sed -n "/${ligname}/q;p" | wc -l)
	idrec=$(grep "\[" index_cluster.ndx  | sed -n "/${recname}/q;p" | wc -l)

	echo -e "${idrec} | ${id}\n q" | $gmx make_ndx -f prod.gro -o index_cluster.ndx
	echo -e "${recname}_${ligname}\n ${recname}_${ligname}" | $gmx cluster -f prod-center.xtc -n index_cluster.ndx -s prod.tpr -dist -cutoff $cutoff -cl -method gromos
	sed -n '/MODEL        1/,/TER/p' clusters.pdb | head -n -1 | tail -n+2 > ref-complex.pdb
	echo -e "${recname}_${ligname}" | $gmx trjconv -f ref-complex.pdb -o ref-complex.gro -n index_cluster.ndx -s prod.tpr
	grep ${ligname} ref-complex.pdb > ref-ligand.pdb
else
	echo "Welcome in the world of Protein-Ligand..."
	#FOR Protein ligand complex BINDING-site clustering:

	#echo  "q" | $gmx make_ndx -f prod.gro -o index_cluster.ndx

	$gmx select -f prod.gro -on index-site.ndx -select "group Protein and not name \"H*\" and same residue as within 0.4 of resname $ligname" -s prod.tpr
	echo -e "name 0 site\n q" | $gmx make_ndx -n index-site.ndx -o index-site-num.ndx
	cat index-site-num.ndx >> index_cluster.ndx

	id=$(grep "\[" index_cluster.ndx  | sed -n "/${ligname}/q;p" | wc -l)
	siteid=$(grep "\[" index_cluster.ndx  | sed -n "/site/q;p" | wc -l)
	recid=$(grep "\[" index_cluster.ndx  | sed -n "/Protein/q;p" | wc -l)
	#recHid=$(grep "\[" index_cluster.ndx  | sed -n "/Protein-H/q;p" | wc -l)

	echo -e "${siteid}|${id}\n ${recid}|${id}\n q" | $gmx make_ndx -f prod.gro -o index_cluster.ndx -n index_cluster.ndx
	echo -e "site_${ligname}\n Protein_${ligname}" | $gmx cluster -f prod-center.xtc -n index_cluster.ndx -s prod.tpr -dist -cutoff $cutoff -cl -method gromos

	sed -n '/MODEL        1/,/TER/p' clusters.pdb | head -n -1 | tail -n+2 > ref-complex.pdb
	echo -e "Protein_${ligname}" | $gmx trjconv -f ref-complex.pdb -o ref-complex.gro -n index_cluster.ndx -s prod.tpr

	grep ${ligname} ref-complex.pdb > ref-ligand.pdb
fi




#################################################################################################################
# OLD VERSION

##########################################################################################################################################################################


# FOR host-guest and other:
# Add condition to check if protein exist in index or not

#ligname=$(awk '/\[ molecules \]/{getline; getline; getline; print $1}'  bound.top)
#recname=$(awk '/\[ molecules \]/{getline; getline;  print $1}'  bound.top)

#echo -e "\n q" | gmx make_ndx -f prod.gro -o index_cluster.ndx
#id=$(grep "\[" index_cluster.ndx  | sed -n "/${ligname}/q;p" | wc -l)
#idrec=$(grep "\[" index_cluster.ndx  | sed -n "/${recname}/q;p" | wc -l)



#echo -e "${idrec} | ${id}\n q" | gmx make_ndx -f prod.gro -o index_cluster.ndx
#echo -e "${recname}_${ligname}\n ${recname}_${ligname}" | gmx cluster -f prod-center.xtc -n index_cluster.ndx -s prod.tpr -dist -cutoff 0.03 -cl -method jarvis-patrick


#nRow=$(grep ${ligname} prod.gro | wc | awk '{print $1}')
#grep -A $nRow "MODEL        1" clusters.pdb | tail -$nRow > ref-ligand.pdb
