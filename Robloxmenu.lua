-- Skibidi Menu by Cablober (Final Version)
-- Features:
-- ✅ Draggable purple UI
-- ✅ Snap Aimbot with part selection
-- ✅ Smooth Silent Aim
-- ✅ ESP with Name, Distance, Highlight toggles
-- ✅ Sidebar with Player tab at top
-- ✅ Shift + ` to toggle / X button to close

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local menuGui, contentFrame
local menuOpen = false
local espToggles = { Name = false, Distance = false, Highlight = false }
local hitboxOn, aimbotOn, silentAimOn = false, false, false
local aimTargetPart = "Head"
local espFolder = Instance.new("Folder", workspace)
espFolder.Name = "ESP_Objects"

-- Drag function
local function makeDraggable(frame)
	local dragToggle, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragToggle then update(input) end
	end)
end

-- ESP system
local function clearESP()
	espFolder:ClearAllChildren()
	for _, plr in Players:GetPlayers() do
		if plr.Character and plr.Character:FindFirstChild("Highlight") then
			plr.Character.Highlight:Destroy()
		end
	end
end

local function updateESP()
	clearESP()
	for _, target in Players:GetPlayers() do
		if target ~= player and target.Character and target.Character:FindFirstChild("Head") then
			local head = target.Character.Head
			if espToggles.Name or espToggles.Distance then
				local bb = Instance.new("BillboardGui")
				bb.Name = target.Name
				bb.Adornee = head
				bb.Size = UDim2.new(0, 200, 0, 50)
				bb.StudsOffset = Vector3.new(0, 2.5, 0)
				bb.AlwaysOnTop = true
				bb.Parent = espFolder

				local label = Instance.new("TextLabel", bb)
				label.Size = UDim2.new(1, 0, 1, 0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.new(1, 1, 1)
				label.Font = Enum.Font.SourceSansBold
				label.TextScaled = true

				RunService.RenderStepped:Connect(function()
					if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						local dist = math.floor((head.Position - player.Character.HumanoidRootPart.Position).Magnitude)
						label.Text = (espToggles.Name and target.Name or "") .. (espToggles.Distance and (" [" .. dist .. "m]") or "")
					end
				end)
			end
			if espToggles.Highlight and not target.Character:FindFirstChild("Highlight") then
				local highlight = Instance.new("Highlight")
				highlight.FillTransparency = 1
				highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
				highlight.OutlineTransparency = 0
				highlight.Parent = target.Character
			end
		end
	end
end

-- Aimbot Targeting
local function getClosestTarget()
	local closest, dist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild(aimTargetPart) then
			local part = plr.Character[aimTargetPart]
			local screenPos, visible = workspace.CurrentCamera:WorldToScreenPoint(part.Position)
			if visible then
				local mag = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
				if mag < dist then
					dist, closest = mag, part
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = getClosestTarget()
		if target then
			if aimbotOn then
				workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
			elseif silentAimOn then
				local dir = (target.Position - workspace.CurrentCamera.CFrame.Position).Unit
				workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + dir), 0.1)
			end
		end
	end
end)

-- UI builder helper
local function createCheckbox(text, state, callback, parent)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 200, 0, 40)
	btn.Text = (state and "🟪" or "⬛") .. " " .. text
	btn.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 18
	btn.Parent = parent
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = (state and "🟪" or "⬛") .. " " .. text
		callback(state)
	end)
end

-- Main GUI Creation
local function createMenu()
	local gui = Instance.new("ScreenGui")
	gui.Name = "SkibidiMenu"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 450, 0, 350)
	main.Position = UDim2.new(0.5, -225, 0.5, -175)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	main.BorderSizePixel = 0
	main.Name = "Main"
	main.Parent = gui
	makeDraggable(main)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(90, 0, 160)
	title.Text = "Skibidi Menu by Cablober"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 20
	title.Parent = main

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -30, 0, 0)
	closeBtn.Text = "X"
	closeBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextSize = 18
	closeBtn.Parent = main
	closeBtn.MouseButton1Click:Connect(function()
		gui.Enabled = false
		menuOpen = false
	end)

	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 100, 1, -30)
	sidebar.Position = UDim2.new(0, 0, 0, 30)
	sidebar.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
	sidebar.Parent = main

	contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -100, 1, -30)
	contentFrame.Position = UDim2.new(0, 100, 0, 30)
	contentFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
	contentFrame.Parent = main

	local sections = {
		Player = function()
			contentFrame:ClearAllChildren()

			createCheckbox("Snap Aimbot", aimbotOn, function(val) aimbotOn = val end, contentFrame)
			createCheckbox("Silent Aim", silentAimOn, function(val) silentAimOn = val end, contentFrame)

			local partLabel = Instance.new("TextLabel")
			partLabel.Size = UDim2.new(0, 200, 0, 30)
			partLabel.Position = UDim2.new(0, 20, 0, 90)
			partLabel.Text = "Target Part:"
			partLabel.BackgroundTransparency = 1
			partLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			partLabel.Font = Enum.Font.SourceSans
			partLabel.TextSize = 16
			partLabel.Parent = contentFrame

			local dropdown = Instance.new("TextButton")
			dropdown.Size = UDim2.new(0, 200, 0, 30)
			dropdown.Position = UDim2.new(0, 20, 0, 120)
			dropdown.Text = aimTargetPart
			dropdown.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
			dropdown.TextColor3 = Color3.new(1, 1, 1)
			dropdown.Font = Enum.Font.SourceSans
			dropdown.TextSize = 16
			dropdown.Parent = contentFrame
			dropdown.MouseButton1Click:Connect(function()
				if aimTargetPart == "Head" then aimTargetPart = "Torso"
				elseif aimTargetPart == "Torso" then aimTargetPart = "LeftLeg"
				else aimTargetPart = "Head" end
				dropdown.Text = aimTargetPart
			end)
		end,
		Visuals = function()
			contentFrame:ClearAllChildren()
			createCheckbox("Name Tag", espToggles.Name, function(val) espToggles.Name = val updateESP() end, contentFrame)
			createCheckbox("Distance", espToggles.Distance, function(val) espToggles.Distance = val updateESP() end, contentFrame)
			createCheckbox("Highlight", espToggles.Highlight, function(val) espToggles.Highlight = val updateESP() end, contentFrame)
		end
	}

	local i = 0
	for name, fn in pairs(sections) do
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, 0, 0, 30)
		tabBtn.Position = UDim2.new(0, 0, 0, i * 35)
		tabBtn.Text = name
		tabBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)
		tabBtn.Font = Enum.Font.SourceSans
		tabBtn.TextSize = 16
		tabBtn.Parent = sidebar
		tabBtn.MouseButton1Click:Connect(fn)
		i += 1
	end

	sections.Player() -- default open Player tab
	return gui
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Backquote and UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
		if not menuGui then
			menuGui = createMenu()
			menuOpen = true
		else
			menuOpen = not menuOpen
			menuGui.Enabled = menuOpen
		end
	end
end)
