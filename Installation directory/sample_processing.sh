#!/bin/bash

echo "5. QUALITY ANALISIS AND MAPPING TO REFERENCE GENOME"
echo ------------------------------------------------------

samples_model=$1
i=$2
NUMSAM=$3
SC=$4
model=$5
PAIRED=$6
WD=$7
FD=$8
PROMOTER=$9
NUMREP=${10}
TF=${11}

cd $samples_model


if [ $PAIRED == FALSE ]
then
   if [ $model -eq 1 ]
   then
	fastqc input_${i}.fq.gz
	gzip -d input_${i}.fq.gz
	bowtie2 -x ../../genome/index -U input_${i}.fq -S input_${i}.sam
	samtools sort -o input_${i}.bam input_${i}.sam
	samtools index input_${i}.bam
  rm *.sam
# rm *.fq
	cd ..
   elif [ $model -eq 2 ]
   then
	fastqc chip_${i}.fq.gz
	gzip -d chip_${i}.fq.gz
	bowtie2 -x ../../genome/index -U chip_${i}.fq -S chip_${i}.sam
	samtools sort -o chip_${i}.bam chip_${i}.sam
	samtools index chip_${i}.bam
	rm *.sam
#	rm *.fq
	cd ..
   fi
elif [ $PAIRED == TRUE ]
then
   if [ $model -eq 1 ]
   then
	fastqc input_${i}_1.fq.gz
	fastqc input_${i}_2.fq.gz
	gzip -d input_${i}_1.fq.gz
	gzip -d input_${i}_2.fq.gz
	bowtie2 -x ../../genome/index -1 input_${i}_1.fq -2 input_${i}_2.fq -S input_${i}.sam
	samtools sort -o input_${i}.bam input_${i}.sam
	samtools index input_${i}.bam
	rm *.sam
#	rm *.fq
	cd ..
   elif [ $model -eq 2 ]
   then
	fastqc chip_${i}_1.fq.gz
	fastqc chip_${i}_2.fq.gz
	gzip -d chip_${i}_1.fq.gz
	gzip -d chip_${i}_2.fq.gz
	bowtie2 -x ../../genome/index -1 chip_${i}_1.fq -2 chip_${i}_2.fq -S chip_${i}.sam
	samtools sort -o chip_${i}.bam chip_${i}.sam
	samtools index chip_${i}.bam
	rm *.sam
#	rm *.fq
	cd ..
   fi
fi

echo ""
echo "Mapping succesfully done. You're doing a great job"
echo ""


## Write onto blackboard
if [ $model -eq 1 ]
then
   echo "Finished processing sample" input_${i} >> ../results/blackboard
elif [ $model -eq 2 ]
then
   echo "Finished processing sample" chip_${i}  >> ../results/blackboard
fi

## Read the blackboard and count the number of lines to check the number of processed samples
NREPDONE=$(wc -l ../results/blackboard | awk '{ print $1 }')
echo "Numbers of replicates processed are" $NREPDONE
echo ""
echo $NUMREP

cd ../results

## Checking if all replicates are processed for peak calling
if [ $NREPDONE -eq $NUMREP ]
then
   echo "All replicates have been processed"
   echo "Generating a blackboard for the peak.call"
   touch blackboard_peaks
   cd ../scripts
   sbatch $SC/peak_calling.sh $NUMSAM $NREPDONE $model $SC $WD $FD $PROMOTER $TF
else
   echo "Not all replicates have been processed. Please wait. Currently, "$NREPDONE" replicates processed"
fi

