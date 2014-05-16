OUTPUT_FORMAT ("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")
OUTPUT_ARCH(arm)

MEMORY
{
    flash (rx)  : ORIGIN = 0x0,     LENGTH = 256K
    sram_l (rwx)    : ORIGIN = 0x1fff8000,  LENGTH = 32K /* Only accessible via code bus. */
    /* sram_u is split into two separate regions to detect situations where there is too little ram left for the stack during linking. */
    sram_u (rwx)    : ORIGIN = 0x20000000,  LENGTH = 32K - 2K /* Only accessible via system bus. */
    stack  (rw)    : ORIGIN = 0x20000000 + 32K - 2K,  LENGTH = 2K /* Only accessible via system bus. */
}

/* RAM limits */
__sram_u_start  = ORIGIN(sram_u);
__sram_u_length = LENGTH(sram_u);
__sram_u_end    = __sram_u_start + __sram_u_length;
__sram_l_start  = ORIGIN(sram_l);
__sram_l_length = LENGTH(sram_l);
__sram_l_end    = __sram_l_start + __sram_l_length;


SECTIONS
{
    /* Start at address 0x00. */
    . = 0x00;

    /* Interrupt vectors 0x00-0x3ff. */
    .vector_table 0x00000000 :
    {
        _vector_rom = .;
        KEEP(*(.isr_vector))
        KEEP(*(.vector_table))
    } >flash
    /* Actually only 111 entries are used by the K60DNxxxVLL10. (111*4 == 444 == 0x1bc) */
    ASSERT (SIZEOF(.vector_table) == 444, "Interrupt vector table of invalid size.")
    ASSERT (. == 0x1bc, "Interrupt vector table at invalid location.")

    /*
     * Allocate space for interrupt vector in RAM
     * This can safely be removed to free up 0x400 bytes of RAM if the code does
     * not make use of this CPU feature.
     */
    .ramvect :
    {
        . = ALIGN(1024);
        _vector_ram_start = .;
        . = _vector_ram_start + 0x400;
        _vector_ram_end = .;
    } > sram_u


    /* Flash security 0x400-0x40f. */
    .security 0x400 :
    {
        /* Backdoor key. */
        LONG (0x01234567) LONG (0x89abcdef)

        /* FPROT0-3: no region of the flash is protected. */
        LONG (0xffffffff)

        /* FSEC: place MCU in unsecure mode. */
        BYTE (0xfe)

        /* FOPT: disable EzPort. */
        BYTE (0xfd)

        /* FEPROT: default. */
        BYTE (0xff)

        /* FDPROT: default. */
        BYTE (0xff)
    } >flash
    ASSERT (SIZEOF(.security) == 0x10, "Flash security sector of invalid size (linker-script error?).")
    ASSERT (. == 0x410, "Flash security sector of invalid size or position (linker-script error?).")

    /* Program code 0x410-. */
    .text :
    {
        . = ALIGN(4);
        _text_load = LOADADDR(.text);
        _text_start = .;
        KEEP (*(SORT_NONE(.init)))
        KEEP (*(SORT_NONE(.fini)))
        /* Default ISR handlers */
        KEEP(*(.default_handlers))
        *(.text.unlikely .text.*_unlikely .text.unlikely.*)
        *(.text.exit .text.exit.*)
        *(.text.startup .text.startup.*)
        *(.text.hot .text.hot.*)
        *(.text .stub .text.* .gnu.linkonce.t.*)

        /* gcc uses crtbegin.o to find the start of
           the constructors, so we make sure it is
           first.  Because this is a wildcard, it
           doesn't matter if the user does not
           actually link against crtbegin.o; the
           linker won't look for a file to match a
           wildcard.  The wildcard also means that it
           doesn't matter which directory crtbegin.o
           is in.  */
        KEEP (*crtbegin.o(.ctors))
        KEEP (*crtbegin?.o(.ctors))
        KEEP (*crtbeginTS.o(.ctors))
        /* We don't want to include the .ctor section from
           the crtend.o file until after the sorted ctors.
           The .ctor section from the crtend file contains the
           end of ctors marker and it must be last */
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .ctors))
        KEEP (*(SORT(.ctors.*)))
        KEEP (*(.ctors))

        KEEP (*crtbegin.o(.dtors))
        KEEP (*crtbegin?.o(.dtors))
        KEEP (*crtbeginTS.o(.dtors))
        KEEP (*(EXCLUDE_FILE (*crtend.o *crtend?.o ) .dtors))
        KEEP (*(SORT(.dtors.*)))
        KEEP (*(.dtors))
        . = ALIGN(4);
        _rodata_start = .;
        *(.rodata .rodata* .gnu.linkonce.r.*)
        . = ALIGN(4);
        _rodata_end = .;
        _text_end = .;
    } >flash

    .ramcode :
    {
        . = ALIGN(4);
        _ramcode_load = LOADADDR(.ramcode);
        _ramcode_start = .;
        *(.ramcode*)
        . = ALIGN(4);
        _ramcode_end = .;
    } > sram_l AT>flash

    /* The .extab, .exidx sections are used for C++ exception handling */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } >flash

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } >flash
    PROVIDE_HIDDEN (__exidx_end = .);

    /* Program data, values stored in flash and loaded upon init. */
    .data :
    {
        . = ALIGN(4);
        _data_load  = LOADADDR(.data);
        _data_start = .;

        *(.data*)
        . = ALIGN(4);

        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
        . = ALIGN(4);

        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
        . = ALIGN(4);

        /* fini data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);
        . = ALIGN(4);

        _data_end = .;
    } >sram_u AT >flash

    /* Program bss, zeroed out during init. */
    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
        __bss_end = .;
        . = ALIGN(4);
        _heap_start = .;
        __heap_start = .;
    } >sram_u

    /* Make sure we set _end, in case we want dynamic memory management... */
    __end = .;
    _end = .;
    PROVIDE(end = .);

    .stack :
    {
        _heap_end = .;
        __heap_end = _heap_end;
        /* stack and heap meet at their ends */
        __stack_start = .;
        __stack_size = LENGTH(stack);
        . = . + __stack_size;
        . = ALIGN(8);
        __stack_end = .;
        /* Startup code want to know where the stack should begin... */
        __stack_top = .;
    } >stack
}
