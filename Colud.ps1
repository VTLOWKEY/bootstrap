param(
    [string]$ShareUrl = "https://vtlowkey.lanzouc.com/i1K9i1im5fna",
    [string]$Password = "",
    [string]$OutFile = "Core.dll",
    [string]$DownloaderUrl = "https://vtlowkey.github.io/bootstrap/Download.exe",
    [string]$DownloaderSha256 = "7A1B36EF0FF523814DB94DE28FEEA7BE2ED26B13780DCF2AED16AA63021F6440"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path (Get-Location) "download.bin"
}

$tempExe = Join-Path $env:TEMP ("lanzou-resolver-" + [guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($DownloaderUrl -match "^https://api\.github\.com/repos/") {
        Write-Host "正在通过 GitHub API 下载临时解析器..." -ForegroundColor Cyan
        $meta = Invoke-RestMethod -Uri $DownloaderUrl -Headers @{ "User-Agent" = "LanzouDownloader"; "Accept" = "application/vnd.github+json" }
        if (-not $meta.content) { throw "GitHub API 没有返回文件内容。" }
        $bytes = [Convert]::FromBase64String(($meta.content -replace "\\s", ""))
        [System.IO.File]::WriteAllBytes($tempExe, $bytes)
    }
    elseif ($DownloaderUrl -match "^https?://") {
        Write-Host "正在下载临时解析器..." -ForegroundColor Cyan
        try {
            Invoke-WebRequest -Uri $DownloaderUrl -OutFile $tempExe -UseBasicParsing
        }
        catch {
            Write-Warning "Invoke-WebRequest 失败，改用 curl.exe。"
            & curl.exe -L -sS --fail -o $tempExe $DownloaderUrl
            if ($LASTEXITCODE -ne 0) { throw "解析器下载失败。" }
        }
    }
    elseif (Test-Path -LiteralPath $DownloaderUrl -PathType Leaf) {
        Copy-Item -LiteralPath $DownloaderUrl -Destination $tempExe -Force
    }
    else {
        throw "DownloaderUrl 既不是 HTTP 地址，也不是本地文件: $DownloaderUrl"
    }

    Unblock-File -LiteralPath $tempExe -ErrorAction SilentlyContinue

    if (-not [string]::IsNullOrWhiteSpace($DownloaderSha256)) {
        $actual = (Get-FileHash -LiteralPath $tempExe -Algorithm SHA256).Hash
        if ($actual -ne $DownloaderSha256.ToUpperInvariant()) {
            throw "解析器 SHA256 校验失败。`n预期: $DownloaderSha256`n实际: $actual"
        }
    }

    $arguments = @($ShareUrl, "--output", $OutFile, "--overwrite")
    if (-not [string]::IsNullOrWhiteSpace($Password)) {
        $arguments += @("--password", $Password)
    }

    Write-Host "正在从云下载文件..." -ForegroundColor Cyan
    & $tempExe @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "解析器返回错误，退出码: $LASTEXITCODE"
    }

    $item = Get-Item -LiteralPath $OutFile
    Write-Host "下载完成: $($item.FullName)" -ForegroundColor Green
    Write-Host "大小: $($item.Length) 字节"
    Write-Host "SHA256: $((Get-FileHash -LiteralPath $OutFile -Algorithm SHA256).Hash)"
}
finally {
    if (Test-Path -LiteralPath $tempExe) {
        Remove-Item -LiteralPath $tempExe -Force -ErrorAction SilentlyContinue
    }
}


