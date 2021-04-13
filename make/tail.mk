#
#  tail.mk
#

export PATH := $(PATH):$(ORCA_BIN)

CWD=$(shell pwd)

DISKIMAGE=$(TARGETDIR)/$(PGM).2mg
ARCHIVE=$(TARGETDIR)/$(PGM).shk
DESTBOOTIMAGE=$(TARGETDIR)/$(BOOTIMAGE)
BUILDTARGET=$(DISKIMAGE)
EXECTARGET=executeGUI
BOOTCOPYPATH=
AUXTYPE=
CFLAGS+=-i$(GENDIR)

vpath $(GENDIR)

ifeq ($(TARGETTYPE),shell)
    FILETYPE=exe
    EXECTARGET=executeShell
    BUILDTARGET=$(TARGETDIR)/$(PGM)
else ifeq ($(TARGETTYPE),desktop)
    FILETYPE=s16
    ifeq ($(MESSAGE_CENTER),1)
	AUXTYPE=-a 0x0000db07
    else
	AUXTYPE=-a 0x0000db03
    endif
    CFLAGS+=-dMESSAGE_CENTER=$(MESSAGE_CENTER)
    REZFLAGS+=rez='-d DESKTOP_RES_MODE=$(DESKTOP_RES_MODE)'
    REZFLAGS+=rez='-d MESSAGE_CENTER=$(MESSAGE_CENTER)'
else ifeq ($(TARGETTYPE),cda)
    FILETYPE=cda
    BOOTCOPYPATH=System/Desk.Accs
else ifeq ($(TARGETTYPE),cdev)
    BINTARGET=$(TARGETDIR)/$(PGM).bin
    FILETYPE=199
    BOOTCOPYPATH=System/CDevs
    REZFLAGS+=rez='-d BINTARGET="$(BINTARGET)"'
else ifeq ($(TARGETTYPE),nba)
    FILETYPE=exe
    BUILDTARGET=$(TARGETDIR)/$(PGM)
else ifeq ($(TARGETTYPE),nda)
    FILETYPE=nda
    BOOTCOPYPATH=System/Desk.Accs
else ifeq ($(TARGETTYPE),xcmd)
    FILETYPE=exe
    BUILDTARGET=$(TARGETDIR)/$(PGM)
endif


ASM_SRCS=$(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS)))))

ifeq ($(ASSEMBLER),orcam)
    ASM_MACROS=$(patsubst %.s, $(OBJDIR)/%.macros, $(ASM_SRCS))
    ASM_DEPS=$(patsubst %.s, $(OBJDIR)/%.macros.d, $(ASM_SRCS))
    ASM_ROOTS=$(patsubst %.s, $(OBJDIR)/%.ROOT, $(ASM_SRCS))
    ASM_OBJS=$(patsubst %.s, $(OBJDIR)/%.a, $(ASM_SRCS))

    ifeq ($(wildcard $(ROOTCFILE)),)
	ROOTCFILE=
    endif

    C_ROOTS=$(patsubst %.c, $(OBJDIR)/%.root, $(ROOTCFILE))
    C_SRCS+=$(filter-out $(ROOTCFILE), $(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.c, $(SRCDIRS))))))
    C_OBJS=$(patsubst %.c, $(OBJDIR)/%.a, $(C_SRCS))
    C_DEPS=$(patsubst %.c, $(OBJDIR)/%.d, $(ROOTCFILE)) $(patsubst %.c, $(OBJDIR)/%.d, $(C_SRCS))
endif

