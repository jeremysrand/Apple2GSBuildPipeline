;
;  ___FILENAME___
;  ___PROJECTNAME___
;
;  Created by ___FULLUSERNAME___ on ___DATE___.
;___COPYRIGHT___
;

	mcopy main.macros
	keep main

dummy	private
	jmp InitStart
	end

InitStart private
	using InitData

	tay
	tsc
	clc
	adc	#4
	sta	>unloadFlagPtr
	lda	#0
	sta	>unloadFlagPtr+2
	tya
	end

Main start
	using InitData
	
	ldx #0
	short m
l1 anop
	lda >pgm,x
	beq donel1
	sta >message,x
	inx
	bra l1
donel1 anop
    long m
	
	~ShowBootInfo #message,#icon
	
	rtl
	
	end


InitData data

unloadFlagPtr dc i4'0'

icon	dc i2'$8000'
		dc i2'280'
		dc i2'20'
		dc i2'28'
		dc i1'$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$ff'
		dc i1'$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff'
		dc i1'$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00'
		dc i1'$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00'

pgm     dc c'___PROJECTNAME___'
		dc i1'0'

message	dc c'                      v1.0b1'
        dc i1'0'
		
        end

