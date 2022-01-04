const app = @import("app.zig");
const cfg = @import("cfg");
const main = @import("main.zig");
const math = @import("math.zig");
const std = @import("std");

const js = struct {
    const CanvasId = u32;
    const DomHighResTimeStamp = f64;

    extern fn setWindowTitle(wasm_id: main.WasmId, title_ptr: [*]const u8, title_len: usize) void;
    extern fn createCanvas(wasm_id: main.WasmId, width: u32, height: u32) CanvasId;
    extern fn destroyCanvas(canvas_id: CanvasId) void;
    extern fn now() DomHighResTimeStamp;
};

pub const Window = struct {
    size: math.V2u32,
    id: js.CanvasId,

    pub fn init(window: *Window, size: math.V2u32, comptime desc: app.WindowDesc) !void {
        if (desc.name.len > 0) {
            js.setWindowTitle(main.wasm_id, desc.name.ptr, desc.name.len);
        }
        window.* = .{
            .id = js.createCanvas(main.wasm_id, size.x, size.y),
            .size = size,
        };
    }

    pub fn deinit(window: *Window) void {
        const empty: []const u8 = &.{};
        js.setWindowTitle(main.wasm_id, empty.ptr, empty.len);
        js.destroyCanvas(window.id);
    }
};

// matches the public api of std.time.Timer
pub const Timer = struct {
    start_time: js.DomHighResTimeStamp,

    pub fn start() !Timer {
        return Timer{ .start_time = js.now() };
    }

    pub fn read(self: Timer) u64 {
        return timeStampToNs(js.now() - self.start_time);
    }

    pub fn reset(self: *Timer) void {
        self.start_time = js.now();
    }

    pub fn lap(self: *Timer) u64 {
        var now = js.now();
        var lap_time = self.timeStampToNs(now - self.start_time);
        self.start_time = now;
        return lap_time;
    }

    fn timeStampToNs(duration: js.DomHighResTimeStamp) u64 {
        return @floatToInt(u64, duration * 1000000.0);
    }
};
