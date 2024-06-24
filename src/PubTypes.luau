export type ConvexPolygon = {Vector3};
export type ConcavePolygon = {Vector3};
export type Polygon = ConvexPolygon | ConcavePolygon;

export type Box = {
    topLeft: Vector3;
    bottomRight: Vector3;
}

export type Point = Vector3;

export type Matrix2x2 = {
    m00: number;
    m01: number;
    m10: number;
    m11: number;
}

return nil