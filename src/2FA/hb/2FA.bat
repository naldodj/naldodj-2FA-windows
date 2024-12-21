@echo off
setlocal enabledelayedexpansion

rem Diretório base onde as aplicações estão localizadas
set baseDir=.

rem Array de aplicações com paths completos
set apps[0]=%baseDir%\minigui\clock\2FAClockSaver.exe
set apps[1]=%baseDir%\minigui\lines\2FALines.exe
set apps[2]=%baseDir%\minigui\MurphySaver\2FAMLaws.exe
set apps[3]=%baseDir%\minigui\PhantomDesktop\2FAPhantomDesktop.exe

rem Gerar um número aleatório entre 0 e 3
set /a rand=%random% %% 4

rem Executar a aplicação aleatória com o parâmetro /s
start "" "!apps[%rand%]!" /s /b /realtime /min

rem Verificar se um argumento foi passado
if not "%~1"=="" (
    rem Se existir um script em PowerShell a ser executado, executa-o
    if exist "%1" (
        rem Executar o comando e redirecionar a saída para o arquivo de log
        start /b /realtime /min pwsh -WindowStyle Hidden -NoProfileLoadTime -NoProfile -NonInteractive -NoLogo -STA -Login -executionPolicy bypass -file %1
    )
)

endlocal

exit
