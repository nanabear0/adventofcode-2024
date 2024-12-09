const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day09.txt"), "\n");

fn part1() !void {
    var blocks = std.ArrayList(?usize).init(gpa);
    defer blocks.deinit();

    var id: usize = 0;
    var isFile = true;
    for (input) |char| {
        const num: usize = @intCast(char - 48);
        if (isFile) {
            try blocks.appendNTimes(id, num);
            id += 1;
            isFile = false;
        } else {
            try blocks.appendNTimes(null, num);
            isFile = true;
        }
    }

    var start: usize = 0;
    var end: usize = blocks.items.len - 1;
    while (end > start) {
        if (blocks.items[start] == null) {
            while (blocks.items[end] == null) end -= 1;
            blocks.items[start] = blocks.items[end];
            blocks.items[end] = null;
        }

        start += 1;
    }

    var result: usize = 0;
    for (blocks.items, 0..) |blockVal, i| {
        if (blockVal) |val| {
            result += val * i;
        } else break;
    }
    std.debug.print("part1: {any}\n", .{result});
}

pub export fn day09() void {
    std.debug.print("-day09-\n", .{});

    part1() catch unreachable;
}
