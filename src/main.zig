const std = @import("std");
const init = @import("./commands/init.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer {
        const status = gpa.deinit();
        if (status == .leak) {
            std.log.err("Heap de-allocation failed with memory leak\n", .{});
        }
    }

    // form iterator from args
    var it = try std.process.argsWithAllocator(alloc);
    defer it.deinit();

    // skip executable invocation
    if (!it.skip()) {
        std.log.err("No arguments received\n", .{});
        return;
    }

    const command = it.next();
    if (std.mem.eql(u8, command.?, "init")) {
        // init
        try init.run(alloc, &it);
    }
}
