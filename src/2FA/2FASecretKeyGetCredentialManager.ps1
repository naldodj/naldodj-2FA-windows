<#
    .SYNOPSIS
    Retrieves a 2FA secret key from the Windows Credential Manager.

    .DESCRIPTION
    This script retrieves a stored 2FA (Two-Factor Authentication) secret key from the Windows Credential Manager for the specified target.

    .EXAMPLE
    .\2FASecretKeyGetCredentialManager.ps1

    .NOTES
    Written by: Marinaldo de Jesus

    Find me on:
    * My blog: https://blacktdn.com.br/
    * Github: https://github.com/naldodj
#>
#############################################################################################################################################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName "System.ComponentModel.Primitives"
Add-Type -AssemblyName "System.Windows.Forms.Primitives"
#############################################################################################################################################
Add-Type -TypeDefinition @"
using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class CustomForm : Form {
    private const int WM_NCLBUTTONDBLCLK = 0xA3;
    private const int WM_NCLBUTTONDOWN = 0x00A1;
    private const int WM_NCLBUTTONUP = 0x00A2;
    private const int WM_NCMOUSEMOVE = 0x00A0;
    private const int WM_ACTIVATEAPP = 0x001C;
    private const int WM_KILLFOCUS = 0x0008;

    [DllImport("user32.dll")]
    private static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    private delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static HookProc proc = HookCallback;
    private static IntPtr hookId = IntPtr.Zero;

    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int VK_LWIN = 0x5B;
    private const int VK_RWIN = 0x5C;

    public CustomForm() {
        hookId = SetHook(proc);
    }

    ~CustomForm() {
        UnhookWindowsHookEx(hookId);
    }

    private static IntPtr SetHook(HookProc proc) {
        using (var curProcess = System.Diagnostics.Process.GetCurrentProcess())
        using (var curModule = curProcess.MainModule) {
            return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
        }
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
            int vkCode = Marshal.ReadInt32(lParam);
            if (vkCode == VK_LWIN || vkCode == VK_RWIN) {
                // Ignore the Windows key press
                return (IntPtr)1;
            }
        }
        return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    protected override void WndProc(ref Message m) {
        if (m.Msg == WM_NCLBUTTONDBLCLK) {
            // Prevent resizing
            return;
        }
        
        if (m.Msg == WM_NCLBUTTONDOWN || m.Msg == WM_NCLBUTTONUP || m.Msg == WM_NCMOUSEMOVE) {
            // Prevent resizing and keep the window maximized
            this.WindowState = FormWindowState.Maximized;
            return;
        }

        if (m.Msg == WM_ACTIVATEAPP && m.WParam == IntPtr.Zero) {
            // If the application is deactivated, bring it back to the foreground
            SetForegroundWindow(this.Handle);
        }

        if (m.Msg == WM_KILLFOCUS) {
            // Prevent losing focus
            SetForegroundWindow(this.Handle);
        }
        
        base.WndProc(ref m);
    }
}
"@ -ReferencedAssemblies "System.Windows.Forms.dll", "System.Drawing.dll", "System.ComponentModel.Primitives.dll", "System.Windows.Forms.Primitives.dll", "System.Diagnostics.Process.dll"
#############################################################################################################################################
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
#############################################################################################################################################
function EnableTaskManager {
    Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -ErrorAction SilentlyContinue
}
#############################################################################################################################################

#############################################################################################################################################
# Desabilita o Alt+Tab, Ctrl+Alt+Del, etc.
function DisableTaskManager {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }
    Set-ItemProperty -Path $regPath -Name "DisableTaskMgr" -Value 1
}
#############################################################################################################################################

#############################################################################################################################################
function EnableWindowsKey {
    $VK_LWIN = 0x5B
    $VK_RWIN = 0x5C

    [Win32Functions]::UnregisterHotKey([IntPtr]::Zero, 1)
    [Win32Functions]::UnregisterHotKey([IntPtr]::Zero, 2)
}
#############################################################################################################################################

#############################################################################################################################################
# Adicionando a função para desabilitar as teclas Windows
function DisableWindowsKey {
    $VK_LWIN = 0x5B
    $VK_RWIN = 0x5C
    $MOD_NOREPEAT = 0x4000
    $MOD_WIN = 0x0008

    [Win32Functions]::RegisterHotKey([IntPtr]::Zero, 1, $MOD_NOREPEAT -bor $MOD_WIN, $VK_LWIN)
    [Win32Functions]::RegisterHotKey([IntPtr]::Zero, 2, $MOD_NOREPEAT -bor $MOD_WIN, $VK_RWIN)
}
#############################################################################################################################################

#############################################################################################################################################
function EnableHotkeys {
    foreach ($id in $global:hotkeys.Keys) {
        [Win32Functions]::UnregisterHotKey([IntPtr]::Zero, $id)
    }
}
#############################################################################################################################################

