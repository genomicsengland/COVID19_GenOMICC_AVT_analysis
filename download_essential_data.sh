#!/bin/bash
#Code adapted from https://github.com/BRaVa-genetics/vep105_loftee/blob/main/download_data.sh

dir=$1
mkdir -p ${dir}

# Download VEP cache
echo "Downloading VEP cache files..."

wget -c https://ftp.ensembl.org/pub/release-105/variation/indexed_vep_cache/homo_sapiens_vep_105_GRCh38.tar.gz -P ${dir}/homo_sapiens_vep_105_GRCh38.tar.gz
tar -xvzf ${dir}/homo_sapiens_vep_105_GRCh38.tar.gz -C ${dir}/

# Download necessary files for LOFTEE
echo "Downloading LOFTEE files..."

wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/loftee.sql.gz -P ${dir}/loftee.sql.gz && \
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz -P ${dir}/human_ancestor.fa.gz && \
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.fai -P ${dir}/human_ancestor.fa.gz.fai && \
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.gzi -P ${dir}/human_ancestor.fa.gz.gzi && \
wget -c https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/gerp_conservation_scores.homo_sapiens.GRCh38.bw -P ${dir}/gerp_conservation_scores.homo_sapiens.GRCh38.bw

#Unzip loftee
gunzip ${dir}/loftee.sql.gz

#Download and index reference genome
wget -c http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz -P ${dir}/hg38.fa.gz
gunzip ${dir}/hg38.fa.gz
samtools faidx ${dir}/hg38.fa

#CADD annotations and scores
echo "Downloading CADD files with pre-computed scores for SNVs..."
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz -P ${dir}/whole_genome_SNVs.tsv.gz
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/whole_genome_SNVs.tsv.gz.tbi -P ${dir}/whole_genome_SNVs.tsv.gz.tbi



