#!/bin/bash

#$1 = tmp_dir
#$2 = MOC number
#3 = poolnumber
#4 = python
#5 = src
#6 = samtools
#7 = out merged bam

# add tag to barcodefile
NEW_FILES=""
for file in ${1}/${2}_pool${3}[a-zA-Z]_GEX.bam; do
  if [ -f "$file" ]; then
    # Extract the base filename and the prefix (e.g., pool1{letter})
    base_filename=$(basename "$file")
    prefix=$(echo "$base_filename" | sed -E "s/^${2}_(pool${3}[a-zA-Z])_GEX.bam/\1/")
    
    echo "Processing File: ${file}"
    echo "adding string: ${prefix}"

    $4 $5/modify_CB.py --bam $file --string $prefix --out $1/RENAMED_GEX_${2}_${prefix}.bam

    if [ -z "$NEW_FILES" ]; then
        NEW_FILES="$1/RENAMED_GEX_${2}_${prefix}.bam"
    else
      NEW_FILES="$NEW_FILES $1/RENAMED_GEX_${2}_${prefix}.bam"
    fi
  
  fi
done

# merge all GEX files
# merge all ATAC files

$6 merge $7 $NEW_FILES
$6 index $7


# remove tmp files m
rm $NEW_FILES
