/*
 * ___FILENAME___
 * ___PACKAGENAME___
 *
 * Created by ___FULLUSERNAME___ on ___DATE___.
 * Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 *
 */


#pragma nda NDAOpen NDAClose NDAAction NDAInit -1 0x03FF "  ___PACKAGENAME___\\H**"


#include <orca.h>
#include <GSOS.h>
#include <QuickDraw.h>
#include <Window.h>
#include <Desk.h>
#include <Event.h>
#include <Resources.h>
#include <MiscTool.h>
#include <Memory.h>
#include <Loader.h>

#include "___FILEBASENAME___.h"


static BOOLEAN ndaActive;
static GrafPortPtr winPtr;
static unsigned int userId;
static unsigned int resourceId;
static Str255 gStrBuf;


void NDAClose(void)
{
    if (ndaActive) {
        CloseWindow(winPtr);
        winPtr = NULL;
        ndaActive = FALSE;
    }
    
    CloseResourceFile(resourceId);
    ResourceShutDown();
}


void NDAInit(int code)
{
    /* When code is 1, this is tool startup, otherwise tool
     * shutdown.
     */
    
    if (code) {
        ndaActive = FALSE;
        userId = MMStartUp();
    } else {
        if (ndaActive)
            NDAClose();
    }
}


#pragma databank 1
void DrawContents(void)
{
    PenNormal();
    MoveTo(7,10);
    DrawCString("Hello, world!");
}
#pragma databank 0


GrafPortPtr NDAOpen(void)
{
    Pointer pathToSelf;
    unsigned int oldResourceApp;
    LevelRecGS levelDCB;
    unsigned int oldLevel;
    SysPrefsRecGS prefsDCB;
    unsigned int oldPrefs;
    
    if (ndaActive)
        return NULL;
    
    oldResourceApp = GetCurResourceApp();
    ResourceStartUp(userId);
    
    pathToSelf = LGetPathname2(userId, 1);
    
    levelDCB.pCount = 2;
    GetLevelGS(&levelDCB);
    oldLevel = levelDCB.level;
    levelDCB.level = 0;
    SetLevelGS(&levelDCB);
    
    prefsDCB.pCount = 1;
    GetSysPrefsGS(&prefsDCB);
    oldPrefs = prefsDCB.preferences;
    prefsDCB.preferences = (prefsDCB.preferences & 0x1fff) | 0x8000;
    SetSysPrefsGS(&prefsDCB);
    
    resourceId = OpenResourceFile(readEnable, NULL, pathToSelf);
    
    winPtr = NewWindow2("\p ___PACKAGENAME___ ", 0, DrawContents, NULL, 0x02, windowRes, rWindParam1);
    
    SetSysWindow(winPtr);
    ShowWindow(winPtr);
    SelectWindow(winPtr);
    
    ndaActive = TRUE;
    
    prefsDCB.preferences = oldPrefs;
    SetSysPrefsGS(&prefsDCB);
    
    levelDCB.level = oldLevel;
    SetLevelGS(&levelDCB);
    
    SetCurResourceApp(oldResourceApp);
    
    return winPtr;
}


void HandleRun(void)
{
}


void HandleControl(EventRecord *event)
{
}


void HandleKey(EventRecord *event)
{
}


void HandleCursor(void)
{
}


void HandleMenu(int menuItem)
{
}


BOOLEAN NDAAction(EventRecord *sysEvent, int code)
{
    static EventRecord localEvent;
    unsigned int eventCode;
    BOOLEAN result = FALSE;
    
    switch (code) {
        case runAction:
            HandleRun();
            break;
            
        case eventAction:
            BlockMove((Pointer)sysEvent, (Pointer)&localEvent, 16);
            localEvent.wmTaskMask = 0x001FFFFF;
            eventCode = TaskMasterDA(0, &localEvent);
            switch(eventCode) {
                case updateEvt:
                    BeginUpdate(winPtr);
                    DrawContents();
                    EndUpdate(winPtr);
                    break;
                    
                case wInControl:
                    HandleControl(&localEvent);
                    break;
                    
                case keyDownEvt:
                case autoKeyEvt:
                    HandleKey(&localEvent);
                    break;
            }
            break;
            
        case cursorAction:
            HandleCursor();
            break;
            
        case cutAction:
        case copyAction:
        case pasteAction:
        case clearAction:
            result = TRUE;
            HandleMenu(code);
            break;
    }
    
    return result;
}

