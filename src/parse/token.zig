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
};

pub const InvalidTokenError = error{ UnrecognizedToken, MalformedToken };
