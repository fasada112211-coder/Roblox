-- LocalScript (StarterPlayer -> StarterPlayerScripts) - PART 1 OF 3
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

--// GUI Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AntiFreakHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

--// Helper: Mobile & PC Smooth Draggable
local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--// Floating Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "OpenButton"
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -26)
toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Text = "⚡"
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = screenGui
makeDraggable(toggleBtn)

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(80, 90, 130)
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

--// Main Frame
local mainFrame = Instance.new("CanvasGroup")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 540, 0, 380)
mainFrame.Position = UDim2.new(0.5, -270, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
mainFrame.BorderSizePixel = 0
mainFrame.GroupTransparency = 1
mainFrame.Visible = false
mainFrame.Parent = screenGui
makeDraggable(mainFrame)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(42, 46, 62)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

--// Top Bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 14)
topBarCorner.Parent = topBar

local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 12)
topBarFix.Position = UDim2.new(0, 0, 1, -12)
topBarFix.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
topBarFix.BorderSizePixel = 0
topBarFix.Parent = topBar

local backBtn = Instance.new("TextButton")
backBtn.Name = "BackBtn"
backBtn.Size = UDim2.new(0, 30, 0, 30)
backBtn.Position = UDim2.new(0, 12, 0.5, -15)
backBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 65)
backBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
backBtn.Text = "<"
backBtn.TextSize = 16
backBtn.Font = Enum.Font.GothamBold
backBtn.AutoButtonColor = false
backBtn.Visible = false
backBtn.Parent = topBar

local backCorner = Instance.new("UICorner")
backCorner.CornerRadius = UDim.new(0, 8)
backCorner.Parent = backBtn

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ANTIFREAK HUB"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(36, 39, 52)
closeBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
closeBtn.Text = "X"
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = topBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 60), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(36, 39, 52), TextColor3 = Color3.fromRGB(200, 205, 225)}):Play()
end)

--// Sidebar & Content Area
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 135, 1, -48)
sidebar.Position = UDim2.new(0, 0, 0, 48)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 27)
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Padding = UDim.new(0, 6)
tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabListLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 12)
sidebarPadding.Parent = sidebar

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -135, 1, -48)
contentArea.Position = UDim2.new(0, 135, 0, 48)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

--// Tabs System
local tabs = {}
local tabButtons = {}
local defaultTabNames = {"Visuals", "Player", "Game", "Hub", "Misc", "Settings"}
local activeThemeAccent = Color3.fromRGB(75, 100, 245)

local function switchTab(selectedName)
	for name, page in pairs(tabs) do
		local btn = tabButtons[name]
		if btn then
			if name == selectedName then
				page.Visible = true
				TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					BackgroundColor3 = activeThemeAccent,
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			else
				page.Visible = false
				TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(24, 26, 36),
					TextColor3 = Color3.fromRGB(145, 150, 170)
				}):Play()
			end
		end
	end
end

for _, tabName in ipairs(defaultTabNames) do
	local tBtn = Instance.new("TextButton")
	tBtn.Name = tabName .. "Btn"
	tBtn.Size = UDim2.new(0, 115, 0, 35)
	tBtn.BackgroundColor3 = Color3.fromRGB(24, 26, 36)
	tBtn.TextColor3 = Color3.fromRGB(145, 150, 170)
	tBtn.Text = tabName
	tBtn.TextSize = 13
	tBtn.Font = Enum.Font.GothamMedium
	tBtn.AutoButtonColor = false
	tBtn.Parent = sidebar

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 8)
	tCorner.Parent = tBtn

	tabButtons[tabName] = tBtn

	local page = Instance.new("ScrollingFrame")
	page.Name = tabName .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Color3.fromRGB(60, 65, 90)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.Visible = false
	page.Parent = contentArea

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 10)
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingTop = UDim.new(0, 14)
	pagePadding.PaddingLeft = UDim.new(0, 14)
	pagePadding.PaddingRight = UDim.new(0, 14)
	pagePadding.PaddingBottom = UDim.new(0, 14)
	pagePadding.Parent = page

	tabs[tabName] = page

	tBtn.MouseButton1Click:Connect(function()
		switchTab(tabName)
	end)
end

switchTab("Visuals")

--// State Registry for Saving & Restoration
local StateRegistry = {
	ESP = false,
	Fly = false,
	Speedhack = false,
	TouchFling = false,
	AntiFling = false,
	WalkSpeedValue = 16
}

local SavedStateBackup = {}

--// Visuals Tab: ESP System
local currentESPColor = Color3.fromRGB(255, 50, 50)
local highlights = {}

