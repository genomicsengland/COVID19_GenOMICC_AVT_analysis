#!/bin/bash

#Input arguments
pgenfile_test=$1
covarFile=$2
phenoFile=$3
annot_prefix=$4
output_prefix=$5

#run AVT step 2
docker run --rm --init -u $(id -u):$(id -g) -v $PWD:$PWD -w $PWD -i quay.io/kousathanas/regenie:v3.2.5 regenie \
  --step 2 \
  --pgen ${pgenfile_test} \
  --covarFile ${covarFile} \
  --phenoFile ${phenoFile} \
  --anno-file ${annot_prefix}.annotations \
  --set-list ${annot_prefix}.setlist \
  --mask-def ${annot_prefix}.masks \
  --out ${output_prefix} \
  --ref-first \
  --bt \
  --firth --approx \
  --firth-se \
  --aaf-bins 0.005 \
  --write-mask \
  --bsize 1000 \
  --minMAC 1 \
  --build-mask 'max'\
  --singleton-carrier \
  --vc-tests skato,acato-full \
  --write-mask-snplist \
  --af-cc \
  --ignore-pred \
  --htp ${output_prefix}