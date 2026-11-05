param(
    [Parameter(Mandatory = $true)]
    [string]$InFile,
    [string]$OutFile = "",
    [string]$Password = "",
    [int]$Iterations = 150000
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutFile)) {
    $OutFile = [System.IO.Path]::ChangeExtension($InFile, ".enc")
}

if ([string]::IsNullOrWhiteSpace($Password)) {
    $secure = Read-Host "请输入加密密码" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { $Password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }
}

$plainBytes = [System.IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $InFile))
$salt = New-Object byte[] 16
$iv = New-Object byte[] 16
$rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
$rng.GetBytes($salt)
$rng.GetBytes($iv)
$rng.Dispose()

$kdf = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
    $Password, $salt, $Iterations,
    [System.Security.Cryptography.HashAlgorithmName]::SHA256
)
$material = $kdf.GetBytes(64)
$encKey = New-Object byte[] 32
$macKey = New-Object byte[] 32
[Array]::Copy($material, 0, $encKey, 0, 32)
[Array]::Copy($material, 32, $macKey, 0, 32)

$aes = [System.Security.Cryptography.Aes]::Create()
$aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
$aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$aes.Key = $encKey
$aes.IV = $iv
$encryptor = $aes.CreateEncryptor()
$cipher = $encryptor.TransformFinalBlock($plainBytes, 0, $plainBytes.Length)
$encryptor.Dispose()
$aes.Dispose()

$macInput = New-Object byte[] (16 + $cipher.Length)
[Array]::Copy($iv, 0, $macInput, 0, 16)
[Array]::Copy($cipher, 0, $macInput, 16, $cipher.Length)
$hmac = New-Object System.Security.Cryptography.HMACSHA256
$hmac.Key = $macKey
$mac = $hmac.ComputeHash($macInput)
$hmac.Dispose()

$output = New-Object byte[] (16 + 16 + 32 + $cipher.Length)
[Array]::Copy($salt, 0, $output, 0, 16)
[Array]::Copy($iv, 0, $output, 16, 16)
[Array]::Copy($mac, 0, $output, 32, 32)
[Array]::Copy($cipher, 0, $output, 64, $cipher.Length)
[System.IO.File]::WriteAllBytes($OutFile, $output)

$hash = (Get-FileHash -LiteralPath $OutFile -Algorithm SHA256).Hash
Write-Host "Encrypted: $((Resolve-Path $OutFile).Path)"
Write-Host "Size: $($output.Length) bytes"
Write-Host "SHA256: $hash"
