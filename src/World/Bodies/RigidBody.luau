local PubTypes = require(script.Parent.Parent.Parent.PubTypes)

local Utility = script.Parent.Parent.Parent.Utility
local Matrix2x2 = require(Utility.Matrix2x2)
local Box = require(Utility.Box)

local BodyRTTI = require(script.Parent.BodyRTTI)
local Body = require(script.Parent.Body)

local RigidBody = setmetatable({}, Body)
RigidBody.__index = RigidBody
RigidBody._classIndex = BodyRTTI(RigidBody, Body)

function RigidBody:setRotation(radians: number): ()
    self.rotation = Matrix2x2.fromAngle(radians)
end

function RigidBody.new(): RigidBody
    local self = setmetatable(Body.new(), RigidBody)
    
    self.rotation = Matrix2x2.fromAngle(0)
    self.angularVelocity = 0

    self.restitution = 0.3
    self.friction = 0.3

    self._inertia = 0
    self._inverseInertia = 0

    self._centroid = Vector2.zero
    self._area = 0

    self._boundingBox = Box.point(Vector2.zero)
    self.size = Vector2.zero

    return self
end

export type RigidBody = typeof(setmetatable({} :: {
    rotation: PubTypes.Matrix2x2;
    angularVelocity: number;

    restitution: number;
    friction: number;

    _inertia: number;
    _inverseInertia: number;

    _centroid: Vector2;
    _area: number;

    _boundingBox: PubTypes.Box;
    size: Vector2;

    setRotation: (self: RigidBody, radians: number) -> ();
}, RigidBody)) & Body.Body

return RigidBody