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

fn part2() !void {
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

    var workingWithSlice = blocks.items[0..];
    var poop: usize = 0;
    while (workingWithSlice.len > 0) {
        poop += 1;
        std.debug.print("------{any}------\n", .{workingWithSlice});
        if (std.mem.indexOf(?usize, workingWithSlice, &[_]?usize{null})) |emptySpotStart| {
            if (std.mem.indexOfNone(?usize, workingWithSlice[emptySpotStart..], &[_]?usize{null})) |emptySpotSize| {
                var targetSearchSlice = workingWithSlice[emptySpotStart + emptySpotSize ..];
                while (targetSearchSlice.len > 0) {
                    if (std.mem.indexOf(?usize, targetSearchSlice, &[_]?usize{targetSearchSlice[targetSearchSlice.len - 1]})) |startOfReplacementSlice| {
                        const sizeOfSlice = targetSearchSlice.len - startOfReplacementSlice;
                        std.debug.print("{any}, {any},{d},{d}\n", .{ targetSearchSlice, targetSearchSlice[startOfReplacementSlice..], emptySpotSize, sizeOfSlice });
                        if (emptySpotSize >= sizeOfSlice) {
                            for (0..sizeOfSlice) |i| {
                                workingWithSlice[emptySpotStart + i] = targetSearchSlice[targetSearchSlice.len - 1];
                                targetSearchSlice[startOfReplacementSlice + i] = null;
                            }
                            workingWithSlice = workingWithSlice[emptySpotStart + sizeOfSlice .. workingWithSlice.len - 1 - sizeOfSlice];
                            break;
                        } else {
                            if (std.mem.lastIndexOfNone(?usize, targetSearchSlice, &[_]?usize{ targetSearchSlice[targetSearchSlice.len - 1], null })) |startOfNextFile| {
                                targetSearchSlice = targetSearchSlice[0 .. startOfNextFile + 1];
                            } else {
                                break;
                            }
                        }
                    }
                }
                // std.mem.lastIndexOf(?usize, haystack: workingWithSlice[emptySpotSize+])
                // break;
                // workingWithSlice = std.mem.trimRight(?usize, workingWithSlice[emptySpotStart + emptySpotSize ..], &[_]?usize{null});
            } else break;
        } else break;
        if (poop > 20) break;
    }

    std.debug.print("part2: {any}\n", .{0});
}

pub export fn day09() void {
    std.debug.print("-day09-\n", .{});

    // part1() catch unreachable;
    part2() catch unreachable;
}
