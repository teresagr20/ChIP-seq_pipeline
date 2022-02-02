# CSAR - ChIP-seq_pipeline
## CSAR - ChIP-Seq Analysis in aRabidopsis thaliana

## **Welcome to CSAR!**

### What is this tool for?

We present our ChIP-seq data analysis pipeline, an instinctive computational bash pipeline particularly designed to process ChIP-seq data.

CSAR is composed of a sort of scripts with the capacity of automatically generating peak expression files starting from raw fastq files. These generated files can be runned in Rstudio with the aim of obtaining more information about the transcription factor’s target genes. When finished, the HOMER findMotifsGenome tool was added in order to find the sequence which is most likely identified by your transcription factor.

### How to install it?

The correct functioning of the pipeline requires the previously installation of the following:

* [**FASTQC: A quality control tool for high throughput sequence data**] (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
* [Bowtie 2: an ultrafast and memory-efficient tool for aligning sequencing reads to long reference sequences] (http://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
* [Samtools: Reading/writing/editing/indexing/viewing SAM/BAM/CRAM format] (http://www.htslib.org/)
* [MACS2: Model-based Analysis for ChIP-Seq] (https://pypi.org/project/MACS2/)
* [R: free software environment for statistical computing and graphics with the following packages:]
(https://www.r-project.org/)
  + ChIPseeker 
  + Ballgown
  + TxDB of the organism of study 
  + .db file of the organism of study (org.At.tair.db for Arabidopsis)
  + clusterProfiler
  + pathview
 
* [The HOMER program and the information of the organism of study in format fq.gz.]
  + Please, make sure you add your script file to your PATH so that HOMER can produce the desired results.
When installed, follow these steps:


  1. Create a folder called with your *TF’s name* in your home directory using the instruction mkdir.


```
cd 
mkdir  <TF’s folder>
```
 
  2. Download the code from Github to your home folder, for example:

```
cd 
git clone https://github.com/teresagr20/ChIP-seq_pipeline
```
 
  3. Copy the *installation directory* folder and the *parameters.txt* script to your *<TF’s folder>*.

```
cd ChIP-seq_pipeline
cp -r Installation\ directory/ ../<TF’s folder>
cp parameters.txt ../<TF’s folder>
```
 
  4. Change the *parameters.txt* script to adjust it to your analysis. The meaning of each parameter is explained below.

### Scripts

* parameters.txt

In this script, you have to fill the parameters in relation to your ChIP-seq experiment. An example is given for each parameter.

  1. installation_directory: This is the path to the scripts you have downloaded.
  2. working_directory: This is the path to your *TF’s folder* where you have the *installation_directory* and *parameters.txt*
  3. folder_name: Here you have to choose the name of the output folder that is going to contain the results and the processing of the samples.
  4. genome: This is the path to the file that contains the genome of reference in .fa extension.
  5. annotation: This is the path to the file that contains the annotation of the genome of reference in .gtf extension.
  6. number_samples: Here you have to set the number of samples you are processing.
  7. doble_samples: This is the double of samples you are processing. This parameter is created for the replicates.
  8. chip_(left/right)_@: This is the path to the chip sample number @, the sample must be in .fq.gz extension. If you are working with paired end sequences you have to add left or right to differ between both files.
  9. input_(left/right)_@: This is the path to the control sample number @, the sample must be in .fq.gz extension. If you are working with paired end sequences you have to add left or right to differ between both files.
  10. folder_scripts: This is the path to the folder with the scripts that will be moved during the command running. By general, it will be *working_directory/test/folder_name/scripts*
  11. number_chain_end: Here you have to denote if your sample is single end *(FALSE)* when there is a single fastq file per sample; or pair end *(TRUE)* when there are two fastq files 1 and 2 per sample.
  12. promoter_length: Here you have to indicate the average length of the promoter in pb 
  13. transcription_factor: Here you have to indicate the name of the transcription factor that you are investigating to generate the target_gene file with its name
  14. selection: Normally this parameter takes the argument mv or cp, this will indicate what the program will do with your samples.

* **chip_seq_analysis.sh**

Your pipeline will start with the launching of this script. The instruction to launch it is *./installation_directory/chip_seq_analysis.sh parameters.txt*. Then, the program using the parameters.txt script will automatically follow the provided instructions, organizing the workspace and the data. Once this is established, the genome index will be created and the chip and input samples will also be automatically processed by the launching of the sample_processing.sh script.

* **sample_processing.sh**

This script will process every chip and input sample provided in *parameters.txt*. The processing will start with a quality analysis and the mapping to the reference genome. It is worth to be mentioned that these instructions are designed to consider the possibility of single or paired ended samples all the time. Once it is done, the script will check if all the replicates are processed for peak calling. If everything is correctly done, the peak_calling script will be launched.

* **peak_calling.sh**

This script will do the peak calling using the instruction macs2. Once the peaks are generated the process will be checked and if everything is in order the final_report.sh script will be launched.

* **final_report.sh**

This script is designed to do the peak analysis using the HOMER and RStudio tools. The HOMER analysis is executed by using the findMotifsGenome.pl instruction and the R analysis will be done by launching the R script.


* **R_analysis_chipseq.R**

This R script will provide you a list of target genes recognised by your transcription factor and other information related to target gene functions as the GEO terms enrichment using the function enrichGO.  

### How to use it?

To run CSAR you have to generate a parameters.txt file with all the parameters listed above. You will find a template of this file in the download folder. 

Once you have filled the *parameters.txt*, in order to run the function you have to use the executable chip_seq_analysis.sh with *parameters.txt* as the input. It is recommended to execute the function from your *<TF’s folder>* as indicated in the following line:

```
./installation_directory/chip_seq_analysis.sh <parameters.txt>
```

Before executing the function, check that the *<TF’s folder>* contains the file *<parameters.txt>* and the *installation_directory* folder with the scripts downloaded from our GitHub. You can verify the progress of the process by checking the slurm generated scripts.

### Results

The final report and the result files generated during the execution of the CSAR pipeline will be saved in your *<TF’s folder>*.
The CSAR output folders for a Chip-seq data analysis consists of the following subfolders:
samples: This folder contains a subfolder for each sample with files for quality control (fastqc), mapping stats, transcript assembly and mapping information for exons, transcripts and introns (bam, bam.bai).
results: This folder contains the information of the results of the peak calling, HOMER and RStudio as the generated slurm script of the final_report.sh.

### References

 * BOWTIE2:
Langmead B. et al(2018). Scaling read aligners to hundreds of threads on general-purpose processors. Bioinformatics.
Langmead B. et al (2012). Fast gapped-read alignment with Bowtie 2. Nature Methods. 4;9(4):357-9.

* FASTQC:
Andrews, S. (2010). FastQC: A Quality Control Tool for High Throughput Sequence Data [Online].
SAMTOOLS:
Li H. et al (2009) The Sequence alignment/map (SAM) format and SAMtools. Bioinformatics, 25, 2078-9.

* MACS2:
Zhang Y. et al (2008). Model-based Analysis of ChIP-Seq (MACS). Genome Biology, 9:R137.

* HOMER:
Heinz S., Benner C., Spann N., Bertolino E. et al. (2010) Simple Combinations of Lineage-Determining Transcription Factors Prime cis-Regulatory Elements Required for Macrophage and B Cell Identities. Mol. Cell. May 28;38(4):576-589.

* R:
R Core Team (2018). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. URL https://www.R-project.org/.

* RStudio:
RStudio Team (2020). RStudio: Integrated Development Environment for R. RStudio, PBC, Boston, MA. URL http://www.rstudio.com/.

* Bioconductor packages for R analysis:
ChIPseeker: Yu G. et al (2015). ChIPseeker: an R/Bioconductor package for ChIP peak annotation, comparison and visualization. Bioinformatics 2015, 31(14):2382-2383
TxDb.Athaliana.BioMart.plantsmart28: Carlson M, Maintainer BP (2015). TxDb.Athaliana.BioMart.plantsmart28: Annotation package for TxDb object(s).
Org.at.tair.db: Carlson M. (2019). org.At.tair.db: Genome wide annotation for Arabidopsis. R package version 3.8.2.
DO.db: Li J (2015). DO.db: A set of annotation maps describing the entire Disease Ontology.
ClusterProfiler: Yu G. et al (2012). clusterProfiler: an R package for comparing biological themes among gene clusters. OMICS: A Journal of Integrative Biology, 16(5):284-287
Pathview: Luo, W and Brouwer C (2013). Pathview: an R/Bioconductor package for pathway-based data integration and visualization. Bioinformatics, 29(14), 1830-1831.
KEGG:
Kanehisa M. and Goto, S. (2000). KEGG: Kyoto Encyclopedia of Genes and Genomes. Nucleic Acids Res. 28, 27-30.
Kanehisa M (2019). Toward understanding the origin and evolution of cellular organisms. Protein Sci. 28, 1947-1951.
Kanehisa M. et al (2021). KEGG: integrating viruses and cellular organisms. Nucleic Acids Res. 49, D545-D551.


If you have any further questions, do not hesitate to ask the developers:

Ángela Jiménez (angela21072000@gmail.com).
Teresa González (teresaglez.2000@gmail.com)
Jaime Hiniesta Valero (jaimehiva@gmail.com)
Sebastián Flores Salva (asfloressalva@gmail.com)
