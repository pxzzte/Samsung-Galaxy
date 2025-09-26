-- Wizard UI + Lobby / Collectibles helper
-- Load Wizard lib
local success, Library = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end)
if not success or not Library then
	warn("Failed to load Wizard UI library")
	return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local lp = Players.LocalPlayer

-- Safe getters for remote / parts
local function getGoToLobbyRemote()
	local ok, res = pcall(function()
		return game:GetService("ReplicatedStorage")
			:WaitForChild("Packages")
			:WaitForChild("Knit")
			:WaitForChild("Services")
			:WaitForChild("GameService")
			:WaitForChild("RF")
			:WaitForChild("GoToLobby")
	end)
	if ok then return res end
	return nil
end

local function getCollectiblePartByIndex(childIndex)
	-- Use protected calls and ensure object exists
	if not workspace:FindFirstChild("Lobby") then return nil end
	local coll = workspace.Lobby:FindFirstChild("Collectibles")
	if not coll then return nil end
	local children = coll:GetChildren()
	if type(childIndex) ~= "number" then return nil end
	if childIndex < 1 or childIndex > #children then return nil end
	return children[childIndex]
end

-- Teleport helper (smoothCFrame optional)
local function teleportToPart(part)
	if not part or not part:IsA("BasePart") then
		addLog("Invalid part to teleport", Color3.fromRGB(255,125,125))
		return false
	end
	local char = lp.Character
	if not char then
		addLog("Character not found", Color3.fromRGB(255,125,125))
		return false
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then
		addLog("HRP not found", Color3.fromRGB(255,125,125))
		return false
	end

	-- Offset slightly above the part to avoid collisions
	local targetCFrame = part.CFrame + Vector3.new(0, 3, 0)
	-- Instant teleport (keeps it simple & reliable)
	hrp.CFrame = targetCFrame
	return true
end

-- Simple log function shown via StarterGui notification + printed
local function addLog(text, color)
	color = color or Color3.fromRGB(220,220,220)
	-- small notification
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "UGC Tester", Text = text, Duration = 3})
	end)
	print("[UGC Tester] "..text)
end

-- ==========================
-- Build GUI (Wizard)
-- ==========================
local Window = Library:NewWindow("UGC Helper")
local Tab = Window:NewSection("Lobby & Collectibles")

-- Small state for auto loop
local autoCollect = false
local autoTask = nil
local autoDelay = 0.8 -- default delay between teleports

-- --- Buttons / controls ---
Tab:CreateButton("Go To Lobby", function()
	local remote = getGoToLobbyRemote()
	if not remote then
		addLog("GoToLobby remote not found", Color3.fromRGB(255,100,100))
		return
	end
	-- safe call
	local ok, res = pcall(function()
		return remote:InvokeServer()
	end)
	if ok then
		addLog("GoToLobby invoked", Color3.fromRGB(150,255,150))
	else
		addLog("Invoke GoToLobby failed: "..tostring(res), Color3.fromRGB(255,150,150))
	end
end)

Tab:CreateButton("Teleport → Part 1 (index 5)", function()
	local part = getCollectiblePartByIndex(5)
	if not part then
		addLog("Part 1 (index 5) not found", Color3.fromRGB(255,100,100))
		return
	end
	if teleportToPart(part) then
		addLog("Teleported to Part 1", Color3.fromRGB(200,255,200))
	end
end)

Tab:CreateButton("Teleport → Part 2 (index 4)", function()
	local part = getCollectiblePartByIndex(4)
	if not part then
		addLog("Part 2 (index 4) not found", Color3.fromRGB(255,100,100))
		return
	end
	if teleportToPart(part) then
		addLog("Teleported to Part 2", Color3.fromRGB(200,255,200))
	end
end)

Tab:CreateButton("Teleport → Part 3 (index 2)", function()
	local part = getCollectiblePartByIndex(2)
	if not part then
		addLog("Part 3 (index 2) not found", Color3.fromRGB(255,100,100))
		return
	end
	if teleportToPart(part) then
		addLog("Teleported to Part 3", Color3.fromRGB(200,255,200))
	end
end)

-- Dropdown to choose a collectible index (1..n)
Tab:CreateDropdown("Choose Collectible Index", (function()
	-- prepare list of string indices dynamically (safe)
	local items = {}
	local coll = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Collectibles")
	if coll then
		for i=1,#coll:GetChildren() do
			table.insert(items, tostring(i))
		end
	end
	if #items == 0 then table.insert(items, "No Collectibles") end
	return items
end)(), 1, function(text)
	addLog("Selected index "..tostring(text), Color3.fromRGB(200,200,255))
end)

-- Slider: delay between teleports in auto-collect
Tab:CreateSlider("Auto Delay (s)", 0.05, 3, autoDelay, false, function(value)
	autoDelay = value
	addLog(string.format("Auto delay set to %.2fs", value), Color3.fromRGB(200,200,255))
end)

-- Auto Collect toggle: loops teleport to the three requested indices in order
Tab:CreateToggle("Auto-Collect 5 → 4 → 2", function(enabled)
	autoCollect = enabled
	if autoCollect then
		addLog("Auto-Collect started", Color3.fromRGB(150,255,150))
		-- spawn worker
		autoTask = task.spawn(function()
			local sequence = {5,4,2}
			while autoCollect do
				for _, idx in ipairs(sequence) do
					if not autoCollect then break end
					local part = getCollectiblePartByIndex(idx)
					if part then
						teleportToPart(part)
						addLog("Auto teleported to index "..tostring(idx), Color3.fromRGB(180,240,180))
					else
						addLog("Auto: index "..tostring(idx).." not found", Color3.fromRGB(255,150,150))
					end
					-- wait with small yields (keeps UI responsive)
					local waited = 0
					while waited < autoDelay do
						if not autoCollect then break end
						task.wait(0.05)
						waited = waited + 0.05
					end
				end
				-- small pause before repeating sequence
				task.wait(0.2)
			end
			addLog("Auto-Collect stopped", Color3.fromRGB(255,200,200))
		end)
	else
		autoCollect = false
		addLog("Auto-Collect stopping...", Color3.fromRGB(255,200,200))
	end
end)

-- Extra: Quick actions grouped in a submenu-like area (keeps main UI clean)
Tab:CreateButton("Open Utilities (Show more controls)", function()
	-- create a small ephemeral window with extra buttons
	local sub = Library:NewWindow("Utilities")
	local sTab = sub:NewSection("More")
	sTab:CreateButton("Teleport to Lobby Root", function()
		local lobbyRoot = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Root")
		if lobbyRoot and lobbyRoot:IsA("BasePart") then
			teleportToPart(lobbyRoot)
			addLog("Teleported to Lobby Root", Color3.fromRGB(200,255,200))
		else
			addLog("Lobby Root not found", Color3.fromRGB(255,100,100))
		end
	end)
	sTab:CreateButton("Stop Auto-Collect", function()
		autoCollect = false
		addLog("Requested stop auto-collect", Color3.fromRGB(255,200,200))
	end)
	sTab:CreateTextbox("Custom Teleport Index", function(text)
		local n = tonumber(text)
		if not n then
			addLog("Invalid index", Color3.fromRGB(255,100,100)); return
		end
		local part = getCollectiblePartByIndex(n)
		if part then
			teleportToPart(part)
			addLog("Teleported to index "..tostring(n), Color3.fromRGB(200,255,200))
		else
			addLog("Index not found: "..tostring(n), Color3.fromRGB(255,100,100))
		end
	end)
end)

-- Final small note
addLog("UI loaded: Lobby & Collectibles controls ready", Color3.fromRGB(150,255,150))


