--[[
    AntiFreak Hub
    Full client-side LocalScript
    Place inside:
    StarterPlayer > StarterPlayerScripts

    UI language: English only
    Input: PC + Mobile / Touch
]]

--//========================================================
--// SERVICES
--//========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

--//========================================================
--// CLEAN OLD GUI
--//========================================================

local oldGui = PlayerGui:FindFirstChild("AntiFreakHub")
if oldGui then
	oldGui:Destroy()
end

--//========================================================
--// CONFIG
--//========================================================

local Config = {
	MenuOpen = true,
	CurrentTab = "Visuals",

	ESPEnabled = false,
	ESPColor = Color3.fromHSV(0.55, 0.85, 1),

	FlyEnabled = false,
	FlySpeed = 80,
	FlyTilt = 32,

	SpeedEnabled = false,
	WalkSpeed = 32,

	TouchFlingEnabled = false,
	AntiFlingEnabled = false,

	MM2Mode = false,
	Animations = true,

	DefaultWalkSpeed = 16,
}

local SavedStates = {}

--//========================================================
--// THEMES
--//========================================================

local Themes = {
	Default = {
		Background = Color3.fromRGB(12, 14, 19),
		Panel = Color3.fromRGB(18, 21, 28),
		Panel2 = Color3.fromRGB(23, 27, 36),
		Panel3 = Color3.fromRGB(29, 34, 44),

		Accent = Color3.fromRGB(180, 76, 255),
		Accent2 = Color3.fromRGB(96, 132, 255),

		Text = Color3.fromRGB(245, 247, 255),
		SubText = Color3.fromRGB(145, 153, 174),

		Stroke = Color3.fromRGB(48, 53, 67),

		Success = Color3.fromRGB(87, 228, 142),
		Danger = Color3.fromRGB(255, 85, 105),
	},

	MM2 = {
		Background = Color3.fromRGB(4, 11, 20),
		Panel = Color3.fromRGB(7, 19, 34),
		Panel2 = Color3.fromRGB(9, 27, 47),
		Panel3 = Color3.fromRGB(13, 37, 61),

		Accent = Color3.fromRGB(0, 183, 255),
		Accent2 = Color3.fromRGB(0, 111, 255),

		Text = Color3.fromRGB(235, 249, 255),
		SubText = Color3.fromRGB(125, 174, 204),

		Stroke = Color3.fromRGB(20, 77, 111),

		Success = Color3.fromRGB(55, 235, 188),
		Danger = Color3.fromRGB(255, 78, 112),
	},
}

local Theme = Themes.Default

local ThemeObjects = {
	Background = {},
	Panel = {},
	Panel2 = {},
	Panel3 = {},
	Accent = {},
	Text = {},
	SubText = {},
	Stroke = {},
}

--//========================================================
--// HELPERS
--//========================================================

local function New(className, properties)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	return object
end

local function Corner(parent, radius)
	local corner = New("UICorner", {
		CornerRadius = UDim.new(0, radius or 10),
	})
	corner.Parent = parent
	return corner
end

local function Stroke(parent, color, transparency, thickness)
	local stroke = New("UIStroke", {
		Color = color or Theme.Stroke,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	})
	stroke.Parent = parent
	return stroke
end

local function Padding(parent, left, right, top, bottom)
	local padding = New("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
	})
	padding.Parent = parent
	return padding
end

local function Tween(object, info, properties)
	local tweenInfo

	if typeof(info) == "TweenInfo" then
		tweenInfo = info
	else
		tweenInfo = TweenInfo.new(
			info or 0.25,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		)
	end

	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()

	return tween
end

local function RegisterTheme(object, category)
	if ThemeObjects[category] then
		table.insert(ThemeObjects[category], object)
	end
end

local function SafeThemeProperty(object, property, value)
	if object and object.Parent then
		pcall(function()
			object[property] = value
		end)
	end
end

local function ApplyTheme()
	for _, object in ipairs(ThemeObjects.Background) do
		SafeThemeProperty(object, "BackgroundColor3", Theme.Background)
	end

	for _, object in ipairs(ThemeObjects.Panel) do
		SafeThemeProperty(object, "BackgroundColor3", Theme.Panel)
	end

	for _, object in ipairs(ThemeObjects.Panel2) do
		SafeThemeProperty(object, "BackgroundColor3", Theme.Panel2)
	end

	for _, object in ipairs(ThemeObjects.Panel3) do
		SafeThemeProperty(object, "BackgroundColor3", Theme.Panel3)
	end

	for _, object in ipairs(ThemeObjects.Accent) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			SafeThemeProperty(object, "TextColor3", Theme.Accent)
		elseif object:IsA("UIStroke") then
			SafeThemeProperty(object, "Color", Theme.Accent)
		else
			SafeThemeProperty(object, "BackgroundColor3", Theme.Accent)
		end
	end

	for _, object in ipairs(ThemeObjects.Text) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			SafeThemeProperty(object, "TextColor3", Theme.Text)
		end
	end

	for _, object in ipairs(ThemeObjects.SubText) do
		if object:IsA("TextLabel") or object:IsA("TextButton") then
			SafeThemeProperty(object, "TextColor3", Theme.SubText)
		end
	end

	for _, object in ipairs(ThemeObjects.Stroke) do
		if object:IsA("UIStroke") then
			SafeThemeProperty(object, "Color", Theme.Stroke)
		end
	end
end

local function GetCharacter()
	return LocalPlayer.Character
end

local function GetHumanoid()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
	local character = GetCharacter()

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function MakeDraggable(frame, dragHandle)
	dragHandle = dragHandle or frame

	local dragging = false
	local dragStart
	local startPosition
	local dragInput

	local function Update(input)
		if not dragging then
			return
		end

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput then
			Update(input)
		end
	end)
end

--//========================================================
--// ROOT GUI
--//========================================================

local ScreenGui = New("ScreenGui", {
	Name = "AntiFreakHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
})

ScreenGui.Parent = PlayerGui

--//========================================================
--// OPTIONAL BACKGROUND BLUR
--//========================================================

local Blur = Lighting:FindFirstChild("AntiFreakHubBlur")

if not Blur then
	Blur = New("BlurEffect", {
		Name = "AntiFreakHubBlur",
		Size = 0,
	})
	Blur.Parent = Lighting
end

--//========================================================
--// OPEN BUTTON
--//========================================================

local OpenButton = New("TextButton", {
	Name = "OpenButton",

	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 18, 0.5, 0),
	Size = UDim2.fromOffset(54, 54),

	BackgroundColor3 = Theme.Panel2,

	AutoButtonColor = false,

	Text = "⚡",
	TextSize = 25,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 50,
})

Corner(OpenButton, 16)

local OpenStroke = Stroke(OpenButton, Theme.Accent, 0.15, 1.5)

OpenButton.Parent = ScreenGui

RegisterTheme(OpenButton, "Panel2")
RegisterTheme(OpenButton, "Text")
RegisterTheme(OpenStroke, "Accent")

MakeDraggable(OpenButton)

--//========================================================
--// MAIN WINDOW
--//========================================================

local MainGroup = New("CanvasGroup", {
	Name = "MainGroup",

	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.fromOffset(720, 460),

	BackgroundTransparency = 1,

	GroupTransparency = 0,
	ZIndex = 10,
})

