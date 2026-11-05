param(
    [string]$ShareUrl = "https://vtlowkey.lanzouc.com/i1K9i1im5fna",
    [string]$Password = "",
    [string]$OutFile = "Core.dll",
    [string]$DownloaderUrl = "https://vtlowkey.github.io/bootstrap/Download.exe",
    [string]$DownloaderSha256 = "7A1B36EF0FF523814DB94DE28FEEA7BE2ED26B13780DCF2AED16AA63021F6440"
)

[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path (Get-Location) "download.bin"
}

$tempExe = Join-Path $env:TEMP ("lanzou-resolver-" + [guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($DownloaderUrl -match "^https://api\.github\.com/repos/") {
        Write-Host "???? GitHub API ???????..." -ForegroundColor Cyan
        $meta = Invoke-RestMethod -Uri $DownloaderUrl -Headers @{ "User-Agent" = "LanzouDownloader"; "Accept" = "application/vnd.github+json" }
        if (-not $meta.content) { throw "GitHub API ?????????" }
        $bytes = [Convert]::FromBase64String(($meta.content -replace "\s", ""))
        [System.IO.File]::WriteAllBytes($tempExe, $bytes)
    }
    elseif ($DownloaderUrl -match "^https?://") {
        Write-Host "?????????..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $DownloaderUrl -OutFile $tempExe -UseBasicParsing
        }
        catch {
            Write-Warning "Invoke-WebRequest ????? curl.exe?"
            & curl.exe -L -sS --fail -o $tempExe $DownloaderUrl
            if ($LASTEXITCODE -ne 0) { throw "????????" }
        }
    }
    elseif (Test-Path -LiteralPath $DownloaderUrl -PathType Leaf) {
        Copy-Item -LiteralPath $DownloaderUrl -Destination $tempExe -Force
    }
    else {
        throw "DownloaderUrl ??? HTTP ??????????: $DownloaderUrl"
    }

    Unblock-File -LiteralPath $tempExe -ErrorAction SilentlyContinue

    if (-not [string]::IsNullOrWhiteSpace($DownloaderSha256)) {
        $actual = (Get-FileHash -LiteralPath $tempExe -Algorithm SHA256).Hash
        if ($actual -ne $DownloaderSha256.ToUpperInvariant()) {
            throw "??? SHA256 ?????`n??: $DownloaderSha256`n??: $actual"
        }
    }

    $arguments = @($ShareUrl, "--output", $OutFile, "--overwrite")
    if (-not [string]::IsNullOrWhiteSpace($Password)) {
        $arguments += @("--password", $Password)
    }

    Write-Host "????????..." -ForegroundColor Cyan
    & $tempExe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "???????????: $LASTEXITCODE"
    }

    $item = Get-Item -LiteralPath $OutFile
    Write-Host "????: $($item.FullName)" -ForegroundColor Green
    Write-Host "??: $($item.Length) ??"
    Write-Host "SHA256: $((Get-FileHash -LiteralPath $OutFile -Algorithm SHA256).Hash)"
}
finally {
    if (Test-Path -LiteralPath $tempExe) {
        Remove-Item -LiteralPath $tempExe -Force -ErrorAction SilentlyContinue
    }
}



