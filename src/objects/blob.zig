const std = @import("std");

pub const Blob = struct {
    size: u64,
    hash: [40]u8,
    content: std.ArrayList(u8),

    pub fn fromBuffer(allocator: std.mem.Allocator, buffer: []const u8) !Blob {

        
    }

};
