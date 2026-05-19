param(
    [string]$Compiler = "gfortran",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

function Get-FortranSources {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir
    )

    if (-not (Test-Path -LiteralPath $SourceDir)) {
        return @()
    }

    $exts = @(".f", ".for", ".f90", ".f95", ".f03", ".f08")
    return @(Get-ChildItem -LiteralPath $SourceDir -Recurse -File |
        Where-Object { $exts -contains $_.Extension.ToLowerInvariant() } |
        Sort-Object FullName)
}

$toolRoot = Split-Path -Parent $PSCommandPath
$srcRoot = Join-Path $toolRoot "src"
$binRoot = Join-Path $toolRoot "bin"
$buildRoot = Join-Path $toolRoot "build"

if ($Clean) {
    foreach ($path in @($binRoot, $buildRoot)) {
        if (Test-Path -LiteralPath $path) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
    }
}

New-Item -ItemType Directory -Force -Path $binRoot | Out-Null
New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null

$compilerCmd = Get-Command $Compiler -ErrorAction SilentlyContinue
if (-not $compilerCmd) {
    throw "Could not find compiler '$Compiler'. Install gfortran or pass -Compiler with a valid executable name."
}

$jobs = @(
    @{
        Name = "gview2d"
        SourceDir = Join-Path $srcRoot "gview2d"
        OutputExe = Join-Path $binRoot "gview2d.exe"
        ModuleDir = Join-Path $buildRoot "gview2d"
    },
    @{
        Name = "gview3d"
        SourceDir = Join-Path $srcRoot "gview3d"
        OutputExe = Join-Path $binRoot "gview3d.exe"
        ModuleDir = Join-Path $buildRoot "gview3d"
    }
)

$builtAny = $false

foreach ($job in $jobs) {
    $sources = Get-FortranSources -SourceDir $job.SourceDir
    if ($sources.Count -eq 0) {
        Write-Warning "Skipping $($job.Name): no Fortran sources found in $($job.SourceDir)"
        continue
    }

    New-Item -ItemType Directory -Force -Path $job.ModuleDir | Out-Null
    $args = @(
        "-O2",
        "-J", $job.ModuleDir,
        "-o", $job.OutputExe
    ) + $sources.FullName

    Write-Host "[build] $($job.Name)" -ForegroundColor Cyan
    Write-Host "        sources: $($sources.Count)"
    Write-Host "        output : $($job.OutputExe)"

    & $compilerCmd.Source @args
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for $($job.Name)."
    }

    $builtAny = $true
    Write-Host "[ok] Built $($job.OutputExe)" -ForegroundColor Green
}

if (-not $builtAny) {
    Write-Warning "No gview executables were built. Add adapted sources under fortran/src/gview2d and/or fortran/src/gview3d first."
}
