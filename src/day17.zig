const std = @import("std");
const mvzr = @import("mvzr");
const Point = @import("utils.zig").Point;
const Vector = @import("utils.zig").Vector;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

const input = std.mem.trim(u8, @embedFile("inputs/day17.txt"), "\n");

fn garbage(am: usize) [16]?usize {
    var output = [_]?usize{null} ** 16;
    var i: u5 = 0;
    var a = am;
    var b: usize = 0;
    var c: usize = 0;
    while (a != 0) {
        b = a % 8;
        b = b ^ 5;
        c = a >> @intCast(b);
        b = b ^ 6;
        b = b ^ c;
        output[i] = b % 8;

        a = a / 8;
        i += 1;
    }
    return output;
}

fn doThing() !void {
    const target = [16]?usize{ 2, 4, 1, 5, 7, 5, 1, 6, 0, 3, 4, 3, 5, 5, 3, 0 };
    std.debug.print("part1: {any}\n", .{garbage(34615120)});
    std.debug.print("part2: fuck you\n", .{});

    // var str = [16]u8{ '1', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0' };
    // digits: for (0..16) |digit| {
    //     for (0..8) |value| {
    //         str[15 - digit] = @as(u8, @intCast(value)) + '0';
    //         std.debug.print("trying {s}\n", .{str});
    //         if (ananinAmi(try std.fmt.parseInt(usize, &str, 8), digit + 1)) {
    //             std.debug.print("matches {d}th digit\n\n", .{digit});
    //             continue :digits;
    //         }
    //     }
    //     std.debug.print("I fucked up at digit {d}\n\n", .{digit});
    //     break;
    // }
    // yolo taimu
    var a: usize = try std.fmt.parseInt(usize, "1000000000000000", 8);
    while (true) : (a += 1) {
        const result = garbage(a);
        if (std.mem.eql(?usize, &target, &result)) {
            std.debug.print("part2: {any}\n", .{a});
            break;
        }
    }
    // std.debug.print("\npart2: {any}\n", .{try std.fmt.parseInt(usize, &str, 8)});
}

pub export fn day17() void {
    doThing() catch unreachable;
}
