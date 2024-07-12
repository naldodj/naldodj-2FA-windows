2FA (x)Harbour/Minigui ScreenSaver

## Dependencias

- [Harbour MiniGUI Extended Edition](https://hmgextended.com/)
- [Cygwin](https://cygwin.com/)
    - [OATH Toolkit](https://savannah.nongnu.org/projects/oath-toolkit/#devtools)

## Instalação :: Cygwin

- Baixe o [setup-x86_64.exe](https://cygwin.com/setup-x86_64.exe)
    - crie a pasta `C:\cygwin64\'
        - copie o arquivo setup-x86_64.exe para `C:\cygwin64\'
        - execute o instalador setup-x86_64.exe da seguinte forma:
        ```bash
        cd c:\cygwin64
        setup-x86_64.exe -q -P wget -P gcc-g++ -P make -P libssl-devel -P zlib-devel -P ldd
        ```
      - Após a instalação das dependências. Baixe e instale o `OATH Toolkit`

        ```bash
        cd c:\cygwin64
        C:\cygwin64> .\Cygwin.bat
        ```
        
        ```bash
        wget https://download.savannah.gnu.org/releases/oath-toolkit/oath-toolkit-2.6.9.tar.gz
        tar xzvf oath-toolkit-2.6.9.tar.gz
        rm -rf ./oath-toolkit-2.6.9.tar.gz
        cd oath-toolkit-2.6.9
        ./configure
        make
        ```

## Instalação :: Harbour MiniGUI Extended Edition

- Baixe conforme os procedimentos descritos [aqui](https://hmgextended.com/download.html)

    - [Harbour MiniGUI Extended Edition 24.05 STD for Borland C++ 5.5](https://hmgextended.com/files/CONTRIB/hmg-24.06-pro.7z)
      - Extraia no diretório padrão     
    - [Borland C++ Compiler version 5.8](https://hmgextended.com/files/MISC/bcc582.zip)
      - Extraia no diretório padrão

## Compilação 

- Execute compile.bat
 - Execute .\2FALines.exe para instalar o ScreenSaver
 - Execute .\2FALines.exe /s para executar o ScreenSaver
