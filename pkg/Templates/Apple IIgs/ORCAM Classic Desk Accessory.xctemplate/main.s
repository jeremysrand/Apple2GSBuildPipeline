;
;  ___FILENAME___
;  ___PROJECTNAME___
;
;  Created by ___FULLUSERNAME___ on ___DATE___.
;___COPYRIGHT___
;

        mcopy main.macros
        keep main

Main    start

        dw '___PROJECTNAME___'
        dc i4'startCda'
        dc i4'shutdownCda'
        end

startCda start
    
        using CDAData
    
        phb
        phk
        plb

        pha                     ; Save the old text tool state to the stack
        pha
        pha
        ~GetInputDevice
        
        pha
        pha
        ~GetInGlobals
        
        pha
        pha
        pha
        ~GetOutputDevice
        
        pha
        pha
        ~GetOutGlobals
        
        ~SetInputDevice #0,#3       ; Setup input and output device to the console
        ~SetInGlobals #$7f,#$00
        ~SetOutputDevice #0,#3
        ~SetOutGlobals #$ff,#$80
        ~InitTextDev #0
        ~InitTextDev #1
        
        ~WriteChar #$0c
        
        ~WriteCString #message
        
        pha
        ~ReadChar #0
        pla
        
        ~SetOutGlobals *,*         ; Restore the old text tool state from the stack
        ~SetOutputDevice *,*
        ~SetInGlobals *,*
        ~SetInputDevice *,*
        ~InitTextDev #0
        ~InitTextDev #1

        plb
        rtl

shutdownCda entry
        rtl

        end


CDAData data
    
message dc c'Hello, world!'
        dc i1'$0d'
        dc i1'$0d'
        dc c'   Press ENTER to quit...'
        dc i1'$00'
    
        end

