#!/bin/bash
input=$1
output=$2

#Create VCF file 
echo "##fileformat=VCFv4.2\n#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO" > ${output}
awk '{print $0"\t\.\t\.\t\."}' ${input} >> ${output}
bgzip ${output}
tabix ${output}.gz