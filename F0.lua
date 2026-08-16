--[[
	AntiFreak Hub
	Minimal Rounded Edition

	Place:
	StarterPlayer > StarterPlayerScripts > LocalScript

	UI LANGUAGE: ENGLISH ONLY

	Features:
	- Compact rounded UI
	- Long smooth animations
	- Touch + PC support
	- Adjustable UI scale
	- Player ESP
	- Full HSV ESP color picker + presets
	- Superhero Fly
	- Flight speed / tilt
	- WalkSpeed
	- Impact Spin
	- Anti-Fling
	- MM2 independent profile
	- AIM independent profile
		* Visuals tab
		* Aim tab
		* FOV circle
		* FOV radius
		* FOV opacity
		* FOV thickness
		* Aim sharpness
		* Max distance
		* Team check
		* Wall check
		* Target highlight
		* Head / Root target
		* Touch AIM ON/OFF button
]]

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================
-- CLEANUP
--========================================================

local oldGui = PlayerGui:FindFirstChild("AntiFreakHub")
if oldGui then
	oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("AntiFreakHubBlur")
if oldBlur then
	oldBlur:Destroy()
end

--========================================================
-- CONFIG
--========================================================

local Config = {
	MenuOpen = true,
	CurrentTab = "Visuals",
	CurrentProfile = nil,

	UIScale = 0.90,
	Animations = true,

	ESPEnabled = false,
	ESPColor = Color3.fromHSV(0.73, 0.78, 1),

	FlyEnabled = false,
	FlySpeed = 85,
	FlyTilt = 28,

	SpeedEnabled = false,
	WalkSpeed = 32,

	ImpactSpinEnabled = false,
	AntiFlingEnabled = false,

	AimEnabled = false,
	AimTab = "Aim",

	ShowFOV = true,
	FOVRadius = 145,
	FOVOpacity = 45,
	FOVThickness = 2,

	AimSharpness = 12,
	AimMaxDistance = 1000,

	AimTeamCheck = false,
	AimWallCheck = true,
	AimTargetHighlight = true,

	AimTargetPart = "Head",
	AimFOVColor = Color3.fromRGB(170, 100, 255),
}

local UniversalSavedState = {}

--========================================================
-- THEME
--========================================================

local Themes = {
	Default = {
		Background = Color3.fromRGB(9, 10, 14),

		Surface = Color3.fromRGB(15, 17, 23),
		Surface2 = Color3.fromRGB(20, 23, 31),
		Surface3 = Color3.fromRGB(26, 29, 39),

		Accent = Color3.fromRGB(166, 91, 255),
		AccentSoft = Color3.fromRGB(116, 87, 205),

		Text = Color3.fromRGB(247, 248, 252),
		SubText = Color3.fromRGB(139, 145, 165),

		Stroke = Color3.fromRGB(49, 53, 68),

		Success = Color3.fromRGB(74, 224, 143),
		Danger = Color3.fromRGB(255, 86, 112),
	},

	MM2 = {
		Background = Color3.fromRGB(4, 9, 16),

		Surface = Color3.fromRGB(6, 18, 30),
		Surface2 = Color3.fromRGB(8, 27, 45),
		Surface3 = Color3.fromRGB(10, 38, 61),

		Accent = Color3.fromRGB(0, 187, 255),
		AccentSoft = Color3.fromRGB(0, 110, 218),

		Text = Color3.fromRGB(239, 250, 255),
		SubText = Color3.fromRGB(120, 170, 201),

		Stroke = Color3.fromRGB(23, 72, 102),

		Success = Color3.fromRGB(69, 231, 191),
		Danger = Color3.fromRGB(255, 83, 111),
	},

	AIM = {
		Background = Color3.fromRGB(10, 8, 14),

		Surface = Color3.fromRGB(18, 14, 25),
		Surface2 = Color3.fromRGB(25, 19, 34),
		Surface3 = Color3.fromRGB(32, 24, 44),

		Accent = Color3.fromRGB(221, 78, 151),
		AccentSoft = Color3.fromRGB(147, 62, 159),

		Text = Color3.fromRGB(252, 244, 250),
		SubText = Color3.fromRGB(168, 139, 160),

		Stroke = Color3.fromRGB(68, 48, 66),

		Success = Color3.fromRGB(84, 231, 150),
		Danger = Color3.fromRGB(255, 76, 108),
	},
}

local Theme = Themes.Default
local ThemeBindings = {}
local ThemeRefreshers = {}

--========================================================
-- BASIC HELPERS
--========================================================

local function New(className, properties)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	return object
end

local function Round(object, radius)
	local corner = New("UICorner", {
		CornerRadius = UDim.new(0, radius or 14),
	})

	corner.Parent = object
	return corner
end

local function Circle(object)
	local corner = New("UICorner", {
		CornerRadius = UDim.new(1, 0),
	})

	corner.Parent = object
	return corner
end

local function Stroke(object, color, transparency, thickness)
	local stroke = New("UIStroke", {
		Color = color or Theme.Stroke,
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	})

	stroke.Parent = object
	return stroke
end

local function Padding(object, l, r, t, b)
	local padding = New("UIPadding", {
		PaddingLeft = UDim.new(0, l or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingTop = UDim.new(0, t or 0),
		PaddingBottom = UDim.new(0, b or 0),
	})

	padding.Parent = object
	return padding
end

local function Tween(
	object,
	duration,
	properties,
	style,
	direction
)
	if not object then
		return
	end

	local tween = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.4,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)

	tween:Play()

	return tween
end

local function BindTheme(object, bindings)
	ThemeBindings[object] = bindings
end

local function AddThemeRefresher(callback)
	table.insert(ThemeRefreshers, callback)
end

local function ApplyTheme()
	for object, bindings in pairs(ThemeBindings) do
		if not object or not object.Parent then
			ThemeBindings[object] = nil
		else
			for property, key in pairs(bindings) do
				pcall(function()
					object[property] = Theme[key]
				end)
			end
		end
	end

	for _, callback in ipairs(ThemeRefreshers) do
		pcall(callback)
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

--========================================================
-- BUTTON ANIMATION
--========================================================

local function AnimateButton(button)
	local scale = New("UIScale", {
		Scale = 1,
	})

	scale.Parent = button

	local stroke = button:FindFirstChildOfClass("UIStroke")

	button.MouseEnter:Connect(function()
		if not UserInputService.MouseEnabled then
			return
		end

		Tween(
			scale,
			0.32,
			{Scale = 1.035},
			Enum.EasingStyle.Quint
		)

		if stroke then
			Tween(stroke, 0.4, {
				Transparency = 0.05,
			})
		end
	end)

	button.MouseLeave:Connect(function()
		if not UserInputService.MouseEnabled then
			return
		end

		Tween(
			scale,
			0.38,
			{Scale = 1},
			Enum.EasingStyle.Quint
		)

		if stroke then
			Tween(stroke, 0.45, {
				Transparency = 0.35,
			})
		end
	end)

	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			Tween(
				scale,
				0.16,
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
				0.48,
				{Scale = 1},
				Enum.EasingStyle.Back
			)
		end
	end)
end

--========================================================
-- DRAG
--========================================================

local function MakeDraggable(frame, handle)
	handle = handle or frame

	local dragging = false
	local dragStart
	local startPosition
	local dragInput

	handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then

			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or input ~= dragInput then
			return
		end

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)
end

--========================================================
-- ROOT GUI
--========================================================

local Gui = New("ScreenGui", {
	Name = "AntiFreakHub",

	ResetOnSpawn = false,
	IgnoreGuiInset = true,

	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
})

Gui.Parent = PlayerGui

local Blur = New("BlurEffect", {
	Name = "AntiFreakHubBlur",
	Size = 8,
})

Blur.Parent = Lighting

--========================================================
-- FOV OVERLAY
--========================================================

local FOVRing = New("Frame", {
	Name = "AimFOV",

	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.fromOffset(
		Config.FOVRadius * 2,
		Config.FOVRadius * 2
	),

	BackgroundTransparency = 1,

	Visible = false,

	ZIndex = 30,
})

Circle(FOVRing)

local FOVStroke = Stroke(
	FOVRing,
	Config.AimFOVColor,
	Config.FOVOpacity / 100,
	Config.FOVThickness
)

FOVRing.Parent = Gui

--========================================================
-- OPEN BUTTON
--========================================================

local OpenButton = New("TextButton", {
	Name = "OpenButton",

	AnchorPoint = Vector2.new(0, 0.5),

	Position = UDim2.new(
		0,
		16,
		0.5,
		0
	),

	Size = UDim2.fromOffset(48, 48),

	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "⚡",
	TextSize = 21,

	Font = Enum.Font.GothamBold,
	TextColor3 = Theme.Text,

	ZIndex = 90,
})

Round(OpenButton, 17)

local OpenStroke = Stroke(
	OpenButton,
	Theme.Accent,
	0.18,
	1.4
)

OpenButton.Parent = Gui

BindTheme(OpenButton, {
	BackgroundColor3 = "Surface2",
	TextColor3 = "Text",
})

BindTheme(OpenStroke, {
	Color = "Accent",
})

AnimateButton(OpenButton)

--========================================================
-- OPEN BUTTON DRAG
--========================================================

local OpenDragging = false
local OpenMoved = false

local OpenStart
local OpenPosition

OpenButton.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1
		and input.UserInputType ~= Enum.UserInputType.Touch then

		return
	end

	OpenDragging = true
	OpenMoved = false

	OpenStart = input.Position
	OpenPosition = OpenButton.Position
end)

