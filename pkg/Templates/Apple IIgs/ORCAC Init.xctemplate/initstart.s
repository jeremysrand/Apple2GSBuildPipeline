;
;  ___FILENAME___
;  ___PROJECTNAME___
;
;  Created by ___FULLUSERNAME___ on ___DATE___.
;___COPYRIGHT___
;

        case on
        mcopy initstart.macros
        keep initstart

dummy	private
	jmp	InitStart
	end

InitStart private
	tay
	tsc
	clc
	adc	#4
	sta	>unloadFlagPtr
	lda	#0
	sta	>unloadFlagPtr+2
	tya
	end
