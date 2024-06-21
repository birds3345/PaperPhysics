local Body = require(script.Parent.Body)

--using generics don't work here so we rely on width subtyping instead
return function(body: Body.Body, class: {_classIndex: number}): boolean
    return bit32.band(class._classIndex, body._classIndex) == class._classIndex
end