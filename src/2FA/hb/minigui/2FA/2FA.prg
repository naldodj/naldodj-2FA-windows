#include "inkey.ch"
#include "setcurs.ch"
#include "hbcompat.ch"
#include "i_keybd_ext.ch"

#ifdef __XHARBOUR__
    #include "hbcompat.ch"
    #xtranslate hb_Run( [<x,...>] ) => __Run( <x> )
    #xtranslate hb_DirCreate( [<x,...>] ) => MakeDir( <x> )
    #xtranslate hb_dirTmp() => GetTempFolder()
#endif

#define MOD_NOREPEAT 0x4000
#xcommand DEFINE LBLTEXTBOX <name> ROW <nRow> COL <nCol> [ WIDTH <nW> ] CAPTION <cCaption> ;
      => ;
      CreateTextboxWithLabel( <(name)>, <nRow>, <nCol>, <cCaption>, <nW> )

#xcommand END LBLTEXTBOX =>;

static s_aRegKeys:=Array(0)
static s_a__doMethod:=Array(0)

init Procedure NoWinKeys(lReSet)
    if (aScan(s_aRegKeys,{|x|x[4]=="NoWinKeys"})==0)
        aAdd(s_aRegKeys,{HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoWinKeys","N",1,0})
    endif
    if (aScan(s_aRegKeys,{|x|x[4]=="DisableTaskMgr"})==0)
        aAdd(s_aRegKeys,{HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableTaskMgr","N",1,0})
    endif
    if (aScan(s_aRegKeys,{|x|x[4]=="TaskbarEndTask"})==0)
        aAdd(s_aRegKeys,{HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings","TaskbarEndTask","N",0,1})
    endif
    __NoWinKeys(.F.)
return

static function __NoWinKeys(lReSet)
    local nReg,nRegs:=Len(s_aRegKeys),xValue
    hb_default(@lReSet,.F.)
    for nReg:=1 to nRegs
        xValue:=s_aRegKeys[nReg][5]
        if (IsRegistryKey(s_aRegKeys[nReg][1],s_aRegKeys[nReg][2]))
            if (!lReSet)
                s_aRegKeys[nReg][6]:=GetRegistryValue(s_aRegKeys[nReg][1],s_aRegKeys[nReg][2],s_aRegKeys[nReg][3],s_aRegKeys[nReg][4])
            else
                xValue:=s_aRegKeys[nReg][6]
            endif
            SetRegistryValue(s_aRegKeys[nReg][1],s_aRegKeys[nReg][2],s_aRegKeys[nReg][3],xValue)
        elseif (!lReSet)
            if (CreateRegistryKey(s_aRegKeys[nReg][1],s_aRegKeys[nReg][2]))
                SetRegistryValue(s_aRegKeys[nReg][1],s_aRegKeys[nReg][2],s_aRegKeys[nReg][3],xValue)
            endif
        endif
    next nReg
    if (lReSet)
        UNINSTALL_READ_KEYBOARD()
    endif
return(lReSet)

static procedure __DisableKeys(cForm)

    local aKeysDisable:=Array(0),k

    aAdd(aKeysDisable,VK_LBUTTON)
    aAdd(aKeysDisable,VK_RBUTTON)
    aAdd(aKeysDisable,VK_CANCEL)
    aAdd(aKeysDisable,VK_MBUTTON)
    *aAdd(aKeysDisable,VK_BACK)
    aAdd(aKeysDisable,VK_TAB)
    aAdd(aKeysDisable,VK_CLEAR)
    aAdd(aKeysDisable,VK_RETURN)
    aAdd(aKeysDisable,VK_SHIFT)
    aAdd(aKeysDisable,VK_CONTROL)
    aAdd(aKeysDisable,VK_MENU)
    aAdd(aKeysDisable,VK_PAUSE)
    aAdd(aKeysDisable,VK_PRINT)
    aAdd(aKeysDisable,VK_CAPITAL)
    aAdd(aKeysDisable,VK_KANA)
    aAdd(aKeysDisable,VK_HANGEUL)
    aAdd(aKeysDisable,VK_HANGUL)
    aAdd(aKeysDisable,VK_JUNJA)
    aAdd(aKeysDisable,VK_FINAL)
    aAdd(aKeysDisable,VK_HANJA)
    aAdd(aKeysDisable,VK_KANJI)
    aAdd(aKeysDisable,VK_CONVERT)
    aAdd(aKeysDisable,VK_NONCONVERT)
    aAdd(aKeysDisable,VK_ACCEPT)
    aAdd(aKeysDisable,VK_MODECHANGE)
    aAdd(aKeysDisable,VK_ESCAPE)
    aAdd(aKeysDisable,VK_SPACE)
    aAdd(aKeysDisable,VK_PRIOR)
    aAdd(aKeysDisable,VK_NEXT)
    aAdd(aKeysDisable,VK_END)
    aAdd(aKeysDisable,VK_HOME)
    aAdd(aKeysDisable,VK_LEFT)
    aAdd(aKeysDisable,VK_UP)
    aAdd(aKeysDisable,VK_RIGHT)
    aAdd(aKeysDisable,VK_DOWN)
    aAdd(aKeysDisable,VK_SELECT)
    aAdd(aKeysDisable,VK_EXECUTE)
    aAdd(aKeysDisable,VK_SNAPSHOT)
    aAdd(aKeysDisable,VK_INSERT)
    aAdd(aKeysDisable,VK_DELETE)
    aAdd(aKeysDisable,VK_HELP)

    aAdd(aKeysDisable,VK_LWIN)
    aAdd(aKeysDisable,VK_RWIN)
    aAdd(aKeysDisable,VK_APPS)

    aAdd(aKeysDisable,VK_NUMLOCK)
    aAdd(aKeysDisable,VK_SCROLL)
    aAdd(aKeysDisable,VK_LSHIFT)
    aAdd(aKeysDisable,VK_LCONTROL)
    aAdd(aKeysDisable,VK_LMENU)
    aAdd(aKeysDisable,VK_RSHIFT)
    aAdd(aKeysDisable,VK_RCONTROL)
    aAdd(aKeysDisable,VK_RMENU)
    aAdd(aKeysDisable,VK_PROCESSKEY)

    aAdd(aKeysDisable,91)//VK_LWIN
    aAdd(aKeysDisable,92)//VK_RWIN
    aAdd(aKeysDisable,93)//VK_APPS

    for k:=1 to Len(aKeysDisable)
        if (aKeysDisable[k]!=VK_RETURN)
            _DefineHotKey(cForm,0,aKeysDisable[k],{||__doMethod(cForm,"Release")})
            if (aScan(s_a__doMethod,{|akey|aKey[1]==aKeysDisable[k]})==0)
                aAdd(s_a__doMethod,{aKeysDisable[k],.F.})
            endif
        endif
        _DefineHotKey(cForm,MOD_ALT,aKeysDisable[k],{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_WIN,aKeysDisable[k],{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_SHIFT,aKeysDisable[k],{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL,aKeysDisable[k],{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,aKeysDisable[k],{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,aKeysDisable[k],{||__doMethod(cForm,"Release")})
    next k

    //VK_0...VK_9
    for k:=48 to 57
        _DefineHotKey(cForm,MOD_ALT,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_WIN,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
    next k

    //VK_A...VK_Z
    for k:=65 to 90
        if (k!=65/*A*/).and.(k!=79/*O*/)
            _DefineHotKey(cForm,MOD_ALT,k,{||__doMethod(cForm,"Release")})
        endif
        _DefineHotKey(cForm,MOD_WIN,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
    next k

    //VK_F1...VK_F24
    for k:=112 to 135
        _DefineHotKey(cForm,MOD_ALT,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_WIN,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||__doMethod(cForm,"Release")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||__doMethod(cForm,"Release")})
    next k

    _DefineHotKey(cForm,hb_bitOr(MOD_NOREPEAT,MOD_WIN),VK_LWIN,{||__doMethod(cForm,"Release")})
    _DefineHotKey(cForm,hb_bitOr(MOD_NOREPEAT,MOD_WIN),VK_RWIN,{||__doMethod(cForm,"Release")})

    if (INSTALL_READ_KEYBOARD())
        DEFINE TIMER timer_k OF &cForm INTERVAL .01 ACTION __chkKeysPressed(cForm)
    endif

return

*--------------------------------------------------------*
//2FA Code Validation Begin
*--------------------------------------------------------*
    exit function Valid2FACode()
        local lRet:=.T.
        if (type("lValid2FAExec")!="L")
            public lValid2FAExec:=.T.
            lRet:=__Valid2FACode()
            if (!lRet)
                __NoWinKeys(.T.)                
                ShellExecute(nil,"open",ExeName(),"/s",nil,SW_SHOWMINIMIZED)
            else
                __NoWinKeys(.T.)                
            endif
        endif
    return(lRet)

    static function __Valid2FACode()
        local cIni:="2FA.ini"
        local hIni:=hb_iniRead(cIni)
        local cUser:=GetUserName()
        local cCurDir:=(CurDrive()+":\"+CurDir())
        local cTmpPath:=hb_dirTmp()
        local cSecretKey,c2FACode,cTmp2FACode,cTmpSecretKeyFile
        local cFileSecret:="C:\2FA\"+GetComputerName()+".txt"
        local lRet:=.T.
        if (hb_FileExists(cFileSecret))
            if (.NOT.(hb_FileExists(cIni)).or.Empty(hIni))
                hIni:=hb_Hash()
                hIni["GENERAL"]:=hb_Hash()
                hIni["GENERAL"]["FILESECRET"]:=cFileSecret
                hIni["GENERAL"]["TMPPATH"]:=cTmpPath
                hIni["GENERAL"]["HBOTPPATH"]:="C:\2FA"
                hIni["GENERAL"]["HBOTP_GCRYPT"]:="hbotp_gcrypt.exe"
                hIni["GENERAL"]["HBOTP_OPENSSL"]:="hbotp_openssl.exe"
                hIni["GENERAL"]["CYGWIN_PATH"]:="C:\cygwin64\"
                hIni["GENERAL"]["OATH_TOOLKIT_PATH"]:="C:\cygwin64\home\"+cUser+"\oath-toolkit-2.6.9"
                hb_iniWrite(cIni,hIni,"#@2FA.ini","#end of file",.F.)
                hIni:=hb_iniRead(cIni)
            endif
            if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"TMPPATH"))
                cTmpPath:=hIni["GENERAL"]["TMPPATH"]
            endif
            if (Right(cTmpPath,1)!="\")
                cTmpPath+="\"
            endif
            if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"FILESECRET"))
                cFileSecret:=hIni["GENERAL"]["FILESECRET"]
            endif
            cSecretKey:=hb_MemoRead(cFileSecret)
            c2FACode:=Left(Get2FACode(),6)
            cTmpSecretKeyFile:=cTmpPath
            if (empty(c2FACode))
                cTmpSecretKeyFile+=c2FACode
                cTmpSecretKeyFile+=".txt"
            else
                cTmpSecretKeyFile+="tmpotp.txt"
            endif
            if (hb_FileExists(cTmpSecretKeyFile))
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            lRet:=Get2FACodeByHBOtp(@cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,hIni)
            if (!lRet)
                lRet:=Get2FACodeByOathtool(@cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,hIni)
            endif
            if (lRet)
                lRet:=(cTmp2FACode==c2FACode)
                if (!lRet)
                    MsgInfo("Invalid OTP Key: "+c2FACode,"2FA Key Code")
                endif
            endif
        endif
    return(lRet)

    static function Get2FACodeByHBOtp(cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,hIni)
        local cCmd
        local chbotpPath
        local chbotp_gcrypt
        local chbotp_openssl
        local lRet
        if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"HBOTPPATH"))
            chbotpPath:=hIni["GENERAL"]["HBOTPPATH"]
        endif        
        hb_Default(@chbotpPath,"")
        if (Right(chbotpPath,1)!="\")
            chbotpPath+="\"
        endif        
        if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"HBOTP_GCRYPT"))
            chbotp_gcrypt:=hIni["GENERAL"]["HBOTP_GCRYPT"]
        endif
        hb_Default(@chbotp_gcrypt,"")
        if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"HBOTP_OPENSSL"))
            chbotp_openssl:=hIni["GENERAL"]["HBOTP_OPENSSL"]
        endif
        hb_Default(@chbotp_openssl,"")
        DirChange(chbotpPath)
        lRet:=(hb_FileExists(chbotpPath+chbotp_gcrypt).or.hb_FileExists(chbotpPath+chbotp_openssl))
        if (lRet).and.(hb_FileExists(chbotpPath+chbotp_openssl))
            cCmd:=".\"+chbotp_openssl+" -k="+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
            hb_Run(cCmd)
            lRet:=hb_FileExists(cTmpSecretKeyFile)
        endif
        if ((!lRet).and.(hb_FileExists(chbotpPath+chbotp_gcrypt)))
            cCmd:=".\"+chbotp_gcrypt+" -k="+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
            hb_Run(cCmd)
            lRet:=hb_FileExists(cTmpSecretKeyFile)
        endif
        if (lRet)
            cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
            lRet:=!Empty(cTmp2FACode)
            hb_FileDelete(cTmpSecretKeyFile)
        endif
        DirChange(cCurDir)
    return(lRet)

    static function Get2FACodeByOathtool(cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,hIni)

        local cCmd
        
        local cCygwinPath
        local cOathtoolPath
        local cCygWinTmpSecretKeyFile
        
        local lRet:=.F.

        if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"CYGWIN_PATH"))
            cCygwinPath:=hIni["GENERAL"]["CYGWIN_PATH"]
        endif
        hb_default(@cCygwinPath,"")
        if (Right(cCygwinPath,1)!="\")
            cCygwinPath+="\"
        endif
        
        if (HB_HHASKEY(hIni,"GENERAL").and.HB_HHASKEY(hIni["GENERAL"],"OATH_TOOLKIT_PATH"))
            cOathtoolPath:=hIni["GENERAL"]["OATH_TOOLKIT_PATH"]
        endif
        hb_default(@cOathtoolPath,"")
        if (Right(cOathtoolPath,1)!="\")
            cOathtoolPath+="\"
        endif

        begin sequence

            if (hb_FileExists(cOathtoolPath+"oathtool\oathtool.exe"))

                DirChange(cOathtoolPath)

                cCmd:=".\oathtool\oathtool.exe --totp -b "+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
                hb_Run(cCmd)

                DirChange(cCurDir)

                lRet:=hb_FileExists(cTmpSecretKeyFile)

                if (lRet)
                    cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                    hb_FileDelete(cTmpSecretKeyFile)
                    lRet:=(!Empty(cTmp2FACode))
                    if (lRet)
                        break
                    endif
                endif

            endif

            DirChange(cOathtoolPath)

            cCygWinOathtoolPath:=strTran(cTmpSecretKeyFile,":","")
            cCygWinOathtoolPath:=strTran(cTmpSecretKeyFile,"\","/")
            if (Right(cCygWinOathtoolPath,1)!="/")
                cCygWinOathtoolPath+="/"
            endif

            cCygWinTmpSecretKeyFile:=strTran(cTmpSecretKeyFile,":","")
            cCygWinTmpSecretKeyFile:=strTran(cTmpSecretKeyFile,"\","/")

            cCmd:=cCygwinPath+'bin\bash.exe -c "'+cCygWinOathtoolPath+'oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/'+cCygWinTmpSecretKeyFile+' 2>&1"'
            hb_Run(cCmd)

            DirChange(cCurDir)

            lRet:=hb_FileExists(cTmpSecretKeyFile)

            if (!lRet)
                break
            endif

            cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
            hb_FileDelete(cTmpSecretKeyFile)
            lRet:=!Empty(cTmp2FACode)

        end sequence

    return(lRet)

    static function Get2FACode()

      LOCAL c2FACode:=""
      LOCAL nWidth  := 200 + GetBorderWidth() - iif( IsSeven(), 2, 0 )
      LOCAL nHeight := 085 + GetTitleHeight() + GetBorderHeight() - iif( IsSeven(), 2, 0 )

      IF !_IsControlDefined( "DlgFont", "Main" )
         DEFINE FONT DlgFont FONTNAME "Segoe UI" SIZE 10
      ENDIF

      SET WINDOW MAIN OFF
      SET NAVIGATION EXTENDED
      SET INTERACTIVECLOSE OFF

      DEFINE WINDOW Form_2FA ;
         AT 0, 0 WIDTH nWidth HEIGHT nHeight ;
         TITLE "2FA Key Code" ;
         MODAL ;
         NOSIZE ;
         ON INIT (__DisableKeys("Form_2FA"),.T.);
         FONT "Segoe UI" SIZE 10

         DEFINE LBLTEXTBOX Text_1 ;
            ROW 10 ;
            COL 55 ;
            WIDTH 145 ;
            CAPTION "Code:"
            VALID !Empty(Form_2FA.Text_1.Value)
         END LBLTEXTBOX

         DEFINE BUTTON Button_1
            ROW nHeight - GetTitleHeight() - GetBorderHeight() - iif(IsSeven(), 2, 0) - 35
            COL nWidth  - GetBorderWidth() - iif(IsSeven(), 2, 0) - 125
            WIDTH 70
            CAPTION "&OK"
            ACTION (IF(Empty(Form_2FA.Text_1.Value),Form_2FA.Text_1.SetFocus(),(c2FACode:=Form_2FA.Text_1.Value,ThisWindow.Release)))
         END BUTTON

        ON LOSTFOCUS (IF(Empty(Form_2FA.Text_1.Value),Form_2FA.Text_1.SetFocus(),nil))

        ON KEY ESCAPE ACTION Form_2FA.Text_1.SetFocus()

      END WINDOW

      Form_2FA.Text_1.SetFocus()

      Form_2FA.Center()
      Form_2FA.Activate()

    return(c2FACode)

    static function CreateTextboxWithLabel( textboxname, nR, nC, cCaption, nW )

      LOCAL lbl :=  textboxname + "_Label"
      LOCAL hWnd := ThisWindow.Handle
      LOCAL hDC := GetDC( hWnd )
      LOCAL hDlgFont := GetFontHandle( "DlgFont" )
      LOCAL nLabelLen := GetTextWidth( hDC, cCaption, hDlgFont )

      hb_default( @nW, 120 )
      ReleaseDC( hWnd, hDC )

      DEFINE LABEL &( lbl )
         ROW nR
         COL nC - nLabelLen - GetBorderWidth()
         VALUE cCaption
         HEIGHT 24
         AUTOSIZE .T.
         VCENTERALIGN .T.
      END LABEL

      DEFINE TEXTBOX &( textboxname )
         ROW nR
         Col nC
         WIDTH nW
         HEIGHT 24
         INPUTMASK "999999"
         //ONGOTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", BLACK )
         //ONLOSTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", GRAY )
      END TEXTBOX

    return(nil)

*--------------------------------------------------------*
//2FA Code Validation End
*--------------------------------------------------------*

static procedure __chkKeysPressed(cForm)

    static s_nLastKeyPress:=-999
    static s_cLastKeyPress:=""

    local a__doMethod:=Array(0)

    local nAT

    aAdd(a__doMethod,VK_LWIN)
    aAdd(a__doMethod,VK_RWIN)
    aAdd(a__doMethod,VK_APPS)

    aAdd(a__doMethod,91)//VK_LWIN
    aAdd(a__doMethod,92)//VK_RWIN
    aAdd(a__doMethod,93)//VK_APPS

    if (s_nLastKeyPress!=GET_LAST_VK())
        s_nLastKeyPress:=GET_LAST_VK()
        s_cLastKeyPress:=GET_LAST_VK_NAME()
        if ((nAT:=aScan(s_a__doMethod,{|aKey|aKey[1]==s_nLastKeyPress}))>0)
            if (s_a__doMethod[nAT][2])
                __doMethod(cForm,"Release")
                s_a__doMethod[nAT][2]:=.F.
            else
                s_a__doMethod[nAT][2]:=.T.
            endif
        endif
    endif

return

static function IsInCallStack(cIsInCallStack as character,cStackExit as character)

   local IsInCallStack:=.F.

   local cCallStack:=""
   local nCallStack:=0

   hb_default(@cIsInCallStack,"")
   hb_default(@cStackExit,"")

   cIsInCallStack:=Upper(AllTrim(cIsInCallStack))
   cStackExit:=Upper(AllTrim(cStackExit))

   while ( ;
         !((cCallStack:=ProcName(++nCallStack ))$cStackExit);
         .and. ;
         !Empty( cCallStack );
         )
      if ( IsInCallStack:=(cCallStack==cIsInCallStack))
         exit
      endif
   end while

return( IsInCallStack )

static procedure __doMethod(cForm,cMethod)
    if (Upper(cMethod)=="RELEASE")
        if (!IsInCallStack("_RELEASEWINDOW"))
            doMethod(cForm,cMethod)
        else
            doMethod(cForm,"SetFocus")
        endif
    else
        doMethod(cForm,cMethod)
    endif
return

#pragma begindump

    #include <windows.h>
    #include "hbapi.h"

    HB_BOOL flag_hhk = FALSE;
    HB_BOOL PAUSE_hhk = FALSE;
    HHOOK hhk = NULL;
    HB_LONG VK_PRESSED = 0;
    HB_LONG VK_lParam = 0;

    LRESULT CALLBACK KeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
    {
        DWORD vkCode;

        if (nCode < 0)
            return CallNextHookEx(hhk, nCode, wParam, lParam);

        if (PAUSE_hhk == FALSE)
        {
            VK_PRESSED = (long) wParam;
            VK_lParam = (LONG) lParam;

            vkCode = ((KBDLLHOOKSTRUCT *) lParam)->vkCode;

            // If it's the Windows key
            if (vkCode == VK_LWIN || vkCode == VK_RWIN)
                return 1; // Stop propagation
        }
        else
        {
            VK_PRESSED = 0;
            VK_lParam = 0;
        }

        return CallNextHookEx(hhk, nCode, wParam, lParam);
    }

    HB_FUNC(GET_STATE_VK_SHIFT)
    {
       if (GetKeyState(VK_SHIFT) & 0x8000)
           hb_retl(TRUE);
       else
           hb_retl(FALSE);
    }

    HB_FUNC(GET_STATE_VK_CONTROL)
    {
       if (GetKeyState(VK_CONTROL) & 0x8000)
           hb_retl(TRUE);
       else
           hb_retl(FALSE);
    }

    HB_FUNC(GET_STATE_VK_ALT)
    {
       if (GetKeyState(VK_MENU) & 0x8000)
           hb_retl(TRUE);
       else
           hb_retl(FALSE);
    }

    HB_FUNC(GET_LAST_VK)
    {
       if (flag_hhk == TRUE)
           hb_retnl(VK_PRESSED);
       else
          hb_retnl(0);
    }

    HB_FUNC(GET_LAST_VK_NAME)
    {
       CHAR string[128];

       if (flag_hhk == TRUE)
       {
          GetKeyNameText(VK_lParam, (LPTSTR) &string, 128);
          hb_retc(string);
       }
       else
          hb_retc("");
    }

    HB_FUNC(PAUSE_READ_VK)
    {
       if (hb_pcount() == 1 && hb_parinfo(1) == HB_IT_LOGICAL)
       {
           if (hb_parl(1) == TRUE)
           {
               VK_PRESSED = 0;
               VK_lParam = 0;
           }
           PAUSE_hhk = hb_parl(1);
       }
    }

    HB_FUNC(INSTALL_READ_KEYBOARD)
    {
       if (flag_hhk == FALSE)
       {
           hhk = SetWindowsHookEx(WH_KEYBOARD_LL, KeyboardProc, (HINSTANCE) NULL, 0); // Use WH_KEYBOARD_LL for low-level hook

            if (hhk == NULL)
                hb_retl(FALSE);
            else
            {
                flag_hhk = TRUE;
                hb_retl(TRUE);
            }
       }
       else
          hb_retl(TRUE);
    }

    HB_FUNC(UNINSTALL_READ_KEYBOARD)
    {
       if (flag_hhk == TRUE)
       {
           if (UnhookWindowsHookEx(hhk) == TRUE)
           {
               flag_hhk = FALSE;
               hb_retl(TRUE);
           }
           else
               hb_retl(FALSE);
       }
       else
          hb_retl(TRUE);
    }

#pragma enddump
