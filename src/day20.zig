const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day20.txt"), "\n");

const PossibleCheats = [_][2]Point{
    [2]Point{ Point{ .x = 0, .y = -1 }, Point{ .x = 0, .y = -1 } },
    [2]Point{ Point{ .x = 0, .y = -1 }, Point{ .x = 1, .y = 0 } },
    [2]Point{ Point{ .x = 0, .y = -1 }, Point{ .x = -1, .y = 0 } },

    [2]Point{ Point{ .x = 1, .y = 0 }, Point{ .x = 1, .y = 0 } },
    [2]Point{ Point{ .x = 1, .y = 0 }, Point{ .x = 0, .y = -1 } },
    [2]Point{ Point{ .x = 1, .y = 0 }, Point{ .x = 0, .y = 1 } },

    [2]Point{ Point{ .x = 0, .y = 1 }, Point{ .x = 0, .y = 1 } },
    [2]Point{ Point{ .x = 0, .y = 1 }, Point{ .x = -1, .y = 0 } },
    [2]Point{ Point{ .x = 0, .y = 1 }, Point{ .x = 1, .y = 0 } },

    [2]Point{ Point{ .x = -1, .y = 0 }, Point{ .x = -1, .y = 0 } },
    [2]Point{ Point{ .x = -1, .y = 0 }, Point{ .x = 0, .y = -1 } },
    [2]Point{ Point{ .x = -1, .y = 0 }, Point{ .x = 0, .y = 1 } },
};

const MovementCost = struct {
    cheatable: Cheatables,
    cost: isize,
    pub fn canCheat(self: *const MovementCost) bool {
        return self.cheatable.canCheat();
    }
    pub fn move(self: *const MovementCost, dir: Point) MovementCost {
        return MovementCost{ .cheatable = self.cheatable.move(dir), .cost = self.cost + 1 };
    }
    pub fn cheat(self: *const MovementCost, dir1: Point, dir2: Point) MovementCost {
        return MovementCost{ .cheatable = self.cheatable.cheat(dir1, dir2), .cost = self.cost + 2 };
    }
    pub fn comp(_: void, a: MovementCost, b: MovementCost) std.math.Order {
        return std.math.order(a.cost, b.cost);
    }
};

const Cheatables = struct {
    point: Point,
    usedCheats: ?[2]Point,
    pub fn canCheat(self: *const Cheatables) bool {
        return self.usedCheats == null;
    }
    pub fn move(self: *const Cheatables, dir: Point) Cheatables {
        return Cheatables{ .point = self.point.add(dir), .usedCheats = self.usedCheats };
    }
    pub fn cheat(self: *const Cheatables, dir1: Point, dir2: Point) Cheatables {
        return Cheatables{ .point = self.point.add(dir1).add(dir2), .usedCheats = .{ self.point.add(dir1), self.point.add(dir1).add(dir2) } };
    }
};

const CostOfCheating = struct {
    cost: isize,
    hasCheated: false,
};

const MapEntry = enum {
    Free,
    Blocked,
};

fn part1() !void {
    var map = std.AutoHashMap(Point, MapEntry).init(gpa);
    var start: Point = Point{ .x = 0, .y = 0 };
    var end: Point = Point{ .x = 0, .y = 0 };
    defer map.deinit();

    var inputIter = std.mem.splitSequence(u8, input, "\n");
    var y: isize = 0;
    while (inputIter.next()) |line| : (y += 1) {
        for (line, 0..) |char, x| {
            const point = Point{ .x = @intCast(x), .y = y };
            switch (char) {
                '.' => try map.put(point, .Free),
                '#' => try map.put(point, .Blocked),
                'S' => {
                    start = point;
                    try map.put(point, .Free);
                },
                'E' => {
                    end = point;
                    try map.put(point, .Free);
                },
                else => unreachable,
            }
        }
    }

    var visited = std.AutoHashMap(Point, isize).init(gpa);
    var frontier = std.PriorityQueue(MovementCost, void, MovementCost.comp).init(gpa, {});
    var cheatEndingCosts = std.AutoHashMap(?[2]Point, isize).init(gpa);
    defer visited.deinit();
    defer frontier.deinit();
    defer cheatEndingCosts.deinit();

    try visited.put(Cheatables{ .point = start, .usedCheats = null }, 0);
    try frontier.add(MovementCost{ .cheatable = Cheatables{ .point = start, .usedCheats = null }, .cost = 0 });

    var bestPath: isize = std.math.maxInt(isize);
    while (frontier.removeOrNull()) |*current| {
        // std.debug.print("{d}\n", .{frontier.count()});
        if (current.cheatable.point.equals(end)) {
            // if (bestPath >= current.cost) {
            try cheatEndingCosts.put(current.cheatable.usedCheats, current.cost);
            bestPath = current.cost;
            // }
            continue;
        }

        var options = std.ArrayList(MovementCost).init(gpa);
        for (CardinalDirections) |dir| {
            try options.append(current.move(dir));
        }
        if (current.canCheat()) {
            for (PossibleCheats) |cheat| {
                try options.append(current.cheat(cheat[0], cheat[1]));
            }
        }

        for (options.items) |option| {
            if (option.cost > 9344) continue;
            if (map.get(option.cheatable.point) != .Free) continue;
            if ((visited.get(option.cheatable) orelse std.math.maxInt(isize)) < option.cost) continue;

            try frontier.add(option);
            try visited.put(option.cheatable, option.cost);
        }
    }
    var cheatEndingsIter = cheatEndingCosts.iterator();
    while (cheatEndingsIter.next()) |entry| {
        std.debug.print("{any} -> {any}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    std.debug.print("part1: {d}\n", .{0});
}

fn part2() !void {
    std.debug.print("part2: {d}\n", .{0});
}

pub export fn day20() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
