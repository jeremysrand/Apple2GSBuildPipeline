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
#include <Control.h>
#include <TextEdit.h>
#include <Desk.h>
#include <Resources.h>
#include <MiscTool.h>
#include <STDFile.h>
#include <GSOS.h>
#include <Print.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "___FILEBASENAME___.h"


/* Defines and macros */

#define TOOLFAIL(string) \
    if (toolerror()) SysFailMgr(toolerror(), "\p" string "\n\r    Error Code -> $");

#define MAX_DOCUMENT_NAME 80

#define PRINT_RECORD_SIZE 140


/* Types */

typedef struct tDocument
{
    struct tDocument * nextDocument;
    struct tDocument * prevDocument;
    GrafPortPtr wPtr;
    char documentName[MAX_DOCUMENT_NAME + 1];
    BOOLEAN isOnDisk;
    ResultBuf255Hndl fileName;
    ResultBuf255Hndl pathName;
    PrRecHndl printRecordHandle;
} tDocument;


/* Globals */

BOOLEAN shouldQuit;
EventRecord myEvent;
unsigned int userid;
tDocument * documentList;


/* Forward declarations */

void doFileSave(void);


/* Implementation */

const char * resourceString(int resourceId, const char * defaultValue)
{
    Handle handle;
    const char *result = defaultValue;
    
    handle = LoadResource(rCString, resourceId);
    if (toolerror() == 0) {
        HLock(handle);
        result = (const char *) (*handle);
    }
    return(result);
}


void freeResourceString(int resourceId)
{
    ReleaseResource(-3, rCString, resourceId);
}


void showErrorAlert(int resourceId, int toolErrorCode)
{
    char buffer[40] = "";
    const char *substArray[2];
    const char *toolErrorFormat;
    
    if (toolErrorCode != 0) {
        toolErrorFormat = resourceString(TOOL_ERROR_STRING, "\n\nTool error code = $%04x");
        sprintf(buffer, toolErrorFormat, toolErrorCode);
        freeResourceString(TOOL_ERROR_STRING);
    }
    
    substArray[0] = resourceString(resourceId, "Unknown error has occurred");
    substArray[1] = buffer;
    
    AlertWindow(awCString + awResource, (Pointer) substArray,  ERROR_ALERT_STRING);
    freeResourceString(resourceId);
}


tDocument * findDocumentFromWindow(GrafPortPtr wPtr)
{
    tDocument * result = documentList;
    
    while (result != NULL) {
        if (result->wPtr == wPtr)
            break;
        
        result = result->nextDocument;
    }
    
    return result;
}


#pragma databank 1
void drawContents(void)
{
    DrawControls(GetPort());
}
#pragma databank 0


const char * getUntitledName(void)
{
    static int untitledNum = 1;
    static char buffer[MAX_DOCUMENT_NAME];
    const char *untitledFormat = resourceString(UNTITLED_STRING, "  Untitled %d  ");
    
    sprintf(buffer, untitledFormat, untitledNum);
    freeResourceString(UNTITLED_STRING);
    untitledNum++;
    
    return(buffer);
}


