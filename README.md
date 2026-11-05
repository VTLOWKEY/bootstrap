# bootstrap

PowerShell bootstrap for downloading a file from a Lanzou share link.

## Files

- `Colud.ps1` - PowerShell bootstrap script.

## What it does

1. Downloads `Colud.ps1` through the GitHub API.
2. Downloads `Download.exe` to `%TEMP%`.
3. Verifies the resolver SHA256.
4. Resolves the configured Lanzou share link.
5. Downloads the target file.
6. Deletes the temporary resolver.

The current configuration downloads `Core.dll` from the sample Lanzou share URL to the current directory. Edit the `param` defaults in `Colud.ps1` to change the share URL, password, output name, or resolver source.

Only execute scripts and binaries from sources you trust.
