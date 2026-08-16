--[[
	AntiFreak Hub
	Compact Client UI
	LocalScript -> StarterPlayer > StarterPlayerScripts

	UI: English only
	Input: PC + Touch
]]

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- CLEANUP
--========================================================

local oldGui = PlayerGui:FindFirstChild("AntiFreakHub")
if oldGui then
	oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("AntiFreakBlur")
if oldBlur then
	oldBlur:Destroy()
end

--========================================================
-- CONFIG
--========================================================

local Config = {
	MenuOpen = true,
	CurrentTab = "Visuals",

	UIScale = 0.92,
	Animations = true,

	ESP = false,
	ESPColor = Color3.fromHSV(0.57, 0.82, 1),

	Fly = false,
	FlySpeed = 80,
	FlyTilt = 28,

	Speed = false,
	WalkSpeed = 32,

	ImpactSpin = false,
	AntiFling = false,

	MM2 = false,
}

local SavedState = {}

--========================================================
-- THEMES
--========================================================

local Themes = {
	Default = {
		Background = Color3.fromRGB(11, 13, 18),
		Sidebar = Color3.fromRGB(15, 18, 24),
		Panel = Color3.fromRGB(20, 23, 31),
		Panel2 = Color3.fromRGB(25, 29, 39),
		Panel3 = Color3.fromRGB(31, 36, 48),

		Accent = Color3.fromRGB(168, 88, 255),
		Accent2 = Color3.fromRGB(93, 123, 255),

		Text = Color3.fromRGB(245, 247, 255),
		SubText = Color3.fromRGB(143, 150, 170),

		Stroke = Color3.fromRGB(48, 54, 70),

		Success = Color3.fromRGB(70, 225, 140),
		Danger = Color3.fromRGB(255, 83, 109),
	},

	MM2 = {
		Background = Color3.fromRGB(4, 10, 18),
		Sidebar = Color3.fromRGB(5, 17, 29),
		Panel = Color3.fromRGB(7, 23, 39),
		Panel2 = Color3.fromRGB(8, 31, 52),
		Panel3 = Color3.fromRGB(10, 42, 68),

		Accent = Color3.fromRGB(0, 188, 255),
		Accent2 = Color3.fromRGB(0, 102, 255),

		Text = Color3.fromRGB(238, 250, 255),
		SubText = Color3.fromRGB(117, 170, 202),

		Stroke = Color3.fromRGB(22, 79, 113),

		Success = Color3.fromRGB(72, 235, 191),
		Danger = Color3.fromRGB(255, 78, 108),
	},
}

local Theme = Themes.Default
local ThemeBindings = {}
local Refreshers = {}

--========================================================
-- HELPERS
--========================================================

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

local function Padding(parent, l, r, t, b)
	local padding = New("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	})

	padding.Parent = parent
	return padding
end

local function Tween(object, duration, properties, style, direction)
	if not object then
		return nil
	end

	local info = TweenInfo.new(
		duration or 0.2,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(object, info, properties)
	tween:Play()

	return tween
end

local function BindTheme(object, bindings)
	ThemeBindings[object] = bindings
end

local function AddRefresher(callback)
	table.insert(Refreshers, callback)
end

local function ApplyTheme()
	for object, bindings in pairs(ThemeBindings) do
		if not object or not object.Parent then
			ThemeBindings[object] = nil
		else
			for property, themeKey in pairs(bindings) do
				pcall(function()
					object[property] = Theme[themeKey]
				end)
			end
		end
	end

	for _, refresher in ipairs(Refreshers) do
		pcall(refresher)
	end
end

local function GetCharacter()
	return LocalPlayer.Character
end

local function GetHumanoid()
	local character = GetCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
	local character = GetCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function AddPressAnimation(button)
	local scale = New("UIScale", {
		Scale = 1,
	})

	scale.Parent = button

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Tween(
				scale,
				0.09,
				{Scale = 0.94},
				Enum.EasingStyle.Quart
			)
		end
	end)

	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Tween(
				scale,
				0.18,
				{Scale = 1},
				Enum.EasingStyle.Back
			)
		end
	end)

	button.MouseEnter:Connect(function()
		if UserInputService.MouseEnabled then
			Tween(scale, 0.15, {Scale = 1.025})
		end
	end)

	button.MouseLeave:Connect(function()
		if UserInputService.MouseEnabled then
			Tween(scale, 0.15, {Scale = 1})
		end
	end)
end

local function MakeDraggable(frame, handle)
	handle = handle or frame

	local dragging = false
	local startInputPosition
	local startFramePosition
	local activeInput

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		startInputPosition = input.Position
		startFramePosition = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			activeInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= activeInput then
			return
		end

		local delta = input.Position - startInputPosition

		frame.Position = UDim2.new(
			startFramePosition.X.Scale,
			startFramePosition.X.Offset + delta.X,
			startFramePosition.Y.Scale,
			startFramePosition.Y.Offset + delta.Y
		)
	end)
end

--========================================================
-- GUI ROOT
--========================================================

local Gui = New("ScreenGui", {
	Name = "AntiFreakHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
})

Gui.Parent = PlayerGui

local Blur = New("BlurEffect", {
	Name = "AntiFreakBlur",
	Size = 7,
})

Blur.Parent = Lighting

--========================================================
-- FLOATING BUTTON
--========================================================

local OpenButton = New("TextButton", {
	Name = "OpenButton",

	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 16, 0.5, 0),
	Size = UDim2.fromOffset(48, 48),

	BackgroundColor3 = Theme.Panel2,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "⚡",
	TextSize = 22,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 50,
})

Corner(OpenButton, 16)

local OpenStroke = Stroke(
	OpenButton,
	Theme.Accent,
	0.08,
	1.4
)

OpenButton.Parent = Gui

BindTheme(OpenButton, {
	BackgroundColor3 = "Panel2",
	TextColor3 = "Text",
})

BindTheme(OpenStroke, {
	Color = "Accent",
})

AddPressAnimation(OpenButton)

local OpenButtonStart
local OpenButtonFrameStart
local OpenDragging = false
local OpenMoved = false

OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	OpenDragging = true
	OpenMoved = false

	OpenButtonStart = input.Position
	OpenButtonFrameStart = OpenButton.Position
end)

UserInputService.InputChanged:Connect(function(input)
	if not OpenDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	local delta = input.Position - OpenButtonStart

	if delta.Magnitude > 7 then
		OpenMoved = true
	end

	OpenButton.Position = UDim2.new(
		OpenButtonFrameStart.X.Scale,
		OpenButtonFrameStart.X.Offset + delta.X,
		OpenButtonFrameStart.Y.Scale,
		OpenButtonFrameStart.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		OpenDragging = false
	end
end)

--========================================================
-- MAIN WINDOW
--========================================================

local MainGroup = New("CanvasGroup", {
	Name = "MainGroup",

	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.fromOffset(620, 390),

	BackgroundTransparency = 1,

	GroupTransparency = 0,

	ZIndex = 10,
})

MainGroup.Parent = Gui

local MainScale = New("UIScale", {
	Scale = Config.UIScale,
})

MainScale.Parent = MainGroup

local MainFrame = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,

	ClipsDescendants = true,
})

