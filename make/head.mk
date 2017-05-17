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

MACGEN=$(ORCA) macgen
MACGENFLAGS=-P
MACGENMACROS=$(wildcard $(ORCA_HOME)/libraries/ORCAInclude/m*)

ASSEMBLE=make/orca-asm
ASMFLAGS=-P

LINK=$(ORCA) link
LDFLAGS=-P

RM=rm -f
CP=cp
