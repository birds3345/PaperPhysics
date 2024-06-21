local PubTypes = require(script.Parent.Parent.PubTypes)

local Box = {}

function Box.intersects(box1: PubTypes.Box, box2: PubTypes.Box): boolean
    return not (box1.bottomRight.X < box2.topLeft.X or box1.bottomRight.Y > box2.topLeft.Y or box1.topLeft.X > box2.bottomRight.X or box1.topLeft.Y < box2.bottomRight.Y)
end

--[[
@returns true if box1 is completely encapsulated by box2 (inclusive)
]]
function Box.contains(box1: PubTypes.Box, box2: PubTypes.Box): boolean
    return box1.topLeft.X >= box2.topLeft.X and box1.topLeft.Y <= box2.topLeft.Y and box1.bottomRight.X <= box2.bottomRight.X and box1.bottomRight.Y >= box2.bottomRight.Y
end

function Box.size(box: PubTypes.Box): Vector2
    return (box.topLeft - box.bottomRight):Abs()
end

function Box.translate(box: PubTypes.Box, translation: Vector2): PubTypes.Box
    return {
        topLeft = box.topLeft + translation;
        bottomRight = box.bottomRight + translation;
    }
end

function Box.new(topLeft: Vector2, bottomRight: Vector2): PubTypes.Box
    return {
        topLeft = topLeft;
        bottomRight = bottomRight;
    }
end

function Box.point(point: Vector2): PubTypes.Box
    return {
        topLeft = point;
        bottomRight = point;
    }
end

return Box