# naldodj-2FA-windows
Autenticação 2FA para logon no Windows

![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/ee3632d7-cc40-40cb-8886-7ca30ad42bb8)

# Adicionando Autenticação de Dois Fatores ao Windows com PowerShell e Otp.NET

Autenticação de dois fatores (2FA) é uma camada adicional de segurança usada para garantir que as pessoas tentando obter acesso a uma conta online sejam quem dizem ser. Primeiro, um usuário insere seu nome de usuário e uma senha. Em seguida, em vez de obter acesso imediatamente, ele é solicitado a fornecer outra informação. Essa segunda camada pode vir de uma variedade de fontes:

- Algo que você sabe - uma informação adicional, como uma senha ou PIN.
- Algo que você possui - um dispositivo específico, como um smartphone.
- Algo que você é - uma impressão digital ou reconhecimento facial.

Neste guia, vamos configurar a autenticação de dois fatores (2FA) usando PowerShell e a biblioteca Otp.NET, armazenando a chave secreta no Windows Credential Manager e validando o código gerado por aplicativos autenticadores como Google Authenticator ou Microsoft Authenticator.

## Pré-requisitos

1. **PowerShell** instalado no seu sistema.
2. **Otp.NET** - Biblioteca .NET para geração de códigos TOTP e HOTP.

## Passo 1: Instalar a Biblioteca Otp.NET

Primeiro, precisamos instalar a biblioteca Otp.NET usando o NuGet. Execute o seguinte comando no PowerShell:

```powershell
Install-Package Otp.NET
```

## Passo 2: Gerar e Armazenar a Chave Secreta

Vamos criar um script PowerShell para gerar e mostrar a chave secreta para configurar o aplicativo autenticador.

```powershell
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
    $credential | Export-Clixml -Path "C:\tmp\2FA\$credName.xml"

    # Exibir a chave secreta para configurar o aplicativo autenticador
    Write-Output "Chave secreta para configurar no aplicativo autenticador: $base32Secret"
}

# Exemplo de uso para gerar e armazenar a chave secreta
$credName = "DNA-TECH-01-2FA"
Generate-2FASecret -credName $credName
```

## Passo 3: Verificar o Código 2FA

Agora, vamos criar um script PowerShell para verificar o código 2FA gerado pelo aplicativo autenticador.

```powershell
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
    $credential = Import-Clixml -Path "C:\tmp\2FA\$credName.xml"
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
            # Bloqueie o acesso ou tente novamente
            exit 1
        }
    } catch {
        Write-Output "Erro ao verificar o código 2FA: $_"
        exit 1
    }
}

# Exemplo de uso para verificar o código 2FA no processo de autenticação do Windows
$credName = "DNA-TECH-01-2FA"
Write-Host "Digite o código 2FA gerado pelo aplicativo autenticador (por exemplo, Microsoft Authenticator):"
$code = Read-Host

Verify-2FACode -credName $credName -code $code
```

## Passo 4: Integrar o Script ao Processo de Logon do Windows

Para integrar este script ao processo de logon do Windows, vamos configurá-lo para ser executado por meio de uma Política de Grupo (GPO).

### Configuração da GPO

#### Abra o Editor de Política de Grupo Local:
1. Pressione Win + R, digite `gpedit.msc` e pressione Enter.

#### Navegue até o Script de Logon:
1. Vá para Configuração do Usuário -> Políticas -> Configurações do Windows -> Scripts (Logon/Logoff).

#### Adicione o Script de Logon:
1. Clique em Logon -> Adicionar Script.
2. No campo **Script Name**, forneça o caminho do script PowerShell criado acima.
3. No campo **Script Parameters**, você pode adicionar parâmetros se necessário.

#### Aplique e Feche:
1. Clique em OK para salvar as configurações.

## Passo 5: Testar o Script

Após configurar a GPO, você pode testar o script fazendo logon com uma conta de usuário e verificando se o prompt do PowerShell aparece solicitando o código 2FA.

## Considerações de Segurança

