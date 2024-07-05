local RunService = game:GetService("RunService")

local WorldSettings = require(script.Parent.WorldSettings)

local Solver = require(script.Parent.Solver.Solver)

local Box = require(script.Parent.Parent.Utility.Box)
local IdStream = require(script.Parent.Parent.Utility.IdStream)
local QuadTree = require(script.Parent.Parent.Utility.QuadTree)

local Body = require(script.Parent.Bodies.Body)

local World = {}
World.__index = World

function World:registerBody(body: Body.Body): ()
    --we don't assign ids at creation time since an id that
    --doesn't systematically grow is a little odd because of how ids are generated
    body._bodyId = self._idStream:nextId()
    
    self._bodyIdMap[body._bodyId] = body
    table.insert(self._bodies, body)
end

function World:isRegistered(body: Body.Body): boolean
    if body._bodyId == -1 then return false end

    return self._bodyIdMap[body._bodyId] == body
end

--updating should be an atomic operation so we store
--bodies that want to be deregistered in a queue
function World:deregisterBody(body: Body.Body): ()
    table.insert(self._deregisterationQueue, body)
end

function World:getBodyFromId(id: number): Body.Body
    return self._bodyIdMap[id]
end

function World:update(delta: number): ()
    for i = #self._deregisterationQueue, 1, -1 do
        local body: Body.Body = self._deregisterationQueue[i]
        if self:isRegistered(body) then
            self._bodyIdMap[body._bodyId] = nil
            table.remove(self._bodies, table.find(self._bodies, body))
        end

        table.remove(self._deregisterationQueue, i)
    end

    for i = 1, self._worldSettings.subSteps do
        self._solver:update(delta / self._worldSettings.subSteps)
    end
end

function World:loop(): ()
    RunService.Heartbeat:Connect(function(delta: number)
        self:update(delta)
    end)
end

function World.new(worldSettings: WorldSettings.WorldSettings?)
    if not worldSettings then
        worldSettings = WorldSettings.new()
    end

    local wSettings = worldSettings :: WorldSettings.WorldSettings

    assert(WorldSettings.validate(wSettings), "Missing fields in world settings")
    assert(wSettings.subSteps >= 1, "Substeps can't be lower than 1")

    local bodies: {Body.Body} = table.create(16)
    local bodyIdMap: {[number]: Body.Body} = table.create(16)
    local quadTree: QuadTree.QuadTree<number> = QuadTree.new(wSettings.maxQuadTreePoints, Box.new(Vector3.new(-1e6, 1e6), Vector3.new(1e6, -1e6)))

    return setmetatable({
        _bodies = bodies;
        _bodyIdMap = bodyIdMap;
        _quadTree = quadTree;
        _deregisterationQueue = {} :: {Body.Body};
        
        _solver = Solver.new(bodies, bodyIdMap, quadTree);
        
        _idStream = IdStream.new(wSettings.maximumId);

        _worldSettings = wSettings;
    }, World)
end

export type World = typeof(World.new(...));

return World