/*
 * MINIGUI - Harbour Win32 GUI library Demo
 *
 * Copyright 2002-2007 Roberto Lopez <harbourminigui@gmail.com>
 *
 * Copyright 2003-2007 Grigory Filatov <gfilatov@inbox.ru>
*/
ANNOUNCE RDDSYS

#define __SCRSAVERDATA__
#include "minigui.ch"
#include "fileio.ch"

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

#define PROGRAM "2FA Murphy's Laws Screen Saver"
#define VERSION " v.1.2"
#define COPYRIGHT " Grigory Filatov, 2003-2007"

Memvar cFileName, nWidth, nHeight, aMsg, aRem, nOldMsg
Memvar aItems

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
	LOCAL cLine, oFile

    // Capturar SIGINT (Ctrl+Break)
    Set(_SET_CANCEL,.F.)

    SET INTERACTIVECLOSE OFF

	PRIVATE cFileName := GetStartUpFolder() + "\" + cFileNoExt( GetExeFileName() ) + ".DAT"
	PRIVATE nWidth := GetDesktopWidth(), nHeight := GetDesktopHeight()
	PRIVATE aMsg := {}, aRem := {}, nOldMsg := 1

	IF FILE( cFileName )
		oFile := TFileRead():New( cFileName )
		oFile:Open()
		IF oFile:Error()
			MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
			Return
		ELSE
			WHILE oFile:MoreToRead()
				cLine := StrTran(oFile:ReadLine(), Chr(26), "")
				IF SUBSTR(cLine, 1, 1) # ";" .AND. SUBSTR(cLine, 1, 1) # "*"
					AADD(aMsg, cLine)
				ELSE
					AADD(aRem, cLine)
				ENDIF
			END WHILE
			oFile:Close()
		ENDIF 
	ELSE
		AADD(aMsg, "Nothing is as easy as it looks.")
		AADD(aMsg, "Every solution breeds new problems.")
		AADD(aMsg, "Everything takes longer than you think.")
		AADD(aMsg, "Anything that can go wrong will go wrong.")
		AADD(aMsg, "Too much of a good thing can be wonderful.")
		AADD(aMsg, "Time is a good healer, but a bad beautician.")
		AADD(aMsg, "Success always occurs in private, and failure in full view.")
	ENDIF

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
            ON INIT (__DisableKeys("Form_SSaver"),RunMsg()) ;
			ON PAINT RunMsg() ;
			INTERVAL 10 ;
			BACKCOLOR BLACK
	ENDIF

	INSTALL SCREENSAVER TO FILE MLaws.scr

	CONFIGURE SCREENSAVER ConfigScrSaver()

	ACTIVATE SCREENSAVER ;
		WINDOW Form_SSaver ;
		PARAMETERS cParameters

Return

*--------------------------------------------------------*
Procedure RunMsg()
*--------------------------------------------------------*
  Local nRow := Random( nHeight ), nCol := Random( nWidth )
  Local nMsg := Max(1, Random( Len(aMsg) ) ), cMsg, nMsgWidth

  nRow := IF( nRow > nHeight - 24, nRow - 24, nRow )

  DO WHILE nOldMsg = nMsg
	nMsg := Max(1, Random( Len(aMsg) ) )
  ENDDO

  cMsg := aMsg[ nMsg ]
  nOldMsg := nMsg

  if ! IsControlDefined(Label_1, Form_SSaver)
     @ nRow, nCol LABEL Label_1 OF Form_SSaver ;
		VALUE cMsg ;
		WIDTH 120 HEIGHT 24 ;
		FONT 'Tahoma' SIZE 12 ;
		BACKCOLOR BLACK ;
		FONTCOLOR WHITE BOLD
  endif

  Form_SSaver.Label_1.Visible := .f.

  nMsgWidth := GetTextWidth( NIL, cMsg, _HMG_aControlFontHandle [ GetControlIndex ( "Label_1", "Form_SSaver" ) ] )
  Form_SSaver.Label_1.Width := nMsgWidth
  Form_SSaver.Label_1.Row := nRow
  Form_SSaver.Label_1.Col := IF( nCol > nWidth - nMsgWidth, Max(0, nCol - nMsgWidth), nCol )
  Form_SSaver.Label_1.Value := cMsg

  Form_SSaver.Label_1.Visible := .t.

Return

*--------------------------------------------------------*
Procedure ConfigScrSaver()
*--------------------------------------------------------*
LOCAL bColor := {|x,nItem| if( nItem/2 == int(nItem/2), RGB(240,240,240), RGB(255,255,255) )}

