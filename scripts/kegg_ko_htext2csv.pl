#!/usr/bin/perl -w
use strict;
use File::Basename;

#my $flist="ko00001.keg";
my %files=();
my $file="";
my %listGOs=();
my %GOs=();
my $line="";
my $x=0;
my @poub=();
my $head="";
my %Hpatways=();
my %HpatwaysID=();
my $pos = 0;
my $pathID="";
my $annotEC="";

my $script= basename($0);
if (($#ARGV+1) != 1 ) {
		  print "usage: $script <in kegg file in htext format (*.keg)> \n";
		  print "Downloaded from :http://www.genome.jp/kegg-bin/get_htext?ko00001.keg\n";
		  exit(0);
}

my $kegg=$ARGV[0]; # keg file
my ($filebase,$dir,$ext) = fileparse($kegg, qr/\.keg/);
my $outfile="${dir}/${filebase}.csv";


if(-z $kegg){
		  print "ERROR: You must get the keg file in in htext format (*.keg)\n";
		  print "from:http://www.genome.jp/kegg-bin/get_htext?ko00001.keg\n";
		  print "download the htext file\n";
		  print "Should be a *.keg file\n";
		  exit (0);
}

open (IN,"<$kegg") or die "ERROR: Could not open the keg file: $kegg\n";
open (OUT,">$outfile") or die "ERROR: Could not write file: $outfile\n";

while($line =<IN>){
		  chomp($line);

		  if($line =~ /^A<b>/){ #A<b>Metabolism</b>
					 $line=~ s/^A<b>(.*)<.*/$1/g;
					 print OUT "$line\n";
		  }elsif($line =~ /^B[\t ]{1,}<b>/){ #B  <b>Overview</b>
					 $line=~ s/^B[\t ]{1,}<b>(.*)<.*/$1/g;
					 print OUT "\t$line\n";
		  }elsif($line =~ /^C[\t ]{1,}/){ #C    01200 Carbon metabolism [PATH:ko01200]
					 $line=~ s/^C[\t ]{1,}//g;
					 print OUT "\t\t$line\n";
		  }elsif($line =~ /^D[\t ]{1,}/){ #D      K00844  HK; hexokinase [EC:2.7.1.1]
					 $line=~ s/^D[\t ]{1,}//g;
					 $line=~ s/^(\w{2,})[ \t]{1,}/$1\t/g;
					 $line=~ s/;[ \t]{1,}/\t/g;
					 print OUT "\t\t\t$line\n";
		  }
}

close(IN);
close(OUT);
print "OK: File formated: $outfile\n";
exit(0);

