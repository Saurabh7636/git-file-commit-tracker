# Bash Script Explanation: `commit_info.sh`

### Purpose
The `commit_info.sh` script is designed to gather and organize commit information from a Git repository, specifically focusing on files within user-specified directories. It creates a CSV file (`commit_info.csv`) containing details such as the last commit ID, author, message, and date for each file.

### Script Breakdown

#### Initialization and Setup
```bash
#!/bin/bash

# Define output directory
output_dir="commit_info_output"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Define output CSV and log files inside the output directory
output_file="$output_dir/commit_info.csv"
scanned_files="$output_dir/scanned_files.log"
excluded_dirs="$output_dir/excluded_dirs.log"
```
- **Purpose**: Sets up the script by defining necessary variables and creating the output directory and files.
- **Explanation**: 
  - `output_dir`: Directory where all output files will be stored.
  - `output_file`: Path to the CSV file where commit information will be stored.
  - `scanned_files` and `excluded_dirs`: Logs to record scanned files and excluded directories respectively.

#### Checking Git Repository
```bash
# Check if the current directory is a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "This is not a git repository."
    exit 1
fi
```
- **Purpose**: Ensures the script is executed within a Git repository.
- **Explanation**: Uses `git rev-parse --is-inside-work-tree` to check if the current directory is a Git repository. If not, it exits with an error message.

#### User Interaction for Directory Selection
```bash
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
```
- **Purpose**: Prompts the user to choose directories for scanning.
- **Explanation**: 
  - `main_dirs`: Lists top-level directories in the repository.
  - For each directory, it asks the user if they want to include it (`included_dirs`) or exclude it (`excluded_dirs`).

#### Counting and Scanning Files
```bash
# Calculate the number of files to scan
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
```
- **Purpose**: Counts and prepares to scan files.
- **Explanation**: 
  - `total_files`: Total files in the repository.
  - `files_to_scan`: Files selected for scanning based on user's directory choices.

#### Scanning and Recording Commit Information
```bash
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
        # Get commit details for the file
        last_commit_id=$(git log -1 --format="%H" -- "$file")
        last_commit_author=$(git log -1 --format="%an" -- "$file")
        last_commit_message=$(git log -1 --format="%s" -- "$file")
        last_commit_date=$(git log -1 --format="%cd" --date=format:"%Y-%m-%d %H:%M:%S" -- "$file")
        
        # Append information to CSV file
        echo "\"$file\",\"$last_commit_id\",\"$last_commit_author\",\"$last_commit_message\",\"$last_commit_date\"" >> "$output_file"
        
        # Record scanned file
        echo "$file" >> "$scanned_files"
        
        # Update progress
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))
        update_progress "$files_scanned" "$files_to_scan" "$elapsed_time"
    fi
done
```
- **Purpose**: Retrieves commit information for each selected file.
- **Explanation**: 
  - For each file in `included_dirs`, it retrieves the last commit ID, author, message, and date using `git log`.
  - Appends this information formatted as CSV to `commit_info.csv` and logs the file in `scanned_files`.
  - Updates a progress bar to indicate scanning progress.

#### Summary
```bash
# Print the summary
echo -e "\n\nSummary:"
echo "Total files to scan: $files_to_scan"
echo "Total files scanned: $files_scanned"
echo "Excluded directories:"
cat "$excluded_dirs"

echo "Commit information written to $output_file."
```
- **Purpose**: Provides a summary of the script execution.
- **Explanation**: 
  - Displays total files selected for scanning, files actually scanned, and lists directories excluded from scanning.
  - Informs where the commit information CSV (`commit_info.csv`) is stored.

#### Conclusion
```bash
# No need to remove the log files as they are part of the output directory
```
- **Explanation**: 
  - Notes that log files (`scanned_files.log`, `excluded_dirs.log`) are retained as they form part of the script's output.

### Conclusion
The `commit_info.sh` script efficiently manages Git repository traversal, user interaction, and commit data extraction, culminating in a detailed CSV report (`commit_info.csv`) and summary of operations.

---

> This markdown file provides a comprehensive explanation of how `commit_info.sh` works, from initialization to completion, ensuring clarity on each function and purpose within the script.