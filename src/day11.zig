const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day11.txt"), "\n");

fn doThing(blinks: usize) !usize {
    var stones = std.AutoArrayHashMap(usize, usize).init(gpa);
    defer stones.deinit();

    var stoneIter = std.mem.split(u8, input, " ");
    while (stoneIter.next()) |stone| {
        const entry = try stones.getOrPutValue(try std.fmt.parseInt(usize, stone, 10), 0);
        entry.value_ptr.* += 1;
    }

    var newStones = std.AutoArrayHashMap(usize, usize).init(gpa);
    defer newStones.deinit();
    for (0..blinks) |_| {
        var stonesIter = stones.iterator();
        while (stonesIter.next()) |stoneEntry| {
            const digits: usize = @as(usize, @intFromFloat(@floor(@log10(@as(f64, @floatFromInt(stoneEntry.key_ptr.*)))))) + 1;
            if (stoneEntry.key_ptr.* == 0) {
                const entry = try newStones.getOrPutValue(1, 0);
                entry.value_ptr.* += stoneEntry.value_ptr.*;
            } else if (digits % 2 == 0) {
                const splitter = std.math.pow(usize, 10, digits / 2);
                const entry1 = try newStones.getOrPutValue(stoneEntry.key_ptr.* / splitter, 0);
                entry1.value_ptr.* += stoneEntry.value_ptr.*;
                const entry2 = try newStones.getOrPutValue(stoneEntry.key_ptr.* % splitter, 0);
                entry2.value_ptr.* += stoneEntry.value_ptr.*;
            } else {
                const entry = try newStones.getOrPutValue(stoneEntry.key_ptr.* * 2024, 0);
                entry.value_ptr.* += stoneEntry.value_ptr.*;
            }
        }
        std.mem.swap(std.AutoArrayHashMap(usize, usize), &stones, &newStones);
        newStones.clearRetainingCapacity();
    }

    var result: usize = 0;
    for (stones.values()) |stone| result += stone;
    return result;
}

pub export fn day11() void {
    std.debug.print("-day11-\n", .{});

    std.debug.print("part1: {any}\n", .{doThing(25) catch unreachable});
    std.debug.print("part1: {any}\n", .{doThing(75) catch unreachable});
}
