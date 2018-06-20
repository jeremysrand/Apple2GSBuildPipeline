#
#  head.mk
#

ORCA_HOME := $(HOME)/orca

ORCA_BINDIR = /usr/local/bin

export ORCA=$(ORCA_BINDIR)/orca

TARGETTYPE=shell

SRCDIRS=.

COMPILE=make/orca-cc
CFLAGS= -P -I
ROOTCFILE=main.c
DEFINES=
INCLUDE_PATHS=

REZ=make/orca-rez
REZFLAGS=

MACGEN=make/orca-macgen
MACGENFLAGS=-P
MACGENMACROS=13/ORCAInclude/m=

ASSEMBLE=make/orca-asm
ASMFLAGS=-P

LINK=$(ORCA) link
LDFLAGS=-P

CHTYP=$(ORCA) chtyp

RM=rm -f
CP=cp

GSPLUS=/Applications/GSplus.app/Contents/MacOS/gsplus
GSPORT=/Applications/GSport/GSport.app/Contents/MacOS/GSport

export GSPLUS
export GSPORT

XCODE_PATH=/Applications/Xcode.app
XCODE_INFO=$(XCODE_PATH)/Contents/Info.plist

ORCAM_PLUGIN_PATH=$(HOME)/Library/Developer/Xcode/Plug-ins/OrcaM.ideplugin
ORCAM_PLUGIN_INFO=$(ORCAM_PLUGIN_PATH)/Contents/Info.plist

XCODE_PLUGIN_COMPATIBILITY=DVTPlugInCompatibilityUUID


.PHONY: all gen genclean xcodefix

all:
	@make xcodefix
	@make gen
	@make build

xcodefix:
	defaults write "$(ORCAM_PLUGIN_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)s -array `defaults read "$(XCODE_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)`
