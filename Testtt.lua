-- =====================================================
-- RAGALIC CLIENT • FULL MOBILE EDITION
-- 100% функций из оригинального файла
-- =====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Camera = Workspace.CurrentCamera
local SoundService = game:GetService("SoundService")
local PS = Players
local RS = ReplicatedStorage
local R = RunService

-- =====================================================
-- ЗАГРУЗКА БИБЛИОТЕКИ
-- =====================================================
loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles
Library.ForceCheckbox = false

-- =====================================================
-- ОКНО
-- =====================================================
local Window = Library:CreateWindow({
	Title = "Ragalic Mobile",
	Footer = "Ragalic Mobile",
	NotifySide = "Right",
	ShowCustomCursor = true,
})

local Tabs = {
	Defense = Window:AddTab("defense", "shield"),
	Target = Window:AddTab("target", "crosshair"),
	Grab = Window:AddTab("grab", "hand"),
	Player = Window:AddTab("player", "user"),
	Misc = Window:AddTab("misc", "layers"),
	Build = Window:AddTab("build", "box"),
	Fun = Window:AddTab("fun", "smile"),
	Keybinds = Window:AddTab("keybinds", "keyboard"),
	Notifications = Window:AddTab("notifications", "bell"),
	Auras = Window:AddTab("auras", "sparkles"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- =====================================================
-- УТИЛИТЫ
-- =====================================================
local function notify(title, content, duration)
	Library:Notify({ Title = title or "Notification", Description = content or "", Time = duration or 5 })
end

local function getPlayerList()
	local list = {}
	for _, plr in ipairs(PS:GetPlayers()) do
		if plr ~= LocalPlayer then
			table.insert(list, plr.DisplayName .. " (" .. plr.Name .. ")")
		end
	end
	return list
end

local function getPlayerFromSelection(selection)
	if not selection then return nil end
	local username = selection:match("%((.-)%)")
	if username then return PS:FindFirstChild(username) end
	return nil
end

-- =====================================================
-- МОБИЛЬНОЕ УПРАВЛЕНИЕ (100% ТАЧ)
-- =====================================================
local Mobile = {
	TouchStart = false,
	MoveDir = Vector3.new(0, 0, 0),
	Buttons = {},
}

-- ДЖОЙСТИК
local function CreateJoystick()
	local size = 130
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, size, 0, size)
	frame.Position = UDim2.new(0.08, 0, 0.75, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BackgroundTransparency = 0.6
	frame.BorderSizePixel = 0
	frame.Parent = CoreGui
	frame.ZIndex = 999
	
	local border = Instance.new("Frame")
	border.Size = UDim2.new(1, -10, 1, -10)
	border.Position = UDim2.new(0.5, 0, 0.5, 0)
	border.BackgroundTransparency = 1
	border.BorderSizePixel = 2
	border.BorderColor3 = Color3.fromRGB(150, 150, 200)
	border.Parent = frame
	
	local inner = Instance.new("Frame")
	inner.Size = UDim2.new(0, 45, 0, 45)
	inner.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
	inner.BackgroundColor3 = Color3.fromRGB(200, 200, 255)
	inner.BackgroundTransparency = 0.3
	inner.BorderSizePixel = 0
	inner.Parent = frame
	
	local function onTouchBegan(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local fPos = frame.AbsolutePosition
			local center = fPos + Vector2.new(size/2, size/2)
			if (pos - center).Magnitude < size then
				Mobile.TouchStart = true
			end
		end
	end
	
	local function onTouchMoved(input)
		if input.UserInputType == Enum.UserInputType.Touch and Mobile.TouchStart then
			local pos = input.Position
			local fPos = frame.AbsolutePosition
			local center = fPos + Vector2.new(size/2, size/2)
			local delta = pos - center
			local maxD = size/2 - 15
			local clamped = delta.Magnitude > maxD and delta.Unit * maxD or delta
			inner.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
			local norm = delta.Magnitude > 0 and delta / maxD or Vector2.new(0, 0)
			Mobile.MoveDir = Vector3.new(norm.X, 0, -norm.Y)
		end
	end
	
	local function onTouchEnded(input)
		if input.UserInputType == Enum.UserInputType.Touch then
			Mobile.TouchStart = false
			inner.Position = UDim2.new(0.5, -22.5, 0.5, -22.5)
			Mobile.MoveDir = Vector3.new(0, 0, 0)
		end
	end
	
	UserInputService.InputBegan:Connect(onTouchBegan)
	UserInputService.InputChanged:Connect(onTouchMoved)
	UserInputService.InputEnded:Connect(onTouchEnded)
	return frame
end

-- КНОПКИ
local function CreateButtons()
	local btns = {}
	local function addBtn(name, icon, yPos, color, callback)
		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.new(0, 60, 0, 60)
		btn.Position = UDim2.new(0.85, 0, yPos, 0)
		btn.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
		btn.BackgroundTransparency = 0.35
		btn.Image = icon
		btn.ImageColor3 = Color3.fromRGB(255, 255, 255)
		btn.Parent = CoreGui
		btn.ZIndex = 999
		btn.MouseButton1Click:Connect(callback)
		local stroke = Instance.new("UICorner", btn)
		stroke.CornerRadius = UDim.new(0.5, 0)
		btns[name] = btn
		return btn
	end
	
	addBtn("Jump", "rbxassetid://1297645249", 0.80, Color3.fromRGB(0, 180, 255), function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end)
	
	addBtn("Sit", "rbxassetid://1297645336", 0.70, Color3.fromRGB(100, 220, 100), function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Sit = not hum.Sit end
	end)
	
	addBtn("Reset", "rbxassetid://1297645513", 0.60, Color3.fromRGB(255, 80, 80), function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end)
	
	addBtn("TP", "rbxassetid://1297645697", 0.50, Color3.fromRGB(255, 200, 0), function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = Camera.CFrame.Position + Camera.CFrame.LookVector * 15
			hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		end
	end)
	
	return btns
end

-- ДВИЖЕНИЕ
local function MobileMovement()
	task.spawn(function()
		while true do
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root and Mobile.MoveDir.Magnitude > 0.1 then
				local cam = Camera.CFrame
				local fwd = cam.LookVector * Vector3.new(1, 0, 1)
				local right = cam.RightVector * Vector3.new(1, 0, 1)
				local move = (fwd * Mobile.MoveDir.Z + right * Mobile.MoveDir.X)
				if move.Magnitude > 1 then move = move.Unit end
				root.CFrame = root.CFrame + move * 0.7
				root.AssemblyLinearVelocity = Vector3.zero
			end
			task.wait(0.03)
		end
	end)
end

task.spawn(function()
	CreateJoystick()
	Mobile.Buttons = CreateButtons()
	MobileMovement()
end)

-- =====================================================
-- =====================================================
-- ВСЕ ФУНКЦИИ ИЗ ОРИГИНАЛЬНОГО ФАЙЛА (100%)
-- =====================================================
-- =====================================================

-- =====================================================
-- DEFENSE TAB (полностью)
-- =====================================================
local DefenseGroup = Tabs.Defense:AddLeftGroupbox("Defense Main")
local DefenseExtra = Tabs.Defense:AddRightGroupbox("Extra Defense")

-- Anti Grab (полный)
local autoStruggleConn = nil
DefenseGroup:AddToggle("AntiGrabObsidian", {
	Text = "Anti Grab",
	Default = false,
	Callback = function(Value)
		if Value then
			if autoStruggleConn then autoStruggleConn:Disconnect() end
			autoStruggleConn = R.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("PartOwner") then
					task.spawn(function()
						local Struggle = RS.CharacterEvents and RS.CharacterEvents:FindFirstChild("Struggle")
						if Struggle then Struggle:FireServer(LocalPlayer) end
						pcall(function() RS.GameCorrectionEvents.StopAllVelocity:FireServer() end)
						for _, part in pairs(char:GetChildren()) do
							if part:IsA("BasePart") then part.Anchored = true end
						end
						local isHeld = LocalPlayer:FindFirstChild("IsHeld")
						while isHeld and isHeld.Value do task.wait() end
						for _, part in pairs(char:GetChildren()) do
							if part:IsA("BasePart") then part.Anchored = false end
						end
					end)
				end
			end)
		else
			if autoStruggleConn then autoStruggleConn:Disconnect() end
		end
	end
})

-- Anti Blobman
local antiBlob1T = false
DefenseGroup:AddToggle("AntiBlobmanToggle", {
	Text = "Anti Blobman",
	Default = false,
	Callback = function(on)
		antiBlob1T = on
		if on then
			workspace.DescendantAdded:Connect(function(toy)
				if toy.Name == "CreatureBlobman" and antiBlob1T then
					pcall(function()
						if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
						if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
					end)
				end
			end)
		end
	end
})

-- Anti Explosion
local antiExplodeT = false
DefenseGroup:AddToggle("AntiExplosionToggle", {
	Text = "Anti Explosion",
	Default = false,
	Callback = function(on)
		antiExplodeT = on
		if on then
			task.spawn(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				workspace.ChildAdded:Connect(function(model)
					if model.Name == "Part" and antiExplodeT then
						local mag = (model.Position - hrp.Position).Magnitude
						if mag <= 20 then
							hrp.Anchored = true
							task.wait(0.01)
							local rightArm = char:FindFirstChild("Right Arm")
							local ragdoll = rightArm and rightArm:FindFirstChild("RagdollLimbPart")
							while ragdoll and ragdoll.CanCollide do task.wait(0.001) end
							hrp.Anchored = false
						end
					end
				end)
			end)
		end
	end
})

-- Anti Burn
local hookBurnConn
DefenseGroup:AddToggle("AntiBurnToggle", {
	Text = "Anti Burn",
	Default = false,
	Callback = function(on)
		if on then
			local char = LocalPlayer.Character
			local hum = char:WaitForChild("Humanoid")
			local hrp = char:WaitForChild("HumanoidRootPart")
			char.PrimaryPart = hrp
			if hookBurnConn then hookBurnConn:Disconnect() end
			hookBurnConn = hum.FireDebounce.Changed:Connect(function(isBurning)
				if isBurning then
					local oldCF = hrp.CFrame
					local plots = workspace:FindFirstChild("Plots")
					if plots and plots:FindFirstChild("Plot2") then
						local pb = plots.Plot2.Barrier and plots.Plot2.Barrier:FindFirstChild("PlotBarrier")
						if pb and pb:IsA("BasePart") then
							char:SetPrimaryPartCFrame(pb.CFrame * CFrame.new(0, 6, 0))
							task.wait(0.3)
							local firePart = char:FindFirstChild("FirePlayerPart", true)
							if firePart then
								for _, obj in pairs(firePart:GetChildren()) do
									if obj:IsA("Sound") then obj:Stop() end
									if obj:IsA("Light") or obj:IsA("ParticleEmitter") then obj.Enabled = false end
								end
								if firePart:FindFirstChild("CanBurn") then firePart.CanBurn.Value = false end
								if hum:FindFirstChild("FireDebounce") then hum.FireDebounce.Value = false end
							end
							task.wait(0.6)
							if char and char.PrimaryPart then char:SetPrimaryPartCFrame(oldCF) end
						end
					end
				end
			end)
		elseif hookBurnConn then hookBurnConn:Disconnect() end
	end
})

-- Anti Void
local antiVoidConn
DefenseGroup:AddToggle("AntiVoidToggle", {
	Text = "Anti Void",
	Default = false,
	Callback = function(on)
		if on then
			if antiVoidConn then antiVoidConn:Disconnect() end
			antiVoidConn = R.Heartbeat:Connect(function()
				local char = LocalPlayer.Character
				if char and char.PrimaryPart then
					local pos = char.PrimaryPart.Position
					if pos.Y < -50 then
						char:SetPrimaryPartCFrame(CFrame.new(pos.X, pos.Y + 100, pos.Z))
						char.PrimaryPart.AssemblyLinearVelocity = Vector3.zero
					end
				end
			end)
		else
			if antiVoidConn then antiVoidConn:Disconnect() end
		end
	end
})

-- Anti Sticky
DefenseGroup:AddToggle("AntiStickyToggle", {
	Text = "Anti Sticky",
	Default = false,
	Callback = function(Value)
		local sticky = LocalPlayer.PlayerScripts:FindFirstChild("StickyPartsTouchDetection")
		if sticky then sticky.Disabled = Value end
	end
})

-- Anti Lag (удаление граб-линий)
local createGrabLineCopy, extendGrabLineCopy
local grabFolder = RS:FindFirstChild("GrabEvents")
if grabFolder then
	local originalCreate = grabFolder:FindFirstChild("CreateGrabLine")
	local originalExtend = grabFolder:FindFirstChild("ExtendGrabLine")
	if originalCreate then createGrabLineCopy = originalCreate:Clone() end
	if originalExtend then extendGrabLineCopy = originalExtend:Clone() end
end

DefenseGroup:AddToggle("AntiLagToggle", {
	Text = "Anti Lag",
	Default = false,
	Callback = function(Value)
		if Value then
			local gf = RS:FindFirstChild("GrabEvents")
			if gf then
				local create = gf:FindFirstChild("CreateGrabLine")
				local extend = gf:FindFirstChild("ExtendGrabLine")
				if create and create:IsA("RemoteEvent") then create:Destroy() end
				if extend and extend:IsA("RemoteEvent") then extend:Destroy() end
			end
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("Beam") or v.Name:lower():find("line") then v:Destroy() end
			end
		else
			local gf = RS:FindFirstChild("GrabEvents")
			if gf then
				if createGrabLineCopy and not gf:FindFirstChild("CreateGrabLine") then
					createGrabLineCopy:Clone().Parent = gf
				end
				if extendGrabLineCopy and not gf:FindFirstChild("ExtendGrabLine") then
					extendGrabLineCopy:Clone().Parent = gf
				end
			end
		end
	end
})

-- Anti Input Lag (полный)
DefenseExtra:AddToggle("AntiInputLag", {
	Text = "Anti Input Lag",
	Default = false,
	Callback = function(Value)
		_G.AntiInputLag = Value
		if Value then
			task.spawn(function()
				local SelectedToy = "FoodHamburger"
				while _G.AntiInputLag do
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if hrp then
						local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
						local toy = folder and folder:FindFirstChild(SelectedToy)
						if not toy then
							pcall(function()
								RS.MenuToys.SpawnToyRemoteFunction:InvokeServer(SelectedToy, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.zero)
							end)
							task.wait(0.5)
						else
							local holdPart = toy:FindFirstChild("HoldPart")
							if holdPart then
								pcall(function()
									holdPart.HoldItemRemoteFunction:InvokeServer(toy, char)
									task.wait(0.05)
									holdPart.DropItemRemoteFunction:InvokeServer(toy, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.zero)
								end)
							end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

-- Anti Paint
local paintPartsBackup = {}
local paintConnections = {}
local function deleteAllPaintParts()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
			paintPartsBackup[obj] = obj:Clone()
			obj:Destroy()
		end
	end
end
local function restorePaintParts()
	for _, data in pairs(paintPartsBackup) do
		if data and data.Parent == nil then data.Parent = Workspace end
	end
	paintPartsBackup = {}
end
local function watchNewPaintParts()
	table.insert(paintConnections, Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
			task.defer(function()
				if obj and obj.Parent then
					paintPartsBackup[obj] = obj:Clone()
					obj:Destroy()
				end
			end)
		end
	end))
end
local function disconnectWatchers()
	for _, conn in ipairs(paintConnections) do
		if conn.Connected then conn:Disconnect() end
	end
	paintConnections = {}
end
local function setTouchQuery(state)
	local char = Workspace:FindFirstChild(LocalPlayer.Name)
	if not char then return end
	for _, v in pairs(char:GetChildren()) do
		if v:IsA("Part") or v:IsA("BasePart") then
			v.CanTouch = state
			v.CanQuery = state
		end
	end
end

DefenseExtra:AddToggle("PaintDeleteToggle", {
	Text = "Anti Paint",
	Default = false,
	Callback = function(state)
		if state then
			deleteAllPaintParts()
			watchNewPaintParts()
			setTouchQuery(false)
		else
			restorePaintParts()
			disconnectWatchers()
			setTouchQuery(true)
		end
	end
})

-- Anti Gucci (Blobman)
local autoGucciActive = false
local antiGucciConnection
local safePosition
local restoreFrames = 0

local function spawnBlobman()
	pcall(function()
		RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("CreatureBlobman", CFrame.new(0, 5000000, 0), Vector3.new(0, 60, 0))
	end)
end

local function startAntiGucci()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	safePosition = root.Position
	
	local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	local blob = folder and folder:FindFirstChild("CreatureBlobman")
	local seat = blob and blob:FindFirstChild("VehicleSeat")
	
	if not blob then
		spawnBlobman()
		task.wait(1)
		folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		blob = folder and folder:FindFirstChild("CreatureBlobman")
		seat = blob and blob:FindFirstChild("VehicleSeat")
	end
	
	if seat and seat:IsA("VehicleSeat") then
		root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(hum)
	end
	
	if antiGucciConnection then antiGucciConnection:Disconnect() end
	antiGucciConnection = R.Heartbeat:Connect(function()
		if not root or not hum then return end
		RS.CharacterEvents.RagdollRemote:FireServer(root, 0)
		if restoreFrames > 0 then
			root.CFrame = CFrame.new(safePosition)
			restoreFrames = restoreFrames - 1
		end
	end)
end

local function stopAntiGucci()
	if antiGucciConnection then antiGucciConnection:Disconnect() end
	local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	if folder and folder:FindFirstChild("CreatureBlobman") then
		folder.CreatureBlobman:Destroy()
	end
end

DefenseExtra:AddToggle("AutoGucciToggle", {
	Text = "Anti Gucci (Blobman)",
	Default = false,
	Callback = function(Value)
		autoGucciActive = Value
		if Value then
			startAntiGucci()
			task.spawn(function()
				while autoGucciActive do
					local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
					local blob = folder and folder:FindFirstChild("CreatureBlobman")
					if not blob then
						stopAntiGucci()
						spawnBlobman()
						task.wait(1)
						if autoGucciActive then startAntiGucci() end
					end
					task.wait(0.5)
				end
			end)
		else
			stopAntiGucci()
		end
	end
})

-- Anti Gucci (Train)
local autoGucciTrainActive = false
local antiGucciTrainConn
local safePositionTrain
local restoreFramesTrain = 0

local function startAntiGucciTrain()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local root = char:WaitForChild("HumanoidRootPart")
	safePositionTrain = root.Position
	
	local folder = workspace.Map.AlwaysHereTweenedObjects
	local train = folder and folder:FindFirstChild("Train")
	local seat
	if train then
		for _, d in pairs(train:GetDescendants()) do
			if d:IsA("Seat") then seat = d break end
		end
	end
	
	if seat then
		root.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
		seat:Sit(hum)
	end
	
	if antiGucciTrainConn then antiGucciTrainConn:Disconnect() end
	antiGucciTrainConn = R.Heartbeat:Connect(function()
		if not root or not hum then return end
		RS.CharacterEvents.RagdollRemote:FireServer(root, 0)
		if restoreFramesTrain > 0 then
			root.CFrame = CFrame.new(safePositionTrain)
			restoreFramesTrain = restoreFramesTrain - 1
		end
	end)
end

local function stopAntiGucciTrain()
	if antiGucciTrainConn then antiGucciTrainConn:Disconnect() end
	local trainFolder = workspace.Map.AlwaysHereTweenedObjects
	if trainFolder and trainFolder:FindFirstChild("Train") then
		LocalPlayer.Character.Humanoid.Health = 0
	end
end

DefenseExtra:AddToggle("AutoGucciTrainToggle", {
	Text = "Anti Gucci (Train)",
	Default = false,
	Callback = function(Value)
		autoGucciTrainActive = Value
		if Value then startAntiGucciTrain() else stopAntiGucciTrain() end
	end
})

-- Anti Kick (Shuriken)
DefenseExtra:AddToggle("ShurikenAntiKick", {
	Text = "Anti Kick",
	Default = false,
	Callback = function(Value)
		_G.ShurikenAntiKick = Value
		if Value then
			task.spawn(function()
				local setOwner = RS:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
				local stickyEvent = RS:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
				local spawnRemote = RS.MenuToys.SpawnToyRemoteFunction
				local destroyrem = RS.MenuToys.DestroyToy
				local canSpawn = LocalPlayer:WaitForChild("CanSpawnToy")
				
				local function getHRP()
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						return LocalPlayer.Character.HumanoidRootPart
					end
					return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
				end
				
				local function CheckForHome()
					if not workspace.PlotItems.PlayersInPlots:FindFirstChild(LocalPlayer.Name) then
						return false
					end
					for _, v in pairs(workspace.Plots:GetChildren()) do
						local sign = v:FindFirstChild("PlotSign")
						local owners = sign and sign:FindFirstChild("ThisPlotsOwners")
						if owners then
							for _, b in pairs(owners:GetChildren()) do
								if b.Value == LocalPlayer.Name then
									local folder = workspace.PlotItems:FindFirstChild(v.Name)
									if folder then return true, folder end
								end
							end
						end
					end
					return false
				end
				
				local function StickKunai(kunai)
					if not kunai or not kunai:FindFirstChild("StickyPart") then return end
					local hrp = getHRP()
					if not hrp then return end
					
					if kunai:FindFirstChild("SoundPart") then
						if not kunai.SoundPart:FindFirstChild("PartOwner") or kunai.SoundPart.PartOwner.Value ~= LocalPlayer.Name then
							setOwner:FireServer(kunai.SoundPart, kunai.SoundPart.CFrame)
						end
					end
					
					local firePart = hrp:FindFirstChild("FirePlayerPart") or hrp:WaitForChild("FirePlayerPart", 5)
					if firePart then
						stickyEvent:FireServer(kunai.StickyPart, firePart, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), math.rad(90)))
					end
					
					for _, obj in pairs(kunai:GetChildren()) do
						if obj.Name == "Pyramid" then
							obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false
						elseif obj.Name == "Main" then
							obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false
						elseif obj:IsA("BasePart") then
							obj.CanTouch = false; obj.CanCollide = false; obj.CanQuery = false
						end
					end
				end
				
				local function ClearKunai()
					local inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
					if inv and destroyrem then
						for _, v in pairs(inv:GetChildren()) do
							if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
								pcall(function() destroyrem:FireServer(v) end)
							end
						end
					end
				end
				
				while _G.ShurikenAntiKick do
					task.wait(0.005)
					local char = LocalPlayer.Character
					if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then continue end
					
					local inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
					local kunai = inv and inv:FindFirstChild("NinjaShuriken")
					
					if workspace.PlotItems.PlayersInPlots:FindFirstChild(LocalPlayer.Name) then
						local boolik, house = CheckForHome()
						if boolik and house and workspace.Plots:FindFirstChild(house.Name) then
							local sign = workspace.Plots[house.Name]:FindFirstChild("PlotSign")
							if sign and sign.ThisPlotsOwners.Value.TimeRemainingNum.Value > 89 then
								local hrp = getHRP()
								if hrp then
									pcall(function()
										spawnRemote:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 12, 20), Vector3.zero)
									end)
									task.wait(0.5)
									inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
									kunai = inv and inv:FindFirstChild("NinjaShuriken")
									if kunai then
										kunai.Name = "AntiKick"
										StickKunai(kunai)
									end
								end
							end
						end
					end
					
					if not kunai then
						if workspace.PlotItems.PlayersInPlots:FindFirstChild(LocalPlayer.Name) then continue end
						local hrp = getHRP()
						if hrp then
							pcall(function()
								spawnRemote:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 12, 20), Vector3.zero)
							end)
							task.wait(0.5)
							inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
							kunai = inv and inv:FindFirstChild("NinjaShuriken")
							if kunai then
								kunai.Name = "AntiKick"
								StickKunai(kunai)
							end
						end
					end
					
					if kunai and kunai:FindFirstChild("StickyPart") and kunai.StickyPart.CanTouch == true then
						StickKunai(kunai)
						kunai.Name = "AntiKick"
					end
					
					if not kunai or not kunai:FindFirstChild("StickyPart") or not char or not char:FindFirstChild("HumanoidRootPart") or (char.HumanoidRootPart.Position - kunai.StickyPart.Position).Magnitude >= 20 then
						ClearKunai()
					end
					task.wait(0.3)
				end
				ClearKunai()
			end)
		else
			_G.ShurikenAntiKick = false
			local inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
			local destroyrem = RS.MenuToys.DestroyToy
			if inv and destroyrem then
				for _, v in pairs(inv:GetChildren()) do
					if v.Name == "AntiKick" or v.Name == "NinjaShuriken" then
						pcall(function() destroyrem:FireServer(v) end)
					end
				end
			end
		end
	end
})

