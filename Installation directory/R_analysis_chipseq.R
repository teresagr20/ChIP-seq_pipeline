## This R script will use the results of callpeaks with the intention
## of establishing the expression peaks and target genes.

peaks_args <- commandArgs(trailingOnly = TRUE)

promotor.length <- as.numeric(peaks_args[[1]])
narrow.peaks <- peaks_args[[2]]
peaks.summits <- peaks_args [[3]]
nametf <- as.character(peaks_args[[4]])

print("Promotor length:")
print(as.numeric(peaks_args[[1]]))

print("Narrow peaks:")
print(peaks_args[[2]])

print("Peaks summits:")
print(peaks_args[[3]])

print("TF name:")
print(nametf)

## Install all packages required, chipseeker and annotation package.
## if (!requireNamespace("BiocManager", quietly = TRUE))
##  install.packages("BiocManager")
## BiocManager::install("ChIPseeker")
## BiocManager::install("TxDb.Athaliana.BioMart.plantsmart28")

## Loading packages
## TxDb must be install depending on the organism of study. 

library(ChIPseeker)
library(TxDb.Athaliana.BioMart.plantsmart28)
library(ballgown)
library(genefilter)

txdb <- TxDb.Athaliana.BioMart.plantsmart28


## Reading peaks file
peaks <- readPeakFile(peakfile = narrow.peaks ,header=FALSE)

## Defining the region considered as promotor around TSS.
promoter <- getPromoters(TxDb=txdb, 
                         upstream=promotor.length, 
                         downstream=promotor.length)

## Peaks annotation
peakAnno <- annotatePeak(peak = peaks, 
                             tssRegion=c(-promotor.length, promotor.length),
                             TxDb=txdb)

plotAnnoPie(peakAnno)
#jpeg("annotation_bar.jpg")
plotDistToTSS(peakAnno,
              title="Distribution of genomic loci relative to TSS",
              ylab = "Genomic Loci (%) (5' -> 3')")

## Turn annotation into data frame
annotation_dataframe <- as.data.frame(peakAnno)
head(annotation_dataframe)

## Target genes are obtained, considering them as genes which promotor 
## is recognised by the transcription factor.  

target.genes <- annotation_dataframe$geneId[annotation_dataframe$annotation == "Promoter"]

## If you only use a FT ...
## write(x = target.genes,file = "target_genes.txt")

## If you use more than 1 FT...
write(x = target.genes, file = paste(c(nametf,"_target_genes.txt"), collapse = ""))


## GO terms enrichment

#peak_anno_summits <- annotatePeak(peak = peaks.summits, tssRegion = c(-promoter.length,
#                        promotor.length), TxDb=txdb)
#peak_anno_summits_dataframe <- as.data.frame(peak_anno_summits_dataframe)
#target.genes_summits <- 

#BiocManager::install("clusterProfiler")
library (clusterProfiler)

#BiocManager::install("org.At.tair.db")
library(org.At.tair.db)

txdb_genes <- as.data.frame(genes(txdb))
atha_genes <- txdb_genes$gene_id

enrichGO <- enrichGO(gene=target.genes, OrgDb= org.At.tair.db,
                    keyType= "TAIR", ont= "ALL", universe= atha_genes)

head(enrichGO)
barplot(enrichGO)

enrichmentgo <- as.data.frame(enrichGO)
write.csv(enrichmentgo, file = "enrichment_GO.csv")

