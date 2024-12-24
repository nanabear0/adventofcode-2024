const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day24.txt"), "\n");

fn part2() !void {
    std.debug.print("part2: {d}\n", .{0});
}

const Instruction = enum {
    AND,
    OR,
    XOR,
};

const Gate = struct {
    a: []const u8,
    b: []const u8,
    out: []const u8,
    ins: Instruction,
};

fn strCompare(_: void, a: []const u8, b: []const u8) std.math.Order {
    return std.mem.order(u8, b, a);
}

fn part1() !void {
    var inputIter = std.mem.splitSequence(u8, input, "\n\n");
    const inputInitialValues = inputIter.next().?;
    const inputGates = inputIter.next().?;
    var gates = std.StringHashMap(Gate).init(gpa);
    var zs = std.PriorityQueue([]const u8, void, strCompare).init(gpa, {});
    var values = std.StringHashMap(u1).init(gpa);
    defer gates.deinit();
    defer values.deinit();
    defer zs.deinit();
    var initialValuesIter = std.mem.splitScalar(u8, inputInitialValues, '\n');
    var inputGatesIter = std.mem.splitScalar(u8, inputGates, '\n');
    while (initialValuesIter.next()) |line| {
        var iter = std.mem.splitSequence(u8, line, ": ");
        const gate = iter.next().?;
        const value = try std.fmt.parseInt(u1, iter.next().?, 10);
        try values.put(gate, value);
    }
    while (inputGatesIter.next()) |line| {
        var iter = std.mem.splitScalar(u8, line, ' ');
        const a = iter.next().?;
        const ins: Instruction = switch (iter.next().?[0]) {
            'A' => .AND,
            'O' => .OR,
            'X' => .XOR,
            else => unreachable,
        };
        const b = iter.next().?;
        _ = iter.next().?;
        const out = iter.next().?;
        const gate = Gate{ .a = a, .b = b, .out = out, .ins = ins };
        try gates.put(out, gate);
        if (out[0] == 'z') try zs.add(out);
    }

    var resultBuffer = std.ArrayList(u8).init(gpa);
    while (zs.removeOrNull()) |z| {
        try resultBuffer.append(@as(u8, @intCast(try calc(z, &gates, &values))) + '0');
    }
    std.debug.print("part1: {d}\n", .{try std.fmt.parseInt(usize, resultBuffer.items, 2)});
}

fn calc(in: []const u8, gates: *std.StringHashMap(Gate), values: *std.StringHashMap(u1)) !u1 {
    if (values.get(in)) |value| return value;

    const gate = gates.get(in).?;
    const a = try calc(gate.a, gates, values);
    const b = try calc(gate.b, gates, values);
    return switch (gate.ins) {
        .AND => a & b,
        .OR => a | b,
        .XOR => a ^ b,
    };
}

pub export fn day24() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
