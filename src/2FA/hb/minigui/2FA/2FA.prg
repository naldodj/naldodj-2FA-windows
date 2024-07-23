#include "inkey.ch"
#include "setcurs.ch"
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

Memvar nNoWinKeys,nDisableTaskMgr,nTaskbarEndTask

static s_aDoMethod:=Array(0)

init Procedure NoWinKeys(lReSet)
    if (type("nNoWinKeys")!="N")
        public nNoWinKeys:=GetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoWinKeys","N")
        hb_default(@nNoWinKeys,0)
    endif
    if (type("nDisableTaskMgr")!="N")
        public nDisableTaskMgr:=GetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableTaskMgr","N")
        hb_default(@nDisableTaskMgr,0)
    endif
    if (type("nTaskbarEndTask")!="N")
        public nTaskbarEndTask:=1
    endif
    __NoWinKeys(.F.)
return

static function __NoWinKeys(lReSet)
    hb_default(@lReSet,.F.)
    SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoWinKeys",if(lReSet,nNoWinKeys,1))
    SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableTaskMgr",if(lReSet,nDisableTaskMgr,1))
    if (!lReset)
        if (IsRegistryKey(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"))
            nTaskbarEndTask:=GetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings","TaskbarEndTask","N")
            SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings","TaskbarEndTask",if(lReSet,nTaskbarEndTask,0))
        else
            if (CreateRegistryKey(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"))
                SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings","TaskbarEndTask",if(lReSet,nTaskbarEndTask,0))
            endif
        endif
    else
        if (IsRegistryKey(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"))
            SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings","TaskbarEndTask",if(lReSet,nTaskbarEndTask,0))
        endif
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
            _DefineHotKey(cForm,0,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
            if (aScan(s_aDoMethod,{|akey|aKey[1]==aKeysDisable[k]})==0)
                aAdd(s_aDoMethod,{aKeysDisable[k],.F.})
            endif
        endif
        _DefineHotKey(cForm,MOD_ALT,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_WIN,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_SHIFT,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
    next k

    //VK_0...VK_9
    for k:=48 to 57
        _DefineHotKey(cForm,MOD_ALT,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_WIN,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
    next k

    //VK_A...VK_Z
    for k:=65 to 90
        if (k!=65/*A*/).and.(k!=79/*O*/)
            _DefineHotKey(cForm,MOD_ALT,k,{||DoMethod(cForm,"SetFocus")})
        endif
        _DefineHotKey(cForm,MOD_WIN,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
    next k

    //VK_F1...VK_F24
    for k:=112 to 135
        _DefineHotKey(cForm,MOD_ALT,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_WIN,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_ALT+MOD_CONTROL,k,{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,MOD_CONTROL+MOD_SHIFT,k,{||DoMethod(cForm,"SetFocus")})
    next k

    _DefineHotKey(cForm,hb_bitOr(MOD_NOREPEAT,MOD_WIN),VK_LWIN,{||DoMethod(cForm,"SetFocus")})
    _DefineHotKey(cForm,hb_bitOr(MOD_NOREPEAT,MOD_WIN),VK_RWIN,{||DoMethod(cForm,"SetFocus")})

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
                UNINSTALL_READ_KEYBOARD()
                ShellExecute(nil,"open",ExeName(),"/s",nil,SW_SHOWMINIMIZED)
            else
                __NoWinKeys(.T.)
            endif
        endif
    return(lRet)

    static function __Valid2FACode()
        local cUser:=GetUserName()
        local cCurDir:=(CurDrive()+":\"+CurDir())
        local cTmpPath:=hb_dirTmp()
        local chbotpPath:="C:\2FA"
        local cSecretKey,c2FACode,cTmp2FACode,cTmpSecretKeyFile
        local cFileSecret:="C:\2FA\"+GetComputerName()+".txt"
        local coathtoolPath:="C:\cygwin64\home\"+cUser+"\oath-toolkit-2.6.9"
        local lRet:=.T.
        if (hb_FileExists(cFileSecret))
            if (Right(cTmpPath,1)!="\")
                cTmpPath+="\"
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
            lRet:=Get2FACodeByHBOtp(@cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir)
            if (!lRet)
                lRet:=Get2FACodeByOathtool(@cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,coathtoolPath)
            endif
            if (lRet)
                lRet:=(cTmp2FACode==c2FACode)
                if (!lRet)
                    MsgInfo("Codigo Invalido: "+c2FACode,"2FA Key Code")
                endif
            endif
        endif
    return(lRet)

    static function Get2FACodeByHBOtp(cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir)
        local cCmd
        local chbotpPath:="C:\2FA"
        local lRet
        lRet:=(hb_FileExists(chbotpPath+"\hbotp_gcrypt.exe").or.hb_FileExists(chbotpPath+"\hbotp_openssl.exe"))
        if (lRet)
            DirChange(chbotpPath)
            cCmd:=".\hbotp_openssl.exe -k="+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
            hb_Run(cCmd)
            lRet:=hb_FileExists(cTmpSecretKeyFile)
            if (!lRet)
                cCmd:=".\hbotp_gcrypt.exe -k="+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
                hb_Run(cCmd)
                lRet:=hb_FileExists(cTmpSecretKeyFile)
            endif
            if (lRet)
                cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                lRet:=!Empty(cTmp2FACode)
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            DirChange(cCurDir)
        endif
    return(lRet)

    static function Get2FACodeByOathtool(cTmp2FACode,cSecretKey,cTmpSecretKeyFile,cCurDir,coathtoolPath)

        local cCmd
        local lRet:=.F.

        begin sequence

            if (hb_FileExists(coathtoolPath+"\oathtool\oathtool.exe"))

                DirChange(coathtoolPath)

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

            DirChange(coathtoolPath)

            cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
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

    return(cTmp2FACode)

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
    
    local aDoMethod:=Array(0)
    
    local nAT
    
    aAdd(aDoMethod,VK_LWIN)
    aAdd(aDoMethod,VK_RWIN)
    aAdd(aDoMethod,VK_APPS)
    
    aAdd(aDoMethod,91)//VK_LWIN
    aAdd(aDoMethod,92)//VK_RWIN
    aAdd(aDoMethod,93)//VK_APPS

    if (s_nLastKeyPress!=GET_LAST_VK())
        s_nLastKeyPress:=GET_LAST_VK()
        s_cLastKeyPress:=GET_LAST_VK_NAME()
        Keybd_Event(s_nLastKeyPress,.T.)
        if ((nAT:=aScan(s_aDoMethod,{|aKey|aKey[1]==s_nLastKeyPress}))>0)
            if (s_aDoMethod[nAT][2])
                DoMethod(cForm,"SetFocus")
                if (!IsInCallStack("_RELEASEWINDOW"))
                    DoMethod(cForm,"Release")
                endif
                s_aDoMethod[nAT][2]:=.F.
            else
                s_aDoMethod[nAT][2]:=.T.
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
