;
;  ___FILENAME___
;  ___PACKAGENAME___
;
; Created by ___FULLUSERNAME___ on ___DATE___.
; Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
;

        mcopy main.macros
        keep main

windowRes   gequ    1001

eventAction     gequ $0001
runAction       gequ $0002
cursorAction    gequ $0003
undoAction      gequ $0005
cutAction       gequ $0006
copyAction      gequ $0007
pasteAction     gequ $0008
clearAction     gequ $0009

updateEvt       gequ $0006
wInControl      gequ $0021
keyDownEvt      gequ $0003
autoKeyEvt      gequ $0005


main    start
        dc i4'NDAOpen'          ; Open callback
        dc i4'NDAClose'         ; Close callback
        dc i4'NDAAction'        ; Action callback
        dc i4'NDAInit'          ; Init callback
        dc i2'$ffff'            ; Period
        dc i2'$03ff'            ; Event mask
        dc c'  ___PACKAGENAME___\\H**'   ; Menu line
        dc i1'0'
        
        end


NDAOpen start
        
        phb
        phk
        plb
        
        lda ndaActive
        beq doOpen
        plb
        rtl
        
doOpen  anop

        _getLevelGS levelDCB
        lda level
        sta oldLevel
        stz level
        _setLevelGS levelDCB
        
        _getSysPrefsGS prefsDCB
        lda prefs
        sta oldPrefs
        and #$1fff
        ora #$8000
        sta prefs
        _setSysPrefsGS prefsDCB
        
        pha
        ~OpenResourceFileByID #1,userId
        pl2 oldResApp

        pha
        pha
        ~NewWindow2 #winName,#0,#DrawContents,#0,#2,#windowRes,#$800E
        pl4 winPtr
        
        ~SetSysWindow winPtr
        ~ShowWindow winPtr
        ~SelectWindow winPtr
        
        lda #1
        sta ndaActive

        lda oldPrefs
        sta prefs
        _setSysPrefsGS prefsDCB
        lda oldLevel
        sta level
        _setLevelGS levelDCB
        
        ~SetCurResourceApp oldResApp
        
        lda winPtr
        sta 5,S
        lda winPtr+2
        sta 7,S
        
        plb
        
        rtl
        
DrawContents entry
        phb
        phk
        plb
        
        ~PenNormal
        ~MoveTo #7,#10
        ~DrawString #messageStr
        
        plb
        
        rtl
        
NDAClose entry
        phb
        phk
        plb

        lda ndaActive
        beq closeNotActive
        
        ~CloseWindow winPtr
        
        stz winPtr
        stz winPtr+2
        stz ndaActive
        
closeNotActive anop
        ~ResourceShutdown
        
        plb
        rtl
        
NDAAction entry

        phb
        phk
        plb
        
        cmp #eventAction
        bne notEvent
        jsl HandleEvent
        bra actionDone
        
notEvent anop
        cmp #runAction
        bne notRun
        jsl HandleRun
        bra actionDone
        
notRun  anop
        cmp #cursorAction
        bne notCursor
        jsl HandleCursor
        bra actionDone
        
notCursor anop
        cmp #undoAction
        blt notEdit
        cmp #clearAction+1
        bge notEdit
        jsl HandleEdit
        lda #1
        bra actionDone
        
notEdit anop
actionDone anop
        plb
        rtl
        
HandleEvent entry
; The X register has the low 16 bits of the address of the event record.
; We leave that there and use that in the memory move instruction to
; copy that event record into our local event.
;
; The Y register has the high 16 bits of the address of the event record.
; We need to get that into the upper 8 bits of the accumulator.
        tya
        xba
; Now we need to or in the current bank register into the lower 8 bits
; of the accumulator for the move instruction
        pea $0
        phb
        ora 1,S
; We have the source and destination banks in the accumulator now.  Modify
; the move instruction to have these banks and clean up the stack.
        sta moveIns+1
        plb
        pla
        
; X is already setup for the move.  We need the low 16 bits of the destination
; in the Y register and the count of bytes to copy minus one in the accumulator.
        ldy #localEvent
        lda #15             ; Copy 16 bytes
moveIns mvn 0,0
        
        pha
        ~TaskMasterDA #0,#localEvent
        pla
        
        cmp #updateEvt
        bne notUpdate
        ~BeginUpdate winPtr
        jsl DrawContents
        ~EndUpdate winPtr
        bra eventDone
        
notUpdate anop
        cmp #wInControl
        bne notControl
        jsl HandleControl
        bra eventDone
        
notControl anop
        cmp #keyDownEvt
        beq isKey
        cmp #autoKeyEvt
        beq isKey

eventDone anop
        rtl
        
isKey   anop
        jsl HandleKey
        bra eventDone
        
        
HandleControl entry
; Add code here if you need to handle controls in your NDA window
        rtl
        
HandleKey entry
; Add code here if you need to handle keypresses
        rtl
        
HandleRun entry
; Add code here if you need to execute something periodically from your NDA
        rtl
        
HandleCursor entry
; Add code here if you need to do something to the cursor when over the NDA window
        rtl
        
HandleEdit entry
; Add code here to handle undo, cut, copy, paste or clear.  The A register holds
; the action code.
        rtl
        
NDAInit entry
        phb
        phk
        plb
        cmp #$00
        beq toolShutdown
        
        stz ndaActive
        
        pha
        ~MMStartUp
        pla
        sta userId
        
        bra initReturn
        
toolShutdown anop
        lda ndaActive
        beq initReturn
        jsl NDAClose
        
initReturn anop
        plb
        rtl

; Global data
    
ndaActive   dc i2'0'
winPtr      dc i4'0'
userId      dc i2'0'
winName     dw ' ___PACKAGENAME___ '
messageStr  dw 'Hello, world!'

; Used by NDAOpen to access resources
oldResApp   dc i2'0'
oldLevel    dc i2'0'
oldPrefs    dc i2'0'

levelDCB    dc i2'2'    ; GSOS control block to get/set level
level       dc i2'0'
            dc i2'0'
            
prefsDCB    dc i2'1'    ; GSOS control block to get/set preferences
prefs       dc i2'0'

; Used by HandleEvent
localEvent          anop
what                dc i2'0'
message             dc i4'0'
when                dc i4'0'
where_vert          dc i2'0'
where_horiz         dc i2'0'
modifiers           dc i2'0'
wmTaskData          dc i4'0'
wmTaskMask          dc i4'$001fffff'
wmLastClickTick     dc i4'0'
wmClickCount        dc i2'0'
wmTaskData2         dc i4'0'
wmTaskData3         dc i4'0'
wmTaskData4         dc i4'0'
wmLastClickPt_vert  dc i2'0'
wmLastClickPt_horiz dc i2'0'


        end
