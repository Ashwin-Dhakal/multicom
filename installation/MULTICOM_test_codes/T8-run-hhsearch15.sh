#!/bin/bash

dtime=$(date +%m%d%y)


mkdir -p /home/jh7x3/multicom/test_out/T1006_hhsearch15/
cd /home/jh7x3/multicom/test_out/T1006_hhsearch15/

mkdir hhsearch15

touch /home/jh7x3/multicom/test_out/T1006_hhsearch15.running
if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb" ]];then 
	perl /home/jh7x3/multicom/src/meta/hhsearch1.5/script/tm_hhsearch1.5_main_v2.pl /home/jh7x3/multicom/src/meta/hhsearch1.5/hhsearch1.5_option /home/jh7x3/multicom/examples/T1006.fasta hhsearch15  2>&1 | tee  /home/jh7x3/multicom/test_out/T1006_hhsearch15.log
fi


printf "\nFinished.."
printf "\nCheck log file </home/jh7x3/multicom/test_out/T1006_hhsearch15.log>\n\n"


if [[ ! -f "/home/jh7x3/multicom/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb" ]];then 
	printf "!!!!! Failed to run hhsearch15, check the installation </home/jh7x3/multicom/src/meta/hhsearch1.5/>\n\n"
else
	printf "\nJob successfully completed!"
	printf "\nResults: /home/jh7x3/multicom/test_out/T1006_hhsearch15/hhsearch15/ss1.pdb\n\n"
fi

rm /home/jh7x3/multicom/test_out/T1006_hhsearch15.running