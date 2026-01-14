<#
.SYNOPSIS
    Prepend file creation year to existing file names.

.DESCRIPTION
    This PowerShell script prepends the file creation year to the filename.
    Designed for Windows 11 environment.

.PARAMETER Path
    The file or directory path to process.

.PARAMETER Recursive
    Process subdirectories recursively.

.PARAMETER Execute
    Actually rename files. Without this flag, the script runs in dry-run mode.

.PARAMETER Extensions
    Array of file extensions to filter (e.g., ".mp4", ".avi"). Process all files if not specified.

.EXAMPLE
    .\Prepend-Year.ps1 -Path "C:\Videos\video.mp4"
    Dry run on a single file.

.EXAMPLE
    .\Prepend-Year.ps1 -Path "C:\Videos\video.mp4" -Execute
    Actually rename a single file.

.EXAMPLE
    .\Prepend-Year.ps1 -Path "C:\Videos" -Execute
    Rename all files in the directory.

.EXAMPLE
    .\Prepend-Year.ps1 -Path "C:\Videos" -Recursive -Execute
    Rename all files in the directory and subdirectories.

.EXAMPLE
    .\Prepend-Year.ps1 -Path "C:\Videos" -Extensions ".mp4",".avi" -Execute
    Rename only .mp4 and .avi files in the directory.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Path,

    [Parameter(Mandatory=$false)]
    [switch]$Recursive,

    [Parameter(Mandatory=$false)]
    [switch]$Execute,

    [Parameter(Mandatory=$false)]
    [string[]]$Extensions
)

function Get-FileCreationYear {
    <#
    .SYNOPSIS
        Get the file creation year.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$File
    )

    try {
        return $File.CreationTime.Year
    }
    catch {
        Write-Warning "Error getting creation year for $($File.FullName): $_"
        return $null
    }
}

function Rename-FileWithYear {
    <#
    .SYNOPSIS
        Prepend the creation year to the filename.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$File,

        [Parameter(Mandatory=$false)]
        [bool]$DryRun = $true
    )

    try {
        # Get the creation year
        $year = Get-FileCreationYear -File $File
        if ($null -eq $year) {
            return @{
                Success = $false
                OldName = $null
                NewName = $null
            }
        }

        # Get filename components
        $directory = $File.DirectoryName
        $filename = $File.Name

        # Check if year is already prepended
        if ($filename -match "^$year`_") {
            Write-Host "Year already prepended: $filename" -ForegroundColor Yellow
            return @{
                Success = $false
                OldName = $null
                NewName = $null
            }
        }

        # Create new filename with year prepended
        $newFilename = "$year`_$filename"
        $newPath = Join-Path -Path $directory -ChildPath $newFilename

        # Check if target file already exists
        if (Test-Path -Path $newPath) {
            Write-Warning "Target file already exists: $newPath"
            return @{
                Success = $false
                OldName = $null
                NewName = $null
            }
        }

        if ($DryRun) {
            Write-Host "[DRY RUN] Would rename: $($File.FullName) -> $newPath" -ForegroundColor Cyan
        }
        else {
            # Rename the file
            Rename-Item -Path $File.FullName -NewName $newFilename -ErrorAction Stop
            Write-Host "Renamed: $($File.FullName) -> $newPath" -ForegroundColor Green
        }

        return @{
            Success = $true
            OldName = $File.FullName
            NewName = $newPath
        }
    }
    catch {
        Write-Error "Error processing $($File.FullName): $_"
        return @{
            Success = $false
            OldName = $null
            NewName = $null
        }
    }
}

function Process-Files {
    <#
    .SYNOPSIS
        Process files in the specified path.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$TargetPath,

        [Parameter(Mandatory=$false)]
        [bool]$IsRecursive = $false,

        [Parameter(Mandatory=$false)]
        [bool]$DryRun = $true,

        [Parameter(Mandatory=$false)]
        [string[]]$FileExtensions
    )

    # Check if path exists
    if (-not (Test-Path -Path $TargetPath)) {
        Write-Error "Path not found: $TargetPath"
        return
    }

    $item = Get-Item -Path $TargetPath

    # Handle single file
    if ($item -is [System.IO.FileInfo]) {
        $result = Rename-FileWithYear -File $item -DryRun $DryRun
        if ($result.Success) {
            Write-Host "`nFile processed successfully!" -ForegroundColor Green
        }
        return
    }

    # Handle directory
    if ($item -is [System.IO.DirectoryInfo]) {
        $successCount = 0
        $skipCount = 0

        # Build Get-ChildItem parameters
        $getChildItemParams = @{
            Path = $TargetPath
            File = $true
        }

        if ($IsRecursive) {
            $getChildItemParams['Recurse'] = $true
        }

        # Get files
        $files = Get-ChildItem @getChildItemParams

        # Filter by extensions if specified
        if ($FileExtensions -and $FileExtensions.Count -gt 0) {
            # Ensure extensions start with a dot
            $normalizedExtensions = $FileExtensions | ForEach-Object {
                if ($_ -notmatch '^\.') { ".$_" } else { $_ }
            }
            $files = $files | Where-Object { $normalizedExtensions -contains $_.Extension }
        }

        # Process each file
        foreach ($file in $files) {
            $result = Rename-FileWithYear -File $file -DryRun $DryRun
            if ($result.Success) {
                $successCount++
            }
            else {
                $skipCount++
            }
        }

        Write-Host "`n========================================" -ForegroundColor Cyan
        Write-Host "Summary: $successCount files processed, $skipCount files skipped" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
    }
}

# Main script execution
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "File Year Prepender for Windows 11" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

$dryRun = -not $Execute

if ($dryRun) {
    Write-Host "=" * 60 -ForegroundColor Yellow
    Write-Host "DRY RUN MODE - No files will be renamed" -ForegroundColor Yellow
    Write-Host "Use -Execute flag to actually rename files" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Yellow
    Write-Host ""
}

# Process files
Process-Files -TargetPath $Path -IsRecursive $Recursive -DryRun $dryRun -FileExtensions $Extensions

Write-Host "`nDone!" -ForegroundColor Green