Corner(MainFrame, 23)

local MainStroke = Stroke(
	MainFrame,
	Theme.Stroke,
	0.05,
	1.2
)

MainFrame.Parent = MainGroup

BindTheme(MainFrame, {
	BackgroundColor3 = "Background",
})

BindTheme(MainStroke, {
	Color = "Stroke",
})

--========================================================
-- TOP BAR
--========================================================

local TopBar = New("Frame", {
	Size = UDim2.new(1, 0, 0, 52),

	BackgroundColor3 = Theme.Sidebar,
	BorderSizePixel = 0,

	ZIndex = 4,
})

TopBar.Parent = MainFrame

BindTheme(TopBar, {
	BackgroundColor3 = "Sidebar",
})

local TopLine = New("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),

	Size = UDim2.new(1, 0, 0, 1),

	BackgroundColor3 = Theme.Stroke,
	BorderSizePixel = 0,
})

TopLine.Parent = TopBar

BindTheme(TopLine, {
	BackgroundColor3 = "Stroke",
})

local BackButton = New("TextButton", {
	Position = UDim2.fromOffset(10, 9),
	Size = UDim2.fromOffset(34, 34),

	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "<",
	TextSize = 18,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	Visible = false,

	ZIndex = 5,
})

Corner(BackButton, 11)
BackButton.Parent = TopBar
AddPressAnimation(BackButton)

BindTheme(BackButton, {
	BackgroundColor3 = "Panel3",
	TextColor3 = "Text",
})

local Logo = New("Frame", {
	Position = UDim2.fromOffset(13, 9),
	Size = UDim2.fromOffset(34, 34),

	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
})

Corner(Logo, 11)
Logo.Parent = TopBar

BindTheme(Logo, {
	BackgroundColor3 = "Accent",
})

local LogoText = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Text = "⚡",
	TextSize = 17,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.new(1, 1, 1),
})

LogoText.Parent = Logo

local Title = New("TextLabel", {
	Position = UDim2.fromOffset(57, 7),
	Size = UDim2.new(0, 220, 0, 21),

	BackgroundTransparency = 1,

	Text = "AntiFreak Hub",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 15,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

Title.Parent = TopBar

BindTheme(Title, {
	TextColor3 = "Text",
})

local Subtitle = New("TextLabel", {
	Position = UDim2.fromOffset(57, 27),
	Size = UDim2.new(0, 260, 0, 16),

	BackgroundTransparency = 1,

	Text = "Compact Universal Interface",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

Subtitle.Parent = TopBar

BindTheme(Subtitle, {
	TextColor3 = "SubText",
})

local CloseButton = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 9),
	Size = UDim2.fromOffset(34, 34),

	BackgroundColor3 = Theme.Panel3,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "X",
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

Corner(CloseButton, 11)
CloseButton.Parent = TopBar
AddPressAnimation(CloseButton)

BindTheme(CloseButton, {
	BackgroundColor3 = "Panel3",
	TextColor3 = "Text",
})

MakeDraggable(MainGroup, TopBar)

--========================================================
-- SIDEBAR
--========================================================

local Sidebar = New("Frame", {
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(0, 128, 1, -52),

	BackgroundColor3 = Theme.Sidebar,
	BorderSizePixel = 0,
})

Sidebar.Parent = MainFrame

BindTheme(Sidebar, {
	BackgroundColor3 = "Sidebar",
})

local SideLine = New("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),

	Size = UDim2.new(0, 1, 1, 0),

	BackgroundColor3 = Theme.Stroke,
	BorderSizePixel = 0,
})

SideLine.Parent = Sidebar

BindTheme(SideLine, {
	BackgroundColor3 = "Stroke",
})

local NavigationText = New("TextLabel", {
	Position = UDim2.fromOffset(13, 12),
	Size = UDim2.new(1, -26, 0, 14),

	BackgroundTransparency = 1,

	Text = "NAVIGATION",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.SubText,
})

NavigationText.Parent = Sidebar

BindTheme(NavigationText, {
	TextColor3 = "SubText",
})

local TabHolder = New("Frame", {
	Position = UDim2.fromOffset(8, 34),
	Size = UDim2.new(1, -16, 1, -68),

	BackgroundTransparency = 1,
})

TabHolder.Parent = Sidebar

local TabLayout = New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

TabLayout.Parent = TabHolder

local Version = New("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),

	Size = UDim2.new(1, -20, 0, 15),

	BackgroundTransparency = 1,

	Text = "v3.0",
	TextSize = 8,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

Version.Parent = Sidebar

BindTheme(Version, {
	TextColor3 = "SubText",
})

--========================================================
-- CONTENT
--========================================================

local Content = New("Frame", {
	Position = UDim2.fromOffset(128, 52),
	Size = UDim2.new(1, -128, 1, -52),

	BackgroundTransparency = 1,

	ClipsDescendants = true,
})

Content.Parent = MainFrame

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
	local group = New("CanvasGroup", {
		Name = name .. "Page",

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		GroupTransparency = 1,

		Visible = false,
	})

	group.Parent = Content

	local scroll = New("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,

		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
	})

	Padding(scroll, 14, 14, 13, 18)

	scroll.Parent = group

	local layout = New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	layout.Parent = scroll

	Pages[name] = {
		Group = group,
		Scroll = scroll,
	}

	return scroll
end

local VisualsPage = CreatePage("Visuals")
local PlayerPage = CreatePage("Player")
local GamePage = CreatePage("Game")
local HubPage = CreatePage("Hub")
local MiscPage = CreatePage("Misc")
local SettingsPage = CreatePage("Settings")

local Tabs = {
	{"Visuals", "◉"},
	{"Player", "●"},
	{"Game", "◆"},
	{"Hub", "⬢"},
	{"Misc", "✦"},
	{"Settings", "⚙"},
}

local PageAnimating = false

local function RefreshTabs()
	for name, button in pairs(TabButtons) do
		local active = name == Config.CurrentTab

		if active then
			button.BackgroundColor3 = Theme.Panel3
			button.BackgroundTransparency = 0
			button.TextColor3 = Theme.Text
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = Theme.SubText
		end

		local indicator = button:FindFirstChild("Indicator")

		if indicator then
			indicator.BackgroundColor3 = Theme.Accent
			indicator.BackgroundTransparency = active and 0 or 1
		end
	end
end

AddRefresher(RefreshTabs)

local function SwitchTab(name)
	if Config.MM2 then
		return
	end

	if not Pages[name] then
		return
	end

	Config.CurrentTab = name

	for pageName, data in pairs(Pages) do
		if pageName ~= name then
			data.Group.Visible = false
			data.Group.GroupTransparency = 1
		end
	end

	local selected = Pages[name]

	selected.Group.Visible = true
	selected.Group.GroupTransparency = 1
	selected.Group.Position = UDim2.fromOffset(10, 0)

	if Config.Animations then
		Tween(
			selected.Group,
			0.25,
			{
				GroupTransparency = 0,
				Position = UDim2.fromOffset(0, 0),
			},
			Enum.EasingStyle.Quart
		)
	else
		selected.Group.GroupTransparency = 0
		selected.Group.Position = UDim2.fromOffset(0, 0)
	end

	RefreshTabs()
end

for index, data in ipairs(Tabs) do
	local name = data[1]
	local icon = data[2]

	local button = New("TextButton", {
		Name = name,

		Size = UDim2.new(1, 0, 0, 35),

		BackgroundColor3 = Theme.Panel3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "  " .. icon .. "   " .. name,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 10,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,

		LayoutOrder = index,
	})

	Corner(button, 10)
	button.Parent = TabHolder

	local indicator = New("Frame", {
		Name = "Indicator",

		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),

		Size = UDim2.fromOffset(3, 17),

		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,

		BorderSizePixel = 0,
	})

	Corner(indicator, 3)
	indicator.Parent = button

	AddPressAnimation(button)

	TabButtons[name] = button

	button.MouseButton1Click:Connect(function()
		SwitchTab(name)
	end)
end

--========================================================
-- COMPONENTS
--========================================================

local function CreateSection(parent, title, description)
	local height = description and 39 or 25

	local holder = New("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
	})

	holder.Parent = parent

	local titleLabel = New("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = holder

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	if description then
		local desc = New("TextLabel", {
			Position = UDim2.fromOffset(0, 21),
			Size = UDim2.new(1, 0, 0, 14),

			BackgroundTransparency = 1,

			Text = description,
			TextXAlignment = Enum.TextXAlignment.Left,

			TextSize = 9,
			Font = Enum.Font.GothamMedium,
			TextColor3 = Theme.SubText,
		})

		desc.Parent = holder

		BindTheme(desc, {
			TextColor3 = "SubText",
		})
	end

	return holder
end

local function CreateCard(parent, height)
	local card = New("Frame", {
		Size = UDim2.new(1, 0, 0, height or 58),

		BackgroundColor3 = Theme.Panel,
		BorderSizePixel = 0,

		ClipsDescendants = true,
	})

	Corner(card, 14)

	local stroke = Stroke(
		card,
		Theme.Stroke,
		0.35,
		1
	)

	card.Parent = parent

	BindTheme(card, {
		BackgroundColor3 = "Panel",
	})

	BindTheme(stroke, {
		Color = "Stroke",
	})

	return card
end

local function CreateToggle(parent, title, description, value, callback)
	local card = CreateCard(parent, 58)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 9),
		Size = UDim2.new(1, -88, 0, 18),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -90, 0, 16),

		BackgroundTransparency = 1,

		Text = description or "",
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 8,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,
	})

	descLabel.Parent = card

	BindTheme(descLabel, {
		TextColor3 = "SubText",
	})

	local switch = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),

		Size = UDim2.fromOffset(46, 24),

		BackgroundColor3 = Theme.Panel3,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "",
	})

	Corner(switch, 12)
	switch.Parent = card

	local knob = New("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.fromOffset(18, 18),

		BackgroundColor3 = Theme.SubText,
		BorderSizePixel = 0,
	})

	Corner(knob, 9)
	knob.Parent = switch

	local controller = {}

	local function Render(animated)
		local switchColor = value and Theme.Accent or Theme.Panel3
		local knobColor = value and Color3.new(1, 1, 1) or Theme.SubText

		local knobPosition

		if value then
			knobPosition = UDim2.new(1, -21, 0, 3)
		else
			knobPosition = UDim2.fromOffset(3, 3)
		end

		if animated then
			Tween(switch, 0.2, {
				BackgroundColor3 = switchColor,
			})

			Tween(
				knob,
				0.24,
				{
					Position = knobPosition,
					BackgroundColor3 = knobColor,
				},
				Enum.EasingStyle.Back
			)
		else
			switch.BackgroundColor3 = switchColor
			knob.BackgroundColor3 = knobColor
			knob.Position = knobPosition
		end
	end

	function controller:Set(newValue, fireCallback)
		value = newValue == true

		Render(true)

		if fireCallback ~= false and callback then
			callback(value)
		end
	end

	function controller:Get()
		return value
	end

	AddRefresher(function()
		Render(false)
	end)

	switch.MouseButton1Click:Connect(function()
		controller:Set(not value, true)
	end)

	AddPressAnimation(switch)
	Render(false)

	return controller, card
