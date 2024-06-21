--!native

local PubTypes = require(script.Parent.Parent.PubTypes)

local Matrix2x2 = {}

function Matrix2x2.multiplyMM(mat1: PubTypes.Matrix2x2, mat2: PubTypes.Matrix2x2): PubTypes.Matrix2x2
    return {
        m00 = mat1.m00 * mat2.m00 + mat1.m01 * mat2.m10;
        m01 = mat1.m00 * mat2.m01 + mat1.m01 * mat2.m11;
        m10 = mat1.m10 * mat2.m00 + mat1.m11 * mat2.m10;
        m11 = mat1.m10 * mat2.m01 + mat1.m11 * mat2.m11;
    }
end

function Matrix2x2.multiplyMV(mat: PubTypes.Matrix2x2, vector: Vector2): Vector2
    return Vector2.new(mat.m00 * vector.X + mat.m01 * vector.Y, mat.m10 * vector.X + mat.m11 * vector.Y)
end

function Matrix2x2.fromAngle(radians: number): PubTypes.Matrix2x2
    return {
        m00 = math.cos(radians);
        m01 = -math.sin(radians);
        m10 = math.sin(radians);
        m11 = math.cos(radians);
    }
end

--[[
@returns in radians
]]
function Matrix2x2.toAngle(mat: PubTypes.Matrix2x2): number
    return math.atan2(mat.m10, mat.m00)
end

return Matrix2x2