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

fn doThing() !void {
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
    var currents = std.AutoArrayHashMap(Point, usize).init(gpa);
    var nextTargets = std.AutoArrayHashMap(Point, usize).init(gpa);
    defer nextTargets.deinit();
    defer currents.deinit();
    for (zeroes.items) |zero| {
        defer currents.clearRetainingCapacity();
        defer nextTargets.clearRetainingCapacity();
        try currents.put(zero, 1);

        var currentValue: u8 = 0;
        while (currents.count() > 0 and currentValue < 9) : (currentValue += 1) {
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
            std.mem.swap(std.AutoArrayHashMap(Point, usize), &currents, &nextTargets);
            nextTargets.clearRetainingCapacity();
        }
        if (currentValue == 9) {
            p1Result += currents.count();
            for (currents.values()) |value| p2Result += value;
        }
    }

    std.debug.print("part1: {any}\n", .{p1Result});
    std.debug.print("part2: {any}\n", .{p2Result});
}

pub fn day10() void {
    std.debug.print("-day10-\n", .{});

    doThing() catch unreachable;
}
