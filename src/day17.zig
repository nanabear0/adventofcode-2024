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
            // adv
            0 => {
                if (insPointer == operations.items.len - 1) break;
                registers[0] = registers[0] >> @intCast(getCombo(operations.items[insPointer + 1], registers));
            },
            // bxl
            1 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[1] ^ operations.items[insPointer + 1];
            },
            // bst
            2 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = getCombo(operations.items[insPointer + 1], registers) % 8;
            },
            // jnz
            3 => {
                if (registers[0] != 0) {
                    if (insPointer == operations.items.len - 1) break;
                    insPointer = operations.items[insPointer + 1];
                    continue;
                }
            },
            // bxc
            4 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[1] ^ registers[2];
            },
            // out
            5 => {
                if (insPointer == operations.items.len - 1) break;
                try outputBuffer.append(getCombo(operations.items[insPointer + 1], registers) % 8);
            },
            // bdv
            6 => {
                if (insPointer == operations.items.len - 1) break;
                registers[1] = registers[0] >> @intCast(getCombo(operations.items[insPointer + 1], registers));
            },
            // cdv
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

fn doThing() !void {
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

    std.debug.print("output: {any}\n", .{outputBuffer.items});
}

pub export fn day17() void {
    doThing() catch unreachable;
}
