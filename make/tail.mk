#
#  tail.mk
#

export PATH := $(PATH):$(ORCA_BIN)

CWD=$(shell pwd)

ifeq ($(wildcard $(ROOTCFILE)),) 
    ROOTCFILE=
endif

C_ROOTS=$(ROOTCFILE:.c=.root)
C_SRCS+=$(filter-out $(ROOTCFILE), $(patsubst ./%, %, $(wildcard $(addsuffix /*.c, $(SRCDIRS)))))
C_OBJS=$(C_SRCS:.c=.a)
C_DEPS=$(ROOTCFILE:.c=.d) $(C_SRCS:.c=.d)

ASM_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.s, $(SRCDIRS))))
ASM_MACROS=$(ASM_SRCS:.s=.macros)
ASM_ROOTS=$(ASM_SRCS:.s=.ROOT)
ASM_OBJS=$(ASM_SRCS:.s=.a)

REZ_SRCS=$(patsubst ./%, %, $(wildcard $(addsuffix /*.rez, $(SRCDIRS))))
REZ_DEPS=$(REZ_SRCS:.rez=.rez.d)
REZ_OBJS=$(REZ_SRCS:.rez=.r)

ifneq ($(firstword $(REZ_SRCS)), $(lastword $(REZ_SRCS)))
    $(error Only a single resource file supported, found $(REZ_SRCS))
endif

BUILD_OBJS=$(C_ROOTS) $(C_OBJS) $(ASM_ROOTS) $(REZ_OBJS)
BUILD_OBJS_NOSUFFIX=$(C_ROOTS:.root=) $(C_OBJS:.a=) $(ASM_ROOTS:.ROOT=)

ALL_OBJS=$(C_ROOTS:.root=.a) $(C_OBJS) $(ASM_OBJS) $(REZ_OBJS)
ALL_ROOTS=$(C_ROOTS) $(C_OBJS:.a=.root) $(ASM_ROOTS)
ALL_DEPS=$(C_DEPS) $(REZ_DEPS)

LINK_ARGS=

EXECCMD=

#ALLTARGET=$(DISKIMAGE)
ifeq ($(TARGETTYPE),shell)
    ALLTARGET=execute
else
    ALLTARGET=$(PGM)
endif

.PHONY: all execute clean

#.PRECIOUS: $(ASM_MACROS)
	
all: $(ALLTARGET)

clean:
	$(RM) "$(PGM)"
	$(RM) $(ALL_OBJS)
	$(RM) $(ALL_ROOTS)
	$(RM) $(ALL_DEPS)
	$(RM) $(ASM_MACROS)
#	 $(RM) "$(DISKIMAGE)"

createPackage:
	pkg/createPackage

cleanMacCruft:
	rm -rf pkg

$(PGM): $(BUILD_OBJS)
ifneq ($(REZ_OBJS),)
	$(RM) $(PGM)
	$(CP) $(REZ_OBJS) $(PGM)
endif
	$(LINK) $(BUILD_OBJS_NOSUFFIX) --keep=$(PGM) $(LDFLAGS)

#$(DISKIMAGE): $(PGM)
#	make/createDiskImage $(AC) $(MACHINE) "$(DISKIMAGE)" "$(PGM)" "$(START_ADDR)"

#execute: $(DISKIMAGE)
#	osascript make/V2Make.scpt "$(CWD)" "$(PGM)" "$(CWD)/make/DevApple.vii" "$(EXECCMD)"

execute: $(PGM)
	$(ORCA) $(PGM)

%.a:	%.c
	$(COMPILE) $< $(CFLAGS) --noroot

%.root:	%.c
	$(COMPILE) $< $(CFLAGS)

%.macros:	%.s
	$(MACGEN) $(MACGENFLAGS) $< $@ $(MACGENMACROS)

%.ROOT:	%.macros
	$(ASSEMBLE) $(<:.macros=.s) $(ASMFLAGS)

%.r:	%.rez
	$(REZ) $< $(REZFLAGS)

$(OBJS): Makefile

# This adds a dependency to force all .macro targets to be regenerated if
# any of the macro library files have changed.  We can't tell which actual
# macros are used so we have to regenerate if any have changed.
ifneq ($(ASM_MACROS),)
$(ASM_MACROS): $(MACGENMACROS)
endif

# Include the C and rez dependencies which were generated from the last build
# so we recompile correctly on .h file changes.
-include $(ALL_DEPS)
