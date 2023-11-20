#!/bin/bash
inputvcf=$1
output=$2
dbNSFP_source=$3

cmd="vep -i ${inputvcf} \
         --assembly GRCh38 \
         --vcf \
         --format vcf \
         --cache \
         --dir_cache vep_data \
         -o ${output} \
         --plugin LoF,loftee_path:/opt/micromamba/share/ensembl-vep-105.0-1,human_ancestor_fa:vep_data/human_ancestor.fa.gz,conservation_file:vep_data/loftee.sql,gerp_bigwig:vep_data/gerp_conservation_scores.homo_sapiens.GRCh38.bw \
         --plugin dbNSFP,${dbNSFP_source},CADD_phred \
         --everything \
         --force_overwrite \
         --offline"

docker run -v $(pwd):/$HOME/ -w $HOME -it ghcr.io/brava-genetics/vep105_loftee:main $cmd
#singularity pull vep_data/vep.sif docker://skoyamamd/vep105_loftee
#singularity run -B $(pwd):/$HOME/ vep_data/vep.sif $cmd
