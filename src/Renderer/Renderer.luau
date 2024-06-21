--!strict
local RunService = game:GetService("RunService")

local World = require(script.Parent.Parent.World.World)
local Bodies = script.Parent.Parent.World.Bodies
local RigidBody = require(Bodies.RigidBody)
local Particle = require(Bodies.Particle)
local Body = require(Bodies.Body)

local BodyIs = require(Bodies.BodyIs)


local BodyGraphics = require(script.Parent.BodyGraphics)
local Camera = require(script.Parent.Camera)

local Matrix2x2 = require(script.Parent.Parent.Utility.Matrix2x2)
local Maid = require(script.Parent.Parent.Utility.Maid)

local Renderer = {}
Renderer.__index = Renderer

function Renderer:loop(): ()
    self._maid:giveTask(RunService.RenderStepped:Connect(function(dt: number)
        self:update(dt)
    end))
end

function Renderer:update(delta: number): ()
    --TODO: correctly implement zooming
    --TODO: only update this when needed
    local sizePerPixel = 0.01 * math.max(self._canvas.AbsoluteSize.X, self._canvas.AbsoluteSize.Y) * self.camera.zoom
    self._sizePerPixel = sizePerPixel

    local canvasMid: Vector2 = (self._canvas.AbsoluteSize :: Vector2) / 2
    
    for bodyId: number, frame: Frame in self._bindings do
        local body: Body.Body? = self._world._bodyIdMap[bodyId]
        if not body then
            frame:Destroy()
            self._bindings[bodyId] = nil

            continue
        end
        
        if BodyIs(body, Particle) then
            frame.Size = UDim2.fromOffset(sizePerPixel, sizePerPixel)
            
        elseif BodyIs(body, RigidBody) then
            local rigidBody: RigidBody.RigidBody = body
            frame.Size = UDim2.fromOffset(rigidBody.size.X * sizePerPixel, rigidBody.size.Y * sizePerPixel)
            frame.Rotation = -math.deg(Matrix2x2.toAngle(rigidBody.rotation))
        end
            
        frame.Position = UDim2.fromOffset(canvasMid.X + (body.position.X - self.camera.position.X) * sizePerPixel, canvasMid.X - (body.position.Y - self.camera.position.Y) * sizePerPixel)
    end
end

function Renderer:track(bodyId: number, frame: Frame?): ()
    if not frame then
        frame = BodyGraphics.create(self._world._bodyIdMap[bodyId])
    end

    if frame then
        frame.Parent = self._canvas

        self._bindings[bodyId] = frame
    end
end

function Renderer:destroy()
    self._maid:clean()
end

function Renderer.new(canvas: Frame, world: World.World, camera: Camera.Camera)
    local self = setmetatable({
        camera = camera;

        _world = world;
        _maid = Maid.new();
        _canvas = canvas;
        
        _bindings = {} :: {[number]: Frame};

        _sizePerPixel = 1;
    }, Renderer)

    return self
end

export type Renderer = typeof(setmetatable({} :: {
    camera: Camera.Camera;

    _world: World.World;
    _maid: Maid.Maid;
    _canvas: Frame;

    _sizePerPixel: number;
}, Renderer))

return Renderer