UserInputService.InputChanged:Connect(function(input)
	if not OpenDragging then
		return
	end

	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then

		return
	end

	local delta = input.Position - OpenStart

	if delta.Magnitude > 7 then
		OpenMoved = true
	end

	OpenButton.Position = UDim2.new(
		OpenPosition.X.Scale,
		OpenPosition.X.Offset + delta.X,
		OpenPosition.Y.Scale,
		OpenPosition.Y.Offset + delta.Y
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

	Position = UDim2.fromScale(
		0.5,
		0.5
	),

	Size = UDim2.fromOffset(
		600,
		380
	),

	BackgroundTransparency = 1,

	GroupTransparency = 0,

	ZIndex = 50,
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

Round(MainFrame, 28)

local MainStroke = Stroke(
	MainFrame,
	Theme.Stroke,
	0.08,
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
-- SOFT INNER GLOW
--========================================================

local InnerGlow = New("Frame", {
	Position = UDim2.fromOffset(6, 6),

	Size = UDim2.new(
		1,
		-12,
		1,
		-12
	),

	BackgroundTransparency = 1,
})

Round(InnerGlow, 23)

local InnerStroke = Stroke(
	InnerGlow,
	Theme.Accent,
	0.88,
	1
)

InnerGlow.Parent = MainFrame

BindTheme(InnerStroke, {
	Color = "Accent",
})

--========================================================
-- HEADER
--========================================================

local Header = New("Frame", {
	Position = UDim2.fromOffset(10, 10),

	Size = UDim2.new(
		1,
		-20,
		0,
		50
	),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,

	ZIndex = 4,
})

Round(Header, 17)

local HeaderStroke = Stroke(
	Header,
	Theme.Stroke,
	0.42,
	1
)

Header.Parent = MainFrame

BindTheme(Header, {
	BackgroundColor3 = "Surface",
})

BindTheme(HeaderStroke, {
	Color = "Stroke",
})

--========================================================
-- HEADER ACCENT
--========================================================

local HeaderAccent = New("Frame", {
	Position = UDim2.fromOffset(8, 8),

	Size = UDim2.fromOffset(4, 34),

	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
})

Round(HeaderAccent, 4)

HeaderAccent.Parent = Header

BindTheme(HeaderAccent, {
	BackgroundColor3 = "Accent",
})

--========================================================
-- BACK BUTTON
--========================================================

local BackButton = New("TextButton", {
	Position = UDim2.fromOffset(18, 9),

	Size = UDim2.fromOffset(32, 32),

	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "‹",

	TextSize = 26,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.Text,

	Visible = false,

	ZIndex = 6,
})

Round(BackButton, 11)

local BackStroke = Stroke(
	BackButton,
	Theme.Stroke,
	0.35,
	1
)

BackButton.Parent = Header

BindTheme(BackButton, {
	BackgroundColor3 = "Surface3",
	TextColor3 = "Text",
})

BindTheme(BackStroke, {
	Color = "Stroke",
})

AnimateButton(BackButton)

--========================================================
-- LOGO
--========================================================

local Logo = New("Frame", {
	Position = UDim2.fromOffset(20, 9),

	Size = UDim2.fromOffset(32, 32),

	BackgroundColor3 = Theme.Accent,
	BorderSizePixel = 0,
})

Round(Logo, 11)

Logo.Parent = Header

BindTheme(Logo, {
	BackgroundColor3 = "Accent",
})

local LogoText = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Text = "⚡",

	TextSize = 16,
	Font = Enum.Font.GothamBold,

	TextColor3 = Color3.new(1, 1, 1),
})

LogoText.Parent = Logo

--========================================================
-- TITLE
--========================================================

local HeaderTitle = New("TextLabel", {
	Position = UDim2.fromOffset(64, 7),

	Size = UDim2.new(
		0,
		250,
		0,
		19
	),

	BackgroundTransparency = 1,

	Text = "AntiFreak Hub",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 14,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Text,
})

HeaderTitle.Parent = Header

BindTheme(HeaderTitle, {
	TextColor3 = "Text",
})

local HeaderSubtitle = New("TextLabel", {
	Position = UDim2.fromOffset(64, 26),

	Size = UDim2.new(
		0,
		300,
		0,
		15
	),

	BackgroundTransparency = 1,

	Text = "Universal Interface",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

HeaderSubtitle.Parent = Header

BindTheme(HeaderSubtitle, {
	TextColor3 = "SubText",
})

--========================================================
-- CLOSE BUTTON
--========================================================

local CloseButton = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0),

	Position = UDim2.new(
		1,
		-9,
		0,
		9
	),

	Size = UDim2.fromOffset(32, 32),

	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "×",

	TextSize = 18,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

Round(CloseButton, 11)

local CloseStroke = Stroke(
	CloseButton,
	Theme.Stroke,
	0.35,
	1
)

CloseButton.Parent = Header

BindTheme(CloseButton, {
	BackgroundColor3 = "Surface3",
	TextColor3 = "SubText",
})

BindTheme(CloseStroke, {
	Color = "Stroke",
})

AnimateButton(CloseButton)

MakeDraggable(MainGroup, Header)

--========================================================
-- UNIVERSAL SIDEBAR
--========================================================

local Sidebar = New("Frame", {
	Position = UDim2.fromOffset(10, 70),

	Size = UDim2.new(
		0,
		122,
		1,
		-80
	),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
})

Round(Sidebar, 19)

local SidebarStroke = Stroke(
	Sidebar,
	Theme.Stroke,
	0.42,
	1
)

Sidebar.Parent = MainFrame

BindTheme(Sidebar, {
	BackgroundColor3 = "Surface",
})

BindTheme(SidebarStroke, {
	Color = "Stroke",
})

local NavLabel = New("TextLabel", {
	Position = UDim2.fromOffset(13, 12),

	Size = UDim2.new(
		1,
		-26,
		0,
		14
	),

	BackgroundTransparency = 1,

	Text = "NAVIGATION",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.SubText,
})

NavLabel.Parent = Sidebar

BindTheme(NavLabel, {
	TextColor3 = "SubText",
})

local TabsHolder = New("Frame", {
	Position = UDim2.fromOffset(8, 34),

	Size = UDim2.new(
		1,
		-16,
		1,
		-66
	),

	BackgroundTransparency = 1,
})

TabsHolder.Parent = Sidebar

local TabsLayout = New("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

TabsLayout.Parent = TabsHolder

local VersionLabel = New("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),

	Position = UDim2.new(
		0.5,
		0,
		1,
		-8
	),

	Size = UDim2.new(
		1,
		-20,
		0,
		14
	),

	BackgroundTransparency = 1,

	Text = "v4.0",

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

VersionLabel.Parent = Sidebar

BindTheme(VersionLabel, {
	TextColor3 = "SubText",
})

--========================================================
-- UNIVERSAL CONTENT
--========================================================

local Content = New("Frame", {
	Position = UDim2.fromOffset(142, 70),

	Size = UDim2.new(
		1,
		-152,
		1,
		-80
	),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,

	ClipsDescendants = true,
})

Round(Content, 19)

local ContentStroke = Stroke(
	Content,
	Theme.Stroke,
	0.42,
	1
)

Content.Parent = MainFrame

BindTheme(Content, {
	BackgroundColor3 = "Surface",
})

BindTheme(ContentStroke, {
	Color = "Stroke",
})

--========================================================
-- PAGES
--========================================================

local Pages = {}
local TabButtons = {}

local function CreatePage(name)
	local page = New("CanvasGroup", {
		Name = name .. "Page",

		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		GroupTransparency = 1,

		Visible = false,
	})

	page.Parent = Content

	local scroll = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,

		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
	})

	Padding(scroll, 13, 13, 12, 16)

	scroll.Parent = page

	local layout = New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	layout.Parent = scroll

	Pages[name] = {
		Group = page,
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

local TabData = {
	{"Visuals", "◉"},
	{"Player", "●"},
	{"Game", "◆"},
	{"Hub", "◇"},
	{"Misc", "✦"},
	{"Settings", "⚙"},
}

local function RefreshUniversalTabs()
	for name, button in pairs(TabButtons) do
		local active = Config.CurrentTab == name

		local indicator = button:FindFirstChild("Indicator")

		if active then
			button.BackgroundColor3 = Theme.Surface3
			button.BackgroundTransparency = 0

			button.TextColor3 = Theme.Text

			if indicator then
				indicator.BackgroundColor3 = Theme.Accent
				indicator.BackgroundTransparency = 0
			end
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = Theme.SubText

			if indicator then
				indicator.BackgroundTransparency = 1
			end
		end
	end
end

AddThemeRefresher(RefreshUniversalTabs)

local function SwitchUniversalTab(name)
	if Config.CurrentProfile then
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

	selected.Group.Position = UDim2.fromOffset(14, 0)

	if Config.Animations then
		Tween(
			selected.Group,
			0.55,
			{
				GroupTransparency = 0,
				Position = UDim2.fromOffset(0, 0),
			},
			Enum.EasingStyle.Quint
		)
	else
		selected.Group.GroupTransparency = 0
		selected.Group.Position = UDim2.fromOffset(0, 0)
	end

	RefreshUniversalTabs()
end

for index, data in ipairs(TabData) do
	local name = data[1]
	local icon = data[2]

	local button = New("TextButton", {
		Name = name,

		Size = UDim2.new(
			1,
			0,
			0,
			34
		),

		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "  " .. icon .. "   " .. name,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 9,
		Font = Enum.Font.GothamMedium,

		TextColor3 = Theme.SubText,

		LayoutOrder = index,
	})

	Round(button, 11)

	button.Parent = TabsHolder

	local indicator = New("Frame", {
		Name = "Indicator",

		AnchorPoint = Vector2.new(0, 0.5),

		Position = UDim2.new(
			0,
			0,
			0.5,
			0
		),

		Size = UDim2.fromOffset(3, 16),

		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,

		BorderSizePixel = 0,
	})

	Round(indicator, 3)

	indicator.Parent = button

	TabButtons[name] = button

	AnimateButton(button)

	button.MouseButton1Click:Connect(function()
		SwitchUniversalTab(name)
	end)
end

--========================================================
-- COMPONENTS
--========================================================

local function CreateSection(parent, title, description)
	local holder = New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			description and 38 or 23
		),

		BackgroundTransparency = 1,
	})

	holder.Parent = parent

	local titleLabel = New("TextLabel", {
		Size = UDim2.new(
			1,
			0,
			0,
			20
		),

		BackgroundTransparency = 1,

		Text = title,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 15,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = holder

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	if description then
		local subtitle = New("TextLabel", {
			Position = UDim2.fromOffset(0, 20),

			Size = UDim2.new(
				1,
				0,
				0,
				14
			),

			BackgroundTransparency = 1,

			Text = description,

			TextXAlignment = Enum.TextXAlignment.Left,

			TextSize = 8,
			Font = Enum.Font.GothamMedium,

			TextColor3 = Theme.SubText,
		})

		subtitle.Parent = holder

		BindTheme(subtitle, {
			TextColor3 = "SubText",
		})
	end

	return holder
end

local function CreateCard(parent, height)
	local card = New("Frame", {
		Size = UDim2.new(
			1,
			0,
			0,
			height or 56
		),

		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,

		ClipsDescendants = true,
	})

	Round(card, 16)

	local stroke = Stroke(
		card,
		Theme.Stroke,
		0.42,
		1
	)

	card.Parent = parent

	BindTheme(card, {
		BackgroundColor3 = "Surface2",
	})

	BindTheme(stroke, {
		Color = "Stroke",
	})

	return card
end

local function CreateToggle(
	parent,
	title,
	description,
	defaultValue,
	callback
)
	local card = CreateCard(parent, 57)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),

		Size = UDim2.new(
			1,
			-82,
			0,
			18
		),

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

	local descriptionLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),

		Size = UDim2.new(
			1,
			-88,
			0,
			15
		),

		BackgroundTransparency = 1,

		Text = description or "",

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 8,
		Font = Enum.Font.GothamMedium,

		TextColor3 = Theme.SubText,
	})

	descriptionLabel.Parent = card

	BindTheme(descriptionLabel, {
		TextColor3 = "SubText",
	})

	local toggle = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),

		Position = UDim2.new(
			1,
			-13,
			0.5,
			0
		),

		Size = UDim2.fromOffset(45, 24),

		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "",
	})

	Round(toggle, 12)

	toggle.Parent = card

	local knob = New("Frame", {
		Position = UDim2.fromOffset(3, 3),

		Size = UDim2.fromOffset(18, 18),

		BackgroundColor3 = Theme.SubText,
		BorderSizePixel = 0,
	})

	Circle(knob)

	knob.Parent = toggle

	local value = defaultValue == true

	local controller = {}

	local function Render(animated)
		local switchColor =
			value
			and Theme.Accent
			or Theme.Surface3

		local knobColor =
			value
			and Color3.new(1, 1, 1)
			or Theme.SubText

		local knobPosition =
			value
			and UDim2.new(1, -21, 0, 3)
			or UDim2.fromOffset(3, 3)

		if animated then
			Tween(
				toggle,
				0.42,
				{
					BackgroundColor3 = switchColor,
				},
				Enum.EasingStyle.Quint
			)

			Tween(
				knob,
				0.52,
				{
					Position = knobPosition,
					BackgroundColor3 = knobColor,
				},
				Enum.EasingStyle.Back
			)
		else
			toggle.BackgroundColor3 = switchColor
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

	AddThemeRefresher(function()
		Render(false)
	end)

	toggle.MouseButton1Click:Connect(function()
		controller:Set(not value, true)
	end)

	AnimateButton(toggle)
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
	local card = CreateCard(parent, 66)

	local value = math.clamp(
		defaultValue,
		minimum,
		maximum
	)

	local dragging = false

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),

		Size = UDim2.new(
			1,
			-92,
			0,
			17
		),

		BackgroundTransparency = 1,

		Text = title,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 9,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Text,
	})

	titleLabel.Parent = card

	BindTheme(titleLabel, {
		TextColor3 = "Text",
	})

	local valueLabel = New("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),

		Position = UDim2.new(
			1,
			-13,
			0,
			8
		),

		Size = UDim2.fromOffset(80, 17),

		BackgroundTransparency = 1,

		TextXAlignment = Enum.TextXAlignment.Right,

		TextSize = 9,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Accent,
	})

	valueLabel.Parent = card

	local bar = New("Frame", {
		Position = UDim2.fromOffset(13, 41),

		Size = UDim2.new(
			1,
			-26,
			0,
			7
		),

		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,

		Active = true,
	})

	Round(bar, 4)

	bar.Parent = card

	BindTheme(bar, {
		BackgroundColor3 = "Surface3",
	})

	local fill = New("Frame", {
		Size = UDim2.fromScale(0, 1),

		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
	})

	Round(fill, 4)

	fill.Parent = bar

	local knob = New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),

		Position = UDim2.fromScale(0, 0.5),

		Size = UDim2.fromOffset(15, 15),

		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	})

	Circle(knob)

	local knobStroke = Stroke(
		knob,
		Theme.Accent,
		0,
		1.5
	)

	knob.Parent = bar

	local controller = {}

	local function Render(animated)
		local alpha =
			(value - minimum)
			/ (maximum - minimum)

		valueLabel.Text =
			tostring(math.floor(value + 0.5))
			.. (suffix or "")

		valueLabel.TextColor3 = Theme.Accent
		fill.BackgroundColor3 = Theme.Accent
		knobStroke.Color = Theme.Accent

		if animated then
			Tween(
				fill,
				0.25,
				{
					Size = UDim2.fromScale(
						alpha,
						1
					),
				}
			)

			Tween(
				knob,
				0.25,
				{
					Position = UDim2.fromScale(
						alpha,
						0.5
					),
				}
			)
		else
			fill.Size = UDim2.fromScale(alpha, 1)
			knob.Position = UDim2.fromScale(alpha, 0.5)
		end
	end

	local function SetFromX(x)
		if bar.AbsoluteSize.X <= 0 then
			return
		end

		local alpha = math.clamp(
			(x - bar.AbsolutePosition.X)
			/ bar.AbsoluteSize.X,
			0,
			1
		)

		value =
			minimum
			+ ((maximum - minimum) * alpha)

		value = math.floor(value + 0.5)

		Render(false)

		if callback then
			callback(value)
		end
	end

	function controller:Set(newValue, fireCallback)
		value = math.clamp(
			newValue,
			minimum,
			maximum
		)

		Render(true)

		if fireCallback ~= false and callback then
			callback(value)
		end
	end

	function controller:Get()
		return value
	end

	AddThemeRefresher(function()
		Render(false)
	end)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			SetFromX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			SetFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	Render(false)

	return controller, card
