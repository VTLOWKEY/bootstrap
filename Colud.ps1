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

function Quote-ProcessArg([string]$Value) {
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Read-SharedText([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return "" }
    try {
        $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::ReadWrite)
        $reader = New-Object IO.StreamReader($stream, [Text.Encoding]::UTF8)
        $text = $reader.ReadToEnd()
        $reader.Dispose()
        $stream.Dispose()
        return $text
    }
    catch {
        return ""
    }
}

$activity = Get-LzText "5q2j5Zyo5LqR6Kej5p6Q"
$statusDownload = Get-LzText "5q2j5Zyo5LiL6L29Li4u"

$tempDownloadDir = $null
$stdoutFile = Join-Path $env:TEMP ("lanzou-stdout-" + [guid]::NewGuid().ToString("N") + ".log")
$stderrFile = Join-Path $env:TEMP ("lanzou-stderr-" + [guid]::NewGuid().ToString("N") + ".log")
$tempExe = Join-Path $env:TEMP ("lanzou-resolver-" + [guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($DownloaderUrl -match "^https://api\.github\.com/repos/") {
        $meta = Invoke-RestMethod -Uri $DownloaderUrl -Headers @{ "User-Agent" = "LanzouDownloader"; "Accept" = "application/vnd.github+json" }
        if (-not $meta.content) { throw (Get-LzText "R2l0SHViIEFQSSDmsqHmnInov5Tlm57mlofku7blhoXlrrnjgII=") }
        $bytes = [Convert]::FromBase64String(($meta.content -replace "\s", ""))
        [System.IO.File]::WriteAllBytes($tempExe, $bytes)
    }
    elseif ($DownloaderUrl -match "^https?://") {
        try {
            Invoke-WebRequest -Uri $DownloaderUrl -OutFile $tempExe -UseBasicParsing
        }
        catch {
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

    $argLine = (($arguments | ForEach-Object { Quote-ProcessArg $_ }) -join " ")
    $ProgressPreference = "Continue"
    Write-Progress -Activity $activity -Status $statusDownload -PercentComplete 0

    $process = Start-Process -FilePath $tempExe -ArgumentList $argLine -PassThru -NoNewWindow `
        -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
    $started = Get-Date
    $lastPercent = -1
    while (-not $process.HasExited) {
        Start-Sleep -Milliseconds 200
        $text = Read-SharedText $stdoutFile
        $percent = -1
        if ($text) {
            $matches = [regex]::Matches($text, "(\d+(?:\.\d+)?)%")
            if ($matches.Count -gt 0) {
                $percent = [int][double]$matches[$matches.Count - 1].Groups[1].Value
            }
        }
        if ($percent -lt 0) {
            $elapsed = ((Get-Date) - $started).TotalSeconds
            $percent = [int](($elapsed * 6) % 90) + 5
        }
        if ($percent -gt 99) { $percent = 99 }
        if ($percent -ne $lastPercent) {
            Write-Progress -Activity $activity -Status $statusDownload -PercentComplete $percent
            $lastPercent = $percent
        }
    }
    $process.WaitForExit()
    Write-Progress -Activity $activity -Completed

    $desktop = [Environment]::GetFolderPath("Desktop")
    if ([string]::IsNullOrWhiteSpace($desktop)) {
        $desktop = Join-Path $env:USERPROFILE "Desktop"
    }
    if (-not (Test-Path -LiteralPath $desktop)) {
        New-Item -ItemType Directory -Path $desktop -Force | Out-Null
    }

    if ($tempDownloadDir) {
        $downloaded = Get-ChildItem -LiteralPath $tempDownloadDir -File |
            Where-Object { $_.Name -notlike "*.part" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if (-not $downloaded) { throw "Downloaded file not found." }
        $destination = Join-Path $desktop $downloaded.Name
        Move-Item -LiteralPath $downloaded.FullName -Destination $destination -Force
        $item = Get-Item -LiteralPath $destination
    }
    else {
        $item = Get-Item -LiteralPath $OutFile
    }

    Write-Host ((Get-LzText "6Kej5p6Q5a6M5oiQOiA=") + $item.FullName) -ForegroundColor Green
    Write-Host ((Get-LzText "5aSn5bCPOiA=") + $item.Length + (Get-LzText "IOWtl+iKgg=="))
}
finally {
    Write-Progress -Activity $activity -Completed
    if (Test-Path -LiteralPath $tempExe) {
        Remove-Item -LiteralPath $tempExe -Force -ErrorAction SilentlyContinue
    }
    if ($tempDownloadDir -and (Test-Path -LiteralPath $tempDownloadDir)) {
        Remove-Item -LiteralPath $tempDownloadDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $stdoutFile) {
        Remove-Item -LiteralPath $stdoutFile -Force -ErrorAction SilentlyContinue
    }
    if (Test-Path -LiteralPath $stderrFile) {
        Remove-Item -LiteralPath $stderrFile -Force -ErrorAction SilentlyContinue
    }
}


