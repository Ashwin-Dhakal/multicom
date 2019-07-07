#!/bin/bash
#SBATCH -J  rosetta
#SBATCH -o rosetta-%j.out
#SBATCH --partition Lewis,hpc5,hpc4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=5
#SBATCH --mem-per-cpu=2G
#SBATCH --time 2-00:00

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_rosetta/
cd /home/jh7x3/multicom/test_out/T1006_rosetta/

mkdir rosetta2
mkdir rosetta_common

touch /home/jh7x3/multicom/test_out/T1006_rosetta.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_rosetta/rosetta2/abini/abini-1.pdb" ]];then 
	sh /home/jh7x3/multicom/src/meta/script/make_rosetta_fragment.sh /home/jh7x3/multicom/examples/T1006.fasta abini  rosetta_common 100 2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_rosetta.log
	cp -r rosetta_common/abini rosetta2
	sh /home/jh7x3/multicom/src/meta/script/run_rosetta_no_fragment.sh /home/jh7x3/multicom/examples/T1006.fasta abini rosetta2 100  2>&1 | tee  -a /home/jh7x3/multicom/test_out/T1006_rosetta.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_rosetta.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_rosetta/rosetta2/abini/abini-1.pdb" ]];then 
	printf "!!!!! Failed to run rosetta, check the installation </home/jh7x3/multicom/src/meta/script/run_rosetta_no_fragment.sh>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_rosetta/rosetta2/abini/abini-1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_rosetta.running
