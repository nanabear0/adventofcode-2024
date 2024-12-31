const std = @import("std");

const input = std.mem.trim(u8, @embedFile("inputs/day01.txt"), "\n");

fn part1() !void {
    var lines = std.mem.split(u8, input, "\n");
    var firstList = std.ArrayList(i32).init(std.heap.page_allocator);
    var secondList = std.ArrayList(i32).init(std.heap.page_allocator);
    defer firstList.deinit();
    defer secondList.deinit();

    while (lines.next()) |line| {
        var sides = std.mem.split(u8, line, "   ");
        try firstList.append(try std.fmt.parseInt(i32, sides.next().?, 10));
        try secondList.append(try std.fmt.parseInt(i32, sides.next().?, 10));
    }
    std.mem.sort(i32, firstList.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, secondList.items, {}, comptime std.sort.asc(i32));

    var acc: u32 = 0;
    for (firstList.items, secondList.items) |x, y| {
        acc = acc + @abs(x - y);
    }

    std.debug.print("part1: {d}\n", .{acc});
}

fn part2() !void {
    var lines = std.mem.split(u8, input, "\n");
    var firstList = std.ArrayList(u32).init(std.heap.page_allocator);
    var secondListMap = std.AutoHashMap(u32, u32).init(std.heap.page_allocator);
    defer firstList.deinit();
    defer secondListMap.deinit();

    while (lines.next()) |line| {
        var sides = std.mem.split(u8, line, "   ");
        try firstList.append(try std.fmt.parseInt(u32, sides.next().?, 10));

        const countEntry = try secondListMap.getOrPutValue(try std.fmt.parseInt(u32, sides.next().?, 10), 0);
        countEntry.value_ptr.* += 1;
    }

    var acc: u32 = 0;
    for (firstList.items) |elem| {
        acc += elem * (secondListMap.get(elem) orelse 0);
    }

    std.debug.print("part2: {d}\n", .{acc});
}

pub fn day01() void {
    std.debug.print("-day01-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