local function applyHighlight(plr)
	if plr == localPlayer or not StateRegistry.ESP then return end
	local char = plr.Character
	if char and not highlights[plr] then
		local hl = Instance.new("Highlight")
		hl.Name = "ESPHighlight"
		hl.FillColor = currentESPColor
		hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		hl.FillTransparency = 0.4
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = char
		highlights[plr] = hl
	end
end

local function removeHighlight(plr)
	if highlights[plr] then
		highlights[plr]:Destroy()
		highlights[plr] = nil
	end
end

local function refreshAllHighlights()
	for _, plr in ipairs(Players:GetPlayers()) do
		if StateRegistry.ESP then
			if highlights[plr] then
				highlights[plr].FillColor = currentESPColor
			else
				applyHighlight(plr)
			end
		else
			removeHighlight(plr)
		end
	end
end

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		if StateRegistry.ESP then applyHighlight(plr) end
	end)
end)

Players.PlayerRemoving:Connect(function(plr) removeHighlight(plr) end)

local visualsPage = tabs["Visuals"]
local espAccordion = Instance.new("Frame")
espAccordion.Size = UDim2.new(1, 0, 0, 50)
espAccordion.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
espAccordion.ClipsDescendants = true
espAccordion.Parent = visualsPage

local accCorner = Instance.new("UICorner")
accCorner.CornerRadius = UDim.new(0, 10)
accCorner.Parent = espAccordion

local accStroke = Instance.new("UIStroke")
accStroke.Color = Color3.fromRGB(38, 42, 58)
accStroke.Thickness = 1
accStroke.Parent = espAccordion

local headerRow = Instance.new("Frame")
headerRow.Size = UDim2.new(1, 0, 0, 50)
headerRow.BackgroundTransparency = 1
headerRow.Parent = espAccordion

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(0.4, 0, 1, 0)
espTitle.Position = UDim2.new(0, 14, 0, 0)
espTitle.BackgroundTransparency = 1
espTitle.Text = "Player ESP"
espTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
espTitle.TextSize = 14
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = headerRow

local arrowBtn = Instance.new("TextButton")
arrowBtn.Size = UDim2.new(0, 32, 0, 32)
arrowBtn.Position = UDim2.new(1, -125, 0.5, -16)
arrowBtn.BackgroundColor3 = Color3.fromRGB(32, 36, 50)
arrowBtn.TextColor3 = Color3.fromRGB(180, 185, 210)
arrowBtn.Text = "▼"
arrowBtn.TextSize = 11
arrowBtn.Font = Enum.Font.GothamBold
arrowBtn.AutoButtonColor = false
arrowBtn.Parent = headerRow

local arrowCorner = Instance.new("UICorner")
arrowCorner.CornerRadius = UDim.new(0, 8)
arrowCorner.Parent = arrowBtn

local toggleSwitch = Instance.new("TextButton")
toggleSwitch.Size = UDim2.new(0, 75, 0, 32)
toggleSwitch.Position = UDim2.new(1, -85, 0.5, -16)
toggleSwitch.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
toggleSwitch.TextColor3 = Color3.fromRGB(180, 185, 200)
toggleSwitch.Text = "OFF"
toggleSwitch.TextSize = 11
toggleSwitch.Font = Enum.Font.GothamBold
toggleSwitch.AutoButtonColor = false
toggleSwitch.Parent = headerRow

local switchCorner = Instance.new("UICorner")
switchCorner.CornerRadius = UDim.new(0, 8)
switchCorner.Parent = toggleSwitch

local function setESPState(state)
	StateRegistry.ESP = state
	toggleSwitch.Text = state and "ON" or "OFF"
	toggleSwitch.BackgroundColor3 = state and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
	toggleSwitch.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
	refreshAllHighlights()
end

toggleSwitch.MouseButton1Click:Connect(function()
	setESPState(not StateRegistry.ESP)
end)

local settingsContainer = Instance.new("Frame")
settingsContainer.Size = UDim2.new(1, -28, 0, 150)
settingsContainer.Position = UDim2.new(0, 14, 0, 52)
settingsContainer.BackgroundTransparency = 1
settingsContainer.Parent = espAccordion

local previewCard = Instance.new("Frame")
previewCard.Size = UDim2.new(1, 0, 0, 28)
previewCard.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
previewCard.Parent = settingsContainer

local previewCorner = Instance.new("UICorner")
previewCorner.CornerRadius = UDim.new(0, 6)
previewCorner.Parent = previewCard

local previewBox = Instance.new("Frame")
previewBox.Size = UDim2.new(0, 18, 0, 18)
previewBox.Position = UDim2.new(0, 8, 0.5, -9)
previewBox.BackgroundColor3 = currentESPColor
previewBox.Parent = previewCard

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 4)
boxCorner.Parent = previewBox

local previewLabel = Instance.new("TextLabel")
previewLabel.Size = UDim2.new(1, -34, 1, 0)
previewLabel.Position = UDim2.new(0, 34, 0, 0)
previewLabel.BackgroundTransparency = 1
previewLabel.Text = "Selected Color Spectrum"
previewLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
previewLabel.TextSize = 11
previewLabel.Font = Enum.Font.GothamMedium
previewLabel.TextXAlignment = Enum.TextXAlignment.Left
previewLabel.Parent = previewCard

local paletteFrame = Instance.new("Frame")
paletteFrame.Size = UDim2.new(1, 0, 0, 80)
paletteFrame.Position = UDim2.new(0, 0, 0, 36)
paletteFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
paletteFrame.BorderSizePixel = 0
paletteFrame.Parent = settingsContainer

local palCorner = Instance.new("UICorner")
palCorner.CornerRadius = UDim.new(0, 8)
palCorner.Parent = paletteFrame

local palGradient = Instance.new("UIGradient")
palGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
	ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
	ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
	ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
	ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
	ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
})
palGradient.Parent = paletteFrame

local pickerCursor = Instance.new("Frame")
pickerCursor.Size = UDim2.new(0, 14, 0, 14)
pickerCursor.AnchorPoint = Vector2.new(0.5, 0.5)
pickerCursor.Position = UDim2.new(0.05, 0, 0.5, 0)
pickerCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
pickerCursor.Parent = paletteFrame

local curCorner = Instance.new("UICorner")
curCorner.CornerRadius = UDim.new(1, 0)
curCorner.Parent = pickerCursor

local curStroke = Instance.new("UIStroke")
curStroke.Color = Color3.fromRGB(20, 20, 25)
curStroke.Thickness = 2
curStroke.Parent = pickerCursor

local isExpanded, pickingColor = false, false
local function updatePalette(input)
	local x = math.clamp((input.Position.X - paletteFrame.AbsolutePosition.X) / paletteFrame.AbsoluteSize.X, 0, 1)
	local y = math.clamp((input.Position.Y - paletteFrame.AbsolutePosition.Y) / paletteFrame.AbsoluteSize.Y, 0, 1)
	pickerCursor.Position = UDim2.new(x, 0, y, 0)
	currentESPColor = Color3.fromHSV(x, 1 - (y * 0.4), 1)
	previewBox.BackgroundColor3 = currentESPColor
	refreshAllHighlights()
end

paletteFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		pickingColor = true
		updatePalette(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then pickingColor = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if pickingColor and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updatePalette(input) end
end)

arrowBtn.MouseButton1Click:Connect(function()
	isExpanded = not isExpanded
	arrowBtn.Text = isExpanded and "▲" or "▼"
	TweenService:Create(espAccordion, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = isExpanded and UDim2.new(1, 0, 0, 205) or UDim2.new(1, 0, 0, 50)
	}):Play()
end)
-- LocalScript (StarterPlayer -> StarterPlayerScripts) - PART 2 OF 3 (Continuation)

--// Helper: Toggle Card Constructor
local function createToggleCard(parent, titleText, onToggle)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 50)
	card.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
	card.Parent = parent

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 10)
	cCorner.Parent = card

	local cStroke = Instance.new("UIStroke")
	cStroke.Color = Color3.fromRGB(38, 42, 58)
	cStroke.Thickness = 1
	cStroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = Color3.fromRGB(240, 240, 255)
	label.TextSize = 14
	label.Font = Enum.Font.GothamBold
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 75, 0, 32)
	btn.Position = UDim2.new(1, -85, 0.5, -16)
	btn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
	btn.TextColor3 = Color3.fromRGB(180, 185, 200)
	btn.Text = "OFF"
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = false
	btn.Parent = card

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 8)
	bCorner.Parent = btn

	local state = false
	btn.MouseButton1Click:Connect(function()
		state = not state
		btn.Text = state and "ON" or "OFF"
		TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundColor3 = state and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58),
			TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
		}):Play()
		onToggle(state)
	end)

	return {
		Card = card,
		SetState = function(val)
			state = val
			btn.Text = state and "ON" or "OFF"
			btn.BackgroundColor3 = state and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
			btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
			onToggle(val)
		end
	}
end

--// Compact Flight Settings Sub-Window
local flySpeed = 70
local flyAnimationTilt = true
local flyBodyVel, flyBodyGyro

