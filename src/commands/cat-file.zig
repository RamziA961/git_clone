const std = @import("std");

// git cat-file <type> <object>
// git cat-file (-e | -p) <object>
// git cat-file (-t | -s) [--allow-unknown-type] <object>
// git cat-file (--textconv | --filters)
// 	     [<rev>:<path|tree-ish> | --path=<path|tree-ish> <rev>]
// git cat-file (--batch | --batch-check | --batch-command) [--batch-all-objects]
// 	     [--buffer] [--follow-symlinks] [--unordered]
// 	     [--textconv | --filters] [-Z]
//
// reference: https://git-scm.com/docs/git-cat-file 


pub fn run(allocator: std.mem.Allocator, args: std.ArrayList([]const u8)) !void {
    if(args.items.len == 0) {
        // print help message
        return;
    }
    


}
