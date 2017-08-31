#
#  tail.mk
#

export PATH := $(PATH):$(ORCA_BIN)

CWD=$(shell pwd)

DISKIMAGE=$(PGM).2mg
BUILDTARGET=$(DISKIMAGE)
EXECTARGET=executeGUI
DISKIMAGEDEST=.

ifeq ($(TARGETTYPE),shell)
    FILETYPE=exe
    EXECTARGET=executeShell
    BUILDTARGET=$(PGM)
else ifeq ($(TARGETTYPE),desktop)
    FILETYPE=s16
else ifeq ($(TARGETTYPE),cda)
    FILETYPE=cda
    DISKIMAGEDEST=System/Desk.Accs
else ifeq ($(TARGETTYPE),cdev)
    BINTARGET=$(PGM).bin
    FILETYPE=199
    DISKIMAGEDEST=System/CDevs
else ifeq ($(TARGETTYPE),nba)
    FILETYPE=exe
    BUILDTARGET=$(PGM)
else ifeq ($(TARGETTYPE),nda)
    FILETYPE=nda
    DISKIMAGEDEST=System/Desk.Accs
else ifeq ($(TARGETTYPE),xcmd)
    FILETYPE=exe
    BUILDTARGET=$(PGM)
endif

ifeq ($(wildcard $(ROOTCFILE)),)
    ROOTCFILE=
endif

C_ROOTS=$(ROOTCFILE:.c=.root)
C_SRCS+=$(filter-out $(ROOTCFILE), $(patsubst ./%, %, $(wildcard $(addsuffix /*.c, $(SRCDIRS)))))
C_OBJS=$(C_SRCS:.c=.a)
C_DEPS=$(ROOTCFILE:.c=.d) $(C_SRCS:.c=.d)

ASM_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS))))
ASM_MACROS=$(ASM_SRCS:.s=.macros)
ASM_DEPS=$(ASM_SRCS:.s=.macros.d)
ASM_ROOTS=$(ASM_SRCS:.s=.ROOT)
ASM_OBJS=$(ASM_SRCS:.s=.a)

REZ_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.rez, $(SRCDIRS))))
REZ_DEPS=$(REZ_SRCS:.rez=.rez.d)
REZ_OBJS=$(REZ_SRCS:.rez=.r)

ifneq ($(firstword $(REZ_SRCS)), $(lastword $(REZ_SRCS)))
    $(error Only a single resource file supported, found $(REZ_SRCS))
endif

BUILD_OBJS=$(C_ROOTS) $(C_OBJS) $(ASM_ROOTS)
ifeq ($(BINTARGET),)
    BUILD_OBJS+=$(REZ_OBJS)
endif
BUILD_OBJS_NOSUFFIX=$(C_ROOTS:.root=) $(C_OBJS:.a=) $(ASM_ROOTS:.ROOT=)

ALL_OBJS=$(C_ROOTS:.root=.a) $(C_OBJS) $(ASM_OBJS) $(REZ_OBJS)
ALL_ROOTS=$(C_ROOTS) $(C_OBJS:.a=.root) $(ASM_ROOTS)
ALL_DEPS=$(C_DEPS) $(ASM_DEPS) $(REZ_DEPS)

EXECCMD=

.PHONY: build execute executeShell executeGUI clean

.PRECIOUS: $(ASM_MACROS)

build: $(BUILDTARGET)

clean: genclean
	$(RM) "$(PGM)" $(BINTARGET)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_ROOTS)
	$(RM) $(ALL_DEPS)
	$(RM) $(ASM_MACROS)
	$(RM) "$(DISKIMAGE)"

createPackage:
	pkg/createPackage

cleanMacCruft:
	rm -rf pkg


ifeq ($(BINTARGET),)

# This is a standard build where we generate the resources if any and then link
# the binary over that same file creating the resource fork first and the data
# fork second.
$(PGM): $(BUILD_OBJS)
ifneq ($(REZ_OBJS),)
	$(RM) $(PGM)
	$(CP) $(REZ_OBJS) $(PGM)
endif
	$(LINK) $(LDFLAGS) $(BUILD_OBJS_NOSUFFIX) --keep=$(PGM)
	$(CHTYP) -t $(FILETYPE) $(PGM)

else

# This is a special build for CDevs (maybe others also?) where we build the binary
# into a $(PGM).bin file and then build the resources into the $(PGM) target.  The
# resource compile will read the $(PGM).bin binary and load it into the resources
# also.
$(BINTARGET): $(BUILD_OBJS)
	$(LINK) $(LDFLAGS) $(BUILD_OBJS_NOSUFFIX) --keep=$(BINTARGET)

$(REZ_OBJS): $(BINTARGET)

$(PGM): $(REZ_OBJS)
	$(RM) $(PGM)
	$(CP) $(REZ_OBJS) $(PGM)
	$(CHTYP) -t $(FILETYPE) $(PGM)

endif

$(DISKIMAGE): $(PGM)
	make/createDiskImage "$(DISKIMAGE)" "$(PGM)" "$(DISKIMAGEDEST)" $(COPYDIRS)

execute: $(EXECTARGET)

executeGUI: all
	make/launchEmulator -doit

executeShell: all
	$(ORCA) ./$(PGM)

%.a:	%.c
	$(COMPILE) $< $(CFLAGS) --noroot

%.root:	%.c
	$(COMPILE) $< $(CFLAGS)

%.macros:	%.s
	$(MACGEN) "$(MACGENFLAGS)" $< $@ $(MACGENMACROS)

%.ROOT:	%.macros
	$(ASSEMBLE) $(<:.macros=.s) $(ASMFLAGS)

%.r:	%.rez
	$(REZ) $< $(REZFLAGS)

$(OBJS): Makefile

# Include the C and rez dependencies which were generated from the last build
# so we recompile correctly on .h file changes.
-include $(ALL_DEPS)
