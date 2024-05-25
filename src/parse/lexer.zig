const std = @import("std");

const token = @import("token.zig");

const ExtractedToken = struct { token: token.Token, bytes_read: u16 };

pub const Lexer = struct {
    buffer: *std.ArrayList([]const u8),
    pos: u16,

    pub fn init(self: *Lexer, buffer: *std.ArrayList([]const u8)) !void {
        self.buffer = buffer;
    }

    pub fn tokenize(self: *Lexer, allocator: std.mem.Allocator) ![]token.Token {
        const token_buf = std.ArrayList(token.Token).init(allocator);
        errdefer token_buf.deinit();

        for (self.buffer) |_| {
            const tokens = try self.next();
            try token_buf.appendSlice(tokens);
            self.pos += 1;
        }

        return token_buf.toOwnedSlice();
    }

    fn next(self: *Lexer) token.InvalidTokenError![]token.Token {
        const local_buf = std.ArrayList(token.Token);
        errdefer local_buf.deinit();

        var cursor = 0;
        const arg = self.buffer.items[self.pos];

        const token_ty_set = [_]token.TokenTag{
            token.TokenTag.Int,
            token.TokenTag.Hyphen,
            token.TokenTag.Colon,
            token.TokenTag.Caret,
            token.TokenTag.Period,
            token.TokenTag.Ident,
        };

        var extracted = false;
        while (cursor < arg.len) {
            // pipeline
            for (token_ty_set) |token_ty| {
                if (extract_token(token_ty, self.buffer.items[self.pos], cursor)) |tok| {
                    cursor += tok.bytes_read;
                    local_buf.append(tok.token);
                    extracted = true;
                    break;
                }
            }

            if (!extracted) {
                return token.InvalidTokenError{arg};
            }
        }

        return local_buf.toOwnedSlice();
    }

    fn extract_token(token_ty: token.TokenTag, buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        return switch (token_ty) {
            .Int => extract_uint(buffer, cursor),
            .Hyphen => extract_hyphen(buffer, cursor),
            .Colon => extract_colon(buffer, cursor),
            .Caret => extract_caret(buffer, cursor),
            .Ident => extract_ident(buffer, cursor),
        };
    }

    fn extract_hyphen(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        return if (buffer.items[cursor] == '-') {
            ExtractedToken{ token.Token{.Hyphen}, 1 };
        } else {
            null;
        };
    }

    fn extract_colon(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        return if (buffer.items[cursor] == ':') {
            ExtractedToken{ token.Token{.Colon}, 1 };
        } else {
            null;
        };
    }

    fn extract_caret(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        return if (buffer.items[cursor] == '^') {
            ExtractedToken{ token.Token{.Caret}, 1 };
        } else {
            null;
        };
    }

    fn extract_period(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        return if (buffer.items[cursor] == '.') {
            ExtractedToken{ token.Token{.Period}, 1 };
        } else {
            null;
        };
    }

    fn extract_uint(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        var digit = 0;
        var index = cursor;
        while (index < buffer.items.len) {
            const c = buffer.items[index];
            if (c >= '0' and c <= '9') {
                digit *= 10;
                digit += c - '0';
            } else {
                break;
            }
            index += 1;
        }

        return if (index != cursor) {
            token.Token{ .Int{digit}, index - cursor };
        } else {
            null;
        };
    }

    fn extract_ident(buffer: *std.ArrayList(u8), cursor: u16) ?ExtractedToken {
        //TODO: needs additional checks/constraints
        return if (cursor < buffer.items - 1) {
            token.Token{ .Ident{buffer.items[cursor..]}, buffer.items.len - cursor };
        } else {
            null;
        };
    }
};
