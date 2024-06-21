local Bodies = script.Parent.Parent.World.Bodies
local Circle = require(Bodies.Circle)
local Rectangle = require(Bodies.Rectangle)
local Body = require(Bodies.Body)

local BodyIs = require(Bodies.BodyIs)

local BodyGraphics = {}

function BodyGraphics.create(body: Body.Body): Frame
    if BodyIs(body, Circle) then
        return BodyGraphics.createCircle(body)
    end

    if BodyIs(body, Rectangle) then
        return BodyGraphics.createRectangle(body)
    end

    warn("Body type is not yet supported")

    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    return frame
end

function BodyGraphics.createCircle(circle: Circle.Circle): Frame
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = frame

    local leg = Instance.new("Frame")
    leg.BorderSizePixel = 0
    leg.AnchorPoint = Vector2.new(0, 0.5)
    leg.Position = UDim2.fromScale(0.5, 0.5)
    leg.Size = UDim2.new(0.5, 0, 0, 4)
    leg.Parent = frame

    return frame
end

function BodyGraphics.createRectangle(rectangle: Rectangle.Rectangle): Frame
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    return frame
end

return BodyGraphics