$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$target = Join-Path $projectDir "Start_Penelope_Studio_V9_NoConsole.pyw"

if (-not (Test-Path $target)) {
    Write-Error "Launcher not found: $target"
    exit 1
}

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "PENELOPE Studio V9.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $target
$shortcut.WorkingDirectory = $projectDir
$shortcut.IconLocation = "$env:SystemRoot\System32\SHELL32.dll,220"
$shortcut.Save()

Write-Host "Created desktop shortcut:"
Write-Host $shortcutPath
