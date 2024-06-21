local WorldSettings = {}

--none of the fields should be nil (as per the type)
--however just to be safe we call this function before
--using the world settings
function WorldSettings.validate(worldSettings: WorldSettings): boolean
    return
        worldSettings.maxQuadTreePoints ~= nil
        and worldSettings.maximumId ~= nil
        and worldSettings.subSteps ~= nil
end

function WorldSettings.new(): WorldSettings
    return {
        subSteps = 20;
        maximumId = 1e18;

        maxQuadTreePoints = 20;
    }
end

export type WorldSettings = {
    subSteps: number;
    maximumId: number;

    maxQuadTreePoints: number;
}

return WorldSettings