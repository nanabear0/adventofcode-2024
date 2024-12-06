const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day06.txt"), "\n");
const MapEntry = enum { free, blocked };

const directions = [4]Point{
    Point{ .x = 0, .y = -1 },
    Point{ .x = 1, .y = 0 },
    Point{ .x = 0, .y = 1 },
    Point{ .x = -1, .y = 0 },
};

const Vector = struct {
    point: Point,
    dir: u3,
    pub fn move(self: *Vector) Vector {
        return Vector{ .point = self.point.add(directions[self.dir]), .dir = self.dir };
    }
    pub fn rotate(self: *Vector) Vector {
        return Vector{ .point = self.point, .dir = (self.dir + 1) % 4 };
    }
};

fn part1() !void {
    var linesIter = std.mem.split(u8, input, "\n");
    var y: isize = 0;
    var map = std.AutoHashMap(Point, MapEntry).init(gpa);
    defer map.deinit();

    var startingVector: ?Vector = null;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '#' => try map.put(point, .blocked),
                '.' => try map.put(point, .free),
                '^' => startingVector = Vector{ .point = point, .dir = 0 },
                '>' => startingVector = Vector{ .point = point, .dir = 1 },
                'v' => startingVector = Vector{ .point = point, .dir = 2 },
                '<' => startingVector = Vector{ .point = point, .dir = 3 },
                else => {},
            }
        }
    }
    try map.put(startingVector.?.point, .free);

    var visitedVectorSet = std.AutoHashMap(Vector, void).init(gpa);
    var visitedPointSet = std.AutoHashMap(Point, void).init(gpa);
    defer visitedVectorSet.deinit();
    defer visitedPointSet.deinit();

    var currentMove: Vector = startingVector orelse unreachable;
    movement: while (true) {
        try visitedVectorSet.put(currentMove, {});
        try visitedPointSet.put(currentMove.point, {});

        var move = currentMove.move();
        if (map.getKey(move.point) == null) break :movement;

        while (map.get(move.point) != MapEntry.free) {
            currentMove = currentMove.rotate();
            move = currentMove.move();
        }

        if (visitedVectorSet.getKey(move) != null) {
            break :movement;
        }
        currentMove = move;
    }

    std.debug.print("part1: {d}\n", .{visitedPointSet.count()});
}

fn part2() !void {
    var linesIter = std.mem.split(u8, input, "\n");
    var y: isize = 0;
    var map = std.AutoHashMap(Point, MapEntry).init(gpa);
    defer map.deinit();

    var startingVector: ?Vector = null;
    while (linesIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '#' => try map.put(point, .blocked),
                '.' => try map.put(point, .free),
                '^' => startingVector = Vector{ .point = point, .dir = 0 },
                '>' => startingVector = Vector{ .point = point, .dir = 1 },
                'v' => startingVector = Vector{ .point = point, .dir = 2 },
                '<' => startingVector = Vector{ .point = point, .dir = 3 },
                else => {},
            }
        }
    }
    try map.put(startingVector.?.point, .free);

    var visitedVectorSet = std.AutoHashMap(Vector, void).init(gpa);
    var visitedPointSet = std.AutoHashMap(Point, void).init(gpa);
    defer visitedVectorSet.deinit();
    defer visitedPointSet.deinit();
    var mapIter = map.iterator();
    var result: usize = 0;
    var counterino: usize = 0;
    attempts: while (mapIter.next()) |entryToSkip| : (counterino += 1) {
        defer visitedVectorSet.clearRetainingCapacity();
        defer visitedPointSet.clearRetainingCapacity();

        if (entryToSkip.value_ptr.* != .free) continue;
        entryToSkip.value_ptr.* = .blocked;
        defer entryToSkip.value_ptr.* = .free;

        var currentMove: Vector = startingVector orelse unreachable;
        while (true) {
            try visitedVectorSet.put(currentMove, {});
            try visitedPointSet.put(currentMove.point, {});

            var move = currentMove.move();
            if (map.getKey(move.point) == null) {
                continue :attempts;
            }

            while (map.get(move.point) != MapEntry.free) {
                currentMove = currentMove.rotate();
                move = currentMove.move();
            }

            if (visitedVectorSet.getKey(move) != null) {
                result += 1;
                continue :attempts;
            }
            currentMove = move;
        }
    }

    std.debug.print("part2: {d}\n", .{result});
}

pub export fn day06() void {
    std.debug.print("-day06-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
