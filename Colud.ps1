param(
    [string]$ShareUrl = "https://vtlowkey.lanzouc.com/i1K9i1im5fna",
    [string]$Password = "",
    [string]$OutFile = "",
    [string]$DownloaderUrl = "https://example.com/LanzouDownloader-static.exe",
    [string]$DownloaderSha256 = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = Join-Path (Get-Location) "lanzou-download.bin"
}

$tempExe = Join-Path $env:TEMP ("lanzou-resolver-" + [guid]::NewGuid().ToString("N") + ".exe")

try {
    if ($DownloaderUrl -match "^https?://") {
        Write-Host "正在下载临时解析器..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $DownloaderUrl -OutFile $tempExe -UseBasicParsing
    }
    elseif (Test-Path -LiteralPath $DownloaderUrl -PathType Leaf) {
        Copy-Item -LiteralPath $DownloaderUrl -Destination $tempExe -Force
    }
    else {
        throw "DownloaderUrl 既不是 HTTP 地址，也不是本地文件: $DownloaderUrl"
    }

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

    Write-Host "正在从蓝奏云下载文件..." -ForegroundColor Cyan
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
