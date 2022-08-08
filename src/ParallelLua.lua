local DEFAULT_ACTORS = 64

local actor;
local container = Instance.new("Folder")
container.Name = "Actors"

if game:GetService("RunService"):IsClient() then
	container.Parent = game:GetService("Players").LocalPlayer.PlayerScripts
	
	actor = script.ClientActor
else
	container.Parent = game:GetService("ServerScriptService")
	
	actor = script.Actor
end

return function(moduleScript, actorCount)
	actorCount = actorCount or DEFAULT_ACTORS
	
	local actors = {}

	do
		for i = 1, actorCount do
			local newActor = actor:Clone()
			newActor.Script.Disabled = false
			newActor.Pointer.Value = moduleScript
			newActor.Parent = container

			table.insert(actors, newActor)
		end
	end

	local actorIndex = 1
	
	return function(f, params)
		local runningThread =coroutine.running()

		local numParams = #params

		local rCount = 0
		local returns = {}

		for _, param in ipairs(params) do
			local actor = actors[actorIndex]

			coroutine.wrap(function()
				local res; 

				if type(param) == "table" then
					res = table.pack(actor.Function:Invoke(f, table.unpack(param)))
				else
					res = table.pack(actor.Function:Invoke(f, param))
				end

				table.insert(returns, res)

				rCount += 1

				if rCount == numParams then
					coroutine.resume(runningThread)
				end
			end)()

			actorIndex = actorIndex % actorCount + 1
		end


		coroutine.yield(runningThread)

		return returns
	end

end