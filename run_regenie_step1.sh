#!/bin/bash

#Input arguments
bedfile_HQSNPs=$1
covarFile=$2
phenoFile=$3
output_prefix=$4

#run AVT step 1
docker run --rm --init -u $(id -u):$(id -g) -v $PWD:$PWD -w $PWD -i quay.io/kousathanas/regenie:v3.2.5 regenie \
  --step 1 \
  --bed ${bedfile_HQSNPs} \
  --covarFile  ${covarFile} \
  --phenoFile  ${phenoFile} \
  --ref-first \
  --bsize 1000 \
  --bt --lowmem \
  --lowmem-prefix ${output_prefix}_tmp \
  --loocv \
  --out ${output_prefix}