/*
 * ___FILENAME___
 * ___PACKAGENAME___
 *
 * Created by ___FULLUSERNAME___ on ___DATE___.
 * Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 *
 */


#include <Memory.h>
#include <Locator.h>
#include <Event.h>
#include <Menu.h>
#include <QuickDraw.h>
#include <Window.h>
#include <Desk.h>
#include <Resources.h>
#include <MiscTool.h>

#include "___FILEBASENAME___.h"


// Defines and macros

#define TOOLFAIL(string) \
    if (toolerror()) SysFailMgr(toolerror(), "\p" string "\n\r    Error Code -> $");


// Globals

BOOLEAN done;
EventRecord myEvent;
unsigned int userid;


// Implementation

void doAbout(void)
{
    AlertWindow(awCString + awResource, NULL, ABOUT_ALERT_STRING);
}


GrafPortPtr newDocument(void)
{
    return(NewWindow2("\p MyWindow ", 0, NULL, NULL, 0x02, WINDOW_RESID, rWindParam1));
}


void closeDocument(GrafPortPtr wPtr)
{
    if (wPtr != NULL) {
        CloseWindow(wPtr);
    }
}


void handleMenu(void)
{
    int menuNum;
    int menuItemNum;
    
    menuNum = myEvent.wmTaskData >> 16;
    menuItemNum = myEvent.wmTaskData;
    
    switch (menuItemNum) {
        case APPLE_ABOUT:
            doAbout();
            break;
        case FILE_NEW:
            newDocument();
            break;
        case FILE_OPEN:
            newDocument();
            break;
        case FILE_CLOSE:
            closeDocument(FrontWindow());
            break;
        case FILE_QUIT:
            done = TRUE;
            break;
        case EDIT_UNDO:
            break;
        case EDIT_CUT:
            break;
        case EDIT_COPY:
            break;
        case EDIT_PASTE:
            break;
        case EDIT_CLEAR:
            break;
    }
    HiliteMenu(FALSE, menuNum);
}


void initMenus(void)
{
    int height;
    MenuBarRecHndl menuBarHand;
    
    menuBarHand = NewMenuBar2(refIsResource, MENU_BAR, NULL);
    TOOLFAIL("Unable to create menu bar");
    
    SetSysBar(menuBarHand);
    TOOLFAIL("Unable to set system menu bar");
    
    SetMenuBar(NULL);
    TOOLFAIL("Unable to set menu bar");
    
    FixAppleMenu(APPLE_MENU);
    TOOLFAIL("Unable to fix Apple menu");
    
    height = FixMenuBar();
    TOOLFAIL("Unable to fix menu bar");
    
    DrawMenuBar();
    TOOLFAIL("Unable to draw menu bar");
}


int main(void)
{
    int event;
    Ref toolStartupRef;
    
    userid = MMStartUp();
    TOOLFAIL("Unable to start memory manager");
    
    TLStartUp();
    TOOLFAIL("Unable to start tool locator");
    
    toolStartupRef = StartUpTools(userid, refIsResource, TOOL_STARTUP);
    TOOLFAIL("Unable to start tools");
    
    initMenus();
    InitCursor();
    
    done = FALSE;
    myEvent.wmTaskMask = 0x001F7FFF;
    while (!done) {
        event = TaskMaster(everyEvent, &myEvent);
        TOOLFAIL("Unable to handle next event");
        
        switch (event) {
            case wInSpecial:
            case wInMenuBar:
                handleMenu();
                break;
            case wInGoAway:
                closeDocument((GrafPortPtr)myEvent.wmTaskData);
                break;
        }
    }
    
    ShutDownTools(refIsHandle, toolStartupRef);
    TOOLFAIL("Unable to shutdown tools");
    
    TLShutDown();
    TOOLFAIL("Unable to shutdown tool locator");
    
    MMShutDown(userid);
    TOOLFAIL("Unable to shutdown memory manager");
}
