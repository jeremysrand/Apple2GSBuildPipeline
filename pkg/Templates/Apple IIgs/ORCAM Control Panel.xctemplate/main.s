;
;  ___FILENAME___
;  ___PACKAGENAME___
;
; Created by ___FULLUSERNAME___ on ___DATE___.
; Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
;

        mcopy main.macros
        keep main

; Resource numbers
cdevResource    gequ $1
mainResource    gequ $100
helpResource    gequ $101

; CDEV Message Numbers
machineCDev     gequ 1
bootCDev        gequ 2
reservedCDev    gequ 3
initCDev        gequ 4
closeCDev       gequ 5
eventsCDev      gequ 6
createCDev      gequ 7
aboutCDev       gequ 8
rectCDev        gequ 9
hitCDev         gequ 10
runCDev         gequ 11
editCDev        gequ 12

; Edit menu actions
undoAction      gequ 5
cutAction       gequ 6
copyAction      gequ 7
pasteAction     gequ 8
clearAction     gequ 9


main    start
        sub (2:message,4:data1,4:data2),0

        lda message
        cmp #machineCDev
        bne notMachine
; Return zero if you cannot be opened on this machine
; (and maybe display an alert explaining why).
        ret 2:#1
        
notMachine anop
        cmp #bootCDev
        bne notBoot
        jsl doBoot
        bra done

notBoot anop
        cmp #initCDev
        bne notInit
        jsl doInit
        bra done
        
notInit anop
        cmp #closeCDev
        bne notClose
        jsl doClose
        bra done
        
notClose anop
        cmp #eventsCDev
        bne notEvents
        jsl doEvents
        bra done
        
notEvents anop
        cmp #createCDev
        bne notCreate
        jsl doCreate
        bra done
        
notCreate anop
        cmp #aboutCDev
        bne notAbout
        jsl doAbout
        bra done
        
notAbout anop
        cmp #rectCDev
        bne notRect
        jsl doRect
        bra done
        
notRect anop
        cmp #hitCDev
        bne notHit
        jsl doHit
        bra done
        
notHit  anop
        cmp #runCDev
        bne notRun
        jsl doRun
        bra done
        
notRun  anop
        cmp #editCDev
        bne notEdit
        jsl doEdit
        bra done
        
notEdit anop

done    anop
        ret 2:#1
        
doBoot  entry
; data1 is a pointer to a flag.  Set bit 0 to 1 in this flag if you want to
; draw an X through the icon at boot time to indicate that this CDev will not
; load.
        rtl
        
        
doInit  entry
; data1 is a pointer to the grafport.
        rtl
        
    
doClose entry
; data1 is a pointer to the grafport.
        rtl
        
        
doEvents entry
; data1 is a pointer to the event record.
; data2 is a pointer to the grafport.
        rtl
        
    
doCreate entry
; data1 is a pointer to the grafport.
        pha
        pha
        ~NewControl2 data1,#9,#mainResource
        pla
        pla
        rtl
        
        
doAbout entry
; data1 is a pointer to the grafport.
        pha
        pha
        ~NewControl2 data1,#9,#helpResource
        pla
        pla
        rtl
        

doRect  entry
; data1 is a pointer to the grafport.
        rtl
        
    
doHit   entry
; data1 is a handle to the control which was hit
; data2 is the controlID of the control which was hit
        rtl
        
        
doRun   entry
; data1 is a pointer to the grafport.
        rtl
        

doEdit  entry
; The lower 16 bits of data1 is the edit action
; data2 is a pointer to the grafport.

        lda data1
        cmp #undoAction
        bne notUndo
; Handle undo here
        bra doneEdit
        
notUndo anop
        cmp #cutAction
        bne notCut
; Handle cut here
        bra doneEdit
        
notCut  anop
        cmp #copyAction
        bne notCopy
; Handle copy here
        bra doneEdit
        
notCopy anop
        cmp #pasteAction
        bne notPaste
; Handle paste here
        bra doneEdit
        
notPaste    anop
        cmp #clearAction
        bne notClear
; handle clear here
        bra doneEdit
        
notClear anop

doneEdit anop
        rtl
        

        end