-- Loop TP
local tpActive = false
DefenseExtra:AddToggle("LoopTP", {
	Text = "Loop TP",
	Default = false,
	Callback = function(Value)
		tpActive = Value
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if Value then
			if hum then hum.PlatformStand = true end
			task.spawn(function()
				while tpActive and hrp do
					local x = math.random(-500, 500)
					local y = math.random(30, 480)
					local z = math.random(-500, 500)
					hrp.CFrame = CFrame.new(x, y, z)
					task.wait(0.03)
				end
			end)
		else
			if hum then hum.PlatformStand = false end
		end
	end
})

-- =====================================================
-- TARGET TAB (полностью)
-- =====================================================
local TargetGroup = Tabs.Target:AddLeftGroupbox("Target Interaction")
local BlobGroup = Tabs.Target:AddRightGroupbox("Blobman Kick")
local WhitelistGroup = Tabs.Target:AddRightGroupbox("Whitelist")

local selectedKickPlayer = nil
local kickLoopEnabled = false
local savedKickPos = nil
local currentKickTargetChar = nil

TargetGroup:AddDropdown("KickPlayerDropdown", {
	Values = getPlayerList(),
	Default = 1,
	Multi = false,
	Text = "Select Target",
	Callback = function(Value)
		selectedKickPlayer = getPlayerFromSelection(Value)
	end
})

