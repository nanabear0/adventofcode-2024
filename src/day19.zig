const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day19.txt"), "\n");

fn validateDesign(design: []const u8, patterns: *const std.StringHashMap(void), designValidations: *std.StringHashMap(usize)) !usize {
    if (designValidations.get(design)) |validMoves| {
        return validMoves;
    }

    for (1..design.len) |len| {
        if (patterns.contains(design[0..len])) {
            const possibilities = try validateDesign(design[len..], patterns, designValidations);
            const entry = try designValidations.getOrPutValue(design, 0);
            entry.value_ptr.* += possibilities;
        }
    }

    if (patterns.contains(design)) {
        const entry = try designValidations.getOrPutValue(design, 0);
        entry.value_ptr.* += 1;
    }

    return designValidations.get(design) orelse 0;
}

fn part1() !void {
    var questionPartsIter = std.mem.splitSequence(u8, input, "\n\n");
    var patterns = std.StringHashMap(void).init(gpa);
    defer patterns.deinit();
    var patternsParseIter = std.mem.splitSequence(u8, questionPartsIter.next().?, ", ");
    while (patternsParseIter.next()) |pattern| {
        try patterns.put(pattern, {});
    }
    var designValidations = std.StringHashMap(usize).init(gpa);
    defer designValidations.deinit();
    var designsParseIter = std.mem.splitSequence(u8, questionPartsIter.next().?, "\n");
    var validCount: usize = 0;
    var validSum: usize = 0;
    while (designsParseIter.next()) |design| {
        const possibilities = try validateDesign(design, &patterns, &designValidations);
        if (possibilities > 0) {
            validSum += possibilities;
            validCount += 1;
        }
    }
    std.debug.print("part1: {d}\n", .{validCount});
    std.debug.print("part2: {d}\n", .{validSum});
}

fn part2() !void {}

pub fn day19() void {
    std.debug.print("-day19-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
