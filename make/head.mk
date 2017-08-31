#
#  head.mk
#

ORCA_HOME := $(HOME)/orca

ORCA_BINDIR = /usr/local/bin

export ORCA=$(ORCA_BINDIR)/orca

AC=make/AppleCommander.jar

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


.PHONY: all gen genclean

all:
	@make gen
	@make build
