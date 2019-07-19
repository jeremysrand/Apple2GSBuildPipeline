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
        use 4/Ctl.Macs

* Resource numbers
cdevResource = $1
mainResource = $100
helpResource = $101

* CDEV Message Numbers
machineCDev  = 1
bootCDev     = 2
reservedCDev = 3
initCDev     = 4
closeCDev    = 5
eventsCDev   = 6
createCDev   = 7
aboutCDev    = 8
rectCDev     = 9
hitCDev      = 10
runCDev      = 11
editCDev     = 12

* Edit menu actions
undoAction  = 5
cutAction   = 6
copyAction  = 7
pasteAction = 8
clearAction = 9

* Offsets in direct page from the stack
message = $0c
data1   = $08
data2   = $04

main
        tsc
        phd
        tcd
        lda message
        cmp #machineCDev
        bne notMachine
* Return zero if you cannot be opened on this machine
* (and maybe display an alert explaining why).
        lda $02
        sta $0c
        lda $01
        sta $0b
        pld
        tsc
        clc
        adc #$a
        tcs
        lda #$1
        rtl
        
notMachine
        cmp #bootCDev
        bne notBoot
        jsl doBoot
        bra done

notBoot
        cmp #initCDev
        bne notInit
        jsl doInit
        bra done
        
notInit
        cmp #closeCDev
        bne notClose
        jsl doClose
        bra done
        
notClose
        cmp #eventsCDev
        bne notEvents
        jsl doEvents
        bra done
        
notEvents
        cmp #createCDev
        bne notCreate
        jsl doCreate
        bra done
        
notCreate
        cmp #aboutCDev
        bne notAbout
        jsl doAbout
        bra done
        
notAbout
        cmp #rectCDev
        bne notRect
        jsl doRect
        bra done
        
notRect
        cmp #hitCDev
        bne notHit
        jsl doHit
        bra done
        
notHit
        cmp #runCDev
        bne notRun
        jsl doRun
        bra done
        
notRun
        cmp #editCDev
        bne notEdit
        jsl doEdit
        bra done
        
notEdit

done
        lda $02
        sta $0c
        lda $01
        sta $0b
        pld
        tsc
        clc
        adc #$a
        tcs
        lda #$1
        rtl
        
doBoot
* data1 is a pointer to a flag.  Set bit 0 to 1 in this flag if you want to
* draw an X through the icon at boot time to indicate that this CDev will not
* load.
        rtl
        
        
doInit
* data1 is a pointer to the grafport.
        rtl
        
    
doClose
* data1 is a pointer to the grafport.
        rtl
        
        
doEvents
* data1 is a pointer to the event record.
* data2 is a pointer to the grafport.
        rtl
        
    
doCreate
* data1 is a pointer to the grafport.
        pha
        pha
        PushLong data1
        PushWord #9
        PushLong #mainResource
        _NewControl2
        pla
        pla
        rtl
        
        
doAbout
* data1 is a pointer to the grafport.
        pha
        pha
        PushLong data1
        PushWord #9
        PushLong #helpResource
        _NewControl2
        pla
        pla
        rtl
        

doRect
* data1 is a pointer to the grafport.
        rtl
        
    
doHit
* data1 is a handle to the control which was hit
* data2 is the controlID of the control which was hit
        rtl
        
        
doRun
* data1 is a pointer to the grafport.
        rtl
        

doEdit
* The lower 16 bits of data1 is the edit action
* data2 is a pointer to the grafport.

        lda data1
        cmp #undoAction
        bne notUndo
* Handle undo here
        bra doneEdit
        
notUndo
        cmp #cutAction
        bne notCut
* Handle cut here
        bra doneEdit
        
notCut
        cmp #copyAction
        bne notCopy
* Handle copy here
        bra doneEdit
        
notCopy
        cmp #pasteAction
        bne notPaste
* Handle paste here
        bra doneEdit
        
notPaste
        cmp #clearAction
        bne notClear
* Handle clear here
        bra doneEdit
        
notClear

doneEdit
        rtl

]XCODEEND       ; Keep this at the end and put your code above this