tDocument * newDocument(const char * windowName)
{
    tDocument * documentPtr;
    int titleLength;
    
    documentPtr = malloc(sizeof(tDocument));
    if (documentPtr == NULL) {
        showErrorAlert(MALLOC_ERROR_STRING, 0);
        return(NULL);
    }
    documentPtr->printRecordHandle = (PrRecHndl) NewHandle(PRINT_RECORD_SIZE, userid, 0, NULL);
    if (toolerror() != 0) {
        showErrorAlert(MALLOC_ERROR_STRING, toolerror());
        free(documentPtr);
        return(NULL);
    }
    PrDefault(documentPtr->printRecordHandle);
    
    documentPtr->isOnDisk = FALSE;
    documentPtr->fileName = NULL;
    documentPtr->pathName = NULL;
    
    titleLength = strlen(windowName);
    if (titleLength > MAX_DOCUMENT_NAME) {
        titleLength = MAX_DOCUMENT_NAME;
    }
    documentPtr->documentName[0] = titleLength;
    strncpy(&(documentPtr->documentName[1]), windowName, titleLength);
    
    documentPtr->wPtr = NewWindow2(documentPtr->documentName, 0, drawContents, NULL, refIsResource,
                            WINDOW_RESID, rWindParam1);
    if (documentPtr->wPtr == NULL) {
        showErrorAlert(NEW_WINDOW_ERROR_STRING, toolerror());
        DisposeHandle((Handle)documentPtr->printRecordHandle);
        free(documentPtr);
        return(NULL);
    }
    
    documentPtr->nextDocument = documentList;
    documentPtr->prevDocument = NULL;
    if (documentList != NULL)
        documentList->prevDocument = documentPtr;
    
    documentList = documentPtr;
    
    return(documentPtr);
}


BOOLEAN isDocumentDirty(tDocument * documentPtr)
{
    BOOLEAN isDirty = FALSE;
    CtlRecHndl controlHdl;
    CtlRec * controlPtr;
    
    controlHdl = GetCtlHandleFromID(documentPtr->wPtr, CONTROL_TEXT_EDIT);
    if (toolerror() == 0) {
        HLock((Handle) controlHdl);
        controlPtr = *controlHdl;
        isDirty = ((controlPtr->ctlFlag & fRecordDirty) != 0);
        HUnlock((Handle) controlHdl);
    }
    return isDirty;
}


void clearDocumentDirty(tDocument * documentPtr)
{
    CtlRecHndl controlHdl;
    CtlRec * controlPtr;
    
    controlHdl = GetCtlHandleFromID(documentPtr->wPtr, CONTROL_TEXT_EDIT);
    if (toolerror() == 0) {
        HLock((Handle) controlHdl);
        controlPtr = *controlHdl;
        controlPtr->ctlFlag &= (~fRecordDirty);
        HUnlock((Handle) controlHdl);
    }
}


void saveDocument(tDocument * documentPtr)
{
    RefNumRecGS closeRecord;
    CreateRecGS createRecord;
    NameRecGS destroyRecord;
    OpenRecGS openRecord;
    IORecGS writeRecord;
    
    GrafPortPtr tmpPort;
    LongWord dataLength;
    Handle dataHandle;
    
    tmpPort = GetPort();
    SetPort(documentPtr->wPtr);
    dataLength = TEGetText(teTextIsNewHandle | teDataIsCString, (Ref) &dataHandle, 0,
                           0, (Ref) NULL, NULL);
    if (toolerror() != 0) {
        showErrorAlert(SAVE_FILE_ERROR_STRING, toolerror());
        SetPort(tmpPort);
        return;
    }
    
    HLock((Handle) documentPtr->pathName);
    
    destroyRecord.pCount = 1;
    destroyRecord.pathname = &((*(documentPtr->pathName))->bufString);
    DestroyGS(&destroyRecord);
    
    createRecord.pCount = 5;
    createRecord.pathname = &((*(documentPtr->pathName))->bufString);
    createRecord.access = destroyEnable | renameEnable | readWriteEnable;
    createRecord.fileType = 0x04;
    createRecord.auxType = 0x0000;
    createRecord.storageType = 1;
    CreateGS(&createRecord);
    
    if (toolerror() != 0) {
        showErrorAlert(SAVE_FILE_ERROR_STRING, toolerror());
    } else {
        openRecord.pCount = 3;
        openRecord.pathname = &((*(documentPtr->pathName))->bufString);
        openRecord.requestAccess = writeEnable;
        OpenGS(&openRecord);
        
        if (toolerror() != 0) {
            showErrorAlert(SAVE_FILE_ERROR_STRING, toolerror());
        } else {
            HLock(dataHandle);
            
            writeRecord.pCount = 4;
            writeRecord.refNum = openRecord.refNum;
            writeRecord.dataBuffer = *dataHandle;
            writeRecord.requestCount = dataLength;
            WriteGS(&writeRecord);
            
            if (toolerror() != 0) {
                showErrorAlert(SAVE_FILE_ERROR_STRING, toolerror());
            } else {
                documentPtr->isOnDisk = TRUE;
                clearDocumentDirty(documentPtr);
            }
            
            HUnlock(dataHandle);
            
            closeRecord.pCount = 1;                 /* close the file */
            closeRecord.refNum = openRecord.refNum;
            CloseGS(&closeRecord);
        }
    }
    
    DisposeHandle(dataHandle);
    HUnlock((Handle) documentPtr->pathName);
    SetPort(tmpPort);
}


