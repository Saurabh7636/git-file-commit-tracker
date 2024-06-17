#!/bin/bash

###########################################################
# Script: commit_info.sh
# Description: Extracts commit information from files within
#              a Git repository and organizes it into a CSV file.
# Author: Your Name
# Date: June 2024
#
# Usage:
#   - Ensure the script is executed within a Git repository.
#   - Run the script: `bash commit_info.sh`
#   - Follow the prompts to select directories for scanning.
#   - Outputs:
#     - `commit_info_output/commit_info.csv`: CSV file with commit details.
#     - `commit_info_output/scanned_files.log`: Log of scanned files.
#     - `commit_info_output/excluded_dirs.log`: Log of excluded directories.
###########################################################

# Define output directory
output_dir="commit_info_output"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Define output CSV and log files inside the output directory
output_file="$output_dir/commit_info.csv"
scanned_files="$output_dir/scanned_files.log"
excluded_dirs="$output_dir/excluded_dirs.log"

# Check if the current directory is a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: This script must be run within a Git repository."
    exit 1
fi

# Create or overwrite the CSV file and add the header
echo "File,Last Commit ID,Author,Message,Date" > "$output_file"
> "$scanned_files"  # Clear the scanned files log
> "$excluded_dirs"  # Clear the excluded directories log

# Get a list of main directories
main_dirs=$(find . -maxdepth 1 -type d | cut -c 3- | grep -v "^$")

# Ask the user whether to scan each main directory
included_dirs=()
for dir in $main_dirs; do
    echo -n "Do you want to scan the directory '$dir'? (y/n): "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        included_dirs+=("$dir")
    else
        echo "$dir" >> "$excluded_dirs"
    fi
done

# Get the total number of files to be scanned
total_files=$(git ls-files | wc -l)
files_to_scan=0

# Calculate the number of files in the included directories
for file in $(git ls-files); do
    for dir in "${included_dirs[@]}"; do
        if [[ "$file" == "$dir/"* || "$dir" == "." ]]; then
            files_to_scan=$((files_to_scan + 1))
            break
        fi
    done
done

# Initialize counters and start time
files_scanned=0
start_time=$(date +%s)

# Function to update the progress bar
update_progress() {
    local current=$1
    local total=$2
    local elapsed_time=$3
    local progress=$((current * 100 / total))
    local remaining=$((total - current))
    local time_per_file=$(bc -l <<< "scale=2; $elapsed_time / $current")
    local est_remaining_time=$(bc -l <<< "scale=2; $time_per_file * $remaining")
    
    printf "\rScanning files: [%3d%%] (%d/%d) | Elapsed: %ds | Remaining: ~%.0fs" \
        "$progress" "$current" "$total" "$elapsed_time" "$est_remaining_time"
}

# Loop through all files in the included directories
for file in $(git ls-files); do
    # Check if the file is in one of the included directories
    include_file=false
    for dir in "${included_dirs[@]}"; do
        if [[ "$file" == "$dir/"* || "$dir" == "." ]]; then
            include_file=true
            break
        fi
    done
    
    if [ "$include_file" = true ]; then
        # Get the last commit ID for the file
        last_commit_id=$(git log -1 --format="%H" -- "$file")
        
        # Get the author of the last commit
        last_commit_author=$(git log -1 --format="%an" -- "$file")
        
        # Get the commit message of the last commit
        last_commit_message=$(git log -1 --format="%s" -- "$file")
        
        # Get the exact date and time of the last commit in yyyy-mm-dd HH:MM:SS format
        last_commit_date=$(git log -1 --format="%cd" --date=format:"%Y-%m-%d %H:%M:%S" -- "$file")
        
        # Append the information to the CSV file
        echo "\"$file\",\"$last_commit_id\",\"$last_commit_author\",\"$last_commit_message\",\"$last_commit_date\"" >> "$output_file"
        
        # Record the file that was scanned
        echo "$file" >> "$scanned_files"
        
        # Increment the scanned files counter
        files_scanned=$((files_scanned + 1))
        
        # Update progress bar
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        update_progress "$files_scanned" "$files_to_scan" "$elapsed_time"
    fi
done

# Print the summary
echo -e "\n\nSummary:"
echo "Total files to scan: $files_to_scan"
echo "Total files scanned: $files_scanned"
echo "Excluded directories:"
cat "$excluded_dirs"

echo "Commit information written to $output_file."

# No need to remove the log files as they are part of the output directory