end

local function CreateAction(
	parent,
	title,
	description,
	buttonText,
	callback
)
	local card = CreateCard(parent, 57)

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 8),

		Size = UDim2.new(
			1,
			-105,
			0,
			18
		),

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

	local descriptionLabel = New("TextLabel", {
		Position = UDim2.fromOffset(13, 29),

		Size = UDim2.new(
			1,
			-110,
			0,
			15
		),

		BackgroundTransparency = 1,

		Text = description or "",

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 8,
		Font = Enum.Font.GothamMedium,

		TextColor3 = Theme.SubText,
	})

	descriptionLabel.Parent = card

	BindTheme(descriptionLabel, {
		TextColor3 = "SubText",
	})

	local button = New("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),

		Position = UDim2.new(
			1,
			-13,
			0.5,
			0
		),

		Size = UDim2.fromOffset(73, 30),

		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = buttonText,

		TextSize = 8,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Text,
	})

	Round(button, 11)

	local buttonStroke = Stroke(
		button,
		Theme.Stroke,
		0.35,
		1
	)

	button.Parent = card

	BindTheme(button, {
		BackgroundColor3 = "Surface3",
		TextColor3 = "Text",
	})

	BindTheme(buttonStroke, {
		Color = "Stroke",
	})

	AnimateButton(button)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback(button)
		end
	end)

	return card, button
end

--========================================================
-- PLAYER ESP
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
		FillTransparency = 0.68,

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
	Config.ESPEnabled = state

	if state then
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

local function HookESPPlayer(player)
	if player == LocalPlayer then
		return
	end

	if ESPConnections[player] then
		ESPConnections[player]:Disconnect()
	end

	ESPConnections[player] =
		player.CharacterAdded:Connect(function()
			task.wait(0.35)

			if Config.ESPEnabled then
				AddESP(player)
			end
		end)
end

for _, player in ipairs(Players:GetPlayers()) do
	HookESPPlayer(player)
end

Players.PlayerAdded:Connect(HookESPPlayer)

Players.PlayerRemoving:Connect(function(player)
	RemoveESP(player)

	if ESPConnections[player] then
		ESPConnections[player]:Disconnect()
		ESPConnections[player] = nil
	end
end)

--========================================================
-- SPEED
--========================================================

local StoredWalkSpeed

local function SetSpeed(state)
	Config.SpeedEnabled = state

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

local function UpdateWalkSpeed()
	if not Config.SpeedEnabled then
		return
	end

	local humanoid = GetHumanoid()

	if humanoid then
		humanoid.WalkSpeed = Config.WalkSpeed
	end
end

--========================================================
-- SUPERHERO FLIGHT
--========================================================

local FlyAttachment
local FlyVelocity
local FlyOrientation
local FlyConnection

local FlyUp = false
local FlyDown = false

local FlyMotors = {}

local function ResetFlyPose()
	for _, motor in pairs(FlyMotors) do
		if motor and motor.Parent then
			motor.Transform = CFrame.new()
		end
	end
end

local function CacheFlyMotors()
	table.clear(FlyMotors)

	local character = GetCharacter()

	if not character then
		return
	end

	local upperTorso =
		character:FindFirstChild("UpperTorso")

	local torso =
		character:FindFirstChild("Torso")

	if upperTorso then
		FlyMotors.RightShoulder =
			upperTorso:FindFirstChild("RightShoulder")

		FlyMotors.LeftShoulder =
			upperTorso:FindFirstChild("LeftShoulder")

		FlyMotors.Waist =
			upperTorso:FindFirstChild("Waist")

		FlyMotors.Neck =
			upperTorso:FindFirstChild("Neck")
	elseif torso then
		FlyMotors.RightShoulder =
			torso:FindFirstChild("Right Shoulder")

		FlyMotors.LeftShoulder =
			torso:FindFirstChild("Left Shoulder")

		FlyMotors.Neck =
			torso:FindFirstChild("Neck")
	end
end

