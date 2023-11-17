#!/bin/bash

bedfile_HQSNPs=$1
pgenfile_test=$2
covarFile=$3
phenoFile=$4
annot_prefix=$5

#run AVT step 1
docker run --rm --init -u $(id -u):$(id -g) -v $PWD:$PWD -w $PWD -i quay.io/kousathanas/regenie:v3.2.5 regenie \
  --step 1 \
  --bed ${bedfile_HQSNPs} \
  --ref-first \
  --covarFile  ${covarFile} \
  --phenoFile  ${phenoFile} \
  --bsize 1000 \
  --bt --lowmem \
  --lowmem-prefix tmp_rg \
  --loocv \
  --out fit_bin_out

#run AVT step 2
docker run --rm --init -u $(id -u):$(id -g) -v $PWD:$PWD -w $PWD -i quay.io/kousathanas/regenie:v3.2.5 regenie \
  --step 2 \
  --pgen ${pgenfile_test} \
  --ref-first \
  --covarFile  ${covarFile} \
  --phenoFile  ${phenoFile} \
  --bt \
  --firth --approx \
  --firth-se \
  --pred fit_bin_out_pred.list \
  --anno-file ${annot_prefix}.annotations \
  --mask-def ${annot_prefix}.masks \
  --set-list ${annot_prefix}.tsv \
  --aaf-bins 0.005 \
  --write-mask \
  --bsize 1000 \
  --out test_bin_out_firth_filtered \
  --minMAC 1 \
  --build-mask 'max'\
  --singleton-carrier \
  --vc-tests skato,acato-full \
  --write-mask-snplist \
  --af-cc \
  --htp aggCOVID_v5