MainGroup.Parent = ScreenGui

local MainScale = New("UIScale", {
	Scale = 1,
})

MainScale.Parent = MainGroup

local MainFrame = New("Frame", {
	Name = "MainFrame",

	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,

	ClipsDescendants = true,
})

Corner(MainFrame, 20)

local MainStroke = Stroke(MainFrame, Theme.Stroke, 0.15, 1)

MainFrame.Parent = MainGroup

RegisterTheme(MainFrame, "Background")
RegisterTheme(MainStroke, "Stroke")

--//========================================================
--// TOP BAR
--//========================================================

local TopBar = New("Frame", {
	Name = "TopBar",

	Size = UDim2.new(1, 0, 0, 58),

	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,

	ZIndex = 3,
})

TopBar.Parent = MainFrame
RegisterTheme(TopBar, "Panel")

local TopBottomLine = New("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),

	Size = UDim2.new(1, 0, 0, 1),

	BackgroundColor3 = Theme.Stroke,
	BorderSizePixel = 0,
})

TopBottomLine.Parent = TopBar
RegisterTheme(TopBottomLine, "Stroke")

local BackButton = New("TextButton", {
	Name = "BackButton",

	Position = UDim2.fromOffset(16, 11),
	Size = UDim2.fromOffset(36, 36),

	BackgroundColor3 = Theme.Panel3,
	AutoButtonColor = false,

	Text = "<",
	TextSize = 21,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	Visible = false,
})

Corner(BackButton, 11)

BackButton.Parent = TopBar
RegisterTheme(BackButton, "Panel3")
RegisterTheme(BackButton, "Text")

local LogoBox = New("Frame", {
	Position = UDim2.fromOffset(18, 11),
	Size = UDim2.fromOffset(36, 36),

	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
})

Corner(LogoBox, 11)

LogoBox.Parent = TopBar
RegisterTheme(LogoBox, "Accent")

local LogoText = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Text = "⚡",
	TextSize = 19,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.new(1, 1, 1),
})

LogoText.Parent = LogoBox

local Title = New("TextLabel", {
	Position = UDim2.fromOffset(66, 8),
	Size = UDim2.new(0, 260, 0, 24),

	BackgroundTransparency = 1,

	Text = "AntiFreak Hub",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 17,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

Title.Parent = TopBar
RegisterTheme(Title, "Text")

local Subtitle = New("TextLabel", {
	Position = UDim2.fromOffset(66, 30),
	Size = UDim2.new(0, 320, 0, 18),

	BackgroundTransparency = 1,

	Text = "Universal Client Interface",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

Subtitle.Parent = TopBar
RegisterTheme(Subtitle, "SubText")

local CloseButton = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -14, 0, 11),
	Size = UDim2.fromOffset(36, 36),

	BackgroundColor3 = Theme.Panel3,
	AutoButtonColor = false,

	Text = "X",
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

Corner(CloseButton, 11)

CloseButton.Parent = TopBar

RegisterTheme(CloseButton, "Panel3")
RegisterTheme(CloseButton, "Text")

--//========================================================
--// SIDEBAR
--//========================================================

local Sidebar = New("Frame", {
	Name = "Sidebar",

	Position = UDim2.fromOffset(0, 58),
	Size = UDim2.new(0, 164, 1, -58),

	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
})

Sidebar.Parent = MainFrame
RegisterTheme(Sidebar, "Panel")

local SidebarLine = New("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),

	Size = UDim2.new(0, 1, 1, 0),

	BackgroundColor3 = Theme.Stroke,
	BorderSizePixel = 0,
})

SidebarLine.Parent = Sidebar
RegisterTheme(SidebarLine, "Stroke")

local SidebarTitle = New("TextLabel", {
	Position = UDim2.fromOffset(18, 15),
	Size = UDim2.new(1, -36, 0, 18),

	BackgroundTransparency = 1,

	Text = "NAVIGATION",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.SubText,
})

SidebarTitle.Parent = Sidebar
RegisterTheme(SidebarTitle, "SubText")

local TabContainer = New("Frame", {
	Position = UDim2.fromOffset(10, 43),
	Size = UDim2.new(1, -20, 1, -100),

	BackgroundTransparency = 1,
})

TabContainer.Parent = Sidebar

local TabLayout = New("UIListLayout", {
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

TabLayout.Parent = TabContainer

local VersionText = New("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -15),

	Size = UDim2.new(1, -20, 0, 20),

	BackgroundTransparency = 1,

	Text = "v2.0 • Client",
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

VersionText.Parent = Sidebar
RegisterTheme(VersionText, "SubText")

--//========================================================
--// CONTENT
--//========================================================

local ContentHolder = New("Frame", {
	Name = "ContentHolder",

	Position = UDim2.fromOffset(164, 58),
	Size = UDim2.new(1, -164, 1, -58),

	BackgroundTransparency = 1,

	ClipsDescendants = true,
})

ContentHolder.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local Tabs = {
	{"Visuals", "◉"},
	{"Player", "●"},
	{"Game", "◆"},
	{"Hub", "⬢"},
	{"Misc", "✦"},
	{"Settings", "⚙"},
}

local function CreatePage(name)
	local page = New("ScrollingFrame", {
		Name = name .. "Page",

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,

		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		Visible = false,
	})

	Padding(page, 20, 20, 18, 24)

	local list = New("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	list.Parent = page

	page.Parent = ContentHolder

	Pages[name] = page

	return page
end

for _, tabData in ipairs(Tabs) do
	CreatePage(tabData[1])
end

--//========================================================
--// TAB SWITCHING
--//========================================================

local function SwitchTab(name)
	if not Pages[name] then
		return
	end

	Config.CurrentTab = name

	for tabName, page in pairs(Pages) do
		page.Visible = tabName == name
	end

	for tabName, button in pairs(TabButtons) do
		local active = tabName == name

		if active then
			Tween(button, 0.2, {
				BackgroundTransparency = 0,
				BackgroundColor3 = Theme.Panel3,
				TextColor3 = Theme.Text,
			})
		else
			Tween(button, 0.2, {
				BackgroundTransparency = 1,
				TextColor3 = Theme.SubText,
			})
		end

		local indicator = button:FindFirstChild("Indicator")

		if indicator then
			Tween(indicator, 0.2, {
				BackgroundTransparency = active and 0 or 1,
			})
		end
	end
end

for index, tabData in ipairs(Tabs) do
	local name = tabData[1]
	local icon = tabData[2]

	local button = New("TextButton", {
		Name = name .. "Tab",

		Size = UDim2.new(1, 0, 0, 43),

		BackgroundColor3 = Theme.Panel3,
		BackgroundTransparency = 1,

		AutoButtonColor = false,

		Text = "   " .. icon .. "    " .. name,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 12,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,

		LayoutOrder = index,
	})

	Corner(button, 11)

	local indicator = New("Frame", {
		Name = "Indicator",

		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),

		Size = UDim2.fromOffset(3, 22),

		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,

		BorderSizePixel = 0,
	})

	Corner(indicator, 3)

	indicator.Parent = button
	RegisterTheme(indicator, "Accent")

	button.Parent = TabContainer

	RegisterTheme(button, "Panel3")
	RegisterTheme(button, "SubText")

	TabButtons[name] = button

	button.MouseButton1Click:Connect(function()
		SwitchTab(name)
	end)
end

--//========================================================
--// UI COMPONENTS
--//========================================================

local function CreateSectionTitle(parent, title, description)
	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, description and 50 or 32),
		BackgroundTransparency = 1,
	})

	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = holder
	RegisterTheme(titleLabel, "Text")

	if description then
		local desc = New("TextLabel", {
			Position = UDim2.fromOffset(0, 25),
			Size = UDim2.new(1, 0, 0, 18),

			BackgroundTransparency = 1,

			Text = description,
			TextXAlignment = Enum.TextXAlignment.Left,

			TextSize = 11,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Theme.SubText,
		})

		desc.Parent = holder
		RegisterTheme(desc, "SubText")
	end

	holder.Parent = parent

	return holder
end

local function CreateCard(parent, height)
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 72),

		BackgroundColor3 = Theme.Panel2,
		BorderSizePixel = 0,

		ClipsDescendants = true,
	})

	Corner(card, 14)

	local cardStroke = Stroke(card, Theme.Stroke, 0.35, 1)

	card.Parent = parent

	RegisterTheme(card, "Panel2")
	RegisterTheme(cardStroke, "Stroke")

	return card
