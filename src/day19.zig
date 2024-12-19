const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day19.txt"), "\n");

fn validateDesign(design: []const u8, patterns: *const std.StringHashMap(void), designValidations: *std.StringHashMap(bool)) !bool {
    if (designValidations.get(design)) |validity| {
        return validity;
    }
    if (patterns.contains(design)) {
        try designValidations.put(design, true);
        return true;
    }

    for (1..design.len + 1) |len| {
        const possiblePattern = design[0..len];
        if (patterns.contains(possiblePattern)) {
            if (try validateDesign(design[len..], patterns, designValidations)) {
                try designValidations.put(design, true);
                return true;
            }
        }
    }

    try designValidations.put(design, false);
    return false;
}

fn part1() !void {
    var questionPartsIter = std.mem.splitSequence(u8, input, "\n\n");
    var patterns = std.StringHashMap(void).init(gpa);
    defer patterns.deinit();
    var patternsParseIter = std.mem.splitSequence(u8, questionPartsIter.next().?, ", ");
    while (patternsParseIter.next()) |pattern| {
        try patterns.put(pattern, {});
    }
    var designValidations = std.StringHashMap(bool).init(gpa);
    defer designValidations.deinit();
    var designsParseIter = std.mem.splitSequence(u8, questionPartsIter.next().?, "\n");
    var validCount: usize = 0;
    while (designsParseIter.next()) |design| {
        if (try validateDesign(design, &patterns, &designValidations)) validCount += 1;
    }
    std.debug.print("part1: {d}\n", .{validCount});
}

fn part2() !void {
    std.debug.print("part2: {d}\n", .{0});
}

pub export fn day19() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
