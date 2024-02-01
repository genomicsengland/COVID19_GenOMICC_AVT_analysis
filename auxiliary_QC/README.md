# Masking QC for VCF files

Mask VCF files by setting low quality genotypes to missing, i.e, "./."

## Requirements
bcftools required

## Test on 1000 genomes data

Get sample from 1KG chr22 data and index
```
#generate testdata for chr22
bcftools view http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr22.recalibrated_variants.vcf.gz|head -n 10000|bgzip > 20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr22.recalibrated_variants_testset.vcf.gz

tabix 20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr22.recalibrated_variants_testset.vcf.gz

#generate testdata for chrX
bcftools view http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_raw_GT_with_annot/20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.recalibrated_variants.vcf.gz|head -n 10000|bgzip > 20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.recalibrated_variants_testset.vcf.gz

tabix 20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.recalibrated_variants_testset.vcf.gz

```

Run masking on test data for chr22:
```
repo=~/COVID19_GenOMICC_AVT_analysis

sh ${repo}/auxiliary_QC/vcf_genomic_masking_QC.sh \
20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chr22.recalibrated_variants_testset.vcf.gz \
22 \
${repo}/aux_resources/1KGP3_samplelist_sex.txt \
1KGP3_chr22 \
10 \
10000
```

Run masking on test data for chrX:

```
repo=~/COVID19_GenOMICC_AVT_analysis

sh ${repo}/auxiliary_QC/vcf_genomic_masking_QC.sh \
20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.recalibrated_variants_testset.vcf.gz \
X \
${repo}/aux_resources/1KGP3_samplelist_sex.txt \
1KGP3_chrX \
10 \
10000
```