local function UpdateFlyPose(timeValue, moving)
	local wave =
		math.sin(timeValue * 4.5) * 2.8

	local shoulderAngle =
		moving and -122 or -96

	local right = FlyMotors.RightShoulder
	local left = FlyMotors.LeftShoulder
	local waist = FlyMotors.Waist
	local neck = FlyMotors.Neck

	if right then
		right.Transform =
			CFrame.Angles(
				math.rad(shoulderAngle + wave),
				math.rad(-4),
				math.rad(10)
			)
	end

	if left then
		left.Transform =
			CFrame.Angles(
				math.rad(shoulderAngle - wave),
				math.rad(4),
				math.rad(-10)
			)
	end

	if waist then
		waist.Transform =
			CFrame.Angles(
				math.rad(-7),
				0,
				math.rad(
					math.sin(timeValue * 2.5)
					* 2
				)
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

local function StopFly()
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
	StopFly()

	local root = GetRoot()
	local humanoid = GetHumanoid()

	if not root or not humanoid then
		Config.FlyEnabled = false
		return
	end

	CacheFlyMotors()

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

		Mode =
			Enum.OrientationAlignmentMode.OneAttachment,

		Responsiveness = 24,

		MaxTorque = math.huge,

		MaxAngularVelocity = math.huge,

		RigidityEnabled = false,
	})

	FlyOrientation.Parent = root

	local startTime = os.clock()

	FlyConnection =
		RunService.RenderStepped:Connect(function()
			if not Config.FlyEnabled then
				return
			end

			local currentRoot = GetRoot()
			local currentHumanoid = GetHumanoid()
			local camera = Workspace.CurrentCamera

			if not currentRoot
				or not currentHumanoid
				or not camera then

				return
			end

			local moveDirection =
				currentHumanoid.MoveDirection

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

			local moving =
				direction.Magnitude > 0.05
				or vertical ~= 0

			FlyVelocity.VectorVelocity =
				(direction * Config.FlySpeed)
				+ Vector3.new(
					0,
					vertical * Config.FlySpeed,
					0
				)

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

			local tilt =
				moving
				and Config.FlyTilt
				or 4

			local roll = 0

			if direction.Magnitude > 0.05 then
				roll =
					-camera.CFrame.RightVector:Dot(
						direction
					) * 10
			end

			FlyOrientation.CFrame =
				CFrame.lookAt(
					Vector3.zero,
					facing
				)
				* CFrame.Angles(
					math.rad(-tilt),
					0,
					math.rad(roll)
				)

			UpdateFlyPose(
				os.clock() - startTime,
				moving
			)
		end)
end

local function SetFly(state)
	Config.FlyEnabled = state

	if state then
		StartFly()
	else
		StopFly()
	end
end

--========================================================
-- IMPACT SPIN
--========================================================

local SpinConnection

local function StopImpactSpin()
	if SpinConnection then
		SpinConnection:Disconnect()
		SpinConnection = nil
	end

	local root = GetRoot()

	if root then
		root.AssemblyAngularVelocity = Vector3.zero
	end
end

local function StartImpactSpin()
	StopImpactSpin()

	SpinConnection =
		RunService.Heartbeat:Connect(function()
			if not Config.ImpactSpinEnabled then
				return
			end

			local root = GetRoot()

			if not root then
				return
			end

			root.AssemblyAngularVelocity =
				Vector3.new(
					0,
					44,
					0
				)

			if root.AssemblyLinearVelocity.Magnitude > 100 then
				root.AssemblyLinearVelocity =
					root.AssemblyLinearVelocity.Unit
					* 68
			end
		end)
end

local function SetImpactSpin(state)
	Config.ImpactSpinEnabled = state

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
local AntiCollisionCache = {}

local function StopAntiFling()
	if AntiFlingConnection then
		AntiFlingConnection:Disconnect()
		AntiFlingConnection = nil
	end

	for part, state in pairs(AntiCollisionCache) do
		if part and part.Parent then
			part.CanCollide = state
		end
	end

	table.clear(AntiCollisionCache)
end

local function StartAntiFling()
	StopAntiFling()

	AntiFlingConnection =
		RunService.Heartbeat:Connect(function()
			if not Config.AntiFlingEnabled then
				return
			end

			local root = GetRoot()

			if root then
				if root.AssemblyLinearVelocity.Magnitude > 115 then
					root.AssemblyLinearVelocity =
						Vector3.zero
				end

				if root.AssemblyAngularVelocity.Magnitude > 75 then
					root.AssemblyAngularVelocity =
						Vector3.zero
				end
			end

			for _, player in ipairs(
				Players:GetPlayers()
			) do
				if player ~= LocalPlayer
					and player.Character then

					for _, object in ipairs(
						player.Character:GetDescendants()
					) do
						if object:IsA("BasePart") then
							if AntiCollisionCache[object] == nil then
								AntiCollisionCache[object] =
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
	Config.AntiFlingEnabled = state

	if state then
		StartAntiFling()
	else
		StopAntiFling()
	end
end

--========================================================
-- UNIVERSAL VISUALS PAGE
--========================================================

CreateSection(
	VisualsPage,
	"Visuals",
	"Player rendering and color customization."
)

local ESPController = CreateToggle(
	VisualsPage,

	"Player ESP",

	"Highlight players through geometry.",

	Config.ESPEnabled,

	SetESP
)

--========================================================
-- BIG HSV COLOR PICKER
--========================================================

local PickerCard = CreateCard(
	VisualsPage,
	57
)

local PickerTitle = New("TextLabel", {
	Position = UDim2.fromOffset(13, 8),

	Size = UDim2.new(
		1,
		-100,
		0,
		18
	),

	BackgroundTransparency = 1,

	Text = "ESP Color",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Text,
})

PickerTitle.Parent = PickerCard

BindTheme(PickerTitle, {
	TextColor3 = "Text",
})

local PickerSub = New("TextLabel", {
	Position = UDim2.fromOffset(13, 29),

	Size = UDim2.new(
		1,
		-110,
		0,
		15
	),

	BackgroundTransparency = 1,

	Text = "Full HSV palette and quick presets.",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

PickerSub.Parent = PickerCard

BindTheme(PickerSub, {
	TextColor3 = "SubText",
})

local ESPPreview = New("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),

	Position = UDim2.new(
		1,
		-47,
		0.5,
		0
	),

	Size = UDim2.fromOffset(23, 23),

	BackgroundColor3 = Config.ESPColor,
	BorderSizePixel = 0,
})

Round(ESPPreview, 8)

Stroke(
	ESPPreview,
	Color3.new(1, 1, 1),
	0.6,
	1
)

ESPPreview.Parent = PickerCard

local PickerArrow = New("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),

	Position = UDim2.new(
		1,
		-10,
		0.5,
		0
	),

	Size = UDim2.fromOffset(25, 25),

	BackgroundColor3 = Theme.Surface3,
	BackgroundTransparency = 0,

	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "⌄",

	TextSize = 15,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.SubText,
})

Round(PickerArrow, 9)

PickerArrow.Parent = PickerCard

BindTheme(PickerArrow, {
	BackgroundColor3 = "Surface3",
	TextColor3 = "SubText",
})

AnimateButton(PickerArrow)

local PickerBody = New("Frame", {
	Position = UDim2.fromOffset(13, 65),

	Size = UDim2.new(
		1,
		-26,
		0,
		188
	),

	BackgroundTransparency = 1,
})

PickerBody.Parent = PickerCard

local SVBox = New("Frame", {
	Size = UDim2.new(
		1,
		0,
		0,
		108
	),

	BackgroundColor3 =
		Color3.fromHSV(
			0.73,
			1,
			1
		),

	BorderSizePixel = 0,

	Active = true,
})

Round(SVBox, 13)

SVBox.Parent = PickerBody

local WhiteLayer = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
})

Round(WhiteLayer, 13)

WhiteLayer.Parent = SVBox

local WhiteGradient = New("UIGradient", {
	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	}),
})

WhiteGradient.Parent = WhiteLayer

local BlackLayer = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Color3.new(0, 0, 0),
	BorderSizePixel = 0,
})

Round(BlackLayer, 13)

BlackLayer.Parent = SVBox

local BlackGradient = New("UIGradient", {
	Rotation = 90,

	Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0),
	}),
})

BlackGradient.Parent = BlackLayer

local SVMarker = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(
		0.78,
		0
	),

	Size = UDim2.fromOffset(14, 14),

	BackgroundTransparency = 1,
})

Circle(SVMarker)

Stroke(
	SVMarker,
	Color3.new(1, 1, 1),
	0,
	2
)

SVMarker.Parent = SVBox

local HueBar = New("Frame", {
	Position = UDim2.fromOffset(0, 118),

	Size = UDim2.new(
		1,
		0,
		0,
		14
	),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,

	Active = true,
})

Round(HueBar, 7)

HueBar.Parent = PickerBody

local HuePoints = {}

for i = 0, 12 do
	local hue = i / 12

	table.insert(
		HuePoints,
		ColorSequenceKeypoint.new(
			hue,
			Color3.fromHSV(
				hue,
				1,
				1
			)
		)
	)
end

local HueGradient = New("UIGradient", {
	Color = ColorSequence.new(HuePoints),
})

HueGradient.Parent = HueBar

local HueMarker = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(
		0.73,
		0.5
	),

	Size = UDim2.fromOffset(5, 21),

	BackgroundColor3 = Color3.new(1, 1, 1),
	BorderSizePixel = 0,
})

Round(HueMarker, 3)

Stroke(
	HueMarker,
	Color3.new(0, 0, 0),
	0.4,
	1
)

HueMarker.Parent = HueBar

local PresetsHolder = New("Frame", {
	Position = UDim2.fromOffset(0, 143),

	Size = UDim2.new(
		1,
		0,
		0,
		30
	),

	BackgroundTransparency = 1,
})

PresetsHolder.Parent = PickerBody

local PresetLayout = New("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,

	HorizontalAlignment =
		Enum.HorizontalAlignment.Left,

	VerticalAlignment =
		Enum.VerticalAlignment.Center,

	Padding = UDim.new(0, 7),

	SortOrder = Enum.SortOrder.LayoutOrder,
})

PresetLayout.Parent = PresetsHolder

local Hue = 0.73
local Saturation = 0.78
local Value = 1

local HueDragging = false
local SVDragging = false
local PickerOpen = false

local function RefreshPickerColor()
	Config.ESPColor =
		Color3.fromHSV(
			Hue,
			Saturation,
			Value
		)

	ESPPreview.BackgroundColor3 =
		Config.ESPColor

	SVBox.BackgroundColor3 =
		Color3.fromHSV(
			Hue,
			1,
			1
		)

	RefreshESPColor()
end

local function SetPickerColor(color)
	local h, s, v = color:ToHSV()

	Hue = h
	Saturation = s
	Value = v

	HueMarker.Position =
		UDim2.fromScale(
			Hue,
			0.5
		)

	SVMarker.Position =
		UDim2.fromScale(
			Saturation,
			1 - Value
		)

	RefreshPickerColor()
end

local PresetColors = {
	Color3.fromRGB(255, 82, 108),
	Color3.fromRGB(255, 159, 67),
	Color3.fromRGB(255, 221, 80),
	Color3.fromRGB(72, 225, 144),
	Color3.fromRGB(60, 204, 255),
	Color3.fromRGB(90, 130, 255),
	Color3.fromRGB(171, 93, 255),
	Color3.fromRGB(255, 91, 208),
	Color3.fromRGB(245, 245, 255),
}

