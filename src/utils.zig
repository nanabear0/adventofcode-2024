pub const Point = struct {
    x: isize,
    y: isize,
    pub fn add(self: *Point, other: Point) Point {
        return Point{ .x = self.x + other.x, .y = self.y + other.y };
    }
    pub fn subtract(self: *Point, other: Point) Point {
        return Point{ .x = self.x - other.x, .y = self.y - other.y };
    }
};