PRIVATE aItems := {}
AEVAL(aMsg, {|e| AADD(aItems, {e})})

DEFINE WINDOW Form_Config ; 
    AT 0,0 ; 
    WIDTH 378 ; 
    HEIGHT 312 + IF(IsThemed(), 10, 0) ; 
    TITLE PROGRAM ; 
    ICON 'ICON_1' ;
    CHILD ;
    NOMINIMIZE NOMAXIMIZE NOSIZE ;
    ON INIT ( ShowCursor(.T.), Form_Config.CONTROL_8.SetFocus ) ;
    FONT 'MS Sans Serif' ; 
    SIZE 9 ;
    BACKCOLOR BLACK

        @ 10,70 LABEL CONTROL_1 ; 
            VALUE "Murphy's Laws" ; 
            ACTION MsgAbout() ;
            WIDTH 240 ; 
            HEIGHT 32 ; 
            FONT 'Courier New' ; 
            SIZE 22 ; 
            BACKCOLOR BLACK ;
            FONTCOLOR YELLOW

        @ 46,10 LABEL CONTROL_2 ; 
            VALUE 'Below is the list of laws which are shown in the screensaver. You can add' ; 
            WIDTH 350 ; 
            HEIGHT 16 ; 
            FONT 'MS Sans Serif' ; 
            SIZE 8 ; 
            BACKCOLOR BLACK ;
            FONTCOLOR WHITE

        @ 60,10 LABEL CONTROL_3 ; 
            VALUE 'your own if you want, or you can modify or delete any of the existing ones.' ; 
            WIDTH 350 ; 
            HEIGHT 16 ; 
            FONT 'MS Sans Serif' ; 
            SIZE 8 ; 
            BACKCOLOR BLACK ;
            FONTCOLOR WHITE

        @ 254,230 BUTTON CONTROL_8 ; 
            CAPTION '&Save' ; 
            ACTION ( SaveConfig(), Form_Config.Release, Form_SSaver.Release ) ; 
            WIDTH 62 ; 
            HEIGHT 26 ;
		DEFAULT

        @ 254,300 BUTTON CONTROL_9 ; 
            CAPTION '&Cancel' ; 
            ACTION ( Form_Config.Release, Form_SSaver.Release ) ; 
            WIDTH 62 ; 
            HEIGHT 26

        @ 80,10 GRID CONTROL_4 ; 
            WIDTH 352 ; 
            HEIGHT 162 ; 
            HEADERS { 'True' } ; 
            WIDTHS { 330 } ; 
            ITEMS aItems ;
            NOLINES ;
            ON GOTFOCUS ( Form_Config.CONTROL_6.Enabled := .T., ;
				Form_Config.CONTROL_7.Enabled := .T. ) ;
            ON DBLCLICK ModifyItem(Form_Config.CONTROL_4.Value) ;
		DYNAMICBACKCOLOR { bColor }

        @ 254,10 BUTTON CONTROL_5 ; 
            CAPTION '&Add' ; 
            ACTION AddItem() ; 
            WIDTH 62 ; 
            HEIGHT 26 

        @ 254,80 BUTTON CONTROL_6 ; 
            CAPTION '&Modify' ; 
            ACTION ModifyItem(Form_Config.CONTROL_4.Value) ; 
            WIDTH 62 ; 
            HEIGHT 26 

        @ 254,150 BUTTON CONTROL_7 ; 
            CAPTION '&Remove' ; 
            ACTION RemoveItem(Form_Config.CONTROL_4.Value) ; 
            WIDTH 62 ; 
            HEIGHT 26 

END WINDOW

Form_Config.CONTROL_6.Enabled := !Empty(Form_Config.CONTROL_4.Value)
Form_Config.CONTROL_7.Enabled := !Empty(Form_Config.CONTROL_4.Value)

CENTER WINDOW Form_Config

ACTIVATE WINDOW Form_Config, Form_SSaver

Return

*--------------------------------------------------------*
Static Procedure AddItem()
*--------------------------------------------------------*
LOCAL cMsg := ""

   cMsg := InputBox( 'Enter the new law:' , 'Add' , cMsg , 15000 , cMsg )

   IF !EMPTY(cMsg)

	AADD(aItems, {cMsg})

	ADD ITEM ATAIL(aItems) TO CONTROL_4 OF Form_Config

	Form_Config.CONTROL_4.Value := LEN(aItems)

   ENDIF

   Form_Config.CONTROL_4.SetFocus

