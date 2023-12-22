#!/bin/bash
input=$1
vcftoannotate=$2
output=$3

python /cadd_data/predictSKmodel.py -i ${input} \
-m /cadd_data/models/CADDv1.6-GRCh38.mod \
-a ${vcftoannotate} \
| python /cadd_data/max_line_hierarchy.py --all \
| python /cadd_data/appendPHREDscore.py \
-t /cadd_data/models/conversionTable_CADDv1.6-GRCh38.txt \
| awk '{print $1"\t"$2"\t"$3"\t"$4"\t"$(NF-1)"\t"$NF}' \
| uniq \
| bgzip -c > ${output}