end

local function CreateSlider(
	parent,
	title,
	minimum,
	maximum,
	defaultValue,
	callback,
	suffix
)
	local card = CreateCard(parent, 68)

	local value = math.clamp(defaultValue, minimum, maximum)
	local dragging = false

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 9),
		Size = UDim2.new(1, -90, 0, 17),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	local valueLabel = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, 9),

		Size = UDim2.fromOffset(75, 17),

		BackgroundTransparency = 1,

		TextXAlignment = Enum.TextXAlignment.Right,

		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Accent,
	})

	valueLabel.Parent = card

	local bar = New("Frame", {
		Position = UDim2.fromOffset(13, 42),
		Size = UDim2.new(1, -26, 0, 7),

		BackgroundColor3 = Theme.Panel3,
		BorderSizePixel = 0,

		Active = true,
	})

	Corner(bar, 5)
	bar.Parent = card

	BindTheme(bar, {
		BackgroundColor3 = "Panel3",
	})

	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),

		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	})

	Corner(fill, 5)
	fill.Parent = bar

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),

		Size = UDim2.fromOffset(15, 15),

		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	})

	Corner(knob, 8)

	local knobStroke = Stroke(
		knob,
		Theme.Accent,
		0,
		1.5
	)

	knob.Parent = bar

	local controller = {}

	local function Render()
		local alpha = (value - minimum) / (maximum - minimum)

		fill.BackgroundColor3 = Theme.Accent
		knobStroke.Color = Theme.Accent

		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)

		valueLabel.Text =
			tostring(math.floor(value + 0.5))
			.. (suffix or "")

		valueLabel.TextColor3 = Theme.Accent
	end

	local function UpdateFromX(x)
		local width = bar.AbsoluteSize.X

		if width <= 0 then
			return
		end

		local alpha = math.clamp(
			(x - bar.AbsolutePosition.X) / width,
			0,
			1
		)

		value = minimum + ((maximum - minimum) * alpha)
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

	AddRefresher(Render)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			UpdateFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			UpdateFromX(input.Position.X)
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

local function CreateAction(parent, title, description, text, callback)
	local card = CreateCard(parent, 58)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 9),
		Size = UDim2.new(1, -105, 0, 18),

		BackgroundTransparency = 1,

		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 11,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	local descLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),
		Size = UDim2.new(1, -110, 0, 15),

		BackgroundTransparency = 1,

		Text = description or "",
		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 8,
		Font = Enum.Font.GothamMedium,
		TextColor3 = Theme.SubText,
	})

	descLabel.Parent = card

	BindTheme(descLabel, {
		TextColor3 = "SubText",
	})

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -13, 0.5, 0),

		Size = UDim2.fromOffset(72, 30),

		BackgroundColor3 = Theme.Panel3,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = text,
		TextSize = 9,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,
	})

	Corner(button, 10)
	button.Parent = card

	BindTheme(button, {
		BackgroundColor3 = "Panel3",
		TextColor3 = "Text",
	})

	AddPressAnimation(button)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback(button)
		end
	end)

	return card, button
