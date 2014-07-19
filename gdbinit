set disassembly-flavor intel
set print asm-demangle on
set print array on
set print array-indexes on
set output-radix 16.
set follow-fork-mode child
set history filename ~/.gdb_history
set history save on
display/i $pc
