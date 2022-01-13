const api = switch (cfg.platform) {
    .web => @import("res_web.zig"),
};
const cfg = @import("cfg");
const mem = @import("mem.zig");
const std = @import("std");

pub const Kind = enum {
    shader,
};

pub const FileData = struct {
    id: usize,
    path: []const u8,
    size: usize,
};

pub const Data = union(enum) {
    file: FileData,
    embedded: []const u8,
};

pub const Resource = struct {
    kind: Kind,
    data: Data,
};

pub const Loader = struct {
    ba: mem.BumpAllocator,
    has_allocator: bool,
    file_cache: []?[]const u8,

    pub fn init(comptime res: anytype) !Loader {
        var loader: Loader = undefined;
        const has_files = res.total_file_size > 0;
        if (has_files) {
            const file_ptr_size = @sizeOf(?[]const u8);
            const file_ptr_align = @alignOf(?[]const u8);
            const total_file_size = std.mem.alignForward(res.total_file_size, file_ptr_align);
            const total_size = total_file_size + file_ptr_size * res.total_file_count;
            loader.ba = try mem.BumpAllocator.init(total_size);
            loader.file_cache = try loader.ba.allocator().alloc(?[]const u8, res.total_file_count);
            for (loader.file_cache) |*file| {
                file.* = null;
            }
        }
        loader.has_allocator = has_files;
        return loader;
    }

    pub fn deinit(loader: *Loader) void {
        if (loader.has_allocator) {
            loader.ba.deinit();
        }
    }

    pub fn load(loader: *Loader, comptime resource: Resource) ![]const u8 {
        return switch (resource.data) {
            .embedded => |embedded_data| embedded_data,
            .file => |file_data| try loader.loadFile(file_data),
        };
    }

    fn loadFile(loader: *Loader, file_data: FileData) ![]const u8 {
        if (loader.file_cache[file_data.id]) |file| {
            return file;
        }

        const file = try loader.ba.allocator().alloc(u8, file_data.size);
        try api.loadFile(file_data.path, file);
        loader.file_cache[file_data.id] = file;
        return file;
    }
};
