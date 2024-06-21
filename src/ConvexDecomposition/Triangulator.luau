local PubTypes = require(script.Parent.Parent.PubTypes)

local Triangulator = {}

--[[
@returns a flat list of points which make up a triangle
]]
function Triangulator.triangulate(polygon: PubTypes.Polygon): TriangleList
    return {}
end

export type TriangleList = {Vector2}

return Triangulator