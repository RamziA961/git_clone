const std = @import("std");

const Blob = struct {
    size: u64,
    hash: [40]u8,
    content: std.ArrayList(u8),
};
