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
const day11 = @import("./day11.zig").day11;
const day12 = @import("./day12.zig").day12;
const day13 = @import("./day13.zig").day13;
const day14 = @import("./day14.zig").day14;
const day15 = @import("./day15.zig").day15;
const day16 = @import("./day16.zig").day16;
const day17 = @import("./day17.zig").day17;
const day18 = @import("./day18.zig").day18;
const day19 = @import("./day19.zig").day19;
const day20 = @import("./day20.zig").day20;
const day21 = @import("./day21.zig").day21;
const day22 = @import("./day22.zig").day22;
const day23 = @import("./day23.zig").day23;
const day24 = @import("./day24.zig").day24;
const day25 = @import("./day25.zig").day25;

fn withTimeReport(comptime do: fn () void) void {
    var timer = std.time.Timer.start() catch unreachable;
    do();
    const elapsed2: f64 = @floatFromInt(timer.read());
    std.debug.print("Time: {d:.3}ms\n\n", .{
        elapsed2 / std.time.ns_per_ms,
    });
}

pub fn main() !void {
    var timer = std.time.Timer.start() catch unreachable;
    withTimeReport(day01);
    withTimeReport(day02);
    withTimeReport(day03);
    withTimeReport(day04);
    withTimeReport(day05);
    withTimeReport(day06);
    withTimeReport(day07);
    withTimeReport(day08);
    withTimeReport(day09);
    withTimeReport(day10);
    withTimeReport(day11);
    withTimeReport(day12);
    withTimeReport(day13);
    withTimeReport(day14);
    withTimeReport(day15);
    withTimeReport(day16);
    withTimeReport(day17);
    withTimeReport(day18);
    withTimeReport(day19);
    withTimeReport(day20);
    withTimeReport(day21);
    withTimeReport(day22);
    withTimeReport(day23);
    withTimeReport(day24);
    withTimeReport(day25);
    const elapsed2: f64 = @floatFromInt(timer.read());
    std.debug.print("Total Time: {d:.3}ms\n\n", .{
        elapsed2 / std.time.ns_per_ms,
    });
}
