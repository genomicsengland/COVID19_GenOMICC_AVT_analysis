#!/usr/bin/env Rscript
suppressMessages(library(data.table))
suppressMessages(library(dplyr))

#Define inputs
args = commandArgs(trailingOnly=TRUE)
annot_cons<-args[1]
Ensembl_coord<-args[2]
CADD_thres<-as.numeric(args[3])
output_prefix<-args[4]

#Read missense+ consequences and cleanup for genes without Ensembl name
cons<-fread(annot_cons)%>%
filter(SYMBOL!='.')

#get strict LoF consequences
lof<-cons%>%filter(LoF=='HC' & IMPACT=='HIGH')%>%
select(ID, SYMBOL)%>%
mutate(consequence="LoF")

#get missense but not LoF
missense<-cons%>%
filter(!ID%in%lof$ID)%>%
filter(CADD_PHRED>=10)%>%
select(ID, SYMBOL)%>%
mutate(consequence="missense")

annodata<-rbind(lof,missense)%>%distinct()

#Write annotation file
fwrite(annodata, file=paste0(output_prefix,".annotations"), sep='\t', col.names=FALSE)

Ens<-fread(Ensembl_coord)%>%
rename(SYMBOL=gene_symbol)

setdata<-merge(annodata, Ens, by='SYMBOL')
concatenated <- aggregate(ID ~ SYMBOL, data = setdata, FUN = paste, collapse = ",")

#Create and writeout REGENIE setfile
setfile<-merge(concatenated, Ens, by='SYMBOL')
setfile_out<-setfile%>%select(SYMBOL, chrom, start, ID)

fwrite(setfile_out, file = paste0(output_prefix,".setlist"), sep='\t', col.names=FALSE)