local flightSubWindow = Instance.new("CanvasGroup")
flightSubWindow.Name = "FlightSettingsWindow"
flightSubWindow.Size = UDim2.new(0, 210, 0, 165)
flightSubWindow.Position = UDim2.new(0.78, 0, 0.45, 0)
flightSubWindow.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
flightSubWindow.BorderSizePixel = 0
flightSubWindow.Visible = false
flightSubWindow.Parent = screenGui
makeDraggable(flightSubWindow)

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 10)
subCorner.Parent = flightSubWindow

local subStroke = Instance.new("UIStroke")
subStroke.Color = Color3.fromRGB(50, 55, 75)
subStroke.Thickness = 1.5
subStroke.Parent = flightSubWindow

local subTopBar = Instance.new("Frame")
subTopBar.Size = UDim2.new(1, 0, 0, 32)
subTopBar.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
subTopBar.BorderSizePixel = 0
subTopBar.Parent = flightSubWindow

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -36, 1, 0)
subTitle.Position = UDim2.new(0, 10, 0, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Flight Settings"
subTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
subTitle.TextSize = 12
subTitle.Font = Enum.Font.GothamBold
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = subTopBar

local subClose = Instance.new("TextButton")
subClose.Size = UDim2.new(0, 22, 0, 22)
subClose.Position = UDim2.new(1, -26, 0.5, -11)
subClose.BackgroundColor3 = Color3.fromRGB(36, 39, 52)
subClose.TextColor3 = Color3.fromRGB(200, 205, 225)
subClose.Text = "X"
subClose.TextSize = 11
subClose.Font = Enum.Font.GothamBold
subClose.AutoButtonColor = false
subClose.Parent = subTopBar

local subCloseCorner = Instance.new("UICorner")
subCloseCorner.CornerRadius = UDim.new(0, 6)
subCloseCorner.Parent = subClose

subClose.MouseButton1Click:Connect(function() flightSubWindow.Visible = false end)

local subContent = Instance.new("Frame")
subContent.Size = UDim2.new(1, -16, 1, -40)
subContent.Position = UDim2.new(0, 8, 0, 36)
subContent.BackgroundTransparency = 1
subContent.Parent = flightSubWindow

local subFlyBtn = Instance.new("TextButton")
subFlyBtn.Size = UDim2.new(1, 0, 0, 28)
subFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
subFlyBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
subFlyBtn.Text = "Flight: OFF"
subFlyBtn.TextSize = 11
subFlyBtn.Font = Enum.Font.GothamBold
subFlyBtn.AutoButtonColor = false
subFlyBtn.Parent = subContent

local subFlyCorner = Instance.new("UICorner")
subFlyCorner.CornerRadius = UDim.new(0, 6)
subFlyCorner.Parent = subFlyBtn

local subTiltBtn = Instance.new("TextButton")
subTiltBtn.Size = UDim2.new(1, 0, 0, 26)
subTiltBtn.Position = UDim2.new(0, 0, 0, 32)
subTiltBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
subTiltBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
subTiltBtn.Text = "Tilt Animation: ON"
subTiltBtn.TextSize = 10
subTiltBtn.Font = Enum.Font.GothamMedium
subTiltBtn.AutoButtonColor = false
subTiltBtn.Parent = subContent

local subTiltCorner = Instance.new("UICorner")
subTiltCorner.CornerRadius = UDim.new(0, 6)
subTiltCorner.Parent = subTiltBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 16)
speedLabel.Position = UDim2.new(0, 0, 0, 62)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. tostring(flySpeed)
speedLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
speedLabel.TextSize = 10
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = subContent

local speedTrack = Instance.new("Frame")
speedTrack.Size = UDim2.new(1, 0, 0, 8)
speedTrack.Position = UDim2.new(0, 0, 0, 82)
speedTrack.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
speedTrack.Parent = subContent

local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(1, 0)
stCorner.Parent = speedTrack

local speedFill = Instance.new("Frame")
speedFill.Size = UDim2.new((flySpeed - 10) / 290, 0, 1, 0)
speedFill.BackgroundColor3 = Color3.fromRGB(75, 100, 245)
speedFill.Parent = speedTrack

local sfCorner = Instance.new("UICorner")
sfCorner.CornerRadius = UDim.new(1, 0)
sfCorner.Parent = speedFill

local draggingSpeed = false
local function updateSpeed(input)
	local percent = math.clamp((input.Position.X - speedTrack.AbsolutePosition.X) / speedTrack.AbsoluteSize.X, 0, 1)
	flySpeed = math.floor(10 + (percent * 290))
	speedFill.Size = UDim2.new(percent, 0, 1, 0)
	speedLabel.Text = "Speed: " .. tostring(flySpeed)
end

speedTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSpeed = true
		updateSpeed(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSpeed = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSpeed and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSpeed(input) end
end)