end

--========================================================
-- ESP
--========================================================

local ESPHighlights = {}
local ESPConnections = {}

local function RemoveESP(player)
	local highlight = ESPHighlights[player]

	if highlight then
		highlight:Destroy()
	end

	ESPHighlights[player] = nil
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
		FillTransparency = 0.67,

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

local function SetESP(state)
	Config.ESP = state

	if state then
		for _, player in ipairs(Players:GetPlayers()) do
			AddESP(player)
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

	if ESPConnections[player] then
		ESPConnections[player]:Disconnect()
	end

	ESPConnections[player] = player.CharacterAdded:Connect(function()
		task.wait(0.3)

		if Config.ESP then
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

	if ESPConnections[player] then
		ESPConnections[player]:Disconnect()
	end

	ESPConnections[player] = nil
end)

--========================================================
-- SPEED
--========================================================

local StoredWalkSpeed = nil

local function SetSpeed(state)
	Config.Speed = state

	local humanoid = GetHumanoid()

	if not humanoid then
		return
	end

	if state then
		StoredWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = Config.WalkSpeed
	else
		humanoid.WalkSpeed = StoredWalkSpeed or 16
		StoredWalkSpeed = nil
	end
end

local function RefreshSpeed()
	if not Config.Speed then
		return
	end

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.WalkSpeed = Config.WalkSpeed
	end
end

--========================================================
-- SUPERHERO FLY
--========================================================

local FlyAttachment
local FlyVelocity
local FlyOrientation
local FlyConnection

local FlyUp = false
local FlyDown = false

local PoseJoints = {}

local function FindMotor(parent, name)
	if not parent then
		return nil
	end

	local motor = parent:FindFirstChild(name)

	if motor and motor:IsA("Motor6D") then
		return motor
	end

	return nil
end

local function SetupPoseJoints()
	table.clear(PoseJoints)

	local character = GetCharacter()

	if not character then
		return
	end

	local upperTorso = character:FindFirstChild("UpperTorso")
	local torso = character:FindFirstChild("Torso")

	if upperTorso then
		PoseJoints.RightShoulder =
			FindMotor(upperTorso, "RightShoulder")

		PoseJoints.LeftShoulder =
			FindMotor(upperTorso, "LeftShoulder")

		PoseJoints.Waist =
			FindMotor(upperTorso, "Waist")

		PoseJoints.Neck =
			FindMotor(
				character:FindFirstChild("Head"),
				"Neck"
			)
			or FindMotor(upperTorso, "Neck")
	elseif torso then
		PoseJoints.RightShoulder =
			FindMotor(torso, "Right Shoulder")

		PoseJoints.LeftShoulder =
			FindMotor(torso, "Left Shoulder")

		PoseJoints.Neck =
			FindMotor(torso, "Neck")
	end
end

local function ResetFlyPose()
	for _, motor in pairs(PoseJoints) do
		if motor and motor.Parent then
			motor.Transform = CFrame.new()
		end
	end
end

local function ApplySuperheroPose(timeValue)
	local bob = math.sin(timeValue * 5) * 3

	local right = PoseJoints.RightShoulder
	local left = PoseJoints.LeftShoulder
	local waist = PoseJoints.Waist
	local neck = PoseJoints.Neck

	if right then
		right.Transform =
			CFrame.Angles(
				math.rad(-118 + bob),
				math.rad(-4),
				math.rad(12)
			)
	end

	if left then
		left.Transform =
			CFrame.Angles(
				math.rad(-118 - bob),
				math.rad(4),
				math.rad(-12)
			)
	end

	if waist then
		waist.Transform =
			CFrame.Angles(
				math.rad(-7),
				0,
				math.rad(math.sin(timeValue * 2) * 2)
			)
	end

	if neck then
		neck.Transform =
			CFrame.Angles(
				math.rad(8),
				0,
				0
			)
	end
end

local function DestroyFly()
	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	ResetFlyPose()

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyOrientation then
		FlyOrientation:Destroy()
		FlyOrientation = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.AutoRotate = true
	end
end

local function StartFly()
	DestroyFly()

	local humanoid = GetHumanoid()
	local root = GetRoot()

	if not humanoid or not root then
		Config.Fly = false
		return
	end

	SetupPoseJoints()

	humanoid.AutoRotate = false

	FlyAttachment = New("Attachment", {
		Name = "AntiFreakFlyAttachment",
	})

	FlyAttachment.Parent = root

	FlyVelocity = New("LinearVelocity", {
		Name = "AntiFreakFlyVelocity",

		Attachment0 = FlyAttachment,

		RelativeTo = Enum.ActuatorRelativeTo.World,

		VelocityConstraintMode =
			Enum.VelocityConstraintMode.Vector,

		VectorVelocity = Vector3.zero,

		MaxForce = math.huge,
	})

	FlyVelocity.Parent = root

	FlyOrientation = New("AlignOrientation", {
		Name = "AntiFreakFlyOrientation",

		Attachment0 = FlyAttachment,

		Mode = Enum.OrientationAlignmentMode.OneAttachment,

		RigidityEnabled = false,

		Responsiveness = 30,

		MaxTorque = math.huge,
		MaxAngularVelocity = math.huge,
	})

	FlyOrientation.Parent = root

	local startTime = os.clock()

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not Config.Fly then
			return
		end

		local currentHumanoid = GetHumanoid()
		local currentRoot = GetRoot()
		local camera = Workspace.CurrentCamera

		if not currentHumanoid
			or not currentRoot
			or not camera then
			return
		end

		local moveDirection = currentHumanoid.MoveDirection
		local direction = Vector3.zero

		if moveDirection.Magnitude > 0.05 then
			direction = moveDirection.Unit
		end

		local vertical = 0

		if FlyUp then
			vertical += 1
		end

		if FlyDown then
			vertical -= 1
		end

		local velocity =
			direction * Config.FlySpeed
			+ Vector3.new(
				0,
				vertical * Config.FlySpeed,
				0
			)

		FlyVelocity.VectorVelocity = velocity

		local facing

		if direction.Magnitude > 0.05 then
			facing = Vector3.new(
				direction.X,
				0,
				direction.Z
			)
		else
			facing = Vector3.new(
				camera.CFrame.LookVector.X,
				0,
				camera.CFrame.LookVector.Z
			)
		end

		if facing.Magnitude < 0.01 then
			facing = currentRoot.CFrame.LookVector
		else
			facing = facing.Unit
		end

		local moving = direction.Magnitude > 0.05
			or vertical ~= 0

		local tilt = moving and Config.FlyTilt or 3

		local roll = 0

		if moving then
			local rightDot =
				camera.CFrame.RightVector:Dot(direction)

			roll = -rightDot * 9
		end

		local target =
			CFrame.lookAt(
				Vector3.zero,
				facing
			)
			* CFrame.Angles(
				math.rad(-tilt),
				0,
				math.rad(roll)
			)

		FlyOrientation.CFrame = target

		ApplySuperheroPose(os.clock() - startTime)
	end)
