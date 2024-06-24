local PaperPhysics = require(game.ReplicatedStorage.PaperPhysics)

local world = PaperPhysics.World.new()
local renderer = PaperPhysics.Renderer.new(script.Parent.Canvas, world, PaperPhysics.Camera.new())
world:loop()
renderer:loop()

for i = 1, 10 do
    local circle = PaperPhysics.Bodies.Circle.new()
    circle:setRadius(0.8)
    circle.position = Vector3.new(math.random() * 2, 50 + math.random() * 50)
    world:registerBody(circle)
    renderer:track(circle:getId())
end

for i = 1, 10 do
    local rect = PaperPhysics.Bodies.Rectangle.new()
    rect:setSize(Vector3.new(3, 1))
    rect.position = Vector3.new(math.random() * 2, 50 + math.random() * 50)
    world:registerBody(rect)
    renderer:track(rect:getId())
end

local rectangle = PaperPhysics.Bodies.Rectangle.new()
rectangle:setSize(Vector3.new(50, 2))
rectangle.position = Vector3.new(0, 20)
rectangle.static = true
world:registerBody(rectangle)
renderer:track(rectangle:getId())