end

local function CreateToggle(parent, title, description, defaultValue, callback)
	local card = CreateCard(parent, 76)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -100, 0, 21),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card
	RegisterTheme(titleLabel, "Text")

	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(16, 36),
		Size = UDim2.new(1, -105, 0, 25),

		BackgroundTransparency = 1,

		Text = description or "",
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,

		TextSize = 10,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,
	})

	descLabel.Parent = card
	RegisterTheme(descLabel, "SubText")

	local toggle = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),

		Size = UDim2.fromOffset(54, 28),

		BackgroundColor3 = Theme.Panel3,

		AutoButtonColor = false,

		Text = "",
	})

	Corner(toggle, 14)

	toggle.Parent = card
	RegisterTheme(toggle, "Panel3")

	local knob = New("Frame", {
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.fromOffset(20, 20),

		BackgroundColor3 = Theme.SubText,
		BorderSizePixel = 0,
	})

	Corner(knob, 10)
	knob.Parent = toggle

	local value = defaultValue == true

	local function Render(instant)
		local targetPosition = value
			and UDim2.new(1, -24, 0, 4)
			or UDim2.fromOffset(4, 4)

		local targetToggleColor = value
			and Theme.Accent
			or Theme.Panel3

		local targetKnobColor = value
			and Color3.new(1, 1, 1)
			or Theme.SubText

		if instant then
			toggle.BackgroundColor3 = targetToggleColor
			knob.Position = targetPosition
			knob.BackgroundColor3 = targetKnobColor
		else
			Tween(toggle, 0.18, {
				BackgroundColor3 = targetToggleColor,
			})

			Tween(knob, 0.18, {
				Position = targetPosition,
				BackgroundColor3 = targetKnobColor,
			})
		end
	end

	local controller = {}

	function controller:Set(newValue, fireCallback)
		value = newValue == true
		Render(false)

		if fireCallback ~= false and callback then
			callback(value)
		end
	end

	function controller:Get()
		return value
	end

	function controller:Refresh()
		Render(true)
	end

	toggle.MouseButton1Click:Connect(function()
		controller:Set(not value, true)
	end)

	Render(true)

	return controller, card
end

local function CreateButtonCard(parent, title, description, buttonText, callback)
	local card = CreateCard(parent, 76)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -125, 0, 20),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 13,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card
	RegisterTheme(titleLabel, "Text")

	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(16, 37),
		Size = UDim2.new(1, -130, 0, 20),

		BackgroundTransparency = 1,

		Text = description or "",
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 10,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,
	})

	descLabel.Parent = card
	RegisterTheme(descLabel, "SubText")

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),

		Size = UDim2.fromOffset(86, 34),

		BackgroundColor3 = Theme.Panel3,
		AutoButtonColor = false,

		Text = buttonText,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	Corner(button, 10)

	local buttonStroke = Stroke(button, Theme.Stroke, 0.25, 1)

	button.Parent = card

	RegisterTheme(button, "Panel3")
	RegisterTheme(button, "Text")
	RegisterTheme(buttonStroke, "Stroke")

	button.MouseButton1Click:Connect(function()
		Tween(button, 0.08, {
			BackgroundTransparency = 0.25,
		})

		task.delay(0.09, function()
			if button.Parent then
				Tween(button, 0.12, {
					BackgroundTransparency = 0,
				})
			end
		end)

		if callback then
			callback(button)
		end
	end)

	return card, button
end

local function CreateSlider(parent, title, minimum, maximum, defaultValue, callback)
	local card = CreateCard(parent, 94)

	local value = math.clamp(defaultValue, minimum, maximum)
	local dragging = false

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -110, 0, 20),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card
	RegisterTheme(titleLabel, "Text")

	local valueLabel = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 12),

		Size = UDim2.fromOffset(80, 20),

		BackgroundTransparency = 1,

		Text = tostring(math.floor(value)),
		TextXAlignment = Enum.TextXAlignment.Right,

		TextSize = 12,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Accent,
	})

	valueLabel.Parent = card
	RegisterTheme(valueLabel, "Accent")

	local bar = New("Frame", {
		Position = UDim2.fromOffset(16, 56),
		Size = UDim2.new(1, -32, 0, 8),

		BackgroundColor3 = Theme.Panel3,
		BorderSizePixel = 0,

		Active = true,
	})

	Corner(bar, 4)
	bar.Parent = card

	RegisterTheme(bar, "Panel3")

	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),

		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	})

	Corner(fill, 4)

	fill.Parent = bar
	RegisterTheme(fill, "Accent")

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),

		Size = UDim2.fromOffset(18, 18),

		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	})

	Corner(knob, 9)

	local knobStroke = Stroke(knob, Theme.Accent, 0, 2)
	RegisterTheme(knobStroke, "Accent")

	knob.Parent = bar

	local controller = {}

	local function Render()
		local alpha = (value - minimum) / (maximum - minimum)

		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = tostring(math.floor(value + 0.5))
	end

	local function SetFromX(x)
		local absolutePosition = bar.AbsolutePosition.X
		local absoluteSize = bar.AbsoluteSize.X

		if absoluteSize <= 0 then
			return
		end

		local alpha = math.clamp(
			(x - absolutePosition) / absoluteSize,
			0,
			1
		)

		value = minimum + (maximum - minimum) * alpha
		value = math.floor(value + 0.5)

		Render()

		if callback then
			callback(value)
		end
	end

	function controller:Set(newValue, fireCallback)
		value = math.clamp(newValue, minimum, maximum)
		Render()

		if fireCallback ~= false and callback then
			callback(value)
		end
	end

	function controller:Get()
		return value
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			) then

			SetFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	Render()

	return controller, card
end

--//========================================================
--// PLAYER ESP
--//========================================================

local ESPHighlights = {}
local PlayerConnections = {}

local function RemoveESP(player)
	local highlight = ESPHighlights[player]

	if highlight then
		highlight:Destroy()
		ESPHighlights[player] = nil
	end
end

