#!/usr/bin/perl -w
###########################################################################
#Rank the stx-stx alignments for each protein from sarf output for both correct and partial correct
#Input: linda_stx_stx.txt file, output file
#Output: prot 1, length 1, protein 2, length 2, match, identity in match,
#        rank 
#Author: Jianlin Cheng
#Date: 6/13/2005 
###########################################################################
sub round
{
     my $value = $_[0];
     $value *= 10000;
     $value = int($value + 0.5);
     $value /= 10000;
     return $value;
}

if (@ARGV != 3)
{
	die "need 3 params: stx-stx alignment file, length file,  output file.\n";
}
$align_file = shift @ARGV;
$len_file = shift @ARGV;
$rank_file = shift @ARGV;

print "read structure alignment file...\n";
open(ALIGN, $align_file) || die "can't read alignment file.\n";
$num = 0; 
while(<ALIGN>)
{
	$num++;
	push @align, $_;
	if ($num % 1000 == 0)
	{
		print "$num+";
	}
	if ($num >= 1858659)
	{
		last;
	}
}
close ALIGN;
print "done.";

open(RANK, ">$rank_file") || die "can't create ranking file.\n";

#gather the lengths for all uniq proteins
print "gather the lengths of proteins...";
%uniq_len = (); 
foreach $line (@align)
{
	if ($line =~ /^(\S+)\s+\(\s*(\d+)\)\s+(\S+)\s+\(\s*(\d+)\)\s+(\d+)\s+([\.\d]+) ([\d\.]+)\%\s+([\d\.]+)\%\s+/)
	{
		$prot1 = $1;
		$len1 = $2;
		$prot2 = $3;
		$len2 = $4;
		$afound = 0;
		$bfound = 0;
		foreach $prot (keys %uniq_len)
		{
			if ($prot eq $prot1)
			{
				$afound = 1;
			}
			if ($prot eq $prot2)
			{
				$bfound = 1; 
			}
			if ($afound == 1 && $bfound == 1)
			{
				last;
			}
		}
		if ($afound == 0)
		{
			$uniq_len{$prot1} = $len1; 
		}
		if ($bfound == 0)
		{
			$uniq_len{$prot2} = $len2; 
		}

	}
}
print "done.\n";
$size = keys %uniq_len;
print "total number of sequence: $size\n";

#add sequence length if it is not found in uniq_len
open(LEN, $len_file) || die "can't read length file.\n";
while (<LEN>)
{
	chomp $_;
	($prot_id, $prot_len) = split(/\s+/, $_);
	if (! exists $uniq_len{$prot_id} )
	{
		print "add length for $prot_id\n";
		$uniq_len{$prot_id} = $prot_len;
	}
}
close LEN; 


$first = 1;
@group = (); 
$pre_id = ""; 

