-- Private Roblox Studio aim-testing script
-- LocalScript -> StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local AIMBOT_ENABLED = false
local HIGHLIGHTS_ENABLED = false
local WALL_CHECK_ENABLED = false

local FOV_SIZE = 150
local AIM_SPEED = 0.15

local lockedTarget = nil

local highlights = {}

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "MobileAimTest"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 310)
frame.Position = UDim2.new(0.5, -155, 0.5, -155)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

--------------------------------------------------
-- TITLE
--------------------------------------------------

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 40)
title.Position = UDim2.fromOffset(5, 0)
title.BackgroundTransparency = 1
title.Text = "Mobile Aim Testing"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Active = true
title.Parent = frame

--------------------------------------------------
-- DRAGGING
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)

	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.fromOffset(35, 30)
minimize.Position = UDim2.new(1, -40, 0, 5)
minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
minimize.TextColor3 = Color3.new(1, 1, 1)
minimize.Text = "−"
minimize.TextSize = 22
minimize.Font = Enum.Font.GothamBold
minimize.Parent = frame

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 7)
minimizeCorner.Parent = minimize

local minimized = false

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function createButton(text, y)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -30, 0, 38)
	button.Position = UDim2.fromOffset(15, y)

	button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)

	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold

	button.Text = text

	button.Parent = frame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button

	return button
end

--------------------------------------------------
-- AIMBOT BUTTON
--------------------------------------------------

local aimButton = createButton(
	"Aimbot: OFF",
	45
)

aimButton.Activated:Connect(function()

	AIMBOT_ENABLED = not AIMBOT_ENABLED

	if not AIMBOT_ENABLED then
		lockedTarget = nil
	end

	if AIMBOT_ENABLED then
		aimButton.Text = "Aimbot: ON"
	else
		aimButton.Text = "Aimbot: OFF"
	end
end)

--------------------------------------------------
-- HIGHLIGHT BUTTON
--------------------------------------------------

local highlightButton = createButton(
	"Player Highlights: OFF",
	90
)

--------------------------------------------------
-- CREATE HIGHLIGHT
--------------------------------------------------

local function addHighlight(player)

	if player == LocalPlayer then
		return
	end

	if highlights[player] then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	local highlight = Instance.new("Highlight")

	highlight.Name = "AimTestHighlight"

	-- Red player highlight
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)

	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0

	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

	highlight.Adornee = character
	highlight.Parent = gui

	highlights[player] = highlight
end

--------------------------------------------------
-- REMOVE HIGHLIGHT
--------------------------------------------------

local function removeHighlight(player)

	local highlight = highlights[player]

	if highlight then
		highlight:Destroy()
		highlights[player] = nil
	end
end

--------------------------------------------------
-- UPDATE ALL HIGHLIGHTS
--------------------------------------------------

local function updateHighlights()

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			if HIGHLIGHTS_ENABLED then
				addHighlight(player)
			else
				removeHighlight(player)
			end
		end
	end
end

--------------------------------------------------
-- HIGHLIGHT TOGGLE
--------------------------------------------------

highlightButton.Activated:Connect(function()

	HIGHLIGHTS_ENABLED = not HIGHLIGHTS_ENABLED

	updateHighlights()

	if HIGHLIGHTS_ENABLED then
		highlightButton.Text = "Player Highlights: ON"
	else
		highlightButton.Text = "Player Highlights: OFF"
	end
end)

--------------------------------------------------
-- HANDLE CHARACTER RESPAWNS
--------------------------------------------------

local function setupPlayer(player)

	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(function(character)

		if HIGHLIGHTS_ENABLED then

			task.wait(0.2)

			removeHighlight(player)
			addHighlight(player)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(function(player)

	setupPlayer(player)

	if HIGHLIGHTS_ENABLED then

		task.wait(0.2)

		addHighlight(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)

	removeHighlight(player)

	if player == lockedTarget then
		lockedTarget = nil
	end
end)

--------------------------------------------------
-- WALL CHECK BUTTON
--------------------------------------------------

local wallButton = createButton(
	"Wall Check: OFF",
	135
)

wallButton.Activated:Connect(function()

	WALL_CHECK_ENABLED = not WALL_CHECK_ENABLED

	-- Re-evaluate the current target when enabled.
	if WALL_CHECK_ENABLED then
		lockedTarget = nil
	end

	if WALL_CHECK_ENABLED then
		wallButton.Text = "Wall Check: ON"
	else
		wallButton.Text = "Wall Check: OFF"
	end
end)

--------------------------------------------------
-- SLIDER SYSTEM
--------------------------------------------------

local sliderObjects = {}

local function createSlider(
	y,
	text,
	minValue,
	maxValue,
	defaultValue,
	callback
)

	local label = Instance.new("TextLabel")

	label.Size = UDim2.new(1, -30, 0, 22)
	label.Position = UDim2.fromOffset(15, y)

	label.BackgroundTransparency = 1

	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextSize = 14
	label.Font = Enum.Font.Gotham

	label.TextXAlignment = Enum.TextXAlignment.Left

	label.Parent = frame

	local bar = Instance.new("Frame")

	bar.Size = UDim2.new(1, -30, 0, 12)
	bar.Position = UDim2.fromOffset(15, y + 27)

	bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

	bar.BorderSizePixel = 0
	bar.Active = true

	bar.Parent = frame

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar

	-- Large touch area for mobile.
	local touchArea = Instance.new("TextButton")

	touchArea.Size = UDim2.new(1, 30, 1, 30)
	touchArea.Position = UDim2.fromOffset(-15, -15)

	touchArea.BackgroundTransparency = 1
	touchArea.Text = ""

	touchArea.AutoButtonColor = false

	touchArea.Parent = bar

	local knob = Instance.new("Frame")

	knob.Size = UDim2.fromOffset(20, 20)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)

	knob.BackgroundColor3 = Color3.new(1, 1, 1)

	knob.BorderSizePixel = 0

	knob.Parent = bar

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(1, 0)
	knobCorner.Parent = knob

	local sliding = false

	local function setValue(x)

		local relative = math.clamp(
			(x - bar.AbsolutePosition.X) /
			bar.AbsoluteSize.X,
			0,
			1
		)

		local value =
			minValue +
			(maxValue - minValue) * relative

		local normalized =
			(value - minValue) /
			(maxValue - minValue)

		knob.Position = UDim2.new(
			normalized,
			0,
			0.5,
			0
		)

		label.Text = string.format(
			"%s: %.2f",
			text,
			value
		)

		callback(value)
	end

	touchArea.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then

			sliding = true

			setValue(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)

		if not sliding then
			return
		end

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseMovement then

			setValue(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1 then

			sliding = false
		end
	end)

	local initial =
		(defaultValue - minValue) /
		(maxValue - minValue)

	knob.Position = UDim2.new(
		initial,
		0,
		0.5,
		0
	)

	label.Text = string.format(
		"%s: %.2f",
		text,
		defaultValue
	)

	table.insert(sliderObjects, label)
	table.insert(sliderObjects, bar)
