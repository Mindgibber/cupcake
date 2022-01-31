const cc = @import("cupcake");
const res = @import("res");

const Example = struct {
    window: cc.app.Window,
    instance: cc.gfx.Instance,
    adapter: cc.gfx.Adapter,
    device: cc.gfx.Device,
    surface: cc.gfx.Surface,
    swapchain: cc.gfx.Swapchain,
    render_pipeline: cc.gfx.RenderPipeline,
};

var example: Example = undefined;

pub fn init() !void {
    example.window = try cc.app.Window.init(cc.math.V2u32.make(800, 600), .{});
    example.instance = try cc.gfx.Instance.init();
    example.surface = try example.instance.createSurface(&example.window, .{});
    example.adapter = try example.instance.requestAdapter(&example.surface, .{});
    example.device = try example.adapter.requestDevice(.{});

    const swapchain_format = comptime cc.gfx.Surface.getPreferredFormat();

    example.swapchain = try example.device.createSwapchain(
        &example.surface,
        example.window.size,
        .{ .format = swapchain_format },
    );

    const vert_shader_res = try cc.res.load(res.triangle_vert_shader, .{});
    var vert_shader = try example.device.createShader(vert_shader_res);
    defer vert_shader.destroy();

    const frag_shader_res = try cc.res.load(res.triangle_frag_shader, .{});
    var frag_shader = try example.device.createShader(frag_shader_res);
    defer frag_shader.destroy();

    var pipeline_layout = try example.device.createPipelineLayout(&.{}, .{});
    defer pipeline_layout.destroy();

    example.render_pipeline = try example.device.createRenderPipeline(
        &pipeline_layout,
        &vert_shader,
        &frag_shader,
        .{
            .vertex = .{
                .entry_point = "vs_main",
                .buffers = &.{},
            },
            .fragment = .{
                .entry_point = "fs_main",
                .targets = &.{.{ .format = swapchain_format }},
            },
        },
    );
}

pub fn update() !void {
    var swapchain_view = try example.swapchain.getCurrentTextureView();
    defer swapchain_view.destroy();

    var command_encoder = example.device.createCommandEncoder();
    var render_pass = command_encoder.beginRenderPass(
        .{
            .color_views = &.{swapchain_view},
        },
        .{
            .color_attachments = &.{
                .{
                    .load_value = cc.gfx.default_clear_color,
                    .store_op = .store,
                },
            },
        },
    );
    render_pass.setPipeline(&example.render_pipeline);
    render_pass.draw(3, 1, 0, 0);
    render_pass.end();

    var queue = example.device.getQueue();
    queue.submit(&.{command_encoder.finish(.{})});
    example.swapchain.present();
}

pub fn deinit() !void {
    example.render_pipeline.destroy();
    example.swapchain.destroy();
    example.device.destroy();
    example.adapter.destroy();
    example.surface.destroy();
    example.instance.deinit();
    example.window.deinit();
}
