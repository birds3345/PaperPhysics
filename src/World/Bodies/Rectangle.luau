local RigidBody = require(script.Parent.RigidBody)

local BodyRTTI = require(script.Parent.BodyRTTI)

local Rectangle = setmetatable({}, RigidBody)
Rectangle.__index = Rectangle
Rectangle._classIndex = BodyRTTI(Rectangle, RigidBody)

function Rectangle:setSize(size: Vector2): ()
    self.size = size
    self._inertia = 1 / 12 * self.mass * (size.Y * size.Y + size.X * size.X)
    self._inverseInertia = 1 / self._inertia

    self._area = size.X * size.Y
    self._centroid = Vector2.zero
end

function Rectangle.new(): Rectangle
    local self = setmetatable(RigidBody.new(), Rectangle)
    
    return self
end

export type Rectangle = typeof(setmetatable({} :: {
    setSize: (self: Rectangle, size: Vector2) -> ();
}, Rectangle)) & RigidBody.RigidBody

return Rectangle