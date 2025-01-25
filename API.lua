--/ Services
local Players = game:GetService("Players")

--/ Globals
local speaker = Players.LocalPlayer
local cmsc = game:GetService("ReplicatedStorage")["ßtools"].Client_M_ServerControl

--/ Utility
local function getChar()
	return speaker.Character
end
local function getTool(name)
	local char = getChar()
	local tool
	if char then
		tool = char:FindFirstChild(name)
	end
	return
		workspace:FindFirstChild(name) or
		speaker.Backpack:FindFirstChild(name) or
		tool
end

--/ BTools API
local server = {}
local function getTServer(tt)
	return server[tt].Server
end

local btools = {}
btools.Init = function()
	-- Get tool references
	local d = getTool("D")
	local g = getTool("G")
	local c = getTool("C")
	if not d or not g or not c then
		return warn("--[LPI]-- Couldn't find BTools")
	end
	local char = getChar()
	server = {
		["D"] = d,
		["G"] = g,
		["C"] = c
	}
	-- Safely store tools
	for i, v in server do
		v.Parent = char
	end
	wait()
	for i, v in server do
		v.Parent = workspace
	end
	
	print("--[LPI]-- Got tool references!")
end
btools.DestroyPart = function(orig)
	local pnan = CFrame.new(0/0, 0/0, 0/0)
	local grab = getTServer("G")
	grab:InvokeServer(orig, pnan, "Update", "InputBegun")
	cmsc:FireServer(orig, pnan)
end
btools.DestroyInstance = function(orig)
	local delete = getTServer("D")
	delete:FireServer(orig, 0)
end
btools.ClonePart = function(orig)
	local clone = getTServer("C")
	orig.Locked = false
	clone:InvokeServer(orig, orig.CFrame, "Clone")
end
btools.Kill = function(orig)
	if orig:FindFirstChildOfClass("Humanoid") then
		local rootpart = orig:FindFirstChild("Head") or
			orig:FindFirstChild("Torso") or
			orig:FindFirstChild("LowerTorso") or
			orig:FindFirstChild("HumanoidRootPart")
		btools.DestroyPart(rootpart)
	end
end
btools.PlaySound = function(orig, sound)
	local grab = getTServer("G")
	grab:InvokeServer(orig, nil, "Sound", sound)
end

--/ Workspace API
local worksp = {}
worksp.GetDispensers = function()
	local holder = workspace.SafePlate.Mesh.Value
	local res = {}
	for i, v in holder:GetChildren() do
		if v.Bricks:FindFirstChild("Bar") then
			res.F3X = v
		else
			res.BTools = v
		end
	end
	return res
end
worksp.GetF3XDispenser = function()
	return worksp.GetDispensers().F3X
end
worksp.GetBToolsDispenser = function()
	return worksp.GetDispensers().BTools
end
worksp.GrabF3X = function()
	local dispenser = worksp.GetF3XDispenser()
	firetouchinterest(dispenser.Bricks.Bar.TouchInterest, getChar().HumanoidRootPart, 0)
end
worksp.GrabBTools = function()
	local dispenser = worksp.GetBToolsDispenser()
	firetouchinterest(dispenser.Bricks["Smooth Block Model"].TouchInterest, getChar().HumanoidRootPart, 0)
end

--/ Expose the API
return {
	["BTools"] = btools,
	["Workspace"] = worksp
}
