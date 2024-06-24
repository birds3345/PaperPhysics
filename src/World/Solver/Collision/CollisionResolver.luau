--!native

local CollisionManifold = require(script.Parent.CollisionManifold)

local Bodies = script.Parent.Parent.Parent.Bodies
local RigidBody = require(Bodies.RigidBody)

local CollisionResolver = {}

--TODO: make this based on mass
function CollisionResolver.separate(manifold: CollisionManifold.CollisionManifold): ()
    local offset = manifold.normal * manifold.depth
    
    if manifold.body1.static then
        manifold.body2.position += offset

    elseif manifold.body2.static then
        manifold.body1.position -= offset

    else
        manifold.body1.position -= offset / 2
        manifold.body2.position += offset / 2
    end
end

function CollisionResolver.resolve(manifold: CollisionManifold.CollisionManifold): ()
    local rigidBody1 = manifold.body1 :: RigidBody.RigidBody
    local rigidBody2 = manifold.body2 :: RigidBody.RigidBody
    
    local body1Force = Vector3.zero
    local body2Force = Vector3.zero
    
    local body1AngularForce = 0
    local body2AngularForce = 0
    
    local friction = math.min(rigidBody1.friction, rigidBody2.friction)
    local e = math.min(rigidBody1.restitution, rigidBody2.restitution)

    for _, contactPoint in manifold.contactPoints do
        --collision impulse
        local rel1 = contactPoint - (rigidBody1.position + rigidBody1._centroid)
        local rel2 = contactPoint - (rigidBody2.position + rigidBody2._centroid)
        
        --convert the angular velocity into a vector that describes the angular velocity
        local angularVel1 = Vector3.new(-rel1.Y, rel1.X) * rigidBody1.angularVelocity
        local angularVel2 = Vector3.new(-rel2.Y, rel2.X) * rigidBody2.angularVelocity

        --add the contributions of the angular velocity to the linear velocity
        local relVel1 = rigidBody1.velocity + angularVel1
        local relVel2 = rigidBody2.velocity + angularVel2

        local relative = relVel2 - relVel1
        --if the dot product is above zero the bodies are already moving away from each other
        --(a dot product of 0 means that the two vectors are perpendicular and a dot product of one means they are the same)
        local d = relative:Dot(manifold.normal)
        if d > 0 then continue end

        --calculate the relative velocity's influence on the angular velocity
        local c1 = rel1:Cross(manifold.normal).Z
        local c2 = rel2:Cross(manifold.normal).Z

        --formula to calculate the amount of force to apply for each impulse
        local crossInertiaSum = c1 * c1 * rigidBody1._inverseInertia + c2 * c2 * rigidBody2._inverseInertia
        local j = (-(1 + e) * d) / (rigidBody1._inverseMass + rigidBody2._inverseMass + crossInertiaSum)
        
        local impulse = manifold.normal * j
        body1Force -= impulse * rigidBody1._inverseMass
        body2Force += impulse * rigidBody2._inverseMass
        
        body1AngularForce -= c1 * j * rigidBody1._inverseInertia
        body2AngularForce += c2 * j * rigidBody2._inverseInertia
        
        --frictional impulse
        --subtract the relative vector projected on the normal from the relative vector
        local tangent = relative - manifold.normal * relative:Dot(manifold.normal)
        if math.abs(tangent.X) <= 0.001 and math.abs(tangent.Y) <= 0.001 then
            continue
        end
        --this currently faces towards the relative vector so we negate it
        tangent = -tangent.Unit

        local ct1 = rel1:Cross(tangent).Z
        local ct2 = rel2:Cross(tangent).Z

        local crossTangentSum = ct1 * ct1 * rigidBody1._inverseInertia + ct2 * ct2 * rigidBody2._inverseInertia
        
        local jt = -relative:Dot(tangent) / (rigidBody1._inverseMass + rigidBody2._inverseMass + crossTangentSum)
        jt = math.min(jt, j * friction)
        
        local frictionalImpulse = tangent * jt
        
        body1Force -= frictionalImpulse * rigidBody1._inverseMass
        body2Force += frictionalImpulse * rigidBody2._inverseMass
        
        body1AngularForce -= ct1 * jt * rigidBody1._inverseInertia
        body2AngularForce += ct2 * jt * rigidBody2._inverseInertia
    end
    
    rigidBody1.velocity += body1Force
    rigidBody2.velocity += body2Force

    rigidBody1.angularVelocity += body1AngularForce
    rigidBody2.angularVelocity += body2AngularForce

    CollisionResolver.separate(manifold)
end

return CollisionResolver