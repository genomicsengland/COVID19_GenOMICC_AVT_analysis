#!/bin/bash

#Script to perform masking procedure on VCF files using bcftools

#Should be used for autosomes or ChrX

#samplefile argument should provide a tab or space separated file with two columns: first column should have the sample names as they appear in the VCF file to retain, second column should have only 0 and 1 values as a sex indicator 0(males), 1(females).

#chr argument should take arguments for chr 1-22 and X. These should correspond to how chromosomes are specified in the VCF files. Be careful sometimes chromosomes are specified with prefix "chr", e.g., "chr1"

#threads argument specifies the number of threads to be used for bcftools and plink2 and plinkmem the memory in MB to be used for plink2

#Make sure you have loaded up bcftools either through module load for your cluster or for your running container.

vcf=${1}
chr=${2}
samplefile=${3}
prefix=${4}
threads=${5}
plinkmem=${6}

#Default masking thresholds
#dp=Depth, gq=Genotype quality, pvalue_fmt_abratio=Pvalue for ABratio test
min_fmt_dp=10
min_fmt_gq=20
min_fmt_gq_females=20
min_fmt_gq_males=20
min_fmt_dp_females=10
min_fmt_dp_males=5
pvalue_fmt_abratio=0.001

#ensure header line is removed and there is only a single whitespace as separator
tail -n +2 ${samplefile}|tr -s " "|sed 's/\t/ /g' > all_sample_file.txt
cat all_sample_file.txt| cut -f 1 -d ' ' > onlysamplenames.txt

#Masking begins

#Processing for autosomes
if [ ${chr} != "X" ]; then
bcftools view ${vcf} -S onlysamplenames.txt \
        --force-samples \
        --threads ${threads} \
        -Ou -- \
        | bcftools +setGT -Ou -- \
            -t q \
            -i "FMT/DP<${min_fmt_dp} | FMT/GQ<${min_fmt_gq}" \
            -n . \
        | bcftools +setGT -Ou -- \
            -t "b:AD<=${pvalue_fmt_abratio}" \
            -n . \
        | bcftools view \
            --threads ${threads} \
            -Oz -o ${prefix}_maskedQC.vcf.gz
fi

# #Processing for X chromosome, if chr is X, then perform masking on males and females separately and merge VCF files
if [ ${chr} == "X" ]; then

echo "chrX detected"

#Second field specifies 0/1 males/females
awk -F' ' '$2 == 0 {print $1}' all_sample_file.txt > males_sample_file.txt
awk -F' ' '$2 == 1 {print $1}' all_sample_file.txt > females_sample_file.txt

bcftools view ${vcf} -S females_sample_file.txt \
        --force-samples \
        --threads ${threads} \
        -Ou -- \
        | bcftools +setGT -Ou -- \
            -t q \
            -i "FMT/DP<${min_fmt_dp_females} | FMT/GQ<${min_fmt_gq_females}" \
            -n . \
        | bcftools +setGT -Ou -- \
            -t "b:AD<=${pvalue_fmt_abratio}" \
            -n . \
        | bcftools view \
            -Oz -o ${prefix}_females.masked.vcf.gz
bcftools index ${prefix}_females.masked.vcf.gz

bcftools view ${vcf} -S males_sample_file.txt \
        --force-samples \
        --threads ${threads} ${vcfQC_additional_args} \
        -Ou -- \
        | bcftools +setGT -Ou -- \
            -t q \
            -i "FMT/DP<${min_fmt_dp_males} | FMT/GQ<${min_fmt_gq_males}" \
            -n . \
        | bcftools view \
            -Oz -o ${prefix}_males.masked.vcf.gz
bcftools index ${prefix}_males.masked.vcf.gz

#merge male and female masked VCF files
bcftools merge ${prefix}_females.masked.vcf.gz ${prefix}_males.masked.vcf.gz -m none \
        -Oz -o ${prefix}_maskedQC.vcf.gz
fi

bcftools index ${prefix}_maskedQC.vcf.gz