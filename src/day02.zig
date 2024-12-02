const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day02.txt"), "\n");

fn isReportSafe(levels: []i32, skipIndex: ?usize) !bool {
    var previousDifference: ?i32 = null;
    var previousLevel: ?i32 = null;
    for (levels, 0..) |level, index| {
        if (index == skipIndex) continue;

        defer previousLevel = level;
        if (previousLevel == null) continue;

        const difference = level - previousLevel.?;
        defer previousDifference = difference;
        if (difference > 3 or difference < -3 or difference == 0) return false;
        if (previousDifference != null and difference * previousDifference.? <= 0) return false;
    }

    return true;
}

fn part1() !void {
    var lines = std.mem.split(u8, input, "\n");
    var safeReports: u32 = 0;
    while (lines.next()) |line| {
        var levels = std.ArrayList(i32).init(std.heap.page_allocator);
        defer levels.deinit();

        var lineIter = std.mem.split(u8, line, " ");
        while (lineIter.next()) |level| try levels.append(try std.fmt.parseInt(i32, level, 10));

        if (try isReportSafe(levels.items, null)) safeReports += 1;
    }

    std.debug.print("part1: {d}\n", .{safeReports});
}

fn part2() !void {
    var lines = std.mem.split(u8, input, "\n");
    var safeReports: u32 = 0;
    while (lines.next()) |line| {
        var levels = std.ArrayList(i32).init(std.heap.page_allocator);
        defer levels.deinit();

        var lineIter = std.mem.split(u8, line, " ");
        while (lineIter.next()) |level| try levels.append(try std.fmt.parseInt(i32, level, 10));

        for (0..levels.items.len) |skipIndex| {
            if (try isReportSafe(levels.items, skipIndex)) {
                safeReports += 1;
                break;
            }
        }
    }

    std.debug.print("part2: {d}\n", .{safeReports});
}

pub export fn day02() void {
    std.debug.print("-day02-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
