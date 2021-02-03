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

mkdir -p $outputdir/disthbond

cd $outputdir

perl /storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/DeepHbond/lib/run_deephbond.py -f $fastafile -o $outputdir/disthbond/  2>&1 | tee  disthbond.log

printf "\nFinished.."
printf "\nCheck log file <$outputdir/disthbond.log>\n\n"


if [[ ! -f "$outputdir/disthbond/$targetid.hbond.tbl" ]]
then
    printf "!!!!! Failed to run DeepHbond, check the installation </storage/htc/bdm/tianqi/test/MULTICOM2/multicom/src/DeepHbond/>\n\n"
fi