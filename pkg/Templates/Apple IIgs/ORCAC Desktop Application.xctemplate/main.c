/*
 * ___FILENAME___
 * ___PACKAGENAME___
 *
 * Created by ___FULLUSERNAME___ on ___DATE___.
 * Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___. All rights reserved.
 *
 */


#include <orca.h>
#include <Event.h>
#include <Menu.h>
#include <QuickDraw.h>
#include <Window.h>
#include <Desk.h>
#include <Resources.h>

#include "___FILEBASENAME___.h"


BOOLEAN done;
EventRecord myEvent;


void DoAbout(void)
{
    AlertWindow(awCString + awResource, NULL, aboutAlertString);
}


GrafPortPtr NewDocument(void)
{
    return(NewWindow2("\pMyWindow", 0, NULL, NULL, 0x02, windowRes, rWindParam1));
}


void CloseDocument(GrafPortPtr wPtr)
{
    if (wPtr != NULL) {
        CloseWindow(wPtr);
    }
}


void HandleMenu(void)
{
    int menuNum;
    int menuItemNum;
    
    menuNum = myEvent.wmTaskData >> 16;
    menuItemNum = myEvent.wmTaskData;
    
    switch (menuItemNum) {
        case appleAbout:
            DoAbout();
            break;
        case fileNew:
            NewDocument();
            break;
        case fileOpen:
            NewDocument();
            break;
        case fileClose:
            CloseDocument(FrontWindow());
            break;
        case fileQuit:
            done = TRUE;
            break;
        case editUndo:
            break;
        case editCut:
            break;
        case editCopy:
            break;
        case editPaste:
            break;
        case editClear:
            break;
    }
    HiliteMenu(FALSE, menuNum);
}


void InitMenus(void)
{
    int height;
    MenuBarRecHndl menuBarHand;
    
    menuBarHand = NewMenuBar2(refIsResource, menuBar, NULL);
    SetSysBar(menuBarHand);
    SetMenuBar(NULL);
    FixAppleMenu(appleMenu);
    height = FixMenuBar();
    DrawMenuBar();
}


int main(void)
{
    int event;
    
    startdesk(640);
    InitMenus();
    InitCursor();
    
    done = FALSE;
    myEvent.wmTaskMask = 0x001F7FFF;
    while (!done) {
        event = TaskMaster(everyEvent, &myEvent);
        switch (event) {
            case wInSpecial:
            case wInMenuBar:
                HandleMenu();
                break;
            case wInGoAway:
                CloseDocument((GrafPortPtr)myEvent.wmTaskData);
                break;
        }
    }
    enddesk();
}

