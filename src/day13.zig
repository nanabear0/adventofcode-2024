const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day13.txt"), "\n");

fn doThing(bigboi: bool) !isize {
    const numRegex = mvzr.compile("[0-9]+").?;
    var numIter = numRegex.iterator(input);
    var tokens: isize = 0;
    var n: isize = 0;
    while (numIter.next()) |amatch| {
        n += 1;
        const a = try std.fmt.parseInt(isize, amatch.slice, 10);
        const d = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        const b = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        const e = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        var c = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        var f = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        if (bigboi) {
            c += 10000000000000;
            f += 10000000000000;
        }

        const ynum = f * a - c * d;
        const ydenom = a * e - b * d;
        if (@mod(ynum, ydenom) != 0) continue;
        const y = @divExact(ynum, ydenom);

        const xnum = c - b * y;
        const xdenom = a;
        if (@mod(xnum, xdenom) != 0) continue;
        const x = @divExact(xnum, xdenom);

        if (x >= 0 and y >= 0) {
            tokens += x * 3 + y;
        }
    }
    return tokens;
}

pub export fn day13() void {
    std.debug.print("-day13-\n", .{});
    std.debug.print("part1: {any}\n", .{doThing(false) catch unreachable});
    std.debug.print("part2: {any}\n", .{doThing(true) catch unreachable});
}
