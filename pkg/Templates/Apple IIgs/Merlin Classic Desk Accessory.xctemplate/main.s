*
*  ___FILENAME___
*  ___PROJECTNAME___
*
*  Created by ___FULLUSERNAME___ on ___DATE___.
*  ___COPYRIGHT___
*

]XCODESTART     ; Keep this at the start and put your code after this

        mx %00

        use 4/Util.Macs
        use 4/Text.Macs
    
        str '___PROJECTNAME___'
        adrl startCda
        adrl shutdownCda

startCda
        phb
        phk
        plb
        
        pha
        pha
        pha
        _GetInputDevice
        
        pha
        pha
        _GetInGlobals
        
        pha
        pha
        pha
        _GetOutputDevice
        
        pha
        pha
        _GetOutGlobals
        
        PushLong #0
        PushWord #3
        _SetInputDevice
        
        PushWord #$7f
        PushWord #0
        _SetInGlobals
        
        PushLong #0
        PushWord #3
        _SetOutputDevice
        
        PushWord #$ff
        PushWord #$80
        _SetOutGlobals
        
        PushWord #0
        _InitTextDev
        
        PushWord #1
        _InitTextDev

        PushWord #$0c
        _WriteChar
        
        PushLong #message
        _WriteCString
        
        pha
        PushWord #0
        _ReadChar
        pla
        
        _SetOutGlobals
        _SetOutputDevice
        _SetInGlobals
        _SetInputDevice
        ~InitTextDev #0
        ~InitTextDev #1

        plb
        rtl

shutdownCda
        rtl

    
message
        asc 'Hello, world!',0d,0d,'   Press ENTER to quit...',00

]XCODEEND       ; Keep this at the end and put your code above this
