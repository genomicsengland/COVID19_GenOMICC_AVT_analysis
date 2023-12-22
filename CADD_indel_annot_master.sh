#!/bin/bash
prefix=$1
output=$2
repo=$3
aux_data=$4

#Keep indels only
bcftools view  -i 'type="indel"' ${prefix}.vcf.gz > ${prefix}_indels.vcf.gz

#step 1:pre-annotate
docker run --rm -it -v ${PWD}:${PWD} -v ${aux_data}:${aux_data} -w ${PWD} quay.io/alexander-stuckey/vep:105.2 \
vep \
--input_file ${prefix}_indels.vcf.gz \
--fasta ${aux_data}/hg38.fa \
--dir_cache ${aux_data} \
--cache_version 105 \
--offline \
--species homo_sapiens \
--assembly GRCh38 \
--format vcf \
--vcf \
--compress_output bgzip \
--regulatory \
--sift b \
--polyphen b \
--per_gene \
--ccds \
--domains \
--numbers \
--canonical \
--total_length \
--fork 4 \
--force_overwrite \
--output_file ${prefix}_indels_part1.vcf.gz
 
#step 2:pre-process
docker run --rm -it -v ${PWD}:${PWD} -w ${PWD} quay.io/kousathanas/cadd:v1.6 \
python /cadd_data/annotateVEPvcf.py -i ${prefix}_indels_part1.vcf.gz -c references_GRCh38_v1.6.cfg | gzip -c > ${prefix}_indels_part2.vcf.gz
 
#step 3:impute
docker run --rm -it -v ${PWD}:${PWD} -w ${PWD} quay.io/kousathanas/cadd:v1.6 \
python /cadd_data/trackTransformation.py -b -i ${prefix}_indels_part2.vcf.gz -c /cadd_data/impute_GRCh38_v1.6.cfg --noheader|gzip -c > ${prefix}_indels_part3.vcf.gz
 
#step 4:Add CADD score annotation
docker run --rm -it -v ${PWD}:${PWD} -v ${repo}:${repo} -w ${PWD} quay.io/kousathanas/cadd:v1.6 \
bash ${repo}/CADD_indel_annot_final_step.sh ${prefix}_indels_part3.vcf.gz ${prefix}_indels_part2.vcf.gz ${output}.tsv.gz

#index annotated file
tabix -p vcf -f ${output}.tsv.gz

#remove intermediate files
rm ${prefix}_indels_part1* ${prefix}_indels_part2* ${prefix}_indels_part3*
