const WIDTH = 80;
const HEIGHT = 25;
const vga_buffer: *[80 * 25]u16 = @ptrFromInt(0xB8000);

pub const Colour = enum(u4) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    Yellow = 14,
    White = 15,
};

pub fn vgaEntry(character: u8, fg: Colour, bg: Colour) u16 {
    // | 7        | 6 | 5 | 4 | 3 | 2 | 1 | 0 | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
    // | Blink/bg | bg colour | fg colour     | character                     |
    return (@as(u16, @intFromEnum(bg)) << 12) | (@as(u16, @intFromEnum(fg)) << 8) | @as(u16, character);
}

pub fn clear() void {
    @memset(vga_buffer, vgaEntry(' ', Colour.White, Colour.Black));
}

pub fn put(x: usize, y: usize, character: u8, fg: Colour, bg: Colour) void {
    vga_buffer[y * WIDTH + x] = vgaEntry(character, fg, bg);
}
