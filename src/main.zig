const std = @import("std");
const parse = @import("parse.zig");

//const init = @import("./commands/init.zig");

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
    _ = it.skip();

    var args = std.ArrayList([]const u8).init(alloc);
    defer args.deinit();

    while (it.next()) |arg| {
        try args.append(arg);
    }

    // if (args.items.len == 0) {
    //     std.debug.print("No arguments received.", .{});
    //     return;
    // }

    // const command = args.items[0];
    // if (std.mem.eql(u8, command, "init")) {
    //     // init
    //     _ = try init.run(alloc, args);
    // }

    var lexer = parse.lexer.Lexer.init(&args);
    const tokens = try lexer.tokenize(alloc);
    defer alloc.free(tokens);

    std.debug.print("\n", .{});
    for (tokens) |tok| {
        tok.debugPrint();
    }
}
