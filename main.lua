-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Init lib
local rep = "https://github.com/cheatmine/lpi/raw/refs/heads/main"
local LPI = loadstring(game:HttpGet(rep.."/API.lua", false), "LPI")()
local UI = loadstring(game:HttpGet(rep.."/UILib.lua", false), "UI")()
local Notif = UI:InitNotifications()

local blacklisted = { -- blacklisted tools
	"D", "G", "C",
	"F3X"
}
local exempt = { -- exempt players
	Player.Name,
	"qs_.*",
	"solome10202787"
}

-- Utility
local function match(s, t)
	for _, pattern in t do
		if s:match(pattern) then
			return true
		end
	end
	return false
end

-- Service functions
local runningServices = {}
local services = {}

local function stopService(name)
	if runningServices[name] then
		services[name].stop(runningServices[name])
		task.cancel(runningServices[name])
		runningServices[name] = nil
	else
		warn("Couldn't find a running task named '".. name.. "'")
	end
end
local function startService(name)
	runningServices[name] = task.spawn(services[name].start)
end
local function execService(name)
	services[name].start()
end

-- Services
local events = {}
services.ToolBlacklist = {
	start = function()
		events.NoTools = {}
		local function BindTool(tool, character)
			if not tool or not character then return end
			if tool:IsA("Tool") and match(tool.Name, blacklisted) then
				LPI.BTools.Kill(character)
			end
		end
		local function BindCharacter(character)
			table.insert(events.NoTools, character.ChildAdded:Connect(function(tool)
				BindTool(tool, character)
			end))
		end
		local function BindPlayer(player)
			if player.Character then BindCharacter(player.Character) end
			table.insert(events.NoTools, player.CharacterAdded:Connect(function(char)
				BindCharacter(char)
				table.insert(events.NoTools, player.Backpack.ChildAdded:Connect(function(tool)
					BindTool(tool, char)
				end))
				for i, v in player.Backpack:GetChildren() do
					BindTool(tool, char)
				end
			end))
		end

		table.insert(events.NoTools, Players.PlayerAdded:Connect(BindPlayer))
		for i, v in Players:GetPlayers() do
			if not match(v.Name, exempt) then
				BindPlayer(v)
				if v.Character then
					LPI.BTools.Kill(v.Character)
				end
			end
		end

		table.insert(events.NoTools, workspace.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") and tool:FindFirstChild("Handle") and match(tool.Name, blacklisted) then
				LPI.BTools.DestroyPart(tool.Handle)
			end
		end))
	end,
	stop = function()
		for i, v in events.NoTools do
			v:Disconnect()
		end
	end
}

-- UI
UI.title = "LPI Client"
UI:Introduction()

local Window = UI:Init(Enum.KeyCode.RightControl)

local Wm = UI:Watermark("LPI Client | v1.0 | " .. UI:GetUsername())
local FpsWm = Wm:AddWatermark("fps: " .. UI.fps)

coroutine.wrap(function()
	while wait(.75) do
		FpsWm:Text("fps: " .. UI.fps)
	end
end)()

-- Tabs
local tab = Window:NewTab("World")

tab:NewToggle("Tool Blacklist", false, function(bool)
	if bool then
		startService("ToolBlacklist")
	else
		stopService("ToolBlacklist")
	end
end)
tab:NewButton("Init BTools API", function()
	if not workspace:FindFirstChild("D") then
		LPI.Workspace.GrabBTools()
	end
	LPI.BTools.Init()
end)
tab:NewButton("Get F3X", function()
	LPI.Workspace.GrabF3X()
end)
tab:NewButton("Get BTools", function()
	LPI.Workspace.GrabBTools()
end)
tab:NewSection("Parts")
tab:NewButton("Delete all spawns", function()
	for i, v in workspace:GetChildren() do
		if v.Name == "SpawnLocation" then
			LPI.BTools.DestroyInstance(v)
		end
	end
end)

local tab = Window:NewTab("Players")
tab:NewButton("Kill All", function()
	for i, v in Players:GetPlayers() do
		if not match(v.Name, exempt) and v.Character then
			LPI.BTools.Kill(v.Character)
		end
	end
end)


Notif:Notify("Loaded LPI Client", 4, "success")
