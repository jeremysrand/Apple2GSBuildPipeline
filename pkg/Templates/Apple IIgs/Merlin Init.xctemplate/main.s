*
*  ___FILENAME___
*  ___PROJECTNAME___
*
*  Created by ___FULLUSERNAME___ on ___DATE___.
*  ___COPYRIGHT___
*

]XCODEEND       ; Keep this at the end and put your code above this
*
*  main.s
*  merlinpif
*
*  Created by Jeremy Rand on 2026-02-15.
*  
*

]XCODESTART     ; Keep this at the start and put your code after this

        mx %00
		
        use 4/Util.Macs
        use 4/Misc.Macs

startInit
		
        tay
        tsc
        clc
        adc	#4
        sta	>unloadFlagPtr
        lda	#0
        sta	>unloadFlagPtr+2
        tya

        ldx #0
        sep #$20
l1      lda >pgm,x
        beq donel1
        sta >message,x
        inx
        bra l1
donel1	rep #$20

        PushLong #message
        PushLong #icon
        _ShowBootInfo
		 
        rtl

icon	dw $8000
        dw 280
        dw 20
        dw 28
        db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff
        db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00
        db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
        
unloadFlagPtr
        adrl 0

pgm
        asc '___PROJECTNAME___',00
message
        asc '                      v1.0b1',00

]XCODEEND       ; Keep this at the end and put your code above this
