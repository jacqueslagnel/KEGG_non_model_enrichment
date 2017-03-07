#!/usr/bin/perl -w
#jacques revised 28/02/2017

use strict;
use Statistics::R ;
use File::Basename;

############################# KEGG enrichment Fisher's test and FDR correction ################################
my $wd=`pwd`;
chomp($wd);

my $script= basename($0);
if (($#ARGV+1) != 4 ) {
	print "usage: $script <Test.Pathways4enrichment.csv> <Reference.Pathways4enrichment.csv> <FDR thresshold (0.05)> <output path>\n";
	exit(0);
}

my $ftest=$ARGV[0]; #DE_AS_vs_S.UP.EC2KO2count.txt.Pathways4enrichment.csv
my $fref=$ARGV[1]; #ec2ko2contigcount.csv.Pathways4enrichment.csv
my $FDRcut=$ARGV[2];
my $outp=$ARGV[3];

my ($fbref,$dirr,$extr) = fileparse($fref, qr/\.Pathways4enrichment\.csv.*/);
my ($fbtest,$dirt,$extt) = fileparse($ftest, qr/\.Pathways4enrichment\.csv.*/);
my $outbase="${outp}/${fbtest}_VS_${fbref}";

my %list_test=();
my $test_total_count=0;
my $test_total_pathways=0;

my %list_ref=();
my $ref_total_count=0;
my $ref_total_pathways=0;

my $line=0;
my @a=();
my @fdrs=();
my $R = Statistics::R->new() ;
my $x=0;
my $kegg="";
my %matrix4R=();
my $Rout="";
my %list_kegg2pvalues=();

open(F,"<$ftest") or die "no f\n";
while($line=<F>){
	chomp($line);
	if(length($line)>3){
		@a=split(/\t/,$line);
		$list_test{$a[0]}=$a[1];
		$test_total_count +=$a[1];
		$test_total_pathways++;
	}
}
close(F);

$ref_total_count=0;
$ref_total_pathways=0;
open(F,"<$fref") or die "no f\n";
while($line=<F>){
	chomp($line);
	if(length($line)>3){
		@a=split(/\t/,$line);
		$list_ref{$a[0]}=$a[1];
		$ref_total_count +=$a[1];
		$ref_total_pathways++;
	}
}
close(F);

if($test_total_pathways<1 || $ref_total_pathways<1){
	die("$ftest: $test_total_pathways\t$fref: $ref_total_pathways\n");
}
print "TEST\t$ftest\t$test_total_pathways\t$test_total_count\n";
print "REF\t$fref\t$ref_total_pathways\t$ref_total_count\n";
foreach $kegg (sort keys  %list_test){
	if(exists($list_ref{$kegg})){
		############ NO common removal #############################
		#$matrix4R{$kegg}=$list_test{$kegg}.", $test_total_count, ".$list_ref{$kegg}.", $ref_total_count";
		############ ONLY common removal in reference set ##########
		#$matrix4R{$kegg}=$list_test{$kegg}.", $test_total_count, ".$list_ref{$kegg}.", ".$list_ref{$kegg}.", ".($ref_total_count-$list_ref{$kegg});
		############ BOTH set and ref common removal ###############
		$matrix4R{$kegg}=$list_test{$kegg}.", ".($test_total_count-$list_test{$kegg}).", ".$list_ref{$kegg}.", ".($ref_total_count-$list_ref{$kegg});
	}
}

$R->startR;
$R->send("library(multtest)");
$line="";
foreach $kegg (sort keys  %matrix4R){
	my $mat=$matrix4R{$kegg};
	$R->send("counts = (matrix(data = c($mat), nrow = 2))");
	$R->send('ft<-fisher.test(counts)');
	$R->send('ftp=ft$p.value');
	$R->send('cat(sprintf("%.10e",ftp))');
	$Rout = $R->read;
	$line .="$Rout, ";
	$list_kegg2pvalues{$kegg}{"raw"}=$Rout;
	push(@a,$list_kegg2pvalues{$kegg}{"raw"});
}
$line =~ s/, $//g;
$R->send("vpval <- c($line)");
$R->send('res = mt.rawp2adjp(vpval, "BH")');
$R->send('adjp = res$adjp[order(res$index),]');
$R->send('print(adjp)');
@fdrs = split(/\n/,$R->read);
##################  the rejected by alpha values #######################
#$R->send('mt.reject(adjp, seq(0,1, 0.05))$r');
#$Rout = $R->read;
#print OUT "\nrejected ->[$Rout]\n";
#########################################################################
#my $outfile="${wd}/${filebase}.KEGGenrichment_fisher_FDR5.csv.txt";
open (OUT,">${outbase}.KEGGenrichment_fisher_FDR5.csv") or die ("no W file\n");
$x=1;
print OUT "KeggID\tKegg Patways\tKo ID\t%test\t%ref\t#Test\t#notAnnotTest\t#Ref\t#notAnnotRef\tp-value\tFDR\tOver\\Under represented\n";
foreach $kegg (sort keys  %matrix4R){
	# for KEGG defs
	my $tablekegg=$kegg;
	$tablekegg=~s/ /\t/;
	$tablekegg=~s/ \[PATH:(.*)\].*/\t$1/g;
	
	# for FDR ->"  [1,] 1.000000e+00 1.000000e+00"
	$fdrs[$x]=~ s/.*\] {1,}//g;
	$fdrs[$x]=~ s/[, ]{1,}/,/g;
	
	# for the matrix + fdrs
	my $table=$matrix4R{$kegg}.",".$fdrs[$x];
	$table=~ s/ //g;

	@a=split(/[, \t]/,$table);
	if($a[5]<$FDRcut){
		my $pseqs_test=0.0;
		my $pseqs_ref=0.0;
		$pseqs_test=100.00/(int($a[0])+int($a[1]))*int($a[0]);
		$pseqs_ref=100.00/(int($a[2])+int($a[3]))*int($a[2]);
		$table="";
		foreach my $fval (@a){
			$table .="\t$fval";
		}
		if($pseqs_test >= $pseqs_ref){
			$table .="\tOver";
		}else{
			$table .="\tUnder";		
		}
		print OUT "$tablekegg\t$pseqs_test\t$pseqs_ref$table\n";
	}
	$x++;
}

exit(0);

