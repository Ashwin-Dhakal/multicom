#!/usr/bin/perl -w
##########################################################################
#Use LOBSTER(COACH) to create hhm  and fasta profiles from msa and query 
#input: script dir, lobster dir, query file(fasta), query(msa), output file
#Author: Jianlin Cheng
#Modified from msa2hmm.pl
#Date: 7/26/2005
##########################################################################
if (@ARGV != 5)
{
	die "need five parameters: script dir, lobster dir(lobster), query file(fasta), query msa(from blast), output file.\n";
}
$script_dir = shift @ARGV;
$lobster_dir = shift @ARGV;
-d $script_dir || die "can't find script dir.\n";
-d $lobster_dir || die "can't find lobster dir.\n";

$query_fasta = shift @ARGV;
-f $query_fasta || die "can't find query fasta file.\n";
open(QUERY, $query_fasta);
$code1 = <QUERY>;
chomp $code1; 
$code1 = substr($code1, 1);
$seq1 = <QUERY>;
chomp $seq1; 
close QUERY;

$query_msa = shift @ARGV;
-f $query_msa || die "can't find query msa file.\n";

$out_file = shift @ARGV;

#convert fasta and msa to gde format multiple alignments
system("$script_dir/msa2gde.pl $query_fasta $query_msa fasta $query_msa.fas");

#remove non-standard amino acids if necessary
system("$script_dir/check_amino_acids.pl $query_msa.fas");

#create hmm from msa
system("$lobster_dir/lobster -msa2hmm  $query_msa.fas -hmm $out_file >/dev/null"); 

### check if lobster output is generated. Sometimes lobster will fail when too many alignments are found
if(!(-e $out_file))
{
  print "Failed to generate lobster on $query_msa.fas, need filter the alignments\n\n";
  `cp $query_msa.fas $query_msa.fas.filt0`;
  for($rep=1;$rep<=20;$rep++)
  {
      if(-e $out_file)
      {
        last;
      }
      print "Trying $rep times' filtering\n\n";
      $prev = $rep -1;
      system("$script_dir/fas_reduce2half.pl $query_msa.fas.filt$prev $query_msa.fas.filt$rep");
      system("$lobster_dir/lobster -msa2hmm  $query_msa.fas.filt$rep -hmm $out_file >/dev/null");
  }
}

if(!(-e $out_file))
{
  print "Failed to generate $out_file, report error\n\n";
}


#also keep the fasta file.
$idx = rindex($out_file, "."); 
if ($idx >= 1)
{
	$fas_file = substr($out_file, 0, $idx);
	$fas_file .= ".fas";
}
else
{
	$fas_file = $out_file . ".fas"; 
}

#`rm $query_msa.fas`; 
`mv $query_msa.fas $fas_file`; 




