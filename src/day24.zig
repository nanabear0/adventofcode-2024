const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day24.txt"), "\n");
const inputP2 = std.mem.trim(u8, @embedFile("inputs/day24-p2helper.txt"), "\n");

fn addbaby(swaps: *std.StringHashMap([]const u8), isP1: bool) !usize {
    var inputIter = std.mem.splitSequence(u8, if (isP1) input else inputP2, "\n\n");
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
        var out = iter.next().?;
        out = swaps.get(out) orelse out;
        const gate = Gate{ .a = a, .b = b, .out = out, .ins = ins };
        try gates.put(out, gate);
        if (out[0] == 'z') try zs.add(out);
    }

    var resultBuffer = std.ArrayList(u8).init(gpa);
    var alreadyAttempted = std.StringHashMap(void).init(gpa);
    defer alreadyAttempted.deinit();
    while (zs.removeOrNull()) |z| {
        alreadyAttempted.clearRetainingCapacity();
        const calcResult = try calc(z, &gates, &values, &alreadyAttempted);
        try resultBuffer.append(@as(u8, @intCast(calcResult)) + '0');
    }
    return try std.fmt.parseInt(usize, resultBuffer.items, 2);
}

fn part2() !void {
    var inputIter = std.mem.splitSequence(u8, inputP2, "\n\n");
    const inputInitialValues = inputIter.next().?;
    const inputGates = inputIter.next().?;
    var xs = std.PriorityQueue([]const u8, void, strCompare).init(gpa, {});
    var ys = std.PriorityQueue([]const u8, void, strCompare).init(gpa, {});
    var values = std.StringHashMap(u1).init(gpa);
    var gateSet = std.StringArrayHashMap(void).init(gpa);
    defer values.deinit();
    defer gateSet.deinit();
    var initialValuesIter = std.mem.splitScalar(u8, inputInitialValues, '\n');
    while (initialValuesIter.next()) |line| {
        var iter = std.mem.splitSequence(u8, line, ": ");
        const gate = iter.next().?;
        const value = try std.fmt.parseInt(u1, iter.next().?, 10);
        try values.put(gate, value);
        if (gate[0] == 'x') try xs.add(gate);
        if (gate[0] == 'y') try ys.add(gate);
    }
    var inputGatesIter = std.mem.splitScalar(u8, inputGates, '\n');
    while (inputGatesIter.next()) |line| {
        var iter = std.mem.splitSequence(u8, line, " -> ");
        _ = iter.next();
        const gate = iter.next().?;
        if (gate[0] == 'x' or gate[0] == 'y' or gate[0] == 'z') continue;
        try gateSet.put(gate, {});
    }

    var xb = std.ArrayList(u8).init(gpa);
    defer xb.deinit();
    try xb.append('0');
    while (xs.removeOrNull()) |x| {
        try xb.append(@as(u8, @intCast(values.get(x).?)) + '0');
    }
    var yb = std.ArrayList(u8).init(gpa);
    try yb.append('0');
    defer yb.deinit();
    while (ys.removeOrNull()) |y| {
        try yb.append(@as(u8, @intCast(values.get(y).?)) + '0');
    }

    const x = try std.fmt.parseInt(usize, xb.items, 2);
    const y = try std.fmt.parseInt(usize, yb.items, 2);

    var swaps = std.StringHashMap([]const u8).init(gpa);
    defer swaps.deinit();
    try swaps.put("z16", "fkb");
    try swaps.put("fkb", "z16");
    try swaps.put("z31", "rdn");
    try swaps.put("rdn", "z31");
    try swaps.put("z37", "rrn");
    try swaps.put("rrn", "z37");

    for (0..gateSet.count() - 1) |i| {
        const s1 = gateSet.keys()[i];
        if (swaps.contains(s1)) continue;
        for (i + 1..gateSet.count()) |j| {
            const s2 = gateSet.keys()[j];
            if (swaps.contains(s2)) continue;
            try swaps.put(s1, s2);
            try swaps.put(s2, s1);
            const z = addbaby(&swaps, false) catch 0;
            _ = swaps.remove(s1);
            _ = swaps.remove(s2);
            if (z == x + y) {
                std.debug.print("swap {s} and {s}: {d}+{d}={d}\n", .{ s1, s2, x, y, z });
            }
        }
    }
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
    var swaps = std.StringHashMap([]const u8).init(gpa);
    std.debug.print("part1: {d}\n", .{try addbaby(&swaps, true)});
}

const InvalidSwapError = error{InvalidSwapError};

fn calc(in: []const u8, gates: *std.StringHashMap(Gate), values: *std.StringHashMap(u1), alreadyAttempted: *std.StringHashMap(void)) !u1 {
    if (values.get(in)) |value| return value;
    if (alreadyAttempted.contains(in)) return error.InvalidSwapError;
    try alreadyAttempted.put(in, {});

    if (gates.get(in)) |gate| {
        const a = try calc(gate.a, gates, values, alreadyAttempted);
        const b = try calc(gate.b, gates, values, alreadyAttempted);
        const out = switch (gate.ins) {
            .AND => a & b,
            .OR => a | b,
            .XOR => a ^ b,
        };
        try values.put(gate.out, out);
        return out;
    } else {
        return error.InvalidSwapError;
    }
}

pub fn day24() void {
    std.debug.print("-day24-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
