--!native

local PubTypes = require(script.Parent.Parent.PubTypes)
local Box = require(script.Parent.Box)

type Point<T> = {
    position: PubTypes.Box;
    point: T;
}

local QuadTree = {}
QuadTree.__index = QuadTree

function QuadTree:query<T>(searchSpace: PubTypes.Box): {T}
    local points = {}
    self:_query(searchSpace, points)
    
    return points
end

function QuadTree:_query<T>(searchSpace: PubTypes.Box, points: {T}): ()
    if not Box.intersects(searchSpace, self._boundary) then return end

    for _, point: Point<T> in self._points do
        if Box.intersects(searchSpace, point.position) then
            table.insert(points, point.point)
        end
    end

    if self._subdivided then
        self._topLeft:_query(searchSpace, points)
        self._topRight:_query(searchSpace, points)
        self._bottomLeft:_query(searchSpace, points)
        self._bottomRight:_query(searchSpace, points)
    end
end

function QuadTree:insert<T>(position: PubTypes.Box, point: T): ()
    self:_insert(position, {
        position = position;
        point = point;
    } :: Point<T>)
end

function QuadTree:_insert<T>(position: PubTypes.Box, point: Point<T>): ()
    if not Box.contains(position, self._boundary) then return end

    local size = Box.size(position)
    if size.X > self._subdivisionSize.X or size.Y > self._subdivisionSize.Y then
        table.insert(self._points, point)

        return
    end

    if #self._points >= self._maxPoints then
        self:_subdivide()
        
        --if the box is on a boundary (it is not fully contained by a subdivision), we store it in the current subdivision instead
        if not Box.contains(position, self._topLeft._boundary)
           and not Box.contains(position, self._topRight._boundary)
           and not Box.contains(position, self._bottomLeft._boundary)
           and not Box.contains(position, self._bottomRight._boundary)
        then
            table.insert(self._points, point)

            return
        end

        self._topLeft:_insert(position, point);
        self._topRight:_insert(position, point);
        self._bottomLeft:_insert(position, point);
        self._bottomRight:_insert(position, point);

        return
    end

    table.insert(self._points, point)
end

function QuadTree:_subdivide()
    if self._subdivided then return end
    self._subdivided = true

    local topLeft = self._boundary.topLeft
    local bottomRight = self._boundary.bottomRight
    local mid = (topLeft + bottomRight) / 2

    self._topLeft = QuadTree.new(self._maxPoints, Box.new(topLeft, mid))
    self._topRight = QuadTree.new(self._maxPoints, Box.new(Vector2.new(mid.X, topLeft.Y), Vector2.new(bottomRight.X, mid.Y)))
    self._bottomLeft = QuadTree.new(self._maxPoints, Box.new(Vector2.new(topLeft.X, mid.Y), Vector2.new(mid.X, bottomRight.Y)))
    self._bottomRight = QuadTree.new(self._maxPoints, Box.new(mid, bottomRight))
end

function QuadTree:clear(): ()
    self._topLeft = nil
    self._topRight = nil
    self._bottomLeft = nil
    self._bottomRight = nil
    self._subdivided = false

    table.clear(self._points)
end

function QuadTree.new<T>(maxPoints: number, boundary: PubTypes.Box)
    return setmetatable({ 
        _topLeft = nil :: QuadTree<T>?;
        _topRight = nil :: QuadTree<T>?;
        _bottomLeft = nil :: QuadTree<T>?;
        _bottomRight = nil :: QuadTree<T>?;

        _subdivided = false;
        
        _boundary = boundary;
        _subdivisionSize = Box.size(boundary) / 2;

        _maxPoints = maxPoints;
        _points = table.create(maxPoints) :: {T};
    }, QuadTree)
end

export type QuadTree<T> = typeof(setmetatable({} :: {
    _topLeft: QuadTree<T>?;
    _topRight: QuadTree<T>?;
    _bottomLeft: QuadTree<T>?;
    _bottomRight: QuadTree<T>?;

    _subdivided: boolean;

    _boundary: PubTypes.Box;
    _subdivisionSize: Vector2;

    _maxPoints: number;
    _points: {Point<T>};
}, QuadTree));

return QuadTree