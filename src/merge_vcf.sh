#!/bin/bash
#Author: Jarne Geurts (T. Voet lab)
#Script to merge the specified VCF files in the seperate file to use in WGS analysis

# --> given a samplesheet containing different patients, loops over these files, copies them over to output folder, change name, index & combines these in object.
# Afterwards, all these VCF files are merged using bcftools

# Read samplecodes from file
#initiate
APPENDIX=".pileup.vcf.gz" # = Appendix to be removed, change this or remove if completely specified in samplesheet
PREFIX=$1 # =filepath to vcf files
FILE_LIST=$2 # = samplesheet containing all identifiers/sample ID's of patients
NEW_FILES=""

mkdir -p $6/vcf
echo "Samples in samplesheet:" > $7

#loop through samplesheetlist and copy over files
while IFS= read -r FILE; do
  ORIGINAL_FILE="${PREFIX}/${FILE}${APPENDIX}"
  echo "${ORIGINAL_FILE}"
  echo "${FILE}" >> $7
  # Check if the file exists, if not, flag this and resume 
  if [ -f "$ORIGINAL_FILE" ]; then
    cp $ORIGINAL_FILE $6/vcf
    NEW_FILE="${6}/vcf/${FILE}${APPENDIX}"
    #index 
    $3 index -t -f $NEW_FILE
    
    # append all in list
    if [ -z "$NEW_FILES" ]; then
      NEW_FILES="$NEW_FILE"
    else
      NEW_FILES="$NEW_FILES $NEW_FILE"
    fi
  else
    echo "Warning: $NEW_FILE does not exist and will not be added."
  fi
done < "$FILE_LIST"

#print filelist in terminal & redirect to file

echo "VCF files taken for analysis: $NEW_FILES"
echo "VCF files taken for analysis: $NEW_FILES" >> $7

# merge all renamed, indexed files  


$3 merge $NEW_FILES --force-samples -Oz -0 --threads $5 --output $4
