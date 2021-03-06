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

mkdir -p $outputdir/fusioncon

cd $outputdir
perl /home/jhou4/tools/multicom/src/meta/fusioncon/script/tm_fusioncon_main.pl /home/jhou4/tools/multicom/src/meta/fusioncon/fusioncon_option $fastafile fusioncon  2>&1 | tee  fusioncon.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/fusioncon.log>\n\n"


if [[ ! -f "$outputdir/fusioncon/fusicon1.pdb" ]];then 
	printf "!!!!! Failed to run fusioncon, check the installation </home/jhou4/tools/multicom/src/meta/fusioncon/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/fusioncon/fusicon1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/$targetid.pdb\n\n"
fi

