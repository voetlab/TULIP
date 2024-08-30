#!/bin/bash

#$1 = tmp_dir
#$2 = MOC number
#3 = poolnumber
#4 = out barcodes

# add tag to barcodefile

for file in ${1}/${2}_pool${3}[a-zA-Z]_barcodes.tsv.gz; do
  if [ -f "$file" ]; then
    # Extract the base filename and the prefix (e.g., pool1{letter})
    base_filename=$(basename "$file")
    prefix=$(echo "$base_filename" | sed -E "s/^${2}_(pool${3}[a-zA-Z])_barcodes.tsv.gz/\1/")
    
    # Create a temporary file for the modified content
    temp_file=$(mktemp)

    # Process the file, adding the prefix to each line
    gunzip -c "$file" | awk -v prefix="$prefix" '{print prefix "_" $0}' > "$temp_file"

    # Compress the modified content back to .tsv.gz format
    gzip -c "$temp_file" > "$1/RENAMED_${base_filename}"
    
    # Remove the temporary file
    rm "$temp_file"
  fi
done

# merge all barcode files

zcat $1/RENAMED_* > $4

echo 'ATAC copied over' > $1/ATAC.done
echo 'GEX copied over' > $1/GEX.done

# remove tmp files 
# rm $1/RENAMED* 
# rm $1/*barcodes*


