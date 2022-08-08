-- ## SERVICES ## --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- ## VARIABLES ## --

local DEFAULT_ACTORS = 64

local actor = if RunService:IsClient() then script.ClientActor else script.Actor
local container = Instance.new("Folder")

-- ## SETUP ## --

container.Name = "Actors"
container.Parent = if RunService:IsClient() then Players.LocalPlayer.PlayerScripts else ServerScriptService

-- ## RETURNING ## --

return function(moduleScript, actorCount)
	local actors = {}
	local actorIndex = 1
	
	actorCount = actorCount or DEFAULT_ACTORS

	for _ = 1, actorCount do
		local newActor = actor:Clone()
		
		newActor.Script.Disabled = false
		newActor.Pointer.Value = moduleScript
		newActor.Parent = container

		table.insert(actors, newActor)
	end

	return function(func, parameters)
		local runningThread = coroutine.running()
		local returnValues = {}

		for _, parameter in parameters do
			local actor = actors[actorIndex]

			task.spawn(function()
				local result = nil

				if typeof(parameter) == "table" then
					result = table.pack(actor.Function:Invoke(func, table.unpack(parameter)))
				else
					result = table.pack(actor.Function:Invoke(func, parameter))
				end

				table.insert(returnValues, result)

				if #returnValues == #parameters then
					coroutine.resume(runningThread)
				end
			end)

			actorIndex %= actorCount + 1
		end

		coroutine.yield(runningThread)
		return returnValues
	end
end
