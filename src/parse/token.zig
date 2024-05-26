const std = @import("std");
const debug = std.debug;

pub const TokenTag = enum {
    // primitives
    Int,

    // Special Characters
    Hyphen,
    Colon,
    Caret,
    Period,

    // Can be a command name, arg name, rev hash
    Ident,
};

pub const Token = union(TokenTag) {
    // digits
    Int: usize,

    Hyphen: void,
    Colon: void,
    Caret: void,
    Period: void,

    // slice of bytes
    Ident: []const u8,

    pub fn debugPrint(token: Token) void {
        switch (token) {
            .Int => |v| {
                debug.print("Int {{ {} }}\n", .{v});
            },
            .Ident => |s| {
                debug.print("Ident {{ {s} }}\n", .{s});
            },

            else => {
                debug.print("{s}\n", .{@tagName(token)});
            },
        }
    }
};

pub const InvalidTokenError = error{ UnrecognizedToken, MalformedToken };
