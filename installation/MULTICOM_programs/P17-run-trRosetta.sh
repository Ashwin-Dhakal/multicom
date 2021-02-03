#!/bin/bash

if [ $# != 3 ]; then
	echo "$0 <target id> <fasta> <output-directory>"
	exit
fi

targetid=$1
fastafile=$2
outputdir=$3

mkdir -p $outputdir
cd $outputdir

if [[ "$fastafile" != /* ]]
then
   echo "Please provide absolute path for $fastafile"
   exit
fi

if [[ "$outputdir" != /* ]]
then
   echo "Please provide absolute path for $outputdir"
   exit
fi

mkdir -p $outputdir/trrosetta

cd $outputdir

sh /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/trRosetta/scripts/run_trRosetta_v3.sh $targetid $fastafile 0.05 0.55 0.05 5 $outputdir/disthbond/ $outputdir/trrosetta/  2>&1 | tee  trrosetta.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/trrosetta.log>\n\n"


if [[ ! -f "$outputdir/trrosetta/trRosetta1.pdb" ]];then
        printf "!!!!! Failed to run trRosetta, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/tools/trRosetta/>\n\n"
else
        printf "\nJob successfully completed!"
        cp $outputdir/trrosetta/trRosetta1.pdb $outputdir/$targetid.pdb
        printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi