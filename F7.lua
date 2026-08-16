-- LocalScript (StarterPlayer -> StarterPlayerScripts) - PART 1
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

--// Helper: Smooth Draggable UI
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

--// Floating Open Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "OpenButton"
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 24, 0.5, -26)
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
mainFrame.Size = UDim2.new(0, 550, 0, 390)
mainFrame.Position = UDim2.new(0.5, -275, 0.5, -195)
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

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -65, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "ANTIFREAK HUB"
title.TextColor3 = Color3.fromRGB(245, 245, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

-- Large Clean Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
closeBtn.BackgroundColor3 = Color3.fromRGB(36, 39, 52)
closeBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
closeBtn.Text = "✕"
closeBtn.TextSize = 15
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

--// Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 1, -48)
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

--// Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -140, 1, -48)
contentArea.Position = UDim2.new(0, 140, 0, 48)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

--// Tabs Setup
local tabs = {}
local tabButtons = {}
local tabNames = {"Visuals", "Player", "Game", "Misc", "Settings"}

local function switchTab(selectedName)
	for name, page in pairs(tabs) do
		local btn = tabButtons[name]
		if name == selectedName then
			page.Visible = true
			TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(75, 100, 245),
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

for _, tabName in ipairs(tabNames) do
	local tBtn = Instance.new("TextButton")
	tBtn.Name = tabName .. "Btn"
	tBtn.Size = UDim2.new(0, 120, 0, 35)
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
-- LocalScript (StarterPlayer -> StarterPlayerScripts) - PART 2 (Continuation)

--// ==================== VISUALS (ESP & PALETTE) ====================
local espEnabled = false
local currentESPColor = Color3.fromRGB(255, 50, 50)
local highlights = {}

local function applyHighlight(plr)
	if plr == localPlayer then return end
	if not espEnabled then return end
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
		if espEnabled then
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
		if espEnabled then applyHighlight(plr) end
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

toggleSwitch.MouseButton1Click:Connect(function()
	espEnabled = not espEnabled
	toggleSwitch.Text = espEnabled and "ON" or "OFF"
	TweenService:Create(toggleSwitch, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundColor3 = espEnabled and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58),
		TextColor3 = espEnabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 185, 200)
	}):Play()
	refreshAllHighlights()
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

--// ==================== HELPER: TOGGLE CARD ====================
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
	return {Card = card, SetState = function(val)
		state = val
		btn.Text = state and "ON" or "OFF"
		btn.BackgroundColor3 = state and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
	end}
end

--// ==================== FLIGHT SETTINGS SUB-WINDOW ====================
local isFlying = false
local flySpeed = 70
local flyAnimationTilt = true
local flyBodyVel, flyBodyGyro

local flightSubWindow = Instance.new("CanvasGroup")
flightSubWindow.Name = "FlightSettingsWindow"
flightSubWindow.Size = UDim2.new(0, 240, 0, 200)
flightSubWindow.Position = UDim2.new(0.75, 0, 0.4, 0)
flightSubWindow.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
flightSubWindow.BorderSizePixel = 0
flightSubWindow.Visible = false
flightSubWindow.Parent = screenGui
makeDraggable(flightSubWindow)

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 12)
subCorner.Parent = flightSubWindow

local subStroke = Instance.new("UIStroke")
subStroke.Color = Color3.fromRGB(50, 55, 75)
subStroke.Thickness = 1.5
subStroke.Parent = flightSubWindow

local subTopBar = Instance.new("Frame")
subTopBar.Size = UDim2.new(1, 0, 0, 36)
subTopBar.BackgroundColor3 = Color3.fromRGB(24, 27, 38)
subTopBar.BorderSizePixel = 0
subTopBar.Parent = flightSubWindow

local subTitle = Instance.new("TextLabel")
subTitle.Size = UDim2.new(1, -40, 1, 0)
subTitle.Position = UDim2.new(0, 12, 0, 0)
subTitle.BackgroundTransparency = 1
subTitle.Text = "Flight Settings"
subTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
subTitle.TextSize = 13
subTitle.Font = Enum.Font.GothamBold
subTitle.TextXAlignment = Enum.TextXAlignment.Left
subTitle.Parent = subTopBar

local subClose = Instance.new("TextButton")
subClose.Size = UDim2.new(0, 24, 0, 24)
subClose.Position = UDim2.new(1, -30, 0.5, -12)
subClose.BackgroundColor3 = Color3.fromRGB(36, 39, 52)
subClose.TextColor3 = Color3.fromRGB(200, 205, 225)
subClose.Text = "✕"
subClose.TextSize = 12
subClose.Font = Enum.Font.GothamBold
subClose.AutoButtonColor = false
subClose.Parent = subTopBar

local subCloseCorner = Instance.new("UICorner")
subCloseCorner.CornerRadius = UDim.new(0, 6)
subCloseCorner.Parent = subClose

subClose.MouseButton1Click:Connect(function()
	flightSubWindow.Visible = false
end)

-- Inner Controls for Flight Sub-Window
local subContent = Instance.new("Frame")
subContent.Size = UDim2.new(1, -20, 1, -46)
subContent.Position = UDim2.new(0, 10, 0, 42)
subContent.BackgroundTransparency = 1
subContent.Parent = flightSubWindow

local subFlyBtn = Instance.new("TextButton")
subFlyBtn.Size = UDim2.new(1, 0, 0, 32)
subFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
subFlyBtn.TextColor3 = Color3.fromRGB(200, 205, 225)
subFlyBtn.Text = "Flight Active: OFF"
subFlyBtn.TextSize = 12
subFlyBtn.Font = Enum.Font.GothamBold
subFlyBtn.AutoButtonColor = false
subFlyBtn.Parent = subContent

local subFlyCorner = Instance.new("UICorner")
subFlyCorner.CornerRadius = UDim.new(0, 8)
subFlyCorner.Parent = subFlyBtn

local subTiltBtn = Instance.new("TextButton")
subTiltBtn.Size = UDim2.new(1, 0, 0, 30)
subTiltBtn.Position = UDim2.new(0, 0, 0, 38)
subTiltBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
subTiltBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
subTiltBtn.Text = "Tilt Animation: ON"
subTiltBtn.TextSize = 11
subTiltBtn.Font = Enum.Font.GothamMedium
subTiltBtn.AutoButtonColor = false
subTiltBtn.Parent = subContent

local subTiltCorner = Instance.new("UICorner")
subTiltCorner.CornerRadius = UDim.new(0, 8)
subTiltCorner.Parent = subTiltBtn

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 18)
speedLabel.Position = UDim2.new(0, 0, 0, 74)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed: " .. tostring(flySpeed)
speedLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
speedLabel.TextSize = 11
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = subContent

local speedTrack = Instance.new("Frame")
speedTrack.Size = UDim2.new(1, 0, 0, 10)
speedTrack.Position = UDim2.new(0, 0, 0, 96)
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

local function startFlightEngine()
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end

	isFlying = true
	hum.PlatformStand = true

	flyBodyVel = Instance.new("BodyVelocity")
	flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	flyBodyVel.Velocity = Vector3.zero
	flyBodyVel.Parent = root

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	flyBodyGyro.P = 10000
	flyBodyGyro.D = 500
	flyBodyGyro.CFrame = root.CFrame
	flyBodyGyro.Parent = root
end

local function stopFlightEngine()
	isFlying = false
	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = false end
	end
	if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
	if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
end

--// ==================== GAME TAB (FLY & SPEEDHACK) ====================
local gamePage = tabs["Game"]
local mainFlyToggle = nil

local function toggleFlyGlobal(state)
	if state then
		flightSubWindow.Visible = true
		startFlightEngine()
		subFlyBtn.Text = "Flight Active: ON"
		subFlyBtn.BackgroundColor3 = Color3.fromRGB(45, 185, 100)
	else
		stopFlightEngine()
		subFlyBtn.Text = "Flight Active: OFF"
		subFlyBtn.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
	end
	if mainFlyToggle then mainFlyToggle.SetState(state) end
end

mainFlyToggle = createToggleCard(gamePage, "Fly", function(enabled)
	toggleFlyGlobal(enabled)
end)

subFlyBtn.MouseButton1Click:Connect(function()
	toggleFlyGlobal(not isFlying)
end)

subTiltBtn.MouseButton1Click:Connect(function()
	flyAnimationTilt = not flyAnimationTilt
	subTiltBtn.Text = flyAnimationTilt and "Tilt Animation: ON" or "Tilt Animation: OFF"
	subTiltBtn.BackgroundColor3 = flyAnimationTilt and Color3.fromRGB(45, 185, 100) or Color3.fromRGB(40, 44, 58)
end)

-- Flight Stepped Motion
RunService.RenderStepped:Connect(function()
	if not isFlying or not flyBodyVel or not flyBodyGyro then return end
	local char = localPlayer.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local moveDir = Vector3.zero
	local isMoving = false

	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector; isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector; isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector; isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector; isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0); isMoving = true end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0); isMoving = true end

	if isMoving and moveDir.Magnitude > 0 then
		flyBodyVel.Velocity = moveDir.Unit * flySpeed
		if flyAnimationTilt then
			local forwardCFrame = CFrame.lookAt(root.Position, root.Position + moveDir)
			flyBodyGyro.CFrame = forwardCFrame * CFrame.Angles(math.rad(-75), 0, 0)
		else
			flyBodyGyro.CFrame = camera.CFrame
		end
	else
		flyBodyVel.Velocity = Vector3.zero
		local lookFlat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
		flyBodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + lookFlat)
	end
end)

-- Speedhack Card & Logic
local speedhackCard = Instance.new("Frame")
speedhackCard.Size = UDim2.new(1, 0, 0, 80)
speedhackCard.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
speedhackCard.Parent = gamePage

local shCorner = Instance.new("UICorner")
shCorner.CornerRadius = UDim.new(0, 10)
shCorner.Parent = speedhackCard

local shStroke = Instance.new("UIStroke")
shStroke.Color = Color3.fromRGB(38, 42, 58)
shStroke.Thickness = 1
shStroke.Parent = speedhackCard

local shTitle = Instance.new("TextLabel")
shTitle.Size = UDim2.new(1, -28, 0, 20)
shTitle.Position = UDim2.new(0, 14, 0, 10)
shTitle.BackgroundTransparency = 1
shTitle.Text = "Speedhack (WalkSpeed: 16)"
shTitle.TextColor3 = Color3.fromRGB(240, 240, 255)
shTitle.TextSize = 14
shTitle.Font = Enum.Font.GothamBold
shTitle.TextXAlignment = Enum.TextXAlignment.Left
shTitle.Parent = speedhackCard

local shTrack = Instance.new("Frame")
shTrack.Size = UDim2.new(1, -28, 0, 10)
shTrack.Position = UDim2.new(0, 14, 0, 42)
shTrack.BackgroundColor3 = Color3.fromRGB(32, 35, 48)
shTrack.Parent = speedhackCard

local shtCorner = Instance.new("UICorner")
shtCorner.CornerRadius = UDim.new(1, 0)
shtCorner.Parent = shTrack

local shFill = Instance.new("Frame")
shFill.Size = UDim2.new(0, 0, 1, 0)
shFill.BackgroundColor3 = Color3.fromRGB(75, 100, 245)
shFill.Parent = shTrack

local shfCorner = Instance.new("UICorner")
shfCorner.CornerRadius = UDim.new(1, 0)
shfCorner.Parent = shFill

local currentWalkSpeed = 16
local draggingSpeedhack = false

local function updateSpeedhack(input)
	local percent = math.clamp((input.Position.X - shTrack.AbsolutePosition.X) / shTrack.AbsoluteSize.X, 0, 1)
	currentWalkSpeed = math.floor(16 + (percent * 234))
	shFill.Size = UDim2.new(percent, 0, 1, 0)
	shTitle.Text = "Speedhack (WalkSpeed: " .. tostring(currentWalkSpeed) .. ")"
	
	local char = localPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = currentWalkSpeed end
	end
end

shTrack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingSpeedhack = true
		updateSpeedhack(input)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
		draggingSpeedhack = false 
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingSpeedhack and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
		updateSpeedhack(input) 
	end
end)

--// ==================== MISC TAB (STABLE FLING & ANTI-FLING) ====================
local miscPage = tabs["Misc"]
local touchFlingEnabled = false
local antiFlingEnabled = false

createToggleCard(miscPage, "Touch Fling", function(enabled)
	touchFlingEnabled = enabled
end)

createToggleCard(miscPage, "Anti Fling (Push Protection)", function(enabled)
	antiFlingEnabled = enabled
end)

RunService.Stepped:Connect(function()
	local myChar = localPlayer.Character
	if not myChar then return end
	local myRoot = myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return end

	-- Maintain walkspeed
	local myHum = myChar:FindFirstChildOfClass("Humanoid")
	if myHum and not isFlying and myHum.WalkSpeed ~= currentWalkSpeed then
		myHum.WalkSpeed = currentWalkSpeed
	end

	-- Safe No-Lag Fling Collision Handling
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= localPlayer and plr.Character then
			local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			if targetRoot then
				local dist = (myRoot.Position - targetRoot.Position).Magnitude
				
				if touchFlingEnabled and dist <= 7.5 then
					for _, p in ipairs(myChar:GetDescendants()) do
						if p:IsA("BasePart") then p.CanCollide = false end
					end
					local dir = (targetRoot.Position - myRoot.Position).Unit
					targetRoot.AssemblyLinearVelocity = (dir * 300) + Vector3.new(0, 150, 0)
					targetRoot.AssemblyAngularVelocity = Vector3.new(300, 300, 300)
				end

				if antiFlingEnabled then
					for _, part in ipairs(plr.Character:GetDescendants()) do
						if part:IsA("BasePart") and part.CanCollide then 
							part.CanCollide = false 
						end
					end
					if dist <= 8 and targetRoot.AssemblyLinearVelocity.Magnitude > 50 then
						targetRoot.AssemblyLinearVelocity = Vector3.zero
						targetRoot.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end
		end
	end
end)

--// ==================== MAIN MENU OPEN/CLOSE ====================
local isMenuOpen = false
local function toggleMenu()
	isMenuOpen = not isMenuOpen
	if isMenuOpen then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 490, 0, 340)
		mainFrame.GroupTransparency = 1
		TweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 550, 0, 390),
			GroupTransparency = 0
		}):Play()
	else
		local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 480, 0, 330),
			GroupTransparency = 1
		})
		closeTween:Play()
		closeTween.Completed:Connect(function()
			if not isMenuOpen then 
				mainFrame.Visible = false 
			end
		end)
	end
end

toggleBtn.MouseButton1Click:Connect(toggleMenu)
closeBtn.MouseButton1Click:Connect(toggleMenu)
