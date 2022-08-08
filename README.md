# ParallelLua

Simple, efficient way of taking advantage of Roblox's Parallel Lua.

## Usage

1 ) Download, or get from Roblox's website [ParalleLua](https://www.roblox.com/library/10523744631/ParallelProcess)

2) Place the module in ReplicatedStorage (make sure there exists the Actor and ClientActor prefabs as children of the module).

3) Do the following :

`
-- Require the Instance of the ModuleScript
local ParallelModule = require(\_path.ParallelLua)(\_path.MyModule)

-- Create an array of parameters (Can be an array of tables as well)
local paramsList = table.create(100, true) -- Just an example

-- Returns an array of the returned results
local resturns = ParallelModule("FunctionName", paramsList)

print(returns)
`

4) Upon calling "ParallelModule", the code will yield until all of the parameters in 'paramsList' have all been processed. Internally, we're simply iterating through the array and executing the function within coroutine.wrap. The function is yielded until this process has finished


## Example Results

The output of an example run using the code below :

![Three to four times more efficient!](/assets/Benchmark.png "Benchmark")
![Microprofiler](/assets/Microprofiler.png "Microprofiler")

`
local pp = require(workspace.ParallelProcess)(workspace.Functions)

while true do
	-- SEQUENTIAL LUAU 
	
	local s = os.clock()
	
	for i = 1, 100 do
		local a, b = 0, 1
		for i = 1, 1e6 do
			a, b = b, a
		end
	end
	
	print("SEQ : ", os.clock() - s)
	
	-- PARALLEL LUAU
	
	local s = os.clock()
	
	local params = {}

	for i = 1, 100 do
		table.insert(params, {0, 1})
	end
	
	pp("Test", params)
	
	print("PARA : ", os.clock() - s)
	
	wait(.6)
end
`

