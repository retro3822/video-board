#!/usr/bin/env python3
"""
Prepend file creation year to existing file names.
Designed for Windows 11 environment.
"""

import os
import sys
from datetime import datetime
from pathlib import Path


def get_creation_year(file_path):
    """
    Get the file creation year.
    On Windows, this returns the actual creation time.
    On Unix, this returns the last metadata change time.
    """
    try:
        # Get file stats
        stat_info = os.stat(file_path)

        # On Windows, st_ctime is creation time
        # On Unix, st_ctime is last metadata change time
        creation_time = stat_info.st_ctime

        # Convert to datetime and extract year
        creation_date = datetime.fromtimestamp(creation_time)
        return creation_date.year
    except Exception as e:
        print(f"Error getting creation year for {file_path}: {e}")
        return None


def prepend_year_to_filename(file_path, dry_run=True):
    """
    Prepend the creation year to the filename.

    Args:
        file_path: Path to the file
        dry_run: If True, only show what would be done without making changes

    Returns:
        Tuple of (success, old_name, new_name)
    """
    try:
        path = Path(file_path)

        # Skip if file doesn't exist
        if not path.exists():
            print(f"File not found: {file_path}")
            return False, None, None

        # Skip directories
        if path.is_dir():
            print(f"Skipping directory: {file_path}")
            return False, None, None

        # Get the creation year
        year = get_creation_year(file_path)
        if year is None:
            return False, None, None

        # Get filename components
        parent = path.parent
        filename = path.name

        # Check if year is already prepended
        if filename.startswith(f"{year}_"):
            print(f"Year already prepended: {filename}")
            return False, None, None

        # Create new filename with year prepended
        new_filename = f"{year}_{filename}"
        new_path = parent / new_filename

        # Check if target file already exists
        if new_path.exists():
            print(f"Target file already exists: {new_path}")
            return False, None, None

        if dry_run:
            print(f"[DRY RUN] Would rename: {path} -> {new_path}")
            return True, str(path), str(new_path)
        else:
            # Rename the file
            path.rename(new_path)
            print(f"Renamed: {path} -> {new_path}")
            return True, str(path), str(new_path)

    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False, None, None


def process_directory(directory, recursive=False, dry_run=True, extensions=None):
    """
    Process all files in a directory.

    Args:
        directory: Directory path to process
        recursive: If True, process subdirectories recursively
        dry_run: If True, only show what would be done
        extensions: List of file extensions to process (e.g., ['.mp4', '.avi'])
                   If None, process all files
    """
    try:
        path = Path(directory)

        if not path.exists() or not path.is_dir():
            print(f"Invalid directory: {directory}")
            return

        # Get file pattern
        pattern = "**/*" if recursive else "*"

        success_count = 0
        skip_count = 0

        # Process files
        for file_path in path.glob(pattern):
            if file_path.is_file():
                # Check extension filter
                if extensions and file_path.suffix.lower() not in extensions:
                    continue

                success, old_name, new_name = prepend_year_to_filename(file_path, dry_run)
                if success:
                    success_count += 1
                else:
                    skip_count += 1

        print(f"\nSummary: {success_count} files processed, {skip_count} files skipped")

    except Exception as e:
        print(f"Error processing directory: {e}")


def main():
    """Main function with command-line interface."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Prepend file creation year to existing file names",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Dry run on single file
  python prepend_year.py file.txt

  # Actually rename single file
  python prepend_year.py file.txt --execute

  # Process all files in directory (dry run)
  python prepend_year.py --directory ./videos

  # Process all files in directory recursively
  python prepend_year.py --directory ./videos --recursive --execute

  # Process only specific file types
  python prepend_year.py --directory ./videos --extensions .mp4 .avi --execute
        """
    )

    parser.add_argument(
        "file",
        nargs="?",
        help="File to process (single file mode)"
    )

    parser.add_argument(
        "-d", "--directory",
        help="Process all files in this directory"
    )

    parser.add_argument(
        "-r", "--recursive",
        action="store_true",
        help="Process subdirectories recursively"
    )

    parser.add_argument(
        "-e", "--execute",
        action="store_true",
        help="Actually rename files (default is dry run)"
    )

    parser.add_argument(
        "--extensions",
        nargs="+",
        help="Only process files with these extensions (e.g., .mp4 .avi)"
    )

    args = parser.parse_args()

    # Determine dry run mode
    dry_run = not args.execute

    if dry_run:
        print("=" * 60)
        print("DRY RUN MODE - No files will be renamed")
        print("Use --execute flag to actually rename files")
        print("=" * 60)
        print()

    # Process extensions
    extensions = None
    if args.extensions:
        extensions = [ext if ext.startswith('.') else f'.{ext}' for ext in args.extensions]
        extensions = [ext.lower() for ext in extensions]

    # Single file mode
    if args.file:
        success, old_name, new_name = prepend_year_to_filename(args.file, dry_run)
        if success:
            print("\nFile processed successfully!")
        sys.exit(0 if success else 1)

    # Directory mode
    elif args.directory:
        process_directory(args.directory, args.recursive, dry_run, extensions)
        sys.exit(0)

    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
