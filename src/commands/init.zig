const std = @import("std");
const fs_utils = @import("../utils/fs.zig");
const DIRNAME = @import("../configuration.zig").DIRNAME;

pub fn run(allocator: std.mem.Allocator, args: *std.process.ArgIterator) anyerror!fs_utils.InitializationResult {
    if (@constCast(args).next()) |_| {
        // this could be -h
        // won't handle this case for now
    }

    const isInitialized = fs_utils.isRepositoryInitialized() catch |err| {
        std.log.err("{}", .{err});
        return fs_utils.InitializationResult{ .err = err };
    };

    if (isInitialized) {
        std.log.info("Repository already initialized.\n", .{});
        return fs_utils.InitializationResult.ok;
    }

    const init_result = fs_utils.initializeRepository(allocator);
    switch (init_result) {
        .ok => {
            std.debug.print("Initialized git_clone directory\n", .{});
        },
        .err => |err| {
            std.debug.print("Could not initialize the repository. {}\n", .{err});
        },
    }
    return init_result;
}
