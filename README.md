# File Year Prepender

Utilities to prepend the file creation year to existing file names. Designed for Windows 11 environment.

## Overview

This repository provides two implementations for prepending file creation years to filenames:
- **Python script**: Cross-platform solution (`prepend_year.py`)
- **PowerShell script**: Native Windows solution (`Prepend-Year.ps1`)

Both scripts support:
- Single file processing
- Directory processing (with optional recursion)
- File extension filtering
- Dry-run mode (preview changes before applying)

## Python Script

### Requirements
- Python 3.6 or higher

### Usage

```bash
# Dry run on single file (preview only)
python prepend_year.py file.txt

# Actually rename single file
python prepend_year.py file.txt --execute

# Process all files in directory (dry run)
python prepend_year.py --directory ./videos

# Process all files in directory recursively
python prepend_year.py --directory ./videos --recursive --execute

# Process only specific file types
python prepend_year.py --directory ./videos --extensions .mp4 .avi --execute
```

### Command-Line Options

- `file`: File to process (single file mode)
- `-d, --directory`: Process all files in this directory
- `-r, --recursive`: Process subdirectories recursively
- `-e, --execute`: Actually rename files (default is dry run)
- `--extensions`: Only process files with these extensions (e.g., `.mp4 .avi`)

### Examples

```bash
# Preview changes for a video file
python prepend_year.py C:\Videos\vacation.mp4

# Rename all video files in a directory
python prepend_year.py --directory C:\Videos --extensions .mp4 .avi .mkv --execute

# Recursively rename all files
python prepend_year.py --directory C:\Documents --recursive --execute
```

## PowerShell Script

### Requirements
- Windows PowerShell 5.1 or PowerShell 7+
- Windows 11 (optimized for)

### Usage

```powershell
# Dry run on single file (preview only)
.\Prepend-Year.ps1 -Path "C:\Videos\video.mp4"

# Actually rename single file
.\Prepend-Year.ps1 -Path "C:\Videos\video.mp4" -Execute

# Process all files in directory
.\Prepend-Year.ps1 -Path "C:\Videos" -Execute

# Process all files in directory and subdirectories
.\Prepend-Year.ps1 -Path "C:\Videos" -Recursive -Execute

# Process only specific file types
.\Prepend-Year.ps1 -Path "C:\Videos" -Extensions ".mp4",".avi" -Execute
```

### Parameters

- `-Path`: The file or directory path to process (required)
- `-Recursive`: Process subdirectories recursively (optional)
- `-Execute`: Actually rename files (without this, runs in dry-run mode)
- `-Extensions`: Array of file extensions to filter (optional)

### Examples

```powershell
# Preview changes for a document
.\Prepend-Year.ps1 -Path "C:\Documents\report.docx"

# Rename all images in a directory
.\Prepend-Year.ps1 -Path "C:\Pictures" -Extensions ".jpg",".png",".gif" -Execute

# Recursively rename all office documents
.\Prepend-Year.ps1 -Path "C:\Work" -Recursive -Extensions ".docx",".xlsx",".pptx" -Execute
```

## How It Works

1. **Get Creation Year**: Reads the file's creation timestamp and extracts the year
   - On Windows: Uses the actual file creation time
   - On Unix/Linux: Uses the last metadata change time

2. **Check Existing Prefix**: Skips files that already have the year prepended

3. **Generate New Name**: Creates new filename in format: `YYYY_originalname.ext`

4. **Rename File**: Renames the file (or shows preview in dry-run mode)

## Example Output

### Before
```
vacation.mp4
holiday_2023.jpg
report.docx
```

### After
```
2022_vacation.mp4
2023_holiday_2023.jpg
2024_report.docx
```

## Safety Features

- **Dry-run mode by default**: Preview changes before applying
- **Duplicate detection**: Won't overwrite existing files
- **Already processed detection**: Skips files that already have year prefix
- **Error handling**: Gracefully handles permission errors and invalid paths

## Use Cases

- Organize media libraries by creation date
- Add temporal context to documents
- Batch rename photos and videos
- Archive files with creation year
- Prepare files for chronological sorting

## Platform Notes

### Windows 11
Both scripts work perfectly on Windows 11:
- PowerShell script is native and recommended
- Python script requires Python installation

### Cross-Platform
The Python script also works on:
- Windows 10
- Linux
- macOS

Note: On Unix-like systems, "creation time" may actually be the last metadata change time, depending on the filesystem.

## Troubleshooting

### Permission Errors
Run PowerShell as Administrator or ensure you have write permissions for the target files.

### Execution Policy (PowerShell)
If you get an execution policy error, run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Not Found (Python)
Ensure Python 3.6+ is installed:
```bash
python --version
```

## License

This project is provided as-is for utility purposes.
