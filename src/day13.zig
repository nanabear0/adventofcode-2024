const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day13.txt"), "\n");

fn doThing() !void {
    const numRegex = mvzr.compile("[0-9]+").?;
    var numIter = numRegex.iterator(input);
    var tokens: usize = 0;
    var n: usize = 0;
    while (numIter.next()) |amatch| {
        n += 1;
        const a = try std.fmt.parseFloat(f64, amatch.slice);
        const d = try std.fmt.parseFloat(f64, numIter.next().?.slice);
        const b = try std.fmt.parseFloat(f64, numIter.next().?.slice);
        const e = try std.fmt.parseFloat(f64, numIter.next().?.slice);
        const c = try std.fmt.parseFloat(f64, numIter.next().?.slice);
        const f = try std.fmt.parseFloat(f64, numIter.next().?.slice);

        const y: f64 = (c / a - f / d) / (b / a - e / d);
        const x: f64 = (c - b * y) / a;
        const roundy = @round(y);
        const roundx = @round(x);
        if (x >= 0 and y >= 0 and
            std.math.approxEqAbs(f64, x, roundx, 0.0001) and
            std.math.approxEqAbs(f64, y, roundy, 0.0001))
        {
            std.debug.print("{d}. one needs {d} A press, {d} B press. x{d} == x{d}, y{d} == y{d}\n", .{ n, roundx, roundy, c, a * roundx + b * roundy, f, d * roundx + e * roundy });
            tokens += @intFromFloat(roundx * 3 + roundy);
        }
    }
    std.debug.print("part1: {any}\n", .{tokens});
}

pub export fn day13() void {
    std.debug.print("-day13-\n", .{});
    doThing() catch unreachable;
}