for index, color in ipairs(PresetColors) do
	local preset = New("TextButton", {
		Size = UDim2.fromOffset(24, 24),

		BackgroundColor3 = color,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "",

		LayoutOrder = index,
	})

	Round(preset, 8)

	Stroke(
		preset,
		Color3.new(1, 1, 1),
		0.72,
		1
	)

	preset.Parent = PresetsHolder

	AnimateButton(preset)

	preset.MouseButton1Click:Connect(function()
		SetPickerColor(color)
	end)
end

local function UpdateHue(x)
	if HueBar.AbsoluteSize.X <= 0 then
		return
	end

	Hue = math.clamp(
		(x - HueBar.AbsolutePosition.X)
		/ HueBar.AbsoluteSize.X,
		0,
		1
	)

	HueMarker.Position =
		UDim2.fromScale(
			Hue,
			0.5
		)

	RefreshPickerColor()
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

	RefreshPickerColor()
end

HueBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		HueDragging = true
		UpdateHue(input.Position.X)
	end
end)

SVBox.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		SVDragging = true
		UpdateSV(input.Position)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseMovement
		and input.UserInputType ~= Enum.UserInputType.Touch then

		return
	end

	if HueDragging then
		UpdateHue(input.Position.X)
	end

	if SVDragging then
		UpdateSV(input.Position)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		HueDragging = false
		SVDragging = false
	end
end)

local function SetPickerOpen(state)
	PickerOpen = state

	PickerArrow.Text =
		state
		and "⌃"
		or "⌄"

	local targetHeight =
		state
		and 263
		or 57

	if Config.Animations then
		Tween(
			PickerCard,
			0.68,
			{
				Size = UDim2.new(
					1,
					0,
					0,
					targetHeight
				),
			},
			Enum.EasingStyle.Quint
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
	SetPickerOpen(not PickerOpen)
end)

--========================================================
-- PLAYER PAGE
--========================================================

CreateSection(
	PlayerPage,
	"Player",
	"Local character information."
)

local PlayerInfoCard = CreateCard(
	PlayerPage,
	92
)

local PlayerNameLabel = New("TextLabel", {
	Position = UDim2.fromOffset(13, 10),

	Size = UDim2.new(
		1,
		-26,
		0,
		17
	),

	BackgroundTransparency = 1,

	Text = "Player  ·  " .. LocalPlayer.Name,

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 10,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Text,
})

PlayerNameLabel.Parent = PlayerInfoCard

BindTheme(PlayerNameLabel, {
	TextColor3 = "Text",
})

