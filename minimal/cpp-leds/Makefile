### CPU part number (must have a specific linker script for each part)
# Note that MK60DN256ZVLL10 (version 1.x) and MK60DN256VLL10 (version 2.x, no Z)
# only differ in some register locations etc, not in the actual memory layout,
# so it is safe to use the same linker script for both version 1.x and version
# 2.x silicon.
CPU_PART ?= K60DN256VLL10

# Target triple for the build. Use arm-none-eabi if you are unsure.
TARGET_TRIPLE ?= arm-none-eabi

### Optimization setting
ifndef OPTI
OPTI=0
endif

#### Debug settings
# Light debugging info
#DEBUG=-g
# Include macro definitions etc in debugging info
DEBUG=-g3 -gdwarf-4

### Compiler definitions

# Toolchain prefix, composed of the path and target triple, you will most likely not need to touch this.
TCPREFIX  ?= $(if $(GCCBIN),$(GCCBIN)/)$(if $(TARGET_TRIPLE),$(TARGET_TRIPLE)-)
GDBPREFIX ?= $(TCPREFIX)

CC       = $(TCPREFIX)gcc
CXX      = $(TCPREFIX)g++
LD       = $(TCPREFIX)g++
AS       = $(TCPREFIX)as
AR       = $(TCPREFIX)ar
NM       = $(TCPREFIX)nm
LINKER   = $(TCPREFIX)ld
OBJCOPY  = $(TCPREFIX)objcopy
OBJDUMP  = $(TCPREFIX)objdump
STRIP    = $(TCPREFIX)strip
SIZE     = $(TCPREFIX)size
GDB      = $(GDBPREFIX)gdb
CFLAGSNO = -I../../include \
           -I. -I.. \
           -Wall -mcpu=cortex-m4 \
           -fno-common -ffreestanding

ifdef BUILD_WITH_CLANG
ifneq ($(BUILD_WITH_CLANG),0)
CFLAGSNO += -target $(TARGET_TRIPLE)
CC       = clang
CXX      = clang++
LD       = clang++
LLVMPREFIX ?= llvm-
AS       = $(LLVMPREFIX)as
AR       = $(LLVMPREFIX)ar
NM       = $(LLVMPREFIX)nm
# There is no LLVM linker yet, use binutils.
#LINKER   = $(LLVMPREFIX)ld
# objcopy does not have a clear substitute in LLVM
#OBJCOPY  = $(LLVMPREFIX)objcopy
OBJDUMP  = $(LLVMPREFIX)objdump
# LLVM lacks a binutils strip tool as well...
#STRIP    = $(LLVMPREFIX)strip
SIZE     = $(LLVMPREFIX)size
# llvm-ar does not support the f modifier (anymore, since r186078) set in the
# default Contiki Makefile.include
AROPTS   = rcv
endif
endif

LINKERSCRIPTPATH = ../../ldscripts/modular
LINKERSCRIPT = $(CPU_PART).ld

CFLAGS   += $(CFLAGSNO)  $(DEBUG) -O$(OPTI) $(OPTFLAGS) -Wall -Werror=implicit-function-declaration -fno-common -fno-strict-aliasing -mcpu=cortex-m4 -mthumb -nostartfiles -ffunction-sections -fdata-sections -Wextra -pedantic
CXXFLAGS = $(CFLAGS)
LDFLAGS  += $(CFLAGS) -Wl,-L$(LINKERSCRIPTPATH) -T $(LINKERSCRIPT) -Wl,-Map=$@.map -Wl,--gc-sections

LD_START_GROUP ?= -Wl,--start-group
LD_END_GROUP ?= -Wl,--end-group

### Source files
SRCS = core-clocks.c fault-handlers.c interrupt-vector-k60.c startup-k60.c leds.cpp cppsupport.cpp
OBJS = $(patsubst %.c,%.o,$(filter %.c,$(SRCS))) $(patsubst %.cpp,%.o,$(filter %.cpp,$(SRCS)))

all: cppleds

cppleds: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@
