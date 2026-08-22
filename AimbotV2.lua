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
local FOV_SIZE = 150
local AIM_SPEED = 0.15

-- Current locked player
local lockedTarget = nil

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "Aimbot"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 220)
frame.Position = UDim2.new(0.5, -155, 0.5, -110)
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
-- MINIMIZE BUTTON
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
-- AIMBOT TOGGLE
--------------------------------------------------

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(1, -30, 0, 40)
toggle.Position = UDim2.fromOffset(15, 45)
toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.TextSize = 15
toggle.Font = Enum.Font.GothamBold
toggle.Text = "Aimbot: OFF"
toggle.Parent = frame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggle

local function updateToggle()
	if AIMBOT_ENABLED then
		toggle.Text = "Aimbot: ON"
	else
		toggle.Text = "Aimbot: OFF"
	end
end

toggle.Activated:Connect(function()

	AIMBOT_ENABLED = not AIMBOT_ENABLED

	-- Clear the old target when turning off
	if not AIMBOT_ENABLED then
		lockedTarget = nil
	end

	updateToggle()
end)

--------------------------------------------------
-- SLIDERS
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

createSlider(
	95,
	"FOV Size",
	50,
	500,
	FOV_SIZE,
	function(value)
		FOV_SIZE = value
	end
)

createSlider(
	150,
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

		toggle.Visible = false

		for _, object in ipairs(sliderObjects) do
			object.Visible = false
		end

		frame.Size = UDim2.fromOffset(310, 45)
		minimize.Text = "+"

	else

		toggle.Visible = true

		for _, object in ipairs(sliderObjects) do
			object.Visible = true
		end

		frame.Size = UDim2.fromOffset(310, 220)
		minimize.Text = "−"
	end
end)

--------------------------------------------------
-- CHECK WHETHER TARGET IS VALID
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

	return true
end

--------------------------------------------------
-- FIND INITIAL TARGET
--------------------------------------------------

local function findClosestPlayer()

	local closestPlayer = nil
	local closestDistance = FOV_SIZE

	local center = Vector2.new(
		Camera.ViewportSize.X / 2,
		Camera.ViewportSize.Y / 2
	)

	for _, player in ipairs(Players:GetPlayers()) do

		if player ~= LocalPlayer then

			local character = player.Character

			local humanoid =
				character and
				character:FindFirstChildOfClass("Humanoid")

			local root =
				character and
				character:FindFirstChild("HumanoidRootPart")

			if humanoid
				and humanoid.Health > 0
				and root then

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
	end

	return closestPlayer
end

--------------------------------------------------
-- PERSISTENT LOCK
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not AIMBOT_ENABLED then
		lockedTarget = nil
		return
	end

	-- Only search for a new target if there isn't
	-- currently a valid locked target.
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
	-- Keep aiming at the SAME target.
	-- The target does NOT need to remain inside FOV.
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

--------------------------------------------------
-- CLEAN UP WHEN A PLAYER LEAVES
--------------------------------------------------

Players.PlayerRemoving:Connect(function(player)

	if player == lockedTarget then
		lockedTarget = nil
	end
end) 
