local RTTI: {[any]: number} = {}
local index = 0

--note: _classIndex should be set to the last call of BodyRTTI
return function<T, U>(class: T, parent: U?): number
    if RTTI[class] then
        if parent then
            RTTI[class] = bit32.bor(RTTI[class], RTTI[parent])
        end

        return RTTI[class]
    end

    local id = bit32.lshift(1, index)
    index += 1

    if parent then
        id = bit32.bor(id, RTTI[parent])
    end

    RTTI[class] = id
    return id
end