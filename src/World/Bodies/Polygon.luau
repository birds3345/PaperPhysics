local Body = require(script.Parent.Body)
local BodyRTTI = require(script.Parent.BodyRTTI)

local Polygon = {}
Polygon.__index = Polygon
Polygon._classIndex = BodyRTTI(Polygon, Body)

return Polygon