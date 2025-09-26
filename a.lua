-- Wizard UI — Compact + functional (4 textboxes + 4 buttons + loop)
local ok, Library = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
end)
if not ok or not Library then
	warn("Failed to load Wizard UI library")
	return
end

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer

-- === helpers ===
local function safeFindRemote(name)
	if not name or name == "" then return nil end
	-- try direct descendant search (name only) inside ReplicatedStorage and descendants
	local rs = game:GetService("ReplicatedStorage")
	-- if user pasted a full path like "ReplicatedStorage.Rewards.Claim", extract last segment
	local simpleName = tostring(name)
	if simpleName:find("%.") then
		local last = simpleName:match("([^%.]+)$")
		if last then simpleName = last end
	end
	local found = rs:FindFirstChild(simpleName, true)
	return found
end

local function notify(text, dur)
	dur = dur or 2
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title="UGC Helper", Text=text, Duration=dur})
	end)
	print("[UGC Helper] "..text)
end

local function getCollectiblePartByIndex(idx)
	if type(idx) ~= "number" then return nil end
	local coll = workspace:FindFirstChild("Lobby") and workspace.Lobby:FindFirstChild("Collectibles")
	if not coll then return nil end
	local children = coll:GetChildren()
	if idx < 1 or idx > #children then return nil end
	return children[idx]
end

local function teleportToPart(part)
	if not part or not part:IsA("BasePart") then return false end
	if not lp.Character then return false end
	local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	hrp.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	return true
end

local function invokeRemoteObj(obj)
	if not obj then return false, "no remote" end
	if obj:IsA("RemoteFunction") then
		local ok, res = pcall(function() return obj:InvokeServer() end)
		return ok, res
	elseif obj:IsA("RemoteEvent") then
		local ok, res = pcall(function() obj:FireServer() end)
		return ok, res
	else
		return false, "not a remote"
	end
end

-- Default mapping (fixed per your request)
local defaultMap = {
	[1] = 5, -- Part 1 -> children[5]
	[2] = 4, -- Part 2 -> children[4]
	[3] = 2, -- Part 3 -> children[2]
	[4] = 3, -- Part 4 -> children[3] (you requested this)
}

-- === UI build (Wizard) ===
local Window = Library:NewWindow("UGC Helper")
local Tab = Window:NewSection("Runner")

-- store user inputs (remote lookup strings)
local inputs = {"", "", "", ""}

-- Create 4 textbox/button pairs visually compact:
for i = 1, 4 do
	Tab:CreateTextbox("Remote #"..i.." (name/path)", function(text)
		inputs[i] = tostring(text or "")
	end)
	Tab:CreateButton("Go & Invoke Part "..i, function()
		-- map to configured part index (defaultMap)
		local idx = defaultMap[i] or 1
		local part = getCollectiblePartByIndex(idx)
		if not part then
			notify("Part index "..tostring(idx).." not found", 3)
			return
		end
		-- teleport
		local oktp = teleportToPart(part)
		if not oktp then
			notify("Teleport failed", 2)
			return
		end
		task.wait(0.2) -- small settle time
		-- find remote by user input (allow partial / last-segment matching)
		local name = inputs[i]
		if not name or name == "" then
			notify("Remote name empty for slot "..i, 2)
			return
		end
		local remoteObj = safeFindRemote(name)
		if not remoteObj then
			notify("Remote '"..tostring(name).."' not found", 3)
			return
		end
		local ok, res = invokeRemoteObj(remoteObj)
		if ok then
			notify("Invoked slot "..i.." -> "..tostring(remoteObj:GetFullName()), 2)
		else
			notify("Invoke failed slot "..i..": "..tostring(res), 3)
		end
	end)
end

-- Run Sequence Loop controls
local looping = false
local loopTask = nil
Tab:CreateButton("Run Sequence (5 → 4 → 2 → 3)", function()
	if looping then
		notify("Already running. Use Stop to end.", 2)
		return
	end
	looping = true
	notify("Sequence started", 2)
	loopTask = task.spawn(function()
		-- sequence of default indices (explicit)
		local seq = {5,4,2,3}
		while looping do
			for slot = 1,4 do
				if not looping then break end
				local idx = seq[slot] -- use sequence order
				local part = getCollectiblePartByIndex(idx)
				if part then
					teleportToPart(part)
					task.wait(0.18) -- settle
					local name = inputs[slot]
					if name and name ~= "" then
						local remoteObj = safeFindRemote(name)
						if remoteObj then
							local ok, res = invokeRemoteObj(remoteObj)
							if ok then
								notify("Seq: slot "..slot.." invoked", 1)
							else
								notify("Seq invoke error slot "..slot..": "..tostring(res), 2)
							end
						else
							notify("Seq: remote for slot "..slot.." not found", 2)
						end
					else
						notify("Seq: slot "..slot.." remote empty", 1)
					end
				else
					notify("Seq: part idx "..tostring(idx).." missing", 2)
				end
				-- small inter-slot pause, tuned to be quick but not instantaneous
				task.wait(0.35)
			end
			-- short pause between full cycles (keeps it responsive)
			task.wait(0.25)
		end
		notify("Sequence stopped", 2)
	end)
end)

Tab:CreateButton("Stop Sequence", function()
	if not looping then
		notify("Not currently running", 1)
		return
	end
	looping = false
	loopTask = nil
	notify("Stop requested", 1)
end)

-- Quick helper: Go to Lobby remote (if exists)
Tab:CreateButton("GoToLobby (invoke)", function()
	local ok, remote = pcall(function()
		return game:GetService("ReplicatedStorage")
			:WaitForChild("Packages"):WaitForChild("Knit")
			:WaitForChild("Services"):WaitForChild("GameService")
			:WaitForChild("RF"):WaitForChild("GoToLobby")
	end)
	if not ok or not remote then
		notify("GoToLobby not found", 2)
		return
	end
	local s, r = pcall(function() return remote:InvokeServer() end)
	if s then notify("GoToLobby invoked", 2) else notify("GoToLobby failed: "..tostring(r), 3) end
end)

-- Minimal extra: a small note for the user
notify("UI ready — fill 4 remote names, use buttons or run sequence", 4)
