#!/bin/bash

#Input arguments
predfit=$1
pgenfile_test=$2
covarFile=$3
phenoFile=$4
annot_prefix=$5
output_prefix=$6

#run AVT step 2
docker run --rm --init -u $(id -u):$(id -g) -v $PWD:$PWD -w $PWD -i quay.io/kousathanas/regenie:v3.2.5 regenie \
  --step 2 \
  --pred ${predfit} \
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
  --htp ${output_prefix}