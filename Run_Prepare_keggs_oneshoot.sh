#!/bin/bash
#jacques revised 28/02/2017

#1)
#from:http://www.genome.jp/kegg-bin/get_htext?ko00001.keg
#select "Reference Hierarchy (KO)"
#download the htext file
#Should be a *.keg file
#keggf="kegg_data/ko00001_new.keg"
keggf=$1
mypath=`pwd`
if [ "$keggf" == "" ]
then
echo "Usage: $0 <file kegg in htext format>"
echo "Downloaded from: http://www.genome.jp/kegg-bin/get_htext?ko00001.keg"
exit 0
fi

pipd=$0
pipd=${pipd%/*}
wd=`pwd`
scriptspath=${pipd}/scripts

path=${keggf%/*}
keggnoext=${keggf%%/.keg}

#2) format it
${scriptspath}/kegg_ko_htext2csv.pl $keggf
echo "OK: formatted: ${keggnoext}.csv"


#3) get mapping EC to KO (Keggs Orthology) 
#Could be also retrieve from the keg file
#./get_all_kegg_ko.sh
outpath=$path

echo "Downloading EC list"
rm -f ${outpath}/kegg_all_ec2ko.csv
rm -f ${outpath}/kegg_all_ec2ko.tmp
echo "Downloading all EC mapped to KO"
(curl -# http://rest.kegg.jp/list/pathway > ${outpath}/pathways.list)
(curl -# http://rest.kegg.jp/list/orthology > ${outpath}/orthologs.list)

(curl -# http://rest.kegg.jp/list/enzyme > ${outpath}/enzymes.list)
if [ $? -eq 0 ]
then
    for ec in $(cut -f1 ${outpath}/enzymes.list)
	 do
      #(curl -# http://rest.kegg.jp/link/ko/$ec |grep '^ec' >> ${outpath}/kegg_all_ec2ko.tmp) #doens't work got "There was a problem in data retrieval"
		`curl -ss http://rest.kegg.jp/link/ko/$ec >>${outpath}/kegg_all_ec2ko.tmp`
      if [ $? -eq 0 ]; then
        echo "Retrieved $ec ko map"
      else
        echo "There was a problem in data retrieval"
        exit 1
      fi
    done
   sed '/^$/d' ${outpath}/kegg_all_ec2ko.tmp >${outpath}/kegg_all_ec2ko.csv
   gzip ${outpath}/kegg_all_ec2ko.tmp
else
    echo "There was a problem in data retrieval"
    exit 1
fi

echo `ls $path`

exit 0

###################### could be done with pathway too ################33
echo "Downloading pathway list"
if [ $? -eq 0 ]; then
    for next in $(cut -f1 ${outpath}/pathway.list); do
    (curl -# http://rest.kegg.jp/link/ko/$next > ${outpath}/$next.path2ko)
    if [ $? -eq 0 ]; then
        echo "Retrieved $next ko map"   
    else
        echo "There was a problem in data retrieval"
        exit 1
    fi
    done
    exit 0
else
    echo "There was a problem in data retrieval"
    exit 1
fi

exit 0

