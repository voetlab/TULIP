#!/bin/bash -l
#SBATCH --export="NONE"
#SBATCH --get-user-env="60L"
#SBATCH --job-name="MOC11"
#SBATCH --mail-type="BEGIN,END,FAIL,TIME_LIMIT"
#SBATCH --mail-user="jarne.geurts@kuleuven.be"
#SBATCH --nodes="1"
#SBATCH --ntasks-per-node="36"
#SBATCH --ntasks="36"
#SBATCH --time="48:00:00"
#SBATCH --account="llabvoet"

/staging/leuven/stg_00055/miniconda3/envs/VoetEnv/bin/snakemake --snakefile /staging/leuven/stg_00055/projects/ASAP/Multiome/Demultiplexing/Snakefile \
        --configfile /staging/leuven/stg_00055/projects/ASAP/Multiome/Demultiplexing/MOC11/config_Pool1.yaml  --cores 36

/staging/leuven/stg_00055/miniconda3/envs/VoetEnv/bin/snakemake --snakefile /staging/leuven/stg_00055/projects/ASAP/Multiome/Demultiplexing/Snakefile \
        --configfile /staging/leuven/stg_00055/projects/ASAP/Multiome/Demultiplexing/MOC11/config_Pool2.yaml  --cores 36
