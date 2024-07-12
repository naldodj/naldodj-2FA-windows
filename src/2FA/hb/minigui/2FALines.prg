*
* MINIGUI - HARBOUR - Win32
*
* Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
*
ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

#include "inkey.ch"
#include "setcurs.ch"
#include "i_keybd.ch"
#include "i_keybd_ext.ch"

#xcommand DEFINE LBLTEXTBOX <name> ROW <nRow> COL <nCol> [ WIDTH <nW> ] CAPTION <cCaption> ;
      => ;
      CreateTextboxWithLabel( <(name)>, <nRow>, <nCol>, <cCaption>, <nW> )

#xcommand END LBLTEXTBOX =>;

#define PROGRAM "2FA Lines Screen Saver"
#define VERSION " v.1.2"
#define COPYRIGHT " 2003-2008 Grigory Filatov"

#define PS_SOLID   0
#define PIXELMOVE  2
#define CLR_DEFAULT  RGB( 255, 255, 0 )

#define MOD_NOREPEAT 0x4000

Static hPen
Static aX, aY
Static aPX, aPY
Static aMX, aMY
Static aIX, aIY

Static lInit := .T.

Memvar cIniFile
Memvar nWidth, nHeight
Memvar nType, nPolig, nColor

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
Procedure Main( cParameters )
*--------------------------------------------------------*

    // Capturar SIGINT (Ctrl+Break)
    Set(_SET_CANCEL,.F.)

    SET INTERACTIVECLOSE OFF

	PUBLIC cIniFile := GetWindowsFolder()+"\control.ini"

	PRIVATE nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()
	PRIVATE nType := 1, nPolig := 5, nColor := CLR_DEFAULT

	BEGIN INI FILE cIniFile

		GET nType SECTION "Screen Saver.Lines" ENTRY "Type" DEFAULT nType
		GET nPolig SECTION "Screen Saver.Lines" ENTRY "Number" DEFAULT nPolig
		GET nColor SECTION "Screen Saver.Lines" ENTRY "Color" DEFAULT nColor

	END INI

	IF cParameters # NIL .AND. ( LOWER(cParameters) $ "-p/p" .OR. ;
		LOWER(cParameters) = "/a" .OR. LOWER(cParameters) = "-a" .OR. ;
		LOWER(cParameters) = "/c" .OR. LOWER(cParameters) = "-c" )

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			NOSHOW
	ELSE

		DEFINE SCREENSAVER ;
			WINDOW Form_SSaver ;
			MAIN ;
			ON INIT (__DisableKeys("Form_SSaver"),.T.) ;
            ON RELEASE (DeleteObject( hPen ), .T.) ;
			ON PAINT DoLines(nType) ;
			INTERVAL .02 ;
			BACKCOLOR BLACK
	ENDIF

	INSTALL SCREENSAVER FILENAME Lines.scr

	CONFIGURE SCREENSAVER ConfigureSaver()

	ACTIVATE SCREENSAVER ;
		WINDOW Form_SSaver ;
		PARAMETERS cParameters

Return

*--------------------------------------------------------*
Procedure DoLines( nType )
*--------------------------------------------------------*
  local hDC, hOldPen
  local n, nI

  if lInit
     hPen := CreatePen( PS_SOLID, 1, nColor )
     aX := Array( nPolig ); aY := Array( nPolig )
     AFill( aX, 0 ) ; AFill( aY, 0 )
     aPX := AClone( aX ); aPY := AClone( aY )
     aMX := AClone( aX ); aMY := AClone( aY )
     aIX := Array( nPolig ); aIY := Array( nPolig )
     lInit := .F.
  endif

  for n := 1 to nPolig
      if Abs( aX[ n ] - aPX[ n ] ) < PIXELMOVE .or. Abs( aY[ n ] - aPY[ n ] ) < PIXELMOVE
         aPX[ n ] := Random( nWidth )
         aPY[ n ] := Random( nHeight )
         nI := Min( Abs( aX[ n ] - aPX[ n ] ), Abs( aY[ n ] - aPY[ n ] ) ) / PIXELMOVE
         aIX[ n ] := ( aPX[ n ] - aX[ n ] ) / nI
         aIY[ n ] := ( aPY[ n ] - aY[ n ] ) / nI
      endif
      aX[ n ] += aIX[ n ]
      aX[ n ] := MinMax( aX[ n ], nWidth )
      aY[ n ] += aIY[ n ]
      aY[ n ] := MinMax( aY[ n ], nHeight )
  next

  hDC := GetDC( _HMG_MainHandle )
  hOldPen := SelectObject( hDC, hPen )

  IF nType = 1

      MoveTo( hDC, aMX[ nPolig ], aMY[ nPolig ] )
      for n := 1 to nPolig
          LineTo( hDC, aMX[ n ], aMY[ n ] )
          aMX[ n ] := aX[ n ]
          aMY[ n ] := aY[ n ]
      next

      RedrawWindow( _HMG_MainHandle )

      MoveTo( hDC, aX[ nPolig ], aY[ nPolig ] )
      for n := 1 to nPolig
          LineTo( hDC, aX[ n ], aY[ n ] )
      next

  ELSE

      MoveTo( hDC, aMX[ nPolig - 1 ], aMY[ nPolig - 1] )
      for n := 1 to nPolig - 1
          LineTo( hDC, aMX[ n ], aMY[ n ] )
      next
      for n := 1 to nPolig
          MoveTo( hDC, aMX[ nPolig ], aMY[ nPolig ] )
          LineTo( hDC, aMX[ n ], aMY[ n ] )
          aMX[ n ] := aX[ n ]
          aMY[ n ] := aY[ n ]
      next

      RedrawWindow( _HMG_MainHandle )

      MoveTo( hDC, aX[ nPolig - 1 ], aY[ nPolig - 1 ] )
      for n := 1 to nPolig - 1
          LineTo( hDC, aX[ n ], aY[ n ] )
      next
      for n := 1 to nPolig
          MoveTo( hDC, aX[ nPolig ], aY[ nPolig ] )
          LineTo( hDC, aX[ n ], aY[ n ] )
      next

  ENDIF

  SelectObject( hDC, hOldPen )
  ReleaseDC( _HMG_MainHandle, hDC )

Return

*--------------------------------------------------------*
Procedure ConfigureSaver()
*--------------------------------------------------------*
	LOCAL aColor, aCustColor := { RGB(255,255,0), RGB(0,255,0), RGB(0,255,255), ;
		RGB(0,128,255), RGB(255,128,255), RGB(240,240,240), RGB(192,192,192), RGB(255,128,0), ;
		RGB(225,225,0), RGB(0,225,0), RGB(0,225,225), ;
		RGB(0,128,225), RGB(225,128,225), RGB(140,140,140), RGB(216,216,216), RGB(225,128,0) }

	DEFINE WINDOW Form_Config ;
        AT 0,0 ;
        WIDTH 222 ;
        HEIGHT 152 ;
        TITLE 'Lines Settings' ;
        ICON 'ICON_1' ;
        CHILD ;
        NOMINIMIZE NOMAXIMIZE NOSIZE ;
        ON INIT ShowCursor(.T.) ;
        ON PAINT DoMethod( "Form_Config", "Radio_1", "SetFocus" ) ;
        FONT 'MS Sans Serif' ;
        SIZE 9

        @ 8, 8 FRAME Frame_1 ;
            CAPTION 'Type' ;
            WIDTH 66 ;
            HEIGHT 72

        @ 24,20 RADIOGROUP Radio_1 ;
            OPTIONS { "&One", "&Two" } ;
            WIDTH 40 ;
            VALUE nType ;
            ON CHANGE nType := Form_Config.Radio_1.Value

        @ 18, 86 LABEL Label_1 ;
            VALUE 'Number of lines:' ;
            WIDTH 80 ;
            HEIGHT 23 ;

        @ 14, 168 SPINNER Spinner_1 ;
            RANGE 3, 30 ;
            HEIGHT 23 ;
            WIDTH 40 ;
            VALUE nPolig ;
            ON CHANGE nPolig := Form_Config.Spinner_1.Value ;
            FONT 'MS Sans Serif' ;
            SIZE 10

        @ 50,85 BUTTON Button_Clr ;
            CAPTION 'Select the &Color of lines' ;
            ACTION ( aColor := GetColor(nRGB2Arr(nColor), aCustColor, .N.), ;
               iif(aColor[1]==NIL, , nColor := RGB(aColor[1], aColor[2], aColor[3])) ) ;
            WIDTH 122 ;
            HEIGHT 28 ;
            FLAT

        DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 66, 24 FLAT BOTTOM RIGHTTEXT

		BUTTON Button_1  ;
			CAPTION 'A&bout' ;
			PICTURE 'About' ;
			ACTION MsgAbout() SEPARATOR

		BUTTON Button_2 ;
			CAPTION '&Save' ;
			PICTURE 'Save' ;
			ACTION ( SaveConfig(), Form_Config.Release, Form_SSaver.Release )

		BUTTON Button_3 ;
			CAPTION 'C&ancel' ;
			PICTURE 'Cancel' ;
			ACTION ( Form_Config.Release, Form_SSaver.Release )

        END TOOLBAR

	END WINDOW

	CENTER WINDOW Form_Config

	ACTIVATE WINDOW Form_Config, Form_SSaver

