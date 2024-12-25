const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day25.txt"), "\n");

fn part1() !void {
    var locks = std.ArrayList([5]usize).init(gpa);
    var keys = std.ArrayList([5]usize).init(gpa);
    defer locks.deinit();
    defer keys.deinit();

    var lockOrKeyIter = std.mem.splitSequence(u8, input, "\n\n");
    while (lockOrKeyIter.next()) |lockOrKey| {
        var profile: [5]usize = .{0} ** 5;
        var lineIter = std.mem.splitScalar(u8, lockOrKey, '\n');
        const isLock = lineIter.next().?[0] == '#';
        while (lineIter.next()) |line| {
            if (lineIter.peek() == null) break;
            for (line, 0..) |c, i| {
                if (c == '#') profile[i] += 1;
            }
        }
        try (if (isLock) locks else keys).append(profile);
    }

    var result: usize = 0;
    for (locks.items) |lock| {
        key: for (keys.items) |key| {
            for (0..5) |i| if (lock[i] + key[i] > 5) continue :key;
            result += 1;
        }
    }

    std.debug.print("part1: {d}\n", .{result});
}

pub export fn day25() void {
    std.debug.print("-day25-\n", .{});
    part1() catch unreachable;
}
