local RigidBody = require(script.Parent.RigidBody)

local BodyRTTI = require(script.Parent.BodyRTTI)

local Circle = setmetatable({}, RigidBody)
Circle.__index = Circle
Circle._classIndex = BodyRTTI(Circle, RigidBody)

function Circle:setRadius(radius: number): ()
    self.radius = radius
    self.size = Vector2.new(radius * 2, radius * 2)

    self._inertia = 0.5 * self.mass * self.radius * self.radius
    self._inverseInertia = 1 / self._inertia

    self._area = math.pi * radius * radius
    self._centroid = Vector2.zero
end

function Circle.new(): Circle
    local self = setmetatable(RigidBody.new(), Circle)
    self.radius = 0
    
    return self
end

export type Circle = typeof(setmetatable({} :: {
    radius: number;

    setRadius: (self: Circle, radius: number) -> ();
}, Circle)) & RigidBody.RigidBody

return Circle