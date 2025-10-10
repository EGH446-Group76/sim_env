# SetupEnv.ps1 — One-time Python Environment Bootstrap for Windows Matlab Project
# (run in a normal PowerShell from the project root)

# ======================================================================================================================================================
# ##################################################################################################################################[ Parameters ]######
# ======================================================================================================================================================

$ErrorActionPreference = 'Stop'

$PyVer = '-3.12'
$PyVerRegex = '^Python 3\.12\.\d+$'


# ======================================================================================================================================================
# ###################################################################################################################################[ Functions ]######
# ======================================================================================================================================================


# =========================================================================== Check if Python is Microsoft Store Version:
function Is-StorePythonPath($p) {
    return ($p -match '\\Microsoft\\WindowsApps\\') -or ($p -match '\\WindowsApps\\')
}


# =========================================================================== Find a Suitable Python Installation:
function Find-PythonCandidate {
    # Prefer py launcher (python.org typically registers it)
    try {
        $ver = (& py $PyVer --version) 2>$null
        if ($LASTEXITCODE -eq 0 -and $ver -match $PyVerRegex) {
            $pyPath = (& py $PyVer -c 'import sys; print(sys.executable)')
            if ($pyPath -and (Test-Path $pyPath) -and -not (Is-StorePythonPath $pyPath)) { return $pyPath }
        }
    } catch {}

    # Try python.exe on PATH
    try {
        $p = (Get-Command python -ErrorAction Stop).Path
        if ($p -and -not (Is-StorePythonPath $p)) {
            $ver = (& $p --version) 2>$null
            if ($LASTEXITCODE -eq 0 -and $ver -match $PyVerRegex) { return $p }
        }
    } catch {}

    # Common python.org locations (adjust versions as needed)
    $common = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'),
        (Join-Path $env:ProgramFiles 'Python312\python.exe')
    )
    foreach ($c in $common) {
        if (Test-Path $c) {
            $ver = (& $c --version) 2>$null
            if ($LASTEXITCODE -eq 0 -and $ver -match $PyVerRegex) { return $c }
        }
    }
    return $null
}


# =========================================================================== Install Bundled Python if Present:
function Install-PythonIfBundled {
    # Find the newest "python-3.12.X-amd64.exe" in tools\python-installer
    $installer = Get-ChildItem -Path (Join-Path $PSScriptRoot 'tools\python-installer') -Filter 'python-3.12*-amd64.exe' -File |
        Where-Object { $_.Name -match '^python-3\.12\.(\d+)-amd64\.exe$' } |
        Sort-Object -Property { [int]([regex]::Match($_.Name, '^python-3\.12\.(\d+)-amd64\.exe$').Groups[1].Value) } -Descending |
        Select-Object -First 1 -ExpandProperty FullName

    # If found, install it (per-user) and return its path
    if (Test-Path $installer) {
        Write-Output 'Installing bundled Python (per-user) ...'
        & $installer /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1 Include_pip=1 | Out-Null
        Start-Sleep -Seconds 3
        return (Find-PythonCandidate)
    }
    return $null
}


# ======================================================================================================================================================
# #####################################################################################################################################[ Program ]######
# ======================================================================================================================================================


Write-Output ''
Write-Output ''
Write-Output '=== MATLAB Project Python Bootstrap ==='
Write-Output ''


# =========================================================================== Locate or Install a Proper Python:
$pythonExe = Find-PythonCandidate
if (-not $pythonExe) {
    Write-Warning 'No suitable python.org CPython found (and/or PATH points to Store build).'
    $pythonExe = Install-PythonIfBundled
    if (-not $pythonExe) {
        Write-Error @'
No valid Python found and no bundled installer present.

Fix one of the following, then re-run this script:
  - Install python.org CPython (64-bit) for your user
  - Or bundle the installer at: tools\python-installer\python-3.12.X-amd64.exe
'@
    }
}
if (Is-StorePythonPath $pythonExe) {
    Write-Error ('Detected Microsoft Store Python at: ' + $pythonExe + '. Please disable App execution aliases and install python.org Python.')
}

Write-Output ('Using base Python: ' + $pythonExe)


# =========================================================================== Create venv:
$venvDir = (Join-Path $PSScriptRoot 'venv')
$venvPy  = (Join-Path $venvDir 'Scripts\python.exe')

if (-not (Test-Path $venvDir)) {
    Write-Output ''
    Write-Output 'Creating virtual environment ...'
    & $pythonExe -m venv $venvDir
    if ($LASTEXITCODE -ne 0) { throw ('Failed to create venv with ' + $pythonExe) }
}

if (-not (Test-Path $venvPy)) {
    Write-Output ''
    Write-Error ('venv python.exe not found at ' + $venvPy + ' (venv creation may have failed).')
}


# =========================================================================== Install Dependencies:
$req = (Join-Path $PSScriptRoot 'requirements.txt')

Write-Output ''

if (Test-Path $req) {
    Write-Output 'Ensuring required packages are installed ...'
    & $venvPy -m pip install --requirement $req
} else {
    Write-Output '(requirements.txt not found — skipping package install.)'
}


# =========================================================================== End of Script


Write-Output ''
Write-Output '=== Bootstrap Complete ==='
Write-Output ''
Write-Output ''