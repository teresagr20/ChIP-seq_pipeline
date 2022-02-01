#!/bin/bash

echo "6. PEAK CALLING"
echo ------------------

NUMSAM=$1
NREPDONE=$2
model=$3
SC=$4
WD=$5
FD=$6
PROMOTER=$7
TF=$8

## Peak calling and write onto blackboard_peak
cd ../results
mkdir peak_calling
cd peak_calling

i=1
while [ $i -le $NUMSAM ]
do
	echo "Peak calling with input sample"
  	macs2 callpeak -t ../../samples/chip_${i}/chip_${i}.bam -c ../../samples/input_${i}/input_${i}.bam -f BAM --outdir ./ -n replicate_${i}

echo "Peak calling replicate_" ${i} "done" >> ../blackboard_peaks
((i++))
done

cd ..

## Checking peak calling process
NUMPEAK=$(wc -l ./blackboard_peaks | awk '{ print $1 }')

if [ $NUMSAM -eq $NUMPEAK ]
then
   echo "Peak calling has finished"
   echo "Great job!"
else
   echo "Warning: peak calling couldn't finished"
   echo "Please, check the parameters and try again"
fi


## Generating final report

sbatch $SC/final_report.sh $NUMSAM $SC $WD $FD $PROMOTER $TF
