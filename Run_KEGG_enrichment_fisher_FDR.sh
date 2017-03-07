#!/bin/bash
#jacques revised 28/02/2017

#if [ "$#" -lt 7 ]
#then
#echo "Do KEGG enrichment test vs reference from b2g annotated contigs"
#echo "usage: $0 <annot ref (*.annot)> <annot to test (*.annot)> <kegg all ec2ko (kegg_all_ec2ko.tmp)> <KEGG pathways in csv> <FDR cutoff value> <Do again format ref? [Y|N]> <output path>"
#exit 0
#fi
if [ "$#" -lt 6 ]
then
echo "Do KEGG enrichment test vs reference from b2g annotated contigs"
echo "usage: $0 <annot ref (*.annot)> <annot to test (*.annot)> <kegg all ec2ko (kegg_all_ec2ko.tmp)> <KEGG pathways in csv> <FDR cutoff value> <output path>"
exit 0
fi


annotref=$1
annottest=$2
kegg_all_ec2ko=$3
ko00001=$4
fdr=$5
outppath=$6
#doref=$6 #N or Y. N if we have done it before
#outppath=$7

#annotref=inputs/Pagellus_blast2go_annotation_InterPro_Goslim_enzyme.annot
#annottest=inputs/pagellus_female_gonads_lfch2_uniq_trascript_ids.annot
#kegg_all_ec2ko=kegg_data/kegg_all_ec2ko.csv.cor
#ko00001=kegg_data/ko00001_new.csv
#outppath=output_Vd
#fdr=0.05

pipd=$0
pipd=${pipd%/*}
wd=`pwd`
scriptspath=${pipd}/scripts


########### run 4 reference data set
doref=1
if [ "$doref" = 1 ]
then

echo "generating pathways for the ref"
${scriptspath}/step1_annot2ec2KO2count4enrich.pl $annotref $kegg_all_ec2ko $ko00001 $outppath
fi

########### run 4 test ################i
echo "generating pathways for the test"
${scriptspath}/step1_annot2ec2KO2count4enrich.pl $annottest $kegg_all_ec2ko $ko00001 $outppath


############ run enrichment test VS ref #################################
base=${annotref%%.annot}
refnue=${base##*/}
base=${annottest%%.annot}
testnue=${base##*/}
#<Test.Pathways4enrichment.csv> <Reference.Pathways4enrichment.csv> <FDR thresshold (0.05)> <output path>
${scriptspath}/Step2_KEGGenrichment_fisher_FDR_R.pl \
${outppath}/${testnue}.Pathways4enrichment.csv \
${outppath}/${refnue}.Pathways4enrichment.csv \
$fdr \
$outppath

exit 0


