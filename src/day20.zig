const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day20.txt"), "\n");

const CheatsInvolvingBlockage = [_][2]Point{
    [2]Point{ CardinalDirections[0], CardinalDirections[2] },
    [2]Point{ CardinalDirections[1], CardinalDirections[3] },

    [2]Point{ CardinalDirections[0], CardinalDirections[1] },
    [2]Point{ CardinalDirections[1], CardinalDirections[2] },
    [2]Point{ CardinalDirections[2], CardinalDirections[3] },
    [2]Point{ CardinalDirections[3], CardinalDirections[0] },
};

const MapEntry = enum {
    Free,
    Blocked,
};

const MovementCost = struct {
    point: Point,
    cost: isize,
    pub fn move(self: *const MovementCost, dir: Point) MovementCost {
        return MovementCost{ .point = self.point.add(dir), .cost = self.cost + 1 };
    }
    pub fn comp(_: void, a: MovementCost, b: MovementCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

fn findShortestPathBetweenTwoPoints(start: Point, end: Point, map: *std.AutoHashMap(Point, MapEntry)) !isize {
    var visited = std.AutoHashMap(Point, isize).init(gpa);
    var frontier = std.PriorityQueue(MovementCost, void, MovementCost.comp).init(gpa, {});
    var bestPathEndings = std.AutoHashMap(MovementCost, void).init(gpa);
    defer visited.deinit();
    defer frontier.deinit();
    defer bestPathEndings.deinit();

    try visited.put(start, 0);
    try frontier.add(MovementCost{ .point = start, .cost = 0 });

    return while (frontier.removeOrNull()) |*current| {
        if (current.point.equals(end)) {
            break current.cost;
        }
        for (CardinalDirections) |dir| {
            const option = current.move(dir);
            if (map.get(option.point) != .Free) continue;
            if ((visited.get(option.point) orelse std.math.maxInt(isize)) < option.cost) continue;

            try frontier.add(option);
            try visited.put(option.point, option.cost);
        }
    } else -1;
}

fn part1() !void {
    var blockages = std.AutoHashMap(Point, void).init(gpa);
    var map = std.AutoHashMap(Point, MapEntry).init(gpa);
    var start: Point = Point{ .x = 0, .y = 0 };
    var end: Point = Point{ .x = 0, .y = 0 };
    defer map.deinit();
    defer blockages.deinit();

    var inputIter = std.mem.splitSequence(u8, input, "\n");
    var y: isize = 0;
    while (inputIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '.' => try map.put(point, .Free),
                '#' => {
                    try map.put(point, .Blocked);
                    try blockages.put(point, {});
                },
                'S' => {
                    start = point;
                    try map.put(point, .Free);
                },
                'E' => {
                    end = point;
                    try map.put(point, .Free);
                },
                else => unreachable,
            }
        }
    }

    var shortestPathCache = std.AutoHashMap([2]Point, isize).init(gpa);
    defer shortestPathCache.deinit();
    var timeSavers = std.AutoHashMap(usize, usize).init(gpa);
    defer timeSavers.deinit();

    var blockagesIter = blockages.keyIterator();
    while (blockagesIter.next()) |blockage| {
        for (CheatsInvolvingBlockage) |cheatDir| {
            const cheatTerminals = [2]Point{ blockage.add(cheatDir[0]), blockage.add(cheatDir[1]) };

            if (!shortestPathCache.contains(cheatTerminals)) {
                if (map.get(cheatTerminals[0]) != .Free or map.get(cheatTerminals[0]) != .Free) continue;
                try shortestPathCache.put(cheatTerminals, try findShortestPathBetweenTwoPoints(cheatTerminals[0], cheatTerminals[1], &map));
            }

            if (shortestPathCache.get(cheatTerminals)) |distance| {
                // std.debug.print("shortest path between {any} and {any} is {d}\n", .{ cheatTerminals[0], cheatTerminals[1], distance });
                const timeSave = distance - 2;
                if (timeSave > 0) {
                    const entry = try timeSavers.getOrPutValue(@intCast(timeSave), 0);
                    entry.value_ptr.* += 1;
                }
            }
        }
    }

    var result: usize = 0;
    var timeSaversIter = timeSavers.iterator();
    while (timeSaversIter.next()) |timeSave| {
        if (timeSave.key_ptr.* >= 100) {
            result += timeSave.value_ptr.*;
        }
        // std.debug.print("There are {d} cheats that save {d} picoseconds.\n", .{ timeSave.value_ptr.*, timeSave.key_ptr.* });
    }

    std.debug.print("part1: {d}\n", .{result});
}

fn part2() !void {
    std.debug.print("part2: {d}\n", .{0});
}

pub export fn day20() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
