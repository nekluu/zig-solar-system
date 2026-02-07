const std = @import("std");

const rl = @import("raylib");
const Vector3 = rl.Vector3;
const Color = rl.Color;
const G = @import("main.zig").G;

const BodyType = enum {
    star,
    planet,
    moon,
    asteroid,
};
const Distance = struct {
    radius: f32,
    x: f32,
    y: f32,
    z: f32,
};
pub const CelestialBody = struct {
    type: BodyType,
    name: []const u8,

    pos: Vector3,
    velo: Vector3,
    acc: Vector3,
    mass: f64,

    radius: f32,
    color: Color,

    tiles: std.ArrayList(Vector3),
    pub fn applyGravity(self: *CelestialBody, sun: *CelestialBody, dt: f32) void {
        const distance = CelestialBody.take_distance(self, sun); //r²
        //      m1.m2
        //F = G ────
        //        2
        //       r
        const force = G * self.mass * sun.mass / (distance.radius * distance.radius);

        //F = m.a => a = F.m
        const a = force / self.mass;

        self.acc.x = @floatCast(distance.x / distance.radius * a);
        self.acc.y = @floatCast(distance.y / distance.radius * a);
        self.acc.z = @floatCast(distance.z / distance.radius * a);

        // v = v + a * dt
        self.velo.x += self.acc.x * dt;
        self.velo.y += self.acc.y * dt;
        self.velo.z += self.acc.z * dt;
    }
    pub fn update(self: *CelestialBody, dt: f32, gpa: std.mem.Allocator) !void {
        try self.tiles.append(gpa, self.pos);
        self.pos.x += self.velo.x * dt;
        self.pos.y += self.velo.y * dt;
        self.pos.z += self.velo.z * dt;
    }
    fn take_distance(self: *CelestialBody, m2: *CelestialBody) Distance {
        const dx = m2.pos.x - self.pos.x;
        const dy = m2.pos.y - self.pos.y;
        const dz = m2.pos.z - self.pos.z;
        const radius = @sqrt((dx * dx + dy * dy + dz * dz));
        return Distance{ .radius = radius, .x = dx, .y = dy, .z = dz };
    }
    pub fn draw_tiles(self: *CelestialBody, d3: anytype) void {
        for (self.tiles.items, 0..) |tile, i| {
            if (i > 0) {
                d3.drawLine3D(self.tiles.items[i - 1], tile, .gray);
            }
        }

        if (self.tiles.items.len > 0) {
            const last_pos = self.tiles.items[self.tiles.items.len - 1];
            d3.drawLine3D(last_pos, self.pos, rl.Color.light_gray);
        }
    }
};
