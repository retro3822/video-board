<#
.SYNOPSIS
    GUI application to prepend file creation year to filenames.

.DESCRIPTION
    Windows Forms GUI for the file year prepender tool.
    Provides an easy-to-use interface with folder selection, options, and preview.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Import the core functions from the original script
function Get-FileCreationYear {
    param([System.IO.FileInfo]$File)
    try {
        return $File.CreationTime.Year
    }
    catch {
        return $null
    }
}

function Get-PreviewResults {
    param(
        [string]$TargetPath,
        [bool]$IsRecursive,
        [string[]]$FileExtensions
    )

    $results = @()

    if (-not (Test-Path -Path $TargetPath)) {
        return $results
    }

    $getChildItemParams = @{
        Path = $TargetPath
        File = $true
    }

    if ($IsRecursive) {
        $getChildItemParams['Recurse'] = $true
    }

    $files = Get-ChildItem @getChildItemParams

    if ($FileExtensions -and $FileExtensions.Count -gt 0) {
        $normalizedExtensions = $FileExtensions | ForEach-Object {
            if ($_ -notmatch '^\.') { ".$_" } else { $_ }
        }
        $files = $files | Where-Object { $normalizedExtensions -contains $_.Extension }
    }

    foreach ($file in $files) {
        $year = Get-FileCreationYear -File $file
        if ($null -eq $year) { continue }

        $filename = $file.Name

        # Skip if year already prepended
        if ($filename -match "^$year`_") { continue }

        $newFilename = "$year`_$filename"
        $newPath = Join-Path -Path $file.DirectoryName -ChildPath $newFilename

        # Skip if target exists
        if (Test-Path -Path $newPath) { continue }

        $results += [PSCustomObject]@{
            File = $file
            OldName = $filename
            NewName = $newFilename
            Year = $year
        }
    }

    return $results
}

function Rename-FilesFromResults {
    param([array]$Results)

    $successCount = 0
    $errorCount = 0

    foreach ($result in $Results) {
        try {
            Rename-Item -Path $result.File.FullName -NewName $result.NewName -ErrorAction Stop
            $successCount++
        }
        catch {
            $errorCount++
        }
    }

    return @{
        Success = $successCount
        Errors = $errorCount
    }
}

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "File Year Prepender"
$form.Size = New-Object System.Drawing.Size(700, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(660, 30)
$titleLabel.Text = "Prepend File Creation Year to Filenames"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($titleLabel)

# Folder Selection Group
$folderGroupBox = New-Object System.Windows.Forms.GroupBox
$folderGroupBox.Location = New-Object System.Drawing.Point(20, 60)
$folderGroupBox.Size = New-Object System.Drawing.Size(660, 80)
$folderGroupBox.Text = "Select Folder"
$form.Controls.Add($folderGroupBox)

$folderTextBox = New-Object System.Windows.Forms.TextBox
$folderTextBox.Location = New-Object System.Drawing.Point(10, 30)
$folderTextBox.Size = New-Object System.Drawing.Size(520, 25)
$folderTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$folderGroupBox.Controls.Add($folderTextBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point(540, 28)
$browseButton.Size = New-Object System.Drawing.Size(100, 30)
$browseButton.Text = "Browse..."
$browseButton.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$folderGroupBox.Controls.Add($browseButton)

# Options Group
$optionsGroupBox = New-Object System.Windows.Forms.GroupBox
$optionsGroupBox.Location = New-Object System.Drawing.Point(20, 150)
$optionsGroupBox.Size = New-Object System.Drawing.Size(660, 100)
$optionsGroupBox.Text = "Options"
$form.Controls.Add($optionsGroupBox)

$recursiveCheckBox = New-Object System.Windows.Forms.CheckBox
$recursiveCheckBox.Location = New-Object System.Drawing.Point(10, 30)
$recursiveCheckBox.Size = New-Object System.Drawing.Size(300, 25)
$recursiveCheckBox.Text = "Include subfolders (recursive)"
$recursiveCheckBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$optionsGroupBox.Controls.Add($recursiveCheckBox)

$extensionsLabel = New-Object System.Windows.Forms.Label
$extensionsLabel.Location = New-Object System.Drawing.Point(10, 60)
$extensionsLabel.Size = New-Object System.Drawing.Size(180, 25)
$extensionsLabel.Text = "File extensions (optional):"
$extensionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$optionsGroupBox.Controls.Add($extensionsLabel)

$extensionsTextBox = New-Object System.Windows.Forms.TextBox
$extensionsTextBox.Location = New-Object System.Drawing.Point(200, 58)
$extensionsTextBox.Size = New-Object System.Drawing.Size(440, 25)
$extensionsTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$extensionsTextBox.PlaceholderText = "e.g., .mp4 .avi .mkv (leave empty for all files)"
$optionsGroupBox.Controls.Add($extensionsTextBox)

# Preview Group
$previewGroupBox = New-Object System.Windows.Forms.GroupBox
$previewGroupBox.Location = New-Object System.Drawing.Point(20, 260)
$previewGroupBox.Size = New-Object System.Drawing.Size(660, 220)
$previewGroupBox.Text = "Preview (0 files will be renamed)"
$form.Controls.Add($previewGroupBox)

$previewListBox = New-Object System.Windows.Forms.ListBox
$previewListBox.Location = New-Object System.Drawing.Point(10, 25)
$previewListBox.Size = New-Object System.Drawing.Size(640, 185)
$previewListBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$previewListBox.HorizontalScrollbar = $true
$previewGroupBox.Controls.Add($previewListBox)

# Buttons
$previewButton = New-Object System.Windows.Forms.Button
$previewButton.Location = New-Object System.Drawing.Point(350, 495)
$previewButton.Size = New-Object System.Drawing.Size(150, 40)
$previewButton.Text = "Preview Changes"
$previewButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$previewButton.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($previewButton)

$executeButton = New-Object System.Windows.Forms.Button
$executeButton.Location = New-Object System.Drawing.Point(510, 495)
$executeButton.Size = New-Object System.Drawing.Size(170, 40)
$executeButton.Text = "Rename Files"
$executeButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$executeButton.BackColor = [System.Drawing.Color]::LightGreen
$executeButton.Enabled = $false
$form.Controls.Add($executeButton)

# Status Label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 500)
$statusLabel.Size = New-Object System.Drawing.Size(320, 30)
$statusLabel.Text = "Select a folder to begin"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$statusLabel.ForeColor = [System.Drawing.Color]::Gray
$form.Controls.Add($statusLabel)

# Global variable to store preview results
$script:previewResults = @()

# Browse button click event
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select the folder containing files to rename"
    $folderBrowser.ShowNewFolderButton = $false

    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $folderTextBox.Text = $folderBrowser.SelectedPath
        $statusLabel.Text = "Folder selected. Click 'Preview Changes' to see what will be renamed."
        $statusLabel.ForeColor = [System.Drawing.Color]::Blue
        $previewListBox.Items.Clear()
        $executeButton.Enabled = $false
        $script:previewResults = @()
    }
})