end

local function SetFly(state)
	Config.Fly = state

	if state then
		StartFly()
	else
		DestroyFly()
	end
end

--========================================================
-- LOCAL IMPACT SPIN
--========================================================

local SpinConnection
local SpinCollisionCache = {}

local function StopImpactSpin()
	if SpinConnection then
		SpinConnection:Disconnect()
		SpinConnection = nil
	end

	for part, state in pairs(SpinCollisionCache) do
		if part and part.Parent then
			part.CanCollide = state
		end
	end

	table.clear(SpinCollisionCache)

	local root = GetRoot()

	if root then
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function StartImpactSpin()
	StopImpactSpin()

	local character = GetCharacter()

	if not character then
		return
	end

	for _, object in ipairs(character:GetDescendants()) do
		if object:IsA("BasePart") then
			SpinCollisionCache[object] = object.CanCollide
		end
	end

	SpinConnection = RunService.Heartbeat:Connect(function()
		if not Config.ImpactSpin then
			return
		end

		local root = GetRoot()

		if not root then
			return
		end

		root.AssemblyAngularVelocity =
			Vector3.new(
				0,
				42,
				0
			)

		if root.AssemblyLinearVelocity.Magnitude > 100 then
			root.AssemblyLinearVelocity =
				root.AssemblyLinearVelocity.Unit * 65
		end
	end)
end

local function SetImpactSpin(state)
	Config.ImpactSpin = state

	if state then
		StartImpactSpin()
	else
		StopImpactSpin()
	end
end

--========================================================
-- ANTI FLING
--========================================================

local AntiFlingConnection
local CollisionCache = {}

local function StopAntiFling()
	if AntiFlingConnection then
		AntiFlingConnection:Disconnect()
		AntiFlingConnection = nil
	end

	for part, state in pairs(CollisionCache) do
		if part and part.Parent then
			part.CanCollide = state
		end
	end

	table.clear(CollisionCache)
end

local function StartAntiFling()
	StopAntiFling()

	AntiFlingConnection = RunService.Heartbeat:Connect(function()
		if not Config.AntiFling then
			return
		end

		local root = GetRoot()

		if root then
			local linear =
				root.AssemblyLinearVelocity

			local angular =
				root.AssemblyAngularVelocity

			if linear.Magnitude > 115 then
				root.AssemblyLinearVelocity =
					Vector3.zero
			end

			if angular.Magnitude > 75 then
				root.AssemblyAngularVelocity =
					Vector3.zero
			end
		end

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer
				and player.Character then

				for _, object in ipairs(
					player.Character:GetDescendants()
				) do
					if object:IsA("BasePart") then
						if CollisionCache[object] == nil then
							CollisionCache[object] =
								object.CanCollide
						end

						object.CanCollide = false
					end
				end
			end
		end
	end)
end

local function SetAntiFling(state)
	Config.AntiFling = state

	if state then
		StartAntiFling()
	else
		StopAntiFling()
	end
end

--========================================================
-- VISUALS PAGE
--========================================================

CreateSection(
	VisualsPage,
	"Visuals",
	"Player rendering and highlight customization."
)

local ESPToggle = CreateToggle(
	VisualsPage,
	"Player ESP",
	"Highlight players through geometry.",
	Config.ESP,
	SetESP
)

--========================================================
-- ADVANCED ESP COLOR PICKER
--========================================================

local PickerCard = CreateCard(VisualsPage, 58)

local PickerTitle = New("TextLabel", {
	Position = UDim2.fromOffset(13, 9),
	Size = UDim2.new(1, -100, 0, 18),

	BackgroundTransparency = 1,

	Text = "ESP Color Picker",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

PickerTitle.Parent = PickerCard

BindTheme(PickerTitle, {
	TextColor3 = "Text",
})

local PickerDescription = New("TextLabel", {
	Position = UDim2.fromOffset(13, 29),
	Size = UDim2.new(1, -110, 0, 15),

	BackgroundTransparency = 1,

	Text = "Hue, saturation and brightness.",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

PickerDescription.Parent = PickerCard

BindTheme(PickerDescription, {
	TextColor3 = "SubText",
})

local ColorPreview = New("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -47, 0.5, 0),

	Size = UDim2.fromOffset(23, 23),

	BackgroundColor3 = Config.ESPColor,
	BorderSizePixel = 0,
})

Corner(ColorPreview, 7)
ColorPreview.Parent = PickerCard

local PreviewStroke = Stroke(
	ColorPreview,
	Color3.new(1, 1, 1),
	0.55,
	1
)

local PickerArrow = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -10, 0.5, 0),

	Size = UDim2.fromOffset(25, 25),

	BackgroundTransparency = 1,

	Text = "▼",
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.SubText,
})

PickerArrow.Parent = PickerCard

BindTheme(PickerArrow, {
	TextColor3 = "SubText",
})

local PickerContent = New("Frame", {
	Position = UDim2.fromOffset(13, 62),
	Size = UDim2.new(1, -26, 0, 144),

	BackgroundTransparency = 1,
})

PickerContent.Parent = PickerCard

local SVBox = New("Frame", {
	Size = UDim2.new(1, 0, 0, 92),

	BackgroundColor3 = Color3.fromHSV(0.57, 1, 1),
	BorderSizePixel = 0,

	Active = true,
})

Corner(SVBox, 9)
SVBox.Parent = PickerContent

local WhiteGradient = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
})

Corner(WhiteGradient, 9)
WhiteGradient.Parent = SVBox

local WhiteUIGradient = New("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
})

WhiteUIGradient.Parent = WhiteGradient

local BlackGradient = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
})

Corner(BlackGradient, 9)
BlackGradient.Parent = SVBox

local BlackUIGradient = New("UIGradient", {
	Rotation = 90,

	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	}),
})

BlackUIGradient.Parent = BlackGradient

local SVMarker = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(0.82, 0),

	Size = UDim2.fromOffset(12, 12),

	BackgroundTransparency = 1,
})

local SVMarkerStroke = Stroke(
	SVMarker,
	Color3.new(1, 1, 1),
	0,
	2
)

Corner(SVMarker, 6)
SVMarker.Parent = SVBox

local HueBar = New("Frame", {
	Position = UDim2.new(0, 0, 0, 104),
	Size = UDim2.new(1, 0, 0, 15),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,

	Active = true,
})

Corner(HueBar, 7)
HueBar.Parent = PickerContent

local HuePoints = {}

for i = 0, 12 do
	local hue = i / 12

	table.insert(
		HuePoints,
		ColorSequenceKeypoint.new(
			hue,
			Color3.fromHSV(hue, 1, 1)
		)
	)
end

local HueGradient = New("UIGradient", {
	Color = ColorSequence.new(HuePoints),
})

HueGradient.Parent = HueBar

local HueMarker = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(0.57, 0.5),

	Size = UDim2.fromOffset(5, 21),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
})

Corner(HueMarker, 3)

Stroke(
	HueMarker,
	Color3.new(0, 0, 0),
	0.45,
	1
)

HueMarker.Parent = HueBar

