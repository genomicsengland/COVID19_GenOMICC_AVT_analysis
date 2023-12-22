#!/bin/bash

#Input parameters
input=$1
output_prefix=$2
repo=$3

#Extract header from annotation file and append to consequences output
echo "ID" > ${output_prefix}_conseq_header1.txt
bcftools +split-vep ${input} -l|cut -f 2 >> ${output_prefix}_conseq_header1.txt
cat ${output_prefix}_conseq_header.txt|tr '\n' '\t'|sed 's/.$//' > ${output_prefix}_conseq_header2.tsv
echo "$(cat ${output_prefix}_conseq_header2.tsv)" > ${output_prefix}_conseq.tsv

#remove header intermediate files
rm ${output_prefix}_conseq_header1.txt ${output_prefix}_conseq_header2.tsv

#Select missense+ consequences on CANONICAL transcript of protein-coding genes
bcftools +split-vep ${input} \
-f '%ID\t%CSQ\n' -d -A tab \
-i 'CANONICAL="YES" && BIOTYPE="protein_coding"' \
-s all:missense+ \
>> ${output_prefix}_conseq.tsv

#Create Regenie required annotation and variant set files based on variant consequences
Rscript ${repo}/create_REGENIE_maskfiles.R \
${output_prefix}_conseq.tsv \
${repo}/aux_resources/Ensembl_105_genes_coordinates_GRCh38.tsv \
10 \
${output_prefix}

#Define masks
echo "strict_LoF LoF" > ${output_prefix}.masks
echo "mild_LoF LoF,missense" >> ${output_prefix}.masks



