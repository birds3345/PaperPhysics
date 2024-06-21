local Body = require(script.Parent.Parent.Parent.Bodies.Body)

local CollisionManifold = {}

function CollisionManifold.new(body1: Body.Body, body2: Body.Body, normal: Vector2, depth: number, contactPoints: {Vector2}): CollisionManifold
    return {
        body1 = body1;
        body2 = body2;

        normal = normal;
        depth = depth;

        contactPoints = table.clone(contactPoints);
    }
end

export type CollisionManifold = {
    body1: Body.Body;
    body2: Body.Body;

    normal: Vector2;
    depth: number;

    contactPoints: {Vector2};
}

return CollisionManifold