# collect-env.ps1 — snapshot a Tizen .NET development environment on Windows.
#
# Output is a single YAML-ish block on stdout so the calling agent can parse it.
# All probes degrade gracefully: missing commands print `not-found` instead of failing.
#
# Usage:  pwsh -File collect-env.ps1
#     or: powershell -ExecutionPolicy Bypass -File collect-env.ps1

$ErrorActionPreference = 'Continue'

function Have($cmd) {
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Try-Run([scriptblock]$block, [string]$fallback = 'not-found') {
    try {
        $out = & $block 2>$null
        if (-not $out) { return $fallback }
        return $out
    } catch {
        return $fallback
    }
}

# --- Host ---------------------------------------------------------------------
Write-Output "host:"
Write-Output "  os: Windows"
Write-Output "  version: $([System.Environment]::OSVersion.VersionString)"
Write-Output "  arch: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)"
Write-Output "  ps_version: $($PSVersionTable.PSVersion)"

# --- .NET ---------------------------------------------------------------------
Write-Output "dotnet:"
if (Have dotnet) {
    Write-Output "  path: $((Get-Command dotnet).Source)"
    Write-Output "  version: $(Try-Run { dotnet --version })"
    Write-Output "  sdks:"
    $sdks = Try-Run { dotnet --list-sdks }
    if ($sdks -eq 'not-found') {
        Write-Output "    - not-found"
    } else {
        $sdks -split "`n" | Where-Object { $_ } | ForEach-Object { Write-Output "    - $_" }
    }
    Write-Output "  runtimes:"
    $rts = Try-Run { dotnet --list-runtimes }
    if ($rts -eq 'not-found') {
        Write-Output "    - not-found"
    } else {
        $rts -split "`n" | Where-Object { $_ } | ForEach-Object { Write-Output "    - $_" }
    }
    Write-Output "  workloads:"
    $wl = Try-Run { dotnet workload list }
    if ($wl -eq 'not-found') {
        Write-Output "    not-found"
    } else {
        $wl -split "`n" | Where-Object { $_ } | ForEach-Object { Write-Output "    $_" }
    }
} else {
    Write-Output "  status: not-found"
}

# --- Tizen Studio / sdb -------------------------------------------------------
Write-Output "tizen_studio:"
$tz = [System.Environment]::GetEnvironmentVariable('TIZEN_STUDIO')
if ($tz) {
    Write-Output "  env_TIZEN_STUDIO: $tz"
} else {
    Write-Output "  env_TIZEN_STUDIO: not-set"
}
if (Have sdb) {
    Write-Output "  sdb_path: $((Get-Command sdb).Source)"
    $sdbv = Try-Run { sdb version } | Select-Object -First 1
    Write-Output "  sdb_version: $sdbv"
} else {
    Write-Output "  sdb_path: not-found"
}
if (Have tizen) {
    Write-Output "  tizen_cli_path: $((Get-Command tizen).Source)"
    $tcv = Try-Run { tizen version } | Select-Object -First 1
    Write-Output "  tizen_cli_version: $tcv"
} else {
    Write-Output "  tizen_cli_path: not-found"
}

# --- Java (needed by Tizen Studio signer) -------------------------------------
Write-Output "java:"
if (Have java) {
    Write-Output "  path: $((Get-Command java).Source)"
    # java -version writes to stderr
    $jv = Try-Run { (java -version 2>&1) } | Select-Object -First 1
    Write-Output "  version: $jv"
} else {
    Write-Output "  status: not-found"
}

# --- Certificate profiles -----------------------------------------------------
Write-Output "tizen_certificates:"
$tzData = [System.Environment]::GetEnvironmentVariable('TIZEN_STUDIO_DATA')
if (-not $tzData) { $tzData = Join-Path $env:USERPROFILE 'tizen-studio-data' }
$profilesXml = Join-Path $tzData 'profile\profiles.xml'
if (Test-Path $profilesXml) {
    Write-Output "  profiles_xml: $profilesXml"
    try {
        [xml]$xml = Get-Content $profilesXml
        $xml.profiles.profile | ForEach-Object { Write-Output "  - $($_.name)" }
    } catch {
        Write-Output "  - parse-error"
    }
} else {
    Write-Output "  profiles_xml: not-found"
}

# --- TizenFX repo hints -------------------------------------------------------
Write-Output "repo:"
if ((Test-Path .\build.sh) -and (Test-Path .\src)) {
    Write-Output "  looks_like_tizenfx: true"
    Write-Output "  note: build.sh assumes POSIX shell; use WSL2 or Git Bash on Windows"
} else {
    Write-Output "  looks_like_tizenfx: false"
}

# --- PATH hygiene -------------------------------------------------------------
Write-Output "path_hygiene:"
Write-Output "  dotnet_on_path: $((Have dotnet).ToString().ToLower())"
Write-Output "  sdb_on_path: $((Have sdb).ToString().ToLower())"
Write-Output "  multiple_dotnet_binaries:"
$env:Path -split ';' | Where-Object { $_ } | ForEach-Object {
    $candidate = Join-Path $_ 'dotnet.exe'
    if (Test-Path $candidate) { Write-Output "    - $candidate" }
} | Sort-Object -Unique
