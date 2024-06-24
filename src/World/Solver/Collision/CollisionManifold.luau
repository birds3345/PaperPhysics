local Body = require(script.Parent.Parent.Parent.Bodies.Body)

local CollisionManifold = {}

function CollisionManifold.new(body1: Body.Body, body2: Body.Body, normal: Vector3, depth: number, contactPoints: {Vector3}): CollisionManifold
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

    normal: Vector3;
    depth: number;

    contactPoints: {Vector3};
}

return CollisionManifold