local DisplayNameLabel = New("TextLabel", {
	Position = UDim2.fromOffset(13, 32),

	Size = UDim2.new(
		1,
		-26,
		0,
		15
	),

	BackgroundTransparency = 1,

	Text =
		"Display Name  ·  "
		.. LocalPlayer.DisplayName,

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

DisplayNameLabel.Parent = PlayerInfoCard

BindTheme(DisplayNameLabel, {
	TextColor3 = "SubText",
})

local DeviceLabel = New("TextLabel", {
	Position = UDim2.fromOffset(13, 52),

	Size = UDim2.new(
		1,
		-26,
		0,
		15
	),

	BackgroundTransparency = 1,

	Text =
		UserInputService.TouchEnabled
		and "Input  ·  Touch"
		or "Input  ·  Keyboard / Mouse",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

DeviceLabel.Parent = PlayerInfoCard

BindTheme(DeviceLabel, {
	TextColor3 = "SubText",
})

local SpeedInfoLabel = New("TextLabel", {
	Position = UDim2.fromOffset(13, 71),

	Size = UDim2.new(
		1,
		-26,
		0,
		14
	),

	BackgroundTransparency = 1,

	Text = "WalkSpeed  ·  16",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Accent,
})

SpeedInfoLabel.Parent = PlayerInfoCard

RunService.RenderStepped:Connect(function()
	local humanoid = GetHumanoid()

	if humanoid and SpeedInfoLabel.Parent then
		SpeedInfoLabel.Text =
			"WalkSpeed  ·  "
			.. tostring(
				math.floor(humanoid.WalkSpeed)
			)

		SpeedInfoLabel.TextColor3 =
			Theme.Accent
	end
end)

--========================================================
-- GAME PAGE
--========================================================

CreateSection(
	GamePage,
	"Game",
	"Movement and superhero flight."
)

local FlyController = CreateToggle(
	GamePage,

	"Superhero Fly",

	"Smooth cinematic flight with a superhero pose.",

	Config.FlyEnabled,

	SetFly
)

CreateSlider(
	GamePage,

	"Flight Speed",

	10,
	300,

	Config.FlySpeed,

	function(value)
		Config.FlySpeed = value
	end
)

CreateSlider(
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

local SpeedController = CreateToggle(
	GamePage,

	"Speed",

	"Override the local character WalkSpeed.",

	Config.SpeedEnabled,

	SetSpeed
)

CreateSlider(
	GamePage,

	"WalkSpeed",

	16,
	250,

	Config.WalkSpeed,

	function(value)
		Config.WalkSpeed = value
		UpdateWalkSpeed()
	end
)

--========================================================
-- MISC PAGE
--========================================================

CreateSection(
	MiscPage,
	"Misc",
	"Local physics utilities."
)

local ImpactController = CreateToggle(
	MiscPage,

	"Impact Spin",

	"Controlled local rotational physics.",

	Config.ImpactSpinEnabled,

	SetImpactSpin
)

local AntiFlingController = CreateToggle(
	MiscPage,

	"Anti-Fling",

	"Suppress abnormal velocity and collisions.",

	Config.AntiFlingEnabled,

	SetAntiFling
)

--========================================================
-- SETTINGS PAGE
--========================================================

CreateSection(
	SettingsPage,
	"Settings",
	"Interface scale and motion preferences."
)

CreateToggle(
	SettingsPage,

	"Smooth Animations",

	"Enable longer animated transitions.",

	Config.Animations,

	function(state)
		Config.Animations = state
	end
)

--========================================================
-- RESPONSIVE SCALE
--========================================================

local function UpdateResponsiveScale()
	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	local viewport = camera.ViewportSize

	local fitScale = math.min(
		(viewport.X - 18) / 600,
		(viewport.Y - 18) / 380,
		1.2
	)

	MainScale.Scale =
		math.min(
			Config.UIScale,
			fitScale
		)
end

CreateSlider(
	SettingsPage,

	"Interface Size",

	65,
	115,

	math.floor(
		Config.UIScale * 100
	),

	function(value)
		Config.UIScale = value / 100
		UpdateResponsiveScale()
	end,

	"%"
)

CreateAction(
	SettingsPage,

	"Reset Window",

	"Move the menu back to the center.",

	"RESET",

	function()
		Tween(
			MainGroup,
			0.7,
			{
				Position =
					UDim2.fromScale(
						0.5,
						0.5
					),
			},
			Enum.EasingStyle.Quint
		)
	end
)

CreateAction(
	SettingsPage,

	"Reset Open Button",

	"Restore the floating button position.",

	"RESET",

	function()
		Tween(
			OpenButton,
			0.7,
			{
				Position =
					UDim2.new(
						0,
						16,
						0.5,
						0
					),
			},
			Enum.EasingStyle.Quint
		)
	end
)

--========================================================
-- HUB
--========================================================

CreateSection(
	HubPage,
	"Hub",
	"Open an independent profile."
)

local HubGridHolder = New("Frame", {
	Size = UDim2.new(
		1,
		0,
		0,
		142
	),

	BackgroundTransparency = 1,
})

HubGridHolder.Parent = HubPage

local HubGrid = New("UIGridLayout", {
	CellPadding = UDim2.fromOffset(8, 0),

	CellSize = UDim2.new(
		0.5,
		-4,
		1,
		0
	),

	FillDirectionMaxCells = 2,

	SortOrder = Enum.SortOrder.LayoutOrder,
})

HubGrid.Parent = HubGridHolder

local function CreateProfileCard(
	parent,
	title,
	tag,
	description,
	icon,
	order,
	callback
)
	local card = New("Frame", {
		Size = UDim2.fromScale(1, 1),

		BackgroundColor3 = Theme.Surface2,
		BorderSizePixel = 0,

		LayoutOrder = order,
	})

	Round(card, 18)

	local cardStroke = Stroke(
		card,
		Theme.Stroke,
		0.38,
		1
	)

	card.Parent = parent

	BindTheme(card, {
		BackgroundColor3 = "Surface2",
	})

	BindTheme(cardStroke, {
		Color = "Stroke",
	})

	local iconBox = New("Frame", {
		Position = UDim2.fromOffset(12, 12),

		Size = UDim2.fromOffset(32, 32),

		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,
	})

	Round(iconBox, 11)

	iconBox.Parent = card

	BindTheme(iconBox, {
		BackgroundColor3 = "Surface3",
	})

	local iconLabel = New("TextLabel", {
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		Text = icon,

		TextSize = 15,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Accent,
	})

	iconLabel.Parent = iconBox

	BindTheme(iconLabel, {
		TextColor3 = "Accent",
	})

	local tagLabel = New("TextLabel", {
		Position = UDim2.fromOffset(52, 12),

		Size = UDim2.new(
			1,
			-64,
			0,
			13
		),

		BackgroundTransparency = 1,

		Text = tag,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 7,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Accent,
	})

	tagLabel.Parent = card

	BindTheme(tagLabel, {
		TextColor3 = "Accent",
	})

	local titleLabel = New("TextLabel", {
		Position = UDim2.fromOffset(52, 26),

		Size = UDim2.new(
			1,
			-64,
			0,
			18
		),

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

	local descriptionLabel = New("TextLabel", {
		Position = UDim2.fromOffset(12, 54),

		Size = UDim2.new(
			1,
			-24,
			0,
			36
		),

		BackgroundTransparency = 1,

		Text = description,

		TextWrapped = true,

		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,

		TextSize = 8,
		Font = Enum.Font.GothamMedium,

		TextColor3 = Theme.SubText,
	})

	descriptionLabel.Parent = card

	BindTheme(descriptionLabel, {
		TextColor3 = "SubText",
	})

	local load = New("TextButton", {
		AnchorPoint = Vector2.new(0.5, 1),

		Position = UDim2.new(
			0.5,
			0,
			1,
			-11
		),

		Size = UDim2.new(
			1,
			-24,
			0,
			30
		),

		BackgroundColor3 = Theme.Surface3,
		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "OPEN",

		TextSize = 8,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Text,
	})

	Round(load, 11)

	local loadStroke = Stroke(
		load,
		Theme.Stroke,
		0.25,
		1
	)

	load.Parent = card

	BindTheme(load, {
		BackgroundColor3 = "Surface3",
		TextColor3 = "Text",
	})

	BindTheme(loadStroke, {
		Color = "Stroke",
	})

	AnimateButton(load)

	load.MouseButton1Click:Connect(callback)

	return card
end

--========================================================
-- PROFILE CONTAINER
--========================================================

local ProfileContainer = New("CanvasGroup", {
	Position = UDim2.fromOffset(10, 70),

	Size = UDim2.new(
		1,
		-20,
		1,
		-80
	),

	BackgroundTransparency = 1,

	GroupTransparency = 1,

	Visible = false,

	ZIndex = 15,
})

ProfileContainer.Parent = MainFrame

--========================================================
-- MM2 PROFILE
--========================================================

local MM2Profile = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,

	Visible = false,
})

Round(MM2Profile, 20)

local MM2Stroke = Stroke(
	MM2Profile,
	Theme.Stroke,
	0.35,
	1
)

MM2Profile.Parent = ProfileContainer

BindTheme(MM2Profile, {
	BackgroundColor3 = "Surface",
})

BindTheme(MM2Stroke, {
	Color = "Stroke",
})

local MM2CenterCard = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),

	Position = UDim2.fromScale(0.5, 0.5),

	Size = UDim2.fromOffset(315, 165),

	BackgroundColor3 = Theme.Surface2,
	BorderSizePixel = 0,
})

Round(MM2CenterCard, 24)

local MM2CenterStroke = Stroke(
	MM2CenterCard,
	Theme.Accent,
	0.32,
	1.2
)

MM2CenterCard.Parent = MM2Profile

BindTheme(MM2CenterCard, {
	BackgroundColor3 = "Surface2",
})

BindTheme(MM2CenterStroke, {
	Color = "Accent",
})

local MM2Icon = New("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),

	Position = UDim2.new(
		0.5,
		0,
		0,
		19
	),

	Size = UDim2.fromOffset(44, 44),

	BackgroundColor3 = Theme.Surface3,
	BorderSizePixel = 0,
})

Round(MM2Icon, 15)

MM2Icon.Parent = MM2CenterCard

BindTheme(MM2Icon, {
	BackgroundColor3 = "Surface3",
})

local MM2IconText = New("TextLabel", {
	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Text = "◆",

	TextSize = 19,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Accent,
})

MM2IconText.Parent = MM2Icon

BindTheme(MM2IconText, {
	TextColor3 = "Accent",
})

local MM2MainTitle = New("TextLabel", {
	Position = UDim2.fromOffset(15, 76),

	Size = UDim2.new(
		1,
		-30,
		0,
		22
	),

	BackgroundTransparency = 1,

	Text = "Murder Mystery 2",

	TextSize = 15,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Text,
})

MM2MainTitle.Parent = MM2CenterCard

BindTheme(MM2MainTitle, {
	TextColor3 = "Text",
})

local MM2MainSub = New("TextLabel", {
	Position = UDim2.fromOffset(20, 105),

	Size = UDim2.new(
		1,
		-40,
		0,
		34
	),

	BackgroundTransparency = 1,

	Text = "MM2 profile is active.\nUniversal modules are disabled.",

	TextWrapped = true,

	TextSize = 8,
	Font = Enum.Font.GothamMedium,

	TextColor3 = Theme.SubText,
})

MM2MainSub.Parent = MM2CenterCard

BindTheme(MM2MainSub, {
	TextColor3 = "SubText",
})

--========================================================
-- AIM PROFILE SHELL
--========================================================

local AimProfile = New("Frame", {
	Size = UDim2.fromScale(1, 1),

	BackgroundTransparency = 1,

	Visible = false,
})

AimProfile.Parent = ProfileContainer

local AimSidebar = New("Frame", {
	Size = UDim2.new(
		0,
		116,
		1,
		0
	),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,
})

Round(AimSidebar, 19)

local AimSidebarStroke = Stroke(
	AimSidebar,
	Theme.Stroke,
	0.38,
	1
)

AimSidebar.Parent = AimProfile

BindTheme(AimSidebar, {
	BackgroundColor3 = "Surface",
})

BindTheme(AimSidebarStroke, {
	Color = "Stroke",
})

local AimNavTitle = New("TextLabel", {
	Position = UDim2.fromOffset(13, 12),

	Size = UDim2.new(
		1,
		-26,
		0,
		15
	),

	BackgroundTransparency = 1,

	Text = "AIM PROFILE",

	TextXAlignment = Enum.TextXAlignment.Left,

	TextSize = 8,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Accent,
})

AimNavTitle.Parent = AimSidebar

BindTheme(AimNavTitle, {
	TextColor3 = "Accent",
})

local AimTabsHolder = New("Frame", {
	Position = UDim2.fromOffset(8, 38),

	Size = UDim2.new(
		1,
		-16,
		0,
		82
	),

	BackgroundTransparency = 1,
})

AimTabsHolder.Parent = AimSidebar

local AimTabsLayout = New("UIListLayout", {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

AimTabsLayout.Parent = AimTabsHolder

local AimStatusSmall = New("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 1),

	Position = UDim2.new(
		0.5,
		0,
		1,
		-13
	),

	Size = UDim2.new(
		1,
		-20,
		0,
		28
	),

	BackgroundTransparency = 1,

	Text = "AIM\nOFF",

	TextSize = 8,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.SubText,
})

AimStatusSmall.Parent = AimSidebar

local AimContent = New("Frame", {
	Position = UDim2.fromOffset(126, 0),

	Size = UDim2.new(
		1,
		-126,
		1,
		0
	),

	BackgroundColor3 = Theme.Surface,
	BorderSizePixel = 0,

	ClipsDescendants = true,
})

Round(AimContent, 19)

local AimContentStroke = Stroke(
	AimContent,
	Theme.Stroke,
	0.38,
	1
)

AimContent.Parent = AimProfile

BindTheme(AimContent, {
	BackgroundColor3 = "Surface",
})

BindTheme(AimContentStroke, {
	Color = "Stroke",
})

local AimPages = {}
local AimTabButtons = {}

local function CreateAimPage(name)
	local group = New("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		GroupTransparency = 1,

		Visible = false,
	})

	group.Parent = AimContent

	local scroll = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,

		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromOffset(0, 0),
	})

	Padding(scroll, 13, 13, 12, 16)

	scroll.Parent = group

	local layout = New("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	layout.Parent = scroll

	AimPages[name] = {
		Group = group,
		Scroll = scroll,
	}

	return scroll
end

local AimVisualsPage =
	CreateAimPage("Visuals")

local AimSettingsPage =
	CreateAimPage("Aim")

local function RefreshAimTabs()
	for name, button in pairs(AimTabButtons) do
		local active =
			Config.AimTab == name

		if active then
			button.BackgroundColor3 = Theme.Surface3
			button.BackgroundTransparency = 0
			button.TextColor3 = Theme.Text
		else
			button.BackgroundTransparency = 1
			button.TextColor3 = Theme.SubText
		end
	end
end

local function SwitchAimTab(name)
	if not AimPages[name] then
		return
	end

	Config.AimTab = name

	for pageName, data in pairs(AimPages) do
		if pageName ~= name then
			data.Group.Visible = false
			data.Group.GroupTransparency = 1
		end
	end

	local selected = AimPages[name]

	selected.Group.Visible = true
	selected.Group.GroupTransparency = 1
	selected.Group.Position =
		UDim2.fromOffset(12, 0)

	if Config.Animations then
		Tween(
			selected.Group,
			0.55,
			{
				GroupTransparency = 0,

				Position =
					UDim2.fromOffset(
						0,
						0
					),
			},
			Enum.EasingStyle.Quint
		)
	else
		selected.Group.GroupTransparency = 0
	end

	RefreshAimTabs()
end

for index, data in ipairs({
	{"Visuals", "◉"},
	{"Aim", "◎"},
}) do
	local name = data[1]
	local icon = data[2]

	local button = New("TextButton", {
		Size = UDim2.new(
			1,
			0,
			0,
			35
		),

		BackgroundColor3 = Theme.Surface3,
		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = "  " .. icon .. "   " .. name,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextSize = 9,
		Font = Enum.Font.GothamMedium,

		TextColor3 = Theme.SubText,

		LayoutOrder = index,
	})

	Round(button, 11)

	button.Parent = AimTabsHolder

	AimTabButtons[name] = button

	AnimateButton(button)

	button.MouseButton1Click:Connect(function()
		SwitchAimTab(name)
	end)
end

AddThemeRefresher(RefreshAimTabs)

--========================================================
-- AIM ENGINE
--========================================================

local CurrentAimTarget
local CurrentTargetHighlight

local AimToggleController

local function RemoveAimHighlight()
	if CurrentTargetHighlight then
		CurrentTargetHighlight:Destroy()
		CurrentTargetHighlight = nil
	end
end

local function SetCurrentAimTarget(player)
	if CurrentAimTarget == player then
		return
	end

	CurrentAimTarget = player

	RemoveAimHighlight()

	if not player then
		return
	end

	if not Config.AimTargetHighlight then
		return
	end

	local character = player.Character

	if not character then
		return
	end

	CurrentTargetHighlight = New("Highlight", {
		Name = "AntiFreakAimTarget",

		Adornee = character,

		FillColor = Theme.Accent,
		FillTransparency = 0.78,

		OutlineColor = Theme.Accent,
		OutlineTransparency = 0,

		DepthMode =
			Enum.HighlightDepthMode.AlwaysOnTop,
	})

	CurrentTargetHighlight.Parent = character
end

local function IsTargetVisible(character, targetPart)
	if not Config.AimWallCheck then
		return true
	end

	local camera = Workspace.CurrentCamera

	if not camera then
		return false
	end

	local params = RaycastParams.new()

	params.FilterType =
		Enum.RaycastFilterType.Exclude

	local ignore = {}

	local localCharacter = GetCharacter()

	if localCharacter then
		table.insert(
			ignore,
			localCharacter
		)
	end

	params.FilterDescendantsInstances =
		ignore

	params.IgnoreWater = true

	local direction =
		targetPart.Position
		- camera.CFrame.Position

	local result =
		Workspace:Raycast(
			camera.CFrame.Position,
			direction,
			params
		)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(
		character
	)
end

local function GetTargetPart(character)
	if not character then
		return nil
	end

	if Config.AimTargetPart == "Head" then
		return character:FindFirstChild("Head")
			or character:FindFirstChild(
				"HumanoidRootPart"
			)
	end

	return character:FindFirstChild(
		"HumanoidRootPart"
	) or character:FindFirstChild("Head")
end

local function GetBestAimTarget()
	local camera = Workspace.CurrentCamera

	if not camera then
		return nil, nil
	end

	local viewport = camera.ViewportSize

	local center =
		Vector2.new(
			viewport.X / 2,
			viewport.Y / 2
		)

	local bestPlayer
	local bestPart

	local bestDistance =
		Config.FOVRadius

	local localRoot = GetRoot()

	for _, player in ipairs(
		Players:GetPlayers()
	) do
		if player == LocalPlayer then
			continue
		end

		local character = player.Character

		if not character then
			continue
		end

		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)

		if not humanoid
			or humanoid.Health <= 0 then

			continue
		end

		if Config.AimTeamCheck
			and LocalPlayer.Team ~= nil
			and player.Team == LocalPlayer.Team then

			continue
		end

		local targetPart =
			GetTargetPart(character)

		if not targetPart then
			continue
		end

		if localRoot then
			local worldDistance =
				(targetPart.Position - localRoot.Position)
				.Magnitude

			if worldDistance
				> Config.AimMaxDistance then

				continue
			end
		end

		local screenPoint, onScreen =
			camera:WorldToViewportPoint(
				targetPart.Position
			)

		if not onScreen
			or screenPoint.Z <= 0 then

			continue
		end

		local screenPosition =
			Vector2.new(
				screenPoint.X,
				screenPoint.Y
			)

		local screenDistance =
			(screenPosition - center).Magnitude

		if screenDistance
			> Config.FOVRadius then

			continue
		end

		if not IsTargetVisible(
			character,
			targetPart
		) then
			continue
		end

		if screenDistance < bestDistance then
			bestDistance = screenDistance
			bestPlayer = player
			bestPart = targetPart
		end
	end

	return bestPlayer, bestPart
