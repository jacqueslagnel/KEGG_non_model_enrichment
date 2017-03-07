#!/bin/bash

#convert_contigs_IDs_2_annot.pl <in DE contigs IDs list> <in full annot from b2g> <outpath>
../convert_contigs_IDs_2_annot.pl \
inputs/pagellus_female_gonads_lfch2_uniq_trascript_ids.txt \
inputs/Pagellus_blast2go_annotation_InterPro_Goslim_enzyme.annot \
inputs/



#../Run_KEGG_enrichment_fisher_FDR.sh <annot ref (*.annot)> <annot to test (*.annot)> <kegg all ec2ko (kegg_all_ec2ko.tmp)> <KEGG pathways in csv> <FDR cutoff value> <output path>

../Run_KEGG_enrichment_fisher_FDR.sh \
inputs/Pagellus_blast2go_annotation_InterPro_Goslim_enzyme.annot \
inputs/pagellus_female_gonads_lfch2_uniq_trascript_ids.annot \
../keggdata/kegg_all_ec2ko.csv \
../keggdata/ko00001.csv \
0.05 \
outputs/

exit 0