local function AddESP(player)
	if player == LocalPlayer then
		return
	end

	RemoveESP(player)

	local character = player.Character

	if not character then
		return
	end

	local highlight = New("Highlight", {
		Name = "AntiFreakESP",

		Adornee = character,

		FillColor = Config.ESPColor,
		FillTransparency = 0.62,

		OutlineColor = Config.ESPColor,
		OutlineTransparency = 0,

		DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
	})

	highlight.Parent = character
	ESPHighlights[player] = highlight
end

local function RefreshESPColor()
	for _, highlight in pairs(ESPHighlights) do
		if highlight and highlight.Parent then
			highlight.FillColor = Config.ESPColor
			highlight.OutlineColor = Config.ESPColor
		end
	end
end

local function SetESP(enabled)
	Config.ESPEnabled = enabled

	if enabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer then
				AddESP(player)
			end
		end
	else
		for player in pairs(ESPHighlights) do
			RemoveESP(player)
		end
	end
end

local function HookPlayer(player)
	if player == LocalPlayer then
		return
	end

	if PlayerConnections[player] then
		PlayerConnections[player]:Disconnect()
	end

	PlayerConnections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.5)

		if Config.ESPEnabled then
			AddESP(player)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	HookPlayer(player)
end

Players.PlayerAdded:Connect(HookPlayer)

Players.PlayerRemoving:Connect(function(player)
	RemoveESP(player)

	if PlayerConnections[player] then
		PlayerConnections[player]:Disconnect()
		PlayerConnections[player] = nil
	end
end)

--//========================================================
--// SPEED
--//========================================================

local StoredWalkSpeed = nil

local function ApplyWalkSpeed()
	local humanoid = GetHumanoid()

	if not humanoid then
		return
	end

	if Config.SpeedEnabled then
		humanoid.WalkSpeed = Config.WalkSpeed
	end
end

local function SetSpeedEnabled(enabled)
	Config.SpeedEnabled = enabled

	local humanoid = GetHumanoid()

	if not humanoid then
		return
	end

	if enabled then
		StoredWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = Config.WalkSpeed
	else
		humanoid.WalkSpeed = StoredWalkSpeed or Config.DefaultWalkSpeed
		StoredWalkSpeed = nil
	end
end

--//========================================================
--// FLY SYSTEM
--//========================================================

local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlyConnection = nil

local FlyUp = false
local FlyDown = false

local FlyKeys = {
	W = false,
	A = false,
	S = false,
	D = false,
}

local function DestroyFlyObjects()
	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if FlyBodyVelocity then
		FlyBodyVelocity:Destroy()
		FlyBodyVelocity = nil
	end

	if FlyBodyGyro then
		FlyBodyGyro:Destroy()
		FlyBodyGyro = nil
	end

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.AutoRotate = true
	end
end

local function StartFly()
	DestroyFlyObjects()

	local character = GetCharacter()
	local humanoid = GetHumanoid()
	local root = GetRoot()

	if not character or not humanoid or not root then
		Config.FlyEnabled = false
		return
	end

	humanoid.AutoRotate = false

	FlyBodyVelocity = New("BodyVelocity", {
		Name = "AntiFreakFlyVelocity",

		MaxForce = Vector3.new(
			math.huge,
			math.huge,
			math.huge
		),

		P = 9000,
		Velocity = Vector3.zero,
	})

	FlyBodyVelocity.Parent = root

	FlyBodyGyro = New("BodyGyro", {
		Name = "AntiFreakFlyGyro",

		MaxTorque = Vector3.new(
			math.huge,
			math.huge,
			math.huge
		),

		P = 25000,
		D = 700,

		CFrame = root.CFrame,
	})

	FlyBodyGyro.Parent = root

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not Config.FlyEnabled then
			return
		end

		if not root.Parent or humanoid.Health <= 0 then
			return
		end

		Camera = Workspace.CurrentCamera

		if not Camera then
			return
		end

		local direction = Vector3.zero

		-- Keyboard direction
		if FlyKeys.W then
			direction += Camera.CFrame.LookVector
		end

		if FlyKeys.S then
			direction -= Camera.CFrame.LookVector
		end

		if FlyKeys.D then
			direction += Camera.CFrame.RightVector
		end

		if FlyKeys.A then
			direction -= Camera.CFrame.RightVector
		end

		-- Mobile thumbstick
		if UserInputService.TouchEnabled then
			local moveDirection = humanoid.MoveDirection

			if moveDirection.Magnitude > 0.05 then
				direction = moveDirection
			end
		end

		if direction.Magnitude > 1 then
			direction = direction.Unit
		end

		local vertical = 0

		if FlyUp then
			vertical += 1
		end

		if FlyDown then
			vertical -= 1
		end

		local planar = Vector3.new(
			direction.X,
			0,
			direction.Z
		)

		local velocity = planar * Config.FlySpeed
			+ Vector3.new(
				0,
				vertical * Config.FlySpeed,
				0
			)

		FlyBodyVelocity.Velocity = velocity

		local lookVector = Camera.CFrame.LookVector

		local horizontalLook = Vector3.new(
			lookVector.X,
			0,
			lookVector.Z
		)

		if horizontalLook.Magnitude < 0.01 then
			horizontalLook = Vector3.new(
				root.CFrame.LookVector.X,
				0,
				root.CFrame.LookVector.Z
			)
		end

		horizontalLook = horizontalLook.Unit

		local targetCF = CFrame.lookAt(
			root.Position,
			root.Position + horizontalLook
		)

		if planar.Magnitude > 0.05 then
			targetCF *= CFrame.Angles(
				math.rad(-Config.FlyTilt),
				0,
				0
			)
		end

		FlyBodyGyro.CFrame = targetCF
	end)
end

local function SetFly(enabled)
	Config.FlyEnabled = enabled

	if enabled then
		StartFly()
	else
		DestroyFlyObjects()
	end
end

--//========================================================
--// TOUCH FLING
--//========================================================

local TouchFlingConnection = nil

local function StopTouchFling()
	if TouchFlingConnection then
		TouchFlingConnection:Disconnect()
		TouchFlingConnection = nil
	end

	local root = GetRoot()

	if root then
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function StartTouchFling()
	StopTouchFling()

	local root = GetRoot()

	if not root then
		return
	end

	TouchFlingConnection = RunService.Heartbeat:Connect(function()
		if not Config.TouchFlingEnabled then
			return
		end

		local currentRoot = GetRoot()

		if not currentRoot then
			return
		end

		local currentLinear = currentRoot.AssemblyLinearVelocity

		-- Strong local rotation while preserving controlled movement.
		currentRoot.AssemblyAngularVelocity = Vector3.new(
			0,
			95,
			0
		)

		if currentLinear.Magnitude > 140 then
			currentRoot.AssemblyLinearVelocity =
				currentLinear.Unit * 90
		end
	end)
end

local function SetTouchFling(enabled)
	Config.TouchFlingEnabled = enabled

	if enabled then
		StartTouchFling()
	else
		StopTouchFling()
	end
end

--//========================================================
--// ANTI FLING
--//========================================================

local AntiFlingConnection = nil
local CollisionCache = {}

local function RestoreOtherPlayerCollision()
	for part, oldState in pairs(CollisionCache) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = oldState
			end)
		end
	end

	table.clear(CollisionCache)
end

