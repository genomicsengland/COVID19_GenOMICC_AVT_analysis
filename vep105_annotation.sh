#!/bin/bash
inputvcf=$1
cadd_snv_data=$2
cadd_indel_scores_tsv=$3
aux_data=$4
output_prefix=$5

#Command to feed to vep container to annotate with defaults + LoF + CADD 
cmd="vep -i ${inputvcf} \
         --assembly GRCh38 \
         --vcf \
         --format vcf \
         --cache \
         --dir_cache ${aux_data} \
         -o ${output_prefix}.vcf \
         --plugin LoF,loftee_path:/opt/micromamba/share/ensembl-vep-105.0-1,human_ancestor_fa:vep_data/human_ancestor.fa.gz,conservation_file:vep_data/loftee.sql,gerp_bigwig:vep_data/gerp_conservation_scores.homo_sapiens.GRCh38.bw \
         --plugin CADD,${cadd_snv_data},${cadd_indel_scores_tsv} \
         --everything \
         --force_overwrite \
         --offline \
         --fork 4 \
         --quiet"

#Run container
docker run --rm -it -v ${PWD}:${PWD} -v ${aux_data}:${aux_data} -w ${PWD} quay.io/kousathanas/vep:v105 $cmd

#bgzip and index output
bgzip -f ${output_prefix}.vcf
tabix -f ${output_prefix}.vcf.gz

