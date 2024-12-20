const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day20.txt"), "\n");

fn doPart(cheatDuration: isize, blockages: *std.AutoHashMap(Point, void), freeze: *std.AutoHashMap(Point, ?isize)) !usize {
    var result: usize = 0;
    var freezeIter = freeze.iterator();
    while (freezeIter.next()) |freezeEntry| {
        const ylimit: isize = cheatDuration;
        var yy: isize = -ylimit;
        while (yy <= ylimit) : (yy += 1) {
            const xlimit = cheatDuration - @as(isize, @intCast(@abs(yy)));
            var xx: isize = -xlimit;
            while (xx <= xlimit) : (xx += 1) {
                const cheatCost: isize = @intCast(@abs(xx) + @abs(yy));
                if (cheatCost <= 1) continue;

                const cheatDestination = freezeEntry.key_ptr.add(Point{ .x = xx, .y = yy });
                if (blockages.contains(cheatDestination)) continue;
                if (freeze.get(cheatDestination) orelse null == null) continue;

                const normalCost: isize = freeze.get(cheatDestination).?.? - freezeEntry.value_ptr.*.?;
                if (normalCost - cheatCost >= 100) result += 1;
            }
        }
    }

    return result;
}

fn doThing() !void {
    var blockages = std.AutoHashMap(Point, void).init(gpa);
    var freeze = std.AutoHashMap(Point, ?isize).init(gpa);
    var start: Point = Point{ .x = 0, .y = 0 };
    var end: Point = Point{ .x = 0, .y = 0 };
    defer freeze.deinit();
    defer blockages.deinit();

    var y: isize = 0;
    var inputIter = std.mem.splitSequence(u8, input, "\n");
    while (inputIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '.' => {
                    try freeze.put(point, null);
                },
                '#' => {
                    try blockages.put(point, {});
                },
                'S' => {
                    start = point;
                    try freeze.put(point, 0);
                },
                'E' => {
                    end = point;
                    try freeze.put(point, null);
                },
                else => unreachable,
            }
        }
    }

    var costerino: isize = 0;
    var curr = start;
    step: while (!curr.equals(end)) : (costerino += 1) {
        for (CardinalDirections) |dir| {
            const next = curr.add(dir);
            if (blockages.contains(next)) continue;
            if (!freeze.contains(next)) continue;
            if (freeze.get(next).? != null) continue;

            try freeze.put(next, costerino + 1);
            curr = next;
            continue :step;
        }
        break;
    }

    std.debug.print("part1: {}\n", .{try doPart(2, &blockages, &freeze)});
    std.debug.print("part2: {}\n", .{try doPart(20, &blockages, &freeze)});
}

pub export fn day20() void {
    doThing() catch unreachable;
}
