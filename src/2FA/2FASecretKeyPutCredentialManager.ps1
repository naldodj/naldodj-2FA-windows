<#
    .SYNOPSIS
    Stores a 2FA secret key in the Windows Credential Manager.

    .DESCRIPTION
    This script stores a 2FA (Two-Factor Authentication) secret key in the Windows Credential Manager under the specified target name.

    .EXAMPLE
    .\2FASecretKeyPutCredentialManager.ps1

    .NOTES
    Written by: Marinaldo de Jesus

    Find me on:
    * My blog: https://blacktdn.com.br/
    * Github: https://github.com/naldodj
#>

# Caminho para o arquivo DLL Otp.NET (ajuste conforme necessário)
$assemblyPath = "C:\Program Files\PackageManagement\NuGet\Packages\Otp.NET.1.4.0\lib\netstandard2.0\Otp.NET.dll"

# Verificar se o arquivo DLL existe
if (-not (Test-Path $assemblyPath)) {
    Write-Error "Arquivo DLL Otp.NET não encontrado em '$assemblyPath'. Verifique o caminho e reinstale o pacote."
    exit 1
}

# Carregar o assembly Otp.NET
try {
    [Reflection.Assembly]::LoadFrom($assemblyPath)
} catch {
    Write-Error "Erro ao carregar o assembly Otp.NET: $_"
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
    $credentialPath="C:\2FA\"
    if (-not (Test-Path -Path $credentialPath -PathType Container)) {
        [System.IO.Directory]::CreateDirectory($credentialPath)
    }    
    $credential | Export-Clixml -Path "$credentialPath$credName.xml"

    # Exibir a chave secreta para configurar o aplicativo autenticador
    Write-Output "Chave secreta para configurar no aplicativo autenticador: $base32Secret"
}

# Exemplo de uso para gerar e armazenar a chave secreta
$credName = [System.Net.Dns]::GetHostName()
Generate-2FASecret -credName $credName
