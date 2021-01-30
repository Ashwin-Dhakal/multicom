#!/usr/bin/perl -w
##########################################################################
#Evaluate structure models generated by multi-com
#Input: prosys_dir, model dir, output file 
#The following information will be generated:
#model_name, method(cm, fr, ab), top_template name, coverage,
#identity, blast-evalue, svm_score, hhs_score, com_score, 
#ss match score, sa match score, regular clashes, server clashes
#model_check score, model energy score, rank by model_check
#rank by model_energy, average rank
#Author: Jianlin Cheng
#Start date: 1/29/2008
##########################################################################  

sub round
{
	my $value = $_[0];
	$value = int($value * 100) / 100;
	return $value;
}

if (@ARGV != 5)
{
	die "need five parameters: prosys dir, model dir, target name, fasta file, output file.\n";
}

$prosys_dir = shift @ARGV;
$model_dir = shift @ARGV;
$target_name = shift @ARGV;
$fasta_file = shift @ARGV;
$out_file = shift @ARGV;

-d $prosys_dir || die "can't find $prosys_dir.\n";

@pdb2energy = ();
@pdb2mch = (); 

opendir(MOD, $model_dir) || die "can't read $model_dir for $target_name.\n";
@files = readdir MOD;
closedir MOD;
@pdb_files = ();
@models = ();
while (@files)
{
	$file = shift @files;
	if ($file =~ /(.+)\.pdb$/)
	{
		$prefix = $1;
	}
	else
	{
		next;
	}
	push @pdb_files, $file;


	if ($file =~ /cm(\d+)\.pdb/)
	{
		$method = "cm";
	}
	elsif ($file =~ /ab(\d+)\.pdb/)
	{
		$method = "ab";
	}
	else
	{
		$method = "fr";
	}

	$pir_file = "$model_dir/$prefix.pir";

	if (-f $pir_file)
	{
		open(PIR, $pir_file) || die "can't read $pir_file.\n";
		@pir = <PIR>;
		close PIR;
		if ($method eq "cm")
		{
			$comment = $pir[0];
			@fields = split(/\s+/, $comment);
			$blast_evalue = $fields[11];
		}
		else
		{
			$blast_evalue = "N/A";
		}


		$title = $pir[1];
		chomp $title;
		@fields = split(/;/, $title);
		$temp_name = $fields[1];
		$talign = $pir[3];
		$qalign = $pir[$#pir];

		#get coverage and identity
		chomp $talign;
		chop $talign;

		chomp $qalign;
		chop $qalign;

		$qlen = 0;
		$align_len = 0;
		$coverage = 0;
		$identity = 0;

		$len = length($qalign);
		for ($i = 0; $i < $len; $i++)
		{
			$qaa = substr($qalign, $i, 1);	
			$taa = substr($talign, $i, 1);	

			if ($qaa ne "-")
			{
				$qlen++;
				if ($taa ne "-")
				{
					$align_len++;	
					if ($qaa eq $taa)
					{
						$identity++;
					}
				}
			}
		}

		$coverage = $align_len / $qlen;
		if ($align_len != 0)
		{
			$identity = $identity / $align_len;
		}
		else
		{
			$identity = 0; 
		}
	}
	else
	{
		#$coverage = "N/A";
		#$identity = "N/A";	
		#ab initio case
		$temp_name = "N/A";
		$coverage = 0;
		$identity = 0;
		$blast_evalue = "N/A";
	}
	
	if (defined $pdb2mch{$file})
	{
		$model_check = $pdb2mch{$file};
	}
	else
	{
		#not found
		print "$file model check score is not found.\n";
		$model_check = "0";
	}

	if (defined $pdb2energy{$file})
	{
		$model_energy = $pdb2energy{$file};
	}
	else
	{
		#not found
		print "$file model energy score is not found.\n";
		$model_energy = "0";
	}

	#get number of clashes
	$clash = 0;
	$servere = 0;
	$out = `$prosys_dir/script/clash_check.pl $fasta_file $model_dir/$file`; 
	if (defined $out)
	{
		@fields = split(/\n/, $out);
		while (@fields)
		{
			$line = shift @fields;
			if ($line =~ /^clash/)
			{
				$clash++;
			}
			if ($line =~ /^servere/ || $line =~ /^overlap/)
			{
				$servere++;
			}
		}
	}
	else
	{
		$clash = 0;
		$servere = 0;
	}

	push @models, {
		name => $file,
		method => $method,
		template => $temp_name,
		coverage => $coverage,
		identity => $identity,
	        blast_evalue => $blast_evalue, 
		reg_clashes => $clash,
		ser_clashes => $servere,
		model_check => 0,
		model_energy => 0,
		check_rank => 0, 
		energy_rank => 0,
		average_rank => 0
	} 
			
}

#sort by model check score
@sorted_models = sort {$b->{"identity"} <=> $a->{"identity"}} @models;
@sorted_models = sort {$b->{"coverage"} <=> $a->{"coverage"}} @models;
@rank_models = @sorted_models; 

open(OUT, ">$out_file");

print OUT "name\t\tmethod\ttemp\tcov\tident\tblast_e\tr_cla\ts_cla\n";
for ($i = 0; $i < @rank_models; $i++)
{

	print OUT $rank_models[$i]{"name"}, "\t";
	print OUT $rank_models[$i]{"method"}, "\t";
	print OUT $rank_models[$i]{"template"}, "\t";
	print OUT $rank_models[$i]{"coverage"}, "\t";
	print OUT $rank_models[$i]{"identity"}, "\t";
	print OUT $rank_models[$i]{"blast_evalue"}, "\t";
	print OUT $rank_models[$i]{"reg_clashes"}, "\t";
	print OUT $rank_models[$i]{"ser_clashes"}, "\n";
}
		
close OUT;


