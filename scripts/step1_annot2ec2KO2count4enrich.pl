#!/usr/bin/perl -w
#jacques revised 28/02/2017

use strict;
use File::Basename;

#annot file from b2g:
#TR384|c0_g1_i1 GO:0045893  troponin slow skeletal muscle os=rattus norvegicus gn=tnni1 pe=1 sv=2
#TR384|c0_g1_i1 GO:0006874
#TR384|c0_g1_i1 GO:0055010
#TR384|c0_g1_i1 GO:0019901
#TR384|c0_g1_i1 GO:0031014
#TR384|c0_g1_i1 EC:2.7.1.1
#TR384|c0_g1_i1 GO:0003009

#input 2: afetr the run of "./get_ec2ko.sh"
#ec:1.1.1.60	ko:K00042
#ec:1.1.1.35	ko:K00022
#ec:1.1.1.35	ko:K01782
#ec:1.1.1.35	ko:K01825


#output:
#EC:1.1.1.1	K00001	12
#...
# with full match =>no EC:1.-.-.- ONLY the most specific EC mapped

my %ec2count=();
my $line=0;
my %patways=();
my %patwayscount=();
my $l0="";
my $l1="";
my $l2="";
my $l3="";
my $l4="";
my $l5="";
my @b=();

my $script= basename($0);
if (($#ARGV+1) != 4 ) {
		  print "usage: $script <in b2g annot (*.annot)> <in mapped EC2KO (*.ec2ko)> <in ko00001_new.csv> <outfile *.Pathways4enrichment.csv>\n";
		  exit(0);
}


my $annot=$ARGV[0]; # annot file;
my $fec2ko=$ARGV[1]; #file with list of ec:..\tKO:..\n
my $fKO2pathways=$ARGV[2]; #ko00001_new.csv
my $outpath=$ARGV[3]; #output path ";
my ($filebase,$dir,$ext) = fileparse($annot, qr/\.annot/);
my $outfile="${outpath}/${filebase}";

`mkdir -p $outpath`;
#---------------------------------------------------------------------------

############ read annot ###################
open(F,"<$annot") or die "no f\n";
while($line=<F>){
		  if($line =~ /EC:/){
					 chomp($line);
					 my @a=split(/\t/,$line);
					 $ec2count{$a[1]}++;
		  }
}
close(F);

# foreach my $ec (keys %ec2count){
# 	 if ($ec=~ /EC:3\.6\.3\.3/){
#                                 print "FOUND: EC:3.6.3.3=>$ec; ".$ec2count{$ec}."\n";
#                                 #exit (0);
#                         }
# 
# }

############ END read annot ##################

############  Read pathways ###################
open(F,"<$fKO2pathways") or die "no f\n";
while($line=<F>){
		  chomp($line);
		  if(length($line)>3){
					 my @a=split(/\t{1}/,$line);
					 if(exists($a[0]) && length($a[0])>2){
								$l0=$a[0];
					 }
					 if(exists($a[1]) && length($a[1])>2){
								$l1=$a[1];
					 }
					 if(exists($a[2]) && length($a[2])>2){
								$l2=$a[2];
								$patwayscount{$l0}{$l1}{$l2}=0;
					 }
					 if(exists($a[3]) && length($a[3])>2){
								$l3=$a[3];
								$l4=$a[4];
								$l5=$a[5];
								my $def="$l3\t$l4\t$l5";
								$patways{$l0}{$l1}{$l2}{$l3}{"def"}= $def;
								$patways{$l0}{$l1}{$l2}{$l3}{"ko_count"}=0;
					 }
		  }
}
close(F);
############### END read pathways ################


open (OUT,">${outfile}.ec2ko2cnt.csv") or die("no in file\n");
open(F,"<$fec2ko") or die "no file in\n";
#ec:1.1.1.1	ko:K00001
#   0           1
while($line=<F>){
		  chomp($line);
		  if(length($line)>3){
					 $line =~ s/ec:/EC:/g;
					 $line =~ s/[ \t]{1,}/\t/g;
					 my @a=split(/\t/,$line);
# less stringent:
# will be: `cut -f 1 $fec2count >list;grep -f list $fec2ko >ec2ko.txt; and then add count
					 if(exists($ec2count{$a[0]}) && exists($a[1])){
							#print "EC2KP\tec:".$a[0]."\tko:".$a[1]."\tcnt=".$ec2count{$a[0]}."\n";
								#if ($a[0]=~ /EC:3\.6\.3\.3/){
								#		  print "2: FOUND: EC:3.6.3.3=>$a[0] cnt=".$ec2count{$a[0]}."\n";
										  #exit (0);
								#}
								$a[1]=~ s/ko://g;
								print OUT "$a[0]\t$a[1]\t".$ec2count{$a[0]}."\n";

								foreach $l0 (sort keys %patways){
										  foreach $l1 (sort keys %{$patways{$l0}}){
													 foreach $l2 (sort keys %{$patways{$l0}{$l1}}){
																foreach $l3 (sort keys %{$patways{$l0}{$l1}{$l2}}){
																		  if($l3 eq $a[1]){
																					 $patways{$l0}{$l1}{$l2}{$l3}{"ko_count"} =$ec2count{$a[0]};
																					 $patwayscount{$l0}{$l1}{$l2} +=$ec2count{$a[0]};
#print "patwayscount\t[$l0]\t[$l1]\t[$l2]\t[$l3]\tec:".$a[0]."\tko:".$a[1]."\tcnt=".$ec2count{$a[0]}."\n";
																		  }
																}
													 }
										  }
								}
					 }
		  }
}
close(F);
close(OUT);

open (OUT,">${outfile}.Pathways.summary.txt") or die("no in file\n");
foreach $l0 (sort keys %patways){
		  print OUT "$l0\n";
		  foreach $l1 (sort keys %{$patways{$l0}}){
					 print OUT "\t$l1\n";
					 foreach $l2 (sort keys %{$patways{$l0}{$l1}}){
								if($patwayscount{$l0}{$l1}{$l2}>0){
										  print OUT "\t\t$l2\t".$patwayscount{$l0}{$l1}{$l2}."\n";
								}
					 }
		  }
}
close(OUT);

open (OUT,">${outfile}.Pathways4enrichment.csv") or die("no in file\n");
foreach $l0 (sort keys %patways){
		  foreach $l1 (sort keys %{$patways{$l0}}){
					 foreach $l2 (sort keys %{$patways{$l0}{$l1}}){
								if($patwayscount{$l0}{$l1}{$l2}>0){
										  print OUT "$l2\t".$patwayscount{$l0}{$l1}{$l2}."\n";
								}
					 }
		  }
}
close(OUT);

exit(0);

