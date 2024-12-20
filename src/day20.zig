const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day20.txt"), "\n");

fn doPart(cheatDuration: isize, path: []Point) usize {
    var result: usize = 0;
    for (0..path.len - 100) |i| {
        for (i + 100..path.len) |j| {
            const distance = path[j].distanceTo(path[i]);
            if (distance > cheatDuration) continue;
            if (j - i - distance >= 100) result += 1;
        }
    }

    return result;
}

fn doThing() !void {
    var freeze = std.AutoHashMap(Point, void).init(gpa);
    var start: Point = Point{ .x = 0, .y = 0 };
    var end: Point = Point{ .x = 0, .y = 0 };
    defer freeze.deinit();

    var y: isize = 0;
    var inputIter = std.mem.splitSequence(u8, input, "\n");
    while (inputIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '.' => {
                    try freeze.put(point, {});
                },
                'S' => {
                    start = point;
                    try freeze.put(point, {});
                },
                'E' => {
                    end = point;
                    try freeze.put(point, {});
                },
                else => {},
            }
        }
    }

    var path = std.AutoArrayHashMap(Point, void).init(gpa);
    defer path.deinit();
    try path.put(start, {});
    var curr = start;
    step: while (!curr.equals(end)) {
        for (CardinalDirections) |dir| {
            const next = curr.add(dir);
            if (!freeze.contains(next)) continue;
            if (path.contains(next)) continue;

            try path.put(next, {});
            curr = next;
            continue :step;
        }
        break;
    }

    std.debug.print("part1: {}\n", .{doPart(2, path.keys())});
    std.debug.print("part2: {}\n", .{doPart(20, path.keys())});
}

pub export fn day20() void {
    doThing() catch unreachable;
}
