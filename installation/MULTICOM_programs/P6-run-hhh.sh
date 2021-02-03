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

mkdir -p $outputdir/hhh

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/script/tm_hhsu_hhbl_main.pl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhsuite/hhsu_hhbl_option $fastafile hhh  2>&1 | tee  hhh.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/hhh.log>\n\n"


if [[ ! -f "$outputdir/hhh/hhh1.pdb" ]];then
	printf "!!!!! Failed to run hhh, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/hhh/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/hhh/hhh1.pdb $outputdir/$targetid.pdb
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi
