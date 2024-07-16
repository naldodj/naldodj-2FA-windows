/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2003-2008 Grigory Filatov <gfilatov@inbox.ru>
 *
 * Modificado: 27/11/2008 por Walter H.TAVERNA <walhug@yahoo.com.ar>
 *             para evitar el parpadeo del reloj.
 *             in order to avoid the blinking of the clock
*/

ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"

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

#define PROGRAM "2FA Clock Screen Saver"
#define VERSION " v.1.02"
#define COPYRIGHT " 2003-2008 Grigory Filatov"

#define PS_SOLID   0

Static ParentHandle
Static ahPen, ahUPen, nDiametr, xcent, ycent
Static nlseg, nlmin, nlhor, radio

Static lInit := .T.

Memvar nWidth, nHeight

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

*-----------------------------------------------------------------------------*
PROCEDURE Main( cParameters )
*-----------------------------------------------------------------------------*

    // Capturar SIGINT (Ctrl+Break)
    Set(_SET_CANCEL,.F.)

    SET INTERACTIVECLOSE OFF

   Private nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()

   ahPen  := Array(4)
   ahUPen := Array(4)  // WHT 26/11/2008

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
         ON RELEASE ( Aeval(ahPen, {|e| DeleteObject( e )}), ;
                      Aeval(ahUPen, {|e,i| iif(i>1, DeleteObject( e ), )}), .T. ) ;
         ON PAINT DrawClock() ;
         INTERVAL 1 ;
         BACKCOLOR BLACK
   ENDIF

   INSTALL SCREENSAVER TO FILE ClockSaver.scr

   CONFIGURE SCREENSAVER MsgAbout()

   ACTIVATE SCREENSAVER ;
      WINDOW Form_SSaver ;
      PARAMETERS cParameters

RETURN

*-----------------------------------------------------------------------------*
PROCEDURE DrawClock()
*-----------------------------------------------------------------------------*
   Local hDC, hOldPen, ntime := time()
   Local ngseg, ngmin, nghor, t

   Static nGSeg1, nGMin1, nGHor1   // WHT 26/11/2008

   if lInit
      // Cuadrante
      ahPen[1] := CREATEPEN( PS_SOLID, 6, RGB( 255, 255, 255 ) )
      // Segundos
      ahPen[2] := CREATEPEN( PS_SOLID, 1, RGB( 255, 0, 0 ) )
      ahUPen[2]:= CREATEPEN( PS_SOLID, 1, RGB( 0, 0, 0 ) )
      // Minutos
      ahPen[3] := CREATEPEN( PS_SOLID, 4, RGB(  128, 128, 128 ) )
      ahUPen[3]:= CREATEPEN( PS_SOLID, 4, RGB( 0, 0, 0 ) )
      // Horas
      ahPen[4] := CREATEPEN( PS_SOLID, 8, RGB( 128, 128, 128 ) )
      ahUPen[4]:= CREATEPEN( PS_SOLID, 8, RGB( 0, 0, 0 ) )

      xcent    := nWidth / 2
      ycent    := nHeight / 2
      nDiametr := nHeight / 2 + 60
      radio    := ndiametr / 2
      nlseg    := radio - 1
      nlmin    := radio * 3 / 4
      nlhor    := radio / 2

      ParentHandle := _HMG_MainHandle
   endif

   // Manecilla Segundos
   nGSeg := val(substr(ntime,7))*6

   // Manecilla Minutos
   nGMin := val(substr(ntime,4,2))*6

   // Manecilla Horas
   nGHor := mod(val(substr(ntime,1,2)),12)*30 + int(ngmin/12)

   if lInit
      nGSeg1 := nGSeg	;      nGHor1 := nGHor	;      nGMin1 := nGMin
      lInit := .F.
   endif

   hDC := GetDC( ParentHandle )

   // Segundos
   hOldPen := SelectObject( hDC, ahUPen[2] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlseg*sin(ngseg1), ycent-nlseg*cos(ngseg1), ahUPen[2])

   // Cuadrante
   SelectObject( hDC, ahPen[1] )
   for t = 0 to 330 step 30
      MoveTo(hDC, xCent+nLSeg*Sin(t), yCent-nLSeg*Cos(t))
      LineTo(hDC, xCent+(nLSeg+5)*Sin(t), yCent-(nLSeg+5)*Cos(t), ahPen[1])
   next

   // Minutos
   SelectObject( hDC, ahUPen[3] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlmin*sin(nGMin1), ycent-nlmin*cos(nGMin1), ahUPen[3])

   SelectObject( hDC, ahPen[3] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlmin*sin(ngmin), ycent-nlmin*cos(ngmin), ahPen[3])

   // Horas
   SelectObject( hDC, ahUPen[4] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlhor*sin(nGHor1), ycent-nlhor*cos(nGHor1), ahUPen[4])

   SelectObject( hDC, ahPen[4] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlhor*sin(nghor), ycent-nlhor*cos(nghor), ahPen[4])

   // Segundos
   SelectObject( hDC, ahPen[2] )
   MoveTo(hdc, xcent, ycent)
   LineTo(hdc, xcent+nlseg*sin(ngseg), ycent-nlseg*cos(ngseg), ahPen[2])

   SelectObject( hDC, ahPen[4] )
   RoundRect( hDC, xcent-6, ycent-6, xcent+6, ycent+6, 12, 12 )

   SelectObject( hDC, hOldPen )

   ReleaseDC( ParentHandle, hDC )

   nGSeg1 := nGSeg	;   nGMin1 := nGMin	;   nGHor1 := nGHor

RETURN

*-----------------------------------------------------------------------------*
FUNCTION MsgAbout()
*-----------------------------------------------------------------------------*
RETURN MsgInfo( PROGRAM + VERSION + CRLF +;
      "Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF +;
      "eMail: gfilatov@inbox.ru" + CRLF + CRLF +;
      "This Screen Saver is Freeware!" + CRLF +;
      padc("Copying is allowed!", 30), "About..." )


FUNCTION RadToDeg(x); RETURN 180.0*x/PI()
/*
*/
FUNCTION DegToRad(x); RETURN x*PI()/180.0
/*
*/
FUNCTION Signo(nValue); RETURN if(nValue<0, -1.0, 1.0)
/*
*/
FUNCTION Sin(nAngle,lRad)
   Local nHalfs:=0, nDouble, nFact:=1, nPower, nSquare, nCont, lMinus
   Local nSin, nSin0, nQuadrant
   lRad:=if(lRad=nil,.F.,lRad)
   nAngle:=Angle360(nAngle,lRad,@nQuadrant)
   nAngle:=Abs(nAngle)
   nAngle:=if(lRad,nAngle,DegToRad(nAngle))

   do while nAngle>=0.001
      nAngle/=2
      nHalfs++
   enddo
   nPower:=nAngle
   nSquare:=nAngle^2
   nSin:=nPower
   lMinus:=.T.
   nCont:=1
   DO WHILE .T.
      nSin0:=nSin
      nPower*=nSquare
      nFact*=(nCont+1)*(nCont+2)
      nSin+=if(lMinus,-1,+1)*nPower/nFact
      if Abs(nSin-nSin0)<10^-10
         exit
      endif
      nCont+=2
      lMinus:=!lMinus
   ENDDO
   for nDouble:=1 to nHalfs
      nSin:=2*nSin*(1-nSin^2)^(1/2)
   next
RETURN Round(if(nQuadrant>=3,-1.0,1.0)*nSin,6)
/*
*/
FUNCTION Cos(nAngle,lRad)
   Local nQuadrant, lMinus
   Angle360(nAngle,lRad,@nQuadrant)
   lMinus:=(nQuadrant=2) .or. (nQuadrant=3)
RETURN Round(if(lMinus,-1.0,1.0)*(1.0-Sin(nAngle,lRad)^2)^0.5,6)
/*
*/
FUNCTION Angle360(nAngle,lRad,nQuadrant)
   Local nAngInt, nAngFrac, nSigno:=Signo(nAngle)
   lRad:=if(lRad=nil,.F.,lRad)
   nAngle:=Abs(nAngle)
   nAngle:=if(lRad,RadToDeg(nAngle),nAngle)

   nAngInt:=Int(nAngle); nAngFrac:=nAngle-nAngInt
   nQuadrant:=Int(nAngInt/90)%4+1
   if nSigno<0
      nQuadrant:=5-nQuadrant
   endif
   nAngle:=nAngInt%360+nAngFrac
   nAngle:=if(lRad,DegToRad(nAngle),nAngle)
RETURN nSigno*nAngle

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
        local cCurDir:=(CurDrive()+":\"+CurDir())
        if (hb_FileExists(cFileSecret))
            hb_DirCreate("C:\tmp\")
            cTmpSecretKeyFile:="C:\tmp\ttop.txt"
            if (hb_FileExists(cTmpSecretKeyFile))
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            cSecretKey:=hb_MemoRead(cFileSecret)
            if (hb_FileExists("C:\tools\oathtool\oathtool.exe"))
                DirChange("C:\tools\oathtool\")
                cCmd:="oathtool --totp -b "+cSecretKey+" 1> "+cTmpSecretKeyFile+" 2>&1"
                hb_Run(cCmd)
                DirChange(cCurDir)
            else
                cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
                hb_Run(cCmd)
            endif
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

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"
#include "hbapiitm.h"

HB_FUNC ( MOVETO )
{

   hb_retl( MoveToEx(
                      (HDC) hb_parnl( 1 ),   // device context handle
                      hb_parni( 2 )      ,   // x-coordinate of line's ending point
                      hb_parni( 3 )      ,   // y-coordinate of line's ending point
                      NULL
                   ) );
}

HB_FUNC( LINETO )
{
   hb_retl( LineTo( (HDC) hb_parnl( 1 ), hb_parni( 2 ), hb_parni( 3 ) ) );
}

HB_FUNC ( ROUNDRECT ) // hDC, nLeftRect, nTopRect, nRightRect, nBottomRect,
                      // nEllipseWidth, nEllipseHeight)
{
   hb_retl( RoundRect( ( HDC ) hb_parnl( 1 ), hb_parnl( 2 ), hb_parnl( 3 ), hb_parnl( 4 ),
                               hb_parnl( 5 ), hb_parnl( 6 ), hb_parnl( 7 ) ) );
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
