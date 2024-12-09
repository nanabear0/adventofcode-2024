const std = @import("std");

const day01 = @import("./day01.zig").day01;
const day02 = @import("./day02.zig").day02;
const day03 = @import("./day03.zig").day03;
const day04 = @import("./day04.zig").day04;
const day05 = @import("./day05.zig").day05;
const day06 = @import("./day06.zig").day06;
const day07 = @import("./day07.zig").day07;
const day08 = @import("./day08.zig").day08;
const day09 = @import("./day09.zig").day09;
const day10 = @import("./day10.zig").day10;

pub fn main() void {
    var timer = std.time.Timer.start() catch unreachable;
    {
        // day01();
        // day02();
        // day03();
        // day04();
        // day05();
        // day06();
        // day07();
        // day08();
        // day09();
        day10();
    }
    const elapsed2: f64 = @floatFromInt(timer.read());
    std.debug.print("Time: {d:.3}ms\n", .{
        elapsed2 / std.time.ns_per_ms,
    });
}
