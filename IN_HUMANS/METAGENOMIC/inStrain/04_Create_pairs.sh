#!/bin/bash

#SBATCH --job-name 05_Create_pairs
#SBATCH --output /scratch/mcreze/InStrain_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/mcreze/InStrain_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 1G
#SBATCH --time 00:10:00

# Directories
profile_dir=/scratch/mcreze/InStrain_scratch/instrain_output/instrain_profile

# List child samples
find ${profile_dir} -type d -name 'C1WST*' > child_samples.txt

# List mother samples
find ${profile_dir} -type d -name 'MPST*' > mother_samples.txt

# Generate pairs
while IFS= read -r child; do
    # Extract the numeric part of the child sample
    child_num=$(basename $child | sed -E 's/^C1WST([0-9]+)_inStrainOut$/\1/')

    # Find the corresponding mother sample
    mother=$(grep "MPST${child_num}_inStrainOut" mother_samples.txt)

    # Check if the pair exists
    if [ -n "$mother" ]; then
        echo "$mother $child" >> pairs.txt
    else
        echo "No matching mother sample for $child"
    fi
done < child_samples.txt

# Clean up the file (to be replaced by your location)
sed -i 's|/scratch/mcreze/InStrain_scratch/instrain_output/instrain_profile/||g' pairs.txt

# Clean up temporary files
rm child_samples.txt mother_samples.txt
