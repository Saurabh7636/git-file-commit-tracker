# Commit Info Script (commit_info.sh)

## Overview
The `commit_info.sh` script is a Bash tool designed to extract and organize commit information from files within a Git repository. It creates a CSV file (`commit_info.csv`) containing details such as the last commit ID, author, message, and date for each file, based on user-selected directories.

## Features
- **User Interaction**: Allows users to choose directories for scanning within the Git repository.
- **Commit Details**: Retrieves and records commit information (ID, author, message, date) for each selected file.
- **Logging**: Maintains logs (`scanned_files.log`, `excluded_dirs.log`) to track scanned files and excluded directories.
- **Progress Tracking**: Displays a progress bar indicating the status of file scanning.

## Prerequisites
- **Git**: Ensure the script is executed within a Git repository that you want to scan.

## Usage
1. **Clone Repository**:
   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. **Run the Script**:
   ```bash
   bash commit_info.sh
   ```

3. **Follow Prompts**:
   - The script will prompt you to choose directories within the repository to scan (`y` for yes, `n` for no).
   - It will display a progress bar showing the scanning status.

4. **Review Output**:
   - Upon completion, a CSV file (`commit_info.csv`) will be generated in the `commit_info_output` directory.
   - Check the summary for details on files scanned, excluded directories, and the location of the CSV file.

## Output Format (commit_info.csv)
The `commit_info.csv` file is formatted as follows:

| File                       | Last Commit ID    | Author      | Message                  | Date                |
|----------------------------|-------------------|-------------|--------------------------|---------------------|
| "path/to/file.ext"         | "commit_id_hash"  | "author_name" | "commit_message"        | "YYYY-MM-DD HH:MM:SS"|

- **File**: Path to the file within the repository.
- **Last Commit ID**: Hash identifying the last commit affecting the file.
- **Author**: Name of the author who made the last commit.
- **Message**: Commit message describing changes made.
- **Date**: Date and time of the last commit in `YYYY-MM-DD HH:MM:SS` format.

## Files Generated
- **commit_info.csv**: Contains commit information for selected files.
- **scanned_files.log**: Log of files scanned during script execution.
- **excluded_dirs.log**: Log of directories excluded from scanning based on user input.

## Example
```bash
$ bash commit_info.sh
Do you want to scan the directory 'src'? (y/n): y
Do you want to scan the directory 'docs'? (y/n): n
Do you want to scan the directory 'tests'? (y/n): y
...
```

## Notes
- Ensure the script (`commit_info.sh`) has executable permissions (`chmod +x commit_info.sh`) if running directly without `bash`.
- Logs (`scanned_files.log`, `excluded_dirs.log`) are retained in the `commit_info_output` directory as part of script output.

## License
This script is licensed under the MIT License. See LICENSE file for more details.