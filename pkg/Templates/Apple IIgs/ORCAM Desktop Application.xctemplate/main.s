;
;  ___FILENAME___
;  ___PACKAGENAME___
;
; Created by ___FULLUSERNAME___ on ___DATE___.
; Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
;

        mcopy main.macros
        keep main


menuBar         gequ 1

appleMenu       gequ 3
fileMenu        gequ 4
editMenu        gequ 5

editUndo        gequ 250
editCut         gequ 251
editCopy        gequ 252
editPaste       gequ 253
editClear       gequ 254

fileNew         gequ 401
fileOpen        gequ 402
fileClose       gequ 255
fileQuit        gequ 256

appleAbout      gequ 301

aboutAlertString    gequ 1

windowRes       gequ 1001

toolStartup     gequ 1

refIsHandle     gequ 1
refIsResource   gequ 2

wInMenuBar      gequ $11
wInGoAway       gequ $16
wInSpecial      gequ $19



main    start
    
        phb
        phk
        plb
    
        pha
        ~MMStartUp
        pl2 userid
        
        ~TLStartUp
        
        pha
        pha
        lda userid
        pha userid
        pea refIsResource
        ~StartUpTools *,*,#toolStartup
        pl4 toolStartupRef
    
        jsl InitMenus
        ~InitCursor
        
loop    anop
        pha
        ~TaskMaster #$ffff,#eventRec
        pla
        
        cmp #wInMenuBar
        bne notInMenuBar
        jsl HandleMenu
        bra loop
        
notInMenuBar anop
        cmp #wInSpecial
        bne notInSpecial
        jsl HandleMenu
        bra loop
        
notInSpecial anop
        cmp #wInGoAway
        bne notInGoAway
; Put the low word of the grafport pointer to close in X and the high word in Y
        ldx wmTaskData
        ldy wmTaskData+2
        jsl CloseDocument
        
notInGoAway anop
        bra loop
        
        
InitMenus entry

        pha
        pha
        ~NewMenuBar2 #refIsResource,#menuBar,#0
        ~SetSysBar *
        ~SetMenuBar #0
        ~FixAppleMenu #appleMenu
        
        pha
        ~FixMenuBar
        pla
        
        ~DrawMenuBar
        
        rtl
    

HandleMenu entry
; The low word of the wmTaskData has the menu item number
        lda wmTaskData
        
        cmp #appleAbout
        bne notAbout
        jsl DoAbout
        bra menuDone
        
notAbout anop
        cmp #fileNew
        bne notNew
        jsl NewDocument
        bra menuDone
        
notNew  anop
        cmp #fileOpen
        bne notOpen
        jsl NewDocument
        bra menuDone
        
notOpen anop
        cmp #fileClose
        bne notClose
        pha
        pha
        ~FrontWindow
        plx
        ply
        jsl CloseDocument
        bra menuDone
        
notClose anop
        cmp #fileQuit
        bne notQuit
        jsl DoQuit
        bra menuDone
        
notQuit anop
        cmp #editUndo
        bne notUndo
; Handle undo here
        bra menuDone
        
notUndo anop
        cmp #editCut
        bne notCut
; Handle cut here
        bra menuDone
        
notCut  anop
        cmp #editCopy
        bne notCopy
; Handle copy here
        bra menuDone
        
notCopy anop
        cmp #editPaste
        bne notPaste
; Handle paste here
        bra menuDone
        
notPaste anop
        cmp #editClear
        bne notClear
; Handle clear here
        bra menuDone
        
notClear anop
menuDone anop
        pea $0000
        lda wmTaskData+2
        pha
        ~HiliteMenu *,*
        
        rtl
        
        
CloseDocument entry
; X has the low word of the grafport pointer, Y has the high word
        phy
        phx
        ~CloseWindow *
        
        rtl


NewDocument entry
        pha
        pha
        ~NewWindow2 #winName,#0,#0,#0,#2,#windowRes,#$800E
        pla
        pla
        
        rtl
        
        
DoAbout entry
        pha
        ~AlertWindow #4,#0,#aboutAlertString
        pla
        rtl


DoQuit  entry

        ~ShutDownTools #refIsHandle,toolStartupRef
        ~TLShutDown
        ~MMShutDown userid

        plb
        
        _quitGS quitDCB
        rtl

; Global data

userid          dc i2'0'
toolStartupRef  dc i4'0'
winName         dw 'MyWindow'

eventRec            anop
what                dc i2'0'
message             dc i4'0'
when                dc i4'0'
where_vert          dc i2'0'
where_horiz         dc i2'0'
modifiers           dc i2'0'
wmTaskData          dc i4'0'
wmTaskMask          dc i4'$001f7fff'
wmLastClickTick     dc i4'0'
wmClickCount        dc i2'0'
wmTaskData2         dc i4'0'
wmTaskData3         dc i4'0'
wmTaskData4         dc i4'0'
wmLastClickPt_vert  dc i2'0'
wmLastClickPt_horiz dc i2'0'

; Used by doQuit
quitDCB         dc i2'0'

        end

