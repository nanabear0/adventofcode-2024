const std = @import("std");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day09.txt"), "\n");

fn checksum(items: []?usize) usize {
    var result: usize = 0;
    for (items, 0..) |blockVal, i| {
        if (blockVal) |val| {
            result += val * i;
        } else continue;
    }
    return result;
}

fn readInput(allocator: std.mem.Allocator) !std.ArrayList(?usize) {
    var blocks = std.ArrayList(?usize).init(allocator);

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

    return blocks;
}

fn part1() !void {
    var blocks = readInput(gpa) catch unreachable;
    defer blocks.deinit();

    var start: usize = 0;
    var end: usize = blocks.items.len - 1;
    while (end > start) : (start += 1) {
        if (blocks.items[start] == null) {
            while (blocks.items[end] == null) end -= 1;
            std.mem.swap(?usize, &blocks.items[start], &blocks.items[end]);
        }
    }

    std.debug.print("part1: {any}\n", .{checksum(blocks.items)});
}

fn part2() !void {
    var blocks = readInput(gpa) catch unreachable;
    defer blocks.deinit();

    var workingWithSlice = blocks.items[0..];
    while (workingWithSlice.len > 0) {
        const fileToMove = workingWithSlice[workingWithSlice.len - 1];
        const fileStart = std.mem.lastIndexOfNone(?usize, workingWithSlice, &[_]?usize{fileToMove}).? + 1;
        const fileSize = workingWithSlice.len - fileStart;

        var emptySearchSlice = workingWithSlice;
        while (std.mem.indexOf(?usize, emptySearchSlice[0..], &[_]?usize{null})) |emptyStart| {
            emptySearchSlice = emptySearchSlice[emptyStart..];
            const emptySize = std.mem.indexOfNone(?usize, emptySearchSlice, &[_]?usize{null}).?;
            if (fileSize <= emptySize) {
                for (0..fileSize) |i| {
                    std.mem.swap(?usize, &emptySearchSlice[i], &workingWithSlice[fileStart + i]);
                }
                break;
            }
            emptySearchSlice = emptySearchSlice[emptySize..];
        }

        const endOfNextFile = std.mem.lastIndexOfNone(?usize, workingWithSlice, &[_]?usize{ fileToMove, null });
        const startOfFirstEmptySpot = std.mem.indexOf(?usize, workingWithSlice, &[_]?usize{null});
        if (endOfNextFile != null and startOfFirstEmptySpot != null) {
            workingWithSlice = workingWithSlice[startOfFirstEmptySpot.? .. endOfNextFile.? + 1];
        } else break;
    }

    std.debug.print("part2: {any}\n", .{checksum(blocks.items)});
}

pub export fn day09() void {
    std.debug.print("-day09-\n", .{});

    part1() catch unreachable;
    part2() catch unreachable;
}
