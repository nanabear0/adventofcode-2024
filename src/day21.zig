const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.ArenaAllocator.init(std.heap.page_allocator);
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

fn possiblePaths(start: u8, end: u8, grid: *const std.AutoArrayHashMap(u8, Point), isNumber: bool, oldPaths: *std.StringHashMap(void)) !std.StringHashMap(void) {
    var paths = std.StringHashMap(void).init(gpa);
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
            var oldPathsIter = oldPaths.keyIterator();
            while (oldPathsIter.next()) |oldPath| {
                var path1 = std.ArrayList(u8).init(gpa);
                try path1.appendSlice(oldPath.*);
                if (path1valid and path2valid) {
                    var path2 = std.ArrayList(u8).init(gpa);
                    try path2.appendSlice(oldPath.*);
                    try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    try path2.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                    try path2.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                    try path1.append('A');
                    try path2.append('A');
                    try paths.put(try path1.toOwnedSlice(), {});
                    try paths.put(try path2.toOwnedSlice(), {});
                } else {
                    var path2 = std.ArrayList(u8).init(gpa);
                    try path2.appendSlice(oldPath.*);
                    if (moveX < 0) {
                        try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        try path2.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        try path2.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        std.mem.swap(u8, &path2.items[@intCast(oldPath.len + absMoveX - 1)], &path2.items[@intCast(oldPath.len + absMoveX)]);
                    } else {
                        try path1.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        try path1.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        try path2.appendNTimes(if (moveY > 0) 'v' else '^', absMoveY);
                        try path2.appendNTimes(if (moveX > 0) '>' else '<', absMoveX);
                        std.mem.swap(u8, &path2.items[@intCast(oldPath.len + absMoveY - 1)], &path2.items[@intCast(oldPath.len + absMoveY)]);
                    }
                    try path1.append('A');
                    try path2.append('A');
                    try paths.put(try path1.toOwnedSlice(), {});
                    try paths.put(try path2.toOwnedSlice(), {});
                }
            }
        }
    }
    return paths;
}

fn getBestPossiblePath(subCommand: []const u8, level: usize, numberGrid: *std.AutoArrayHashMap(u8, Point), inputGrid: *std.AutoArrayHashMap(u8, Point)) !std.StringHashMap(void) {
    var subPaths = std.StringHashMap(void).init(gpa);
    try subPaths.put("", {});
    subPaths = try possiblePaths('A', subCommand[0], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
    for (1..subCommand.len) |i| {
        subPaths = try possiblePaths(subCommand[i - 1], subCommand[i], if (level == 0) numberGrid else inputGrid, level == 0, &subPaths);
    }
    return subPaths;
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

fn bestPath(path: []u8, level: usize, targetLevel: usize, numberGrid: *std.AutoArrayHashMap(u8, Point), inputGrid: *std.AutoArrayHashMap(u8, Point), bestPathCache: *std.AutoHashMap(usize, std.StringHashMap(usize))) !usize {
    if (!bestPathCache.contains(level)) try bestPathCache.put(level, std.StringHashMap(usize).init(gpa));
    var levelCache = bestPathCache.getPtr(level).?;
    var result: usize = 0;
    var subCommands = try splitCommandsFromA(path);
    var subCommandsIter = subCommands.iterator();
    while (subCommandsIter.next()) |subCommandEntry| {
        const subCommand = subCommandEntry.key_ptr.*;
        const subCommandCount = subCommandEntry.value_ptr.*;
        if (targetLevel == level) {
            try levelCache.put(subCommand, subCommand.len);
            result += subCommandCount * subCommand.len;
            continue;
        }
        if (levelCache.contains(subCommand)) {
            result += levelCache.get(subCommand).? * subCommandCount;
            continue;
        }

        var bestSubPaths = try getBestPossiblePath(subCommand, level, numberGrid, inputGrid);
        var lowestCost: usize = std.math.maxInt(usize);
        var bestSubPathsIter = bestSubPaths.keyIterator();
        while (bestSubPathsIter.next()) |bestSubPath| {
            const cost = try bestPath(@constCast(bestSubPath.*), level + 1, targetLevel, numberGrid, inputGrid, bestPathCache);
            if (cost < lowestCost) lowestCost = cost;
        }
        try levelCache.put(subCommand, lowestCost);
        result += lowestCost * subCommandCount;
    }
    try levelCache.put(path, result);
    return result;
}

fn doThing(hiddenLayers: usize) !usize {
    var numberGrid = try fillNumberGrid();
    defer numberGrid.deinit();
    var inputGrid = try fillInputGrid();
    defer inputGrid.deinit();

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var bestPathCache = std.AutoHashMap(usize, std.StringHashMap(usize)).init(gpa);
    defer bestPathCache.deinit();
    var result: usize = 0;
    try bestPathCache.ensureUnusedCapacity(@intCast(hiddenLayers + 2));
    while (inputIter.next()) |line| {
        const cost = try bestPath(@constCast(line), 0, hiddenLayers + 1, &numberGrid, &inputGrid, &bestPathCache);
        result += try std.fmt.parseInt(usize, line[0 .. line.len - 1], 10) * cost;
    }
    return result;
}

pub export fn day21() void {
    std.debug.print("-day21-\n", .{});
    std.debug.print("part1: {d}\n", .{doThing(2) catch unreachable});
    std.debug.print("part2: {d}\n", .{doThing(25) catch unreachable});
}
