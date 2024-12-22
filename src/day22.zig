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
    return in % 16777216;
}

fn generate(secret: usize) usize {
    var result = prune(mix(secret * 64, secret));
    result = prune(mix(result / 32, result));
    result = prune(mix(result * 2048, result));
    return result;
}

fn recursiveGenerate(secret: usize, times: usize) usize {
    if (times == 0) return secret;
    return recursiveGenerate(generate(secret), times - 1);
}

fn part2() !void {
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
    while (inputIter.next()) |line| {
        prices.clearRetainingCapacity();
        changes.clearRetainingCapacity();
        foundSales.clearRetainingCapacity();
        var secret: usize = try std.fmt.parseInt(usize, line, 10);
        for (0..2001) |_| {
            try prices.append(@intCast(secret % 10));
            secret = generate(secret);
        }

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
    var banyanyas: isize = 0;
    var saleResultsIter = saleResults.iterator();
    while (saleResultsIter.next()) |sales| {
        var sum: isize = 0;
        for (sales.value_ptr.items) |sale| sum += sale;
        if (banyanyas < sum) banyanyas = sum;
    }
    std.debug.print("part2: {d}\n", .{banyanyas});
}

fn part1() !void {
    var inputIter = std.mem.splitScalar(u8, input, '\n');
    var result: usize = 0;
    while (inputIter.next()) |line| {
        const secret: usize = try std.fmt.parseInt(usize, line, 10);
        const out = recursiveGenerate(secret, 2000);
        result += out;
    }
    std.debug.print("part1: {d}\n", .{result});
}

pub export fn day22() void {
    part1() catch unreachable;
    part2() catch unreachable;
}
