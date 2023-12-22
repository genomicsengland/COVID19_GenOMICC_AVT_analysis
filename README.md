# GenOMICC rare variant analysis

Herein we describe the rare variant analysis protocol for the GenOMICC study and instructions to fully replicate it. 

Broadly it is very similar to the HGI COVID19 analysis plan (https://docs.google.com/document/d/1QrwktjejSH7A1Srzdkyfg4gJi8u4HAFrXPn8XrdX7wo/view)

However, there are two important differences:

* The masks used for aggregating variants: Aiming for simplicity, we have defined two masks **strict_LoF** and **mild_LoF** (also described in more detail below). The strict LoF mask is identical to Mask M1 from HGI (High confidence Loss of function variants). The mild_LoF mask includes strict_LoF variants and missense mutations prioritorised with the pathogenicity tool CADD (we used the relaxed threshold of CADD>=10). It is most similar to HGI Mask M4. The CADD machine learning toolset allowed us to annotate every single variant including indels.
* The tests performed with REGENIE include burden, SKAT and ACAT-V, combined with a single omnibus test (ACAT-O) to maximise power.

We describe below our phenotype definition and Quality control procedure to be reviewed by analysts replicating this work.

We then provide a multi-step procedure to annotate variants and run REGENIE in order to align with our analytical approach.

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [Software, storage and compute requirements](#software-storage-and-compute-requirements)
   * [Software](#software)
   * [Storage and compute](#storage-and-compute)
- [Phenotype definition](#phenotype-definition)
- [Site-wise and sample-wise quality control of genomic files](#site-wise-and-sample-wise-quality-control-of-genomic-files)
   * [Site-QC](#site-qc)
   * [Sample-QC](#sample-qc)
- [Step 1: Download resources for variant annotation](#step-1-download-resources-for-variant-annotation)
   * [Primary data](#primary-data)
   * [Auxiliary data for indel CADD annotation](#auxiliary-data-for-indel-cadd-annotation)
- [Step 2: Annotate variant sites](#step-2-annotate-variant-sites)
   * [Prepare vcf input files](#prepare-vcf-input-files)
   * [Compute CADD scores with VEP for indels (optional)](#compute-cadd-scores-with-vep-for-indels-optional)
   * [Annotate all variants](#annotate-all-variants)
- [Step 3: Generate REGENIE mask files](#step-3-generate-regenie-mask-files)
- [Step 4: Run REGENIE step 1](#step-4-run-regenie-step-1)
- [Step 5: Run REGENIE step 2](#step-5-run-regenie-step-2)
   * [Recoding of ref/alt alleles for genomic files (optional)](#recoding-of-refalt-alleles-for-genomic-files-optional)
   * [Running REGENIE step 2](#running-regenie-step-2)
- [Summary statistics sharing](#summary-statistics-sharing)

<!-- TOC end -->

## Software, storage and compute requirements
<hr>

Start by cloning the repository:

```
git clone https://github.com/genomicsengland/COVID19_GenOMICC_AVT_analysis.git
```

### Software
We have made effort to containerise the software for which there is likely to be divergence in results between versions. We supply containers hosted publicly in quay.io when running the following software:

* VEP, v105 (quay.io/kousathanas/vep:v105)
* CADD, v1.6 (quay.io/kousathanas/cadd:v1.6)
* REGENIE, v3.2.5 (quay.io/kousathanas/regenie:v3.2.5)

Some additional essential tools will be needed to be installed in the environment where analyses are run:

* Docker (https://docs.docker.com/engine/install/) \
* bcftools version >=1.11 (https://samtools.github.io/bcftools/howtos/install.html) \
* samtools version >=1.11 (http://www.sthda.com/english/wiki/install-samtools-on-unix-system) \
* plink version >= 1.9b_4.1 (https://www.cog-genomics.org/plink/1.9/)
* plink2 version >= 2.00a3.3LM (https://www.cog-genomics.org/plink/2.0/)
* R version >=3.6, with data.table & tidyverse packages (https://cran.r-project.org/)

both bcftools and samtools can be installed on mac with:

```
brew install bcftools samtools
```

For bcftools, plink and plink2, you can alternative use the following container that satisfies requirements:
* quay.io/alexander-stuckey/gwas_avt 

### Storage and compute
You will be expected to: 
* Download data resources required for annotation (data totalling ~400 Gb, safer to have 1Tb+ free for allowing intermediate files).
* Adapt some scripts to run in parallel across chromosomes.
* Compute nodes need to have access to internet to pull containers from the quay.io docker repositories.

**Note about Docker containers and mounting** 
In the provided scripts we are setting up Docker to mount the current directory ($PWD) by default. If you redirect outputs in different directories, these will not be "seen" by Docker and will complain with "file not found". You can edit the scripts and add additional bind points with -v if that happens.


## Phenotype definition
We use a single endpoint, with cases being COVID-19 positive critically ill patients as assessed by their treating clinician and controls being COVID-19 positive individuals with mild symptoms supplemented with individuals from the 100K genomes project.

The most similar phenotype definition from HGI is phenotype C:
Severe Covid-19 (A2 in Covid-19 HGI):
* Cases: laboratory confirmed Covid-19 with one or more of the following outcomes:
    Death
    ECMO requirement
    Mechanical ventilation (i.e. intubation) requirement
    Non-invasive ventilation requirement (i.e. new requirement for BiPAP or CPAP)
    High-flow oxygen therapy requirement (e.g. Optiflow)

* Controls: every other participant in each cohort that is not a case.

This should be the primary endpoint for replication and meta-analysis with GenOMICC.

## Site-wise and sample-wise quality control of genomic files
<hr> 

Broadly, our QC is aligned with the HGI COVID-19 recommendations as described here: https://github.com/covid19-hg/covid19_sequencing.

As each contributing study has their own quality control procedures optimal for their datasets, we require only that the analyst from each study reviews the GenOMICC approach and communicates to us any major differences or concerns and at minimum filters-out sites with > 5% site-wise missingness.

### Site-QC
We employed the following siteQC protocol (adapted from Kousathanas et al. (2022)):

We masked low-quality genotypes by setting them to missing using the bcftools setGT module:
For autosomes, we masked genotypes having DP < 10 or genotype quality (GQ) < 20 or heterozygote genotypes failing an ABratio binomial test with P-value < $10^{−3}$.
For chrX, we masked females as for autosomes. We masked male genotypes having DP < 5 or GQ < 20.

After masking, we removed variant sites with missingness > 5%. 

### Sample-QC
We employed the sample QC protocol from Kousathanas et al. (2022) by removing samples that failed four BAM-level quality control filters: freemix contamination > 3%, mean autosomal coverage < 25×, per cent mapped reads < 90% or per cent chimeric reads > 5%. We also computed additional metrics: ratio of heterozygous to homozygous genotypes, ratio of insertions to deletions, ratio of transitions to transversions, total deletions, total insertions, total heterozygous SNPs, total homozygous SNPs, total transitions and total transversions. We required that samples were within 4 median absolute deviations (MADs) of the median of each of these statistics and removed outliers.

We required unrelated participants (KING-robust pairwise kinship < 0.0442).

## Step 1: Download resources for variant annotation
<hr> 

### Primary data
First download essential VEP, LOFTEE and CADD data using the script **download_essential_data.sh**. This download will take around 100GB of data. The file with CADD pre-computed scores for single nucleotide variants (SNV) is the largest, 81 GB (file will not need to be unpacked). 
* Variable **${repo}** points to the repo directory (here assumed to reside in the current working directory).
* Variable **${aux_data}** points to the output directory for the files, which will be used downstream.


```
repo=${PWD}/COVID19_GenOMICC_AVT_analysis
mkdir -p ${PWD}/vep_data
aux_data=${PWD}/vep_data

sh ${repo}/download_essential_data.sh ${aux_data}
```

### Auxiliary data for indel CADD annotation
Then, download CADD auxiliary data to be used to infer CADD scores for indels. This includes 200GB of data and unpacking will require an additional 200GB, thus make sure you have at least 500GB available in storage space before running the following script. 

```
sh ${repo}/download_auxiliary_cadd_data.sh ${aux_data}
```

If you cannot run the download_auxiliary_cadd_data.sh script due to limited storage space or internet bandwidth, then you can download and use the pre-computed CADD scores for the gnomadv3.0 indels as shown below (just 1.1GB). However, this will be of limited usefulness for annotating with CADD the rare indels in your data.

[i.e, if using gnomad indel variants to annotate, most indels in your dataset will probably not get a CADD score and thus will not be included in a variant mask defined further downstream that filters using CADD. However, even in such a case we would expect only effects on limiting power rather than bias by not including indels.]

```
wget -c https://krishna.gs.washington.edu/download/CADD/v1.6/GRCh38/gnomad.genomes.r3.0.indel.tsv.gz -o ${aux_data}/gnomad.genomes.r3.0.indel.tsv.gz
```

## Step 2: Annotate variant sites
<hr> 

Here you will be annotating the entirety of your genomic variants.

### Prepare vcf input files
If your have VCF (.vcf.gz) files containing the variant sites for annotation, skip this step.

If you dont have VCF files, prepare tab-separated text files with the following columns: \
CHR POS ID REF ALT

i.e., the first 5 columns of a VCF file. This is straightforward to generate from a .bim or .pvar file, (be careful of the column order).

Then, to create a VCF file from this tab-separated text file (example file variant_sites_chr22_10K.tsv provided in data_examples and used here) you can run:

```
prefix=variant_sites_chr22_10K
sh ${repo}/create_vcf_file.sh ${prefix}.tsv ${prefix}.vcf
```
This will create a basic vcf file with suffix vcf.gz to be used downstream.

### Compute CADD scores with VEP for indels (optional)
Skip this step if you cant download the CADD auxiliary annotation data and use just the gnomad_v3 scores.

Then you can proceed to compute CADD scores with VEP for indels. Provided script will extract automatically indels and compute CADD scores for those.

Script takes four arguments for:
* input prefix (assumed to be in vcf.gz format, script will append ".vcf.gz" before reading). Intermediate output will use this primary prefix.
* output prefix. ".tsv.gz" will be appended.
* repository location
* auxiliary data location.

```
prefix=variant_sites_chr22_10K
output_prefix=${prefix}_indels_cadd
repo=${PWD}/COVID19_GenOMICC_AVT_analysis
aux_data=${PWD}/vep_data

sh ${repo}/CADD_indel_annot_master.sh \
${prefix} \
${output_prefix} \
${repo} \
${aux_data}
```

Run script in parallel across chromosomes. If running on a cluster, make sure to load all necessary modules for required software. Internet connectivity is required to pull Docker containers.

### Annotate all variants

Then you proceed to fully annotate all variant sites with VEP version 105 with additional plugins LOFTEE and CADD. 

Annotation script is followed by five arguments: 

* input vcf file containing the variants to be annotated
* SNV precomputed CADD scores file (downloaded previously)
* indel CADD scores (downloaded previously)
* auxiliary data directory (downloaded VEP, LOFTEE and fasta reference previously)
* output filename, will be vcf.gz format (.vcf.gz will be appended to the text given)


```
prefix=variant_sites_chr22_10K
repo=${PWD}/COVID19_GenOMICC_AVT_analysis
aux_data=${PWD}/vep_data

sh ${repo}/vep105_annotation.sh \
${prefix}.vcf.gz \
${aux_data}/whole_genome_SNVs.tsv.gz \
${prefix}_indels_cadd.tsv.gz \
${aux_data} \
${prefix}_annotated

```

Ignore "Smartmatch is experimental" warnings.

Run script in parallel across chromosomes. If running on a cluster, make sure to load all necessary modules for required software. Internet connectivity is required to pull Docker containers.

## Step 3: Generate REGENIE mask files
<hr> 
We will use two masks as part of the GenOMICC analysis plan:
* **strict_LoF**: Variants with High Confidence Loss of function (LoF) consequence on the canonical gene transcript. 
* **mild_LoF**: Variants from LoF mask + missense variants with CADD>=10 consequence on the canonical gene transcript.

To generate input files for REGENIE to specify these masks, run the following script that uses as input the annotated data that was generated in the previous step.

It takes three arguments:

* annotated vcf.gz file 
* required prefix for output files
* Genomicc repository location

```
prefix=variant_sites_chr22_10K
repo=${PWD}/COVID19_GenOMICC_AVT_analysis

sh ${repo}/extract_consequences.sh \
${prefix}_annotated.vcf.gz \
${prefix} \
${repo}
```

## Step 4: Run REGENIE step 1
<hr> 

Regenie step 1 uses high quality independent SNPs from across the genome to fit a whole genome regression model to capture polygenic effects. It aims to account for confounders such as population stratification.

You should have:
* **HQSNPs**: a plink bed/bim/fam or pgen/psam/pvar file with >50K high quality independent common SNPs from across all autosomes (chr 1-22).
* **phenoFile**: a file with columns for the sample IDs and the phenotype as a 0/1 indicator for controls/cases. See here for phenoFile format: https://rgcgithub.github.io/regenie/options/#phenotype-file-format
* **covarFile**: a file with the covariates: age, sex, age^2, age*sex, PC1-PC10 (common variants), PC1-PC10 (rare variants). Principal components (PCs) should be population-specific. See here for covariate format: https://rgcgithub.github.io/regenie/options/#covariate-file-format

You can then run REGENIE step 1 with the following script (runs a container), that takes four arguments:

```
repo=${PWD}/COVID19_GenOMICC_AVT_analysis

sh ${repo}/run_regenie_step1.sh \
${HQSNPs} \
${covarFile} \
${phenoFile} \
${output_prefix}
```
output_prefix specifies the prefix for output files.

The runs should be once per phenotype tested.

## Step 5: Run REGENIE step 2
<hr> 

### Recoding of ref/alt alleles for genomic files (optional)
REGENIE (v3.2.5), uses AAF [Alternate/GRCH38 ref allele frequency] and not MAF [minor allele frequency] when deciding which variants go into a mask. This means that variants for which the GRCH38 reference genome is the minor allele will not be included if their AAF is quite high (>0.995). We have found that this is problematic as it reduces power with variants that are rare in terms of MAF not being included, and we have observed false positives too arising when there are subtle differences in processing between cases and controls. 

To overcome this, we used plink2 option **--maj-ref force** to recode the genetic files going into step 2 and use REF/ALT as major/minor. [Script recode_plink_files_for_REGENIE_step2.sh]

As we dont expect this step to have a major influence on the results, we leave it to the individual analysts to decide whether to include this step.

### Running REGENIE step 2

REGENIE step 2 conditions on the "null" prediction model from step 1 and then performs several aggregate burden tests. 
We have set up REGENIE to perform the burden, SKAT and ACAT-V tests and combine the P-values of these tests with an omnibus ACAT-O test, for each mask separately.

We used variants with maf < 0.005 before testing and --aaf-bins option was set to 0.005. We do not use multiple aaf-bins for testing.

Before running this step, you should have:
* **predfit**: regression model fit file from REGENIE step 1.
* **pgenfile_test**: File in bed/bim/fam or pgen/psam/pvar format containing the quality control filtered genotype data to be tested

You can then run REGENIE step 2 with the following script (runs a container), that takes six arguments:

```
repo=${PWD}/COVID19_GenOMICC_AVT_analysis

sh ${repo}/run_regenie_step2.sh \
${predfit} \
${pgenfile_test} \
${covarFile} \
${phenoFile} \
${annot_prefix} \
${output_prefix}
```

The runs should be across phenotypes and across chromosomes 1-22 and chrX.

## Summary statistics sharing

Similarly to HGI analysis plan (https://docs.google.com/document/d/1QrwktjejSH7A1Srzdkyfg4gJi8u4HAFrXPn8XrdX7wo/view):

We request that the summary statistics file obtained from Regenie’s Step 2 (with the --htp command) be named with the following convention:

```
CohortName.YYYY.MM.DD.Phenotype.Ancestry.Subanalysis.txt.gz
```

The options are the following:

**CohortName:** your cohort name
**YYYY.MM.DD:** date of analysis
**Phenotype:** A, B or C (phenotypes correspond to definitions from the HGI analysis plan and specifics will be agreed through corespondance)
**Ancestry:** AFR (african), AMR (admixed american), EAS (east asian), EUR(european), MEA (middle eastern), or SAS (south asian).
**Subanalysis:** Tag for sub analysis agreed through correspondance

Note: We do not use the MAF tag as we are performing analysis for MAF < 0.005 only. We do not use the Sex tag, as we are not performing sex-stratified analysis (or this will be applied in particular Subanalysis tag if we choose to pursue it).