end

local function RefreshAimStatus()
	if Config.AimEnabled then
		AimStatusSmall.Text = "AIM\nON"
		AimStatusSmall.TextColor3 =
			Theme.Success
	else
		AimStatusSmall.Text = "AIM\nOFF"
		AimStatusSmall.TextColor3 =
			Theme.SubText
	end
end

local function SetAimEnabled(state)
	Config.AimEnabled = state

	if not state then
		SetCurrentAimTarget(nil)
	end

	if AimToggleController
		and AimToggleController:Get() ~= state then

		AimToggleController:Set(
			state,
			false
		)
	end

	RefreshAimStatus()
end

--========================================================
-- AIM VISUALS TAB
--========================================================

CreateSection(
	AimVisualsPage,
	"Visuals",
	"FOV and target appearance."
)

CreateToggle(
	AimVisualsPage,

	"Show FOV",

	"Display the aim field-of-view circle.",

	Config.ShowFOV,

	function(state)
		Config.ShowFOV = state
	end
)

CreateSlider(
	AimVisualsPage,

	"FOV Radius",

	45,
	320,

	Config.FOVRadius,

	function(value)
		Config.FOVRadius = value
	end,

	" px"
)

CreateSlider(
	AimVisualsPage,

	"FOV Opacity",

	5,
	95,

	Config.FOVOpacity,

	function(value)
		Config.FOVOpacity = value
	end,

	"%"
)

CreateSlider(
	AimVisualsPage,

	"FOV Thickness",

	1,
	5,

	Config.FOVThickness,

	function(value)
		Config.FOVThickness = value
	end
)

CreateToggle(
	AimVisualsPage,

	"Target Highlight",

	"Highlight the currently selected target.",

	Config.AimTargetHighlight,

	function(state)
		Config.AimTargetHighlight = state

		if not state then
			RemoveAimHighlight()
		elseif CurrentAimTarget then
			local player = CurrentAimTarget

			CurrentAimTarget = nil

			SetCurrentAimTarget(player)
		end
	end
)

--========================================================
-- AIM SETTINGS TAB
--========================================================

CreateSection(
	AimSettingsPage,
	"Aim",
	"Target selection and camera assistance."
)

AimToggleController = CreateToggle(
	AimSettingsPage,

	"Aim Assist",

	"Lock toward the closest target inside FOV.",

	Config.AimEnabled,

	SetAimEnabled
)

CreateSlider(
	AimSettingsPage,

	"Aim Sharpness",

	2,
	35,

	Config.AimSharpness,

	function(value)
		Config.AimSharpness = value
	end
)

CreateSlider(
	AimSettingsPage,

	"Max Distance",

	100,
	2500,

	Config.AimMaxDistance,

	function(value)
		Config.AimMaxDistance = value
	end,

	" studs"
)

CreateToggle(
	AimSettingsPage,

	"Wall Check",

	"Only select targets visible from the camera.",

	Config.AimWallCheck,

	function(state)
		Config.AimWallCheck = state
	end
)

CreateToggle(
	AimSettingsPage,

	"Team Check",

	"Ignore players on your team.",

	Config.AimTeamCheck,

	function(state)
		Config.AimTeamCheck = state
	end
)

local TargetPartAction

TargetPartAction =
	CreateAction(
		AimSettingsPage,

		"Target Part",

		"Current target: Head",

		"HEAD",

		function(button)
			if Config.AimTargetPart == "Head" then
				Config.AimTargetPart =
					"HumanoidRootPart"

				button.Text = "ROOT"

				local parent = button.Parent

				for _, object in ipairs(
					parent:GetChildren()
				) do
					if object:IsA("TextLabel")
						and object.Text:find(
							"Current target:"
						) then

						object.Text =
							"Current target: Root"
					end
				end
			else
				Config.AimTargetPart = "Head"

				button.Text = "HEAD"

				local parent = button.Parent

				for _, object in ipairs(
					parent:GetChildren()
				) do
					if object:IsA("TextLabel")
						and object.Text:find(
							"Current target:"
						) then

						object.Text =
							"Current target: Head"
					end
				end
			end
		end
	)

--========================================================
-- TOUCH AIM BUTTON
--========================================================

local AimTouchButton = New("TextButton", {
	Name = "AimTouchButton",

	AnchorPoint = Vector2.new(1, 0.5),

	Position = UDim2.new(
		1,
		-16,
		0.5,
		0
	),

	Size = UDim2.fromOffset(68, 68),

	BackgroundColor3 = Theme.Surface2,
	BackgroundTransparency = 0.06,

	BorderSizePixel = 0,

	AutoButtonColor = false,

	Text = "AIM\nOFF",

	TextSize = 10,
	Font = Enum.Font.GothamBold,

	TextColor3 = Theme.Text,

	Visible = false,

	ZIndex = 95,
})

Round(AimTouchButton, 23)

local AimTouchStroke = Stroke(
	AimTouchButton,
	Theme.Accent,
	0.1,
	1.5
)

AimTouchButton.Parent = Gui

BindTheme(AimTouchButton, {
	BackgroundColor3 = "Surface2",
	TextColor3 = "Text",
})

BindTheme(AimTouchStroke, {
	Color = "Accent",
})

AnimateButton(AimTouchButton)
MakeDraggable(AimTouchButton)

local function RefreshAimTouchButton()
	if Config.AimEnabled then
		AimTouchButton.Text = "AIM\nON"

		AimTouchButton.BackgroundColor3 =
			Theme.Accent

		AimTouchButton.TextColor3 =
			Color3.new(1, 1, 1)
	else
		AimTouchButton.Text = "AIM\nOFF"

		AimTouchButton.BackgroundColor3 =
			Theme.Surface2

		AimTouchButton.TextColor3 =
			Theme.Text
	end
end

AddThemeRefresher(
	RefreshAimTouchButton
)

AimTouchButton.MouseButton1Click:Connect(function()
	SetAimEnabled(
		not Config.AimEnabled
	)

	RefreshAimTouchButton()
end)

--========================================================
-- AIM RENDER LOOP
--========================================================

RunService.RenderStepped:Connect(function(deltaTime)
	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	local aimProfileActive =
		Config.CurrentProfile == "AIM"

	-- FOV
	FOVRing.Visible =
		aimProfileActive
		and Config.ShowFOV

	FOVRing.Position =
		UDim2.fromOffset(
			camera.ViewportSize.X / 2,
			camera.ViewportSize.Y / 2
		)

	local diameter =
		Config.FOVRadius * 2

	FOVRing.Size =
		UDim2.fromOffset(
			diameter,
			diameter
		)

	FOVStroke.Color =
		Config.AimFOVColor

	FOVStroke.Thickness =
		Config.FOVThickness

	FOVStroke.Transparency =
		Config.FOVOpacity / 100

	-- TOUCH BUTTON
	AimTouchButton.Visible =
		aimProfileActive
		and UserInputService.TouchEnabled

	-- AIM
	if not aimProfileActive
		or not Config.AimEnabled then

		if CurrentAimTarget then
			SetCurrentAimTarget(nil)
		end

		return
	end

	local player, part =
		GetBestAimTarget()

	SetCurrentAimTarget(player)

	if not player or not part then
		return
	end

	local targetCFrame =
		CFrame.lookAt(
			camera.CFrame.Position,
			part.Position
		)

	local alpha =
		1
		- math.exp(
			-Config.AimSharpness
			* deltaTime
		)

	camera.CFrame =
		camera.CFrame:Lerp(
			targetCFrame,
			math.clamp(
				alpha,
				0,
				1
			)
		)
end)

--========================================================
-- TOUCH FLIGHT BUTTONS
--========================================================

local FlyTouchHolder = New("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),

	Position = UDim2.new(
		1,
		-15,
		0.5,
		0
	),

	Size = UDim2.fromOffset(60, 126),

	BackgroundTransparency = 1,

	Visible = false,

	ZIndex = 92,
})

FlyTouchHolder.Parent = Gui