--// Speedhack Accordion Card
local gamePage = tabs["Game"]
local speedhackAccordion = Instance.new("Frame")
speedhackAccordion.Size = UDim2.new(1, 0, 0, 50)
speedhackAccordion.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
speedhackAccordion.ClipsDescendants = true
speedhackAccordion.Parent = gamePage

local shCorner = Instance.new("UICorner")
shCorner.CornerRadius = UDim.new(0, 10)
shCorner.Parent = speedhackAccordion

local shStroke = Instance.new("UIStroke")
shStroke.Color = Color3.fromRGB(38, 42, 58)
shStroke.Thickness = 1
shStroke.Parent = speedhackAccordion

local shHeaderRow = Instance.new("Frame")
shHeaderRow.Size = UDim2.new(1, 0, 0, 50)
shHeaderRow.BackgroundTransparency = 1
shHeaderRow.Parent = speedhackAccordion

local shTitle = Instance.new("TextLabel")
shTitle.Size = UDim2.new(0.5, 0, 1, 0)
shTitle.Position = UDim2.new(0, 14, 0, 0)
shTitle.BackgroundTransparency = 1
shTitle.Text = "Speedhack"
shTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
shTitle.TextSize = 14
shTitle.Font = Enum.Font.GothamBold
shTitle.TextXAlignment = Enum.TextXAlignment.Left
shTitle.Parent = shHeaderRow

local shArrowBtn = Instance.new("TextButton")
shArrowBtn.Size = UDim2.new(0, 32, 0, 32)
shArrowBtn.Position = UDim2.new(1, -125, 0.5, -16)
shArrowBtn.BackgroundColor3 = Color3.fromRGB(32, 36, 50)
shArrowBtn.TextColor3 = Color3.fromRGB(180, 185, 210)
shArrowBtn.Text = "▼"
shArrowBtn.TextSize = 11
shArrowBtn.Font = Enum.Font.GothamBold
shArrowBtn.AutoButtonColor = false
shArrowBtn.Parent = shHeaderRow

local shaCorner = Instance.new("UICorner")
shaCorner.CornerRadius = UDim.new(0, 8)
shaCorner.Parent = shArrowBtn

local shToggleBtn = Instance.new("TextButton")
shToggleBtn.Size = UDim2.new(0, 75, 0, 32)
shToggleBtn.Position = UDim2.new(1, -85, 0.5, -16)
shToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
shToggleBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
shToggleBtn.Text = "OFF"
shToggleBtn.TextSize = 11
shToggleBtn.Font = Enum.Font.GothamBold
shToggleBtn.AutoButtonColor = false
shToggleBtn.Parent = shHeaderRow

local shtCorner = Instance.new("UICorner")
shtCorner.CornerRadius = UDim.new(0, 8)
shtCorner.Parent = shToggleBtn

local function setSpeedhackState(state)
	StateRegistry.Speedhack = state
	shToggleBtn.Text = state and "ON" or "OFF"
	shToggleBtn.BackgroundColor3 = state and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
	shToggleBtn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = state and StateRegistry.WalkSpeedValue or 16 end
	end
end

shToggleBtn.MouseButton1Click:Connect(function()
	setSpeedhackState(not StateRegistry.Speedhack)
end)

local shSettingsContainer = Instance.new("Frame")
shSettingsContainer.Size = UDim2.new(1, -28, 0, 60)
shSettingsContainer.Position = UDim2.new(0, 14, 0, 52)
shSettingsContainer.BackgroundTransparency = 1
shSettingsContainer.Parent = speedhackAccordion

local shSpeedValueLabel = Instance.new("TextLabel")
shSpeedValueLabel.Size = UDim2.new(1, 0, 0, 18)
shSpeedValueLabel.BackgroundTransparency = 1
shSpeedValueLabel.Text = "WalkSpeed Value: 16"
shSpeedValueLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
shSpeedValueLabel.TextSize = 11
shSpeedValueLabel.Font = Enum.Font.GothamBold
shSpeedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
shSpeedValueLabel.Parent = shSettingsContainer

local shTrack = Instance.new("Frame")
shTrack.Size = UDim2.new(1, 0, 0, 10)
shTrack.Position = UDim2.new(0, 0, 0, 24)
shTrack.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
shTrack.Parent = shSettingsContainer

local shtkCorner = Instance.new("UICorner")
shtkCorner.CornerRadius = UDim.new(1, 0)
shtkCorner.Parent = shTrack

local shFill = Instance.new("Frame")
shFill.Size = UDim2.new(0, 0, 1, 0)
shFill.BackgroundColor3 = Color3.fromRGB(75, 100, 245)
shFill.Parent = shTrack

