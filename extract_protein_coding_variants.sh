#intersect only genic protein coding variants
grep -v \# all_chunks_merged_norm_chr22_maskedQC.pvar|cut -f 1-5|awk '{print $1"\t"$2-1"\t"$2"\t"$3"\t"$4"\t"$5}'|\
bedtools intersect -a "stdin" -b Ensembl_105_genes_coordinates_GRCh38_protein_coding.tsv -wa|\
awk '{print $1"\t"$3"\t"$4"\t"$5"\t"$6}' > aggCOVID_v5_sites_chr22_proteincoding.vcf
