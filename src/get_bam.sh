#!/bin/bash

# script in ASAP demultiplexing pipeline to copy relevant files from output into tmp folder

#$1 = bam dir
#$2 = MOC number
#$3 = pool number
#$4 = tmp dir

#dir=$1/$2
dir=$1

subpools=()
for folder in "$dir"/*; do
  if [ -d "$folder" ]; then
    foldername=$(basename "$folder")
    # Check if the folder name matches the pattern MOC{XX}_{1,2,3,4}{letter}
    if [[ "$foldername" =~ ^$2_[1234][a-zA-Z]$ ]]; then
      # Extract the number from the folder name
      pool_number=${foldername:6:1}
      # Extract the letter from the folder name
      pool_letter=${foldername:7:1}
      # If the number matches the specified number, add the letter to the array
      if [ "$pool_number" -eq "$3" ]; then
        subpools+=("$pool_letter")
      fi

      cp $dir/$2_$3$pool_letter/outs/atac_possorted_bam.bam $4
      mv $4/atac_possorted_bam.bam $4/${2}_pool${3}${pool_letter}_ATAC.bam

      cp $dir/$2_$3$pool_letter/outs/atac_possorted_bam.bam.bai $4
      mv $4/atac_possorted_bam.bam.bai $4/${2}_pool${3}${pool_letter}_ATAC.bam.bai

      cp $dir/$2_$3$pool_letter/outs/gex_possorted_bam.bam $4
      mv $4/gex_possorted_bam.bam $4/${2}_pool${3}${pool_letter}_GEX.bam

      cp $dir/$2_$3$pool_letter/outs/gex_possorted_bam.bam.bai $4
      mv $4/gex_possorted_bam.bam.bai $4/${2}_pool${3}${pool_letter}_GEX.bam.bai

      cp $dir/$2_$3$pool_letter/outs/filtered_feature_bc_matrix/barcodes.tsv.gz $4
      mv $4/barcodes.tsv.gz $4/${2}_pool${3}${pool_letter}_barcodes.tsv.gz
      #zcat $4/barcodes.tsv.gz | sed s/^/pool${3}${pool_letter}_/ | gzip > $4/${2}_pool${3}${pool_letter}_barcodes.tsv.gz

    fi
  fi
done

# as an expected output, you should have all renamed, bamfiles in the specified tmp folder now
