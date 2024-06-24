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

# Função para verificar o código 2FA
function Verify-2FACode {
    param (
        [string]$credName,
        [string]$code
    )

    # Recuperar a chave secreta do Windows Credential Manager
    $credential = Import-Clixml -Path "C:\tools\2FA\$credName.xml"
    $base32Secret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
    $secretKey = [OtpNet.Base32Encoding]::ToBytes($base32Secret)

    try {
        # Configurar TOTP com a chave secreta
        $totp = [OtpNet.Totp]::new($secretKey)

        # Verificar o código 2FA
        $timeWindowUsed = 0
        if ($totp.VerifyTotp($code, [ref] $timeWindowUsed)) {
            Write-Output "Código 2FA válido. Acesso permitido."
            # Continue com o processo de logon do Windows
        } else {
            Write-Output "Código 2FA inválido. Acesso negado."
            # Desligar o computador
            shutdown.exe /s /t 0
        }
    } catch {
        Write-Output "Erro ao verificar o código 2FA: $_"
        # Desligar o computador em caso de erro
        shutdown.exe /s /t 0
    }
}

# Exemplo de uso para verificar o código 2FA no processo de autenticação do Windows
$credName = "DNA-TECH-01-2FA"
Write-Host "Digite o código 2FA gerado pelo aplicativo autenticador (por exemplo, Microsoft Authenticator):"
$code = Read-Host

Verify-2FACode -credName $credName -code $code