local ColorInfo = New("TextLabel", {
	Position = UDim2.new(0, 0, 0, 125),
	Size = UDim2.new(1, 0, 0, 15),

	BackgroundTransparency = 1,

	Text = "Full HSV Spectrum",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

ColorInfo.Parent = PickerContent

BindTheme(ColorInfo, {
	TextColor3 = "SubText",
})

local pickerOpen = false

local Hue = 0.57
local Saturation = 0.82
local Value = 1

local hueDragging = false
local svDragging = false

local function UpdatePickedColor()
	Config.ESPColor =
		Color3.fromHSV(
			Hue,
			Saturation,
			Value
		)

	ColorPreview.BackgroundColor3 =
		Config.ESPColor

	SVBox.BackgroundColor3 =
		Color3.fromHSV(
			Hue,
			1,
			1
		)

	RefreshESPColor()
end

local function UpdateHue(x)
	local width = HueBar.AbsoluteSize.X

	if width <= 0 then
		return
	end

	Hue = math.clamp(
		(x - HueBar.AbsolutePosition.X)
			/ width,
		0,
		1
	)

	HueMarker.Position =
		UDim2.fromScale(Hue, 0.5)

	UpdatePickedColor()
end

local function UpdateSV(position)
	local size = SVBox.AbsoluteSize

	if size.X <= 0 or size.Y <= 0 then
		return
	end

	local x = math.clamp(
		(position.X - SVBox.AbsolutePosition.X)
			/ size.X,
		0,
		1
	)

	local y = math.clamp(
		(position.Y - SVBox.AbsolutePosition.Y)
			/ size.Y,
		0,
		1
	)

	Saturation = x
	Value = 1 - y

	SVMarker.Position =
		UDim2.fromScale(x, y)

	UpdatePickedColor()
end

HueBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		hueDragging = true
		UpdateHue(input.Position.X)
	end
end)

SVBox.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		svDragging = true
		UpdateSV(input.Position)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if hueDragging then
		UpdateHue(input.Position.X)
	end

	if svDragging then
		UpdateSV(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		hueDragging = false
		svDragging = false
	end
end)

local function SetPickerOpen(state)
	pickerOpen = state

	PickerArrow.Text =
		state and "▲" or "▼"

	local targetHeight =
		state and 216 or 58

	if Config.Animations then
		Tween(
			PickerCard,
			0.32,
			{
				Size = UDim2.new(
					1,
					0,
					0,
					targetHeight
				),
			},
			Enum.EasingStyle.Back
		)
	else
		PickerCard.Size =
			UDim2.new(
				1,
				0,
				0,
				targetHeight
			)
	end
end

PickerArrow.MouseButton1Click:Connect(function()
	SetPickerOpen(not pickerOpen)
end)

AddPressAnimation(PickerArrow)

--========================================================
-- PLAYER PAGE
--========================================================

CreateSection(
	PlayerPage,
	"Player",
	"Local character and device information."
)

local InfoCard = CreateCard(PlayerPage, 94)

local PlayerName = New("TextLabel", {
	Position = UDim2.fromOffset(13, 10),
	Size = UDim2.new(1, -26, 0, 17),

	BackgroundTransparency = 1,

	Text = "Player: " .. LocalPlayer.Name,
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 11,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

PlayerName.Parent = InfoCard

BindTheme(PlayerName, {
	TextColor3 = "Text",
})

local DisplayName = New("TextLabel", {
	Position = UDim2.fromOffset(13, 31),
	Size = UDim2.new(1, -26, 0, 15),

	BackgroundTransparency = 1,

	Text = "Display Name: " .. LocalPlayer.DisplayName,
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

DisplayName.Parent = InfoCard

BindTheme(DisplayName, {
	TextColor3 = "SubText",
})

local Device = New("TextLabel", {
	Position = UDim2.fromOffset(13, 51),
	Size = UDim2.new(1, -26, 0, 15),

	BackgroundTransparency = 1,

	Text = UserInputService.TouchEnabled
		and "Input: Touch"
		or "Input: Keyboard / Mouse",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

Device.Parent = InfoCard

BindTheme(Device, {
	TextColor3 = "SubText",
})

local MovementInfo = New("TextLabel", {
	Position = UDim2.fromOffset(13, 71),
	Size = UDim2.new(1, -26, 0, 14),

	BackgroundTransparency = 1,

	Text = "WalkSpeed: 16",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Accent,
})

MovementInfo.Parent = InfoCard

RunService.RenderStepped:Connect(function()
	local humanoid = GetHumanoid()

	if humanoid and MovementInfo.Parent then
		MovementInfo.Text =
			"WalkSpeed: "
			.. math.floor(humanoid.WalkSpeed)

		MovementInfo.TextColor3 =
			Theme.Accent
	end
end)

--========================================================
-- GAME PAGE
--========================================================

CreateSection(
	GamePage,
	"Game",
	"Movement and superhero flight controls."
)

local FlyToggle

FlyToggle = CreateToggle(
	GamePage,
	"Superhero Fly",
	"Smooth flight with cinematic body pose.",
	Config.Fly,
	function(state)
		SetFly(state)
	end
)

local FlySpeedSlider = CreateSlider(
	GamePage,
	"Flight Speed",
	10,
	300,
	Config.FlySpeed,
	function(value)
		Config.FlySpeed = value
	end
)

local FlyTiltSlider = CreateSlider(
	GamePage,
	"Flight Tilt",
	0,
	55,
	Config.FlyTilt,
	function(value)
		Config.FlyTilt = value
	end,
	"°"
)

local SpeedToggle = CreateToggle(
	GamePage,
	"Speed",
	"Override local WalkSpeed.",
	Config.Speed,
	SetSpeed
)

local WalkSpeedSlider = CreateSlider(
	GamePage,
	"WalkSpeed",
	16,
	250,
	Config.WalkSpeed,
	function(value)
		Config.WalkSpeed = value
		RefreshSpeed()
	end
)

--========================================================
-- TOUCH FLY CONTROLS
--========================================================

local FlyTouch = New("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -15, 0.5, 0),

	Size = UDim2.fromOffset(62, 126),

	BackgroundTransparency = 1,

	Visible = false,

	ZIndex = 60,
})

FlyTouch.Parent = Gui

local function CreateFlyTouchButton(y, text)
	local button = New("TextButton", {
		Position = UDim2.fromOffset(0, y),
		Size = UDim2.fromOffset(58, 58),

		BackgroundColor3 = Theme.Panel2,
		BackgroundTransparency = 0.08,

		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = text,
		TextSize = 10,
		Font = Enum.Font.GothamBold,
		TextColor3 = Theme.Text,

		ZIndex = 61,
	})

	Corner(button, 18)

	local stroke = Stroke(
		button,
		Theme.Accent,
		0.15,
		1.2
	)

	button.Parent = FlyTouch

	BindTheme(button, {
		BackgroundColor3 = "Panel2",
		TextColor3 = "Text",
	})

	BindTheme(stroke, {
		Color = "Accent",
	})

	AddPressAnimation(button)

	return button
end

local UpButton = CreateFlyTouchButton(
	0,
	"▲\nUP"
)

local DownButton = CreateFlyTouchButton(
	68,
	"▼\nDOWN"
)

local function BindHold(button, callback)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			callback(true)
		end
	end)

	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			callback(false)
		end
	end)
end

BindHold(UpButton, function(state)
	FlyUp = state
end)

BindHold(DownButton, function(state)
	FlyDown = state
end)

--========================================================
-- MISC PAGE
--========================================================

CreateSection(
	MiscPage,
	"Misc",
	"Local physics utilities and protection."
)

local ImpactSpinToggle = CreateToggle(
	MiscPage,
	"Impact Spin",
	"Controlled local rotational physics mode.",
	Config.ImpactSpin,
	SetImpactSpin
)

local AntiFlingToggle = CreateToggle(
	MiscPage,
	"Anti-Fling",
	"Suppress abnormal velocity and collisions.",
	Config.AntiFling,
	SetAntiFling
)

--========================================================
-- HUB PAGE
--========================================================

CreateSection(
	HubPage,
	"Hub",
	"Dedicated game profiles."
)

local MM2Card = CreateCard(HubPage, 99)

local MM2Title = New("TextLabel", {
	Position = UDim2.fromOffset(13, 11),
	Size = UDim2.new(1, -100, 0, 18),

	BackgroundTransparency = 1,

	Text = "Murder Mystery 2",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

MM2Title.Parent = MM2Card

BindTheme(MM2Title, {
	TextColor3 = "Text",
})

local MM2Tag = New("TextLabel", {
	Position = UDim2.fromOffset(13, 32),
	Size = UDim2.new(1, -100, 0, 15),

	BackgroundTransparency = 1,

	Text = "MM2 PROFILE",
	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Accent,
})

MM2Tag.Parent = MM2Card

local MM2Desc = New("TextLabel", {
	Position = UDim2.fromOffset(13, 53),
	Size = UDim2.new(1, -120, 0, 32),

	BackgroundTransparency = 1,

	Text = "Enter a separate profile with universal modules disabled.",
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

MM2Desc.Parent = MM2Card

BindTheme(MM2Desc, {
	TextColor3 = "SubText",
})

local MM2Load = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -13, 0.5, 0),

	Size = UDim2.fromOffset(72, 31),

	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "LOAD",
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextColor3 = Color3.new(1, 1, 1),
})

Corner(MM2Load, 10)
MM2Load.Parent = MM2Card

BindTheme(MM2Load, {
	BackgroundColor3 = "Accent",
})

AddPressAnimation(MM2Load)

--========================================================
-- SETTINGS PAGE
--========================================================

CreateSection(
	SettingsPage,
	"Settings",
	"Customize interface appearance and size."
)

local AnimationToggle = CreateToggle(
	SettingsPage,
	"Interface Animations",
	"Enable smooth transitions and motion.",
	Config.Animations,
	function(state)
		Config.Animations = state
	end
)

local function UpdateResponsiveScale()
	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	local fitScale = math.min(
		(viewport.X - 18) / 620,
		(viewport.Y - 18) / 390,
		1.25
	)

	MainScale.Scale = math.min(
		Config.UIScale,
		fitScale
	)
end

local UIScaleSlider = CreateSlider(
	SettingsPage,
	"Interface Size",
	65,
	115,
	math.floor(Config.UIScale * 100),
	function(value)
		Config.UIScale = value / 100
		UpdateResponsiveScale()
	end,
	"%"
)

CreateAction(
	SettingsPage,
	"Reset Window",
	"Return the menu to the screen center.",
	"RESET",
	function()
		Tween(
			MainGroup,
			0.35,
			{
				Position = UDim2.fromScale(
					0.5,
					0.5
				),
			},
			Enum.EasingStyle.Back
		)
	end
)

CreateAction(
	SettingsPage,
	"Reset Button",
	"Return the floating button position.",
	"RESET",
	function()
		Tween(
			OpenButton,
			0.35,
			{
				Position = UDim2.new(
					0,
					16,
					0.5,
					0
				),
			},
			Enum.EasingStyle.Back
		)
	end
)

--========================================================
-- MM2 EMPTY PROFILE
--========================================================

local MM2Screen = New("CanvasGroup", {
	Position = UDim2.fromOffset(0, 52),
	Size = UDim2.new(1, 0, 1, -52),

	BackgroundTransparency = 1,

	GroupTransparency = 1,

	Visible = false,

	ZIndex = 8,
})

MM2Screen.Parent = MainFrame

local MM2Center = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.47),

	Size = UDim2.fromOffset(330, 190),

	BackgroundColor3 = Theme.Panel,
	BorderSizePixel = 0,
})

Corner(MM2Center, 22)

local MM2CenterStroke = Stroke(
	MM2Center,
	Theme.Accent,
	0.25,
	1.2
)

MM2Center.Parent = MM2Screen

BindTheme(MM2Center, {
	BackgroundColor3 = "Panel",
})

BindTheme(MM2CenterStroke, {
	Color = "Accent",
})

local MM2Icon = New("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 22),

	Size = UDim2.fromOffset(60, 60),

	BackgroundColor3 = Theme.Panel2,

	Text = "◆",
	TextSize = 26,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Accent,
})

Corner(MM2Icon, 19)
MM2Icon.Parent = MM2Center

BindTheme(MM2Icon, {
	BackgroundColor3 = "Panel2",
	TextColor3 = "Accent",
})

local MM2ProfileTitle = New("TextLabel", {
	Position = UDim2.fromOffset(20, 94),
	Size = UDim2.new(1, -40, 0, 23),

	BackgroundTransparency = 1,

	Text = "MM2 Mode",
	TextSize = 17,
	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,
})

MM2ProfileTitle.Parent = MM2Center

BindTheme(MM2ProfileTitle, {
	TextColor3 = "Text",
})

local MM2ProfileText = New("TextLabel", {
	Position = UDim2.fromOffset(25, 124),
	Size = UDim2.new(1, -50, 0, 40),

	BackgroundTransparency = 1,

	Text = "Universal modules are disabled in this profile.",
	TextWrapped = true,

	TextSize = 9,
	Font = Enum.Font.GothamMedium,
	TextColor3 = Theme.SubText,
})

MM2ProfileText.Parent = MM2Center

BindTheme(MM2ProfileText, {
	TextColor3 = "SubText",
})

--========================================================
-- STATE REGISTRY
--========================================================

local function SaveStates()
	SavedState = {
		ESP = Config.ESP,
		Fly = Config.Fly,
		Speed = Config.Speed,
		ImpactSpin = Config.ImpactSpin,
		AntiFling = Config.AntiFling,
	}
end

local function DisableUniversalModules()
	SetESP(false)
	SetFly(false)
	SetSpeed(false)
	SetImpactSpin(false)
	SetAntiFling(false)

	ESPToggle:Set(false, false)
	FlyToggle:Set(false, false)
	SpeedToggle:Set(false, false)
	ImpactSpinToggle:Set(false, false)
	AntiFlingToggle:Set(false, false)

	FlyTouch.Visible = false
end

local function RestoreUniversalModules()
	if SavedState.ESP then
		SetESP(true)
		ESPToggle:Set(true, false)
	end

	if SavedState.Fly then
		SetFly(true)
		FlyToggle:Set(true, false)
	end

	if SavedState.Speed then
		SetSpeed(true)
		SpeedToggle:Set(true, false)
	end

	if SavedState.ImpactSpin then
		SetImpactSpin(true)
		ImpactSpinToggle:Set(true, false)
	end

	if SavedState.AntiFling then
		SetAntiFling(true)
		AntiFlingToggle:Set(true, false)
	end

	FlyTouch.Visible =
		Config.Fly
		and UserInputService.TouchEnabled
end

local function EnterMM2()
	if Config.MM2 then
		return
	end

	Config.MM2 = true

	SaveStates()
	DisableUniversalModules()

	Theme = Themes.MM2

	Sidebar.Visible = false
	Content.Visible = false

	MM2Screen.Visible = true
	MM2Screen.GroupTransparency = 1

	BackButton.Visible = true
	Logo.Visible = false

	Title.Position = UDim2.fromOffset(53, 7)
	Subtitle.Position = UDim2.fromOffset(53, 27)

	Title.Text = "AntiFreak Hub • MM2"
	Subtitle.Text = "Murder Mystery 2 Profile"

	ApplyTheme()

	if Config.Animations then
		MM2Center.Position =
			UDim2.fromScale(
				0.5,
				0.54
			)

		MM2Center.Size =
			UDim2.fromOffset(
				300,
				170
			)

		Tween(
			MM2Screen,
			0.3,
			{
				GroupTransparency = 0,
			}
		)

		Tween(
			MM2Center,
			0.42,
			{
				Position = UDim2.fromScale(
					0.5,
					0.47
				),

				Size = UDim2.fromOffset(
					330,
					190
				),
			},
			Enum.EasingStyle.Back
		)
	else
		MM2Screen.GroupTransparency = 0
	end
end

local function ExitMM2()
	if not Config.MM2 then
		return
	end

	Config.MM2 = false

	Theme = Themes.Default

	MM2Screen.Visible = false

	Sidebar.Visible = true
	Content.Visible = true

	BackButton.Visible = false
	Logo.Visible = true

	Title.Position = UDim2.fromOffset(57, 7)
	Subtitle.Position = UDim2.fromOffset(57, 27)

	Title.Text = "AntiFreak Hub"
	Subtitle.Text = "Compact Universal Interface"

	ApplyTheme()
	RestoreUniversalModules()

	SwitchTab("Hub")
end

MM2Load.MouseButton1Click:Connect(
	EnterMM2
)

BackButton.MouseButton1Click:Connect(
	ExitMM2
)

--========================================================
-- MENU OPEN / CLOSE
--========================================================

local MenuBusy = false

local function OpenMenu()
	if Config.MenuOpen or MenuBusy then
		return
	end

	MenuBusy = true
	Config.MenuOpen = true

	MainGroup.Visible = true

	UpdateResponsiveScale()

	if Config.Animations then
		local targetScale = MainScale.Scale

		MainScale.Scale =
			targetScale * 0.82

		MainGroup.GroupTransparency = 1

		Tween(
			MainScale,
			0.45,
			{
				Scale = targetScale,
			},
			Enum.EasingStyle.Back
		)

		Tween(
			MainGroup,
			0.27,
			{
				GroupTransparency = 0,
			}
		)

		Tween(
			Blur,
			0.25,
			{
				Size = 7,
			}
		)

		task.delay(0.45, function()
			MenuBusy = false
		end)
	else
		MainGroup.GroupTransparency = 0
		Blur.Size = 7
		MenuBusy = false
	end
end

local function CloseMenu()
	if not Config.MenuOpen or MenuBusy then
		return
	end

	MenuBusy = true
	Config.MenuOpen = false

	if Config.Animations then
		local currentScale = MainScale.Scale

		Tween(
			MainScale,
			0.18,
			{
				Scale = currentScale * 0.88,
			},
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In
		)

		Tween(
			MainGroup,
			0.16,
			{
				GroupTransparency = 1,
			},
			Enum.EasingStyle.Quart,
			Enum.EasingDirection.In
		)

		Tween(
			Blur,
			0.18,
			{
				Size = 0,
			}
		)

		task.delay(0.2, function()
			MainGroup.Visible = false

			UpdateResponsiveScale()

			MenuBusy = false
		end)
	else
		MainGroup.Visible = false
		Blur.Size = 0
		MenuBusy = false
	end
end

CloseButton.MouseButton1Click:Connect(
	CloseMenu
)

OpenButton.MouseButton1Click:Connect(function()
	if OpenMoved then
		OpenMoved = false
		return
	end

	if Config.MenuOpen then
		CloseMenu()
	else
		OpenMenu()
	end
end)

--========================================================
-- KEYBOARD INPUT
--========================================================

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space then
		FlyUp = true
	end

	if input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.LeftControl then

		FlyDown = true
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		if Config.MenuOpen then
			CloseMenu()
		else
			OpenMenu()
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		FlyUp = false
	end

	if input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.LeftControl then

		FlyDown = false
	end
end)