BOOLEAN loadDocument(tDocument * documentPtr)
{
    BOOLEAN result = TRUE;
    
    RefNumRecGS closeRecord;
    OpenRecGS openRecord;
    IORecGS readRecord;
    GrafPortPtr tmpPort;
    Handle dataHandle;
    
    openRecord.pCount = 12;
    HLock((Handle) documentPtr->pathName);
    openRecord.pathname = &((*(documentPtr->pathName))->bufString);
    openRecord.requestAccess = readEnable;
    openRecord.resourceNumber = 0;
    openRecord.optionList = NULL;
    OpenGS(&openRecord);
    
    if (toolerror() != 0) {
        showErrorAlert(OPEN_FILE_ERROR_STRING, toolerror());
        result = FALSE;
    } else {
        dataHandle = NewHandle(openRecord.eof, userid, attrLocked, NULL);
        
        if (toolerror() != 0) {
            showErrorAlert(MALLOC_ERROR_STRING, toolerror());
            result = FALSE;
        } else {
            readRecord.pCount = 4;
            readRecord.refNum = openRecord.refNum;
            readRecord.dataBuffer = *dataHandle;
            readRecord.requestCount = openRecord.eof;
            ReadGS(&readRecord);
            
            if (toolerror() != 0) {
                showErrorAlert(OPEN_FILE_ERROR_STRING, toolerror());
                result = FALSE;
            } else {
                tmpPort = GetPort();
                SetPort(documentPtr->wPtr);
                TESetText(teTextIsPtr | teDataIsTextBlock, (Ref)*dataHandle, openRecord.eof,
                          teCtlStyleIsPtr, NULL, NULL);
                SetPort(tmpPort);
            }
            DisposeHandle(dataHandle);
        }
        
        closeRecord.pCount = 1;
        closeRecord.refNum = openRecord.refNum;
        CloseGS(&closeRecord);
    }
    
    HUnlock((Handle) documentPtr->pathName);
    clearDocumentDirty(documentPtr);
    
    return result;
}


