type Task = Instance | <T...>(T...) -> T... | RBXScriptConnection

local Maid = {}
Maid.__index = Maid

function Maid:giveTask(task: Task): ()
    table.insert(self._tasks, task)
end

function Maid:clean()
    local index: number?, value: Task? = next(self._tasks)
	
	while index do
		if typeof(value) == "Instance" then
			value:Destroy()
			
		elseif typeof(value) == "function" then
			value()
			
		elseif typeof(value) == "RBXScriptConnection" then
			value:Disconnect()
			
		end
		
		table.remove(self.tasks, index)
		
		index, value = next(self.tasks)
	end
end

function Maid.new()
    return setmetatable({
        _tasks = (setmetatable({}, {
			__mode = "v";
		}) :: any) :: {Task};
    }, Maid)
end

export type Maid = typeof(Maid.new(...))

return Maid