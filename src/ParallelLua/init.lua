-- ## SERVICES ## --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- ## VARIABLES ## --

local DEFAULT_ACTORS = 64

local baseActor = if RunService:IsClient() then script.ClientActor else script.Actor
local container = Instance.new("Folder")

-- ## FUNCTIONS ## --

local function awarn(condition, message)
	if not condition then
		warn(message)
	end
end

-- ## SETUP ## --

container.Name = "Actors"
container.Parent = if RunService:IsClient() then Players.LocalPlayer.PlayerScripts else ServerScriptService

-- ## RETURNING ## --

return function(moduleScript, actorCount)
	local actors = {}
	local actorIndex = 1

	actorCount = actorCount or DEFAULT_ACTORS

	for _ = 1, actorCount do
		local newActor = baseActor:Clone()

		newActor.Script.Disabled = false
		newActor.Pointer.Value = moduleScript
		newActor.Parent = container

		table.insert(actors, newActor)
	end

	return function(func, parameters)
		local runningThread = coroutine.running()
		local returnValues = {}

		awarn(
			#parameters < 10,
			"Sending too many loads becomes very expensive for data transfer!\nConsider combining loads together. 4 - 8 separate loads is optimal"
		)

		for _, parameter in parameters do
			local actor = actors[actorIndex]

			task.spawn(function()
				actor.Out.Event:Once(function(result)
					table.insert(returnValues, result)

					if #returnValues == #parameters then
						coroutine.resume(runningThread)
					end
				end)

				if typeof(parameter) == "table" then
					actor.In:Fire(func, table.unpack(parameter))
				else
					actor.In:Fire(func, parameter)
				end
			end)

			actorIndex = actorIndex % actorCount + 1
		end

		coroutine.yield(runningThread)
		return returnValues
	end
end
