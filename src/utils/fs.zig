const std = @import("std");
const DIRNAME = @import("../configuration.zig").DIRNAME;

pub fn isRepositoryInitialized() std.fs.Dir.AccessError!bool {
    const cwd = std.fs.cwd();
    const check_access = cwd.access(DIRNAME, .{ .mode = .read_only });

    if (check_access) {
        return true;
    } else |err| {
        switch (err) {
            error.PermissionDenied, error.FileBusy => {
                return true;
            },
            else => {
                return err;
            },
        }
    }
}

pub fn isRepositoryDataAccessible() bool {
    const cwd = std.fs.cwd();
    const check_access = cwd.access(DIRNAME, .{ .mode = .read_only });

    if (check_access) {
        return true;
    } else |_| {
        return false;
    }
}

const InitializationResultTag = enum { ok, err };
// TODO: Narrow the type of err
pub const InitializationResult = union(InitializationResultTag) { ok: void, err: anyerror };

pub fn initializeRepository(allocator: std.mem.Allocator) InitializationResult {
    const cwd = std.fs.cwd();

    const rel_path = std.fs.path.join(allocator, &[_][]const u8{ ".", DIRNAME }) catch |e| {
        return InitializationResult{ .err = e };
    };
    defer allocator.free(rel_path);

    cwd.makeDir(rel_path) catch |e| {
        return InitializationResult{ .err = e };
    };

    // Assuming that files are not initialized in the directory after its initialization.
    // Time of check time of use errors are unlikely
    const obj_path = std.fs.path.join(allocator, &[_][]const u8{ rel_path, "objects" }) catch |e| {
        return InitializationResult{ .err = e };
    };
    defer allocator.free(obj_path);

    const refs_path = std.fs.path.join(allocator, &[_][]const u8{ rel_path, "refs" }) catch |e| {
        return InitializationResult{ .err = e };
    };
    defer allocator.free(refs_path);

    const head_path = std.fs.path.join(allocator, &[_][]const u8{ rel_path, "HEAD" }) catch |e| {
        return InitializationResult{ .err = e };
    };
    defer allocator.free(head_path);

    cwd.makeDir(obj_path) catch |e| {
        return InitializationResult{ .err = e };
    };

    cwd.makeDir(refs_path) catch |e| {
        return InitializationResult{ .err = e };
    };

    const fd = cwd.createFile(head_path, .{ .exclusive = true }) catch |e| {
        return InitializationResult{ .err = e };
    };
    defer fd.close();
    _ = fd.write("ref: refs/heads/main\n") catch |e| {
        return InitializationResult{ .err = e };
    };

    return InitializationResult.ok;
}