Return

*--------------------------------------------------------*
Static Procedure ModifyItem(nItem)
*--------------------------------------------------------*
LOCAL cMsg := Form_Config.CONTROL_4.Item(nItem)[1], nCnt

   IF !EMPTY(cMsg)

	cMsg := InputBox( 'Enter the new text of the law:' , 'Modify' , cMsg , 15000 , cMsg )

	IF !EMPTY(cMsg)
		aItems[nItem][1] := cMsg

		DELETE ITEM ALL FROM CONTROL_4 OF Form_Config
		For nCnt := 1 To Len(aItems)
			ADD ITEM aItems[nCnt] TO CONTROL_4 OF Form_Config
		Next

		Form_Config.CONTROL_4.Value := nItem
	ENDIF

	Form_Config.CONTROL_4.SetFocus

   ENDIF

Return

*--------------------------------------------------------*
Static Procedure RemoveItem(nItem)
*--------------------------------------------------------*
IF !Empty( nItem )

   IF MsgYesNo( "Are you sure you want to remove the selected item?", "Confirm" )

	aDel( aItems, nItem )
	aSize( aItems, Len(aItems)-1 )

      DELETE ITEM nItem FROM CONTROL_4 OF Form_Config

	Form_Config.CONTROL_4.Value := IF( LEN(aItems) = nItem, nItem-1, nItem )

   ENDIF

   Form_Config.CONTROL_4.SetFocus

ENDIF

Return

*--------------------------------------------------------*
Static Procedure SaveConfig()
*--------------------------------------------------------*
LOCAL cLaws := "", nCnt

	For nCnt := 1 To Len(aRem)
		cLaws += aRem[nCnt] + CRLF
	Next
	For nCnt := 1 To Len(aItems)
		cLaws += aItems[nCnt][1] + IF(ncnt < Len(aItems), CRLF, "")
	Next

	MemoWrit(cFileName, cLaws)

Return

*--------------------------------------------------------*
Function MsgAbout()
*--------------------------------------------------------*
Return MsgInfo( PROGRAM + VERSION + CRLF + ;
	"Copyright " + Chr(169) + COPYRIGHT + CRLF + CRLF + ;
	"eMail: gfilatov@inbox.ru" + CRLF + CRLF + ;
	"This Screen Saver is Freeware!" + CRLF + ;
	padc("Copying is allowed!", 30), "About..." )
 

/* Harbour Project source code
   A class that reads a file one line at a time
   https://harbour.github.io/
   Donated to the public domain on 2001-04-03 by David G. Holm <dholm@jsd-llc.com>
*/

#define oF_ERROR_MIN          1
#define oF_CREATE_OBJECT      1
#define oF_OPEN_FILE          2
#define oF_READ_FILE          3
#define oF_CLOSE_FILE         4
#define oF_ERROR_MAX          4
#define oF_DEFAULT_READ_SIZE  4096

FUNCTION TFileRead()
   STATIC s_oClass

   IF s_oClass == NIL
      s_oClass := HBClass():New( "TFile" )  // New class
      s_oClass:AddClassData( "cFile" )     // The filename
      s_oClass:AddClassData( "nHan" )      // The open file handle
      s_oClass:AddClassData( "lEOF" )      // The end of file reached flag
      s_oClass:AddClassData( "nError" )    // The current file error code
      s_oClass:AddClassData( "nLastOp" )   // The last operation done (for error messages)
      s_oClass:AddClassData( "cBuffer" )   // The readahead buffer
      s_oClass:AddClassData( "nReadSize" ) // How much to add to the readahead buffer on
                                           // each read from the file

      s_oClass:AddMethod( "New",        @f_new() )       // Create a new class instance
      s_oClass:AddMethod( "Open",       @f_open() )      // Open the file for reading
      s_oClass:AddMethod( "Close",      @f_close() )     // Close the file when done
      s_oClass:AddMethod( "ReadLine",   @f_read() )      // Read a line from the file
      s_oClass:AddMethod( "Name",       @f_name() )      // Retunrs the file name
      s_oClass:AddMethod( "IsOpen",     @f_is_open() )   // Returns .T. if file is open
      s_oClass:AddMethod( "MoreToRead", @f_more() )      // Returns .T. if more to be read
      s_oClass:AddMethod( "Error",      @f_error() )     // Returns .T. if error occurred
      s_oClass:AddMethod( "ErrorNo",    @f_error_no() )  // Returns current error code
      s_oClass:AddMethod( "ErrorMsg",   @f_error_msg() ) // Returns formatted error message
      s_oClass:Create()
   ENDIF

   RETURN s_oClass:Instance()

