/*
 * ___FILENAME___
 * ___PACKAGENAME___
 *
 * Created by ___FULLUSERNAME___ on ___DATE___.
 * Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 *
 */



#pragma cda "___PACKAGENAME___" start shutdown


#include <stdio.h>


char str[256];

void start(void)
{
    printf("Hello, world!\n");
    printf("\n\n   Press ENTER to quit...");
    
    fgets(str, sizeof(str), stdin);
}


void shutdown(void)
{
}

