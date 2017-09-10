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
        phk
        plb
        jsl SystemEnvironmentInit
        jsl SysIOStartup
        puts #'Hello, world!',cr=t
        jsl SysIOShutdown
        lda #0
        rtl
        end