void closeDocument(GrafPortPtr wPtr)
{
    tDocument * documentPtr;
    char documentName[MAX_DOCUMENT_NAME];
    char * alertStrings[] = { documentName };
    int documentNameLen;
    char * tmpPtr;
    int buttonClicked;
    
    if (wPtr == NULL)
        return;
    
    documentPtr = findDocumentFromWindow(wPtr);
    if (documentPtr != NULL) {
        while (isDocumentDirty(documentPtr)) {
            /* The documentName in the documentPtr is actually a PString so the
               first byte is the length of the string. */
            tmpPtr = documentPtr->documentName;
            documentNameLen = *tmpPtr;
            tmpPtr++;
            
            /* The documentName has spaces before and after the real name to format
               the string for the window title bar.  Strip those spaces out and store
               the name into the documentName local array. */
            while ((documentNameLen > 0) &&
                   (tmpPtr[documentNameLen - 1] == ' ')) {
                documentNameLen--;
            }
            while (*tmpPtr == ' ') {
                tmpPtr++;
                documentNameLen--;
            }
            strncpy(documentName, tmpPtr, documentNameLen);
            documentName[documentNameLen] = '\0';
            
            buttonClicked = AlertWindow(awCString+awResource, (Pointer) alertStrings, SAVE_BEFORE_CLOSING);
            switch (buttonClicked) {
                case 0:
                    doFileSave();
                    break;
                    
                case 1:
                    clearDocumentDirty(documentPtr);
                    break;
                    
                case 2:
                    return;
            }
        }
    }
    
    CloseWindow(wPtr);
    
    if (documentPtr == NULL)
        return;

    if (documentPtr->fileName != NULL) {
        DisposeHandle((Handle) documentPtr->fileName);
        documentPtr->fileName = NULL;
    }
    if (documentPtr->pathName != NULL) {
        DisposeHandle((Handle) documentPtr->pathName);
        documentPtr->pathName = NULL;
    }
    if (documentPtr->printRecordHandle != NULL) {
        DisposeHandle((Handle)documentPtr->printRecordHandle);
        documentPtr->printRecordHandle = NULL;
    }
    if (documentList == documentPtr) {
        documentList = documentPtr->nextDocument;
    } else if (documentPtr->prevDocument != NULL) {
        documentPtr->prevDocument->nextDocument = documentPtr->nextDocument;
    }
    
    if (documentPtr->nextDocument != NULL)
        documentPtr->nextDocument->prevDocument = documentPtr->prevDocument;

    free(documentPtr);
}


void printDocument(tDocument * documentPtr)
{
    GrafPortPtr printerPort;
    LongWord lineNumber;
    PrStatusRec printerStatus;
    Rect pageRect;
    
    printerPort = PrOpenDoc(documentPtr->printRecordHandle, NULL);
    if (toolerror() != 0) {
        showErrorAlert(PRINT_ERROR_STRING, toolerror());
        return;
    }
    
    HLock((Handle) documentPtr->printRecordHandle);
    pageRect = (*(documentPtr->printRecordHandle))->prInfo.rPage;
    HUnlock((Handle) documentPtr->printRecordHandle);
    
    if (toolerror() != 0) {
        showErrorAlert(PRINT_ERROR_STRING, toolerror());
    } else {
        lineNumber = 0;
        while (lineNumber != -1) {
            PrOpenPage(printerPort, NULL);
            if (toolerror() != 0) {
                showErrorAlert(PRINT_ERROR_STRING, toolerror());
                break;
            }
            else {
                lineNumber = TEPaintText(printerPort, lineNumber, &pageRect, 0,
                                   (Handle) GetCtlHandleFromID(documentPtr->wPtr, CONTROL_TEXT_EDIT));
                PrClosePage(printerPort);
            }
        }
    }
    PrCloseDoc(printerPort);
    
    if (PrError() == 0)
        PrPicFile(documentPtr->printRecordHandle, NULL, &printerStatus);
}


void doAppleAbout(void)
{
    AlertWindow(awCString + awResource, NULL, ABOUT_ALERT_STRING);
}


void doFileNew(void)
{
    newDocument(getUntitledName());
}