end

--------------------------------------------------
-- FOV SLIDER
--------------------------------------------------

createSlider(
	180,
	"FOV Size",
	50,
	500,
	FOV_SIZE,
	function(value)

		FOV_SIZE = value
	end
)

--------------------------------------------------
-- CAMERA SPEED SLIDER
--------------------------------------------------

createSlider(
	235,
	"Camera Smoothness",
	0.01,
	1,
	AIM_SPEED,
	function(value)

		AIM_SPEED = value
	end
)

--------------------------------------------------
-- MINIMIZE / RESTORE
--------------------------------------------------

minimize.Activated:Connect(function()

	minimized = not minimized

	if minimized then

		aimButton.Visible = false
		highlightButton.Visible = false
		wallButton.Visible = false

		for _, object in ipairs(sliderObjects) do
			object.Visible = false
		end

		frame.Size = UDim2.fromOffset(310, 45)

		minimize.Text = "+"

	else

		aimButton.Visible = true
		highlightButton.Visible = true
		wallButton.Visible = true

		for _, object in ipairs(sliderObjects) do
			object.Visible = true
		end

		frame.Size = UDim2.fromOffset(310, 310)

		minimize.Text = "−"
	end
end)

--------------------------------------------------
-- WALL CHECK
--------------------------------------------------

local function hasLineOfSight(targetCharacter)

	if not targetCharacter then
		return false
	end

	local root =
		targetCharacter:FindFirstChild("HumanoidRootPart")

	if not root then
		return false
	end

	local origin = Camera.CFrame.Position

	local direction = root.Position - origin

	local raycastParams = RaycastParams.new()

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	raycastParams.FilterDescendantsInstances = {
		LocalPlayer.Character,
		targetCharacter
	}

	raycastParams.IgnoreWater = true

	local result = workspace:Raycast(
		origin,
		direction,
		raycastParams
	)

	-- Nothing blocked the ray.
	return result == nil
end

--------------------------------------------------
-- TARGET VALIDATION
--------------------------------------------------

local function isValidTarget(player)

	if not player then
		return false
	end

	if player == LocalPlayer then
		return false
	end

	local character = player.Character

	if not character then
		return false
	end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	local root =
		character:FindFirstChild("HumanoidRootPart")

	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	if not root then
		return false
	end

	-- Wall check is applied only when enabled.
	if WALL_CHECK_ENABLED then

		if not hasLineOfSight(character) then
			return false
		end
	end

	return true
end

--------------------------------------------------
-- FIND CLOSEST VISIBLE PLAYER
--------------------------------------------------

local function findClosestPlayer()

	local closestPlayer = nil
	local closestDistance = FOV_SIZE

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do

		if isValidTarget(player) then

			local character = player.Character
			local root =
				character:FindFirstChild("HumanoidRootPart")

			local position, visible =
				Camera:WorldToViewportPoint(
					root.Position
				)

			if visible and position.Z > 0 then

				local distance = (
					Vector2.new(
						position.X,
						position.Y
					) - center
				).Magnitude

				if distance < closestDistance then

					closestDistance = distance
					closestPlayer = player

				end
			end
		end
	end

	return closestPlayer
end

--------------------------------------------------
-- AIMBOT
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not AIMBOT_ENABLED then

		lockedTarget = nil

		return
	end

	--------------------------------------------------
	-- Keep existing target
	--------------------------------------------------

	if not isValidTarget(lockedTarget) then

		lockedTarget = findClosestPlayer()
	end

	if not lockedTarget then
		return
	end

	local character = lockedTarget.Character

	local root =
		character and
		character:FindFirstChild("HumanoidRootPart")

	if not root then

		lockedTarget = nil

		return
	end

	--------------------------------------------------
	-- Aim at locked target
	--------------------------------------------------

	local targetCFrame = CFrame.lookAt(
		Camera.CFrame.Position,
		root.Position
	)

	Camera.CFrame = Camera.CFrame:Lerp(
		targetCFrame,
		AIM_SPEED
	)
end)
