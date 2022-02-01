#! /bin/bash

NUMSAM=$1
SC=$2
WD=$3
FD=$4
PROMOTER=$5
TF=$6

#HOMER analysis

mkdir homer
cd homer
i=1
while [ $i -le $NUMSAM ]
do
   mkdir motifs_$i
   cd motifs_$i
   findMotifsGenome.pl ../../peak_calling/replicate_${i}_summits.bed tair10 ./ -size 100 -len 8
   cd ..
   ((i++))
done

cd ..

echo ""
echo "Peaks analysis with HOMER succesfully done. "
echo ""

#R data analysis
mkdir R_results
cd R_results
i=1
while [ $i -le $NUMSAM ]
do
   mkdir R_results_$i
   cd R_results_$i
   echo "The promoter length is" $PROMOTER
   Rscript $SC/R_analysis_chipseq.R $PROMOTER ../../peak_calling/replicate_${i}_peaks.narrowPeak ../../peak_calling/replicate_${i}_summits.bed $TF
   cd ..
   ((i++))
done


