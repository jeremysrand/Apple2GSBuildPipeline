#
#  Makefile
#  	Apple //GS Build Engine for ORCA
#

include make/head.mk

# Customize this file to control what kind of project you are working on,
# where to find files, etc.

# The name of your system or binary file to build goes here:
PGM=___PACKAGENAME___

# Set the target type you would like to build.  The options are:
# 	shell - A shell command for ORCA, GNO or other GS shell
# 	desktop - A full desktop application
# 	cda - A classic desk accessory
# 	cdev - A control panel device
# 	nba - A HyperStudio new button action
# 	nda - A new desk accessory
# 	xcmd - A HyperCard XCMD or XCFN
#
TARGETTYPE=shell
# TARGETTYPE=desktop
# TARGETTYPE=cda
# TARGETTYPE=cdev
# TARGETTYPE=nba
# TARGETTYPE=nda
# TARGETTYPE=xcmd

# Add any other directories where you are putting C or assembly source
# files to this list:
# SRCDIRS+=

# If you put your main entry point for your project in a file called main.c
# Then you don't need to change this value.  If you want to call your entry
# point something other than main.c, set this variable to point to this file.
ROOTCFILE=main.c

# Add any arguments you want passed to the C compiler to this variable:
CFLAGS+=

# Add any arguments you want passed to the resource compiler to this variable:
REZFLAGS+=

# Add any arguments you want passed to the macro generator to this variable:
MACGENFLAGS+=

# Add any other macro libraries to include in this variable:
MACGENMACROS+=

# Add any arguments you want passed to the assembler to this variable:
ASMFLAGS+=

# Add any arguments you want passed to the linker to this variable:
LDFLAGS+=

# Do not change anything else below here...
include make/tail.mk