local shfCorner = Instance.new("UICorner")
shfCorner.CornerRadius = UDim.new(1, 0)
shfCorner.Parent = shFill

local isSHExpanded, draggingSH = false, false
local function updateSH(input)
	local percent = math.clamp((input.Position.X - shTrack.AbsolutePosition.X) / shTrack.AbsoluteSize.X, 0, 1)
	StateRegistry.WalkSpeedValue = math.floor(16 + (percent * 234))
	shFill.Size = UDim2.new(percent, 0, 1, 0)
	shSpeedValueLabel.Text = "WalkSpeed Value: " .. tostring(StateRegistry.WalkSpeedValue)
	if StateRegistry.Speedhack then
		local char = localPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = StateRegistry.WalkSpeedValue end
		end
	end
end

shTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSH = true
		updateSH(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSH = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSH and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSH(input) end
end)

shArrowBtn.MouseButton1Click:Connect(function()
	isSHExpanded = not isSHExpanded
	shArrowBtn.Text = isSHExpanded and "▲" or "▼"
	TweenService:Create(speedhackAccordion, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = isSHExpanded and UDim2.new(1, 0, 0, 115) or UDim2.new(1, 0, 0, 50)
	}):Play()
end)
-- LocalScript (StarterPlayer -> StarterPlayerScripts) - PART 3 OF 3 (Continuation)

--// Mobile Touch Fly Controls
local mobileUpPressed, mobileDownPressed = false, false

local mobileControlsFrame = Instance.new("Frame")
mobileControlsFrame.Name = "MobileFlyControls"
mobileControlsFrame.Size = UDim2.new(0, 60, 0, 130)
mobileControlsFrame.Position = UDim2.new(1, -75, 0.5, -65)
mobileControlsFrame.BackgroundTransparency = 1
mobileControlsFrame.Visible = false
mobileControlsFrame.Parent = screenGui

local mobileUpBtn = Instance.new("TextButton")
mobileUpBtn.Size = UDim2.new(0, 55, 0, 55)
mobileUpBtn.Position = UDim2.new(0, 0, 0, 0)
mobileUpBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
mobileUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileUpBtn.Text = "▲"
mobileUpBtn.TextSize = 20
mobileUpBtn.Font = Enum.Font.GothamBold
mobileUpBtn.AutoButtonColor = false
mobileUpBtn.Parent = mobileControlsFrame

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(1, 0)
upCorner.Parent = mobileUpBtn

local upStroke = Instance.new("UIStroke")
upStroke.Color = Color3.fromRGB(75, 100, 245)
upStroke.Thickness = 2
upStroke.Parent = mobileUpBtn

local mobileDownBtn = Instance.new("TextButton")
mobileDownBtn.Size = UDim2.new(0, 55, 0, 55)
mobileDownBtn.Position = UDim2.new(0, 0, 0, 65)
mobileDownBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
mobileDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mobileDownBtn.Text = "▼"
mobileDownBtn.TextSize = 20
mobileDownBtn.Font = Enum.Font.GothamBold
mobileDownBtn.AutoButtonColor = false
mobileDownBtn.Parent = mobileControlsFrame

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(1, 0)
downCorner.Parent = mobileDownBtn

local downStroke = Instance.new("UIStroke")
downStroke.Color = Color3.fromRGB(75, 100, 245)
downStroke.Thickness = 2
downStroke.Parent = mobileDownBtn

mobileUpBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mobileUpPressed = true
		mobileUpBtn.BackgroundColor3 = Color3.fromRGB(75, 100, 245)
	end
end)

mobileUpBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mobileUpPressed = false
		mobileUpBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	end
end)

mobileDownBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mobileDownPressed = true
		mobileDownBtn.BackgroundColor3 = Color3.fromRGB(75, 100, 245)
	end
end)

mobileDownBtn.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		mobileDownPressed = false
		mobileDownBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
	end
end)

--// Flight Logic & Kinematics
local function startFlightEngine()
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	StateRegistry.Fly = true
	hum.PlatformStand = true
	hum:ChangeState(Enum.HumanoidStateType.Freefall)

	if UserInputService.TouchEnabled then
		mobileControlsFrame.Visible = true
	end

	flyBodyVel = Instance.new("BodyVelocity")
	flyBodyVel.MaxForce = Vector3.new(1e8, 1e8, 1e8)
	flyBodyVel.Velocity = Vector3.zero
	flyBodyVel.Parent = root

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
	flyBodyGyro.P = 9e4
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root
end

local function stopFlightEngine()
	StateRegistry.Fly = false
	mobileControlsFrame.Visible = false
	mobileUpPressed, mobileDownPressed = false, false

	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = false
			hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		end
	end
	if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
	if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end