- **Segurança da Chave Secreta**: Certifique-se de proteger a chave secreta e outras credenciais sensíveis. Armazene-as de forma segura.
- **HTTPS**: Use HTTPS para todas as comunicações com a API para garantir a segurança dos dados transmitidos.
- **Tratamento de Erros**: Adicione tratamento de erros e logs apropriados ao script para lidar com falhas e garantir a auditoria.

---

Para garantir que o usuário não possa fechar a tela do PowerShell e evitar a validação, vamos modificar o segundo script de forma que nos forneça uma interface para digitação do código 2FA.

```powershell

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
            return $true
        } else {
            Write-Output "Código 2FA inválido. Acesso negado."
            # Desligar o computador
            return $false
        }
    } catch {
        Write-Output "Erro ao verificar o código 2FA: $_"
        # Desligar o computador em caso de erro
        return $false
    }
}

# Exemplo de uso para verificar o código 2FA no processo de autenticação do Windows
$credName = "DNA-TECH-01-2FA"

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Win32Functions {
    [StructLayout(LayoutKind.Sequential)]
    public struct MSG {
        public IntPtr hwnd;
        public uint message;
        public IntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public POINT pt;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT {
        public int x;
        public int y;
    }

    [DllImport("user32.dll")]
    public static extern bool GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [DllImport("user32.dll")]
    public static extern bool TranslateMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    public static extern IntPtr DispatchMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    public static extern int RegisterHotKey(IntPtr hWnd, int id, int fsModifiers, int vk);

    [DllImport("user32.dll")]
    public static extern int UnregisterHotKey(IntPtr hWnd, int id);
}
"@

# Função para desabilitar teclas de atalho
function Disable-Hotkeys {
    $global:hotkeys = @{}
    $modifiers = @{
        Alt = 0x1
        Ctrl = 0x2
        Shift = 0x4
        Win = 0x8
    }

    $keys = @("Tab", "Escape", "F4", "LWin", "RWin")
    $id = 0

    foreach ($key in $keys) {
        $mod = 0
        if ($key -eq "Tab") { $mod = $modifiers.Alt }
        if ($key -eq "Escape") { $mod = $modifiers.Ctrl }
        if ($key -eq "F4") { $mod = $modifiers.Alt }
        if ($key -eq "LWin" -or $key -eq "RWin") { $mod = $modifiers.Win }

        $vk = [System.Windows.Forms.Keys]::$key
        [Win32Functions]::RegisterHotKey([IntPtr]::Zero, $id, $mod, $vk)
        $global:hotkeys[$id] = $key
        $id++
    }
}

Add-Type -AssemblyName System.Windows.Forms

# Cria a janela
$form = New-Object System.Windows.Forms.Form
$form.Text = "Autenticação 2FA"
$form.TopMost = $true
$form.ControlBox = $false
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.KeyPreview = $true

# Evento para manter o foco na janela
$form.Add_Activated({
    $form.TopMost = $true
    $form.Focus()
})

# Evento para impedir o fechamento da janela
$form.Add_FormClosing({
    $eventArgs = [System.Windows.Forms.FormClosingEventArgs]::new([System.Windows.Forms.CloseReason]::None, $false)
    $eventArgs.Cancel = $true
})

# Desabilita o Alt+Tab, Ctrl+Alt+Del, etc.
function Disable-TaskManager {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }
    Set-ItemProperty -Path $regPath -Name "DisableTaskMgr" -Value 1
}

function Enable-TaskManager {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue
}

Disable-TaskManager

function Enable-Hotkeys {
    foreach ($id in $global:hotkeys.Keys) {
        [Win32Functions]::UnregisterHotKey([IntPtr]::Zero, $id)
    }
}

Disable-Hotkeys

# Adiciona um campo de texto para o código 2FA
$label = New-Object System.Windows.Forms.Label
$label.Text = "Digite o código 2FA:"
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(10,10)
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Width = 200
$form.Controls.Add($textBox)

# Adiciona um botão para enviar o código
$button = New-Object System.Windows.Forms.Button
$button.Text = "&Autenticar"
$button.Location = New-Object System.Drawing.Point(10,80)

$button.Add_Click({
    # Aqui você pode adicionar a lógica de autenticação
    $2FACode=(Verify-2FACode -credName $credName -code $textBox.Text)
    if ($2FACode -eq $true) { # Exemplo de código 2FA
        Enable-TaskManager
        Enable-Hotkeys
        $form.Close()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Código incorreto. Tente novamente.")
        $form.Focus()
        $textBox.Clear()
        $textBox.Focus()
    }
})
$form.Controls.Add($button)

# Timer para capturar e suprimir eventos de tecla
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1 # Intervalo em milissegundos
$timer.Add_Tick({
    $msg = New-Object Win32Functions+MSG
    if ([Win32Functions]::GetMessage([ref]$msg, [IntPtr]::Zero, 0, 0)) {
        if ($msg.message -eq 0x0312) { # WM_HOTKEY
            $key = $global:hotkeys[$msg.wParam.ToInt32()]
            if ($key -eq "F4" -and ($msg.lParam.ToInt32() -band 0x1)) { # Alt+F4
                $form.Focus()
            }
        }
        [Win32Functions]::TranslateMessage([ref]$msg) | Out-Null
        [Win32Functions]::DispatchMessage([ref]$msg) | Out-Null
    }
})
$timer.Start()

# Evento para capturar Alt+F4
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.Alt -and $e.KeyCode -eq [System.Windows.Forms.Keys]::F4) {
        $e.SuppressKeyPress = $true
        $form.Focus()
        $textBox.Focus()
    }
})

# Exibe a janela
[void]$form.ShowDialog()

# Reabilita o Task Manager e as teclas de atalho ao finalizar o script
Enable-TaskManager
Enable-Hotkeys
clear

```

