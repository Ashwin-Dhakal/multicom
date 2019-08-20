#!/bin/bash


if [ $# != 3 ]; then
        echo "$0 <target id> <fasta> <output-directory>"
        exit
fi

targetid=$1
fastafile=$2
outputdir=$3

mkdir -p $outputdir/novel
cd $outputdir


source /storage/hpc/scratch/jh7x3/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/storage/hpc/scratch/jh7x3/multicom/tools/boost_1_55_0/lib/:/storage/hpc/scratch/jh7x3/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

perl /storage/hpc/scratch/jh7x3/multicom/src/meta/novel/script/tm_novel_main.pl /storage/hpc/scratch/jh7x3/multicom/src/meta/novel/novel_option $fastafile novel  2>&1 | tee  novel.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/novel.log>\n\n"


if [[ ! -f "$outputdir/novel/novel1.pdb" ]];then 
	printf "!!!!! Failed to run novel, check the installation </storage/hpc/scratch/jh7x3/multicom/src/meta/novel/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: $outputdir/novel/novel1.pdb\n\n"
fi