--// Game Tab: Fly Toggle
local mainFlyToggle = nil

local function toggleFlyGlobal(state)
	StateRegistry.Fly = state
	if state then
		flightSubWindow.Visible = true
		startFlightEngine()
		subFlyBtn.Text = "Flight: ON"
		subFlyBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
	else
		stopFlightEngine()
		subFlyBtn.Text = "Flight: OFF"
		subFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
	end
	if mainFlyToggle then mainFlyToggle.SetState(state) end
end

mainFlyToggle = createToggleCard(gamePage, "Fly", function(enabled)
	toggleFlyGlobal(enabled)
end)

subFlyBtn.MouseButton1Click:Connect(function()
	toggleFlyGlobal(not StateRegistry.Fly)
end)

subTiltBtn.MouseButton1Click:Connect(function()
	flyAnimationTilt = not flyAnimationTilt
	subTiltBtn.Text = flyAnimationTilt and "Tilt Animation: ON" or "Tilt Animation: OFF"
	subTiltBtn.BackgroundColor3 = flyAnimationTilt and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
end)

RunService.RenderStepped:Connect(function()
	if not StateRegistry.Fly or not flyBodyVel or not flyBodyGyro then return end
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	hum.PlatformStand = true
	local moveDir = Vector3.zero

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) or mobileUpPressed then moveDir += Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or mobileDownPressed then moveDir -= Vector3.new(0, 1, 0) end

	if hum.MoveDirection.Magnitude > 0 then
		moveDir += hum.MoveDirection
	end

	if moveDir.Magnitude > 0 then
		flyBodyVel.Velocity = moveDir.Unit * flySpeed
		if flyAnimationTilt then
			local forwardCFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
			flyBodyGyro.CFrame = forwardCFrame * CFrame.Angles(math.rad(-75), 0, 0)
		else
			flyBodyGyro.CFrame = camera.CFrame
		end
	else
		flyBodyVel.Velocity = Vector3.zero
		local lookFlat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
		if lookFlat.Magnitude > 0 then
			flyBodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + lookFlat.Unit)
		end
	end
end)

--// Misc Tab: Touch Fling & Anti-Fling
local miscPage = tabs["Misc"]
local flingBav = nil

local flingToggle = createToggleCard(miscPage, "Touch Fling", function(enabled)
	StateRegistry.TouchFling = enabled
	local char = localPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if enabled then
		flingBav = Instance.new("BodyAngularVelocity")
		flingBav.Name = "FlingTorque"
		flingBav.MaxTorque = Vector3.new(1e7, 1e7, 1e7)
		flingBav.AngularVelocity = Vector3.new(9000, 9000, 9000)
		flingBav.P = 50000
		flingBav.Parent = root
	else
		if flingBav then flingBav:Destroy(); flingBav = nil end
		root.AssemblyAngularVelocity = Vector3.zero
	end
end)

local antiFlingToggle = createToggleCard(miscPage, "Anti Fling (Push Protection)", function(enabled)
	StateRegistry.AntiFling = enabled
end)

