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


source /home/jhou4/tools/multicom/tools/python_virtualenv/bin/activate
export LD_LIBRARY_PATH=/home/jhou4/tools/multicom/tools/boost_1_55_0/lib/:/home/jhou4/tools/multicom/tools/OpenBLAS:$LD_LIBRARY_PATH

perl /home/jhou4/tools/multicom/src/meta/novel/script/tm_novel_main.pl /home/jhou4/tools/multicom/src/meta/novel/novel_option $fastafile novel  2>&1 | tee  novel.log


printf "\nFinished.."
printf "\nCheck log file <$outputdir/novel.log>\n\n"


if [[ ! -f "$outputdir/novel/novel1.pdb" ]];then 
	printf "!!!!! Failed to run novel, check the installation </home/jhou4/tools/multicom/src/meta/novel/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: $outputdir/novel/novel1.pdb\n\n"
fi

