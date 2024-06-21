export type ConvexPolygon = {Vector2};
export type ConcavePolygon = {Vector2};
export type Polygon = ConvexPolygon | ConcavePolygon;

export type Box = {
    topLeft: Vector2;
    bottomRight: Vector2;
}

export type Point = Vector2;

export type Matrix2x2 = {
    m00: number;
    m01: number;
    m10: number;
    m11: number;
}

return nil