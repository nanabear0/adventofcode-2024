const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day10.txt"), "\n");
const neighbours = [4]Point{
    Point{ .x = 0, .y = 1 },
    Point{ .x = 0, .y = -1 },
    Point{ .x = -1, .y = 0 },
    Point{ .x = 1, .y = 0 },
};

fn part1() !void {
    var map = std.AutoHashMap(Point, u8).init(gpa);
    var zeroes = std.ArrayList(Point).init(gpa);
    defer map.deinit();
    defer zeroes.deinit();

    var linesIter = std.mem.split(u8, input, "\n");

    var y: isize = 0;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            if (char == '.') continue;
            const point = Point{ .x = @intCast(x), .y = y };
            try map.put(point, char - 48);
            if (char - 48 == 0) try zeroes.append(point);
        }
    }

    var p1Result: usize = 0;
    var p2Result: usize = 0;
    for (zeroes.items) |zero| {
        var currents = std.AutoHashMap(Point, usize).init(gpa);
        defer currents.deinit();
        try currents.put(zero, 1);

        var currentValue: u8 = 0;
        while (currents.count() > 0 and currentValue < 9) : (currentValue += 1) {
            var nextTargets = std.AutoHashMap(Point, usize).init(gpa);
            var currentsIter = currents.iterator();
            while (currentsIter.next()) |current| {
                for (neighbours) |neighbourDir| {
                    const neighbour = current.key_ptr.add(neighbourDir);
                    if (map.get(neighbour)) |newTarget| {
                        if (newTarget == currentValue + 1) {
                            const target = try nextTargets.getOrPutValue(neighbour, 0);
                            target.value_ptr.* += current.value_ptr.*;
                        }
                    }
                }
            }
            currents.deinit();
            currents = nextTargets;
        }
        if (currentValue == 9) {
            p1Result += currents.count();
            var currentsIter = currents.valueIterator();
            while (currentsIter.next()) |value| p2Result += value.*;
        }
    }

    std.debug.print("part1: {any}\n", .{p1Result});
    std.debug.print("part2: {any}\n", .{p2Result});
}

fn part2() !void {
    std.debug.print("part2: {any}\n", .{0});
}

pub export fn day10() void {
    std.debug.print("-day10-\n", .{});

    part1() catch unreachable;
    part2() catch unreachable;
}
