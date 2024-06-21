--TODO: implement
--this is supposed to use verlet integration

local BodyRTTI = require(script.Parent.BodyRTTI)
local Body = require(script.Parent.Body)

local Particle = setmetatable({}, Body)
Particle.__index = Particle
Particle._classIndex = BodyRTTI(Particle, Body)

return Particle