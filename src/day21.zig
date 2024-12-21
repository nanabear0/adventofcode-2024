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

fn addShortestPath(start: u8, end: u8, grid: *const std.AutoArrayHashMap(u8, Point), paths: *std.ArrayList(std.ArrayList(u8)), isNumber: bool) !void {
    if (grid.get(start)) |p1| {
        if (grid.get(end)) |p2| {
            const moveX = p2.x - p1.x;
            const moveY = p2.y - p1.y;
            const pathEdge1 = Point{ .x = p1.x, .y = p2.y };
            const pathEdge2 = Point{ .x = p2.x, .y = p1.y };
            const invalidPoint = if (isNumber) Point{ .x = 0, .y = 3 } else Point{ .x = 0, .y = 0 };
            const absMoveX = @abs(moveX);
            const absMoveY = @abs(moveY);
            const path1valid = !pathEdge1.equals(invalidPoint);
            const path2valid = !pathEdge2.equals(invalidPoint);
            const patshLen = paths.items.len;
            for (0..patshLen) |i| {
                var path = paths.items[i];
                if (path1valid and path2valid) {
                    try path.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try path.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    var clone = std.ArrayList(u8).init(gpa);
                    for (path.items) |p| try clone.append(p);
                    try clone.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    try clone.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try paths.append(clone);
                } else {
                    if (moveX > 0) {
                        try path.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        try path.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    } else {
                        try path.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        try path.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    }
                }
            }
        }
    }
    for (paths.items) |*path| {
        try path.append('A');
    }
}
fn getTotalPathForString(str: []const u8, grid: *const std.AutoArrayHashMap(u8, Point), isNumberGrid: bool) !std.ArrayList(std.ArrayList(u8)) {
    var paths = std.ArrayList(std.ArrayList(u8)).init(gpa);
    try paths.append(std.ArrayList(u8).init(gpa));
    try addShortestPath('A', str[0], grid, &paths, isNumberGrid);
    for (1..str.len) |i| {
        try addShortestPath(str[i - 1], str[i], grid, &paths, isNumberGrid);
    }
    return paths;
}

fn doThing() !void {
    var numberGrid = try fillNumberGrid();
    defer numberGrid.deinit();
    var inputGrid = try fillInputGrid();
    defer inputGrid.deinit();

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    while (inputIter.next()) |line| {
        const level0Paths = try getTotalPathForString(line, &numberGrid, true);
        var level1Paths = std.ArrayList(std.ArrayList(u8)).init(gpa);
        for (level0Paths.items) |level0Path| {
            const tmp = try getTotalPathForString(level0Path.items, &inputGrid, false);
            // _ = tmp;
            try level1Paths.appendSlice(tmp.items[0..]);
        }
        var level2Paths = std.ArrayList(std.ArrayList(u8)).init(gpa);
        for (level1Paths.items) |level1Path| {
            const tmp = try getTotalPathForString(level1Path.items, &inputGrid, false);
            // _ = tmp;
            try level2Paths.appendSlice(tmp.items[0..]);
        }
        std.debug.print("\n==={s}===\n", .{line});
        std.debug.print("{d} {s}\n", .{ level0Paths.items.len, level0Paths.items[0].items });
        std.debug.print("{d} {s}\n", .{ level1Paths.items.len, level1Paths.items[0].items });
        std.debug.print("{d} {s}\n", .{ level2Paths.items.len, level2Paths.items[0].items });
    }
}

pub export fn day21() void {
    doThing() catch unreachable;
}