local function StopAntiFling()
	if AntiFlingConnection then
		AntiFlingConnection:Disconnect()
		AntiFlingConnection = nil
	end

	RestoreOtherPlayerCollision()
end

local function StartAntiFling()
	StopAntiFling()

	AntiFlingConnection = RunService.Heartbeat:Connect(function()
		if not Config.AntiFlingEnabled then
			return
		end

		local root = GetRoot()

		if root then
			local linearVelocity = root.AssemblyLinearVelocity
			local angularVelocity = root.AssemblyAngularVelocity

			if linearVelocity.Magnitude > 120 then
				root.AssemblyLinearVelocity = Vector3.zero
			end

			if angularVelocity.Magnitude > 80 then
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character then
				for _, object in ipairs(player.Character:GetDescendants()) do
					if object:IsA("BasePart") then
						if CollisionCache[object] == nil then
							CollisionCache[object] = object.CanCollide
						end

						object.CanCollide = false
					end
				end
			end
		end
	end)
end

local function SetAntiFling(enabled)
	Config.AntiFlingEnabled = enabled

	if enabled then
		StartAntiFling()
	else
		StopAntiFling()
	end
end

--//========================================================
--// FLIGHT TOUCH CONTROLS
--//========================================================

local FlightTouchGui = New("Frame", {
	Name = "FlightTouchControls",

	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -18, 0.5, 0),

	Size = UDim2.fromOffset(76, 158),

	BackgroundTransparency = 1,

	Visible = false,

	ZIndex = 60,
})

FlightTouchGui.Parent = ScreenGui

local UpButton = New("TextButton", {
	Size = UDim2.fromOffset(72, 72),

	BackgroundColor3 = Theme.Panel2,
	BackgroundTransparency = 0.12,

	AutoButtonColor = false,

	Text = "▲\nUP",
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 61,
})

Corner(UpButton, 20)

local upStroke = Stroke(UpButton, Theme.Accent, 0.2, 1.5)

UpButton.Parent = FlightTouchGui

RegisterTheme(UpButton, "Panel2")
RegisterTheme(UpButton, "Text")
RegisterTheme(upStroke, "Accent")

local DownButton = New("TextButton", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),

	Size = UDim2.fromOffset(72, 72),

	BackgroundColor3 = Theme.Panel2,
	BackgroundTransparency = 0.12,

	AutoButtonColor = false,

	Text = "▼\nDOWN",
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 61,
})

Corner(DownButton, 20)

local downStroke = Stroke(DownButton, Theme.Accent, 0.2, 1.5)

DownButton.Parent = FlightTouchGui

RegisterTheme(DownButton, "Panel2")
RegisterTheme(DownButton, "Text")
RegisterTheme(downStroke, "Accent")

local function BindHoldButton(button, callback)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			callback(true)

			Tween(button, 0.1, {
				BackgroundTransparency = 0,
			})
		end
	end)

	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			callback(false)

			Tween(button, 0.1, {
				BackgroundTransparency = 0.12,
			})
		end
	end)
end

BindHoldButton(UpButton, function(state)
	FlyUp = state
end)

BindHoldButton(DownButton, function(state)
	FlyDown = state
end)

--//========================================================
--// FLIGHT SETTINGS WINDOW
--//========================================================

local FlightSettings = New("Frame", {
	Name = "FlightSettings",

	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.fromOffset(330, 315),

	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,

	Visible = false,

	ZIndex = 70,
})

Corner(FlightSettings, 18)

local FlightSettingsStroke = Stroke(
	FlightSettings,
	Theme.Stroke,
	0.1,
	1
)

FlightSettings.Parent = ScreenGui

RegisterTheme(FlightSettings, "Background")
RegisterTheme(FlightSettingsStroke, "Stroke")

local FlightHeader = New("Frame", {
	Size = UDim2.new(1, 0, 0, 52),

	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,

	ZIndex = 71,
})

Corner(FlightHeader, 18)

FlightHeader.Parent = FlightSettings
RegisterTheme(FlightHeader, "Panel")

local FlightHeaderCover = New("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 0, 1, 0),

	Size = UDim2.new(1, 0, 0, 18),

	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
})

FlightHeaderCover.Parent = FlightHeader
RegisterTheme(FlightHeaderCover, "Panel")

local FlightTitle = New("TextLabel", {
	Position = UDim2.fromOffset(16, 0),
	Size = UDim2.new(1, -68, 1, 0),

	BackgroundTransparency = 1,

	Text = "Flight Settings",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 72,
})

FlightTitle.Parent = FlightHeader
RegisterTheme(FlightTitle, "Text")

local FlightClose = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),

	Size = UDim2.fromOffset(32, 32),

	BackgroundColor3 = Theme.Panel3,

	AutoButtonColor = false,

	Text = "X",
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 72,
})

Corner(FlightClose, 10)

FlightClose.Parent = FlightHeader

RegisterTheme(FlightClose, "Panel3")
RegisterTheme(FlightClose, "Text")

local FlightContent = New("Frame", {
	Position = UDim2.fromOffset(12, 64),
	Size = UDim2.new(1, -24, 1, -76),

	BackgroundTransparency = 1,

	ZIndex = 71,
})

FlightContent.Parent = FlightSettings

local FlightLayout = New("UIListLayout", {
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

FlightLayout.Parent = FlightContent

MakeDraggable(FlightSettings, FlightHeader)

FlightClose.MouseButton1Click:Connect(function()
	Tween(FlightSettings, 0.16, {
		BackgroundTransparency = 0.15,
	})

	task.delay(0.12, function()
		FlightSettings.Visible = false
		FlightSettings.BackgroundTransparency = 0
	end)
end)

--//========================================================
--// VISUALS PAGE
--//========================================================

local VisualsPage = Pages.Visuals

CreateSectionTitle(
	VisualsPage,
	"Visuals",
	"Client-side player rendering and appearance."
)

local ESPController = CreateToggle(
	VisualsPage,
	"Player ESP",
	"Highlights other players through walls.",
	Config.ESPEnabled,
	function(enabled)
		SetESP(enabled)
	end
)

--// ESP COLOR PICKER

local ColorCard = CreateCard(VisualsPage, 76)

local ColorTitle = New("TextLabel", {
	Position = UDim2.fromOffset(16, 12),
	Size = UDim2.new(1, -105, 0, 20),

	BackgroundTransparency = 1,

	Text = "ESP Color Spectrum",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

ColorTitle.Parent = ColorCard
RegisterTheme(ColorTitle, "Text")

local ColorDescription = New("TextLabel", {
	Position = UDim2.fromOffset(16, 36),
	Size = UDim2.new(1, -110, 0, 20),

	BackgroundTransparency = 1,

	Text = "Choose the highlight color.",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

ColorDescription.Parent = ColorCard
RegisterTheme(ColorDescription, "SubText")

local ColorPreview = New("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -54, 0.5, 0),

	Size = UDim2.fromOffset(26, 26),

	BackgroundColor3 = Config.ESPColor,
	BorderSizePixel = 0,
})

Corner(ColorPreview, 8)

local ColorPreviewStroke = Stroke(
	ColorPreview,
	Color3.new(1, 1, 1),
	0.6,
	1
)

ColorPreview.Parent = ColorCard

local ColorArrow = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -13, 0.5, 0),

	Size = UDim2.fromOffset(28, 28),

	BackgroundTransparency = 1,

	Text = "▼",
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.SubText,
})

ColorArrow.Parent = ColorCard
RegisterTheme(ColorArrow, "SubText")

local SpectrumHolder = New("Frame", {
	Position = UDim2.fromOffset(16, 75),
	Size = UDim2.new(1, -32, 0, 70),

	BackgroundTransparency = 1,
})

SpectrumHolder.Parent = ColorCard

local Spectrum = New("Frame", {
	Position = UDim2.fromOffset(0, 10),
	Size = UDim2.new(1, 0, 0, 34),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,

	Active = true,
})

Corner(Spectrum, 9)

local SpectrumStroke = Stroke(
	Spectrum,
	Theme.Stroke,
	0.25,
	1
)

SpectrumStroke.Parent = Spectrum

RegisterTheme(SpectrumStroke, "Stroke")

Spectrum.Parent = SpectrumHolder

local ColorPoints = {}

for i = 0, 12 do
	local hue = i / 12

	table.insert(
		ColorPoints,
		ColorSequenceKeypoint.new(
			hue,
			Color3.fromHSV(hue, 1, 1)
		)
	)
end

local SpectrumGradient = New("UIGradient", {
	Color = ColorSequence.new(ColorPoints),
})

SpectrumGradient.Parent = Spectrum

local SpectrumSelector = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.55, 0.5),

	Size = UDim2.fromOffset(5, 43),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
})

