const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day03.txt"), "\n");

fn doThing(enablable: bool) !u32 {
    const validOpRegex = mvzr.compile("mul\\((:?\\d+,)+\\d+\\)|do\\(\\)|don't\\(\\)").?;
    var validOpIter = validOpRegex.iterator(input);
    var acc: u32 = 0;
    var opEnabled: bool = true;
    while (validOpIter.next()) |match| {
        if (match.slice.len == 4) {
            opEnabled = true;
        } else if (match.slice.len == 7) {
            opEnabled = false;
        } else if (!enablable or opEnabled) {
            const numRegex = mvzr.compile("\\d+").?;
            var numIter = numRegex.iterator(match.slice);
            var mulAcc: u32 = 1;
            while (numIter.next()) |num| mulAcc *= try std.fmt.parseInt(u32, num.slice, 10);
            acc += mulAcc;
        }
    }
    return acc;
}
fn part1() !void {
    std.debug.print("part1: {d}\n", .{try doThing(false)});
}

fn part2() !void {
    std.debug.print("part2: {d}\n", .{try doThing(true)});
}

pub fn day03() void {
    std.debug.print("-day03-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