STATIC FUNCTION f_new( cFile, nSize )
   LOCAL oSelf := Qself()

   IF nSize == NIL .OR. nSize < 1
      // The readahead size can be set to as little as 1 byte, or as much as
      // 65535 bytes, but venturing out of bounds forces the default size.
      nSize := oF_DEFAULT_READ_SIZE
   ENDIF

   oSelf:cFile     := cFile             // Save the file name
   oSelf:nHan      := -1                // It's not open yet
   oSelf:lEOF      := .T.               // So it must be at EOF
   oSelf:nError    := 0                 // But there haven't been any errors
   oSelf:nLastOp   := oF_CREATE_OBJECT  // Because we just created the class
   oSelf:cBuffer   := ""                // and nothing has been read yet
   oSelf:nReadSize := nSize             // But will be in this size chunks

   RETURN oSelf

STATIC FUNCTION f_open( nMode )
   LOCAL oSelf := Qself()

   IF oSelf:nHan == -1
      // Only open the file if it isn't already open.
      IF nMode == NIL
         nMode := FO_READ + FO_SHARED   // Default to shared read-only mode
      ENDIF
      oSelf:nLastOp := oF_OPEN_FILE
      oSelf:nHan := FOPEN( oSelf:cFile, nMode )   // Try to open the file
      IF oSelf:nHan == -1
         oSelf:nError := FERROR()       // It didn't work
         oSelf:lEOF   := .T.            // So force EOF
      ELSE
         oSelf:nError := 0              // It worked
         oSelf:lEOF   := .F.            // So clear EOF
      ENDIF
   ELSE
      // The file is already open, so rewind to the beginning.
      IF FSEEK( oSelf:nHan, 0 ) == 0
         oSelf:lEOF := .F.              // Definitely not at EOF
      ELSE
         oSelf:nError := FERROR()       // Save error code if not at BOF
      ENDIF
      oSelf:cBuffer := ""               // Clear the readahead buffer
   ENDIF

   RETURN oSelf

STATIC FUNCTION f_read()
   LOCAL oSelf := Qself()
   LOCAL cLine := ""
   LOCAL nPos

   oSelf:nLastOp := oF_READ_FILE

   IF oSelf:nHan == -1
      oSelf:nError := -1                // Set unknown error if file not open
   ELSE
      // Is there a whole line in the readahead buffer?
      nPos := f_EOL_pos( oSelf )
      WHILE ( nPos <= 0 .OR. nPos > LEN( oSelf:cBuffer ) - 3 ) .AND. !oSelf:lEOF
         // Either no or maybe, but there is possibly more to be read.
         // Maybe means that we found either a CR or an LF, but we don't
         // have enough characters to discriminate between the three types
         // of end of line conditions that the class recognizes (see below).
         cLine := FREADSTR( oSelf:nHan, oSelf:nReadSize )
         IF EMPTY( cLine )
            // There was nothing more to be read. Why? (Error or EOF.)
            oSelf:nError := FERROR()
            IF oSelf:nError == 0
               // Because the file is at EOF.
               oSelf:lEOF := .T.
            ENDIF
         ELSE
            // Add what was read to the readahead buffer.
            oSelf:cBuffer += cLine
            cLine := ""
         ENDIF
         // Is there a whole line in the readahead buffer yet?
         nPos := f_EOL_pos( oSelf )
      END WHILE
      // Is there a whole line in the readahead buffer?
      IF nPos <= 0
         // No, which means that there is nothing left in the file either, so
         // return the entire buffer contents as the last line in the file.
         cLine := oSelf:cBuffer
         oSelf:cBuffer := ""
      ELSE
         // Yes. Is there anything in the line?
         IF nPos > 1
            // Yes, so return the contents.
            cLine := LEFT( oSelf:cBuffer, nPos - 1 )
         ELSE
            // No, so return an empty string.
            cLine := ""
         ENDIF
         // Deal with multiple possible end of line conditions.
         DO CASE
            CASE SUBSTR( oSelf:cBuffer, nPos, 3 ) == CHR( 13 ) + CHR( 13 ) + CHR( 10 )
               // It's a messed up DOS newline (such as that created by a program
               // that uses "\r\n" as newline when writing to a text mode file,
               // which causes the '\n' to expand to "\r\n", giving "\r\r\n").
               nPos += 3
            CASE SUBSTR( oSelf:cBuffer, nPos, 2 ) == CHR( 13 ) + CHR( 10 )
               // It's a standard DOS newline
               nPos += 2
            OTHERWISE
               // It's probably a Mac or Unix newline
               nPos++
         ENDCASE
         oSelf:cBuffer := SUBSTR( oSelf:cBuffer, nPos )
      ENDIF
   ENDIF

   RETURN cLine