void doFileOpen(void)
{
    tDocument * documentPtr;
    SFTypeList2 fileTypes;
    Handle nameHandle;
    ResultBuf255Ptr namePtr;
    int nameLen;
    char documentName[MAX_DOCUMENT_NAME];
    SFReplyRec2 reply;
    
    /* By default, we want to open text files only which is what
       the following fileTypes request.  Customize as necessary. */
    fileTypes.numEntries = 1;
    fileTypes.fileTypeEntries[0].flags = 0x0000;
    fileTypes.fileTypeEntries[0].fileType = 0x04;
    fileTypes.fileTypeEntries[0].auxType = 0x0000;
    
    reply.nameRefDesc = refIsNewHandle;
    reply.pathRefDesc = refIsNewHandle;
    SFGetFile2(30, 30, refIsResource, OPEN_FILE_STRING, NULL, &fileTypes, &reply);
    if (toolerror() != 0) {
        showErrorAlert(OPEN_FILE_ERROR_STRING, toolerror());
        return;
    }
    
    if (reply.good) {
        nameHandle = (Handle) reply.nameRef;
        HLock(nameHandle);
        namePtr = (ResultBuf255Ptr) (*nameHandle);
        strcpy(documentName, "  ");
        nameLen = namePtr->bufString.length;
        if (nameLen > MAX_DOCUMENT_NAME - 5)
            nameLen = MAX_DOCUMENT_NAME - 5;
        strncat(documentName, namePtr->bufString.text, nameLen);
        strcat(documentName, "  ");
        HUnlock(nameHandle);
        documentPtr = newDocument(documentName);
        if (documentPtr == NULL) {
            DisposeHandle((Handle) reply.nameRef);
            DisposeHandle((Handle) reply.pathRef);
        } else {
            documentPtr->fileName = (ResultBuf255Hndl) reply.nameRef;
            documentPtr->pathName = (ResultBuf255Hndl) reply.pathRef;
            documentPtr->isOnDisk = loadDocument(documentPtr);
            
            if (!documentPtr->isOnDisk)
                closeDocument(documentPtr->wPtr);
        }
    }
}


void doFileSaveAs(void)
{
    Handle nameHandle;
    ResultBuf255Ptr namePtr;
    int nameLen;
    SFReplyRec2 reply;
    tDocument * documentPtr = findDocumentFromWindow(FrontWindow());
    
    if (documentPtr == NULL)
        return;
    
    reply.nameRefDesc = refIsNewHandle;
    reply.pathRefDesc = refIsNewHandle;
    
    if (documentPtr->fileName == NULL)
        SFPutFile2(30, 30, refIsResource, SAVE_FILE_STRING, refIsPointer,
                   (Ref) &(documentPtr->fileName), &reply);
    else
        SFPutFile2(30, 30, refIsResource, SAVE_FILE_STRING, refIsPointer,
                   (Ref) &((*(documentPtr->pathName))->bufString), &reply);
    
    if (toolerror() != 0) {
        showErrorAlert(SAVE_FILE_ERROR_STRING, toolerror());
        return;
    }
    
    if (reply.good) {
        nameHandle = (Handle) reply.nameRef;
        HLock(nameHandle);
        namePtr = (ResultBuf255Ptr) (*nameHandle);
        strcpy(documentPtr->documentName, "   ");
        nameLen = namePtr->bufString.length;
        if (nameLen > MAX_DOCUMENT_NAME - 6)
            nameLen = MAX_DOCUMENT_NAME - 6;
        strncat(documentPtr->documentName, namePtr->bufString.text, nameLen);
        strcat(documentPtr->documentName, "  ");
        documentPtr->documentName[0] = strlen(documentPtr->documentName) - 1;
        HUnlock(nameHandle);
        SetWTitle(documentPtr->documentName, documentPtr->wPtr);
        
        documentPtr->fileName = (ResultBuf255Hndl) reply.nameRef;
        documentPtr->pathName = (ResultBuf255Hndl) reply.pathRef;
        documentPtr->isOnDisk = TRUE;
        saveDocument(documentPtr);
    }
}


void doFileSave(void)
{
    tDocument * documentPtr = findDocumentFromWindow(FrontWindow());
    
    if (documentPtr == NULL)
        return;
    
    if (documentPtr->isOnDisk)
        saveDocument(documentPtr);
    else
        doFileSaveAs();
}


void doFileClose(void)
{
    closeDocument(FrontWindow());
}


void doFilePageSetup(void)
{
    tDocument * documentPtr = findDocumentFromWindow(FrontWindow());
    
    if (documentPtr == NULL)
        return;
    
    PrStlDialog(documentPtr->printRecordHandle);
}


