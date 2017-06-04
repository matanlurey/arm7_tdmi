#!/bin/sh

# Dumps assembled arm4t assembly code.
# 
# Example:
#
#  // Input file arm.asm
#  ldrb  r1, [r0], r6
#    
#  // Shell
#  > tool/dump_arm.sh arm.asm
#  > 
#  > tmp.out:  file format Mach-O arm 
#  > 
#  > Disassembly of section __TEXT,__text:
#  > __text:
#  >        0:  06 10 d0 e6   ldrb  r1, [r0], r6
#
# FIXME: The byte-order of the output is reversed from how the instruction 
# should be encoded.  Assembling with big-endian gives the incorrect mnemonic
# output. For now, just reverse the bytes when copy-pasting into test files.

input=$1
output="tmp.out"

# Assemble input file
# -arch is the target architecture
# -EL | EB specifies little|big endian
# -o is the output filename
as -arch armv4t -EL -o "${output}" "${input}"

# Dump binary
# -D specifies that all sections should be disassembled.
objdump -D "${output}"

# Clean up
rm "${output}"