#############################################################################################################################################
# Função para desabilitar teclas de atalho
function DisableHotkeys {
    $global:hotkeys = @{}
    $modifiers = @{
        Alt = 0x1
        Ctrl = 0x2
        Shift = 0x4
        Win = 0x8
    }

    $keys = @("Tab", "Escape", "F4", "LWin", "RWin")
    $id = 3  # Começar com um ID maior para evitar conflito em DisableWindowsKey

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
#############################################################################################################################################

#############################################################################################################################################
function DisableAllKeys {
    # Desabilita o Alt+Tab, Ctrl+Alt+Del, etc.
    DisableTaskManager
    # Chamar a função para desabilitar as teclas de Atalho
    DisableHotkeys
    # Chamar a função para desabilitar as teclas Windows
    DisableWindowsKey
    # Desativar o descanso de tela
    #powercfg -change -monitor-timeout-ac 0
    #powercfg -change -monitor-timeout-dc 0    
}
#############################################################################################################################################

#############################################################################################################################################
function EnableAllKeys {
    # Desabilita o Alt+Tab, Ctrl+Alt+Del, etc.
    EnableTaskManager
    # Chamar a função para desabilitar as teclas de Atalho
    EnableHotkeys
    # Chamar a função para desabilitar as teclas Windows
    EnableWindowsKey
    # restaurar as configurações de descanso de tela
    #powercfg -change -monitor-timeout-ac 10
    #powercfg -change -monitor-timeout-dc 10    
}
#############################################################################################################################################

#############################################################################################################################################
try {

    #############################################################################################################################################
    DisableAllKeys
    #############################################################################################################################################

    #############################################################################################################################################
    # Caminho para o arquivo DLL Otp.NET (ajuste conforme necessário)
    $assemblyPath = "C:\Program Files\PackageManagement\NuGet\Packages\Otp.NET.1.4.0\lib\netstandard2.0\Otp.NET.dll"
    #############################################################################################################################################

    #############################################################################################################################################
    # Verificar se o arquivo DLL existe
    if (-not (Test-Path $assemblyPath)) {
        EnableAllKeys
        Write-Error "Arquivo DLL Otp.NET não encontrado em '$assemblyPath'. Verifique o caminho e reinstale o pacote."
        exit -1
    }
    #############################################################################################################################################

    #############################################################################################################################################
    # Carregar o assembly Otp.NET
    try {
        [Reflection.Assembly]::LoadFrom($assemblyPath)
    } catch {
        EnableAllKeys
        Write-Error "Erro ao carregar o assembly Otp.NET: $_"
        exit -2
    }
    #############################################################################################################################################

    #############################################################################################################################################
    # Função para verificar o código 2FA
    function Verify2FACode {
        param (
            [string]$credName,
            [string]$code
        )

        # Recuperar a chave secreta do Windows Credential Manager
        $credentialPath="C:\2FA\"
        $credential = Import-Clixml -Path "$credentialPath$credName.xml"
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
                # Tentar novamente
                return $false
            }
        } catch {
            Write-Output "Erro ao verificar o código 2FA: $_"
            # Tentar novamente
            return $false
        }
    }
    #############################################################################################################################################

    #############################################################################################################################################
    # Função para centralizar controles verticalmente
    function CenterControl {
        param (
            [System.Windows.Forms.Control]$control,
            [System.Windows.Forms.Form]$form,
            [int]$yOffset
        )
        $control.Left = ($form.ClientSize.Width - $control.Width) / 2
        $control.Top = $yOffset
    }
    #############################################################################################################################################

    #############################################################################################################################################
    # Credencial para verificar o código 2FA no processo de autenticação do Windows
    $credName = [System.Net.Dns]::GetHostName()
    #############################################################################################################################################

    #############################################################################################################################################
    # Cria a janela
    $form = New-Object CustomForm
    $form.Text = "DNA Tech :: Autenticação 2FA"
    $form.TopMost = $true
    $form.ControlBox = $false
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
    $form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
    $form.KeyPreview = $true
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedSingle"
    $form.MaximizeBox = $false

    # Adicionar transparência
    $form.Opacity = 0.9

    # Define o caminho da pasta onde estão as imagens
    $imgfolderPath = "C:\GitHub\naldodj-2FA-windows\img"
    # Obtém a lista de arquivos na pasta com a extensão desejada (por exemplo, .jpeg)
    $imgfiles = Get-ChildItem -Path $imgfolderPath -Filter *.jpeg
    # Verifica se há arquivos na pasta
    if ($imgfiles.Count -gt 0) {
        # Seleciona um arquivo aleatório da lista
        $randomFile = Get-Random -InputObject $imgfiles
        # Define a imagem de fundo com o arquivo selecionado
        $form.BackgroundImage = [System.Drawing.Image]::FromFile($randomFile.FullName)
        $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    } else {
        Write-Host "Nenhum arquivo encontrado na pasta especificada."
    }

    # Criar barra de título personalizada
    $titleBar = New-Object System.Windows.Forms.Panel
    $titleBar.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $titleBar.Height = 30
    $titleBar.Dock = [System.Windows.Forms.DockStyle]::Top
    $form.Controls.Add($titleBar)

    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "DNA Tech :: 2FA Secret Key Credential Manager"
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $titleLabel.Padding = New-Object System.Windows.Forms.Padding(10, 0, 0, 0)
    $titleBar.Controls.Add($titleLabel)

    # Permitir movimentação do formulário ao arrastar a barra de título personalizada
    $titleBar.Add_MouseDown({
        $global:dragging = $true
        $global:startPoint = New-Object System.Drawing.Point($eventArgs.X, $eventArgs.Y)
    })

    $titleBar.Add_MouseMove({
        if ($global:dragging) {
            $point = [System.Windows.Forms.Cursor]::Position
            $point.X = $point.X - $global:startPoint.X
            $point.Y = $point.Y - $global:startPoint.Y
            $form.Location = $point
        }
    })

    $titleBar.Add_MouseUp({
        $global:dragging = $false
    })

    # Evento para manter o foco na janela
    $form.Add_Activated({
        $form.TopMost = $true
        $form.Focus()
        $textBox.Focus()
    })

    # Evento para impedir o fechamento da janela
    $form.Add_FormClosing({
        $eventArgs = [System.Windows.Forms.FormClosingEventArgs]::new([System.Windows.Forms.CloseReason]::None, $false)
        $eventArgs.Cancel = $true
    })

    # Adiciona um campo de texto para o código 2FA
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Digite o código 2FA"
    $label.Size = New-Object System.Drawing.Size(200, 30) # Ajusta o tamanho do Label
    $label.Location = New-Object System.Drawing.Point(10,10)
    $label.BackColor = [System.Drawing.Color]::FromArgb(30, 144, 255)
    $label.ForeColor = [System.Drawing.Color]::White
    $label.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $label.Font = New-Object System.Drawing.Font("Helvetica", 10, [System.Drawing.FontStyle]::Regular)
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter # Centraliza o texto
    $form.Controls.Add($label)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Size = New-Object System.Drawing.Size(200, 30) # Ajusta o tamanho do TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,50) # Reduz o espaçamento
    $textBox.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textBox.ForeColor = [System.Drawing.Color]::White
    $textBox.Font = New-Object System.Drawing.Font("Helvetica", 10)
    $form.Controls.Add($textBox)

    # Adiciona um botão para enviar o código
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "&Autenticar"
    $button.Size = New-Object System.Drawing.Size(200, 30) # Ajusta o tamanho do Button
    $button.Location = New-Object System.Drawing.Point(10,90) # Reduz o espaçamento
    $button.BackColor = [System.Drawing.Color]::FromArgb(30, 144, 255)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.Font = New-Object System.Drawing.Font("Helvetica", 10, [System.Drawing.FontStyle]::Regular)
    $form.Controls.Add($button)

    # Centralizar controles no formulário
    $yOffset = ($form.ClientSize.Height - ($label.Height + $textBox.Height + $button.Height + 40)) / 2 + $titleBar.Height
    CenterControl -control $label -form $form -yOffset $yOffset

    $yOffset += $label.Height + 20
    CenterControl -control $textBox -form $form -yOffset $yOffset

    $yOffset += $textBox.Height + 20
    CenterControl -control $button -form $form -yOffset $yOffset

    # Atualizar layout ao redimensionar a tela
    $form.add_SizeChanged({
        $yOffset = ($form.ClientSize.Height - ($label.Height + $textBox.Height + $button.Height + 40)) / 2 + $titleBar.Height
        CenterControl -control $label -form $form -yOffset $yOffset

        $yOffset += $label.Height + 20
        CenterControl -control $textBox -form $form -yOffset $yOffset

        $yOffset += $textBox.Height + 20
        CenterControl -control $button -form $form -yOffset $yOffset
    })

    $button.Add_Click({
        # Aqui você pode adicionar a lógica de autenticação
        $2FACode=(Verify2FACode -credName $credName -code $textBox.Text)
        if ($2FACode -eq $true) { # Verifica se o código 2FA
            $timer.Stop()
            [System.Windows.Forms.MessageBox]::Show("Código 2FA válido. Acesso permitido.")
            $form.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Código 2FA inválido. Acesso negado.")
            $form.Focus()
            $textBox.Clear()
            $textBox.Focus()
        }
    })
    $form.Controls.Add($button)
    #############################################################################################################################################

    #############################################################################################################################################
    # Adiciona o evento KeyDown ao formulário
    $form.Add_KeyDown({
        param($sender, $e)
        if ($e.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
            $button.PerformClick()
        }
    })
    #############################################################################################################################################

    #############################################################################################################################################
    # Evento para capturar Alt+F4
    $form.Add_KeyDown({
        param($sender, $e)
        if ($e.Alt -and $e.KeyCode -eq [System.Windows.Forms.Keys]::F4) {
            $e.SuppressKeyPress = $true
            $form.Focus()
            $textBox.Focus()
        }
    })
    #############################################################################################################################################
    # Timer para capturar e suprimir eventos de tecla
    # Cria um objeto Mutex
    $mutex = New-Object System.Threading.Mutex($false,"2FASecretKeyGetCredentialManagerMTX")
    #############################################################################################################################################
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100 # Intervalo aumentado para 100 milissegundos
    $timer.Add_Tick({
        # Tenta adquirir o mutex
        $iGotMutex=$false
        try {
            $nGotMutex=0
            while (!($iGotMutex=$mutex.WaitOne(10))) {
                $nGotMutex++
                if ($nGotMutex>10){
                    break
                }
            }        
            if ($iGotMutex){
                try {
                    $msg = New-Object Win32Functions+MSG
                    if ([Win32Functions]::GetMessage([ref]$msg, [IntPtr]::Zero, 0, 0)) {
                        if ($msg.message -eq 0x0312) { # WM_HOTKEY
                            $key = $global:hotkeys[$msg.wParam.ToInt32()]
                            if ($key -eq "F4" -and ($msg.lParam.ToInt32() -band 0x1)) { # Alt+F4
                                $form.Focus()
                                $textBox.Focus()
                            }
                        }
                        [Win32Functions]::TranslateMessage([ref]$msg) | Out-Null
                        [Win32Functions]::DispatchMessage([ref]$msg) | Out-Null
                    }
                } finally {
                    $iGotMutex=$false
                    # Libera o mutex
                    $mutex.ReleaseMutex()
                }
            }
        } catch [System.Threading.AbandonedMutexException] {
            Write-Error "Mutex abandonado detectado. Tentando readquirir..."
            $iGotMutex = $true
            $mutex = New-Object System.Threading.Mutex($false,"2FASecretKeyGetCredentialManagerMTX")
        } catch {
            Write-Error "Erro ao tentar adquirir o mutex: $_"
        } finally {
            if ($iGotMutex) {
                # Libera o mutex se foi adquirido
                $mutex.ReleaseMutex()
            }
        }
    })

    # Evento para parar o timer ao bloquear a sessão e reiniciar ao desbloquear
    Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) -EventName "SessionSwitch" -Action {
        if ($_.SessionSwitchReason -eq [Microsoft.Win32.SessionSwitchReason]::SessionLock) {
            $timer.Stop()
        } elseif ($_.SessionSwitchReason -eq [Microsoft.Win32.SessionSwitchReason]::SessionUnlock) {
            $timer.Stop()
            $timer.Start()
            $form.Focus()
            $textBox.Focus()
        }
    }

    # Evento para monitorar mudanças de estado de energia
    Register-ObjectEvent -InputObject ([Microsoft.Win32.SystemEvents]) -EventName "PowerModeChanged" -Action {
        if ($_.Mode -eq [Microsoft.Win32.PowerModes]::Suspend) {
            $timer.Stop()
        } elseif ($_.Mode -eq [Microsoft.Win32.PowerModes]::Resume) {
            $timer.Stop()
            $timer.Start()
            $form.Focus()
            $textBox.Focus()
        }
    }

    #############################################################################################################################################

    #############################################################################################################################################
    #Executar o formulário
    $form.Add_Shown({
        $timer.Start()
        $textBox.Focus()
        $form.Activate()
    })
    [System.Windows.Forms.Application]::Run($form)
    #############################################################################################################################################

} finally {

    #############################################################################################################################################
    # Dispose dos objetos
    if ($timer) { $timer.Dispose() }
    if ($form) { $form.Dispose() }
    #############################################################################################################################################

    #############################################################################################################################################
    # Garbage collection
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    #############################################################################################################################################

    #############################################################################################################################################
    # Reabilita o Task Manager e as teclas de atalho ao finalizar o script
    EnableAllKeys
    #############################################################################################################################################
    
    #############################################################################################################################################
    # Limpeza de eventos
    Unregister-Event -SourceIdentifier "SessionSwitch" -ErrorAction SilentlyContinue
    Unregister-Event -SourceIdentifier "PowerModeChanged" -ErrorAction SilentlyContinue
    #############################################################################################################################################
    
    #############################################################################################################################################
    Clear
    Exit 0
    #############################################################################################################################################
}