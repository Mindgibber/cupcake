const cfg = @import("cfg");
const std = @import("std");

pub usingnamespace switch (cfg.gfx_backend) {
    .webgpu => @import("gfx_webgpu.zig"),
};

pub const DeviceReadyCb = fn () void;
pub const DeviceErrorCb = fn (err: anyerror) void;

pub const PipelineLayoutDesc = struct {
    label: []const u8 = "",
};

pub const ConstantEntry = struct {
    key: []const u8,
    value: u64,
};

pub const VertexStepMode = enum {
    vertex,
    instance,
};

pub const VertexAttribute = struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const VertexBufferLayout = struct {
    array_stride: u64,
    step_mode: VertexStepMode,
    attributes: []const VertexAttribute,
};

pub const VertexState = struct {
    entry_point: []const u8,
    constants: ?[]const ConstantEntry = null,
    buffers: []const VertexBufferLayout,
};

pub const PrimitiveTopology = enum {
    point_list,
    line_list,
    line_strip,
    triangle_list,
    triangle_strip,
};

pub const IndexFormat = enum {
    @"undefined",
    uint16,
    uint32,
};

pub const FrontFace = enum {
    ccw,
    cw,
};

pub const CullMode = enum {
    none,
    front,
    back,
};

pub const PrimitiveState = struct {
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: IndexFormat = .@"undefined",
    front_face: FrontFace = .ccw,
    cull_mode: CullMode = .back,
};

pub const CompareFunction = enum {
    @"undefined",
    never,
    less,
    less_equal,
    greater,
    greater_equal,
    equal,
    not_equal,
    always,
};

pub const StencilOperation = enum {
    keep,
    zero,
    replace,
    invert,
    increment_clamp,
    decrement_clamp,
    increment_wrap,
    decrement_wrap,
};

pub const StencilFaceState = struct {
    compare: CompareFunction,
    fail_op: StencilOperation,
    depth_fail_op: StencilOperation,
    pass_op: StencilOperation,
};

pub const DepthStencilState = struct {
    format: TextureFormat,
    depth_write_enabled: bool,
    depth_compare: CompareFunction,
    stencil_front: StencilFaceState,
    stencil_back: StencilFaceState,
    stencil_read_mask: u32,
    stencil_write_mask: u32,
    depth_bias: i32,
    depth_bias_slope_scale: f32,
    depth_bias_clamp: f32,
};

pub const MultisampleState = struct {
    count: u32 = 1,
    mask: u32 = std.math.boolMask(u32, true),
    alpha_to_coverage_enabled: bool = false,
};

pub const BlendOperation = enum {
    add,
    subtract,
    reverse_substract,
    min,
    max,
};

pub const BlendFactor = enum {
    zero,
    one,
    src,
    one_minus_src,
    src_alpha,
    one_minus_src_alpha,
    dst,
    one_minus_dst,
    dst_alpha,
    one_minus_dst_alpha,
    src_alpha_saturated,
    constant,
    one_minus_constant,
};

pub const BlendComponent = struct {
    operation: BlendOperation = .add,
    src_factor: BlendFactor = .one,
    dst_factor: BlendFactor = .zero,
};

pub const BlendState = struct {
    color: BlendComponent = .{},
    alpha: BlendComponent = .{},
};

pub const ColorWriteMask = packed struct {
    red: bool = true,
    green: bool = true,
    blue: bool = true,
    alpha: bool = true,
};

pub const ColorTargetState = struct {
    format: TextureFormat,
    blend: BlendState = .{},
    write_mask: ColorWriteMask = .{},
};

pub const FragmentState = struct {
    entry_point: []const u8,
    constants: ?[]const ConstantEntry = null,
    targets: []const ColorTargetState,
};

pub const RenderPipelineDesc = struct {
    label: []const u8 = "",
    vertex: VertexState,
    primitive: PrimitiveState = .{},
    depth_stencil: ?DepthStencilState = null,
    multisample: MultisampleState = .{},
    fragment: ?FragmentState = null,
};

pub const VertexFormat = enum {
    @"undefined",
    uint8x2,
    uint8x4,
    sint8x2,
    sint8x4,
    unorm8x2,
    unorm8x4,
    snorm8x2,
    snorm8x4,
    uint16x2,
    uint16x4,
    sint16x2,
    sint16x4,
    unorm16x2,
    unorm16x4,
    snorm16x2,
    snorm16x4,
    float16x2,
    float16x4,
    float32,
    float32x2,
    float32x3,
    float32x4,
    uint32,
    uint32x2,
    uint32x3,
    uint32x4,
    sint32,
    sint32x2,
    sint32x3,
    sint32x4,
};

pub const TextureFormat = enum {
    @"undefined",
    r8unorm,
    r8snorm,
    r8uint,
    r8sint,
    r16uint,
    r16sint,
    r16float,
    rg8unorm,
    rg8snorm,
    rg8uint,
    rg8sint,
    r32float,
    r32uint,
    r32sint,
    rg16uint,
    rg16sint,
    rg16float,
    rgba8unorm,
    rgba8unorm_srgb,
    rgba8snorm,
    rgba8uint,
    rgba8sint,
    bgra8unorm,
    bgra8unorm_srgb,
    rgb10a2unorm,
    rg11b10ufloat,
    rgb9e5ufloat,
    rg32float,
    rg32uint,
    rg32sint,
    rgba16uint,
    rgba16sint,
    rgba16float,
    rgba32float,
    rgba32uint,
    rgba32sint,
    stencil8,
    depth16unorm,
    depth24plus,
    depth24plus_stencil8,
    depth24unorm_stencil8,
    depth32float,
    depth32float_stencil8,
    bc1_rgba_unorm,
    bc1_rgba_unorm_srgb,
    bc2_rgba_unorm,
    bc2_rgba_unorm_srgb,
    bc3_rgba_unorm,
    bc3_rgba_unorm_srgb,
    bc4_r_unorm,
    bc4_r_snorm,
    bc5_rg_unorm,
    bc5_rg_snorm,
    bc6h_rgb_ufloat,
    bc6h_rgb_float,
    bc7_rgba_unorm,
    bc7_rgba_unorm_srgb,
    etc2_rgb8unorm,
    etc2_rgb8unorm_srgb,
    etc2_rgb8a1unorm,
    etc2_rgb8a1unorm_srgb,
    etc2_rgba8unorm,
    etc2_rgba8unorm_srgb,
    eac_r11unorm,
    eac_r11snorm,
    eac_rg11unorm,
    eac_rg11snorm,
    astc_4x4_unorm,
    astc_4x4_unorm_srgb,
    astc_5x4_unorm,
    astc_5x4_unorm_srgb,
    astc_5x5_unorm,
    astc_5x5_unorm_srgb,
    astc_6x5_unorm,
    astc_6x5_unorm_srgb,
    astc_6x6_unorm,
    astc_6x6_unorm_srgb,
    astc_8x5_unorm,
    astc_8x5_unorm_srgb,
    astc_8x6_unorm,
    astc_8x6_unorm_srgb,
    astc_8x8_unorm,
    astc_8x8_unorm_srgb,
    astc_10x5_unorm,
    astc_10x5_unorm_srgb,
    astc_10x6_unorm,
    astc_10x6_unorm_srgb,
    astc_10x8_unorm,
    astc_10x8_unorm_srgb,
    astc_10x10_unorm,
    astc_10x10_unorm_srgb,
    astc_12x10_unorm,
    astc_12x10_unorm_srgb,
    astc_12x12_unorm,
    astc_12x12_unorm_srgb,
};
