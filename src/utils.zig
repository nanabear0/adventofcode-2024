pub const Point = struct {
    x: isize,
    y: isize,
    pub fn add(self: *const Point, other: Point) Point {
        return Point{ .x = self.x + other.x, .y = self.y + other.y };
    }
    pub fn subtract(self: *const Point, other: Point) Point {
        return Point{ .x = self.x - other.x, .y = self.y - other.y };
    }
    pub fn equals(self: *const Point, other: Point) bool {
        return self.x == other.x and self.y == other.y;
    }
    pub fn containedBy(self: *const Point, start: Point, end: Point) bool {
        return self.x >= start.x and self.x <= end.x and self.y >= start.y and self.y <= end.y;
    }
};
