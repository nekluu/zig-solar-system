const std = @import("std");

const rl = @import("raylib");
const Color = rl.Color;
const Vector3 = rl.Vector3;

const CelestialBody = @import("gravity.zig").CelestialBody;

pub const G: comptime_float = 2000.0;
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var vec = std.ArrayList(Vector3){};
    defer vec.deinit(allocator);
    try vec.append(allocator, Vector3.init(10, 10, 10));
    var sun = CelestialBody{
        .type = .star,
        .name = "sun",
        .pos = Vector3.zero(),
        .velo = Vector3.zero(),
        .acc = Vector3.zero(),
        .mass = 100.0, //TODO
        .radius = 20.0, //TODO
        .color = rl.Color.yellow,
        .tiles = std.ArrayList(Vector3){},
    };
    var earth = CelestialBody{
        .type = .planet,
        .name = "Earth",
        .pos = Vector3.init(100, 0, 0),
        .velo = Vector3.init(0, 0, -40),
        .acc = Vector3.zero(),
        .mass = 0.1, //TODO
        .radius = 4.0, //TODO
        .color = rl.Color.blue,
        .tiles = std.ArrayList(Vector3){},
    };
    rl.initWindow(1600, 800, "G");
    defer rl.closeWindow();

    var camera = rl.Camera3D{
        .position = Vector3.init(0, 100, 300),
        .target = sun.pos,
        .up = Vector3.init(0, 1, 0),
        .fovy = 45.0,
        .projection = .perspective,
    };

    rl.setTargetFPS(60);
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(.black);
        const dt = rl.getFrameTime();
        earth.applyGravity(&sun, dt);
        try earth.update(dt, allocator);
        camera.begin();

        rl.drawSphere(sun.pos, sun.radius, sun.color);
        rl.drawSphere(earth.pos, earth.radius, earth.color);
        earth.draw_tiles(rl);

        camera.end();
        rl.endDrawing();
    }
}
fn e(buffer: []u8) ![]u8 {
    const a = try std.fmt.bufPrint(buffer, "{},{}", .{"hello,world"});
    return a;
}
