#!/bin/bash

if [ $# != 3 ]; then
        echo "$0 <target id> <fasta> <output-directory>"
        exit
fi

targetid = $1
fastafile = $2
outputdir = $3

mkdir -p $outputdir/deepsf
cd $outputdir


source /storage/hpc/scratch/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/hpc/scratch/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/hpc/scratch/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH


perl /storage/hpc/scratch/jh7x3/multicom/src/meta/deepsf/script/tm_deepsf_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/deepsf/deepsf_option $fastafile deepsf  2>&1 | tee  $outputdir/deepsf.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/deepsf.log>\n\n"


if [[ ! -f "$outputdir/deepsf/deepsf1.pdb" ]];then 
	printf "!!!!! Failed to run deepsf, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/deepsf/>\n\n"
else
	printf "\nJob successfully completed!"
	cp $outputdir/deepsf/deepsf1.pdb $outputdir/$targetid.pdb 
	printf "\nResults: $outputdir/deepsf/deepsf1.pdb\n\n"
fi

