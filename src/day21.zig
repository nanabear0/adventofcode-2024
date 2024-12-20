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

fn possiblePaths(start: u8, end: u8, grid: *const std.AutoArrayHashMap(u8, Point), isNumber: bool, oldPaths: *std.ArrayList(std.ArrayList(u8))) !std.ArrayList(std.ArrayList(u8)) {
    var paths = std.ArrayList(std.ArrayList(u8)).init(gpa);
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
            for (oldPaths.items) |*oldPath| {
                var path1 = try oldPath.clone();
                if (path1valid and path2valid) {
                    var path2 = try oldPath.clone();
                    try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    try path2.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    try path2.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try paths.append(path1);
                    try paths.append(path2);
                } else {
                    if (moveX > 0 or isNumber) {
                        try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    } else {
                        try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    }
                    try paths.append(path1);
                }
            }
        }
    }
    for (paths.items) |*path| {
        try path.append('A');
    }
    for (oldPaths.items) |oldPath| {
        oldPath.deinit();
    }
    oldPaths.deinit();
    return paths;
}

fn bestPath(path: []const u8, level: usize, targetLevel: usize, numberGrid: *std.AutoArrayHashMap(u8, Point), inputGrid: *std.AutoArrayHashMap(u8, Point), bestPathCache: *std.AutoHashMap(usize, std.StringHashMap(usize))) !usize {
    if (!bestPathCache.contains(level)) try bestPathCache.put(level, std.StringHashMap(usize).init(gpa));
    var levelCache = bestPathCache.get(level).?;

    if (levelCache.contains(path)) return levelCache.get(path).?;
    if (targetLevel == level) {
        try levelCache.put(path, path.len);
        return path.len;
    }
    var cost: usize = 0;
    var calcPath = path[0..];
    while (std.mem.indexOfScalar(u8, calcPath, 'A')) |aIndex| : (calcPath = calcPath[aIndex + 1 ..]) {
        var subPaths = std.ArrayList(std.ArrayList(u8)).init(gpa);
        try subPaths.append(std.ArrayList(u8).init(gpa));
        subPaths = try possiblePaths('A', calcPath[0], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
        for (1..calcPath.len) |i| {
            subPaths = try possiblePaths(calcPath[i - 1], calcPath[i], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
        }
        var minCost: usize = std.math.maxInt(usize);
        for (subPaths.items) |subPath| {
            const subCost = try bestPath(subPath.items, level + 1, targetLevel, numberGrid, inputGrid, bestPathCache);
            if (subCost < minCost) minCost = subCost;
        }
        cost += minCost;
        if (aIndex == calcPath.len - 1) break;
    }

    try levelCache.put(path, cost);
    return cost;
}

fn doThing() !void {
    var numberGrid = try fillNumberGrid();
    defer numberGrid.deinit();
    var inputGrid = try fillInputGrid();
    defer inputGrid.deinit();

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var bestPathCache = std.AutoHashMap(usize, std.StringHashMap(usize)).init(gpa);
    defer bestPathCache.deinit();
    while (inputIter.next()) |line| {
        const cost = try bestPath(line, 0, 2, &numberGrid, &inputGrid, &bestPathCache);
        std.debug.print("{s}: {d}\n", .{ line, cost });
    }
}

pub export fn day21() void {
    doThing() catch unreachable;
}
