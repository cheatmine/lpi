--/ Dependencies and preparation
if not Prim then
	Prim = loadstring(game:HttpGet("https://github.com/cheatmine/lpi-prim/raw/main/API.lua"))()
end

--/ Modules
export type WeaponConfig = {
	Grip: CFrame,
	GripOrigin: Attachment?,
	Handle: BasePart
}
export type Weapon = {
	Tool: Tool,
	Config: WeaponConfig,
	ID: number,
	Active: boolean
}

--/ Functions
local function WeaponStreaming(obj: Weapon): Weapon
	Prim.QueuePartChange(obj.Config.Handle, {
		Name = "Handle",
		Anchored = true,
		CanCollide = false
	})
	while game:GetService("RunService").Heartbeat:Wait() do
		local active = WeaponEngine.GetWeaponState(obj.ID)
		if not active then break end
		Prim.QueuePartChangeAsync(obj.Config.Handle, {
			CFrame = obj.Config.GripOrigin.WorldCFrame * obj.Config.Grip
		})
	end
end

local function CreateWeapon(obj: Weapon): Weapon
	if obj.Tool:FindFirstChild("Handle") then
		Prim.DestroyInstance(obj.Tool.Handle)
	end
	if not obj.Config.GripOrigin then
		Prim.QueuePartChange(obj.Config.Handle, {
			Name = "Handle",
			Parent = obj.Tool,
			Locked = true
		})
		obj.Tool.Grip = obj.Config.Grip
	else
		task.spawn(WeaponStreaming, obj)
	end

	return obj
end

--/ Module
local _WeaponEngine = {}
_WeaponEngine.Weapons = WeaponEngine and WeaponEngine.Weapons or {}

function _WeaponEngine.NewWeapon(config: WeaponConfig): Weapon
	assert(type(config) == "table", `invalid argument #1 to 'NewWeapon' (table expected, got {typeof(config)})`)
	assert(typeof(config.Grip) == "CFrame", `invalid table element Grip (CFrame expected, got {typeof(config.Grip)})`)
	assert(typeof(config.Handle) == "Instance", `invalid table element Handle (BasePart expected, got {typeof(config.Handle)})`)
	assert(config.Handle:IsA("BasePart"), `invalid table element Handle (BasePart expected, got {config.Handle.ClassName})`)

	local weapon = {
		Tool = game:GetService("Players").LocalPlayer.Character
			:FindFirstChildOfClass("Tool"),
		Config = {
			Grip = config.Grip,
			GripOrigin = config.GripOrigin,
			Handle = config.Handle
		},
		ID = #_WeaponEngine + 1,
		Active = true
	}

	for _, v in _WeaponEngine.Weapons do
		v.Active = false
	end
	_WeaponEngine.Weapons[weapon.ID] = weapon

	return CreateWeapon(weapon :: Weapon)
end

function _WeaponEngine.GetWeaponState(weapon: Weapon | number): boolean
	if type(weapon) == "table" then
		return _WeaponEngine.Weapons[weapon.ID].Active
	elseif type(weapon) == "number" then
		return _WeaponEngine.Weapons[weapon].Active
	end
end

getgenv().WeaponEngine = _WeaponEngine

return _WeaponEngine