#
#  head.mk
#

ORCA_HOME := $(HOME)/orca

ORCA_BINDIR = /usr/local/bin

export ORCA=$(ORCA_BINDIR)/orca

TARGETTYPE=shell

ASSEMBLER=orcam

MERLIN_DIR=/usr/local
export MERLIN_BIN=$(MERLIN_DIR)/bin/Merlin32
export MERLIN_LIB=$(MERLIN_DIR)/lib/Merlin
MERLIN_ASM=make/merlin-asm

SRCDIRS=.

# Check for Xcode build variables for the locations of build outputs and fall back
# to the current directory if not set.
ifeq ($(OBJECT_FILE_DIR),)
    OBJDIR=.
else
    export OBJECT_FILE_DIR
    OBJDIR=$(OBJECT_FILE_DIR)
endif

ifeq ($(DERIVED_SOURCES_DIR),)
    GENDIR=.
else
    export DERIVED_SOURCES_DIR
    GENDIR=$(DERIVED_SOURCES_DIR)
endif

ifeq ($(TARGET_BUILD_DIR),)
    TARGETDIR=.
else
    export TARGET_BUILD_DIR
    TARGETDIR=$(TARGET_BUILD_DIR)
endif

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
MV=mv
MKDIR=mkdir -p

DESKTOP_RES_MODE=640
MESSAGE_CENTER=0

GSPLUS=/Applications/GSplus.app/Contents/MacOS/gsplus
GSPORT=/Applications/GSport/GSport.app/Contents/MacOS/GSport

export GSPLUS
export GSPORT

XCODE_PATH=/Applications/Xcode.app
XCODE_INFO=$(XCODE_PATH)/Contents/Info.plist

ORCAM_PLUGIN_PATH=$(HOME)/Library/Developer/Xcode/Plug-ins/OrcaM.ideplugin
ORCAM_PLUGIN_INFO=$(ORCAM_PLUGIN_PATH)/Contents/Info.plist

XCODE_PLUGIN_COMPATIBILITY=DVTPlugInCompatibilityUUID


.PHONY: all gen genclean

all:
	$(MKDIR) $(OBJDIR) $(GENDIR) $(TARGETDIR)
	@make gen
	@make build

