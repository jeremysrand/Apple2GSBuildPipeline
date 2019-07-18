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
        use 4/Qd.Macs
        use 4/Window.Macs
        use 4/Desk.Macs
        use 4/Resource.Macs
        use 4/GsOs.Macs

windowRes   = 1001

eventAction     = $0001
runAction       = $0002
cursorAction    = $0003
undoAction      = $0005
cutAction       = $0006
copyAction      = $0007
pasteAction     = $0008
clearAction     = $0009

updateEvt       = $0006
wInControl      = $0021
keyDownEvt      = $0003
autoKeyEvt      = $0005

setSysPrefs     = $0c
getSysPrefs     = $0f
setLevel        = $1a
getLevel        = $1b


        adrl NDAOpen
        adrl NDAClose
        adrl NDAAction
        adrl NDAInit
        dw   $ffff
        dw   $03ff
        asc  '  ___PACKAGENAME___  \H**'
        dw   $0


NDAOpen
        phb
        phk
        plb
        
        lda ndaActive
        beq doOpen
        plb
        rtl
        
doOpen
        iGSOS getLevel;levelDCB;1
        lda level
        sta oldLevel
        stz level
        iGSOS setLevel;levelDCB;1
        
        iGSOS getSysPrefs;prefsDCB;1
        lda prefs
        sta oldPrefs
        and #$1fff
        ora #$8000
        sta prefs
        iGSOS setSysPrefs;prefsDCB;1
        
        pha
        PushWord #1
        lda userId
        pha
        _OpenResourceFileByID
        PullWord oldResApp

        pha
        pha
        PushLong #winName
        PushLong #0
        PushLong #DrawContents
        PushLong #0
        PushWord #2
        PushLong #windowRes
        PushWord #$800E
        _NewWindow2
        PullLong winPtr
        
        PushLong winPtr
        _SetSysWindow
        PushLong winPtr
        _ShowWindow
        PushLong winPtr
        _SelectWindow
        
        lda #1
        sta ndaActive

        lda oldPrefs
        sta prefs
        iGSOS setSysPrefs;prefsDCB;1
        lda oldLevel
        sta level
        iGSOS setLevel;levelDCB;1
        
        PushWord oldResApp
        _SetCurResourceApp
        
        lda winPtr
        sta 5,S
        lda winPtr+2
        sta 7,S
        
        plb
        
        rtl
        
DrawContents
        phb
        phk
        plb
        
        _PenNormal
        PushWord #7
        PushWord #10
        _MoveTo
        PushLong #messageStr
        _DrawString
        
        plb
        
        rtl
        
NDAClose
        phb
        phk
        plb

        lda ndaActive
        beq closeNotActive
        
        PushLong winPtr
        _CloseWindow
        
        stz winPtr
        stz winPtr+2
        stz ndaActive
        
closeNotActive
        _ResourceShutDown
        
        plb
        rtl
        
NDAAction
        phb
        phk
        plb
        
        cmp #eventAction
        bne notEvent
        jsl HandleEvent
        bra actionDone
        
notEvent
        cmp #runAction
        bne notRun
        jsl HandleRun
        bra actionDone
        
notRun
        cmp #cursorAction
        bne notCursor
        jsl HandleCursor
        bra actionDone
        
notCursor
        cmp #undoAction
        blt notEdit
        cmp #clearAction+1
        bge notEdit
        jsl HandleEdit
        lda #1
        bra actionDone
        
notEdit
actionDone
        plb
        rtl
        
HandleEvent
* The X register has the low 16 bits of the address of the event record.
* We leave that there and use that in the memory move instruction to
* copy that event record into our local event.
*
* The Y register has the high 16 bits of the address of the event record.
* We need to get that into the upper 8 bits of the accumulator.
        tya
        xba
* Now we need to or in the current bank register into the lower 8 bits
* of the accumulator for the move instruction
        pea $0
        phb
        ora 1,S
* We have the source and destination banks in the accumulator now.  Modify
* the move instruction to have these banks and clean up the stack.
        sta moveIns+1
        plb
        pla
        
* X is already setup for the move.  We need the low 16 bits of the destination
* in the Y register and the count of bytes to copy minus one in the accumulator.
        ldy #localEvent
        lda #15             ; Copy 16 bytes
moveIns mvn 0,0
        
        pha
        PushWord #0
        PushLong #localEvent
        _TaskMasterDA
        pla
        
        cmp #updateEvt
        bne notUpdate
        PushLong winPtr
        _BeginUpdate
        jsl DrawContents
        PushLong winPtr
        _EndUpdate
        bra eventDone
        
notUpdate
        cmp #wInControl
        bne notControl
        jsl HandleControl
        bra eventDone
        
notControl
        cmp #keyDownEvt
        beq isKey
        cmp #autoKeyEvt
        beq isKey

eventDone
        rtl
        
isKey
        jsl HandleKey
        bra eventDone
        
        
HandleControl
* Add code here if you need to handle controls in your NDA window
        rtl
        
HandleKey
* Add code here if you need to handle keypresses
        rtl
        
HandleRun
* Add code here if you need to execute something periodically from your NDA
        rtl
        
HandleCursor
* Add code here if you need to do something to the cursor when over the NDA window
        rtl
        
HandleEdit
* Add code here to handle undo, cut, copy, paste or clear.  The A register holds
* the action code.
        rtl
        
NDAInit
        phb
        phk
        plb
        
        cmp #$00
        beq toolShutdown
        
        stz ndaActive
        
        pha
        _MMStartUp
        pla
        sta userId
        
        bra initReturn
        
toolShutdown
        lda ndaActive
        beq initReturn
        jsl NDAClose
        
initReturn
        plb
        rtl

* Global data
    
ndaActive   dw 0
winPtr      adrl 0
userId      dw 0
winName     str ' ___PACKAGENAME___ '
messageStr  str 'Hello, world!'

* Used by NDAOpen to access resources
oldResApp   dw 0
oldLevel    dw 0
oldPrefs    dw 0

levelDCB    dw 2        ; GSOS control block to get/set level
level       dw 0
            dw 0
            
prefsDCB    dw 1        ; GSOS control block to get/set preferences
prefs       dw 0

* Used by HandleEvent
localEvent
what                dw 0
message             adrl 0
when                adrl 0
where_vert          dw 0
where_horiz         dw 0
modifiers           dw 0
wmTaskData          adrl 0
wmTaskMask          adrl $001fffff
wmLastClickTick     adrl 0
wmClickCount        dw 0
wmTaskData2         adrl 0
wmTaskData3         adrl 0
wmTaskData4         adrl 0
wmLastClickPt_vert  dw 0
wmLastClickPt_horiz dw 0

