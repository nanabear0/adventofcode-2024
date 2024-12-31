const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day07.txt"), "\n");

fn concat(x: usize, y: usize) !usize {
    var concatBuffer: [40]u8 = undefined;
    return try std.fmt.parseInt(usize, try std.fmt.bufPrint(&concatBuffer, "{d}{d}", .{ x, y }), 10);
}

fn validate(sum: usize, runningSum: usize, values: []usize, allowThirdOp: bool) !bool {
    if (runningSum > sum) return false;
    if (values.len == 0) return sum == runningSum;
    if (try validate(sum, runningSum + values[0], values[1..], allowThirdOp)) return true;
    if (try validate(sum, runningSum * values[0], values[1..], allowThirdOp)) return true;
    if (allowThirdOp and
        try validate(sum, (try concat(runningSum, values[0])), values[1..], allowThirdOp)) return true;
    return false;
}

fn doThing() !void {
    var linesIter = std.mem.split(u8, input, "\n");
    var p1Result: usize = 0;
    var p2Result: usize = 0;
    while (linesIter.next()) |line| {
        var partsIter = std.mem.split(u8, line, ": ");
        const sum = try std.fmt.parseInt(usize, partsIter.next().?, 10);
        var valuesIter = std.mem.split(u8, partsIter.next().?, " ");
        var values = std.ArrayList(usize).init(gpa);
        defer values.deinit();
        while (valuesIter.next()) |valueStr| {
            try values.append(try std.fmt.parseInt(usize, valueStr, 10));
        }
        if (try validate(sum, values.items[0], values.items[1..], false)) p1Result += sum;
        if (try validate(sum, values.items[0], values.items[1..], true)) p2Result += sum;
    }

    std.debug.print("part1: {d}\n", .{p1Result});
    std.debug.print("part2: {d}\n", .{p2Result});
}

pub fn day07() void {
    std.debug.print("-day07-\n", .{});
    doThing() catch unreachable;
}
