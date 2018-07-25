/*
 * ___FILENAME___
 * ___PACKAGENAME___
 *
 * Created by ___FULLUSERNAME___ on ___DATE___.
 * Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 *
 */


#pragma cdev entry

#include <types.h>
#include <desk.h>
#include <control.h>
#include <quickdraw.h>

#include "main.h"


/* CDev Message Numbers
 *   (Why aren't these in an include file somewhere?)
 *   Check out FTN.C7.XXXX in the file type tech notes for
 *   more information about CDevs.
 */
#define machineCDev  1
#define bootCDev     2
#define reservedCDev 3
#define initCDev     4
#define closeCDev    5
#define eventsCDev   6
#define createCDev   7
#define aboutCDev    8
#define rectCDev     9
#define hitCDev     10
#define runCDev     11
#define editCDev    12



long doMachine(void)
{
    /* Return non-zero if you cannot be opened on this machine
     * (and maybe display an alert explaining why).
     */
    return 1;
}


void doBoot(int *flag)
{
    /* Set bit 0 to 1 in flag if you want to draw at X through
     * the icon at boot time to indicate that this CDev will not
     * load.
     */
    
#if 0
    /* Enable this line to set bit 0 to 1. */
    *flag |= 1;
#endif
}


void doInit(GrafPortPtr windowPtr)
{
}


void doClose(GrafPortPtr windowPtr)
{
}


void doEvents(GrafPortPtr windowPtr, EventRecord *eventPtr)
{
}


void doAbout(GrafPortPtr windowPtr)
{
    NewControl2(windowPtr, resourceToResource, HELP_RESOURCE);
}


void doCreate(GrafPortPtr windowPtr)
{
    NewControl2(windowPtr, resourceToResource, MAIN_RESOURCE);
}


void doRect(Rect *rectPtr)
{
}


void doHit(Handle controlHandle, long controlID)
{
}


void doRun(GrafPortPtr windowPtr)
{
}


void doEdit(GrafPortPtr windowPtr, int action)
{
    switch (action) {
        case undoAction:
            break;
            
        case cutAction:
            break;
            
        case copyAction:
            break;
            
        case pasteAction:
            break;
            
        case clearAction:
            break;
    }
}


long entry(long data2, long data1, int message)

{
    GrafPortPtr windowPtr = (void *) data1;
    
    switch (message) {
        case machineCDev:
            return doMachine();
            
        case bootCDev:
            doBoot((int *)data1);
            break;
            
        case initCDev:
            doInit((GrafPortPtr)data1);
            break;
            
        case closeCDev:
            doClose((GrafPortPtr)data1);
            break;
            
        case eventsCDev:
            doEvents((GrafPortPtr)data2, (EventRecord *)data1);
            break;
            
        case createCDev:
            doCreate((GrafPortPtr)data1);
            break;
            
        case aboutCDev:
            doAbout((GrafPortPtr)data1);
            break;
            
        case rectCDev:
            doRect((Rect *)data1);
            break;
            
        case hitCDev:
            doHit((Handle)data1, data2);
            break;
            
        case runCDev:
            doRun((GrafPortPtr)data1);
            break;
            
        case editCDev:
            doEdit((GrafPortPtr)data2, (int)(data1 & 0xffff));
            break;
    }
    return 1;
}
