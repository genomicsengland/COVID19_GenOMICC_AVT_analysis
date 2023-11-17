#!/bin/bash
#Code borrowed from https://github.com/BRaVa-genetics/vep105_loftee/blob/main/download_data.sh

mkdir out/
mkdir -p vep_data/dbNSFP/

# Download VEP cache
echo "Downloading VEP cache..."

curl -SL https://ftp.ensembl.org/pub/release-105/variation/indexed_vep_cache/homo_sapiens_vep_105_GRCh38.tar.gz -o vep_data/homo_sapiens_vep_105_GRCh38.tar.gz
tar -xvzf vep_data/homo_sapiens_vep_105_GRCh38.tar.gz -C vep_data/

# Download necessary files for LOFTEE
echo "Downloading LOFTEE files..."

mkdir -p vep_data && \
curl -SL https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/loftee.sql.gz -o vep_data/loftee.sql.gz && \
curl -SL https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz -o vep_data/human_ancestor.fa.gz && \
curl -SL https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.fai -o vep_data/human_ancestor.fa.gz.fai && \
curl -SL https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/human_ancestor.fa.gz.gzi -o vep_data/human_ancestor.fa.gz.gzi && \
curl -SL https://personal.broadinstitute.org/konradk/loftee_data/GRCh38/gerp_conservation_scores.homo_sapiens.GRCh38.bw -o vep_data/gerp_conservation_scores.homo_sapiens.GRCh38.bw

# Download dbNSFP
echo "Downloading dbNSFP cache..."
curl -SL https://dbnsfp.s3.amazonaws.com/dbNSFP4.3a.zip -o vep_data/dbNSFP4.3a.zip

echo "Extracting downloaded files..."
tar -xvzf vep_data/homo_sapiens_vep_105_GRCh38.tar.gz -C vep_data/

# convert dbNSFP file - see dbNSFP section in https://www.ensembl.org/info/docs/tools/vep/script/vep_example.html

unzip vep_data/dbNSFP4.3a.zip -d vep_data/
zcat < vep_data/dbNSFP4.3a_variant.chr1.gz | head -n1 > vep_data/dbNSFP4.3a.txt
zcat < vep_data/dbNSFP4.3a_variant.chr*.gz | grep -v "#" >> vep_data/dbNSFP4.3a.txt
rm vep_data/dbNSFP4.3a_variant.chr*.gz
bgzip vep_data/dbNSFP4.3a.txt
tabix -s 1 -b 2 -e 2 vep_data/dbNSFP4.3a.txt.gz
gunzip vep_data/loftee.sql.gz