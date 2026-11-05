# bootstrap

PowerShell bootstrap for downloading a file from a Lanzou share link.

## Files

- `Colud.ps1` - public PowerShell bootstrap script.
- `Download.exe` - self-contained C++ resolver using WinHTTP.

## What it does

1. Downloads `Download.exe` to `%TEMP%`.
3. Downloads the target file using its original name.
5. Deletes the temporary resolver.

Only execute scripts and binaries from sources you trust.

## Current behavior

- Shows a single progress bar with the activity text `正在云解析`.
- Resolver console output is captured and not shown.
- The downloaded file is saved to the current user's Desktop by default.
- The original remote filename is preserved.
- The script reports the saved file path and size.


## One-click launcher

Double-click `run.bat` or run:

```bat
run.bat
```

The batch file starts PowerShell with the Base64-encoded entry URL. It uses the current cloud resolver flow, shows the `正在云解析` progress bar, and saves the downloaded file to the current user's Desktop.

If the hosted script changes to a new commit or URL, regenerate the Base64 value inside `run.bat`.
