#!/bin/bash
dir=${1}

#Downloadå CADD annotations
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/annotationsGRCh38_v1.6.tar.gz -o ${dir}/annotationsGRCh38_v1.6.tar.gz

#Extract data
tar -xvzf ${dir}/annotationsGRCh38_v1.6.tar.gz

#create link of reference genome to within CADD annotations
#Note that there is already a reference genome (GRCh38_v1.6/reference/reference.fa), but this has chromosomes without "chr" suffix
ln -s ${dir}/hg38.fa ${dir}/GRCh38_v1.6/hg38.fa
ln -s ${dir}/hg38.fa.fai ${dir}/GRCh38_v1.6/hg38.fa.fai