const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day14.txt"), "\n");

const Robot = struct {
    p: Point,
    v: Point,
    pub fn move(self: *Robot, boundary: Point) void {
        self.p = self.p.add(self.v);
        self.p.x = @mod((self.p.x), boundary.x);
        self.p.y = @mod((self.p.y), boundary.y);
    }
};

fn doThing() !void {
    const boundary = Point{ .x = 101, .y = 103 };
    const numRegex = mvzr.compile("-?[0-9]+").?;
    var robots = std.ArrayList(Robot).init(gpa);
    defer robots.deinit();

    var numIter = numRegex.iterator(input);
    while (numIter.next()) |pxmatch| {
        const px = try std.fmt.parseInt(isize, pxmatch.slice, 10);
        const py = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        const vx = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        const vy = try std.fmt.parseInt(isize, numIter.next().?.slice, 10);
        try robots.append(Robot{ .p = Point{ .x = px, .y = py }, .v = Point{ .x = vx, .y = vy } });
    }

    var mapperino = std.AutoHashMap(Point, usize).init(gpa);
    defer mapperino.deinit();
    var printBuffer = std.ArrayList(u8).init(gpa);
    defer printBuffer.deinit();
    keeptrying: for (1..10000) |i| {
        mapperino.clearRetainingCapacity();
        for (robots.items) |*robot| {
            robot.move(boundary);
            const mapPos = try mapperino.getOrPutValue(robot.p, 0);
            mapPos.value_ptr.* += 1;
        }

        var mapperinoIter = mapperino.keyIterator();
        while (mapperinoIter.next()) |pointo| {
            var p = pointo.*;
            var c: usize = 0;
            while (mapperino.contains(p)) : (c += 1) {
                if (c == 6) {
                    std.debug.print("part2: {d}\n", .{i});
                    break :keeptrying;
                }
                p = p.add(Point{ .x = 1, .y = 0 });
            }
        }
        if (i == 100) {
            var sums = [4]usize{ 0, 0, 0, 0 };
            const midPoint = Point{ .x = @divTrunc(boundary.x, 2), .y = @divTrunc(boundary.y, 2) };
            for (robots.items) |robot| {
                if (robot.p.x < midPoint.x and robot.p.y < midPoint.y) sums[0] += 1;
                if (robot.p.x < midPoint.x and robot.p.y > midPoint.y) sums[1] += 1;
                if (robot.p.x > midPoint.x and robot.p.y < midPoint.y) sums[2] += 1;
                if (robot.p.x > midPoint.x and robot.p.y > midPoint.y) sums[3] += 1;
            }

            var result: usize = 1;
            for (sums) |sum| result *= sum;
            std.debug.print("part1: {d}\n", .{result});
        }
    }
}

pub fn day14() void {
    std.debug.print("-day14-\n", .{});

    doThing() catch unreachable;
}
