const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day21.txt"), "\n");

fn fillNumberGrid() !std.AutoArrayHashMap(u8, Point) {
    var numberGrid = std.AutoArrayHashMap(u8, Point).init(gpa);
    try numberGrid.put('7', Point{ .x = 0, .y = 0 });
    try numberGrid.put('8', Point{ .x = 1, .y = 0 });
    try numberGrid.put('9', Point{ .x = 2, .y = 0 });
    try numberGrid.put('4', Point{ .x = 0, .y = 1 });
    try numberGrid.put('5', Point{ .x = 1, .y = 1 });
    try numberGrid.put('6', Point{ .x = 2, .y = 1 });
    try numberGrid.put('1', Point{ .x = 0, .y = 2 });
    try numberGrid.put('2', Point{ .x = 1, .y = 2 });
    try numberGrid.put('3', Point{ .x = 2, .y = 2 });
    try numberGrid.put('0', Point{ .x = 1, .y = 3 });
    try numberGrid.put('A', Point{ .x = 2, .y = 3 });

    return numberGrid;
}

fn fillInputGrid() !std.AutoArrayHashMap(u8, Point) {
    var inputGrid = std.AutoArrayHashMap(u8, Point).init(gpa);
    try inputGrid.put('^', Point{ .x = 1, .y = 0 });
    try inputGrid.put('A', Point{ .x = 2, .y = 0 });
    try inputGrid.put('<', Point{ .x = 0, .y = 1 });
    try inputGrid.put('v', Point{ .x = 1, .y = 1 });
    try inputGrid.put('>', Point{ .x = 2, .y = 1 });

    return inputGrid;
}

fn addShortestPath(start: u8, end: u8, grid: *const std.AutoArrayHashMap(u8, Point), path: *std.ArrayList(u8), _: bool) !void {
    if (grid.get(start)) |p1| {
        if (grid.get(end)) |p2| {
            const moveX = p2.x - p1.x;
            const moveY = p2.y - p1.y;
            const absMoveX = @abs(moveX);
            const absMoveY = @abs(moveY);
            if (moveX > 0) {
                if (moveY > 0) {
                    try path.appendNTimes('>', absMoveX);
                    try path.appendNTimes('v', absMoveY);
                } else {
                    try path.appendNTimes('>', absMoveX);
                    try path.appendNTimes('^', absMoveY);
                }
            } else {
                if (moveY > 0) {
                    try path.appendNTimes('v', absMoveY);
                    try path.appendNTimes('<', absMoveX);
                } else {
                    try path.appendNTimes('^', absMoveY);
                    try path.appendNTimes('<', absMoveX);
                }
            }
        }
    }
    try path.append('A');
}
fn getTotalPathForString(str: []const u8, grid: *const std.AutoArrayHashMap(u8, Point), isNumberGrid: bool) !std.ArrayList(u8) {
    var path = std.ArrayList(u8).init(gpa);
    try addShortestPath('A', str[0], grid, &path, isNumberGrid);
    for (1..str.len) |i| {
        try addShortestPath(str[i - 1], str[i], grid, &path, isNumberGrid);
    }
    return path;
}

fn doThing() !void {
    var numberGrid = try fillNumberGrid();
    defer numberGrid.deinit();
    var inputGrid = try fillInputGrid();
    defer inputGrid.deinit();

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    while (inputIter.next()) |line| {
        const level0Path = try getTotalPathForString(line, &numberGrid, true);
        defer level0Path.deinit();
        const level1Path = try getTotalPathForString(level0Path.items, &inputGrid, false);
        defer level1Path.deinit();
        const level2Path = try getTotalPathForString(level1Path.items, &inputGrid, false);
        defer level2Path.deinit();
        std.debug.print("\n==={s}===\n", .{line});
        std.debug.print("{d} {s}\n", .{ level0Path.items.len, level0Path.items });
        std.debug.print("{d} {s}\n", .{ level1Path.items.len, level1Path.items });
        std.debug.print("{d} {s}\n", .{ level2Path.items.len, level2Path.items });
    }
}

pub export fn day21() void {
    doThing() catch unreachable;
}
