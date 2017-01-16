set disassembly-flavor intel
set print asm-demangle on
set follow-fork-mode child
set history filename ~/.gdb_history
set history save on
set print array on
set print array-indexes on

define vmmap
  eval "shell cat /proc/%d/maps", getpid()
end

define args
  i r rdi rsi rdx rcx r8 r9
end

define nc
  disable display
  nexti
  info registers rax
  while {char}$pc != '\xe8' && {char}$pc != '\xc3'
    nexti
  end
  enable display
  display
end

define xw
  x/40wx $arg0
end

define xg
  x/40gx $arg0
end

define xi
  x/40i $pc-0x20
end

display/i $pc

source .gdbscript.py
