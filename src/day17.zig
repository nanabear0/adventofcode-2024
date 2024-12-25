const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day17.txt"), "\n");

fn getCombo(value: usize, registers: [3]usize) usize {
    return switch (value) {
        0, 1, 2, 3 => value,
        4, 5, 6 => registers[value - 4],
        else => unreachable,
    };
}

fn runCode(operations: std.ArrayList(usize), initialA: usize) !std.ArrayList(usize) {
    var registers = [3]usize{ initialA, 0, 0 };
    var outputBuffer = std.ArrayList(usize).init(gpa);
    var insPointer: usize = 0;
    while (insPointer < operations.items.len) {
        switch (operations.items[insPointer]) {
            0 => {
                if (insPointer == operations.items.len - 1) break;
                registers[0] = registers[0] >> @intCast(getCombo(operations.items[insPointer + 1], registers));
            },
            1 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[1] ^ operations.items[insPointer + 1];
            },
            2 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = getCombo(operations.items[insPointer + 1], registers) % 8;
            },
            3 => {
                if (registers[0] != 0) {
                    if (insPointer == operations.items.len - 1) break;
                    insPointer = operations.items[insPointer + 1];
                    continue;
                }
            },
            4 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[1] ^ registers[2];
            },
            5 => {
                if (insPointer == operations.items.len - 1) break;
                try outputBuffer.append(getCombo(operations.items[insPointer + 1], registers) % 8);
            },
            6 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[0] >> @intCast(getCombo(operations.items[insPointer + 1], registers));
            },
            7 => {
                if (insPointer == operations.items.len - 1) break;
                registers[2] = registers[0] >> @intCast(getCombo(operations.items[insPointer + 1], registers));
            },
            else => unreachable,
        }
        insPointer += 2;
    }
    return outputBuffer;
}

fn part1() !void {
    var operations = std.ArrayList(usize).init(gpa);
    defer operations.deinit();

    const numRegex = mvzr.compile("-?[0-9]+").?;
    var numIter = numRegex.iterator(input);
    const initialA = try std.fmt.parseInt(usize, numIter.next().?.slice, 10);
    _ = numIter.next().?;
    _ = numIter.next().?;
    while (numIter.next()) |opmatch| {
        try operations.append(try std.fmt.parseInt(usize, opmatch.slice, 10));
    }

    const outputBuffer = try runCode(operations, initialA);
    defer outputBuffer.deinit();

    std.debug.print("part1: {any}\n", .{outputBuffer.items});
}

fn runCodeNative(am: usize) !usize {
    var output: usize = 0;
    var a = am;
    var b: usize = 0;
    var c: usize = 0;
    while (a != 0) : (a /= 8) {
        b = a % 8 ^ 5;
        c = a >> @intCast(b);
        b = b ^ 6 ^ c;
        output = output * 8 + b % 8;
    }
    return output;
}

fn part2() !void {
    const target = try std.fmt.parseInt(usize, "2415751603435530", 8);
    var searchList = std.ArrayList(usize).init(gpa);
    var nextList = std.ArrayList(usize).init(gpa);
    defer searchList.deinit();
    defer nextList.deinit();
    try searchList.append(0);
    for (0..16) |digit| {
        nextList.clearRetainingCapacity();
        for (searchList.items) |option| {
            for (0..8) |value| {
                const clone = option * 8 + value;
                if (try runCodeNative(clone) == target % try std.math.powi(
                    usize,
                    8,
                    digit + 1,
                )) {
                    try nextList.append(clone);
                }
            }
        }
        std.mem.swap(std.ArrayList(usize), &searchList, &nextList);
        nextList.clearRetainingCapacity();
    }

    const smallest = std.mem.min(usize, searchList.items);
    std.debug.print("part2: {d}\n", .{smallest});
}

pub export fn day17() void {
    std.debug.print("-day17-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
