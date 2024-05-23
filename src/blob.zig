const std = @import("std");

pub const Blob = struct {
    size: u64,
    hash: [40]u8,
    content: std.ArrayList(u8),

    pub fn readFromFile(allocator: std.mem.Allocator, name: []const u8) !Blob {
        
    }

    fn decompress() anyerror!std.ArrayList(u8) {

    }
};
