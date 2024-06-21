--!native

local Bodies = script.Parent.Parent.Bodies
local Body = require(Bodies.Body)
local RigidBody = require(Bodies.RigidBody)
local Particle = require(Bodies.Particle)
local Circle = require(Bodies.Circle)
local Rectangle = require(Bodies.Rectangle)

local BodyIs = require(Bodies.BodyIs)

local CollisionResolver = require(script.Parent.Collision.CollisionResolver)
local CollisionDetection = require(script.Parent.Collision.CollisionDetection)
local CollisionManifold = require(script.Parent.Collision.CollisionManifold)

local PubTypes = require(script.Parent.Parent.Parent.PubTypes)

local Utility = script.Parent.Parent.Parent.Utility
local ShapeUtility = require(script.Parent.ShapeUtility)
local QuadTree = require(Utility.QuadTree)
local Box = require(Utility.Box)
local Matrix2x2 = require(Utility.Matrix2x2)

type CollisionPair = {
    body1: number;
    body2: number;
}

local function _fuzzyEqVec2(v1: Vector2, v2: Vector2, epsilon: number?): boolean
    if not epsilon then
        epsilon = 2.22045e-16
    end
    
    local diff = v1 - v2
    return diff.X * diff.X + diff.Y * diff.Y < epsilon :: any * epsilon
end

local Solver = {}
Solver.__index = Solver

local function recalculateBoundingBox(body: Body.Body): PubTypes.Box
    if BodyIs(body, Circle) then
        local circle: Circle.Circle = body
        return Box.new(circle.position + Vector2.new(-circle.radius, circle.radius), circle.position + Vector2.new(circle.radius, -circle.radius))
    end

    if BodyIs(body, Rectangle) then
        local rectangle: Rectangle.Rectangle = body

        local b1, b2, b3, b4 = ShapeUtility.calculateRectangleVertices(rectangle)

        local tlx = math.min(rectangle.position.X, b1.X, b2.X, b3.X, b4.X)
        local tly = math.max(rectangle.position.Y, b1.Y, b2.Y, b3.Y, b4.Y)

        local brx = math.max(rectangle.position.X, b1.X, b2.X, b3.X, b4.X)
        local bry = math.min(rectangle.position.Y, b1.Y, b2.Y, b3.Y, b4.Y)
        
        return Box.new(Vector2.new(tlx, tly), Vector2.new(brx, bry))
    end

    error("body parameter is not an body")
end

function Solver:_updateBodies(delta: number): ()
    for _, body: Body.Body in self._bodies do
        if body.static then
            body.velocity = Vector2.zero

            body.mass = 0
            body._inverseMass = 0

            if BodyIs(body, RigidBody) then
                local rigidBody: RigidBody.RigidBody = body
                rigidBody._boundingBox = recalculateBoundingBox(rigidBody)
                rigidBody.angularVelocity = 0
                
                rigidBody._inertia = 0
                rigidBody._inverseInertia = 0
            end

            continue
        end
        
        if BodyIs(body, Particle) then

        elseif BodyIs(body, RigidBody) then
            local rigidBody: RigidBody.RigidBody = body
            
            local acceleration: Vector2 = (rigidBody._force * rigidBody._inverseMass + rigidBody.gravity) :: any --luau thinks this is a number for some reason
            
            rigidBody.velocity += acceleration * delta
            if math.abs(rigidBody.velocity.X) <= 0.001 then
                rigidBody.velocity = Vector2.new(0, rigidBody.velocity.Y)
            end
            if math.abs(rigidBody.velocity.Y) <= 0.001 then
                rigidBody.velocity = Vector2.new(rigidBody.velocity.X, 0)
            end

            rigidBody.position += rigidBody.velocity * delta
            
            rigidBody.rotation = Matrix2x2.multiplyMM(rigidBody.rotation, Matrix2x2.fromAngle(rigidBody.angularVelocity * delta))
            
            rigidBody._boundingBox = recalculateBoundingBox(rigidBody)
            
            rigidBody._force = Vector2.zero
        end
    end
end

function Solver:_updateQuadTree(delta: number): ()
    self._quadTree:clear()

    for _, body: Body.Body in self._bodies do
        if BodyIs(body, Particle) then
            self._quadTree:insert(Box.point(body.position), body._bodyId)

        elseif BodyIs(body, RigidBody) then
            local rigidBody: RigidBody.RigidBody = body
            self._quadTree:insert(rigidBody._boundingBox, rigidBody._bodyId)

        end
    end
end

function Solver:_broadPhase(delta: number): ()
    table.clear(self._collisionPairs)

    --haven't benchmarked this but I assume it's faster than the O(n^2) alternative
    --body1._bodyId ^ body2._bodyId
    local hashes: {[number]: {CollisionPair}} = {}

    local function pairExists(body1: number, body2: number): boolean
        local hash = bit32.bxor(body1, body2)
        if not hashes[hash] then return false end
        
        for _, pair in hashes[hash] do
            if pair.body1 == body1 and pair.body2 == body2 or pair.body1 == body2 and pair.body2 == body1 then
                return true
            end
        end

        return false
    end

    local function insertHash(body1: number, body2: number, pair: CollisionPair): ()
        local hash = bit32.bxor(body1, body2)
        if not hashes[hash] then
            hashes[hash] = {}
        end

        table.insert(hashes[hash], pair)
    end
    
    for _, body: Body.Body in self._bodies do
        if body.static then continue end
        local bodies: {number};

        if BodyIs(body, Particle) then
            bodies = self._quadTree:query(Box.point(body.position))
        elseif BodyIs(body, RigidBody) then
            local rigidBody: RigidBody.RigidBody = body
            bodies = self._quadTree:query(rigidBody._boundingBox)
        end
        
        for _, bodyId in bodies do
            if bodyId == body._bodyId then continue end
            if pairExists(body._bodyId, bodyId) then continue end
            
            local collisionPair: CollisionPair = {
                body1 = body._bodyId;
                body2 = bodyId;
            }
            
            insertHash(body._bodyId, bodyId, collisionPair)
            table.insert(self._collisionPairs, collisionPair)
        end
    end
end

function Solver:_narrowPhase(delta: number): ()
    table.clear(self._manifolds)

    for _, pair: CollisionPair in self._collisionPairs do
        local manifold = CollisionDetection.collide(self._bodyIdMap[pair.body1], self._bodyIdMap[pair.body2])
        
        if manifold then
            table.insert(self._manifolds, manifold)
        end
    end
end

function Solver:_resolveCollision(delta: number): ()
    for _, manifold: CollisionManifold.CollisionManifold in self._manifolds do
        CollisionResolver.resolve(manifold)
    end
end

function Solver:update(delta: number): ()
    self:_updateBodies(delta)
    self:_updateQuadTree(delta)

    self:_broadPhase(delta)
    self:_narrowPhase(delta)
    self:_resolveCollision(delta)
end

function Solver.new(bodies: {Body.Body}, bodyIdMap: {[number]: Body.Body}, quadTree: QuadTree.QuadTree<number>)
    return setmetatable({
        _bodies = bodies;
        _bodyIdMap = bodyIdMap;
        _quadTree = quadTree;

        _manifolds = table.create(16) :: {CollisionManifold.CollisionManifold};
        _collisionPairs = table.create(16) :: {CollisionPair};
    }, Solver)
end

export type Solver = typeof(Solver.new({}, QuadTree.new(0, Box.point(Vector2.zero))))

return Solver