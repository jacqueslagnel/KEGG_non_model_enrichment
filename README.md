This project is licensed under the terms of the MIT license.
Copyright (c) 2015 Lagnel Jacques
last update: Jacques Lagnel (28/02/2017) lagnel 'at' hcmr.gr

KEGG_enrichment4nonmodel

------------
Description
------------
This package aims to do KGG pathways assigment and performs KEGG enrichment analyses for non model species.
It uses enzymes (EC number) produced from Blast2GO annotation.


 run the population genetics software STRUCTURE from Pritchard et al. 2000 (http://pritch.bsd.uchicago.edu/structure.html) in parallel on a cluster (beowulf type) with a PBS queue system (torque: http://www.adaptivecomputing.com/products/open-source/torque/). Each run of K (the number of populations) is executed separately on each CPU of the cluster trough PBS jobs.
A summary statistics table and distruct (Noah Rosenberg: http://www.stanford.edu/group/rosenberglab/distruct.html) outputs are built at the end.
Run Structure in parallel: nb jobs=k*iterations (on a cluster with queuing system (qsub))

KEGG_enrichment4nonmodel conducts the following steps:
1) Get the KEGGs pathways and EC to KO
2) Run Enrichment
3) Build statistics csv file
You have to provide:
the 
the data file named:'project_data'
and the extraparams file named:'extraparams')


-----------------
Requirement:
-----------------
Linux computer or cluster (Beowulf type): perl, bash, R, Bioconductor 

A queue system based on PBS: torque

a shared folder between all cluster nodes of the cluster with the executables:
structure,structure_parse_results.pl, structure2distruct.pl and distruct

----------------
Installation
----------------
1) patch the original structure distribution source code   
patch -p0 < ran.jl.patch
This patch for the structure (ran.c) is provided in order to correct the generation of the seed number

2) copy the perl scripts in a shared folder

3) For the structure_parallel_cluster_qsub.pl:
change lines 12,13,14 in order to set the path of the executables: structure, structure_parse_results.pl and structure2distruct.pl

nb: if you dont want tu use the patched version of structure you can use the seed generator provided in this script by uncomment the line 125 and comment the line 128 (a comment, indicated by putting a '#' at the beginning of the line).

4) For structure2distruct.pl:
change line 31 to set the path of the executables: distruct



---------------
Running
---------------

structure_parallel_cluster_qsub.pl :main script to submit structure jobs to the cluster
Usage:structure_parallel_cluster_qsub.pl <k(min)> <k(max)> <nb of runs>  <keep full raw outputs (y=big files) [y|n]> <Full path of mainparameters and data>
The outputs will be in the '<Full path of mainparameters and data>/structure_ddmmyyyy_HHMMSS_run' folder
at the end 2 scripts are automatically executed (from structure_parallel_cluster_qsub.pl):
structure_parse_results.pl: To build the statistics table.
structure2distruct.pl: produces the figures, parameters and data files from structure outputs

Example:

Where the folder "/home/jacques/test" contains the 3 text files: 
mainparams = main parameters file
project_data = data (genotypes)
extraparams = extra parameters file (optional)
including with the line:
#define RANDOMIZE 1

