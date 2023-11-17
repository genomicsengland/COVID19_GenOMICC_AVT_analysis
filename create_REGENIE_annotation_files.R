library(data.table)
library(dplyr)

x<-fread("mask_files/LoF_mis.annotations",header=FALSE)
y<-fread("Ensembl_105_genes_coordinates_GRCh38.tsv")

colnames(x)=c('SNP','gene_symbol','annotation')
data<-merge(x,y,by='gene_symbol')

concatenated <- aggregate(SNP ~ gene_symbol, data = data, FUN = paste, collapse = ",")

setfile<-merge(concatenated,y,by='gene_symbol')
setfile_out<-setfile%>%select(gene_symbol,chrom,start,SNP)

fwrite(setfile_out, file = "mask_files/LoF_mis.tsv",sep='\t',col.names=FALSE)