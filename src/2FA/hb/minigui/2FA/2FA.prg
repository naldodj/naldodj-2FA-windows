#include "inkey.ch"
#include "setcurs.ch"
#include "i_keybd.ch"
#include "i_keybd_ext.ch"

#ifdef __XHARBOUR__
    #include "hbcompat.ch"
    #xtranslate hb_Run( [<x,...>] ) => __Run( <x> )
    #xtranslate hb_DirCreate( [<x,...>] ) => MakeDir( <x> )
#endif

#define MOD_NOREPEAT 0x4000
#xcommand DEFINE LBLTEXTBOX <name> ROW <nRow> COL <nCol> [ WIDTH <nW> ] CAPTION <cCaption> ;
      => ;
      CreateTextboxWithLabel( <(name)>, <nRow>, <nCol>, <cCaption>, <nW> )

#xcommand END LBLTEXTBOX =>;

Memvar nNoWinKeys,nDisableTaskMgr

init Procedure NoWinKeys(lReSet)
    if (type("nNoWinKeys")!="N")
        public nNoWinKeys:=GetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoWinKeys","N")
        hb_default(@nNoWinKeys,0)
    endif
    if (type("nDisableTaskMgr")!="N")
        public nDisableTaskMgr:=GetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableTaskMgr","N")
        hb_default(@nDisableTaskMgr,0)
    endif
    __NoWinKeys(.F.)
return

static function __NoWinKeys(lReSet)
    hb_default(@lReSet,.F.)
    SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\Explorer","NoWinKeys",if(lReSet,nNoWinKeys,1))
    SetRegistryValue(HKEY_CURRENT_USER,"Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableTaskMgr",if(lReSet,nDisableTaskMgr,1))
return(lReSet)

static procedure __DisableKeys(cForm)

    local aKeysDisable:=Array(0),k

    aAdd(aKeysDisable,VK_LBUTTON)
    aAdd(aKeysDisable,VK_RBUTTON)
    aAdd(aKeysDisable,VK_CANCEL)
    aAdd(aKeysDisable,VK_MBUTTON)
    aAdd(aKeysDisable,VK_BACK)
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

    for k:=1 to Len(aKeysDisable)
        _DefineHotKey(cForm,0,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
        _DefineHotKey(cForm,0,aKeysDisable[k],{||DoMethod(cForm,"SetFocus")})
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
        _DefineHotKey(cForm,MOD_ALT,k,{||DoMethod(cForm,"SetFocus")})
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

    _DefineHotKey(cForm,MOD_NOREPEAT+MOD_WIN,VK_LWIN,{||DoMethod(cForm,"SetFocus")})
    _DefineHotKey(cForm,MOD_NOREPEAT+MOD_WIN,VK_RWIN,{||DoMethod(cForm,"SetFocus")})

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
                ShellExecute(nil,"open",ExeName(),"/s",nil,SW_SHOWNORMAL)
            else
                __NoWinKeys(.T.)
            endif
        endif
    return(lRet)

    static function __Valid2FACode()
        local cCmd,cSecretKey,c2FACode,cTmp2FACode,cTmpSecretKeyFile,lRet:=.T.
        local cFileSecret:="C:\2FA\"+GetComputerName()+".txt"
        local cCurDir:=(CurDrive()+":\"+CurDir())
        local cUser:=GetUserName()
        if (hb_FileExists(cFileSecret))
            hb_DirCreate("C:\tmp\")
            cTmpSecretKeyFile:="C:\tmp\ttop.txt"
            if (hb_FileExists(cTmpSecretKeyFile))
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            cSecretKey:=hb_MemoRead(cFileSecret)
            c2FACode:=Left(Get2FACode(),6)
            if (hb_FileExists("C:\tools\oathtool\oathtool.exe"))
                DirChange("C:\tools\oathtool\")
                cCmd:="oathtool --totp -b "+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
                hb_Run(cCmd)
                DirChange(cCurDir)
                lRet:=hb_FileExists(cTmpSecretKeyFile)
                if (lRet)
                    cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                    hb_FileDelete(cTmpSecretKeyFile)
                    lRet:=(!Empty(cTmp2FACode))
                    if (!lRet)
                        DirChange("C:\cygwin64\home\"+cUser)
                        cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
                        hb_Run(cCmd)
                        DirChange(cCurDir)
                        lRet:=hb_FileExists(cTmpSecretKeyFile)
                        if (lRet)
                            cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                            hb_FileDelete(cTmpSecretKeyFile)
                            lRet:=!Empty(cSecretKey)
                        endif
                    endif
                endif
            else
                DirChange("C:\cygwin64\home\"+cUser)
                cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
                hb_Run(cCmd)
                DirChange(cCurDir)
                lRet:=hb_FileExists(cTmpSecretKeyFile)
                if (lRet)
                    cTmp2FACode:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                    hb_FileDelete(cTmpSecretKeyFile)
                    lRet:=!Empty(cTmp2FACode)
                endif
            endif
            if (lRet)
                lRet:=(cTmp2FACode==c2FACode)
                if (!lRet)
                    MsgInfo("Codigo Invalido: "+c2FACode,"2FA Key Code")
                endif
            endif
        endif
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
         END LBLTEXTBOX

         DEFINE BUTTON Button_1
            ROW nHeight - GetTitleHeight() - GetBorderHeight() - iif(IsSeven(), 2, 0) - 35
            COL nWidth  - GetBorderWidth() - iif(IsSeven(), 2, 0) - 125
            WIDTH 70
            CAPTION "&OK"
            ACTION (c2FACode:=Form_2FA.Text_1.Value,ThisWindow.Release)
         END BUTTON

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
         //ONGOTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", BLACK )
         //ONLOSTFOCUS SetProperty( ThisWindow.Name, textboxname, "FontColor", GRAY )
      END TEXTBOX

    return(nil)

*--------------------------------------------------------*
//2FA Code Validation End
*--------------------------------------------------------*