#!/usr/bin/perl -w
#jacques revised 28/02/2017

use strict;
use File::Basename;

############################# "EC:number\tcount" -> KO ->KoPATHWAYS ###########################################

my $script= basename($0);
if (($#ARGV+1) != 3 ) {
        print "usage: $script <in DE contigs IDs list> <in full annot from b2g> <outpath>\n";
        exit(0);
}

my $line=0;
my %annot2EC=();

my $ids=$ARGV[0]; #contigs IDs list
my $annot=$ARGV[1]; # full annot file from g2g
my $outpath=$ARGV[2]; #output path

my ($filebase,$dir,$ext) = fileparse($ids, qr/\..*/);
my $wd=`pwd`;
chomp($wd);
my $outfilebase="${outpath}/$filebase";

#print "[$filebase][$dir][$ext]\n";
#print "[$outfilebase]\n";

open(F,"<$annot") or die "no f\n";

while($line=<F>){
	if($line =~ /EC:/){
		chomp($line);
		my @a=split(/[ \t]{1,}/,$line);
		$annot2EC{$a[0]}=$a[1];
	}
}
close(F);

open(OUT,">${outfilebase}.annot") or die "no f\n";
open(F,"<$ids") or die "no f\n";
while($line=<F>){
	chomp($line);
	my @a=split(/[ \t]{1,}/,$line);
	if(exists($annot2EC{$a[0]})){
		print OUT $a[0],"\t",$annot2EC{$a[0]},"\n";
	}
}
close(F);
close(OUT);

exit(0);

