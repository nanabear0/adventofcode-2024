const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day15.txt"), "\n");

fn printP1(robot: Point, xmax: usize, ymax: usize, walls: std.AutoHashMap(Point, void), boxes: std.AutoHashMap(Point, void)) void {
    for (0..ymax) |y| {
        for (0..xmax) |x| {
            const point = Point{ .x = @intCast(x), .y = @intCast(y) };
            if (walls.contains(point)) {
                std.debug.print("#", .{});
            } else if (boxes.contains(point)) {
                std.debug.print("O", .{});
            } else if (point.equals(robot)) {
                std.debug.print("@", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn pushBoxesP1(box: Point, dir: Point, boxes: *std.AutoHashMap(Point, void), walls: *std.AutoHashMap(Point, void)) !bool {
    const moveTo = box.add(dir);
    if (walls.contains(moveTo)) {
        return false;
    } else if (boxes.contains(moveTo)) {
        if (try pushBoxesP1(moveTo, dir, boxes, walls)) {
            _ = boxes.remove(box);
            try boxes.put(moveTo, {});
            return true;
        } else {
            return false;
        }
    } else {
        _ = boxes.remove(box);
        try boxes.put(moveTo, {});
        return true;
    }
}

fn part1() !void {
    var inputIter = std.mem.splitSequence(u8, input, "\n");

    var walls = std.AutoHashMap(Point, void).init(gpa);
    var boxes = std.AutoHashMap(Point, void).init(gpa);
    var robotto: ?Point = null;
    defer walls.deinit();
    defer boxes.deinit();

    var y: usize = 0;
    var x: usize = 0;
    while (inputIter.next()) |line| : (y += 1) {
        if (line.len == 0) break;
        x = 0;
        for (line) |char| {
            const point = Point{ .x = @intCast(x), .y = @intCast(y) };
            switch (char) {
                '#' => try walls.put(point, {}),
                'O' => try boxes.put(point, {}),
                '@' => robotto = point,
                else => {},
            }
            x += 1;
        }
    }

    while (inputIter.next()) |instructionLine| {
        for (instructionLine) |instruction| {
            const dir = switch (instruction) {
                '^' => Point{ .x = 0, .y = -1 },
                '>' => Point{ .x = 1, .y = 0 },
                'v' => Point{ .x = 0, .y = 1 },
                '<' => Point{ .x = -1, .y = 0 },
                else => unreachable,
            };
            const moveTo = robotto.?.add(dir);
            if (walls.contains(moveTo)) {
                //
            } else if (boxes.contains(moveTo)) {
                if (try pushBoxesP1(moveTo, dir, &boxes, &walls)) robotto = moveTo;
            } else {
                robotto = moveTo;
            }
        }
    }

    var result: isize = 0;
    var boxesIter = boxes.keyIterator();
    while (boxesIter.next()) |box| {
        result += box.x + 100 * box.y;
    }
    std.debug.print("part1: {d}\n", .{result});
}

fn printP2(robot: Point, xmax: usize, ymax: usize, walls: std.AutoHashMap(Point, void), boxes: std.AutoHashMap(Point, void)) void {
    for (0..ymax) |y| {
        for (0..xmax) |x| {
            const point = Point{ .x = @intCast(x), .y = @intCast(y) };
            const leftPoint = Point{ .x = @as(isize, @intCast(x)) - 1, .y = @intCast(y) };
            if (walls.contains(point)) {
                std.debug.print("#", .{});
            } else if (boxes.contains(point)) {
                std.debug.print("[", .{});
            } else if (boxes.contains(leftPoint)) {
                std.debug.print("]", .{});
            } else if (point.equals(robot)) {
                std.debug.print("@", .{});
            } else {
                std.debug.print(".", .{});
            }
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn actuallyPushBoxes(box: Point, dir: Point, boxes: *std.AutoHashMap(Point, void), walls: *std.AutoHashMap(Point, void)) !void {
    const moveTo = box.add(dir);
    const moveToRight = moveTo.add(Point{ .x = 1, .y = 0 });
    const moveToLeft = moveTo.add(Point{ .x = -1, .y = 0 });
    if (boxes.contains(moveToLeft) and !moveToLeft.equals(box))
        try actuallyPushBoxes(moveToLeft, dir, boxes, walls);
    if (boxes.contains(moveTo) and !moveTo.equals(box))
        try actuallyPushBoxes(moveTo, dir, boxes, walls);
    if (boxes.contains(moveToRight) and !moveToRight.equals(box))
        try actuallyPushBoxes(moveToRight, dir, boxes, walls);

    _ = boxes.remove(box);
    try boxes.put(moveTo, {});
}

fn tryToPushBoxes(box: Point, dir: Point, boxes: *std.AutoHashMap(Point, void), walls: *std.AutoHashMap(Point, void)) !bool {
    const moveTo = box.add(dir);
    const moveToRight = moveTo.add(Point{ .x = 1, .y = 0 });
    const moveToLeft = moveTo.add(Point{ .x = -1, .y = 0 });
    if (walls.contains(moveTo) or walls.contains(moveToRight)) {
        return false;
    }
    if (boxes.contains(moveToLeft) and !moveToLeft.equals(box) and !try tryToPushBoxes(moveToLeft, dir, boxes, walls)) return false;
    if (boxes.contains(moveTo) and !moveTo.equals(box) and !try tryToPushBoxes(moveTo, dir, boxes, walls)) return false;
    if (boxes.contains(moveToRight) and !moveToRight.equals(box) and !try tryToPushBoxes(moveToRight, dir, boxes, walls)) return false;

    return true;
}

fn part2() !void {
    var inputIter = std.mem.splitSequence(u8, input, "\n");

    var walls = std.AutoHashMap(Point, void).init(gpa);
    var boxes = std.AutoHashMap(Point, void).init(gpa);
    var robotto: ?Point = null;
    defer walls.deinit();
    defer boxes.deinit();

    var y: usize = 0;
    var x: usize = 0;
    while (inputIter.next()) |line| : (y += 1) {
        if (line.len == 0) break;
        x = 0;
        for (line) |char| {
            const point = Point{ .x = @intCast(x), .y = @intCast(y) };
            const rightPoint = Point{ .x = @intCast(x + 1), .y = @intCast(y) };
            switch (char) {
                '#' => {
                    try walls.put(point, {});
                    try walls.put(rightPoint, {});
                },
                'O' => try boxes.put(point, {}),
                '@' => robotto = point,
                else => {},
            }
            x += 2;
        }
    }

    while (inputIter.next()) |instructionLine| {
        for (instructionLine) |instruction| {
            const dir = switch (instruction) {
                '^' => Point{ .x = 0, .y = -1 },
                '>' => Point{ .x = 1, .y = 0 },
                'v' => Point{ .x = 0, .y = 1 },
                '<' => Point{ .x = -1, .y = 0 },
                else => unreachable,
            };
            const moveTo = robotto.?.add(dir);
            const moveToLeft = moveTo.add(Point{ .x = -1, .y = 0 });
            if (walls.contains(moveTo)) {
                //
            } else if (boxes.contains(moveTo)) {
                if (try tryToPushBoxes(moveTo, dir, &boxes, &walls)) {
                    try actuallyPushBoxes(moveTo, dir, &boxes, &walls);
                    robotto = moveTo;
                }
            } else if (boxes.contains(moveToLeft)) {
                if (try tryToPushBoxes(moveToLeft, dir, &boxes, &walls)) {
                    try actuallyPushBoxes(moveToLeft, dir, &boxes, &walls);
                    robotto = moveTo;
                }
            } else {
                robotto = moveTo;
            }
        }
    }

    var result: isize = 0;
    var boxesIter = boxes.keyIterator();
    while (boxesIter.next()) |box| {
        result += box.x + 100 * box.y;
    }
    std.debug.print("part2: {d}\n", .{result});
}

pub export fn day15() void {
    std.debug.print("-day15-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
