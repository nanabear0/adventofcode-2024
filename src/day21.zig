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
                    if (moveX > 0 and isNumber) {
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

fn getDist(a: u8, b: u8) usize {
    if (a == b) return 0;

    if (a == '<') {
        if (b == '>') return 3;
        if (b == 'v') return 2;
        if (b == '^') return 3;
        if (b == 'A') return 4;
    }

    if (a == '>') {
        if (b == '<') return 3;
        if (b == 'v') return 2;
        if (b == '^') return 3;
        if (b == 'A') return 2;
    }

    if (a == '^') {
        if (b == '<') return 3;
        if (b == 'v') return 2;
        if (b == '>') return 3;
        if (b == 'A') return 2;
    }

    if (a == 'v') {
        if (b == 'A') return 3;
        return 2;
    }
    return 0;

    // std.debug.print("{c} {c}\n", .{ a, b });
    // unreachable;
}

fn getBestPossiblePath(subCommand: []const u8, level: usize, numberGrid: *std.AutoArrayHashMap(u8, Point), inputGrid: *std.AutoArrayHashMap(u8, Point), getBestPossiblePathCache: *std.StringHashMap([]u8)) ![]u8 {
    if (getBestPossiblePathCache.contains(subCommand)) return getBestPossiblePathCache.get(subCommand).?;

    std.debug.print("{s}\n", .{subCommand});
    var subPaths = std.ArrayList(std.ArrayList(u8)).init(gpa);
    try subPaths.append(std.ArrayList(u8).init(gpa));
    subPaths = try possiblePaths('A', subCommand[0], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
    for (1..subCommand.len) |i| {
        subPaths = try possiblePaths(subCommand[i - 1], subCommand[i], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
    }

    var bestSubPath: ?std.ArrayList(u8) = null;
    var bestSubPathHeur: usize = std.math.maxInt(usize);
    for (subPaths.items) |subPath| {
        var heur: usize = 0;
        var w_iter = std.mem.window(u8, subPath.items, 2, 1);
        while (w_iter.next()) |btns| {
            if (btns.len < 2) break;

            if (btns[0] != btns[1]) heur += getDist(btns[0], btns[1]);
        }
        if (heur < bestSubPathHeur) {
            if (bestSubPath != null) bestSubPath.?.deinit();
            bestSubPath = subPath;
            bestSubPathHeur = heur;
        } else {
            subPath.deinit();
        }
    }
    try getBestPossiblePathCache.put(subCommand, bestSubPath.?.items);
    return bestSubPath.?.items;
}

fn splitCommandsFromA(path: []const u8) !std.StringHashMap(usize) {
    var calcPath = path[0..];
    var subCommands = std.StringHashMap(usize).init(gpa);
    while (std.mem.indexOfScalar(u8, calcPath, 'A')) |aIndex| : (calcPath = calcPath[aIndex + 1 ..]) {
        const entry = try subCommands.getOrPutValue(calcPath[0 .. aIndex + 1], 0);
        entry.value_ptr.* += 1;
        if (aIndex == calcPath.len - 1) break;
    }
    return subCommands;
}

fn bestPath(path: []u8, level: usize, targetLevel: usize, numberGrid: *std.AutoArrayHashMap(u8, Point), inputGrid: *std.AutoArrayHashMap(u8, Point), bestPathCache: *std.AutoHashMap(usize, std.StringHashMap(usize)), getBestPossiblePathCache: *std.StringHashMap([]u8)) !usize {
    if (!bestPathCache.contains(level)) try bestPathCache.put(level, std.StringHashMap(usize).init(gpa));

    var levelCache = bestPathCache.get(level).?;

    var result: usize = 0;
    var subCommands = try splitCommandsFromA(path);
    var subCommandsIter = subCommands.iterator();
    // std.debug.print("this step has {d} unique subCommands\n", .{subCommands.count()});
    while (subCommandsIter.next()) |subCommandEntry| {
        const subCommand = subCommandEntry.key_ptr.*;
        const subCommandCount = subCommandEntry.value_ptr.*;
        if (targetLevel == level) {
            try levelCache.put(path, subCommand.len);
            result += subCommandCount * subCommand.len;
            continue;
        }
        if (levelCache.contains(subCommand)) {
            result += levelCache.get(subCommand).? * subCommandCount;
            continue;
        }
        std.debug.print("{s} {d}\n", .{ subCommand, level });

        const bestSubPath = try getBestPossiblePath(subCommand, level, numberGrid, inputGrid, getBestPossiblePathCache);
        const cost = try bestPath(bestSubPath, level + 1, targetLevel, numberGrid, inputGrid, bestPathCache, getBestPossiblePathCache);
        try levelCache.put(subCommand, cost);
        result += cost * subCommandCount;
    }
    // std.debug.print("level: {d}, path: {s}, result: {s}\n", .{ level, path, result.items });

    try levelCache.put(path, result);
    return result;
}

fn doThing() !void {
    var numberGrid = try fillNumberGrid();
    defer numberGrid.deinit();
    var inputGrid = try fillInputGrid();
    defer inputGrid.deinit();

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var bestPathCache = std.AutoHashMap(usize, std.StringHashMap(usize)).init(gpa);
    var getBestPossiblePathCache = std.StringHashMap([]u8).init(gpa);
    defer bestPathCache.deinit();
    defer getBestPossiblePathCache.deinit();
    var result: usize = 0;
    const hiddenLayers: usize = 2;
    while (inputIter.next()) |line| {
        const cost = try bestPath(@constCast(line), 0, hiddenLayers + 1, &numberGrid, &inputGrid, &bestPathCache, &getBestPossiblePathCache);
        result += try std.fmt.parseInt(usize, line[0 .. line.len - 1], 10) * cost;
    }
    std.debug.print("part1: {d}", .{result});
}

pub export fn day21() void {
    doThing() catch unreachable;
}
