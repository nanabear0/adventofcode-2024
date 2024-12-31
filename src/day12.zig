const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day12.txt"), "\n");

const directions = [4]Point{
    Point{ .x = 0, .y = 1 },
    Point{ .x = 0, .y = -1 },
    Point{ .x = -1, .y = 0 },
    Point{ .x = 1, .y = 0 },
};

fn reduceWalls(walls: *const std.AutoArrayHashMap([2]Point, void)) !usize {
    var processed = std.AutoHashMap([2]Point, void).init(gpa);
    try processed.ensureTotalCapacity(@intCast(walls.count()));
    defer processed.deinit();

    var sides: usize = 0;
    for (walls.keys()) |wall| {
        if (processed.contains(wall)) continue;
        try processed.put(wall, {});

        const adjacentwallDirs: *const [2]Point = if (wall[1].x == 0) directions[2..4] else directions[0..2];

        for (adjacentwallDirs) |dir| {
            var neighbour = .{ wall[0].add(dir), wall[1] };
            while (!processed.contains(neighbour) and walls.contains(neighbour)) {
                try processed.put(neighbour, {});
                neighbour = .{ neighbour[0].add(dir), neighbour[1] };
            }
        }
        sides += 1;
    }

    return sides;
}

fn doThing() !void {
    var map = std.AutoArrayHashMap(Point, u8).init(gpa);
    defer map.deinit();

    var linesIter = std.mem.split(u8, input, "\n");

    var y: isize = 0;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            try map.put(Point{ .x = @intCast(x), .y = y }, char);
        }
    }

    var areaMap = std.AutoHashMap(Point, void).init(gpa);
    var processed = std.AutoHashMap(Point, void).init(gpa);
    try processed.ensureTotalCapacity(@intCast(map.count()));
    var bfs = std.AutoArrayHashMap(Point, void).init(gpa);
    var bfsNext = std.AutoArrayHashMap(Point, void).init(gpa);
    var walls = std.AutoArrayHashMap([2]Point, void).init(gpa);
    defer areaMap.deinit();
    defer bfs.deinit();
    defer bfsNext.deinit();
    defer walls.deinit();
    defer processed.deinit();

    var p1Result: usize = 0;
    var p2Result: usize = 0;
    var mapIter = map.iterator();
    while (mapIter.next()) |mapEntry| {
        const key = mapEntry.key_ptr.*;
        const group = mapEntry.value_ptr.*;
        if (processed.contains(key)) continue;

        areaMap.clearRetainingCapacity();
        bfs.clearRetainingCapacity();
        bfsNext.clearRetainingCapacity();
        walls.clearRetainingCapacity();
        try bfs.put(key, {});
        try areaMap.put(key, {});
        try processed.put(key, {});
        var bok: usize = 0;
        while (bfs.count() > 0) {
            for (bfs.keys()) |current| {
                for (directions) |dir| {
                    const neighbour = current.add(dir);
                    if (areaMap.contains(neighbour)) {
                        continue;
                    } else if (map.get(neighbour) orelse '.' == group) {
                        try bfsNext.put(neighbour, {});
                        try processed.put(neighbour, {});
                        try areaMap.put(neighbour, {});
                    } else {
                        try walls.put([2]Point{ current, dir }, {});
                        bok += 1;
                    }
                }
            }
            std.mem.swap(std.AutoArrayHashMap(Point, void), &bfs, &bfsNext);
            bfsNext.clearRetainingCapacity();
        }
        const reducedWalls = reduceWalls(&walls) catch unreachable;
        p1Result += walls.count() * areaMap.count();
        p2Result += reducedWalls * areaMap.count();
    }

    std.debug.print("part1: {any}\n", .{p1Result});
    std.debug.print("part2: {any}\n", .{p2Result});
}

pub fn day12() void {
    std.debug.print("-day12-\n", .{});
    doThing() catch unreachable;
}
