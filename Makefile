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
# TARGETTYPE=shell
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

# Uncomment the following line if you have installed rlint as found here:
#   https://github.com/ksherlock/rlint/releases
# Assuming that it is in the path that ORCA searches (the Utilities directory is
# probably a good choice), you can just leave the value unchanged.  If you have
# put the rlint somewhere weird, you can set this to the correct path
# RLINT_PATH=rlint

# Add any arguments you want passed to the macro generator to this variable:
MACGENFLAGS+=

# Add any other macro libraries to include in this variable:
MACGENMACROS+=

# Add any arguments you want passed to the assembler to this variable:
ASMFLAGS+=

# Add any arguments you want passed to the linker to this variable:
LDFLAGS+=

# Uncomment the following line if you want to build against the GNO libraries
# export ORCA=$(ORCA_BINDIR)/gno

# If you want to copy one or more files or directories to the target disk
# image, add the root directory to this variable.  Any directories under
# the source directory which don't exist in the target disk image will be
# created.  All files will be copied from the source to the target using
# the same path from the source.
#
# For example, if you set COPYDIRS to dir and in your project you have
# the following files:
#     dir/System/mySystemFile
#     dir/newDir/anotherFile
# Then, during the copy phase, mySystemFile will be copied into the System
# folder and a folder newDir will be created and anotherFile will be copied
# into there.
COPYDIRS=

# By default, the build expects that you have GSplus in the path:
# 	/Applications/GSplus.app/Contents/MacOS/gsplus
# If you have it in a different location, specify that here.
# GSPLUS=/Applications/GSplus.app/Contents/MacOS/gsplus

# By default, the build expects that you have GSport in the path:
# 	/Applications/GSport/GSport.app/Contents/MacOS/GSport
# If you have it in a different location, specify that here.
# GSPORT=/Applications/GSport/GSport.app/Contents/MacOS/GSport

# For a desktop application, it can operate in 640x200 or 320x200
# resolution.  This setting is used to define which horizontal
# resolution you want to use for a desktop application.  Other
# target types ignore this value.
# DESKTOP_RES_MODE=640

# For a desktop application, it can support opening and printing
# files based on paths sent to it by the message center.  This
# option controls if that is or is not supported in the
# application (note: only the C desktop template supports message
# center today)
# MESSAGE_CENTER=0

# Add any rules you want to execute before any compiles or assembly
# commands are called here, if any.  You can generate .c, .s or .h
# files for example.  You can generate data files.  Whatever you
# might need.  You should generate these files in the $(GENDIR)
# directory or within a subdirectory under $(GENDIR) which you create
# yourself.
#
# All of your commands associated with a rule _must_ start with a tab
# character.  Xcode makes it a bit tough to type a tab character by
# default.  Press option-tab within Xcode to insert a tab character.
gen:

# For any files you generated in the gen target above, you should
# add rules in genclean to remove those generated files when you
# clean your build.
genclean:

# Do not change anything else below here...
include make/tail.mk
