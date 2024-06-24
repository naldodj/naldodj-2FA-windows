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
