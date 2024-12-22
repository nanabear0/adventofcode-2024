const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const CardinalDirections = @import("utils.zig").CardinalDirections;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day22.txt"), "\n");

fn mix(a: usize, b: usize) usize {
    return a ^ b;
}

fn prune(in: usize) usize {
    return in & 16777215;
}

fn generate(secret: usize) usize {
    var result = prune(mix(secret << 6, secret));
    result = prune(mix(result >> 5, result));
    result = prune(mix(result << 11, result));
    return result;
}

fn doThing() !void {
    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var saleResults = std.AutoHashMap([4]isize, std.ArrayList(isize)).init(gpa);
    var prices = try std.ArrayList(isize).initCapacity(gpa, 2001);
    var changes = try std.ArrayList(isize).initCapacity(gpa, 2001);
    var foundSales = std.AutoHashMap([4]isize, void).init(gpa);
    defer saleResults.deinit();
    defer {
        var saleResultsIter = saleResults.valueIterator();
        while (saleResultsIter.next()) |list| list.deinit();
    }
    defer prices.deinit();
    defer changes.deinit();
    defer foundSales.deinit();

    var p1Result: usize = 0;
    while (inputIter.next()) |line| {
        prices.clearRetainingCapacity();
        changes.clearRetainingCapacity();
        foundSales.clearRetainingCapacity();
        var secret: usize = try std.fmt.parseInt(usize, line, 10);
        try prices.append(@intCast(secret % 10));
        for (0..2000) |_| {
            secret = generate(secret);
            try prices.append(@intCast(secret % 10));
        }
        p1Result += secret;
        try changes.append(prices.items[0]);
        for (1..prices.items.len) |i| {
            try changes.append(prices.items[i] - prices.items[i - 1]);
        }

        for (3..changes.items.len) |i| {
            const seq = [4]isize{
                changes.items[i - 3],
                changes.items[i - 2],
                changes.items[i - 1],
                changes.items[i - 0],
            };
            if (foundSales.contains(seq)) continue;
            try foundSales.put(seq, {});
            if (!saleResults.contains(seq)) try saleResults.put(seq, std.ArrayList(isize).init(gpa));
            try saleResults.getPtr(seq).?.append(prices.items[i]);
        }
    }
    var p2Result: isize = 0;
    var saleResultsIter = saleResults.iterator();
    while (saleResultsIter.next()) |sales| {
        var sum: isize = 0;
        for (sales.value_ptr.items) |sale| sum += sale;
        if (p2Result < sum) p2Result = sum;
    }
    std.debug.print("part1: {d}\n", .{p1Result});
    std.debug.print("part2: {d}\n", .{p2Result});
}

pub export fn day22() void {
    doThing() catch unreachable;
}
