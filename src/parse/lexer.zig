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

        
    }

    fn next(self: *Lexer, allocator: std.mem.Allocator) ![]token.Token {
        const local_buf = std.ArrayList(token.Token);
        errdefer local_buf.deinit();
        
        var cursor = 0;
        const arg = self.buffer.items[self.pos];
    
        while(cursor < arg.len) {
            

            cursor += 1;
        }
    }

    fn extract_token(token_ty: token.TokenTag, buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        return switch (token_ty) {
            .Int => {},
            .Hyphen => extract_hyphen(buffer, cursor)
        };
    }

    fn extract_hyphen(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        if(buffer.items[cursor] == '-') {
            return ExtractedToken { token.Token { .Hyphen }, 1 }; 
        }
        return null;
    }

    fn extract_colon(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        return if(buffer.items[cursor] == ':') {
            ExtractedToken { token.Token { .Colon }, 1};
        } else {
            null;
        };
    }

    fn extract_caret(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        return if(buffer.items[cursor] == '^') {
            ExtractedToken { token.Token { .Caret }, 1};
        } else {
            null;
        };
    }


    fn extract_period(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        return if(buffer.items[cursor] == '.') {
            ExtractedToken { token.Token { .Period }, 1};
        } else {
            null;
        };
    }
    
    fn extract_uint(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        var digit = 0;
        var index = cursor;
        while(index < buffer.items.len) {
            const c = buffer.items[index];
            if(c >= '0' and c <= '9') {
                digit *= 10;
                digit += c - '0';
            } else {
                break;
            }
            index += 1;
        }

        return if(index != cursor) {
            token.Token { .Int { digit }, index - cursor };
        } else {
            null;
        };
    }

    fn extract_ident(buffer: *std.ArrayList(u8), cursor: u16) !?ExtractedToken {
        //TODO: needs additional checks
        return if(cursor < buffer.items - 1) {
            token.Token { .Ident { buffer.items[cursor..] }, buffer.items.len - cursor };
        } else {
            null;
        };
    }
};
