const std = @import("std");
const zlib = std.compress.zlib;

pub fn decompress(allocator: std.mem.Allocator, buffer: []const u8) !std.ArrayList(u8) {
    const decompressor = zlib.decompressor(buffer);
    const out_buf = std.ArrayList(u8).init(allocator);
    errdefer out_buf.deinit();

    while (try decompressor.next()) |plain| {
        out_buf.appendSlice(plain);
    }
    return out_buf;
}
