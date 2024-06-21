local IdStream = {}
IdStream.__index = IdStream

function IdStream:nextId(): number
    self._currentId = (self._currentId + 1) % self._upperLimit
    return self._currentId
end

function IdStream.new(upperLimit: number)
    return setmetatable({
        _currentId = -1;
        
        _upperLimit = upperLimit;
    }, IdStream)
end

export type IdStream = typeof(IdStream.new(0))

return IdStream