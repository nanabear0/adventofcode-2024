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

pub const CardinalDirections = [4]Point{
    Point{ .x = 0, .y = -1 },
    Point{ .x = 1, .y = 0 },
    Point{ .x = 0, .y = 1 },
    Point{ .x = -1, .y = 0 },
};

pub const Vector = struct {
    point: Point,
    dir: u3,
    pub fn move(self: *const Vector) Vector {
        return Vector{ .point = self.point.add(CardinalDirections[self.dir]), .dir = self.dir };
    }
    pub fn moveReverse(self: *const Vector) Vector {
        return Vector{ .point = self.point.subtract(CardinalDirections[self.dir]), .dir = self.dir };
    }
    pub fn turnRight(self: *const Vector) Vector {
        return Vector{ .point = self.point, .dir = (self.dir + 1) % 4 };
    }
    pub fn turnLeft(self: *const Vector) Vector {
        return Vector{ .point = self.point, .dir = (self.dir + 3) % 4 };
    }
};
