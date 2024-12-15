const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day04.txt"), "\n");

const directions = [8]Point{
    Point{ .x = 0, .y = 1 },
    Point{ .x = 0, .y = -1 },
    Point{ .x = 1, .y = 1 },
    Point{ .x = 1, .y = 0 },
    Point{ .x = 1, .y = -1 },
    Point{ .x = -1, .y = 1 },
    Point{ .x = -1, .y = 0 },
    Point{ .x = -1, .y = -1 },
};

const xmas = "XMAS";

fn part1() !void {
    var map = std.AutoHashMap(Point, u8).init(std.heap.page_allocator);
    defer map.deinit();
    var xs = std.AutoHashMap(Point, void).init(std.heap.page_allocator);
    defer xs.deinit();

    var lineIter = std.mem.split(u8, input, "\n");
    var y: isize = 0;
    while (lineIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            try map.put(point, char);
            if (char == 'X') try xs.put(point, {});
        }
    }

    var xsIter = xs.keyIterator();
    var xmasCount: isize = 0;
    while (xsIter.next()) |xpos| {
        directions: for (directions) |dir| {
            var pointToCheck = Point{ .x = xpos.x, .y = xpos.y };
            for (xmas) |expectedChar| {
                defer pointToCheck = pointToCheck.add(dir);
                if (map.get(pointToCheck) != expectedChar) continue :directions;
            }
            xmasCount += 1;
        }
    }

    std.debug.print("part1: {d}\n", .{xmasCount});
}

const diagonalDirections = [4]Point{
    Point{ .x = 1, .y = 1 },
    Point{ .x = 1, .y = -1 },
    Point{ .x = -1, .y = 1 },
    Point{ .x = -1, .y = -1 },
};

fn part2() !void {
    var map = std.AutoHashMap(Point, u8).init(std.heap.page_allocator);
    defer map.deinit();
    var as = std.AutoHashMap(Point, void).init(std.heap.page_allocator);
    defer as.deinit();

    var lineIter = std.mem.split(u8, input, "\n");
    var y: isize = 0;
    while (lineIter.next()) |line| {
        defer y += 1;

        var x: isize = 0;
        for (line) |char| {
            defer x += 1;

            const point = Point{ .x = x, .y = y };
            try map.put(point, char);
            if (char == 'A') try as.put(point, {});
        }
    }

    var asIter = as.keyIterator();
    var x_masCount: isize = 0;
    while (asIter.next()) |apos| {
        var masCount: usize = 0;
        for (diagonalDirections) |dir| {
            const previous = apos.subtract(dir);
            const next = apos.add(dir);

            if (map.get(previous) == 'M' and map.get(next) == 'S') masCount += 1;
        }

        if (masCount == 2) x_masCount += 1;
    }

    std.debug.print("part2: {d}\n", .{x_masCount});
}

pub export fn day04() void {
    std.debug.print("-day04-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