Return

*--------------------------------------------------------*
Static Procedure SaveConfig()
*--------------------------------------------------------*

  BEGIN INI FILE cIniFile

	SET SECTION "Screen Saver.Lines" ENTRY "Type" TO nType
	SET SECTION "Screen Saver.Lines" ENTRY "Number" TO nPolig
	SET SECTION "Screen Saver.Lines" ENTRY "Color" TO nColor

  END INI

Return

*--------------------------------------------------------*
Static Function MinMax( nvalue, nRegion )
*--------------------------------------------------------*
Return Min( nRegion, Max( nvalue, 0 ) )

*--------------------------------------------------------*
Static Function MsgAbout()
*--------------------------------------------------------*
return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This Screen Saver is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 36), "About", , .F. )

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
        local cCmd,cSecretKey,c2FACode,cTmpSecretKeyFile,lRet:=.T.
        local cFileSecret:="C:\2FA\"+GetComputerName()+".txt"
        if (hb_FileExists(cFileSecret))
            MakeDir("C:\tmp\")
            cTmpSecretKeyFile:="C:\tmp\ttop.txt"
            if (hb_FileExists(cTmpSecretKeyFile))
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            cSecretKey:=hb_MemoRead(cFileSecret)
            cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
            __Run(cCmd)
            lRet:=hb_FileExists(cTmpSecretKeyFile)
            if (lRet)
                cSecretKey:=Left(hb_MemoRead(cTmpSecretKeyFile),6)
                hb_FileDelete(cTmpSecretKeyFile)
                c2FACode:=Left(Get2FACode(),6)
                lRet:=(cSecretKey==c2FACode)
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
            CAPTION "OK"
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

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( MOVETO )
{

   hb_retl( MoveToEx(
                    (HDC) hb_parnl(1),   // device context handle
                    hb_parni(2)      ,   // x-coordinate of line's ending point
                    hb_parni(3)      ,   // y-coordinate of line's ending point
                    NULL
                 ) );
}

HB_FUNC( LINETO )
{

   hb_retl( LineTo( (HDC) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) ) ;

}

HB_FUNC ( CREATEPEN )
{

   hb_retnl( (LONG) CreatePen(
               hb_parni( 1 ),	// pen style
               hb_parni( 2 ),	// pen width
               (COLORREF) hb_parnl( 3 ) 	// pen color
             ) );
}

#pragma ENDDUMP
