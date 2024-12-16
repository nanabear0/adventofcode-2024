const std = @import("std");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day06.txt"), "\n");
const MapEntry = enum { free, blocked };

fn part1and2() !void {
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

    var visitedVectorSetP1 = std.AutoHashMap(Vector, void).init(gpa);
    var visitedPointSetP1 = std.AutoHashMap(Point, void).init(gpa);
    defer visitedVectorSetP1.deinit();
    defer visitedPointSetP1.deinit();
    {
        var currentMove: Vector = startingVector orelse unreachable;
        movement: while (true) {
            try visitedVectorSetP1.put(currentMove, {});
            try visitedPointSetP1.put(currentMove.point, {});

            var move = currentMove.move();
            if (map.getKey(move.point) == null) break :movement;

            while (map.get(move.point) != MapEntry.free) {
                currentMove = currentMove.turnRight();
                move = currentMove.move();
            }

            if (visitedVectorSetP1.getKey(move) != null) {
                break :movement;
            }
            currentMove = move;
        }
    }

    std.debug.print("part1: {d}\n", .{visitedPointSetP1.count()});

    var visitedVectorSetP2 = std.AutoHashMap(Vector, void).init(gpa);
    var visitedPointSetP2 = std.AutoHashMap(Point, void).init(gpa);
    defer visitedVectorSetP2.deinit();
    defer visitedPointSetP2.deinit();
    var result: usize = 0;
    var previousVisitedPointsIter = visitedPointSetP1.iterator();
    attempts: while (previousVisitedPointsIter.next()) |pointToBlock| {
        defer visitedVectorSetP2.clearRetainingCapacity();
        defer visitedPointSetP2.clearRetainingCapacity();

        const entryToSkip = map.getEntry(pointToBlock.key_ptr.*).?;
        entryToSkip.value_ptr.* = .blocked;
        defer entryToSkip.value_ptr.* = .free;

        var currentMove: Vector = startingVector orelse unreachable;
        while (true) {
            try visitedVectorSetP2.put(currentMove, {});
            try visitedPointSetP2.put(currentMove.point, {});

            var move = currentMove.move();
            if (map.getKey(move.point) == null) {
                continue :attempts;
            }

            while (map.get(move.point) != MapEntry.free) {
                currentMove = currentMove.turnRight();
                move = currentMove.move();
            }

            if (visitedVectorSetP2.getKey(move) != null) {
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
    part1and2() catch unreachable;
}