void doFilePrint(void)
{
    tDocument * documentPtr = findDocumentFromWindow(FrontWindow());
    
    if (documentPtr == NULL)
        return;
    
    if (PrJobDialog(documentPtr->printRecordHandle))
        printDocument(documentPtr);
}


void doFileQuit(void)
{
    shouldQuit = TRUE;
}


void doEditUndo(void)
{
    /* Nothing extra to do here.  The text edit control handles this for us. */
}


void doEditCut(void)
{
    /* Nothing extra to do here.  The text edit control handles this for us. */
}


void doEditCopy(void)
{
    /* Nothing extra to do here.  The text edit control handles this for us. */
}


void doEditPaste(void)
{
    /* Nothing extra to do here.  The text edit control handles this for us. */
}


void doEditClear(void)
{
    /* Nothing extra to do here.  The text edit control handles this for us. */
}


void handleMenu(void)
{
    int menuNum;
    int menuItemNum;
    
    menuNum = myEvent.wmTaskData >> 16;
    menuItemNum = myEvent.wmTaskData;
    
    switch (menuItemNum) {
        case APPLE_ABOUT:
            doAppleAbout();
            break;
            
        case FILE_NEW:
            doFileNew();
            break;
            
        case FILE_OPEN:
            doFileOpen();
            break;
        
        case FILE_SAVE:
            doFileSave();
            break;
        
        case FILE_SAVE_AS:
            doFileSaveAs();
            break;
            
        case FILE_CLOSE:
            doFileClose();
            break;
        
        case FILE_PAGE_SETUP:
            doFilePageSetup();
            break;
        
        case FILE_PRINT:
            doFilePrint();
            break;
            
        case FILE_QUIT:
            doFileQuit();
            break;
            
        case EDIT_UNDO:
            doEditUndo();
            break;
            
        case EDIT_CUT:
            doEditCut();
            break;
            
        case EDIT_COPY:
            doEditCopy();
            break;
            
        case EDIT_PASTE:
            doEditPaste();
            break;
            
        case EDIT_CLEAR:
            doEditClear();
            break;
    }
    HiliteMenu(FALSE, menuNum);
}


void dimMenus(void)
{
    static BOOLEAN windowWasOpen = TRUE;
    static BOOLEAN applicationWindowWasInFront = TRUE;
    BOOLEAN windowIsOpen;
    BOOLEAN applicationWindowIsInFront;
    
    GrafPortPtr wPtr = FrontWindow();
    windowIsOpen = (wPtr != NULL);
    applicationWindowIsInFront = (findDocumentFromWindow(wPtr) != NULL);
    
    if ((windowIsOpen == windowWasOpen) &&
        (applicationWindowIsInFront == applicationWindowWasInFront)) {
        return;
    }
    
    windowWasOpen = windowIsOpen;
    applicationWindowWasInFront = applicationWindowIsInFront;
    
    if (windowIsOpen) {
        EnableMItem(FILE_CLOSE);
        SetMenuFlag(enableMenu, EDIT_MENU);
    } else {
        DisableMItem(FILE_CLOSE);
        SetMenuFlag(disableMenu, EDIT_MENU);
    }
    
    if (applicationWindowIsInFront) {
        EnableMItem(FILE_SAVE);
        EnableMItem(FILE_SAVE_AS);
        EnableMItem(FILE_PAGE_SETUP);
        EnableMItem(FILE_PRINT);
    } else {
        DisableMItem(FILE_SAVE);
        DisableMItem(FILE_SAVE_AS);
        DisableMItem(FILE_PAGE_SETUP);
        DisableMItem(FILE_PRINT);
    }
    
    DrawMenuBar();
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


void initGlobals(void)
{
    documentList = NULL;
    shouldQuit = FALSE;
    myEvent.wmTaskMask = 0x001F7FFF;
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
    
    initGlobals();
    initMenus();
    InitCursor();
    
    while (!shouldQuit) {
        dimMenus();
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
