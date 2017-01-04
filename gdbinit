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

define dps
  init-if-undefined $_=$sp
  if $argc == 0
    printf "%p\n", $_
    p {void *}$_@16
    set $_=$+16
  end
  if $argc == 1
    printf "%p\n", $arg0
    p {void *}$arg0@16
    set $_=$+16
  end
  if $argc >= 2
    printf "%p\n", $arg0
    p {void *}$arg0@$arg1
    set $_=$+$arg1
  end
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