while (@align)
{

	$title = shift @align;
	if ($title =~ /align pair: (\d+), (\d+)/)
	{
		$prot1 = $1;
		$prot2 = $2; 
	}
	else
	{
		die "format error, title: $title"; 
	}
	$line2 = shift @align;
	$partial_correct = 0; 

	if ($line2 =~ /failed/)
	{
		$correct = 0;	
	}
	else
	{
		$correct = 1; 
	}
	$line3 = shift @align;
	if ($line3 =~ /Ca-atoms/)
	{
		$partial_correct = 1;	
	}
	elsif ($line3 eq "\n")
	{
		next; 
	}
	$line4 = shift @align; 
	if ($line4 ne "\n")
	{
		die "format error, not empty: $line4";
	}


	if ($correct == 1)
	{
		chomp $line2;
		#field: 1:prot1, 2:length1, 3:prot2, 4:length3, 5:align_length, 
		#6:rmsd, 7:match 8:identity of match, other
		if ($line2 =~ /^(\S+)\s+\(\s*(\d+)\)\s+(\S+)\s+\(\s*(\d+)\)\s+(\d+)\s+([\.\d]+) ([\d\.]+)\%\s+([\d\.]+)\%\s+/)
		{
			$prot1 = $1;
			$len1 = $2;
			$prot2 = $3;
			$len2 = $4;
			$align_len = $5;
			$rmsd = $6;
			$match = $7;
			$ind = $8;
		}
		elsif ($line2 =~ /^(\S+)\s+\(\s*(\d+)\)\s+(\S+)\s+\(\s*(\d+)\)\s+(\d+)\s+(\d\.\d\d)([\d\.]+)\%\s+([\d\.]+)\%\s+/)
		{
			$prot1 = $1;
			$len1 = $2;
			$prot2 = $3;
			$len2 = $4;
			$align_len = $5;
			$rmsd = $6;
			$match = $7;
			$ind = $8;
			if ($match != 100)
			{
				die "format error: line2, $line2\n";
			}
			
		}
		else
		{
			die "format error, line2: $line2\n";
		}
	}
	elsif ($partial_correct == 1)
	{
		
		if ($line3 =~ /^\s*(\d+)\s+Ca-atoms\s+\(\s*(\d+)\%\),\s+rmsd\s+=\s+([\d\.]+),\s+(\d+)\%\s+/)
		{

			$align_len = $1;
			$match = $2;
			$rmsd = $3; 
			$ind = $4;
			$len1 = $uniq_len{$prot1};
			$len2 = $uniq_len{$prot2};
		}
		else
		{
			die "format error, line3: $line3";
		}
	}




	if ($first == 1)
	{
		$first = 0;
		$pre_id = $prot1; 
	}

	if ($prot1 eq $pre_id)
	{

		push @group, {
			prot1 => $prot1,
			prot2 => $prot2,
			match0 => &round($align_len / $len1),
			match => $match,
			ind => $ind,
			align_len => $align_len,
			len1 => $len1,
			len2 => $len2,
			rmsd => $rmsd
			};

	}
	else
	{
		if (@group > 0)
		{
			@sorted_group = sort {$b->{"match0"} <=> $a->{"match0"}} @group;

			for ($j = 0; $j <= $#sorted_group; $j++)
			{
				print RANK $sorted_group[$j]{"prot1"}, " ";
				print RANK $sorted_group[$j]{"prot2"}, " ";
				print RANK $j + 1, " ";
				print RANK $sorted_group[$j]{"match0"}, " ";
				print RANK $sorted_group[$j]{"match"}, " ";
				print RANK $sorted_group[$j]{"ind"}, " ";
				print RANK $sorted_group[$j]{"align_len"}, " ";
				print RANK $sorted_group[$j]{"len1"}, " ";
				print RANK $sorted_group[$j]{"len2"}, " ";
				print RANK $sorted_group[$j]{"rmsd"}, "\n"; 

			}
		}

		#start the next group
		@group = ();
		push @group, {
			prot1 => $prot1,
			prot2 => $prot2,
			match0 => &round($align_len / $len1),
			match => $match,
			ind => $ind,
			align_len => $align_len,
			len1 => $len1,
			len2 => $len2,
			rmsd => $rmsd
			};
		$pre_id = $prot1; 
	}
}

if (@group > 0)
{
	@sorted_group = sort {$b->{"match0"} <=> $a->{"match0"}} @group;
	for ($j = 0; $j <= $#sorted_group; $j++)
	{
		print RANK $sorted_group[$j]{"prot1"}, " ";
		print RANK $sorted_group[$j]{"prot2"}, " ";
		print RANK $j + 1, " ";
		print RANK $sorted_group[$j]{"match0"}, " ";
		print RANK $sorted_group[$j]{"match"}, " ";
		print RANK $sorted_group[$j]{"ind"}, " ";
		print RANK $sorted_group[$j]{"align_len"}, " ";
		print RANK $sorted_group[$j]{"len1"}, " ";
		print RANK $sorted_group[$j]{"len2"}, " ";
		print RANK $sorted_group[$j]{"rmsd"}, "\n"; 
	}
			
}

close RANK; 
