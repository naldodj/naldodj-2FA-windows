<#
    .SYNOPSIS
    Stores a 2FA secret key in the Windows Credential Manager and generates a QR code.

    .DESCRIPTION
    This script stores a 2FA (Two-Factor Authentication) secret key in the Windows Credential Manager under the specified target name and generates a QR code for configuring the authenticator app.

    .EXAMPLE
    .\2FASecretKeyPutCredentialManager.ps1

    .NOTES
    Written by: Marinaldo de Jesus

    Find me on:
    * My blog: https://blacktdn.com.br/
    * Github: https://github.com/naldodj
#>

# Caminho para o arquivo DLL Otp.NET (ajuste conforme necessário)
$otpNetPath = "C:\Program Files\PackageManagement\NuGet\Packages\Otp.NET.1.4.0\lib\netstandard2.0\Otp.NET.dll"
# Caminho para o arquivo DLL QRCoder (ajuste conforme necessário)
$qrCoderPath = "C:\Program Files\PackageManagement\NuGet\Packages\QRCoder.1.1.6\lib\net40\QRCoder.dll"

# Verificar se o arquivo DLL Otp.NET existe
if (-not (Test-Path $otpNetPath)) {
    Write-Error "Arquivo DLL Otp.NET não encontrado em '$otpNetPath'. Verifique o caminho e reinstale o pacote."
    exit 1
}

# Verificar se o arquivo DLL QRCoder existe
if (-not (Test-Path $qrCoderPath)) {
    Write-Error "Arquivo DLL QRCoder não encontrado em '$qrCoderPath'. Verifique o caminho e reinstale o pacote."
    exit 1
}

# Carregar os assemblies
try {
    [Reflection.Assembly]::LoadFrom($otpNetPath) | Out-Null
    [Reflection.Assembly]::LoadFrom($qrCoderPath) | Out-Null
} catch {
    Write-Error "Erro ao carregar os assemblies: $_"
    exit 1
}

# Função para gerar e armazenar a chave secreta
function Generate-2FASecret {
    param (
        [string]$credName
    )

    # Gerar uma chave secreta Base32
    $secretKey = [OtpNet.KeyGeneration]::GenerateRandomKey(20) # Tamanho da chave em bytes (20 bytes = 160 bits)
    $base32Secret = [OtpNet.Base32Encoding]::ToString($secretKey)

    # Armazenar a chave secreta no Windows Credential Manager
    $secretKeySecureString = ConvertTo-SecureString $base32Secret -AsPlainText -Force

    # Criar a credencial no Windows Credential Manager
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $credName, $secretKeySecureString
    $credentialPath = "C:\2FA\"
    if (-not (Test-Path -Path $credentialPath -PathType Container)) {
        [System.IO.Directory]::CreateDirectory($credentialPath)
    }
    $credential | Export-Clixml -Path "$credentialPath$credName.xml"

    # Exibir a chave secreta para configurar o aplicativo autenticador
    Write-Output "Chave secreta para configurar no aplicativo autenticador: $base32Secret"

    # Formatar o URI para o QR Code conforme a especificação
    $issuer = "DNA-TECH"
    $accountName = [uri]::EscapeDataString("$credName")
    $label = $issuer+":"+$accountName
    $qrUri = "otpauth://totp/"+$label+"?secret=$base32Secret&issuer=$issuer&digits=6&period=30&algorithm=SHA512"

    # Exibir o link com o QR Code para configurar o autenticador
    $qrCodeUrl = "https://api.qrserver.com/v1/create-qr-code/?data=$([uri]::EscapeDataString($qrUri))"
    Write-Output "URL do QR Code: $qrCodeUrl"
    
    # Gerar o QR Code usando QRCoder
    $qrGenerator = New-Object QRCoder.QRCodeGenerator
    $qrCodeData = $qrGenerator.CreateQrCode($qrUri, [QRCoder.QRCodeGenerator+ECCLevel]::Q)
    $qrCode = New-Object QRCoder.QRCode($qrCodeData)
    $qrBitmap = $qrCode.GetGraphic(20)

    # Salvar o QR Code como imagem
    $qrCodePath = "$credentialPath$credName-QRCode.png"
    $qrBitmap.Save($qrCodePath, [System.Drawing.Imaging.ImageFormat]::Png)

    # Exibir o caminho do QR Code
    Write-Output "QR Code gerado e salvo em: $qrCodePath"

}

# Exemplo de uso para gerar e armazenar a chave secreta
$credName = [System.Net.Dns]::GetHostName()
Generate-2FASecret -credName $credName