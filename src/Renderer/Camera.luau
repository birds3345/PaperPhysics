local Camera = {}
Camera.__index = Camera

function Camera.new()
    return setmetatable({
        position = Vector2.zero;
        zoom = 1;
    }, Camera)
end

export type Camera = typeof(Camera.new())

return Camera