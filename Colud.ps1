param(
    [string]$ShareUrl = "https://vtlowkey.lanzouc.com/i1K9i1im5fna",
    [string]$Password = "",
    [string]$OutFile = "",
    [string]$DownloaderUrl = "https://vtlowkey.github.io/bootstrap/Download.exe"
)

[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Get-LzText([string]$Base64Text) {
    return [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Base64Text))
}

function Write-Lz([string]$Base64Text, [string]$Color = "Gray") {
    Write-Host (Get-LzText $Base64Text) -ForegroundColor $Color
}

$tempDownloadDir = $null
$tempExe = Join-Path $env:TEMP ("lanzou-resolver-" + [guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($DownloaderUrl -match "^https://api\.github\.com/repos/") {
        Write-Lz "5q2j5Zyo6YCa6L+HIEdpdEh1YiBBUEkg5LiL6L295Li05pe26Kej5p6Q5ZmoLi4u" "Cyan"
        $meta = Invoke-RestMethod -Uri $DownloaderUrl -Headers @{ "User-Agent" = "LanzouDownloader"; "Accept" = "application/vnd.github+json" }
        if (-not $meta.content) { throw (Get-LzText "R2l0SHViIEFQSSDmsqHmnInov5Tlm57mlofku7blhoXlrrnjgII=") }
        $bytes = [Convert]::FromBase64String(($meta.content -replace "\s", ""))
        [System.IO.File]::WriteAllBytes($tempExe, $bytes)
    }
    elseif ($DownloaderUrl -match "^https?://") {
        Write-Lz "5q2j5Zyo5LiL6L295Li05pe26Kej5p6Q5ZmoLi4u" "Cyan"
        try {
            Invoke-WebRequest -Uri $DownloaderUrl -OutFile $tempExe -UseBasicParsing
        }
        catch {
            Write-Warning (Get-LzText "SW52b2tlLVdlYlJlcXVlc3Qg5aSx6LSl77yM5pS555SoIGN1cmwuZXhl44CC")
            & curl.exe -L -sS --fail -o $tempExe $DownloaderUrl
            if ($LASTEXITCODE -ne 0) { throw (Get-LzText "6Kej5p6Q5Zmo5LiL6L295aSx6LSl44CC") }
        }
    }
    elseif (Test-Path -LiteralPath $DownloaderUrl -PathType Leaf) {
        Copy-Item -LiteralPath $DownloaderUrl -Destination $tempExe -Force
    }
    else {
        throw ((Get-LzText "RG93bmxvYWRlclVybCDml6LkuI3mmK8gSFRUUCDlnLDlnYDvvIzkuZ/kuI3mmK/mnKzlnLDmlofku7Y6IA==") + $DownloaderUrl)
    }

    Unblock-File -LiteralPath $tempExe -ErrorAction SilentlyContinue

    $arguments = @($ShareUrl, "--overwrite")
    if (-not [string]::IsNullOrWhiteSpace($OutFile)) {
        $arguments += @("--output", $OutFile)
    }
    else {
        $tempDownloadDir = Join-Path $env:TEMP ("lanzou-file-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $tempDownloadDir | Out-Null
        $arguments += @("--output-dir", $tempDownloadDir)
    }
    if (-not [string]::IsNullOrWhiteSpace($Password)) {
        $arguments += @("--password", $Password)
    }

    Write-Lz "5q2j5Zyo5LuO5LqR5LiL6L295paH5Lu2Li4u" "Cyan"
    & $tempExe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw ((Get-LzText "6Kej5p6Q5Zmo6L+U5Zue6ZSZ6K+v77yM6YCA5Ye656CBOiA=") + $LASTEXITCODE)
    }

    if ($tempDownloadDir) {
        $downloaded = Get-ChildItem -LiteralPath $tempDownloadDir -File |
            Where-Object { $_.Name -notlike "*.part" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if (-not $downloaded) { throw "Downloaded file not found." }
        $destination = Join-Path (Get-Location) $downloaded.Name
        Move-Item -LiteralPath $downloaded.FullName -Destination $destination -Force
        $item = Get-Item -LiteralPath $destination
    }
    else {
        $item = Get-Item -LiteralPath $OutFile
    }
    Write-Host ((Get-LzText "5LiL6L295a6M5oiQOiA=") + $item.FullName) -ForegroundColor Green
    Write-Host ((Get-LzText "5aSn5bCPOiA=") + $item.Length + (Get-LzText "IOWtl+iKgg=="))
    Write-Host ((Get-LzText "U0hBMjU2OiA=") + (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash)
}
finally {
    if (Test-Path -LiteralPath $tempExe) {
        Remove-Item -LiteralPath $tempExe -Force -ErrorAction SilentlyContinue
    }
    if ($tempDownloadDir -and (Test-Path -LiteralPath $tempDownloadDir)) {
        Remove-Item -LiteralPath $tempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}


