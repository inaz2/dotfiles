set disassembly-flavor intel
set print asm-demangle on
set print array on
set print array-indexes on
set output-radix 16.
set follow-fork-mode child
set history filename ~/.gdb_history
set history save on
display/i $pc

define telescope
  if $argc == 0
    p/s {char *}$sp@16
  end
  if $argc == 1
    p/s {char *}($arg0)@16
  end
  if $argc >= 2
    p/s {char *}($arg0)@$arg1
  end
end

define nc
  nexti
  while {char}$pc != (char)0xe8 && {char}$pc != (char)0xc3
    nexti
  end
end
