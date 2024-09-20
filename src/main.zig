const std = @import("std");
const vga = @import("vga.zig");
const cpuid = @import("cpuid.zig");

// https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const MAGIC = 0x1BADB002;
const FLAGS = ALIGN | MEMINFO;

const MultiBoot = extern struct {
    magic: i32,
    flags: i32,
    checksum: i32,
};

export const multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

pub export var stack: [16 * 1024]u8 align(16) linksection(".bss") = undefined;

export fn _start() callconv(.Naked) noreturn {
    asm volatile (
        \\ movl %[stk], %esp
        \\ pushl %ebx
        \\ pushl %eax
        \\ call main 
        :
        : [stk] "{ecx}" (@intFromPtr(&stack) + @sizeOf(@TypeOf(stack))),
    );
    while (true) {}
}

export fn main() void {
    vga.clear();

    for ("Is this thing on?", 0..) |byte, i| {
        vga.put(i, 0, byte, vga.Colour.Green, vga.Colour.Black);
    }

    for (cpuid.manufacturerId(), 0..) |byte, i| {
        vga.put(i, 1, byte, vga.Colour.Green, vga.Colour.Black);
    }

    inline for (std.meta.fields(vga.Colour), 0..) |colour, i| {
        vga.put(i, 2, i + 65, @enumFromInt(colour.value), vga.Colour.Black);
    }

    while (true) {}
}