### 1. Executar o Script como uma Tarefa

Usar o `Task Scheduler` para executar o script pode ajudar a evitar que o usuário feche a janela do PowerShell. Aqui estão os passos:

1. **Criar o Script**:
   - Salve o script de validação como `2FASecretKeyGetCredentialManager.ps1`.

2. **Criar uma Tarefa no Task Scheduler**:
   - Abra o `Task Scheduler`.
   - Clique em `Create Task`.
   - Na aba `General`, dê um nome à tarefa, por exemplo, "2FAuth".
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/c61778b0-0078-454e-8a44-b568f947d0d7)
   - Na aba `Triggers`, clique em `New` e selecione `At log on` e/ou outras opções para validação.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/adc6762f-d984-4a58-8343-6dd453ff4119)
   - Na aba `Actions`, clique em `New` e selecione `Start a program`. No campo `Program/script`, digite `2FASecretKeyRunCredentialManager.bat`.
```cmd
pwsh -executionPolicy bypass -file "C:\tools\2FA\2FASecretKeyGetCredentialManager.ps1"
```
   - Na aba `Conditions`, desmarque a opção `Start the task only if the computer is on AC power` para garantir que a tarefa seja executada mesmo se o computador estiver usando bateria.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/b3ea419f-5f5b-4536-ab61-33565ad82bb5)
   - Na aba `Settings`, marque a opção `Allow task to be run on demand` e `Run task as soon as possible after a scheduled start is missed`.
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/f710d4c8-d411-4410-a630-c4d6f9eb8cf1)

3. **Criar uma ação na Inicialização do Windows ou um Script de Logon**:
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/8dc7791b-77cd-427b-af6e-50821976c6ac)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/4fa44386-24a4-4150-bb55-babce0bcf657)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/e42636f7-9408-4d04-b6c8-cd7a3a4edcf4)
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/445470fa-c307-4d79-a5d0-33f5de6e0f5f)

### Considerações Finais

Essas abordagens ajudam a garantir que o script seja executado de forma consistente e que o usuário não possa fechá-lo facilmente😊!

Com esses passos, você pode adicionar uma camada adicional de segurança ao seu processo de autenticação no Windows, utilizando a autenticação de dois fatores. Isso garante que apenas usuários autorizados, que possuem acesso ao código 2FA gerado pelo aplicativo autenticador, possam acessar o sistema.

### Exemplo
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/c6d746d8-945c-453b-bb10-300d71b68222)

### Autenticação 2FA para logon no Windows
![image](https://github.com/naldodj/naldodj-2FA-windows/assets/102384575/2e605b77-98aa-422a-8405-dc5af719a11e)