RunService.Heartbeat:Connect(function()
	local myChar = localPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	local myHum = myChar:FindFirstChildOfClass("Humanoid")
	if myHum and not StateRegistry.Fly then
		local targetSpeed = StateRegistry.Speedhack and StateRegistry.WalkSpeedValue or 16
		if myHum.WalkSpeed ~= targetSpeed then myHum.WalkSpeed = targetSpeed end
	end

	if StateRegistry.TouchFling and flingBav then
		myRoot.AssemblyAngularVelocity = Vector3.new(9000, 9000, 9000)
		for _, p in ipairs(myChar:GetDescendants()) do
			if p:IsA("BasePart") and p ~= myRoot then p.CanCollide = false end
		end
	end

	if StateRegistry.AntiFling then
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= localPlayer and plr.Character then
				for _, part in ipairs(plr.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
				end
			end
		end
	end
end)

--// Hub Tab: MM2 Mode Engine
local hubPage = tabs["Hub"]
local mm2Card = Instance.new("Frame")
mm2Card.Size = UDim2.new(1, 0, 0, 65)
mm2Card.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
mm2Card.Parent = hubPage

local mm2cCorner = Instance.new("UICorner")
mm2cCorner.CornerRadius = UDim.new(0, 10)
mm2cCorner.Parent = mm2Card

local mm2cStroke = Instance.new("UIStroke")
mm2cStroke.Color = Color3.fromRGB(38, 42, 58)
mm2cStroke.Thickness = 1
mm2cStroke.Parent = mm2Card

local mm2Title = Instance.new("TextLabel")
mm2Title.Size = UDim2.new(0.6, 0, 0, 24)
mm2Title.Position = UDim2.new(0, 14, 0, 10)
mm2Title.BackgroundTransparency = 1
mm2Title.Text = "Murder Mystery 2"
mm2Title.TextColor3 = Color3.fromRGB(240, 240, 255)
mm2Title.TextSize = 14
mm2Title.Font = Enum.Font.GothamBold
mm2Title.TextXAlignment = Enum.TextXAlignment.Left
mm2Title.Parent = mm2Card

local mm2Desc = Instance.new("TextLabel")
mm2Desc.Size = UDim2.new(0.6, 0, 0, 18)
mm2Desc.Position = UDim2.new(0, 14, 0, 34)
mm2Desc.BackgroundTransparency = 1
mm2Desc.Text = "Dedicated MM2 Cheats & Blue UI Mode"
mm2Desc.TextColor3 = Color3.fromRGB(140, 145, 165)
mm2Desc.TextSize = 11
mm2Desc.Font = Enum.Font.GothamMedium
mm2Desc.TextXAlignment = Enum.TextXAlignment.Left
mm2Desc.Parent = mm2Card

local mm2LaunchBtn = Instance.new("TextButton")
mm2LaunchBtn.Size = UDim2.new(0, 85, 0, 34)
mm2LaunchBtn.Position = UDim2.new(1, -95, 0.5, -17)
mm2LaunchBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
mm2LaunchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
mm2LaunchBtn.Text = "LOAD"
mm2LaunchBtn.TextSize = 12
mm2LaunchBtn.Font = Enum.Font.GothamBold
mm2LaunchBtn.AutoButtonColor = false
mm2LaunchBtn.Parent = mm2Card

local mm2lbCorner = Instance.new("UICorner")
mm2lbCorner.CornerRadius = UDim.new(0, 8)
mm2lbCorner.Parent = mm2LaunchBtn

local function disableAllFeatures()
	SavedStateBackup = {
		ESP = StateRegistry.ESP,
		Fly = StateRegistry.Fly,
		Speedhack = StateRegistry.Speedhack,
		TouchFling = StateRegistry.TouchFling,
		AntiFling = StateRegistry.AntiFling
	}

	setESPState(false)
	toggleFlyGlobal(false)
	setSpeedhackState(false)
	flingToggle.SetState(false)
	antiFlingToggle.SetState(false)
end

local function restorePreviousFeatures()
	if SavedStateBackup.ESP then setESPState(true) end
	if SavedStateBackup.Fly then toggleFlyGlobal(true) end
	if SavedStateBackup.Speedhack then setSpeedhackState(true) end
	if SavedStateBackup.TouchFling then flingToggle.SetState(true) end
	if SavedStateBackup.AntiFling then antiFlingToggle.SetState(true) end
end

mm2LaunchBtn.MouseButton1Click:Connect(function()
	disableAllFeatures()
	tabButtons["Hub"].Visible = false
	backBtn.Visible = true
	title.Position = UDim2.new(0, 48, 0, 0)
	title.Text = "ANTIFREAK HUB - MM2"
	activeThemeAccent = Color3.fromRGB(0, 150, 255)

	TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(12, 18, 28)}):Play()
	TweenService:Create(topBar, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(16, 26, 42)}):Play()
	TweenService:Create(sidebar, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(14, 22, 34)}):Play()

	switchTab("Visuals")
end)

backBtn.MouseButton1Click:Connect(function()
	disableAllFeatures()
	restorePreviousFeatures()

	tabButtons["Hub"].Visible = true
	backBtn.Visible = false
	title.Position = UDim2.new(0, 18, 0, 0)
	title.Text = "ANTIFREAK HUB"
	activeThemeAccent = Color3.fromRGB(75, 100, 245)

	TweenService:Create(mainFrame, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(15, 17, 23)}):Play()
	TweenService:Create(topBar, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(22, 24, 34)}):Play()
	TweenService:Create(sidebar, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(18, 20, 27)}):Play()

	switchTab("Hub")
end)

--// Main Menu Toggle Animation
local isMenuOpen = false
local function toggleMenu()
	isMenuOpen = not isMenuOpen
	if isMenuOpen then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 490, 0, 340)
		mainFrame.GroupTransparency = 1
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 540, 0, 380),
			GroupTransparency = 0
		}):Play()
	else
		local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 480, 0, 330),
			GroupTransparency = 1
		})
		closeTween:Play()
		closeTween.Completed:Connect(function()
			if not isMenuOpen then mainFrame.Visible = false end
		end)
	end
end

toggleBtn.MouseButton1Click:Connect(toggleMenu)
closeBtn.MouseButton1Click:Connect(toggleMenu)
