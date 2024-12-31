const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day18.txt"), "\n");
const MapEntry = enum {
    Free,
    Fallen,
};

fn doThing(gridMax: usize, take: usize) !isize {
    var blockages = std.AutoHashMap(Point, void).init(gpa);
    try blockages.ensureTotalCapacity(@intCast(take));
    defer blockages.deinit();
    var lineIter = std.mem.splitScalar(u8, input, '\n');
    var i: usize = 0;
    while (lineIter.next()) |line| : (i += 1) {
        if (i >= take) continue;

        var xys = std.mem.splitScalar(u8, line, ',');
        try blockages.put(Point{ .x = try std.fmt.parseInt(isize, xys.next().?, 10), .y = try std.fmt.parseInt(isize, xys.next().?, 10) }, {});
    }

    const start = Point{ .x = 0, .y = 0 };
    const target = Point{ .x = @intCast(gridMax), .y = @intCast(gridMax) };
    var dist: isize = 0;
    var visited = std.AutoHashMap(Point, isize).init(gpa);
    var frontier = std.AutoHashMap(Point, void).init(gpa);
    var nextFrontier = std.AutoHashMap(Point, void).init(gpa);
    try visited.ensureTotalCapacity(1024);
    defer visited.deinit();
    defer frontier.deinit();
    defer nextFrontier.deinit();

    try visited.put(start, 0);
    try frontier.put(start, {});
    return main: while (frontier.count() > 0) {
        dist += 1;
        var frontierIter = frontier.keyIterator();
        while (frontierIter.next()) |current| {
            for (CardinalDirections) |dir| {
                const next = current.add(dir);
                if (blockages.contains(next)) continue;
                if (!next.containedBy(start, target)) continue;
                if ((visited.get(next) orelse std.math.maxInt(isize)) < dist) continue;
                if (next.equals(target)) break :main dist;

                try nextFrontier.put(next, {});
                try visited.put(next, dist);
            }
        }
        std.mem.swap(std.AutoHashMap(Point, void), &frontier, &nextFrontier);
        nextFrontier.clearRetainingCapacity();
    } else -1;
}

fn part1() !void {
    std.debug.print("part1: {d}\n", .{try doThing(70, 1024)});
}

fn part2() !void {
    var start: usize = 0;
    var end: usize = 3840;
    var result: usize = 0;
    while (start <= end) {
        const middle = start + (end - start) / 2;
        if (try doThing(70, middle) == -1) {
            result = middle;
            end = middle - 1;
        } else {
            start = middle + 1;
        }
    }
    std.debug.print("part2: {d}\n", .{result});
}

pub fn day18() void {
    std.debug.print("-day18-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
