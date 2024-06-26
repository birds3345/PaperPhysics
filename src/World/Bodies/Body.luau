--Bodys in a world have a strong hierarchical system (which also means more look ups)
--however the physics solver is not deeply embedded into these classes
--which means the performance impact is negligible at best
--so this is (hopefully) okay performance wise

local BodyRTTI = require(script.Parent.BodyRTTI)

local Body = {}
Body.__index = Body
Body._classIndex = BodyRTTI(Body)


function Body:getId(): number
    return self._bodyId
end

--using generics don't work here so we rely on width subtyping instead
function Body:is(class: {_classIndex: number}): boolean
    assert(class._classIndex, "This class is not part of paper physics")

    return bit32.band(class._classIndex, self._classIndex) == class._classIndex
end

function Body:impulse(force: Vector3): ()
    self._force = force
end

--needed to update _inverseMass without the use of metatables
function Body:setMass(mass: number): ()
    self.mass = mass
    self._inverseMass = mass
end

function Body.new()
    return setmetatable({
        _bodyId = -1;

        --we use a vector3 for position and velocity because
        --vector3's are their own type (more optimized) and utilize SIMD instructions
        --while vector2's do not
        position = Vector3.zero;
        velocity = Vector3.zero;

        _force = Vector3.zero;
        
        mass = 1;
        _inverseMass = 1;

        gravity = Vector3.new(0, -9.80665);
        static = false;
    }, Body)
end

export type Body = typeof(Body.new())

return Body;
