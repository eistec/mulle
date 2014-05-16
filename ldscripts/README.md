Linker scripts for Mulle
========================

This directory contains linker scripts suitable for GNU binutils' ld program.

How to build a program for the Mulle board
------------------------------------------

The easiest way is to copy the file `mulle.ld` from the `ldscripts/monolithic`
directory to your source code directory. Then add `-T mulle.ld` to your
`LDFLAGS`, most often inside a Makefile.

What is a linker script?
------------------------

Linker scripts are used to tell the linker, the final stage when building a
program, about important parameters about the environment where the code will
run. For example, the Mulle linker script tells the linker to place all
executable code in the CPU's onboard flash, and make sure that all variables
are located in RAM when running the program. There are some other important
parameters as well, such as flash security sector, debugging information and
interrupt vectors, but the main point is to give the linker information about
where to place stuff in the memory layout.

Monolithic or modular?
----------------------

If in doubt, copy the file ldscripts/monolithic/mulle.ld to your source
directory and simply invoke the linker with the argument `-T mulle.ld` in order
to build for the normal Mulle board.

There are two different variations of the same script. One is the monolithic
script, which is a single file for easier packaging with other code. The other
is the modular version, the same version used by the Mulle port of the Contiki
operating system. The modular version is the base version which we use for
development because it is easier to maintain and can be adapted for different
variations of the CPU, the monolithic version is compiled from the modular
pieces by hand and only supports the MK60DN256VLL10 CPU (256kB Mulle).
