local World = require(script.World.World)
local Renderer = require(script.Renderer.Renderer)

local Camera = require(script.Renderer.Camera)

local Bodies = script.World.Bodies
local Circle = require(Bodies.Circle)
local Rectangle = require(Bodies.Rectangle)

export type World = World.World;
export type Renderer = Renderer.Renderer;
export type Camera = Camera.Camera;

--bodies
export type Circle = Circle.Circle
export type Rectangle = Rectangle.Rectangle

--constraints

return {
    World = World;
    Renderer = Renderer;
    Camera = Camera;

    Bodies = {
        Circle = Circle;
        Rectangle = Rectangle;
    };

    Constraints = {

    };
}