TargetGroup:AddButton({
	Text = "Refresh List",
	Func = function()
		Options.KickPlayerDropdown:SetValues(getPlayerList())
	end
})

-- Kick (spam grab)
TargetGroup:AddToggle("LoopKickGrabToggle", {
	Text = "Kick (spam grab)",
	Default = false,
	Callback = function(on)
		kickLoopEnabled = on
		if not on then return end
		task.spawn(function()
			local GE = RS:WaitForChild("GrabEvents")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then Toggles.LoopKickGrabToggle:SetValue(false) return end
			local savedPos = myRoot.CFrame
			local dragging = false
			local grabStart = 0
			
			while kickLoopEnabled do
				local target = selectedKickPlayer
				if not target or not target.Parent then break end
				myChar = LocalPlayer.Character
				myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myRoot then break end
				local tChar = target.Character
				local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
				local tHum = tChar and tChar:FindFirstChild("Humanoid")
				if tRoot and tHum and tHum.Health > 0 then
					tRoot.AssemblyLinearVelocity = Vector3.zero
					tRoot.AssemblyAngularVelocity = Vector3.zero
					if not dragging then
						myRoot.CFrame = tRoot.CFrame
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = true
							GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
						if grabStart == 0 then grabStart = tick() end
						if tick() - grabStart > 0.35 then
							dragging = true
							grabStart = 0
						end
					else
						myRoot.CFrame = savedPos
						local lockPos = savedPos * CFrame.new(0, 17, 0)
						tRoot.CFrame = lockPos
						tRoot.Velocity = Vector3.zero
						pcall(function()
							tHum.PlatformStand = true
							GE.SetNetworkOwner:FireServer(tRoot, lockPos)
							GE.DestroyGrabLine:FireServer(tRoot)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
					end
				else
					dragging = false
					grabStart = 0
				end
				R.Heartbeat:Wait()
			end
			if myRoot then myRoot.CFrame = savedPos end
			kickLoopEnabled = false
			Toggles.LoopKickGrabToggle:SetValue(false)
		end)
	end
})

-- Ragdoll Snowball
TargetGroup:AddToggle("RagdollSnowballKick", {
	Text = "Ragdoll Snowball",
	Default = false,
	Callback = function(on)
		if on then
			task.spawn(function()
				local spawnRemote = RS.MenuToys:WaitForChild("SpawnToyRemoteFunction")
				while on do
					local target = selectedKickPlayer
					if not target or not target.Parent then task.wait(0.1) continue end
					local tChar = target.Character
					local torso = tChar and (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso"))
					if torso then
						pcall(function()
							local offset = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
							spawnRemote:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero)
						end)
						local folder = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
						if folder then
							for _, snowball in pairs(folder:GetChildren()) do
								if snowball.Name == "BallSnowball" then
									local part = snowball.PrimaryPart or snowball:FindFirstChildWhichIsA("BasePart")
									if part then
										part.CFrame = torso.CFrame * CFrame.new(0, 0, 0)
										part.AssemblyLinearVelocity = Vector3.zero
									end
								end
							end
						end
					end
					task.wait(0.05)
				end
			end)
		end
	end
})

-- Kick (ragdoll grab)
TargetGroup:AddToggle("LoopKickRagdollToggle", {
	Text = "Kick (ragdoll grab)",
	Default = false,
	Callback = function(on)
		kickLoopEnabled = on
		if not on then return end
		task.spawn(function()
			local GE = RS:WaitForChild("GrabEvents")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then Toggles.LoopKickRagdollToggle:SetValue(false) return end
			local savedPos = myRoot.CFrame
			local dragging = false
			local grabStart = 0
			
			while kickLoopEnabled do
				local target = selectedKickPlayer
				if not target or not target.Parent then break end
				myChar = LocalPlayer.Character
				myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myRoot then break end
				local tChar = target.Character
				local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
				local tHum = tChar and tChar:FindFirstChild("Humanoid")
				if tRoot and tHum and tHum.Health > 0 then
					tRoot.AssemblyLinearVelocity = Vector3.zero
					tRoot.AssemblyAngularVelocity = Vector3.zero
					if not dragging then
						myRoot.CFrame = tRoot.CFrame
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = true
							GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
						if grabStart == 0 then grabStart = tick() end
						if tick() - grabStart > 0.15 then
							dragging = true
							grabStart = 0
							myRoot.CFrame = savedPos
						end
					else
						local lockCFrame = CFrame.new(savedPos.Position + Vector3.new(0, 7, 0)) * CFrame.Angles(math.rad(math.random(-180,180)), math.rad(math.random(-180,180)), math.rad(math.random(-180,180)))
						tRoot.CFrame = tRoot.CFrame:Lerp(lockCFrame, 0.2)
						tRoot.Velocity = Vector3.zero
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = false
							GE.SetNetworkOwner:FireServer(tRoot, tRoot.CFrame)
							GE.DestroyGrabLine:FireServer(tRoot)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
					end
				else
					dragging = false
					grabStart = 0
				end
				R.Heartbeat:Wait()
			end
			if myRoot then myRoot.CFrame = savedPos end
			kickLoopEnabled = false
			Toggles.LoopKickRagdollToggle:SetValue(false)
		end)
	end
})

-- Grab Troll (spam grab)
TargetGroup:AddToggle("GrabTrollToggle", {
	Text = "Grab Troll (spam grab)",
	Default = false,
	Callback = function(on)
		kickLoopEnabled = on
		if not on then return end
		task.spawn(function()
			local GE = RS:WaitForChild("GrabEvents")
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then Toggles.GrabTrollToggle:SetValue(false) return end
			local savedPos = myRoot.CFrame
			local dragging = false
			local grabStart = 0
			
			local function IsRagdolled(hum)
				local r = hum and hum:FindFirstChild("Ragdolled")
				return r ~= nil and r.Value == true
			end
			
			while kickLoopEnabled do
				local target = selectedKickPlayer
				if not target or not target.Parent then break end
				myChar = LocalPlayer.Character
				myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if not myRoot then break end
				local tChar = target.Character
				local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
				local tHum = tChar and tChar:FindFirstChild("Humanoid")
				if tRoot and tHum and tHum.Health > 0 then
					tRoot.AssemblyLinearVelocity = Vector3.zero
					tRoot.AssemblyAngularVelocity = Vector3.zero
					if not dragging then
						myRoot.CFrame = tRoot.CFrame
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = true
							GE.SetNetworkOwner:FireServer(tRoot, myRoot.CFrame)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
						if grabStart == 0 then grabStart = tick() end
						if tick() - grabStart > 0.35 then
							dragging = true
							grabStart = 0
						end
					else
						if not IsRagdolled(tHum) then
							dragging = false
							grabStart = 0
							pcall(function() GE.DestroyGrabLine:FireServer(tRoot) end)
							R.Heartbeat:Wait()
							continue
						end
						myRoot.CFrame = savedPos
						local lockPos = savedPos * CFrame.new(0, 17, 0)
						tRoot.CFrame = lockPos
						tRoot.Velocity = Vector3.zero
						pcall(function()
							tHum.PlatformStand = true
							GE.SetNetworkOwner:FireServer(tRoot, lockPos)
							GE.DestroyGrabLine:FireServer(tRoot)
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
					end
				else
					dragging = false
					grabStart = 0
				end
				R.Heartbeat:Wait()
			end
			if myRoot then myRoot.CFrame = savedPos end
			kickLoopEnabled = false
			Toggles.GrabTrollToggle:SetValue(false)
		end)
	end
})

-- Loop Kick (grab + blob)
TargetGroup:AddToggle("LoopKickToggle", {
	Text = "Loop Kick (grab + blob)",
	Default = false,
	Callback = function(on)
		kickLoopEnabled = on
		local target = selectedKickPlayer
		if on and not target then Toggles.LoopKickToggle:SetValue(false) return end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		local seat = hum and hum.SeatPart
		if on and (not seat or seat.Parent.Name ~= "CreatureBlobman") then
			Toggles.LoopKickToggle:SetValue(false)
			return
		end
		if not on then kickLoopEnabled = false return end
		
		task.spawn(function()
			local GE = RS:WaitForChild("GrabEvents")
			local blob = seat.Parent
			local blobRoot = blob:FindFirstChild("HumanoidRootPart") or blob.PrimaryPart
			local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
			local CG = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
			local CD = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
			local R_Det = blob:FindFirstChild("RightDetector")
			local R_Weld = R_Det and (R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld"))
			local SavedPos = blobRoot.CFrame
			local tChar = target.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			
			if tRoot and blobRoot then
				local bringStart = tick()
				while tick() - bringStart < 0.35 and kickLoopEnabled do
					blobRoot.CFrame = tRoot.CFrame
					blobRoot.Velocity = Vector3.zero
					pcall(function()
						if CG and R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
						GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						GE.SetNetworkOwner:FireServer(tRoot, blobRoot.CFrame)
					end)
					R.Heartbeat:Wait()
				end
				blobRoot.CFrame = SavedPos
				task.wait(0.05)
			end
			
			local packetTimer = 0
			while kickLoopEnabled do
				if not target or not target.Parent or not target.Character then break end
				tChar = target.Character
				tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
				local tHum = tChar and tChar:FindFirstChild("Humanoid")
				if tRoot and tHum and tHum.Health > 0 and blobRoot then
					blobRoot.CFrame = SavedPos
					local lockPos = SavedPos * CFrame.new(0, 23, 0)
					tRoot.CFrame = lockPos
					tRoot.Velocity = Vector3.zero
					if tick() - packetTimer > 0.05 then
						packetTimer = tick()
						pcall(function()
							tHum.PlatformStand = true
							tHum.Sit = true
							GE.SetNetworkOwner:FireServer(tRoot, lockPos)
							if R_Det then
								local weld = R_Det:FindFirstChild("RightWeld") or R_Det:FindFirstChildWhichIsA("Weld")
								if weld then CD:FireServer(weld) end
							end
							GE.DestroyGrabLine:FireServer(tRoot)
							if R_Det then CG:FireServer(R_Det, tRoot, R_Weld) end
							GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, tRoot.Position, false)
						end)
					end
				end
				R.Heartbeat:Wait()
			end
			kickLoopEnabled = false
			Toggles.LoopKickToggle:SetValue(false)
			if blobRoot then blobRoot.CFrame = SavedPos end
		end)
	end
})

-- Dual Hand Loop Kick
local loopKickDualActive = false
TargetGroup:AddToggle("DualHandLoopKick", {
	Text = "Dual Hand Loop Kick",
	Default = false,
	Callback = function(on)
		loopKickDualActive = on
		if on then
			if not selectedKickPlayer then notify("Error", "Select target first", 3) Toggles.DualHandLoopKick:SetValue(false) return end
			task.spawn(function()
				local lastTargetCharDual = nil
				local bp = nil
				while loopKickDualActive do
					local target = selectedKickPlayer
					local char = LocalPlayer.Character
					local hum = char and char:FindFirstChild("Humanoid")
					local seat = hum and hum.SeatPart
					if not seat or not target or not target.Parent then task.wait(0.5) continue end
					local seatParent = seat.Parent
					local grab = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript") and seatParent.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureGrab")
					local drop = seatParent:FindFirstChild("BlobmanSeatAndOwnerScript") and seatParent.BlobmanSeatAndOwnerScript:FindFirstChild("CreatureDrop")
					if not grab or not drop then task.wait(0.5) continue end
					local leftDet = seatParent:FindFirstChild("LeftDetector")
					local rightDet = seatParent:FindFirstChild("RightDetector")
					local leftWeld = leftDet and leftDet:FindFirstChild("LeftWeld")
					local rightWeld = rightDet and rightDet:FindFirstChild("RightWeld")
					local hrp = char:FindFirstChild("HumanoidRootPart")
					local targetChar = target.Character
					local targetHRP = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
					local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")
					
					if targetHRP and targetHum and targetHum.Health > 0 then
						if targetChar ~= lastTargetCharDual then
							lastTargetCharDual = targetChar
							if bp then bp:Destroy() end
							if hrp then hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 25, 0) end
							task.wait(0.2)
							grab:FireServer(leftDet, targetHRP, leftWeld)
							task.wait(0.3)
							drop:FireServer(leftWeld, targetHRP)
							task.wait(0.1)
							bp = Instance.new("BodyPosition")
							bp.Position = Vector3.new(0, 999999, 0)
							bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
							bp.Parent = targetHRP
							grab:FireServer(leftDet, targetHRP, leftWeld)
							task.wait(0.2)
							drop:FireServer(leftWeld, targetHRP)
						end
						grab:FireServer(leftDet, targetHRP, leftWeld)
						task.wait()
						drop:FireServer(leftWeld, targetHRP)
						task.wait()
						grab:FireServer(rightDet, targetHRP, rightWeld)
						task.wait()
						drop:FireServer(rightWeld, targetHRP)
						task.wait()
						grab:FireServer(leftDet, targetHRP, leftWeld)
						grab:FireServer(rightDet, targetHRP, rightWeld)
						task.wait()
						drop:FireServer(leftWeld, targetHRP)
						drop:FireServer(rightWeld, targetHRP)
					end
					task.wait()
				end
				if bp then bp:Destroy() end
			end)
		end
	end
})