--========================================================
-- CHARACTER RESPAWN
--========================================================

LocalPlayer.CharacterAdded:Connect(function(character)
	character:WaitForChild(
		"Humanoid",
		10
	)

	character:WaitForChild(
		"HumanoidRootPart",
		10
	)

	task.wait(0.25)

	if Config.Speed then
		RefreshSpeed()
	end

	if Config.Fly then
		StartFly()
	end

	if Config.ImpactSpin then
		StartImpactSpin()
	end

	if Config.AntiFling then
		StartAntiFling()
	end
end)

--========================================================
-- RESPONSIVE SIZE
--========================================================

local CameraConnection

local function HookCamera()
	if CameraConnection then
		CameraConnection:Disconnect()
		CameraConnection = nil
	end

	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	CameraConnection =
		camera:GetPropertyChangedSignal(
			"ViewportSize"
		):Connect(
			UpdateResponsiveScale
		)

	UpdateResponsiveScale()
end

Workspace:GetPropertyChangedSignal(
	"CurrentCamera"
):Connect(
	HookCamera
)

HookCamera()

--========================================================
-- LIVE TOUCH CONTROL VISIBILITY
--========================================================

RunService.RenderStepped:Connect(function()
	FlyTouch.Visible =
		Config.Fly
		and UserInputService.TouchEnabled
		and not Config.MM2
end)

--========================================================
-- INITIALIZATION
--========================================================

ApplyTheme()
SwitchTab("Visuals")
UpdateResponsiveScale()

MainGroup.Visible = true
MainGroup.GroupTransparency = 1

local startupScale = MainScale.Scale

MainScale.Scale =
	startupScale * 0.8

if Config.Animations then
	Tween(
		MainScale,
		0.55,
		{
			Scale = startupScale,
		},
		Enum.EasingStyle.Back
	)

	Tween(
		MainGroup,
		0.3,
		{
			GroupTransparency = 0,
		}
	)
else
	MainScale.Scale = startupScale
	MainGroup.GroupTransparency = 0
end

print("[AntiFreak Hub] Compact UI loaded.")