# Preview button click event
$previewButton.Add_Click({
    if ([string]::IsNullOrWhiteSpace($folderTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a folder first.", "No Folder Selected",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    if (-not (Test-Path -Path $folderTextBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("The selected folder does not exist.", "Invalid Folder",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $statusLabel.Text = "Loading preview..."
    $statusLabel.ForeColor = [System.Drawing.Color]::Orange
    $form.Refresh()

    $extensions = $null
    if (-not [string]::IsNullOrWhiteSpace($extensionsTextBox.Text)) {
        $extensions = $extensionsTextBox.Text -split '\s+' | Where-Object { $_ -ne '' }
    }

    $script:previewResults = Get-PreviewResults -TargetPath $folderTextBox.Text -IsRecursive $recursiveCheckBox.Checked -FileExtensions $extensions

    $previewListBox.Items.Clear()

    if ($script:previewResults.Count -eq 0) {
        $previewListBox.Items.Add("No files to rename (either no files found, or all already have year prefix)")
        $previewGroupBox.Text = "Preview (0 files will be renamed)"
        $executeButton.Enabled = $false
        $statusLabel.Text = "No files to rename"
        $statusLabel.ForeColor = [System.Drawing.Color]::Gray
    }
    else {
        foreach ($result in $script:previewResults) {
            $previewListBox.Items.Add("$($result.OldName) → $($result.NewName)")
        }
        $previewGroupBox.Text = "Preview ($($script:previewResults.Count) files will be renamed)"
        $executeButton.Enabled = $true
        $statusLabel.Text = "Ready to rename $($script:previewResults.Count) file(s)"
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
    }
})

# Execute button click event
$executeButton.Add_Click({
    if ($script:previewResults.Count -eq 0) {
        return
    }

    $confirmResult = [System.Windows.Forms.MessageBox]::Show(
        "Are you sure you want to rename $($script:previewResults.Count) file(s)?`n`nThis action cannot be undone!",
        "Confirm Rename",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirmResult -eq [System.Windows.Forms.DialogResult]::Yes) {
        $statusLabel.Text = "Renaming files..."
        $statusLabel.ForeColor = [System.Drawing.Color]::Orange
        $form.Refresh()

        $result = Rename-FilesFromResults -Results $script:previewResults

        $message = "Successfully renamed $($result.Success) file(s)"
        if ($result.Errors -gt 0) {
            $message += "`n$($result.Errors) file(s) failed to rename"
        }

        [System.Windows.Forms.MessageBox]::Show($message, "Rename Complete",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information)

        # Clear preview and reset
        $previewListBox.Items.Clear()
        $script:previewResults = @()
        $executeButton.Enabled = $false
        $previewGroupBox.Text = "Preview (0 files will be renamed)"
        $statusLabel.Text = "Rename complete. Select a new folder or preview again."
        $statusLabel.ForeColor = [System.Drawing.Color]::Green
    }
})

# Show the form
[void]$form.ShowDialog()
