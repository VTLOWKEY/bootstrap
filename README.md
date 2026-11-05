# bootstrap

## Files

- `Colud.ps1` - public PowerShell bootstrap script.
- `Download.exe` - self-contained C++ resolver using WinHTTP.

## What it does

1. Downloads `Download.exe` to `%TEMP%`.
3. Downloads the target file using its original name.
5. Deletes the temporary resolver.

Only execute scripts and binaries from sources you trust.


