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
    const vga_buffer: [*]u16 = @ptrFromInt(0xB8000);

    // Clear screen
    for (0..80 * 25) |i| {
        vga_buffer[i] = 0x0F << 8 | ' ';
    }

    for ("Is this thing on?", 0..) |byte, i| {
        vga_buffer[i] = 0xF0 << 8 | @as(u16, byte);
    }

    while (true) {}
}