REZ_SRCS=$(patsubst $(GENDIR)/%, %, $(patsubst ./%, %, $(wildcard $(addsuffix /*.rez, $(SRCDIRS)))))
REZ_DEPS=$(patsubst %.rez, $(OBJDIR)/%.rez.d, $(REZ_SRCS))
REZ_OBJS=$(patsubst %.rez, $(OBJDIR)/%.r, $(REZ_SRCS))

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

.PHONY: build execute executeShell executeGUI clean xcodefix

.PRECIOUS: $(ASM_MACROS)

build: $(BUILDTARGET)

gen: xcodefix

xcodefix:
	[ "`uname`" = Darwin ] && defaults write "$(ORCAM_PLUGIN_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)s -array `defaults read "$(XCODE_INFO)" $(XCODE_PLUGIN_COMPATIBILITY)` || true

clean: genclean
	$(RM) "$(TARGETDIR)/$(PGM)" $(BINTARGET)
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_ROOTS)
	$(RM) $(ALL_DEPS)
	$(RM) $(ASM_MACROS)
	$(RM) "$(DISKIMAGE)"
	$(RM) "$(DESTBOOTIMAGE)"
	$(RM) "$(ARCHIVE)"

createPackage:
	pkg/createPackage

cleanMacCruft:
	rm -rf pkg


ifeq ($(BINTARGET),)
    ifeq ($(ASSEMBLER),orcam)

# This is a standard ORCA build where we generate the resources if any and
# then link the binary over that same file creating the resource fork first
# and the data fork second.
$(TARGETDIR)/$(PGM): $(BUILD_OBJS)
	$(MKDIR) $(TARGETDIR)
ifneq ($(REZ_OBJS),)
	$(RM) $(TARGETDIR)/$(PGM)
	$(CP) $(REZ_OBJS) $(TARGETDIR)/$(PGM)
endif
	cd $(OBJDIR); $(LINK) $(LDFLAGS) $(patsubst $(OBJDIR)/%, %, $(BUILD_OBJS_NOSUFFIX)) keep="$(abspath $(TARGETDIR)/$(PGM))"
	$(CHTYP) -t $(FILETYPE) $(AUXTYPE) $(TARGETDIR)/$(PGM)

    endif

    ifeq ($(ASSEMBLER),merlin)
# This is a standard Merlin build where we generate the resources if any and
# then link the binary over that same file creating the resource fork first
# and the data fork second.

$(TARGETDIR)/$(PGM): $(BUILD_OBJS) $(ASM_SRCS)
	$(MKDIR) $(TARGETDIR)
	$(RM) $(TARGETDIR)/$(PGM)
	$(MERLIN_ASM) linkscript.s $(PGM) $(TARGETDIR)/$(PGM)
ifneq ($(REZ_OBJS),)
	$(CP) $(REZ_OBJS)/..namedfork/rsrc $(TARGETDIR)/$(PGM)/..namedfork/rsrc
endif
	$(CHTYP) -t $(FILETYPE) $(AUXTYPE) $(TARGETDIR)/$(PGM)

    endif

else

    ifeq ($(ASSEMBLER),orcam)
# This is a special build for CDevs under ORCA where we build the binary into
# a $(PGM).bin file and then build the resources into the $(PGM) target.  The
# resource compile will read the $(PGM).bin binary and load it into the
# resources also.
$(BINTARGET): $(BUILD_OBJS)
	cd $(OBJDIR); $(LINK) $(LDFLAGS) $(patsubst $(OBJDIR)/%, %, $(BUILD_OBJS_NOSUFFIX)) keep="$(abspath $(BINTARGET))"

    endif

    ifeq ($(ASSEMBLER),merlin)
# This is a special build for CDevs under Merlin where we build the binary into
# a $(PGM).bin file and then build the resources into the $(PGM) target.  The
# resource compile will read the $(PGM).bin binary and load it into the
# resources # also.
$(BINTARGET): $(BUILD_OBJS) $(ASM_SRCS)
	$(MERLIN_ASM) linkscript.s $(PGM) $(BINTARGET)

    endif

$(REZ_OBJS): $(BINTARGET)

$(TARGETDIR)/$(PGM): $(REZ_OBJS)
	$(MKDIR) $(TARGETDIR)
	$(RM) $(TARGETDIR)/$(PGM)
	$(CP) $(REZ_OBJS) $(TARGETDIR)/$(PGM)
	$(CHTYP) -t $(FILETYPE) $(AUXTYPE) $(TARGETDIR)/$(PGM)

endif

$(DISKIMAGE): $(TARGETDIR)/$(PGM) make/empty.2mg make/$(BOOTIMAGE)
	make/createDiskImage "$(DISKIMAGE)" $(DESTBOOTIMAGE) "$(TARGETDIR)/$(PGM)" $(BOOTCOPYPATH)

execute: $(EXECTARGET)

executeGUI: all
	make/launchEmulator "$(DISKIMAGE)" "$(DESTBOOTIMAGE)"

executeShell: all
	$(ORCA) $(TARGETDIR)/$(PGM)

$(OBJDIR)/%.a:	%.c
	$(COMPILE) $< $(@:.a=) $(CFLAGS) --noroot

$(OBJDIR)/%.a:    $(GENDIR)/%.c
	$(COMPILE) $< $(@:.a=) $(CFLAGS) --noroot

$(OBJDIR)/%.root:	%.c
	$(COMPILE) $< $(@:.root=) $(CFLAGS)

$(OBJDIR)/%.root:    $(GENDIR)/%.c
	$(COMPILE) $< $(@:.root=) $(CFLAGS)

$(OBJDIR)/%.ROOT:	%.s
	MACGENFLAGS="$(MACGENFLAGS)" MACGENMACROS="$(MACGENMACROS)" $(ASSEMBLE) $< $(@:.ROOT=) $(ASMFLAGS)

$(OBJDIR)/%.ROOT:    $(GENDIR)/%.s
	MACGENFLAGS="$(MACGENFLAGS)" MACGENMACROS="$(MACGENMACROS)" $(ASSEMBLE) $< $(@:.ROOT=) $(ASMFLAGS)

$(OBJDIR)/%.r:	%.rez
	$(REZ) $< $(@:.r=) $(REZFLAGS)
ifneq ($(RLINT_PATH),)
	$(ORCA) $(RLINT_PATH) $@
endif

$(OBJDIR)/%.r:    $(GENDIR)/%.rez
	$(REZ) $< $(@:.r=) $(REZFLAGS)
ifneq ($(RLINT_PATH),)
	$(ORCA) $(RLINT_PATH) $@
endif

$(OBJS): Makefile

# Include the C and rez dependencies which were generated from the last build
# so we recompile correctly on .h file changes.
-include $(ALL_DEPS)
