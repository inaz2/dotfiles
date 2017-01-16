import gdb
import struct
import re

def evaluate(expr):
    value = gdb.parse_and_eval(expr)
    return int(value) & ((1<<64)-1)

def get_wordsize():
    return evaluate('sizeof(void *)')

def poi(addr):
    wordsize = get_wordsize()
    data = gdb.selected_inferior().read_memory(addr, wordsize)
    if wordsize == 4:
        return struct.unpack('<I', data)[0]
    else:
        return struct.unpack('<Q', data)[0]

class DpsCommand(gdb.Command):
    def __init__(self):
        super().__init__("dps", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        args = arg.split()
        if len(args) == 0:
            start = evaluate('$_ ? $_ : $sp')
            num = 16
        elif len(args) == 1:
            start = evaluate(args[0])
            num = 16
        else:
            start = evaluate(args[0])
            num = int(args[1])
        self.display_pointer_with_symbol(start, num)

    def display_pointer_with_symbol(self, start, num):
        wordsize = get_wordsize()
        for i in range(num):
            ptr = start + i*wordsize
            addr = poi(ptr)
            value = gdb.execute('x/s 0x{:x}'.format(addr), to_string=True)
            loc, cstr = value.split(':', 1)
            cstr = cstr.strip()
            if not ' ' in loc and not re.search(r'^<|\\\d{3}', cstr):
                value = loc + ' ' + cstr
            else:
                value = loc
            print('{:x}  {}'.format(ptr, value))
        gdb.execute('set $_=0x{:x}'.format(start + num*wordsize))

class HeapCommand(gdb.Command):
    def __init__(self):
        super().__init__("heap", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        heap_base = self.get_heap_base()
        if heap_base:
            self.print_fastbins()
            print()
            self.print_chunks(heap_base)

    def get_heap_base(self):
        pid = gdb.selected_inferior().pid
        with open('/proc/{}/maps'.format(pid)) as f:
            for line in f.read().splitlines():
                if '[heap]' in line:
                    heap_base = int(line.split('-')[0], 16)
                    return heap_base

    def print_fastbins(self):
        try:
            evaluate('&main_arena')
        except gdb.error:
            print("couldn't find main_arena")
            return

        print('{:<10}{}'.format('fastbins', 'fd'))
        for i in range(7):
            fd = evaluate("main_arena.fastbinsY[{}]".format(i))
            print('{:<10x}{:x}'.format(0x10*(i+2), fd))

    def print_chunks(self, heap_base):
        addr_chunk = heap_base
        wordsize = get_wordsize()

        print('{:<12}  {:<6}  {:<6}  {:<6}  {:<16}  {:<16}'.format('addr', 'prev', 'size', 'flag', 'fd', 'bk'))
        while True:
            try:
                prevsize = poi(addr_chunk)
                size = poi(addr_chunk+wordsize)
                fd = poi(addr_chunk+wordsize*2)
                bk = poi(addr_chunk+wordsize*3)
            except gdb.MemoryError:
                break
            size, flag = (size & ~7), (size & 7)
            print('{:<12x}  {:<6x}  {:<6x}  {:<6x}  {:<16x}  {:<16x}'.format(addr_chunk, prevsize, size, flag, fd, bk))
            addr_chunk += size

DpsCommand()
HeapCommand()
