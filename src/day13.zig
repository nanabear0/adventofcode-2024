const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day13.txt"), "\n");

fn doThing(bigboi: bool) !usize {
    const numRegex = mvzr.compile("[0-9]+").?;
    var numIter = numRegex.iterator(input);
    var tokens: usize = 0;
    var n: usize = 0;
    while (numIter.next()) |amatch| {
        n += 1;
        const a = try std.fmt.parseFloat(f128, amatch.slice);
        const d = try std.fmt.parseFloat(f128, numIter.next().?.slice);
        const b = try std.fmt.parseFloat(f128, numIter.next().?.slice);
        const e = try std.fmt.parseFloat(f128, numIter.next().?.slice);
        var c = try std.fmt.parseFloat(f128, numIter.next().?.slice);
        var f = try std.fmt.parseFloat(f128, numIter.next().?.slice);
        if (bigboi) {
            c += 10000000000000;
            f += 10000000000000;
        }

        const y: f128 = (c / a - f / d) / (b / a - e / d);
        const x: f128 = (c - b * y) / a;
        const roundy = @round(y);
        const roundx = @round(x);
        if (x >= 0 and y >= 0 and
            std.math.approxEqAbs(f128, x, roundx, 0.0000001) and
            std.math.approxEqAbs(f128, y, roundy, 0.0000001))
        {
            tokens += @intFromFloat(roundx * 3 + roundy);
        }
    }
    return tokens;
}

pub export fn day13() void {
    std.debug.print("-day13-\n", .{});
    std.debug.print("part1: {any}\n", .{doThing(false) catch unreachable});
    std.debug.print("part2: {any}\n", .{doThing(true) catch unreachable});
}
