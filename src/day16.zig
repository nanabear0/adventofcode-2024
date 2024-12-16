const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day16.txt"), "\n");

const MapEntry = enum {
    Free,
    Blocked,
};

const MovementCost = struct {
    vec: Vector,
    cost: isize,
    pub fn move(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.move(), .cost = self.cost + 1 };
    }
    pub fn turnRight(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.turnRight(), .cost = self.cost + 1000 };
    }
    pub fn turnLeft(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.turnLeft(), .cost = self.cost + 1000 };
    }
    pub fn moveReverse(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.moveReverse(), .cost = self.cost - 1 };
    }
    pub fn turnRightReverse(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.turnLeft(), .cost = self.cost - 1000 };
    }
    pub fn turnLeftReverse(self: *const MovementCost) MovementCost {
        return MovementCost{ .vec = self.vec.turnRight(), .cost = self.cost - 1000 };
    }
    pub fn comp(_: void, a: MovementCost, b: MovementCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

fn doThing() !void {
    var map = std.AutoHashMap(Point, MapEntry).init(gpa);
    var start: Point = Point{ .x = 0, .y = 0 };
    var end: Point = Point{ .x = 0, .y = 0 };
    defer map.deinit();

    var inputIter = std.mem.splitSequence(u8, input, "\n");
    var y: isize = 0;
    while (inputIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '.' => try map.put(point, .Free),
                '#' => try map.put(point, .Blocked),
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

    var visited = std.AutoHashMap(Vector, isize).init(gpa);
    var frontier = std.PriorityQueue(MovementCost, void, MovementCost.comp).init(gpa, {});
    var bestPathEndings = std.AutoHashMap(MovementCost, void).init(gpa);
    defer visited.deinit();
    defer frontier.deinit();
    defer bestPathEndings.deinit();

    try visited.put(Vector{ .point = start, .dir = 1 }, 0);
    try frontier.add(MovementCost{ .vec = Vector{ .point = start, .dir = 1 }, .cost = 0 });

    var bestPath: isize = std.math.maxInt(isize);
    while (frontier.removeOrNull()) |*current| {
        if (current.vec.point.equals(end)) {
            if (bestPath >= current.cost) {
                try bestPathEndings.put(current.*, {});
                bestPath = current.cost;
            }
            continue;
        }
        const options = [3]MovementCost{ current.move(), current.turnLeft(), current.turnRight() };
        for (options) |option| {
            if (map.get(option.vec.point) != .Free) continue;
            if ((visited.get(option.vec) orelse std.math.maxInt(isize)) < option.cost) continue;

            try frontier.add(option);
            try visited.put(option.vec, option.cost);
        }
    }

    var pointsOnBestPaths = std.AutoHashMap(Point, void).init(gpa);
    var nextSteps = std.AutoHashMap(MovementCost, void).init(gpa);
    defer pointsOnBestPaths.deinit();
    defer nextSteps.deinit();
    while (bestPathEndings.count() > 0) {
        var currentIter = bestPathEndings.keyIterator();
        while (currentIter.next()) |current| {
            try pointsOnBestPaths.put(current.vec.point, {});
            const options = [3]MovementCost{ current.moveReverse(), current.turnLeftReverse(), current.turnRightReverse() };
            for (options) |option| {
                if (visited.get(option.vec) == option.cost) {
                    try nextSteps.put(option, {});
                }
            }
        }
        std.mem.swap(std.AutoHashMap(MovementCost, void), &bestPathEndings, &nextSteps);
        nextSteps.clearRetainingCapacity();
    }
    std.debug.print("part1: {any}\n", .{bestPath});
    std.debug.print("part2: {any}\n", .{pointsOnBestPaths.count()});
}

pub export fn day16() void {
    doThing() catch unreachable;
}