Corner(SpectrumSelector, 3)

local selectorStroke = Stroke(
	SpectrumSelector,
	Color3.fromRGB(0, 0, 0),
	0.4,
	1
)

selectorStroke.Parent = SpectrumSelector

SpectrumSelector.Parent = Spectrum

local SpectrumText = New("TextLabel", {
	Position = UDim2.fromOffset(0, 50),
	Size = UDim2.new(1, 0, 0, 18),

	BackgroundTransparency = 1,

	Text = "Drag to select color",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

SpectrumText.Parent = SpectrumHolder
RegisterTheme(SpectrumText, "SubText")

local SpectrumOpen = false
local SpectrumDragging = false

local function SetSpectrumOpen(state)
	SpectrumOpen = state

	ColorArrow.Text = state and "▲" or "▼"

	Tween(
		ColorCard,
		TweenInfo.new(
			0.28,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		{
			Size = state
				and UDim2.new(1, 0, 0, 155)
				or UDim2.new(1, 0, 0, 76),
		}
	)
end

ColorArrow.MouseButton1Click:Connect(function()
	SetSpectrumOpen(not SpectrumOpen)
end)

local function UpdateSpectrum(x)
	local position = Spectrum.AbsolutePosition.X
	local size = Spectrum.AbsoluteSize.X

	if size <= 0 then
		return
	end

	local alpha = math.clamp(
		(x - position) / size,
		0,
		1
	)

	Config.ESPColor = Color3.fromHSV(alpha, 0.9, 1)

	SpectrumSelector.Position = UDim2.fromScale(alpha, 0.5)
	ColorPreview.BackgroundColor3 = Config.ESPColor

	RefreshESPColor()
end

Spectrum.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SpectrumDragging = true
		UpdateSpectrum(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if SpectrumDragging
		and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then

		UpdateSpectrum(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SpectrumDragging = false
	end
end)

--//========================================================
--// PLAYER PAGE
--//========================================================

local PlayerPage = Pages.Player

CreateSectionTitle(
	PlayerPage,
	"Player",
	"Local character information and movement status."
)

local PlayerInfoCard = CreateCard(PlayerPage, 108)

local PlayerNameLabel = New("TextLabel", {
	Position = UDim2.fromOffset(16, 13),
	Size = UDim2.new(1, -32, 0, 20),

	BackgroundTransparency = 1,

	Text = "Player: " .. LocalPlayer.Name,
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 13,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

PlayerNameLabel.Parent = PlayerInfoCard
RegisterTheme(PlayerNameLabel, "Text")

local PlayerDisplayLabel = New("TextLabel", {
	Position = UDim2.fromOffset(16, 39),
	Size = UDim2.new(1, -32, 0, 18),

	BackgroundTransparency = 1,

	Text = "Display Name: " .. LocalPlayer.DisplayName,
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

PlayerDisplayLabel.Parent = PlayerInfoCard
RegisterTheme(PlayerDisplayLabel, "SubText")

local DeviceLabel = New("TextLabel", {
	Position = UDim2.fromOffset(16, 64),
	Size = UDim2.new(1, -32, 0, 18),

	BackgroundTransparency = 1,

	Text = UserInputService.TouchEnabled
		and "Input: Touch"
		or "Input: Keyboard / Mouse",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

DeviceLabel.Parent = PlayerInfoCard
RegisterTheme(DeviceLabel, "SubText")

local MovementLabel = New("TextLabel", {
	Position = UDim2.fromOffset(16, 86),
	Size = UDim2.new(1, -32, 0, 16),

	BackgroundTransparency = 1,

	Text = "WalkSpeed: 16",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.Accent,
})

MovementLabel.Parent = PlayerInfoCard
RegisterTheme(MovementLabel, "Accent")

RunService.RenderStepped:Connect(function()
	local humanoid = GetHumanoid()

	if humanoid and MovementLabel.Parent then
		MovementLabel.Text =
			"WalkSpeed: "
			.. tostring(math.floor(humanoid.WalkSpeed))
	end
end)

--//========================================================
--// GAME PAGE
--//========================================================

local GamePage = Pages.Game

CreateSectionTitle(
	GamePage,
	"Game",
	"Movement features and flight controls."
)

local FlyController, FlyCard = CreateToggle(
	GamePage,
	"Superhero Fly",
	"Camera-based flight with cinematic body tilt.",
	Config.FlyEnabled,
	function(enabled)
		SetFly(enabled)

		FlightTouchGui.Visible =
			enabled and UserInputService.TouchEnabled
	end
)

local FlightSettingsCard, FlightSettingsButton =
	CreateButtonCard(
		GamePage,
		"Flight Settings",
		"Adjust flight speed and body tilt.",
		"OPEN",
		function()
			FlightSettings.Visible = true
			FlightSettings.BackgroundTransparency = 0.15

			Tween(FlightSettings, 0.18, {
				BackgroundTransparency = 0,
			})
		end
	)

local SpeedController = CreateToggle(
	GamePage,
	"Speedhack",
	"Overrides the local character WalkSpeed.",
	Config.SpeedEnabled,
	function(enabled)
		SetSpeedEnabled(enabled)
	end
)

local SpeedSlider = CreateSlider(
	GamePage,
	"WalkSpeed",
	16,
	250,
	Config.WalkSpeed,
	function(value)
		Config.WalkSpeed = value

		if Config.SpeedEnabled then
			ApplyWalkSpeed()
		end
	end
)

--//========================================================
--// FLIGHT SETTINGS CONTENT
--//========================================================

local FlightWindowToggle = CreateToggle(
	FlightContent,
	"Flight",
	"Enable or disable flight.",
	Config.FlyEnabled,
	function(enabled)
		SetFly(enabled)
		FlyController:Set(enabled, false)

		FlightTouchGui.Visible =
			enabled and UserInputService.TouchEnabled
	end
)

local FlySpeedSlider = CreateSlider(
	FlightContent,
	"Flight Speed",
	10,
	300,
	Config.FlySpeed,
	function(value)
		Config.FlySpeed = value
	end
)

local FlyTiltSlider = CreateSlider(
	FlightContent,
	"Body Tilt",
	0,
	65,
	Config.FlyTilt,
	function(value)
		Config.FlyTilt = value
	end
)

--//========================================================
--// MISC PAGE
--//========================================================

local MiscPage = Pages.Misc

CreateSectionTitle(
	MiscPage,
	"Misc",
	"Local physics utilities and protection."
)

local TouchFlingController = CreateToggle(
	MiscPage,
	"Touch Fling",
	"Applies strong rotational physics to your character.",
	Config.TouchFlingEnabled,
	function(enabled)
		SetTouchFling(enabled)
	end
)

local AntiFlingController = CreateToggle(
	MiscPage,
	"Anti-Fling",
	"Reduces abnormal velocity and player collision impacts.",
	Config.AntiFlingEnabled,
	function(enabled)
		SetAntiFling(enabled)
	end
)

--//========================================================
--// HUB PAGE
--//========================================================

local HubPage = Pages.Hub

CreateSectionTitle(
	HubPage,
	"Hub",
	"Load dedicated game profiles."
)

local MM2Card = CreateCard(HubPage, 128)

local MM2Title = New("TextLabel", {
	Position = UDim2.fromOffset(16, 14),
	Size = UDim2.new(1, -120, 0, 22),

	BackgroundTransparency = 1,

	Text = "Murder Mystery 2",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 15,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

MM2Title.Parent = MM2Card
RegisterTheme(MM2Title, "Text")

local MM2ModeLabel = New("TextLabel", {
	Position = UDim2.fromOffset(16, 41),
	Size = UDim2.new(1, -120, 0, 18),

	BackgroundTransparency = 1,

	Text = "MM2 Mode",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.Accent,
})

MM2ModeLabel.Parent = MM2Card
RegisterTheme(MM2ModeLabel, "Accent")

local MM2Description = New("TextLabel", {
	Position = UDim2.fromOffset(16, 65),
	Size = UDim2.new(1, -32, 0, 45),

	BackgroundTransparency = 1,

	Text = "Loads the neon blue profile and temporarily disables active universal features.",
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,

	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

MM2Description.Parent = MM2Card
RegisterTheme(MM2Description, "SubText")

local MM2LoadButton = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 16),

	Size = UDim2.fromOffset(82, 36),

	BackgroundColor3 = Theme.Accent,

	AutoButtonColor = false,

	Text = "LOAD",
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.new(1, 1, 1),
})

Corner(MM2LoadButton, 11)

MM2LoadButton.Parent = MM2Card
RegisterTheme(MM2LoadButton, "Accent")

--//========================================================
--// SETTINGS PAGE
--//========================================================

local SettingsPage = Pages.Settings

CreateSectionTitle(
	SettingsPage,
	"Settings",
	"Interface preferences and utility controls."
)

local AnimationController = CreateToggle(
	SettingsPage,
	"Interface Animations",
	"Enable smooth menu transitions.",
	Config.Animations,
	function(enabled)
		Config.Animations = enabled
	end
)

CreateButtonCard(
	SettingsPage,
	"Reset Window Position",
	"Move the main interface back to the screen center.",
	"RESET",
	function()
		MainGroup.Position = UDim2.fromScale(0.5, 0.5)
	end
)

CreateButtonCard(
	SettingsPage,
	"Reset Open Button",
	"Move the floating button back to its default position.",
	"RESET",
	function()
		OpenButton.Position = UDim2.new(
			0,
			18,
			0.5,
			0
		)
	end
)

--//========================================================
--// STATE CONTROL
--//========================================================

local function SaveFeatureStates()
	SavedStates = {
		ESP = Config.ESPEnabled,
		Fly = Config.FlyEnabled,
		Speed = Config.SpeedEnabled,
		TouchFling = Config.TouchFlingEnabled,
		AntiFling = Config.AntiFlingEnabled,
	}
end

local function DisableAllFeatures()
	SetESP(false)
	SetFly(false)
	SetSpeedEnabled(false)
	SetTouchFling(false)
	SetAntiFling(false)

	ESPController:Set(false, false)
	FlyController:Set(false, false)
	FlightWindowToggle:Set(false, false)
	SpeedController:Set(false, false)
	TouchFlingController:Set(false, false)
	AntiFlingController:Set(false, false)

	FlightTouchGui.Visible = false
end

local function RestoreFeatureStates()
	if SavedStates.ESP then
		SetESP(true)
		ESPController:Set(true, false)
	end

	if SavedStates.Fly then
		SetFly(true)
		FlyController:Set(true, false)
		FlightWindowToggle:Set(true, false)

		FlightTouchGui.Visible =
			UserInputService.TouchEnabled
	end

	if SavedStates.Speed then
		SetSpeedEnabled(true)
		SpeedController:Set(true, false)
	end

	if SavedStates.TouchFling then
		SetTouchFling(true)
		TouchFlingController:Set(true, false)
	end

	if SavedStates.AntiFling then
		SetAntiFling(true)
		AntiFlingController:Set(true, false)
	end
end

local function EnterMM2Mode()
	if Config.MM2Mode then
		return
	end

	Config.MM2Mode = true

	SaveFeatureStates()
	DisableAllFeatures()

	Theme = Themes.MM2

	ApplyTheme()

	LogoBox.BackgroundColor3 = Theme.Accent
	MM2LoadButton.BackgroundColor3 = Theme.Accent

	Title.Text = "AntiFreak Hub • MM2"
	Subtitle.Text = "Murder Mystery 2 Profile"

	TabButtons.Hub.Visible = false

	LogoBox.Position = UDim2.fromOffset(62, 11)
	Title.Position = UDim2.fromOffset(110, 8)
	Subtitle.Position = UDim2.fromOffset(110, 30)

	BackButton.Visible = true

	if Config.CurrentTab == "Hub" then
		SwitchTab("Visuals")
	else
		SwitchTab(Config.CurrentTab)
	end
end

local function ExitMM2Mode()
	if not Config.MM2Mode then
		return
	end

	Config.MM2Mode = false

	Theme = Themes.Default

	ApplyTheme()

	Title.Text = "AntiFreak Hub"
	Subtitle.Text = "Universal Client Interface"

	BackButton.Visible = false
	TabButtons.Hub.Visible = true

	LogoBox.Position = UDim2.fromOffset(18, 11)
	Title.Position = UDim2.fromOffset(66, 8)
	Subtitle.Position = UDim2.fromOffset(66, 30)

	RestoreFeatureStates()

	SwitchTab("Hub")
end

MM2LoadButton.MouseButton1Click:Connect(EnterMM2Mode)
BackButton.MouseButton1Click:Connect(ExitMM2Mode)

--//========================================================
--// MENU ANIMATION
--//========================================================

local MenuAnimating = false

local function OpenMenu()
	if Config.MenuOpen or MenuAnimating then
		return
	end

	MenuAnimating = true
	Config.MenuOpen = true

	MainGroup.Visible = true

	if Config.Animations then
		MainScale.Scale = 0.88
		MainGroup.GroupTransparency = 1

		Tween(
			MainScale,
			TweenInfo.new(
				0.42,
				Enum.EasingStyle.Back,
				Enum.EasingDirection.Out
			),
			{
				Scale = 1,
			}
		)

		Tween(
			MainGroup,
			TweenInfo.new(
				0.28,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.Out
			),
			{
				GroupTransparency = 0,
			}
		)

		Tween(Blur, 0.25, {
			Size = 10,
		})

		task.delay(0.42, function()
			MenuAnimating = false
		end)
	else
		MainScale.Scale = 1
		MainGroup.GroupTransparency = 0
		Blur.Size = 10
		MenuAnimating = false
	end
end

local function CloseMenu()
	if not Config.MenuOpen or MenuAnimating then
		return
	end

	MenuAnimating = true
	Config.MenuOpen = false

	if Config.Animations then
		Tween(
			MainScale,
			TweenInfo.new(
				0.2,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.In
			),
			{
				Scale = 0.9,
			}
		)

		Tween(
			MainGroup,
			TweenInfo.new(
				0.18,
				Enum.EasingStyle.Quart,
				Enum.EasingDirection.In
			),
			{
				GroupTransparency = 1,
			}
		)

		Tween(Blur, 0.2, {
			Size = 0,
		})

		task.delay(0.2, function()
			MainGroup.Visible = false
			MainScale.Scale = 1
			MenuAnimating = false
		end)
	else
		MainGroup.Visible = false
		MainGroup.GroupTransparency = 1
		Blur.Size = 0
		MenuAnimating = false
	end
end

CloseButton.MouseButton1Click:Connect(CloseMenu)

-- Prevent dragging the floating button from accidentally opening menu.
local OpenButtonPressPosition = nil

OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		OpenButtonPressPosition = input.Position
	end
end)

OpenButton.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		if not OpenButtonPressPosition then
			return
		end

		local distance =
			(input.Position - OpenButtonPressPosition).Magnitude

		if distance < 10 then
			if Config.MenuOpen then
				CloseMenu()
			else
				OpenMenu()
			end
		end

		OpenButtonPressPosition = nil
	end
end)

--//========================================================
--// INPUT
--//========================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.W then
		FlyKeys.W = true

	elseif input.KeyCode == Enum.KeyCode.A then
		FlyKeys.A = true

	elseif input.KeyCode == Enum.KeyCode.S then
		FlyKeys.S = true

	elseif input.KeyCode == Enum.KeyCode.D then
		FlyKeys.D = true

	elseif input.KeyCode == Enum.KeyCode.Space then
		FlyUp = true

	elseif input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.LeftControl then

		FlyDown = true

	elseif input.KeyCode == Enum.KeyCode.RightShift then
		if Config.MenuOpen then
			CloseMenu()
		else
			OpenMenu()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then
		FlyKeys.W = false

	elseif input.KeyCode == Enum.KeyCode.A then
		FlyKeys.A = false

	elseif input.KeyCode == Enum.KeyCode.S then
		FlyKeys.S = false

	elseif input.KeyCode == Enum.KeyCode.D then
		FlyKeys.D = false

	elseif input.KeyCode == Enum.KeyCode.Space then
		FlyUp = false

	elseif input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.LeftControl then

		FlyDown = false
	end
end)

--//========================================================
--// CHARACTER RESPAWN
--//========================================================

LocalPlayer.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild(
		"Humanoid",
		10
	)

	character:WaitForChild(
		"HumanoidRootPart",
		10
	)

	task.wait(0.3)

	if humanoid then
		Config.DefaultWalkSpeed = humanoid.WalkSpeed
	end

	if Config.SpeedEnabled then
		ApplyWalkSpeed()
	end

	if Config.FlyEnabled then
		StartFly()

		FlightTouchGui.Visible =
			UserInputService.TouchEnabled
	end

	if Config.TouchFlingEnabled then
		StartTouchFling()
	end

	if Config.AntiFlingEnabled then
		StartAntiFling()
	end
end)

--//========================================================
--// RESPONSIVE UI
--//========================================================

local function UpdateResponsiveScale()
	Camera = Workspace.CurrentCamera

	if not Camera then
		return
	end

	local viewport = Camera.ViewportSize

	local horizontalScale =
		(viewport.X - 24) / 720

	local verticalScale =
		(viewport.Y - 24) / 460

	local scale = math.min(
		horizontalScale,
		verticalScale,
		1
	)

	scale = math.clamp(
		scale,
		0.56,
		1
	)

	MainScale.Scale = scale

	local flightScale =
		FlightSettings:FindFirstChildOfClass("UIScale")

	if not flightScale then
		flightScale = New("UIScale", {
			Scale = 1,
		})

		flightScale.Parent = FlightSettings
	end

	flightScale.Scale = math.clamp(
		math.min(
			(viewport.X - 20) / 350,
			(viewport.Y - 20) / 335,
			1
		),
		0.68,
		1
	)
end

UpdateResponsiveScale()

if Workspace.CurrentCamera then
	Workspace.CurrentCamera
		:GetPropertyChangedSignal("ViewportSize")
		:Connect(UpdateResponsiveScale)
end

Workspace:GetPropertyChangedSignal(
	"CurrentCamera"
):Connect(function()
	Camera = Workspace.CurrentCamera

	if Camera then
		UpdateResponsiveScale()

		Camera
			:GetPropertyChangedSignal("ViewportSize")
			:Connect(UpdateResponsiveScale)
	end
end)

--//========================================================
--// BUTTON HOVER / TOUCH EFFECTS
--//========================================================

local function AddButtonEffect(button)
	if not button:IsA("TextButton") then
		return
	end

	button.MouseEnter:Connect(function()
		if UserInputService.MouseEnabled then
			Tween(button, 0.14, {
				BackgroundTransparency =
					math.min(
						button.BackgroundTransparency + 0.08,
						0.25
					),
			})
		end
	end)

	button.MouseLeave:Connect(function()
		if UserInputService.MouseEnabled then
			Tween(button, 0.14, {
				BackgroundTransparency = 0,
			})
		end
	end)
end

for _, object in ipairs(ScreenGui:GetDescendants()) do
	if object:IsA("TextButton")
		and object ~= ColorArrow then

		AddButtonEffect(object)
	end
end

--//========================================================
--// INITIAL STATE
--//========================================================

SwitchTab("Visuals")

MainGroup.Visible = true
MainGroup.GroupTransparency = 0

Blur.Size = 10

FlightTouchGui.Visible =
	Config.FlyEnabled
	and UserInputService.TouchEnabled

ApplyTheme()

--//========================================================
--// STARTUP ANIMATION
--//========================================================

if Config.Animations then
	MainScale.Scale = MainScale.Scale * 0.88
	MainGroup.GroupTransparency = 1

	Tween(
		MainScale,
		TweenInfo.new(
			0.5,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.Out
		),
		{
			Scale = math.clamp(
				MainScale.Scale / 0.88,
				0.56,
				1
			),
		}
	)

	Tween(
		MainGroup,
		TweenInfo.new(
			0.3,
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.Out
		),
		{
			GroupTransparency = 0,
		}
	)
end

print("[AntiFreak Hub] Loaded successfully.")