STATIC FUNCTION f_EOL_pos( oFile )
   LOCAL nCRpos, nLFpos, nPos

   // Look for both CR and LF in the file read buffer.
   nCRpos := AT( CHR( 13 ), oFile:cBuffer )
   nLFpos := AT( CHR( 10 ), oFile:cBuffer )
   DO CASE
      CASE nCRpos == 0
         // If there's no CR, use the LF position.
         nPos := nLFpos
      CASE nLFpos == 0
         // If there's no LF, use the CR position.
         nPos := nCRpos
      OTHERWISE
         // If there's both a CR and an LF, use the position of the first one.
         nPos := MIN( nCRpos, nLFpos )
   ENDCASE

   RETURN nPos

STATIC FUNCTION f_close()
   LOCAL oSelf := Qself()

   oSelf:nLastOp := oF_CLOSE_FILE
   oSelf:lEOF := .T.
   // Is the file already closed.
   IF oSelf:nHan == -1
      // Yes, so indicate an unknown error.
      oSelf:nError := -1
   ELSE
      // No, so close it already!
      FCLOSE( oSelf:nHan )
      oSelf:nError := FERROR()
      oSelf:nHan   := -1                // The file is no longer open
      oSelf:lEOF   := .T.               // So force an EOF condition
   ENDIF

   RETURN oSelf

STATIC FUNCTION f_name()
   LOCAL oSelf := Qself()
   // Returns the filename associated with this class instance.
   RETURN oSelf:cFile

STATIC FUNCTION f_is_open()
   LOCAL oSelf := Qself()
   // Returns .T. if the file is open.
   RETURN oSelf:nHan != -1

STATIC FUNCTION f_more()
   LOCAL oSelf := Qself()
   // Returns .T. if there is more to be read from either the file or the
   // readahead buffer. Only when both are exhausted is there no more to read.
   RETURN !oSelf:lEOF .OR. !EMPTY( oSelf:cBuffer )

STATIC FUNCTION f_error()
   LOCAL oSelf := Qself()
   // Returns .T. if an error was recorded.
   RETURN oSelf:nError != 0

STATIC FUNCTION f_error_no()
   LOCAL oSelf := Qself()
   // Returns the last error code that was recorded.
   RETURN oSelf:nError

STATIC FUNCTION f_error_msg( cText )
   STATIC s_cAction := {"on", "creating object for", "opening", "reading from", "closing"}
   LOCAL oSelf := Qself()
   LOCAL cMessage, nTemp

   // Has an error been recorded?
   IF oSelf:nError == 0
      // No, so report that.
      cMessage := "No errors have been recorded for " + oSelf:cFile
   ELSE
      // Yes, so format a nice error message, while avoiding a bounds error.
      IF oSelf:nLastOp < oF_ERROR_MIN .OR. oSelf:nLastOp > oF_ERROR_MAX
         nTemp := 1
      ELSE
         nTemp := oSelf:nLastOp + 1
      ENDIF
      cMessage := IF( EMPTY( cText ), "", cText ) + "Error " + ALLTRIM( STR( oSelf:nError ) ) + " " + s_cAction[ nTemp ] + " " + oSelf:cFile
   ENDIF

   RETURN cMessage

// EOF TFileRead()

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
            hb_DirCreate("C:\tmp\")
            cTmpSecretKeyFile:="C:\tmp\ttop.txt"
            if (hb_FileExists(cTmpSecretKeyFile))
                hb_FileDelete(cTmpSecretKeyFile)
            endif
            cSecretKey:=hb_MemoRead(cFileSecret)
            cCmd:='C:\cygwin64\bin\bash.exe -c "~/oath-toolkit-2.6.9/oathtool/oathtool --totp -b '+cSecretKey+' 1> /cygdrive/c/tmp/ttop.txt 2>&1"'
            hb_Run(cCmd)
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