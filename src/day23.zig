const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day23.txt"), "\n");

fn setClone(s: *const std.StringHashMap(void)) !std.StringHashMap(void) {
    var result = std.StringHashMap(void).init(gpa);
    var sIter = s.keyIterator();
    while (sIter.next()) |sItem| try result.put(sItem.*, {});
    return result;
}

fn setUnion(s1: *const std.StringHashMap(void), s2: *const std.StringHashMap(void)) !std.StringHashMap(void) {
    var result = std.StringHashMap(void).init(gpa);
    var s1Iter = s1.keyIterator();
    while (s1Iter.next()) |s1Item| try result.put(s1Item.*, {});
    var s2Iter = s2.keyIterator();
    while (s2Iter.next()) |s2Item| try result.put(s2Item.*, {});
    return result;
}

fn setIntersection(s1: *const std.StringHashMap(void), s2: *const std.StringHashMap(void)) !std.StringHashMap(void) {
    var result = std.StringHashMap(void).init(gpa);
    var s1Iter = s1.keyIterator();
    while (s1Iter.next()) |s1Item| if (s2.contains(s1Item.*)) try result.put(s1Item.*, {});
    return result;
}

fn BronKerboschInner(
    map: *std.StringHashMap(std.StringHashMap(void)),
    r: *std.StringHashMap(void),
    p: *std.StringHashMap(void),
    x: *std.StringHashMap(void),
    result: *std.ArrayList([]const u8),
) !void {
    if (p.count() == 0 and x.count() == 0) {
        if (r.count() > result.items.len) {
            result.clearRetainingCapacity();
            var rIter = r.keyIterator();
            while (rIter.next()) |rItem| try result.append(rItem.*);
        }
        return;
    }

    var pIter = p.keyIterator();
    while (pIter.next()) |v| {
        var newR = try setClone(r);
        try newR.put(v.*, {});
        var newP = try setIntersection(p, map.getPtr(v.*).?);
        var newX = try setIntersection(p, map.getPtr(v.*).?);
        defer newR.deinit();
        defer newP.deinit();
        defer newX.deinit();
        try BronKerboschInner(map, &newR, &newP, &newX, result);
        _ = p.remove(v.*);
        try x.put(v.*, {});
    }
}

fn BronKerboschOuter(
    map: *std.StringHashMap(std.StringHashMap(void)),
) !std.ArrayList([]const u8) {
    var r = std.StringHashMap(void).init(gpa);
    var p = std.StringHashMap(void).init(gpa);
    var mapKeysIter = map.keyIterator();
    while (mapKeysIter.next()) |key| try p.put(key.*, {});
    var x = std.StringHashMap(void).init(gpa);
    defer r.deinit();
    defer p.deinit();
    defer x.deinit();
    var result = std.ArrayList([]const u8).init(gpa);
    try BronKerboschInner(map, &r, &p, &x, &result);
    return result;
}

fn lessThanFn(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.order(u8, a, b) == std.math.Order.lt;
}

fn part2() !void {
    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var map = std.StringHashMap(std.StringHashMap(void)).init(gpa);
    defer map.deinit();
    while (inputIter.next()) |line| {
        var lineIter = std.mem.splitScalar(u8, line, '-');
        const n1 = lineIter.next().?;
        const n2 = lineIter.next().?;
        var n1Entry = try map.getOrPutValue(n1, std.StringHashMap(void).init(gpa));
        try n1Entry.value_ptr.put(n2, {});
        var n2Entry = try map.getOrPutValue(n2, std.StringHashMap(void).init(gpa));
        try n2Entry.value_ptr.put(n1, {});
    }

    const result = try BronKerboschOuter(&map);
    std.mem.sort([]const u8, result.items, {}, lessThanFn);

    std.debug.print("part2: ", .{});
    std.debug.print("{s}", .{result.items[0]});
    for (result.items[1..]) |r| {
        std.debug.print(",{s}", .{r});
    }
}

fn fillMap() !std.StringHashMap(std.StringArrayHashMap(void)) {
    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var map = std.StringHashMap(std.StringArrayHashMap(void)).init(gpa);
    defer map.deinit();
    while (inputIter.next()) |line| {
        var lineIter = std.mem.splitScalar(u8, line, '-');
        const n1 = lineIter.next().?;
        const n2 = lineIter.next().?;
        var n1Entry = try map.getOrPutValue(n1, std.StringArrayHashMap(void).init(gpa));
        try n1Entry.value_ptr.put(n2, {});
        var n2Entry = try map.getOrPutValue(n2, std.StringArrayHashMap(void).init(gpa));
        try n2Entry.value_ptr.put(n1, {});
    }
    return map;
}

fn part1() !void {
    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var map = std.StringHashMap(std.StringArrayHashMap(void)).init(gpa);
    var proccessedTs = std.StringHashMap(void).init(gpa);
    defer map.deinit();
    defer proccessedTs.deinit();
    while (inputIter.next()) |line| {
        var lineIter = std.mem.splitScalar(u8, line, '-');
        const n1 = lineIter.next().?;
        const n2 = lineIter.next().?;
        var n1Entry = try map.getOrPutValue(n1, std.StringArrayHashMap(void).init(gpa));
        try n1Entry.value_ptr.put(n2, {});
        var n2Entry = try map.getOrPutValue(n2, std.StringArrayHashMap(void).init(gpa));
        try n2Entry.value_ptr.put(n1, {});
    }

    var mapIter = map.iterator();
    var result: usize = 0;
    while (mapIter.next()) |nodeEntry| {
        const n1 = nodeEntry.key_ptr.*;
        if (n1[0] != 't') continue;
        try proccessedTs.put(n1, {});
        const neighbours = nodeEntry.value_ptr.keys();
        for (0..neighbours.len - 1) |i| {
            for (i + 1..neighbours.len) |j| {
                const n2 = neighbours[i];
                const n3 = neighbours[j];
                if (proccessedTs.contains(n2)) continue;
                if (proccessedTs.contains(n3)) continue;
                if (!map.get(n2).?.contains(n3)) continue;
                if (!map.get(n3).?.contains(n2)) continue;
                result += 1;
            }
        }
    }

    std.debug.print("\npart1: {d}\n", .{result});
}

pub export fn day23() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
