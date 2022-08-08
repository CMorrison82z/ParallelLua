# ParallelLua

Simple and efficient way of taking advantage of Roblox's Parallel Lua.

## Usage

1) Download the module or get it from the [toolbox](https://www.roblox.com/library/10523744631/ParallelProcess).
2) Place the module in `ReplicatedStorage` (make sure there exists an `Actor` and a `ClientActor` as children of the module). 
3) Make sure your hierachy looks like this:

![NVIDIA_Share_9EOn4ITgjO](https://user-images.githubusercontent.com/73802888/183499469-00522ef0-89ec-46ac-8f18-149e118aa833.png)

`Pointer` should be an `ObjectValue`, `Function` a `BindableFunction`, and `Script` a normal `Script` (in the `ClientActor`, it should be a `LocalScript`) with the following content:

```lua
local functions = require(script.Parent.Pointer.Value)

script.Parent.Function.OnInvoke = function(func, ...) 
	task.desynchronize()

	return functions[func](...)
end
```

4) Create a module script including all the executable functions. It can look like this:
```lua
return {
	Test = function(a, b)
		for i = 1, 1e6 do
			a, b = b, a
		end
		
		return a, b
	end,
}
```
5) Create a script, and type out the following:

```lua
local ParallelModule = require(path.to.module)(path.to.functions.module)

-- Create an array of parameters (Can be an array of tables as well)
local parameters = table.create(100, true) -- Just an example, you could put pretty anything here (as long as it's an array of parameters)

-- Returns an array of the returned results
local returnValues = ParallelModule("FunctionName", parameters)

print(returnValues)
```

6) Upon calling `ParallelModule`, the function will yield until all of the parameters have been processed. Internally, we're simply iterating through the array and executing the function using `task.spawn()`.

## Example Results

The output of an example run using the code below :

![Three to four times more efficient!](/assets/Benchmark.png "Benchmark")
![Microprofiler](/assets/Microprofiler.png "Microprofiler")

Here's the code that was used for the benchmark above:
```lua
local ParallelLua = require(ReplicatedStorage.ParallelLua)(ReplicatedStorage.Functions)

while true do
	-- SEQUENTIAL LUAU 
	
	local start = os.clock()
	
	for i = 1, 100 do
		local a, b = 0, 1
		
		for i = 1, 1e6 do
			a, b = b, a
		end
	end
	
	print("SEQ : ", os.clock() - start)
	
	-- PARALLEL LUAU
	
	local start = os.clock()
	local parameters = table.create(100, { 0, 1 })
	
	ParallelLua("Test", parameters)
	print("PARA : ", os.clock() - start)
	
	task.wait(1)
end
```
