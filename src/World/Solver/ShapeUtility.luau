local Rectangle = require(script.Parent.Parent.Bodies.Rectangle)

local Matrix2x2 = require(script.Parent.Parent.Parent.Utility.Matrix2x2)

local ShapeUtility = {}

function ShapeUtility.calculateRectangleVertices(rectangle: Rectangle.Rectangle): (Vector3, Vector3, Vector3, Vector3)
    local half: Vector3 = (rectangle.size / 2) :: any --luau thinks this is a number for some reason

    local c1 = Vector3.new(-half.X, half.Y)
    local c2 = Vector3.new(half.X, half.Y)
    local c3 = Vector3.new(half.X, -half.Y)
    local c4 = Vector3.new(-half.X, -half.Y)

    local b1 = Matrix2x2.multiplyMV(rectangle.rotation, c1) + rectangle.position
    local b2 = Matrix2x2.multiplyMV(rectangle.rotation, c2) + rectangle.position
    local b3 = Matrix2x2.multiplyMV(rectangle.rotation, c3) + rectangle.position
    local b4 = Matrix2x2.multiplyMV(rectangle.rotation, c4) + rectangle.position

    return b1, b2, b3, b4
end

return ShapeUtility