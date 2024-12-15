const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day05.txt"), "\n");

fn part1() !void {
    var inputSpliIter = std.mem.split(u8, input, "\n\n");
    const rules = inputSpliIter.next().?;
    const tests = inputSpliIter.next().?;

    var infractions = std.AutoHashMap(usize, std.AutoHashMap(usize, void)).init(std.heap.page_allocator);
    defer infractions.deinit();
    defer {
        var iter = infractions.valueIterator();
        while (iter.next()) |dep| dep.deinit();
    }

    var rulesIter = std.mem.split(u8, rules, "\n");
    while (rulesIter.next()) |rule| {
        var partsIter = std.mem.split(u8, rule, "|");
        const v1 = try std.fmt.parseInt(usize, partsIter.next().?, 10);
        const v2 = try std.fmt.parseInt(usize, partsIter.next().?, 10);
        var set = try infractions.getOrPutValue(v2, std.AutoHashMap(usize, void).init(std.heap.page_allocator));
        try set.value_ptr.put(v1, {});
    }

    var acc: usize = 0;
    var testsIter = std.mem.split(u8, tests, "\n");
    var pages = std.ArrayList(usize).init(std.heap.page_allocator);
    defer pages.deinit();
    tests: while (testsIter.next()) |currentTest| {
        pages.clearRetainingCapacity();
        var pagesIter = std.mem.split(u8, currentTest, ",");
        while (pagesIter.next()) |page| try pages.append(try std.fmt.parseInt(usize, page, 10));
        for (pages.items, 0..) |page, i| {
            if (infractions.get(page)) |nonAllowedPages| {
                for (pages.items[i + 1 ..]) |nextPage| {
                    if (nonAllowedPages.getKey(nextPage)) |_| {
                        continue :tests;
                    }
                }
            }
        }
        acc += pages.items[pages.items.len / 2];
    }
    std.debug.print("part1: {d}\n", .{acc});
}

fn part2() !void {
    var inputSpliIter = std.mem.split(u8, input, "\n\n");
    const rules = inputSpliIter.next().?;
    const tests = inputSpliIter.next().?;

    var infractions = std.AutoHashMap(usize, std.AutoHashMap(usize, void)).init(std.heap.page_allocator);
    defer infractions.deinit();
    defer {
        var iter = infractions.valueIterator();
        while (iter.next()) |dep| dep.deinit();
    }

    var rulesIter = std.mem.split(u8, rules, "\n");
    while (rulesIter.next()) |rule| {
        var partsIter = std.mem.split(u8, rule, "|");
        const v1 = try std.fmt.parseInt(usize, partsIter.next().?, 10);
        const v2 = try std.fmt.parseInt(usize, partsIter.next().?, 10);
        var set = try infractions.getOrPutValue(v2, std.AutoHashMap(usize, void).init(std.heap.page_allocator));
        try set.value_ptr.put(v1, {});
    }

    var acc: usize = 0;
    var testsIter = std.mem.split(u8, tests, "\n");
    var pages = std.ArrayList(usize).init(std.heap.page_allocator);
    defer pages.deinit();
    while (testsIter.next()) |currentTests| {
        pages.clearRetainingCapacity();
        var pagesIter = std.mem.split(u8, currentTests, ",");
        while (pagesIter.next()) |page| try pages.append(try std.fmt.parseInt(usize, page, 10));

        var foundError = false;
        tryFixing: while (true) {
            for (pages.items, 0..) |page, i| {
                if (infractions.get(page)) |nonAllowedPages| {
                    for (pages.items[i + 1 ..], (i + 1)..) |nextPage, j| {
                        if (nonAllowedPages.getKey(nextPage)) |_| {
                            for (i..j) |l| {
                                std.mem.swap(usize, &pages.items.ptr[j], &pages.items.ptr[l]);
                            }
                            foundError = true;
                            continue :tryFixing;
                        }
                    }
                }
            }
            if (foundError) {
                acc += pages.items[pages.items.len / 2];
            }
            break :tryFixing;
        }
    }

    std.debug.print("part2: {d}\n", .{acc});
}

pub export fn day05() void {
    std.debug.print("-day05-\n", .{});
    part1() catch unreachable;
    part2() catch unreachable;
}