local function CreateFlyButton(y, text)
	local button = New("TextButton", {
		Position = UDim2.fromOffset(0, y),

		Size = UDim2.fromOffset(58, 58),

		BackgroundColor3 = Theme.Surface2,
		BackgroundTransparency = 0.06,

		BorderSizePixel = 0,

		AutoButtonColor = false,

		Text = text,

		TextSize = 9,
		Font = Enum.Font.GothamBold,

		TextColor3 = Theme.Text,
	})

	Round(button, 20)

	local stroke = Stroke(
		button,
		Theme.Accent,
		0.15,
		1.3
	)

	button.Parent = FlyTouchHolder

	BindTheme(button, {
		BackgroundColor3 = "Surface2",
		TextColor3 = "Text",
	})

	BindTheme(stroke, {
		Color = "Accent",
	})

	AnimateButton(button)

	return button
end

local FlyUpButton =
	CreateFlyButton(
		0,
		"▲\nUP"
	)

local FlyDownButton =
	CreateFlyButton(
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

BindHold(
	FlyUpButton,
	function(state)
		FlyUp = state
	end
)

BindHold(
	FlyDownButton,
	function(state)
		FlyDown = state
	end
)

RunService.RenderStepped:Connect(function()
	FlyTouchHolder.Visible =
		Config.FlyEnabled
		and UserInputService.TouchEnabled
		and Config.CurrentProfile == nil
end)

--========================================================
-- UNIVERSAL STATE REGISTRY
--========================================================

local function SaveUniversalState()
	UniversalSavedState = {
		ESP = Config.ESPEnabled,
		Fly = Config.FlyEnabled,
		Speed = Config.SpeedEnabled,
		Impact = Config.ImpactSpinEnabled,
		AntiFling = Config.AntiFlingEnabled,
	}
end

local function DisableUniversalModules()
	SetESP(false)
	SetFly(false)
	SetSpeed(false)
	SetImpactSpin(false)
	SetAntiFling(false)

	ESPController:Set(false, false)
	FlyController:Set(false, false)
	SpeedController:Set(false, false)
	ImpactController:Set(false, false)
	AntiFlingController:Set(false, false)

	FlyTouchHolder.Visible = false
end

local function RestoreUniversalState()
	if UniversalSavedState.ESP then
		SetESP(true)
		ESPController:Set(true, false)
	end

	if UniversalSavedState.Fly then
		SetFly(true)
		FlyController:Set(true, false)
	end

	if UniversalSavedState.Speed then
		SetSpeed(true)
		SpeedController:Set(true, false)
	end

	if UniversalSavedState.Impact then
		SetImpactSpin(true)
		ImpactController:Set(true, false)
	end

	if UniversalSavedState.AntiFling then
		SetAntiFling(true)
		AntiFlingController:Set(true, false)
	end
end

--========================================================
-- PROFILE OPEN / CLOSE
--========================================================

local function OpenProfile(profileName)
	if Config.CurrentProfile then
		return
	end

	SaveUniversalState()
	DisableUniversalModules()

	Config.CurrentProfile = profileName

	Sidebar.Visible = false
	Content.Visible = false

	ProfileContainer.Visible = true
	ProfileContainer.GroupTransparency = 1

	BackButton.Visible = true
	Logo.Visible = false

	HeaderAccent.Visible = false

	HeaderTitle.Position =
		UDim2.fromOffset(60, 7)

	HeaderSubtitle.Position =
		UDim2.fromOffset(60, 26)

	MM2Profile.Visible = false
	AimProfile.Visible = false

	if profileName == "MM2" then
		Theme = Themes.MM2

		HeaderTitle.Text =
			"AntiFreak Hub · MM2"

		HeaderSubtitle.Text =
			"Murder Mystery 2 Profile"

		MM2Profile.Visible = true

		MM2CenterCard.Position =
			UDim2.fromScale(
				0.5,
				0.55
			)

	elseif profileName == "AIM" then
		Theme = Themes.AIM

		HeaderTitle.Text =
			"AntiFreak Hub · AIM"

		HeaderSubtitle.Text =
			"Precision Aim Profile"

		AimProfile.Visible = true

		SwitchAimTab("Aim")

		SetAimEnabled(false)
	end

	ApplyTheme()

	if Config.Animations then
		Tween(
			ProfileContainer,
			0.65,
			{
				GroupTransparency = 0,
			},
			Enum.EasingStyle.Quint
		)

		if profileName == "MM2" then
			Tween(
				MM2CenterCard,
				0.8,
				{
					Position =
						UDim2.fromScale(
							0.5,
							0.5
						),
				},
				Enum.EasingStyle.Back
			)
		end
	else
		ProfileContainer.GroupTransparency = 0

		if profileName == "MM2" then
			MM2CenterCard.Position =
				UDim2.fromScale(
					0.5,
					0.5
				)
		end
	end
end

local function ExitProfile()
	if not Config.CurrentProfile then
		return
	end

	SetAimEnabled(false)
	SetCurrentAimTarget(nil)

	FOVRing.Visible = false
	AimTouchButton.Visible = false

	Config.CurrentProfile = nil

	Theme = Themes.Default

	MM2Profile.Visible = false
	AimProfile.Visible = false

	ProfileContainer.Visible = false
	ProfileContainer.GroupTransparency = 1

	Sidebar.Visible = true
	Content.Visible = true

	BackButton.Visible = false
	Logo.Visible = true

	HeaderAccent.Visible = true

	HeaderTitle.Position =
		UDim2.fromOffset(64, 7)

	HeaderSubtitle.Position =
		UDim2.fromOffset(64, 26)

	HeaderTitle.Text =
		"AntiFreak Hub"

	HeaderSubtitle.Text =
		"Universal Interface"

	ApplyTheme()

	RestoreUniversalState()

	SwitchUniversalTab("Hub")
end

BackButton.MouseButton1Click:Connect(
	ExitProfile
)

--========================================================
-- HUB CARDS
--========================================================

CreateProfileCard(
	HubGridHolder,

	"Murder Mystery 2",

	"MM2 PROFILE",

	"Open a clean blue profile with universal modules disabled.",

	"◆",

	1,

	function()
		OpenProfile("MM2")
	end
)

CreateProfileCard(
	HubGridHolder,

	"Aim",

	"AIM PROFILE",

	"Open a separate aim interface with FOV and targeting controls.",

	"◎",

	2,

	function()
		OpenProfile("AIM")
	end
)

--========================================================
-- MENU OPEN / CLOSE
--========================================================

local MenuBusy = false

local function OpenMenu()
	if Config.MenuOpen
		or MenuBusy then

		return
	end

	MenuBusy = true
	Config.MenuOpen = true

	MainGroup.Visible = true

	UpdateResponsiveScale()

	local finalScale = MainScale.Scale

	if Config.Animations then
		MainScale.Scale =
			finalScale * 0.78

		MainGroup.GroupTransparency = 1

		MainGroup.Position =
			UDim2.new(
				0.5,
				0,
				0.5,
				12
			)

		Tween(
			MainScale,
			0.82,
			{
				Scale = finalScale,
			},
			Enum.EasingStyle.Back
		)

		Tween(
			MainGroup,
			0.62,
			{
				GroupTransparency = 0,

				Position =
					UDim2.fromScale(
						0.5,
						0.5
					),
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			Blur,
			0.6,
			{
				Size = 8,
			},
			Enum.EasingStyle.Quint
		)

		Tween(
			InnerStroke,
			0.9,
			{
				Transparency = 0.88,
			},
			Enum.EasingStyle.Sine
		)

		task.delay(0.85, function()
			MenuBusy = false
		end)
	else
		MainGroup.GroupTransparency = 0
		Blur.Size = 8

		MenuBusy = false
	end
end

local function CloseMenu()
	if not Config.MenuOpen
		or MenuBusy then

		return
	end

	MenuBusy = true
	Config.MenuOpen = false

	if Config.Animations then
		local currentScale =
			MainScale.Scale

		Tween(
			MainScale,
			0.42,
			{
				Scale =
					currentScale * 0.86,
			},
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.In
		)

		Tween(
			MainGroup,
			0.4,
			{
				GroupTransparency = 1,

				Position =
					UDim2.new(
						0.5,
						0,
						0.5,
						10
					),
			},
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.In
		)

		Tween(
			Blur,
			0.45,
			{
				Size = 0,
			}
		)

		task.delay(0.44, function()
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

UserInputService.InputBegan:Connect(
	function(input, processed)
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
	end
)

UserInputService.InputEnded:Connect(
	function(input)
		if input.KeyCode == Enum.KeyCode.Space then
			FlyUp = false
		end

		if input.KeyCode == Enum.KeyCode.LeftShift
			or input.KeyCode == Enum.KeyCode.LeftControl then

			FlyDown = false
		end
	end
)

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

	task.wait(0.3)

	if Config.SpeedEnabled then
		UpdateWalkSpeed()
	end

	if Config.FlyEnabled then
		StartFly()
	end

	if Config.ImpactSpinEnabled then
		StartImpactSpin()
	end

	if Config.AntiFlingEnabled then
		StartAntiFling()
	end
end)

--========================================================
-- CAMERA / RESPONSIVE
--========================================================

local CameraSizeConnection

local function HookCamera()
	if CameraSizeConnection then
		CameraSizeConnection:Disconnect()
		CameraSizeConnection = nil
	end

	local camera = Workspace.CurrentCamera

	if not camera then
		return
	end

	CameraSizeConnection =
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
-- INITIAL STATE
--========================================================

ApplyTheme()

SwitchUniversalTab("Visuals")
SwitchAimTab("Aim")

RefreshAimStatus()
RefreshAimTouchButton()

UpdateResponsiveScale()

MainGroup.Visible = true
MainGroup.GroupTransparency = 1

local startupScale =
	MainScale.Scale

MainScale.Scale =
	startupScale * 0.76

MainGroup.Position =
	UDim2.new(
		0.5,
		0,
		0.5,
		16
	)

if Config.Animations then
	Tween(
		MainScale,
		0.95,
		{
			Scale = startupScale,
		},
		Enum.EasingStyle.Back
	)

	Tween(
		MainGroup,
		0.72,
		{
			GroupTransparency = 0,

			Position =
				UDim2.fromScale(
					0.5,
					0.5
				),
		},
		Enum.EasingStyle.Quint
	)

	Blur.Size = 0

	Tween(
		Blur,
		0.8,
		{
			Size = 8,
		},
		Enum.EasingStyle.Quint
	)
else
	MainScale.Scale = startupScale
	MainGroup.GroupTransparency = 0
	MainGroup.Position =
		UDim2.fromScale(
			0.5,
			0.5
		)

	Blur.Size = 8
end

print("[AntiFreak Hub] Minimal Rounded Edition loaded.")
