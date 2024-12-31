const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day08.txt"), "\n");

fn doThing(repeatingAntiNodes: bool) !usize {
    var linesIter = std.mem.split(u8, input, "\n");
    var antennaLocations = std.AutoHashMap(u8, std.ArrayList(Point)).init(gpa);
    defer antennaLocations.deinit();
    defer {
        var antIter = antennaLocations.valueIterator();
        while (antIter.next()) |set| set.deinit();
    }

    var xMax: isize = 0;
    var yMax: isize = 0;
    var y: isize = 0;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            if (char == '.') continue;

            const point = Point{ .x = @intCast(x), .y = y };
            var entry = try antennaLocations.getOrPut(char);
            if (!entry.found_existing) entry.value_ptr.* = std.ArrayList(Point).init(gpa);
            try entry.value_ptr.append(point);
        }
        xMax = @as(isize, @intCast(line.len)) - 1;
    }
    yMax = y - 1;
    const boundaries = .{ Point{ .x = 0, .y = 0 }, Point{ .x = xMax, .y = yMax } };

    var antiNodes = std.AutoHashMap(Point, void).init(gpa);
    defer antiNodes.deinit();
    var antennasIter = antennaLocations.valueIterator();
    while (antennasIter.next()) |antennas| {
        for (antennas.items, 0..) |ant1, i| {
            if (repeatingAntiNodes) try antiNodes.put(ant1, {});
            for (antennas.items[i + 1 ..]) |ant2| {
                const vec = ant2.subtract(ant1);
                var a1 = ant2.add(vec);
                while (a1.containedBy(boundaries[0], boundaries[1])) : (a1 = a1.add(vec)) {
                    try antiNodes.put(a1, {});
                    if (!repeatingAntiNodes) break;
                }
                var a2 = ant1.subtract(vec);
                while (a2.containedBy(boundaries[0], boundaries[1])) : (a2 = a2.subtract(vec)) {
                    try antiNodes.put(a2, {});
                    if (!repeatingAntiNodes) break;
                }
            }
        }
    }
    return antiNodes.count();
}

pub fn day08() void {
    std.debug.print("-day08-\n", .{});

    std.debug.print("part1: {d}\n", .{doThing(false) catch unreachable});
    std.debug.print("part2: {d}\n", .{doThing(true) catch unreachable});
}
