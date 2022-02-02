#! /bin/bash

## Authors: Sebastian Flores Salva - asfloressalva@yahoo.es
##	    Mª Teresa Gonzalez de la Rosa - teresaglez.2000@gmail.com
##	    Jaime Hiniesta Valero - jaimehiva@gmail.com
## 	    Angela Jimenez Velasco - angela21072000@gmail.com

##Welcome to our Chip Seq Analysis in aRabidopsis pipeline, CSAR.
## Load parameters from file

## Load parameters from file

## Input file name
parameters=$1



## Help message

if [ $# -ne 1 ];
then
	echo "Error: The number of parameters is wrong."
	echo ""
	echo "Usage: chip_seq_analysis <param_file>"
	echo ""
	echo "param_file: A file specifying the parameters for the ChIP-seq."
	echo " 		   Data Analysis Pipeline. The folder test contains "
	echo "		   several examples such as chip_test_parameters.txt. "
	echo "	 	   Check the README file for details on how to write "
	echo " 		   the parameter file. "
	exit

fi


echo "1. LOADING PARAMETERS FROM FILE" $parameters
echo -----------------------------------------------

## Load installation directory
INSDIR=$(grep "installation_directory:" $parameters | awk '{print $2}')

## Load working directory
WD=$(grep "working_directory:" $parameters | awk '{ print $2 }')

## Creating the folder name
FD=$(grep "folder_name:" $parameters | awk '{ print $2 }')

## Loading the genome
GN=$(grep "genome:" $parameters | awk '{ print $2 }')

## Loading the annotation
AN=$(grep "annotation:" $parameters | awk '{ print $2 }')

## Load the number of samples
NUMSAM=$(grep "number_samples:" $parameters | awk '{ print $2 }')

##Load the doble of samples
NUMREP=$(grep "doble_samples:" $parameters | awk '{ print $2 }')

## Creating the scripts folder
SC=$(grep "folder_scripts:" $parameters | awk '{ print $2 }')

## Load paired end data
PAIRED=$(grep "number_chain_end:" $parameters | awk '{ print $2 }')

## Load promoter length
PROMOTER=$(grep "promoter_length:" $parameters | awk '{ print $2 }')

##Load type of process of the samples
SL=$(grep "selection:" $parameters | awk '{ print $2 }')

## Load TF name
TF=$(grep "transcription_factor:" $parameters | awk '{ print $2 }')

i=1
if [ $PAIRED == FALSE ]
then
   CHIP=()
   INPUT=()
   while [ $i -le $NUMSAM ]
   do
	CHIP[$i]=$(grep "chip_"${i}":" $parameters | awk '{ print $2 }')
	INPUT[$i]=$(grep "input_"${i}":" $parameters | awk '{ print $2 }')
	((i++))
   done
else
   CHIP_left_=()
   CHIP_right_=()
   INPUT_left_=()
   INPUT_right=()
   while [ $i -le $NUMSAM ]
   do
	CHIP_left_[$i]=$(grep "chip_left_"${i}":" $parameters | awk '{ print $2 }')
	CHIP_right_[$i]=$(grep "chip_right_"${i}":" $parameters | awk '{ print $2 }')
	INPUT_left_[$i]=$(grep "input_left_"${i}":" $parameters | awk '{ print $2 }')
	INPUT_right_[$i]=$(grep "input_right_"${i}":" $parameters | awk '{ print $2 }')
        ((i++))
   done
fi


echo ""
echo "Parameters has been loaded"
echo ""
echo "Installation directory:" $INSDIR
echo "Working directory:" $WD
echo "Folder name:" $FD
echo "Genome:" $GN
echo "Annotation:" $AN
echo "Number of samples:" $NUMSAM
echo "Number doble:" $NUMREP
echo "Chip samples:" ${CHIP[1]}
echo "Input samples:" ${INPUT[1]}
echo "Paired end:" $PAIRED
echo "Transcription factor:" $TF

echo ""
echo "2. GENERATION OF THE WORKING DIRECTORY ESTRUCTURE"
echo ----------------------------------------------------

## Working directory accession
cd $WD

## Creating the folder name and accession
mkdir $FD
cd $FD

## Generating the subfolders
mkdir results genome annotation samples scripts

## Accession, copying and unziping the genome
cd genome
cp $GN genome.fa

##Generating the genome index
bowtie2-build genome.fa index
cd ..

##Generating a blackboard
cd results
touch blackboard
cd ..

## Accession, copying and unziping the annotation
cd annotation
cp $AN annotation.gtf

## Move sample_processing script to the scripts folder
cp $INSDIR/sample_processing.sh ../scripts
cp $INSDIR/peak_calling.sh ../scripts
cp $INSDIR/final_report.sh ../scripts
cp $INSDIR/R_analysis_chipseq.R ../scripts
cd ..

##Accession and generating samples folder
cd samples
if [ $PAIRED == FALSE ]
then
   echo "The samples are single end"
   i=1
   while [ $i -le $NUMSAM ]
	do
		mkdir input_$i chip_$i
		cd input_$i
		$SL ${INPUT[$i]} ./input_$i.fq.gz
		cd ../chip_$i
		$SL ${CHIP[$i]} ./chip_$i.fq.gz
	cd ..
	((i++))
	done
elif [ $PAIRED == TRUE ]
then
   echo "The samples aire paired end"
   i=1
   while [ $i -le $NUMSAM ]
	do
		mkdir input_$i chip_$i
		cd input_$i
		$SL ${INPUT_left_[$i]} ./input_${i}_1.fq.gz
		$SL ${INPUT_right_[$i]} ./input_${i}_2.fq.gz
		cd ../chip_$i
		$SL ${CHIP_left_[$i]} ./chip_${i}_1.fq.gz
		$SL ${CHIP_right_[$i]} ./chip_${i}_2.fq.gz
		((i++))
		cd ..
	done
else
	echo ""
	echo "Warning: Single or paired end must be specified"
	echo ""
fi


echo "3. SAMPLE PROCESSING"
echo -----------------------

cd ../scripts

j=1

while [ $j -le $NUMSAM ]
   do
	sbatch $SC/sample_processing.sh $WD/$FD/samples/input_${j} $j $NUMSAM $SC 1 $PAIRED $WD $FD $PROMOTER $NUMREP $TF
	sbatch $SC/sample_processing.sh $WD/$FD/samples/chip_${j} $j $NUMSAM $SC 2 $PAIRED $WD $FD $PROMOTER $NUMREP $TF
	j=$(($j + 1))
   done

cd ..

echo ""
echo "Currently running jobs, check the progress with the command *squeue*"
echo "This may take some minutes, be patient"
echo "You can also check the progress with the Slurm files generated in scripts and results"
echo "		ChIP analysis done!"
echo "Output reports can be found in the results folder"