-- Fling
local playerFlingActive = false
local flingBAV = nil
local originalPos = nil
TargetGroup:AddToggle("PlayerFlingBtn", {
	Text = "Fling",
	Default = false,
	Callback = function(on)
		playerFlingActive = on
		if on and selectedKickPlayer then
			task.spawn(function()
				while playerFlingActive do
					local target = selectedKickPlayer
					local char = LocalPlayer.Character
					local hrp = char and char:FindFirstChild("HumanoidRootPart")
					if not hrp then task.wait(0.5) continue end
					if not originalPos then originalPos = hrp.CFrame end
					local tChar = target and target.Character
					local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
					local tHum = tChar and tChar:FindFirstChild("Humanoid")
					if tRoot and tHum and tHum.Health > 0 then
						if not flingBAV or flingBAV.Parent ~= hrp then
							if flingBAV then flingBAV:Destroy() end
							flingBAV = Instance.new("BodyAngularVelocity", hrp)
							flingBAV.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
							flingBAV.AngularVelocity = Vector3.new(0, 10000, 0)
							flingBAV.P = 10000
						end
						for _, part in pairs(char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = false end
						end
						local loop = R.Heartbeat:Connect(function()
							if not playerFlingActive or not tRoot or not tRoot.Parent then return end
							hrp.CFrame = tRoot.CFrame
							hrp.Velocity = Vector3.zero
						end)
						local start = tick()
						while tick() - start < 1.5 and playerFlingActive and tRoot and tRoot.Parent do
							task.wait(0.05)
						end
						if loop then loop:Disconnect() end
						if flingBAV then flingBAV:Destroy() end
						for _, part in pairs(char:GetDescendants()) do
							if part:IsA("BasePart") then part.CanCollide = true end
						end
						if hrp and originalPos then
							hrp.CFrame = originalPos
							hrp.RotVelocity = Vector3.zero
							hrp.Velocity = Vector3.zero
						end
					end
					task.wait(0.1)
				end
				if flingBAV then flingBAV:Destroy() end
			end)
		end
	end
})

-- Destroy Gucci (sit)
local DestroyTargetGucciActive = false
TargetGroup:AddToggle("DestroyTargetGucci", {
	Text = "Destroy Gucci (sit)",
	Default = false,
	Callback = function(Value)
		DestroyTargetGucciActive = Value
		if Value and selectedKickPlayer then
			task.spawn(function()
				local folderName = selectedKickPlayer.Name .. "SpawnedInToys"
				while DestroyTargetGucciActive do
					local toysFolder = workspace:FindFirstChild(folderName)
					if toysFolder then
						for _, obj in pairs(toysFolder:GetChildren()) do
							if obj.Name == "CreatureBlobman" then
								local seat = obj:FindFirstChild("VehicleSeat") or obj:FindFirstChildWhichIsA("VehicleSeat", true)
								if seat then
									local myChar = LocalPlayer.Character
									local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
									local myHum = myChar and myChar:FindFirstChild("Humanoid")
									if myRoot and myHum then
										local magnetConnection
										magnetConnection = R.Stepped:Connect(function()
											if myRoot and seat then
												myRoot.CFrame = seat.CFrame
												myRoot.Velocity = Vector3.zero
												if obj.PrimaryPart then
													obj.PrimaryPart.Velocity = Vector3.zero
												end
											end
										end)
										local sitStart = tick()
										while tick() - sitStart < 1 and DestroyTargetGucciActive do
											if myHum.SeatPart == seat then break end
											seat:Sit(myHum)
											task.wait()
										end
										if magnetConnection then magnetConnection:Disconnect() end
										if myHum.SeatPart == seat then
											task.wait(0.3)
											myHum.Sit = false
											myHum.Jump = true
											task.wait(0.05)
											myRoot.CFrame = originalPos or myRoot.CFrame
										end
									end
								end
							end
						end
					end
					task.wait(1)
				end
			end)
		end
	end
})

-- Bring
TargetGroup:AddButton({
	Text = "Bring",
	Func = function()
		if not selectedKickPlayer then return end
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		local seat = hum and hum.SeatPart
		if not seat or seat.Parent.Name ~= "CreatureBlobman" then return end
		local blob = seat.Parent
		local blobRoot = blob:FindFirstChild("HumanoidRootPart")
		local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
		if not blobRoot or not scriptObj then return end
		local CG = scriptObj:FindFirstChild("CreatureGrab")
		local CD = scriptObj:FindFirstChild("CreatureDrop")
		local R_Det = blob:FindFirstChild("RightDetector")
		local R_Weld = R_Det and R_Det:FindFirstChild("RightWeld")
		local tChar = selectedKickPlayer.Character
		local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
		if not tRoot then return end
		local home = blobRoot.CFrame
		blobRoot.CFrame = tRoot.CFrame
		task.wait(0.3)
		pcall(function() CG:FireServer(R_Det, tRoot, R_Weld) end)
		task.wait(0.5)
		blobRoot.CFrame = home
		task.wait(0.05)
		for i = 1, 12 do
			tRoot.CFrame = home * CFrame.new(0, 3, 0)
			tRoot.Velocity = Vector3.zero
			task.wait(0.03)
		end
		for i = 1, 8 do
			local weld = R_Det:FindFirstChild("RightWeld")
			if weld then pcall(function() CD:FireServer(weld) end) end
			task.wait(0.03)
		end
	end
})

-- Remove Anti Input Lag (Anti AntiLag)
local AllowedItems = {
	FoodHamburger = true, FoodCoconut = true, FoodPizzaCheese = true, FoodPizzaPepperoni = true,
	FoodHotdog = true, FoodMushroomPoison = true, FoodBread = true, FoodDippyEgg = true,
	FoodMayonnaise = true, FoodFrenchFries = true, FoodMeatStick = true, FoodDonut = true,
	FoodCakePink = true, InstrumentGuitarBanjo = true, InstrumentGuitarViolin = true,
	InstrumentGuitarUkulele = true, InstrumentWoodwindSaxophone = true, InstrumentWoodwindOcarina = true,
	InstrumentBrassVuvuzelaQwizik = true, InstrumentBrassTrumpet = true, InstrumentDrumBongos = true,
	InstrumentDrumSnare = true, InstrumentPianoMelodica = true, InstrumentVoiceMicrophone = true,
	CupMugWhite = true, CupMugBrown = true, PoopPile = true, PoopPileSparkle = true,
}
local antiAntiLagEnabled = false

TargetGroup:AddToggle("RemoveAntiInputLag", {
	Text = "Remove Anti Input Lag",
	Default = false,
	Callback = function(on)
		antiAntiLagEnabled = on
		if on then
			task.spawn(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				local items = {}
				for _, v in ipairs(Workspace:GetDescendants()) do
					if AllowedItems[v.Name] and v:IsA("Model") and v:FindFirstChild("HoldPart") then
						table.insert(items, v)
					end
				end
				Workspace.DescendantAdded:Connect(function(obj)
					if AllowedItems[obj.Name] and obj:IsA("Model") then
						task.spawn(function()
							local hp = obj:WaitForChild("HoldPart", 3)
							if hp then table.insert(items, obj) end
						end)
					end
				end)
				while antiAntiLagEnabled do
					for i = #items, 1, -1 do
						local b = items[i]
						if not b or not b.Parent or not b:FindFirstChild("HoldPart") then
							table.remove(items, i)
						else
							local hp = b.HoldPart
							pcall(function()
								hp.HoldItemRemoteFunction:InvokeServer(b, char)
							end)
							task.wait()
							pcall(function()
								hp.DropItemRemoteFunction:InvokeServer(b, CFrame.new(hrp.Position + Vector3.new(0, -2000, 0)), Vector3.zero)
							end)
						end
					end
					task.wait()
				end
			end)
		end
	end
})

-- Whitelist
WhitelistGroup:AddDropdown("MultiWhitelist", {
	Values = getPlayerList(),
	Default = {},
	Multi = true,
	Text = "Whitelist",
})
WhitelistGroup:AddButton({
	Text = "Refresh List",
	Func = function()
		Options.MultiWhitelist:SetValues(getPlayerList())
	end
})

-- Joined Notify
local notifyActive = false
local notifyConnection = nil
WhitelistGroup:AddToggle("JoinedNotifyBtn", {
	Text = "Target Joined Notify",
	Default = false,
	Callback = function(on)
		notifyActive = on
		if on then
			if notifyConnection then notifyConnection:Disconnect() end
			notifyConnection = PS.PlayerAdded:Connect(function(newPlayer)
				if not notifyActive then return end
				local detected = false
				local whitelist = Options.MultiWhitelist.Value
				for nameString, isSelected in pairs(whitelist) do
					if isSelected then
						local actualName = nameString:match("%((.-)%)")
						if actualName == newPlayer.Name then detected = true break end
					end
				end
				if not detected and Options.KickPlayerDropdown and Options.KickPlayerDropdown.Value then
					local selection = Options.KickPlayerDropdown.Value
					local selectedName = selection:match("%((.-)%)")
					if selectedName and selectedName == newPlayer.Name then detected = true end
				end
				if detected then
					notify("Detected", "Target joined: " .. newPlayer.Name, 5)
					local sound = Instance.new("Sound", workspace)
					sound.SoundId = "rbxassetid://4590662766"
					sound.Volume = 2
					sound:Play()
					game:GetService("Debris"):AddItem(sound, 3)
				end
			end)
		else
			if notifyConnection then notifyConnection:Disconnect() end
		end
	end
})

-- Remove Anti Kick
local antiAntiKickActive = false
TargetGroup:AddToggle("DestroyAntiKickToggle", {
	Text = "Remove Anti Kick",
	Default = false,
	Callback = function(Value)
		antiAntiKickActive = Value
		if Value then
			task.spawn(function()
				local SetNetOwner = RS.GrabEvents.SetNetworkOwner
				local function CheckAndYeet(toy)
					local part = toy:FindFirstChild("SoundPart")
					if part then
						SetNetOwner:FireServer(part, part.CFrame)
						if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LocalPlayer.Name then
							part.CFrame = CFrame.new(0, 1000, 0)
						end
					end
				end
				while antiAntiKickActive do
					local target = selectedKickPlayer
					if target then
						local spawned = workspace:FindFirstChild(target.Name .. "SpawnedInToys")
						if spawned then
							for _, name in pairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
								local toy = spawned:FindFirstChild(name)
								if toy then CheckAndYeet(toy) end
							end
						end
					end
					task.wait(0.1)
				end
			end)
		end
	end
})

-- =====================================================
-- GRAB TAB (полностью)
-- =====================================================
local GrabGroup = Tabs.Grab:AddLeftGroupbox("Grab Customization")

_G.strength = 750
local strengthConnection
GrabGroup:AddSlider("ThrowPowerSlider", {
	Text = "Power",
	Default = 750,
	Min = 1,
	Max = 20000,
	Rounding = 0,
	Callback = function(value) _G.strength = value end
})

GrabGroup:AddToggle("ThrowStrengthToggle", {
	Text = "Strength",
	Default = false,
	Callback = function(enabled)
		if enabled then
			strengthConnection = workspace.ChildAdded:Connect(function(model)
				if model.Name == "GrabParts" then
					local part = model.GrabPart.WeldConstraint.Part1
					if part then
						local bv = Instance.new("BodyVelocity", part)
						model:GetPropertyChangedSignal("Parent"):Connect(function()
							if not model.Parent then
								if UserInputService:GetLastInputType() == Enum.UserInputType.MouseButton2 then
									bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
									bv.Velocity = Camera.CFrame.LookVector * _G.strength
									game:GetService("Debris"):AddItem(bv, 1)
								else
									bv:Destroy()
								end
							end
						end)
					end
				end
			end)
		elseif strengthConnection then
			strengthConnection:Disconnect()
		end
	end
})

-- Kill Grab
local killGrabEnabled = false
GrabGroup:AddToggle("KillGrabToggle", {
	Text = "Kill Grab",
	Default = false,
	Callback = function(Value)
		killGrabEnabled = Value
		if Value then
			workspace.ChildAdded:Connect(function(v)
				if v:IsA("Model") and v.Name == "GrabParts" then
					task.wait(0.05)
					local gp = v:FindFirstChild("GrabPart")
					if gp and gp:FindFirstChild("WeldConstraint") then
						local p1 = gp.WeldConstraint.Part1
						if p1 and p1.Parent and p1.Parent ~= LocalPlayer.Character then
							local hum = p1.Parent:FindFirstChildOfClass("Humanoid")
							if hum then hum.Health = 0 end
						end
					end
				end
			end)
		end
	end
})

-- MassLess Grab
GrabGroup:AddToggle("MassLessGrabToggle", {
	Text = "MassLess Grab",
	Default = false,
	Callback = function(Value)
		_G.MassLessGrab = Value
		if Value then
			_G.MLSense = 200
			_G.MLConn = R.Heartbeat:Connect(function()
				local gp = workspace:FindFirstChild("GrabParts")
				if not gp then return end
				local dp = gp:FindFirstChild("DragPart")
				if not dp then return end
				local ap = dp:FindFirstChild("AlignPosition")
				local ao = dp:FindFirstChild("AlignOrientation")
				if ap then
					ap.Responsiveness = _G.MLSense
					ap.MaxForce = math.huge
				end
				if ao then
					ao.Responsiveness = _G.MLSense
					ao.MaxTorque = math.huge
				end
			end)
		elseif _G.MLConn then
			_G.MLConn:Disconnect()
		end
	end
})

-- =====================================================
-- PLAYER TAB (полностью)
-- =====================================================
local PlayerView = Tabs.Player:AddLeftGroupbox("View & Movement")
local PlayerESP = Tabs.Player:AddRightGroupbox("ESP")
local PlayerEnv = Tabs.Player:AddLeftGroupbox("Environment")
local PlayerPerf = Tabs.Player:AddRightGroupbox("Performance")

-- Third Person
PlayerView:AddToggle("ThirdPersonToggle", {
	Text = "3rd Person View",
	Default = false,
	Callback = function(Value)
		if Value then
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			Camera.CameraType = Enum.CameraType.Custom
			LocalPlayer.CameraMaxZoomDistance = 999999
			LocalPlayer.CameraMinZoomDistance = 0.5
		else
			LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			LocalPlayer.CameraMaxZoomDistance = 0
			LocalPlayer.CameraMinZoomDistance = 0
		end
	end
})

-- Spin
local spinningConnection
local spinSpeed = 5
PlayerView:AddToggle("SpinToggle", {
	Text = "Spin Character",
	Default = false,
	Callback = function(Value)
		if Value then
			spinningConnection = R.Heartbeat:Connect(function()
				local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
			end)
		elseif spinningConnection then
			spinningConnection:Disconnect()
		end
	end
})
PlayerView:AddSlider("SpinSpeed", {
	Text = "Spin Speed",
	Default = 5,
	Min = 1,
	Max = 50,
	Rounding = 0,
	Callback = function(Value) spinSpeed = Value end
})

-- Infinite Jump
local infJump = false
PlayerView:AddToggle("infJumpToggle", {
	Text = "Infinite Jump",
	Default = false,
	Callback = function(Value) infJump = Value end
})
UserInputService.JumpRequest:Connect(function()
	if infJump then
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ESP (Box)
local espEnabled = false
local espBoxes = {}
local targetNames = {"partesp", "playercharacterlocationdetector"}
local function IsTarget(obj)
	if not obj:IsA("BasePart") then return false end
	for _, name in pairs(targetNames) do
		if string.lower(obj.Name) == string.lower(name) then return true end
	end
	return false
end

PlayerESP:AddToggle("BoxESPWhite", {
	Text = "PCLD View",
	Default = false,
	Callback = function(Value)
		espEnabled = Value
		if Value then
			for _, obj in ipairs(Workspace:GetDescendants()) do
				if IsTarget(obj) then
					local box = Instance.new("BoxHandleAdornment")
					box.Adornee = obj
					box.AlwaysOnTop = true
					box.Color3 = Color3.fromRGB(255, 255, 255)
					box.Transparency = 0.5
					box.Size = obj.Size
					box.Parent = CoreGui
					espBoxes[obj] = box
				end
			end
			Workspace.DescendantAdded:Connect(function(obj)
				if espEnabled and IsTarget(obj) then
					local box = Instance.new("BoxHandleAdornment")
					box.Adornee = obj
					box.AlwaysOnTop = true
					box.Color3 = Color3.fromRGB(255, 255, 255)
					box.Transparency = 0.5
					box.Size = obj.Size
					box.Parent = CoreGui
					espBoxes[obj] = box
				end
			end)
		else
			for obj, box in pairs(espBoxes) do
				if box then box:Destroy() end
			end
			espBoxes = {}
		end
	end
})

-- Nickname ESP
PlayerESP:AddToggle("NicknameESP", {
	Text = "Nickname Esp",
	Default = false,
	Callback = function(Value)
		if Value then
			for _, plr in pairs(PS:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					if not hrp:FindFirstChild("NameESP") then
						local bg = Instance.new("BillboardGui", hrp)
						bg.Name = "NameESP"
						bg.Adornee = hrp
						bg.Size = UDim2.new(0, 100, 0, 30)
						bg.StudsOffset = Vector3.new(0, 3, 0)
						bg.AlwaysOnTop = true
						local tl = Instance.new("TextLabel", bg)
						tl.Size = UDim2.new(1, 0, 1, 0)
						tl.BackgroundTransparency = 1
						tl.Text = plr.Name
						tl.TextColor3 = Color3.fromRGB(255, 255, 255)
						tl.TextScaled = true
					end
				end
			end
		else
			for _, plr in pairs(PS:GetPlayers()) do
				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = plr.Character.HumanoidRootPart
					if hrp:FindFirstChild("NameESP") then hrp.NameESP:Destroy() end
				end
			end
		end
	end
})

-- Dreamy Night Shader
local dreamyEffects = nil
PlayerEnv:AddToggle("DreamyNightShaderToggle", {
	Text = "Dreamy Night Shader",
	Default = false,
	Callback = function(on)
		local Lighting = game:GetService("Lighting")
		if not dreamyEffects then
			local Blur = Instance.new("BlurEffect", Lighting)
			Blur.Size = 6
			local Bloom = Instance.new("BloomEffect", Lighting)
			Bloom.Intensity = 1.6
			Bloom.Size = 90
			Bloom.Threshold = 1.4
			local Color = Instance.new("ColorCorrectionEffect", Lighting)
			Color.Brightness = 0.15
			Color.Contrast = -0.1
			Color.Saturation = 0.25
			Color.TintColor = Color3.fromRGB(210, 220, 255)
			local SunRays = Instance.new("SunRaysEffect", Lighting)
			SunRays.Intensity = 0.05
			SunRays.Spread = 0.6
			local Atmosphere = Instance.new("Atmosphere", Lighting)
			Atmosphere.Density = 0.45
			Atmosphere.Offset = 0.1
			Atmosphere.Color = Color3.fromRGB(180, 190, 255)
			Atmosphere.Decay = Color3.fromRGB(120, 130, 180)
			Atmosphere.Glare = 0.15
			Atmosphere.Haze = 3
			dreamyEffects = {Blur, Bloom, Color, SunRays, Atmosphere}
		end
		for _, effect in pairs(dreamyEffects) do effect.Enabled = on end
		if on then
			Lighting.ClockTime = 0.5
			Lighting.GlobalShadows = false
			Lighting.Brightness = 2
		end
	end
})

-- Boost FPS
local oldProperties = {}
PlayerPerf:AddButton({
	Text = "Boost FPS",
	Func = function()
		local Lighting = game:GetService("Lighting")
		for _, v in pairs(Workspace:GetDescendants()) do
			if v:IsA("BasePart") then
				if not oldProperties[v] then oldProperties[v] = {Material = v.Material, Reflectance = v.Reflectance, CastShadow = v.CastShadow} end
				v.Material = Enum.Material.Plastic
				v.Reflectance = 0
				v.CastShadow = false
			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
				if not oldProperties[v] then oldProperties[v] = {Enabled = v.Enabled} end
				v.Enabled = false
			end
		end
		for _, plr in pairs(PS:GetPlayers()) do
			if plr.Character then
				for _, part in pairs(plr.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						if not oldProperties[part] then oldProperties[part] = {Material = part.Material, Reflectance = part.Reflectance, CastShadow = part.CastShadow} end
						part.Material = Enum.Material.Plastic
						part.Reflectance = 0
						part.CastShadow = false
					end
				end
			end
		end
		if not oldProperties["Lighting"] then
			oldProperties["Lighting"] = {GlobalShadows = Lighting.GlobalShadows, FogEnd = Lighting.FogEnd, Brightness = Lighting.Brightness}
		end
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100000
		Lighting.Brightness = 2
	end
})

PlayerPerf:AddButton({
	Text = "Restore FPS",
	Func = function()
		local Lighting = game:GetService("Lighting")
		for obj, props in pairs(oldProperties) do
			if obj and obj.Parent then
				for prop, value in pairs(props) do obj[prop] = value end
			elseif obj == "Lighting" then
				for prop, value in pairs(props) do Lighting[prop] = value end
			end
		end
		oldProperties = {}
	end
})

-- =====================================================
-- MISC TAB (полностью)
-- =====================================================
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Miscellaneous")

-- FOV
MiscGroup:AddSlider("FOVSlider", {
	Text = "FOV",
	Default = 90,
	Min = 1,
	Max = 120,
	Rounding = 0,
	Suffix = "°",
	Callback = function(value) Camera.FieldOfView = value end
})

-- Ignore House Barriers
MiscGroup:AddToggle("NoBarrierCollision", {
	Text = "Ignore House Barriers",
	Default = false,
	Callback = function(Value)
		local plots = workspace:FindFirstChild("Plots")
		if not plots then return end
		for _, plot in pairs(plots:GetChildren()) do
			local barrier = plot:FindFirstChild("Barrier")
			if barrier then
				for _, obj in pairs(barrier:GetDescendants()) do
					if obj:IsA("BasePart") then obj.CanCollide = not Value end
				end
			end
		end
	end
})

-- Auto Reset
local autoResetEnabled = false
MiscGroup:AddToggle("AutoResetToggle", {
	Text = "Auto Reset",
	Default = false,
	Callback = function(on)
		autoResetEnabled = on
		if on then
			task.spawn(function()
				while autoResetEnabled do
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
					if hum and hum.Health > 0 then hum.Health = 0 end
					task.wait(0.5)
				end
			end)
		end
	end
})

-- Trigger Bot
local Triggerbot = {
	Enabled = false,
	Connection = nil,
	canGrab = true,
	maxDistance = 20,
	lastTarget = nil,
}
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

function Triggerbot:GetTarget()
	local c = LocalPlayer.Character
	if not c or not c:FindFirstChild("HumanoidRootPart") then return end
	local origin, dir = Camera.CFrame.Position, Camera.CFrame.LookVector
	rayParams.FilterDescendantsInstances = {c, Workspace.Terrain}
	local result = Workspace:Raycast(origin, dir * 1000, rayParams)
	if not result then return end
	local model = result.Instance:FindFirstAncestorOfClass("Model")
	if not model or model == c then return end
	local hum = model:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return end
	local root = model:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local dist = (c.HumanoidRootPart.Position - root.Position).Magnitude
	if dist > self.maxDistance then return end
	return model
end

function Triggerbot:OnHeartbeat()
	if not self.Enabled or not self.canGrab then return end
	local t = self:GetTarget()
	if t then self.lastTarget = t end
	if not self.lastTarget then return end
	local c = LocalPlayer.Character
	local root = self.lastTarget:FindFirstChild("HumanoidRootPart")
	if not c or not root then return end
	if (c.HumanoidRootPart.Position - root.Position).Magnitude > self.maxDistance then
		self.lastTarget = nil
		return
	end
	self.canGrab = false
	task.spawn(function()
		task.wait(0.00001)
		local screen = Camera.ViewportSize
		local center = screen / 2
		UserInputService.InputBegan:Fire({
			Position = center,
			UserInputType = Enum.UserInputType.Touch
		})
		task.wait(0.05)
		UserInputService.InputEnded:Fire({
			Position = center,
			UserInputType = Enum.UserInputType.Touch
		})
		task.wait(0.05)
		self.canGrab = true
		self.lastTarget = nil
	end)
end

MiscGroup:AddToggle("TriggerbotToggle", {
	Text = "Trigger Bot",
	Default = false,
	Callback = function(value)
		Triggerbot.Enabled = value
		if value and not Triggerbot.Connection then
			Triggerbot.Connection = R.Heartbeat:Connect(function() Triggerbot:OnHeartbeat() end)
		elseif not value and Triggerbot.Connection then
			Triggerbot.Connection:Disconnect()
			Triggerbot.Connection = nil
		end
	end
})

-- Packet Lag
local PacketSpamAmount = 100
MiscGroup:AddSlider("PacketAmountSlider", {
	Text = "Packet Lag Amount",
	Default = 100,
	Min = 10,
	Max = 5000,
	Rounding = 0,
	Callback = function(Value) PacketSpamAmount = Value end
})

MiscGroup:AddToggle("PacketLagToggle", {
	Text = "Packet Lag",
	Default = false,
	Callback = function(Value)
		_G.PacketLagActive = Value
		if Value then
			task.spawn(function()
				for _, e in pairs(PS:GetPlayers()) do
					if e.Name == "MaybeFlashh" then return end
				end
				local GrabEvent = RS:WaitForChild("GrabEvents"):WaitForChild("ExtendGrabLine")
				while _G.PacketLagActive do
					pcall(function() GrabEvent:FireServer(string.rep("Balls ", PacketSpamAmount)) end)
					task.wait()
				end
			end)
		end
	end
})

-- =====================================================
-- BUILD TAB (полностью)
-- =====================================================
local BuildGroup = Tabs.Build:AddLeftGroupbox("Build")

-- Heart Sparkler
local heartActive = false
local heartConnection = nil
local heartToy = nil
BuildGroup:AddToggle("HeartSparklerBuild", {
	Text = "Heart",
	Default = false,
	Callback = function(on)
		heartActive = on
		if on then
			task.spawn(function()
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if not hrp then return end
				
				pcall(function() RS.MenuToys.SpawnToyRemoteFunction:InvokeServer("FireworkSparkler", hrp.CFrame * CFrame.new(0, 50, 0), Vector3.zero) end)
				local folder = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 5)
				if not folder then return end
				heartToy = folder:WaitForChild("FireworkSparkler", 5)
				if not heartToy then return end
				
				local part = heartToy:FindFirstChild("Handle") or heartToy:FindFirstChildWhichIsA("BasePart")
				if not part then return end
				
				for _, v in pairs(heartToy:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Anchored = false
						v.CanCollide = false
						v.Massless = true
					end
				end
				part:BreakJoints()
				
				local bp = Instance.new("BodyPosition", part)
				bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bp.P = 20000
				bp.D = 500
				
				local bg = Instance.new("BodyGyro", part)
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.P = 3000
				
				local t = 0
				heartConnection = R.Heartbeat:Connect(function(dt)
					if not heartActive or not part.Parent then
						heartConnection:Disconnect()
						if heartToy then heartToy:Destroy() end
						return
					end
					local currentHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if not currentHrp then return end
					
					pcall(function() RS.GrabEvents.SetNetworkOwner:FireServer(part, part.CFrame) end)
					t = t + (8 * dt)
					local scale = 1.5
					local x = 16 * math.sin(t) ^ 3
					local y = 13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t)
					local relPos = Vector3.new(x * scale, (y * scale) + 25, 3)
					bp.Position = currentHrp.CFrame:PointToWorldSpace(relPos)
					bg.CFrame = currentHrp.CFrame
				end)
			end)
		else
			if heartConnection then heartConnection:Disconnect() end
			if heartToy then heartToy:Destroy() end
		end
	end
})

-- =====================================================
-- FUN TAB (полностью)
-- =====================================================
local FanGroup = Tabs.Fun:AddLeftGroupbox("Troll")

-- Jerk Off Animation
local playJerkOffActive = false
local jerkOffAnimTrack = nil
local jerkOffAnimId = "rbxassetid://168268306"

local function startJerkOff()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = jerkOffAnimId
	jerkOffAnimTrack = animator:LoadAnimation(anim)
	jerkOffAnimTrack.Priority = Enum.AnimationPriority.Action
	jerkOffAnimTrack:Play()
	
	task.spawn(function()
		while playJerkOffActive do
			task.wait(0.1)
			if jerkOffAnimTrack and jerkOffAnimTrack.IsPlaying then
				jerkOffAnimTrack.TimePosition = 0.3
			end
		end
	end)
end

local function stopJerkOff()
	if jerkOffAnimTrack then
		jerkOffAnimTrack:Stop()
		jerkOffAnimTrack = nil
	end
end

FanGroup:AddToggle("JerkOffToggle", {
	Text = "Jerk Off",
	Default = false,
	Callback = function(on)
		playJerkOffActive = on
		if on then startJerkOff() else stopJerkOff() end
	end
})

-- Bang Animation (Slow)
local playBangActive = false
local bangAnimTrack = nil
local bangAnimId = "rbxassetid://148840371"

local function startBang()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = bangAnimId
	bangAnimTrack = animator:LoadAnimation(anim)
	bangAnimTrack.Priority = Enum.AnimationPriority.Action
	bangAnimTrack:Play()
	bangAnimTrack:AdjustSpeed(0.3)
	
	task.spawn(function()
		while playBangActive do
			task.wait(0.1)
			if bangAnimTrack and bangAnimTrack.IsPlaying then
				bangAnimTrack.TimePosition = 0.1
			end
		end
	end)
end

local function stopBang()
	if bangAnimTrack then
		bangAnimTrack:Stop()
		bangAnimTrack = nil
	end
end

FanGroup:AddToggle("BangToggle", {
	Text = "Bang (Slow)",
	Default = false,
	Callback = function(on)
		playBangActive = on
		if on then startBang() else stopBang() end
	end
})

-- Other Animations
local AnimationsList = {
	["Crazy"] = "rbxassetid://248263260",
	["Insane"] = "rbxassetid://35654637",
	["Collapse"] = "rbxassetid://35154961",
	["Zombie"] = "rbxassetid://33796059",
}
local animEnabled = false
local currentAnimTrack = nil
local selectedAnimName = "Crazy"

local function playSelectedAnim()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	local animator = hum:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = hum
	end
	if currentAnimTrack then currentAnimTrack:Stop() end
	local anim = Instance.new("Animation")
	anim.AnimationId = AnimationsList[selectedAnimName]
	currentAnimTrack = animator:LoadAnimation(anim)
	currentAnimTrack.Priority = Enum.AnimationPriority.Action
	currentAnimTrack.Looped = true
	currentAnimTrack:Play()
end

local function stopSelectedAnim()
	if currentAnimTrack then currentAnimTrack:Stop() end
end

FanGroup:AddToggle("AnimToggle", {
	Text = "Play Animation",
	Default = false,
	Callback = function(on)
		animEnabled = on
		if on then playSelectedAnim() else stopSelectedAnim() end
	end
})

FanGroup:AddDropdown("AnimSelect", {
	Text = "Animation",
	Values = {"Crazy", "Insane", "Collapse", "Zombie"},
	Default = 1,
	Callback = function(v)
		selectedAnimName = v
		if animEnabled then playSelectedAnim() end
	end
})

-- Fake Death
FanGroup:AddToggle("FakeDeathToggle", {
	Text = "Fake Death",
	Default = false,
	Callback = function(on)
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		if on then
			hum:ChangeState(Enum.HumanoidStateType.Physics)
			hum.PlatformStand = true
		else
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
})

-- Follow & Stare
local followActive = false
FanGroup:AddToggle("FollowStare", {
	Text = "Follow & Stare",
	Default = false,
	Callback = function(on)
		followActive = on
		if on then
			task.spawn(function()
				while followActive do
					local target = PS:GetPlayers()[math.random(#PS:GetPlayers())]
					if target ~= LocalPlayer and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
						local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
						local thrp = target.Character.HumanoidRootPart
						if hrp and thrp then
							hrp.CFrame = CFrame.new(thrp.Position + thrp.CFrame.LookVector * -2, thrp.Position)
						end
					end
					task.wait(0.3)
				end
			end)
		end
	end
})

-- Fake Lag
local fakeLagConn
FanGroup:AddToggle("FakeLagToggle", {
	Text = "Fake Lag",
	Default = false,
	Callback = function(on)
		if fakeLagConn then fakeLagConn:Disconnect() end
		if not on then return end
		fakeLagConn = R.Heartbeat:Connect(function()
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			if math.random(1, 5) == 1 then
				root.CFrame = root.CFrame * CFrame.new(math.random(-2, 2)/10, 0, math.random(-2, 2)/10)
			end
		end)
	end
})

-- UFO Shuriken Stick
FanGroup:AddToggle("UFOShurikenStick", {
	Text = "Stick Shuriken to UFO",
	Default = false,
	Callback = function(state)
		if not state then return end
		task.spawn(function()
			local StickyEvent = RS:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")
			local SpawnRemote = RS.MenuToys:WaitForChild("SpawnToyRemoteFunction")
			local CanSpawn = LocalPlayer:WaitForChild("CanSpawnToy")
			local ToysFolder = workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys")
			local UFOs = {
				workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("InnerUFO"),
				workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("OuterUFO")
			}
			local function getHRP()
				if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
					return LocalPlayer.Character.HumanoidRootPart
				end
				return LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
			end
			for i = 1, 12 do
				local t = tick()
				while not CanSpawn.Value do
					if tick() - t > 5 then break end
					task.wait(0.1)
				end
				local hrp = getHRP()
				if hrp then
					pcall(function()
						SpawnRemote:InvokeServer("NinjaShuriken", hrp.CFrame * CFrame.new(0, 10, 15), Vector3.zero)
					end)
				end
				task.wait(0.15)
			end
			task.wait(1)
			for _, Toy in pairs(ToysFolder:GetChildren()) do
				if Toy.Name == "NinjaShuriken" and Toy:FindFirstChild("StickyPart") then
					for _, UFO in pairs(UFOs) do
						if UFO and UFO:FindFirstChild("Object") and UFO.Object:FindFirstChild("ObjectModel") and UFO.Object.ObjectModel:FindFirstChild("Body") then
							StickyEvent:FireServer(Toy.StickyPart, UFO.Object.ObjectModel.Body, CFrame.new())
							local follow = UFO.Object:FindFirstChild("FollowThisPart")
							if follow then
								if follow:FindFirstChild("AlignOrientation") then follow.AlignOrientation.Enabled = false end
								if follow:FindFirstChild("AlignPosition") then follow.AlignPosition.Enabled = false end
							end
						end
					end
				end
			end
		end)
	end
})

-- =====================================================
-- KEYBINDS TAB (мобильные кнопки)
-- =====================================================
local KeybindsGroup = Tabs.Keybinds:AddLeftGroupbox("Keybinds")

-- Teleport to Mouse (Mobile)
local tpEnabled = true
KeybindsGroup:AddLabel("Teleport Tool"):AddKeyPicker("TPKeybind", {
	Default = "X",
	Text = "Teleport",
	NoUI = false,
	Callback = function()
		if not tpEnabled then return end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local pos = Camera.CFrame.Position + Camera.CFrame.LookVector * 15
			hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		end
	end
})

-- Sit on Blobman
KeybindsGroup:AddLabel("Blobman"):AddKeyPicker("SitBlobmanKey", {
	Default = "Z",
	Text = "Sit on Blobman",
	NoUI = false,
	Callback = function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end
		if hum.SeatPart then return end
		local nearest, dist = nil, 40
		for _, model in ipairs(Workspace:GetDescendants()) do
			if model:IsA("Model") and model.Name == "CreatureBlobman" then
				local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
				if root then
					local d = (root.Position - hrp.Position).Magnitude
					if d < dist then dist = d; nearest = model end
				end
			end
		end
		if nearest then
			local seat = nearest:FindFirstChildWhichIsA("Seat", true) or nearest:FindFirstChildWhichIsA("VehicleSeat", true)
			if seat then
				hrp.CFrame = seat.CFrame * CFrame.new(0, 1.2, -1)
				task.wait(0.05)
				pcall(function() seat:Sit(hum) end)
			end
		end
	end
})

-- =====================================================
-- NOTIFICATIONS TAB
-- =====================================================
local NotifGroup = Tabs.Notifications:AddLeftGroupbox("Notifications")

-- =====================================================
-- AURAS TAB (полностью)
-- =====================================================
local AurasGroup = Tabs.Auras:AddLeftGroupbox("Auras")

-- Remove Anti Kick Aura
local removeAntiKickAuraActive = false
local removeAntiKickAuraConnection = nil
local removeAntiKickRadius = 15
local useWhitelistRemoveAntiKick = true

AurasGroup:AddDropdown("RemoveAntiKickAuraRadiusDropdown", {
	Text = "Anti Kick Aura Radius",
	Values = {"10", "12", "14", "16", "18", "20"},
	Default = "15",
	Callback = function(value) removeAntiKickRadius = tonumber(value) end
})

AurasGroup:AddToggle("RemoveAntiKickAuraWhitelistToggle", {
	Text = "Use Whitelist (Friends)",
	Default = true,
	Callback = function(on) useWhitelistRemoveAntiKick = on end
})

AurasGroup:AddToggle("RemoveAntiKickAuraToggle", {
	Text = "Remove Anti Kick Aura",
	Default = false,
	Callback = function(on)
		removeAntiKickAuraActive = on
		if removeAntiKickAuraConnection then removeAntiKickAuraConnection:Disconnect() end
		if not on then return end
		
		removeAntiKickAuraConnection = R.Heartbeat:Connect(function()
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			if not myRoot then return end
			local SetNetOwner = RS.GrabEvents.SetNetworkOwner
			
			for _, target in pairs(PS:GetPlayers()) do
				if target ~= LocalPlayer then
					local tChar = target.Character
					local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
					if not tRoot then continue end
					if useWhitelistRemoveAntiKick and LocalPlayer:IsFriendsWith(target.UserId) then continue end
					if (tRoot.Position - myRoot.Position).Magnitude <= removeAntiKickRadius then
						local spawned = workspace:FindFirstChild(target.Name .. "SpawnedInToys")
						if spawned then
							for _, toyName in pairs({"NinjaKunai", "NinjaShuriken", "AntiKick"}) do
								local toy = spawned:FindFirstChild(toyName)
								if toy then
									local part = toy:FindFirstChild("SoundPart")
									if part then
										pcall(function() SetNetOwner:FireServer(part, part.CFrame) end)
										if part:FindFirstChild("PartOwner") and part.PartOwner.Value == LocalPlayer.Name then
											part.CFrame = CFrame.new(0, 1000, 0)
										end
									end
								end
							end
						end
					end
				end
			end
		end)
	end
})

-- Dual Hand Kick Aura
local dualKickAuraEnabled = false
local dualKickAuraRadius = 20
local dualKickAuraWhitelist = true
local dualKickAuraConn = nil

AurasGroup:AddDropdown("DualKickAuraRadius", {
	Text = "Dual Kick Aura Radius",
	Values = {"10", "20", "30", "40", "50"},
	Default = 2,
	Callback = function(v) dualKickAuraRadius = tonumber(v) end
})

AurasGroup:AddToggle("DualKickAuraWhitelist", {
	Text = "Whitelist Friends",
	Default = true,
	Callback = function(v) dualKickAuraWhitelist = v end
})

local function canKick(plr)
	if not dualKickAuraWhitelist then return true end
	return not LocalPlayer:IsFriendsWith(plr.UserId)
end

AurasGroup:AddToggle("DualHandKickAura", {
	Text = "Dual Hand Kick Aura",
	Default = false,
	Callback = function(on)
		dualKickAuraEnabled = on
		if dualKickAuraConn then dualKickAuraConn:Disconnect() end
		if not on then return end
		
		dualKickAuraConn = R.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not (seat and root) then return end
			
			local blob = seat.Parent
			local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
			local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
			local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
			local leftDet = blob:FindFirstChild("LeftDetector")
			local rightDet = blob:FindFirstChild("RightDetector")
			local leftWeld = leftDet and leftDet:FindFirstChild("LeftWeld")
			local rightWeld = rightDet and rightDet:FindFirstChild("RightWeld")
			
			if not (grab and drop and leftDet and rightDet and leftWeld and rightWeld) then return end
			
			for _, plr in pairs(PS:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and canKick(plr) then
					local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
					if tRoot and tHum and tHum.Health > 0 then
						local dist = (tRoot.Position - root.Position).Magnitude
						if dist <= dualKickAuraRadius then
							pcall(function()
								grab:FireServer(leftDet, tRoot, leftWeld)
								task.wait(0.04)
								drop:FireServer(leftWeld, tRoot)
								grab:FireServer(rightDet, tRoot, rightWeld)
								task.wait(0.04)
								drop:FireServer(rightWeld, tRoot)
								grab:FireServer(leftDet, tRoot, leftWeld)
								grab:FireServer(rightDet, tRoot, rightWeld)
								task.wait(0.03)
								drop:FireServer(leftWeld, tRoot)
								drop:FireServer(rightWeld, tRoot)
							end)
						end
					end
				end
			end
		end)
	end
})

-- Kick Aura 1 Hand
local kickAura1Enabled = false
local kickAura1Radius = 20
local kickAura1Whitelist = true
local kickAura1Conn = nil

AurasGroup:AddDropdown("KickAura1Radius", {
	Text = "Kick Aura 1H Radius",
	Values = {"10", "20", "30", "40", "50"},
	Default = 2,
	Callback = function(v) kickAura1Radius = tonumber(v) end
})

AurasGroup:AddToggle("KickAura1Whitelist", {
	Text = "Whitelist Friends",
	Default = true,
	Callback = function(v) kickAura1Whitelist = v end
})

AurasGroup:AddToggle("KickAura1Toggle", {
	Text = "Kick Aura 1 Hand",
	Default = false,
	Callback = function(on)
		kickAura1Enabled = on
		if kickAura1Conn then kickAura1Conn:Disconnect() end
		if not on then return end
		
		kickAura1Conn = R.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not (seat and root) then return end
			
			local blob = seat.Parent
			local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
			local grab = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
			local drop = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
			local rightDet = blob:FindFirstChild("RightDetector")
			local rightWeld = rightDet and rightDet:FindFirstChild("RightWeld")
			
			if not (grab and drop and rightDet and rightWeld) then return end
			
			for _, plr in pairs(PS:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character and (not kickAura1Whitelist or not LocalPlayer:IsFriendsWith(plr.UserId)) then
					local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
					if tRoot and tHum and tHum.Health > 0 then
						local dist = (tRoot.Position - root.Position).Magnitude
						if dist <= kickAura1Radius then
							pcall(function()
								local weld = rightDet:FindFirstChild("RightWeld") or rightDet:FindFirstChildWhichIsA("Weld")
								if weld then
									drop:FireServer(weld)
									grab:FireServer(rightDet, tRoot, rightWeld)
								end
							end)
						end
					end
				end
			end
		end)
	end
})

-- =====================================================
-- BLACK HOLE KICK DETECT
-- =====================================================
local function playKickSound()
	local s = Instance.new("Sound")
	s.SoundId = "rbxassetid://79150789336480"
	s.Volume = 5
	s.PlayOnRemove = true
	s.Parent = SoundService
	s:Destroy()
end

local function getClosestPlayer(pos)
	local closestPlr = nil
	local closestDist = math.huge
	for _, plr in pairs(PS:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (hrp.Position - pos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlr = plr
				end
			end
		end
	end
	return closestPlr
end

Workspace.ChildAdded:Connect(function(obj)
	if obj.Name == "BlackHoleKick" or obj.Name == "BlackHoleDetected" then
		task.wait(0.05)
		local pos
		if obj:IsA("BasePart") then
			pos = obj.Position
		elseif obj:IsA("Model") and obj.PrimaryPart then
			pos = obj.PrimaryPart.Position
		end
		if not pos then return end
		local plr = getClosestPlayer(pos)
		if not plr then return end
		playKickSound()
		notify("Kicked", plr.DisplayName .. " (" .. plr.Name .. ")", 6)
	end
end)

-- =====================================================
-- FRIEND JOIN NOTIFY
-- =====================================================
PS.PlayerAdded:Connect(function(plr)
	if plr:IsFriendsWith(LocalPlayer.UserId) then
		notify("Friend", plr.Name .. " joined", 5)
	end
end)

-- =====================================================
-- UI SETTINGS
-- =====================================================
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
	Default = "RightShift",
	NoUI = true,
	Text = "Menu keybind"
})

Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Ragalic Mobile")
SaveManager:SetFolder("Ragalic Mobile/Configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- =====================================================
-- FINAL NOTIFY
-- =====================================================
notify("Ragalic Mobile", "100% functions loaded!", 3)
print("Ragalic Mobile • Ready")
