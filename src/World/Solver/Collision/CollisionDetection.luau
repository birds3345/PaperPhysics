--!native

local Bodies = script.Parent.Parent.Parent.Bodies
local Circle = require(Bodies.Circle)
local Rectangle = require(Bodies.Rectangle)
local Body = require(Bodies.Body)

local BodyIs = require(Bodies.BodyIs)

local ShapeUtility = require(script.Parent.Parent.ShapeUtility)

local CollisionManifold = require(script.Parent.CollisionManifold)

local function closestPointOnLineSegment(point: Vector3, segmentPosition: Vector3, direction: Vector3, length: number): Vector3?
    local offset = point - segmentPosition

    local d = offset:Dot(direction)
    if d < 0 or d > length then return end

    return segmentPosition + direction * d
end

local function projectPolygon(polygon: {Vector3}, axis: Vector3): (number, number)
	local shapeMin = math.huge
    local shapeMax = -math.huge

	for _, vertex in polygon do
		local projected = vertex:Dot(axis)

		shapeMin = math.min(shapeMin, projected)
		shapeMax = math.max(shapeMax, projected)
	end
	
	return shapeMin, shapeMax
end

local function closestPointOnPolygon(point: Vector3, polygon: {Vector3}): Vector3
    local closestPoint: Vector3 = Vector3.zero
    local minDistance = math.huge

    for i = 1, #polygon do
        local v1 = polygon[i]
        local v2 = polygon[i % #polygon + 1]

        local edge = (v2 - v1).Unit
        local edgeLength = (v2 - v1).Magnitude

        local pointOnSeg = closestPointOnLineSegment(point, v1, edge, edgeLength)

        if pointOnSeg then
            local distance = (point - pointOnSeg).Magnitude
            if distance < minDistance then
                minDistance = distance

                closestPoint = pointOnSeg
            end
        end

        --the closest point can also be a vertex
        local distance = (point - v1).Magnitude
        if distance < minDistance then
            minDistance = distance

            closestPoint = v1
        end
    end

    return closestPoint
end

local function polygonPolygon(b1: Body.Body, b2: Body.Body, p1Pos: Vector3, p1: {Vector3}, p2Pos: Vector3, p2: {Vector3}): CollisionManifold.CollisionManifold?
    local normal: Vector3 = Vector3.zero
	local depth = math.huge
    local contacts: {Vector3} = {}

    for i = 1, #p1 do
        local v1 = p1[i]
        local v2 = p1[i % #p1 + 1]

        local edge = (v2 - v1).Unit
        local n = Vector3.new(edge.Y, -edge.X)
        
        local p1Min, p1Max = projectPolygon(p1, n)
		local p2Min, p2Max = projectPolygon(p2, n)
		
		if p1Max <= p2Min or p2Max <= p1Min then
			return
		end
		
		local overlap = math.min(p1Max - p2Min, p2Max - p1Min)
		if overlap < depth then
			depth = overlap
			normal = n
		end
    end

    for i = 1, #p2 do
        local v1 = p2[i]
        local v2 = p2[i % #p2 + 1]

        local edge = (v2 - v1).Unit
        local n = Vector3.new(edge.Y, -edge.X)
        
        local p1Min, p1Max = projectPolygon(p1, n)
		local p2Min, p2Max = projectPolygon(p2, n)
		
		if p1Max <= p2Min or p2Max <= p1Min then
			return
		end
		
		local overlap = math.min(p1Max - p2Min, p2Max - p1Min)
		if overlap < depth then
			depth = overlap
			normal = n
		end
    end

	if (p2Pos - p1Pos).Unit:Dot(normal) < 0 then
		normal *= -1
	end
    
    --TODO: optimize calculation of contact points
    for i = 1, #p2 do
        local v1 = p2[i]
        local v2 = p2[i % #p2 + 1]

        local edge = (v2 - v1).Unit
        local n = Vector3.new(edge.Y, -edge.X)

        local proj1 = n:Dot(v1)
        local proj2 = n:Dot(v2)

        local min = math.min(proj1, proj2)
        local max = math.max(proj1, proj2)
        
        for _, v in p1 do
            if not closestPointOnLineSegment(v, v1, edge, (v2 - v1).Magnitude) then continue end

            local projection = n:Dot(v)
            local closest = math.min(math.abs(projection - min), math.abs(projection - max))
            if closest <= depth then
                table.insert(contacts, v)
            end
        end
    end

    for i = 1, #p1 do
        local v1 = p1[i]
        local v2 = p1[i % #p1 + 1]

        local edge = (v2 - v1).Unit
        local n = Vector3.new(edge.Y, -edge.X)

        local proj1 = n:Dot(v1)
        local proj2 = n:Dot(v2)

        local min = math.min(proj1, proj2)
        local max = math.max(proj1, proj2)
        
        for _, v in p2 do
            if not closestPointOnLineSegment(v, v1, edge, (v2 - v1).Magnitude) then continue end

            local projection = n:Dot(v)
            local closest = math.min(math.abs(projection - min), math.abs(projection - max))
            if closest <= depth then
                table.insert(contacts, v)
            end
        end
    end

    return CollisionManifold.new(b1, b2, normal, depth, contacts)
end

local CollisionDetection = {}

function CollisionDetection.collide(body1: Body.Body, body2: Body.Body): CollisionManifold.CollisionManifold?
    if BodyIs(body1, Circle) and BodyIs(body2, Circle) then
        return CollisionDetection.circleCircle(body1, body2)
    end

    if BodyIs(body1, Rectangle) and BodyIs(body2, Rectangle) then
        return CollisionDetection.rectangleRectangle(body1, body2)
    end
    
    
    if BodyIs(body1, Rectangle) and BodyIs(body2, Circle) then
        return CollisionDetection.rectangleCircle(body1, body2)
    end
    if BodyIs(body1, Circle) and BodyIs(body2, Rectangle) then
        return CollisionDetection.rectangleCircle(body2, body1)
    end



    return nil
end

function CollisionDetection.polygonPolygon(): CollisionManifold.CollisionManifold?
    return nil
end

function CollisionDetection.polygonCircle(circle: Circle.Circle): CollisionManifold.CollisionManifold?
    return nil
end

function CollisionDetection.circleCircle(circle1: Circle.Circle, circle2: Circle.Circle): CollisionManifold.CollisionManifold?
    local relative = circle2.position - circle1.position
    if relative.Magnitude > circle1.radius + circle2.radius then return end
    
    local normal = if relative == Vector3.zero then Vector3.yAxis else relative.Unit
    local depth = circle1.radius + circle2.radius - relative.Magnitude
    local contactPoint = circle1.position + normal * circle1.radius
    
    return CollisionManifold.new(circle1, circle2, normal, depth, {contactPoint})
end

function CollisionDetection.rectangleCircle(rectangle: Rectangle.Rectangle, circle: Circle.Circle): CollisionManifold.CollisionManifold?
    local c1, c2, c3, c4 = ShapeUtility.calculateRectangleVertices(rectangle)
    
    local closest = closestPointOnPolygon(circle.position, {c1, c2, c3, c4})
    local relative = circle.position - closest
    if relative.Magnitude > circle.radius then return end
    
    local normal = if relative == Vector3.zero then Vector3.yAxis else relative.Unit
    local depth = circle.radius - relative.Magnitude
    
    --luau thinks (circle.position - rectangle.position) is a number
    if ((circle.position - rectangle.position) :: any).Unit:Dot(normal) < 0 then
		normal *= -1
	end

    local contactPoint = circle.position - normal * circle.radius
    
    return CollisionManifold.new(rectangle, circle, normal, depth, {contactPoint})
end

function CollisionDetection.rectangleRectangle(rectangle1: Rectangle.Rectangle, rectangle2: Rectangle.Rectangle): CollisionManifold.CollisionManifold?
    local c11, c12, c13, c14 = ShapeUtility.calculateRectangleVertices(rectangle1)
    local c21, c22, c23, c24 = ShapeUtility.calculateRectangleVertices(rectangle2)

    return polygonPolygon(rectangle1, rectangle2, rectangle1.position, {c11, c12, c13, c14}, rectangle2.position, {c21, c22, c23, c24})
end

function CollisionDetection.rectanglePolygon(): CollisionManifold.CollisionManifold?
    return nil
end

return CollisionDetection