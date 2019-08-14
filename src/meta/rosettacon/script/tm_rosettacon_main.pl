#!/usr/bin/perl -w
###############################################################################
#This is the main entry script for protein structure prediction server
#Inputs: option file, query file(fasta), output dir
#New version: starte date: 1/10/2009
#########################################################################

#####################Read Input Parameters###################################
if (@ARGV <3)
{
	die "need three parameters: option file, query file(fasta), output dir\n";
}

$option_file = shift @ARGV;
$query_file = shift @ARGV;
$output_dir = shift @ARGV;
$contact_file = shift @ARGV;; # optional

if(!defined($contact_file))
{
        $contact_file='None';
}

#convert output_dir to absolute path if necessary
-d $output_dir || die "output dir doesn't exist.\n";
use Cwd 'abs_path';
$output_dir = abs_path($output_dir);
$query_file = abs_path($query_file);
############################################################################

###################Preprocessing of Inputs###################################
#read option file
open(OPTION, $option_file) || die "can't read option file.\n";

$local_model_num = 50;

#$contact_file = "";

$tm_score = "/storage/htc/bdm/jh7x3/multicom/tools/tm_score/TMscore_32";

$q_score = "/storage/htc/bdm/jh7x3/multicom/tools/pairwiseQA/q_score";

while (<OPTION>)
{
	$line = $_; 
	chomp $line;

	if ($line =~ /^meta_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$meta_dir = $value; 
	}

	if ($line =~ /^prosys_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$prosys_dir = $value; 
	}

	if ($line =~ /^tm_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$tm_score = $value; 
	}

	if ($line =~ /^q_score/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$q_score = $value; 
	}

	if ($line =~ /^rosettacon_dir/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosettacon_dir = $value; 
	}

	if ($line =~ /^rosettacon_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosettacon_program = $value; 
	}

	if ($line =~ /^rosetta_program/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$rosetta_program = $value; 
	}

	#if ($line =~ /^contact_file/)
	#{
	#	($other, $value) = split(/=/, $line);
	#	$value =~ s/\s//g; 
	#	$contact_file = $value; 
	#}

	if ($line =~ /^max_wait_time/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$max_wait_time = $value; 
	}


	if ($line =~ /^local_model_num/)
	{
		($other, $value) = split(/=/, $line);
		$value =~ s/\s//g; 
		$local_model_num = $value; 
	}
}

close OPTION; 

#check the options
-d $meta_dir || die "can't find $meta_dir.\n";
-d $prosys_dir || die "can't find $prosys_dir.\n";
-d $rosettacon_dir || die "can't find $rosettacon_dir.\n";
-f $rosettacon_program || die "can't find $rosettacon_program.\n";
-f $rosetta_program || die "can't find $rosetta_program.\n";
$max_wait_time > 10 && $max_wait_time < 600 || die "waiting time is out of range.\n";

#get query name and sequence 
open(FASTA, $query_file) || die "can't read fasta file.\n";
$query_name = <FASTA>;
chomp $query_name; 
$qseq = <FASTA>;
chomp $qseq;
close FASTA;

#rewrite fasta file if it contains lower-case letter
if ($qseq =~ /[a-z]/)
{
	print "There are lower case letters in the input file. Convert them to upper case.\n";
	$qseq = uc($qseq);
	open(FASTA, ">$query_file") || die "can't rewrite fasta file.\n";
	print FASTA "$query_name\n$qseq\n";
	close FASTA;
}

if ($query_name =~ /^>/)
{
	$query_name = substr($query_name, 1); 
}
else
{
	die "fasta foramt error.\n"; 
}
####################End of Preprocessing of Inputs#############################

chdir $output_dir; 

#directory containing models to be generated by Rosetta-DNCON2
$model_dir = "$output_dir/rosetta_results_$query_name/";

#####################################################
#
#Wait for external DNCON2 to make contact predictions
#wait for at most 4 fours?
#
#####################################################

if (1)   #if a contact file exists
{

	print "Generate models using Rosetta with contacts...\n";

	system("$rosettacon_program $query_name $query_file $output_dir $contact_file");

}
else
{
	#run Rosetta without contacts
	print "Generate models using Rosetta without contacts...\n";
	system("$rosetta_program $query_name $query_file $output_dir");
}

#reformat the top five models
$model_num = 5; 
my $i = 0; 
open(SEL, ">selected_models"); 
for ($i = 1; $i <= $model_num; ++$i)
{
	my $model_name = $model_dir . "Rosetta_dncon2-" . $i . ".pdb";
	if (! -f $model_name)
	{
		last;
	}
	`cp $model_name rocon$i.pdb`; 

	###########Chain chain id from "A" to " "#################### 	
	open(AB, "rocon$i.pdb"); 
	@ab = <AB>;
	close AB;
	open(AB, ">rocon$i.pdb"); 
	while (@ab)
	{
		$line = shift @ab;
		if ($line =~ /^ATOM/)
		{
			$left = substr($line, 0, 21);
			$right = substr($line, 22);
			$record = "$left $right";
			print AB $record;
		}
	}		
	close AB;
					###############################################################

	print SEL "$model_name\trocon$i\n";		

}
close SEL; 

#self model rosetta models
system("$meta_dir/script/self_dir.pl $meta_dir/script/self.pl $output_dir");

