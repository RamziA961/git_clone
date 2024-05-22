const std = @import("std");
const fs = @import("std").fs;
const path = @import("std").fs.path;
const DIRNAME = @import("../configuration.zig").DIRNAME;

pub fn run(allocator: std.mem.Allocator, args: *std.process.ArgIterator) anyerror!void {
    if (@constCast(args).next()) |_| {
        // this could be -h
        // won't handle this case for now
    }

    const cwd = fs.cwd();
    const rel_path = try path.join(allocator, &[_][]const u8{ ".", DIRNAME });
    defer allocator.free(rel_path);

    const access_check = cwd.access(rel_path, .{ .mode = .read_only });
    // this is really awkward
    if (access_check) {
        std.log.info("Repository already initialized. {s} already exists.\n", .{rel_path});
        return;
    } else |e| {
        switch (e) {
            error.FileNotFound => {},
            else => {
                std.log.err("{}", .{e});
                return;
            },
        }
    }

    cwd.makeDir(rel_path) catch |e| {
        std.log.info("Repository already initialized. {s} already exists.\n", .{DIRNAME});
        return e;
    };

    const obj_path = try path.join(allocator, &[_][]const u8{ rel_path, "objects" });
    defer allocator.free(obj_path);

    //const refs_path = try std.mem.concat(allocator, u8, &[_][]const u8{ rel_path, "/refs" });
    const refs_path = try path.join(allocator, &[_][]const u8{ rel_path, "refs" });
    defer allocator.free(refs_path);

    //const head_path = try std.mem.concat(allocator, u8, &[_][]const u8{ rel_path, "/HEAD" });
    const head_path = try path.join(allocator, &[_][]const u8{ rel_path, "HEAD" });
    defer allocator.free(head_path);

    cwd.makeDir(obj_path) catch |e| {
        std.log.err("{s} could not be initialized.\n", .{obj_path});
        return e;
    };

    cwd.makeDir(refs_path) catch |e| {
        std.log.err("{s} could not be initialized.\n", .{refs_path});
        return e;
    };

    // does not exist
    const fd = try cwd.createFile(head_path, .{ .exclusive = true });
    defer fd.close();
    _ = fd.write("ref: refs/heads/main\n") catch |e| {
        return e;
    };
}
