*
*  ___FILENAME___
*  ___PACKAGENAME___
*
* Created by ___FULLUSERNAME___ on ___DATE___.
* Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
*

]XCODESTART     ; Keep this at the start and put your code after this
    
        mx %00
    
        use 4/Util.Macs
        use 4/Mem.Macs
        use 4/Locator.Macs
        use 4/Qd.Macs
        use 4/Window.Macs
        use 4/Menu.Macs
        use 4/Desk.Macs
        use 4/Dos.16.Macs

menuBar   = 1

appleMenu = 3
fileMenu  = 4
editMenu  = 5

editUndo  = 250
editCut   = 251
editCopy  = 252
editPaste = 253
editClear = 254

fileNew   = 401
fileOpen  = 402
fileClose = 255
fileQuit  = 256

appleAbout = 301

aboutAlertString = 1

windowRes = 1001

toolStartup = 1

refIsHandle   = 1
refIsResource = 2

wInMenuBar = $11
wInGoAway  = $16
wInSpecial = $19


        phb
        phk
        plb
    
        pha
        _MMStartUp
        PullWord userid
        
        _TLStartUp
        
        pha
        pha
        PushWord userid
        PushWord #refIsResource
        PushLong #toolStartup
        _StartUpTools
        PullLong toolStartupRef
    
        jsl InitMenus
        _InitCursor
        
loop
        pha
        PushWord #$ffff
        PushLong #eventRec
        _TaskMaster
        pla
        
        cmp #wInMenuBar
        bne notInMenuBar
        jsl HandleMenu
        bra loop
        
notInMenuBar
        cmp #wInSpecial
        bne notInSpecial
        jsl HandleMenu
        bra loop
        
notInSpecial
        cmp #wInGoAway
        bne notInGoAway
* Put the low word of the grafport pointer to close in X and the high word in Y
        ldx wmTaskData
        ldy wmTaskData+2
        jsl CloseDocument
        
notInGoAway
        bra loop
        
        
InitMenus

        pha
        pha
        PushWord #refIsResource
        PushLong #menuBar
        PushLong #0
        _NewMenuBar2
        _SetSysBar
        PushLong #0
        _SetMenuBar
        PushWord #appleMenu
        _FixAppleMenu
        
        pha
        _FixMenuBar
        pla
        
        _DrawMenuBar
        
        rtl
    

HandleMenu
; The low word of the wmTaskData has the menu item number
        lda wmTaskData
        
        cmp #appleAbout
        bne notAbout
        jsl DoAbout
        bra menuDone
        
notAbout
        cmp #fileNew
        bne notNew
        jsl NewDocument
        bra menuDone
        
notNew
        cmp #fileOpen
        bne notOpen
        jsl NewDocument
        bra menuDone
        
notOpen
        cmp #fileClose
        bne notClose
        pha
        pha
        _FrontWindow
        plx
        ply
        jsl CloseDocument
        bra menuDone
        
notClose
        cmp #fileQuit
        bne notQuit
        jsl DoQuit
        bra menuDone
        
notQuit
        cmp #editUndo
        bne notUndo
* Handle undo here
        bra menuDone
        
notUndo
        cmp #editCut
        bne notCut
* Handle cut here
        bra menuDone
        
notCut
        cmp #editCopy
        bne notCopy
* Handle copy here
        bra menuDone
        
notCopy
        cmp #editPaste
        bne notPaste
* Handle paste here
        bra menuDone
        
notPaste
        cmp #editClear
        bne notClear
* Handle clear here
        bra menuDone
        
notClear
menuDone
        PushWord #0
        PushWord wmTaskData+2
        _HiliteMenu
        
        rtl
        
        
CloseDocument
* X has the low word of the grafport pointer, Y has the high word
        phy
        phx
        _CloseWindow
        
        rtl


NewDocument
        pha
        pha
        PushLong #winName
        PushLong #0
        PushLong #0
        PushLong #0
        PushWord #2
        PushLong #windowRes
        PushWord #$800E
        _NewWindow2
        pla
        pla
        
        rtl
        
        
DoAbout
        pha
        PushWord #4
        PushLong #0
        PushLong #aboutAlertString
        _AlertWindow
        pla
        rtl


DoQuit
        PushWord #refIsHandle
        PushLong toolStartupRef
        _ShutDownTools
        _TLShutDown
        PushWord userid
        _MMShutDown

        plb
        
        _QUIT quitDCB
        rtl

* Global data

userid          dw 0
toolStartupRef  adrl 0
winName         str 'MyWindow'

eventRec
what                dw 0
message             adrl 0
when                adrl 0
where_vert          dw 0
where_horiz         dw 0
modifiers           dw 0
wmTaskData          adrl 0
wmTaskMask          adrl $001f7fff
wmLastClickTick     adrl 0
wmClickCount        dw 0
wmTaskData2         adrl 0
wmTaskData3         adrl 0
wmTaskData4         adrl 0
wmLastClickPt_vert  dw 0
wmLastClickPt_horiz dw 0

* Used by doQuit
quitDCB         dw 0

