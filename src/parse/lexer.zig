const std = @import("std");
const token = @import("token.zig");
const err = @import("../error.zig");

const ExtractedToken = struct { token: token.Token, bytes_read: u16 };

pub const LexingError = err.ApplicationError || token.InvalidTokenError;

pub const Lexer = struct {
    buffer: *std.ArrayList([]const u8),
    pos: u16,

    pub fn init(buffer: *std.ArrayList([]const u8)) Lexer {
        return Lexer{ .buffer = buffer, .pos = 0 };
    }

    pub fn tokenize(self: *Lexer, allocator: std.mem.Allocator) err.ApplicationError![]token.Token {
        var token_buf = std.ArrayList(token.Token).init(allocator);
        errdefer token_buf.deinit();

        for (self.buffer.items) |_| {
            const tokens = self.next(allocator) catch {
                return error.UnhandledError;
            };
            defer allocator.free(tokens);

            token_buf.appendSlice(tokens) catch {
                return error.UnhandledError;
            };
            self.pos += 1;
        }

        return token_buf.toOwnedSlice() catch {
            return error.UnhandledError;
        };
    }

    fn next(self: *Lexer, allocator: std.mem.Allocator) LexingError![]token.Token {
        var local_buf = std.ArrayList(token.Token).init(allocator);
        errdefer local_buf.deinit();

        var cursor: u16 = 0;
        const arg = self.buffer.items[self.pos];

        const token_ty_set = [_]token.TokenTag{
            token.TokenTag.Int,
            token.TokenTag.Hyphen,
            token.TokenTag.Colon,
            token.TokenTag.Caret,
            token.TokenTag.Period,
            token.TokenTag.Ident,
        };

        while (cursor < arg.len) {
            var extracted = false;
            // pipeline
            for (token_ty_set) |token_ty| {
                if (extract_token(token_ty, self.buffer.items[self.pos], cursor)) |tok| {
                    local_buf.append(tok.token) catch |e| {
                        std.log.err("Error: {any}\n", .{e});
                        return error.MalformedToken;
                    };

                    cursor += tok.bytes_read;
                    extracted = true;
                    break;
                }
            }

            if (!extracted) {
                return error.UnrecognizedToken;
            }
        }

        return local_buf.toOwnedSlice() catch |e| {
            std.log.err("Unhandled error: {any}\n", .{e});
            return error.UnhandledError;
        };
    }

    fn extract_token(token_ty: token.TokenTag, buffer: []const u8, cursor: u16) ?ExtractedToken {
        return switch (token_ty) {
            .Int => extract_uint(buffer, cursor),
            .Hyphen => extract_hyphen(buffer, cursor),
            .Colon => extract_colon(buffer, cursor),
            .Caret => extract_caret(buffer, cursor),
            .Period => extract_period(buffer, cursor),
            .Ident => extract_ident(buffer, cursor),
        };
    }

    fn extract_hyphen(buffer: []const u8, cursor: u16) ?ExtractedToken {
        return if (buffer[cursor] == '-') {
            return ExtractedToken{ .token = token.Token{ .Hyphen = {} }, .bytes_read = 1 };
        } else {
            return null;
        };
    }

    fn extract_colon(buffer: []const u8, cursor: u16) ?ExtractedToken {
        return if (buffer[cursor] == ':') {
            return ExtractedToken{ .token = token.Token{ .Colon = {} }, .bytes_read = 1 };
        } else {
            return null;
        };
    }

    fn extract_caret(buffer: []const u8, cursor: u16) ?ExtractedToken {
        return if (buffer[cursor] == '^') {
            return ExtractedToken{ .token = token.Token{ .Caret = {} }, .bytes_read = 1 };
        } else {
            return null;
        };
    }

    fn extract_period(buffer: []const u8, cursor: u16) ?ExtractedToken {
        return if (buffer[cursor] == '.') {
            return ExtractedToken{ .token = token.Token{ .Period = {} }, .bytes_read = 1 };
        } else {
            return null;
        };
    }

    fn extract_uint(buffer: []const u8, cursor: u16) ?ExtractedToken {
        var digit: usize = 0;
        var index = cursor;
        while (index < buffer.len) {
            const c = buffer[index];
            if (c >= '0' and c <= '9') {
                digit *= 10;
                digit += c - '0';
            } else {
                break;
            }
            index += 1;
        }

        return if (index != cursor) {
            return ExtractedToken{ .token = token.Token{ .Int = digit }, .bytes_read = index - cursor };
        } else {
            return null;
        };
    }

    fn extract_ident(buffer: []const u8, cursor: u16) ?ExtractedToken {
        //TODO: needs additional checks/constraints
        return if (cursor < buffer.len - 1) {
            const len: u16 = @truncate(buffer.len);
            return ExtractedToken{ .token = token.Token{ .Ident = buffer[cursor..] }, .bytes_read = len - cursor };
        } else {
            return null;
        };
    }
};
