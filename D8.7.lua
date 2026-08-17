--[[
    AntiFreak Hub - Stable Minimal Build v7
    LocalScript -> StarterPlayer > StarterPlayerScripts
    Main UI language: English; detail/settings language: EN/RU
]]

--============================================================
-- SERVICES / BOOTSTRAP
--============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("AntiFreakHub")
if oldGui then
    oldGui:Destroy()
end

local oldBlur = Lighting:FindFirstChild("AntiFreakHubBlur")
if oldBlur then
    oldBlur:Destroy()
end

local function New(className, props)
    local object = Instance.new(className)
    if props then
        for key, value in pairs(props) do
            object[key] = value
        end
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

local function Stroke(object, color, transparency, thickness)
    local stroke = New("UIStroke", {
        Color = color,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    })
    stroke.Parent = object
    return stroke
end

local function Padding(object, left, right, top, bottom)
    local padding = New("UIPadding", {
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
    })
    padding.Parent = object
    return padding
end

local function Tween(object, duration, props, style, direction)
    local info = TweenInfo.new(
        duration or 0.45,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, info, props)
    tween:Play()
    return tween
end

local Theme = {
    Background = Color3.fromRGB(9, 10, 14),
    Surface = Color3.fromRGB(15, 17, 23),
    Surface2 = Color3.fromRGB(20, 23, 31),
    Surface3 = Color3.fromRGB(27, 30, 40),
    Accent = Color3.fromRGB(170, 92, 255),
    Accent2 = Color3.fromRGB(98, 118, 255),
    Text = Color3.fromRGB(247, 248, 252),
    SubText = Color3.fromRGB(140, 146, 165),
    Stroke = Color3.fromRGB(50, 54, 69),
    Green = Color3.fromRGB(77, 224, 144),
    Red = Color3.fromRGB(255, 86, 112),
}

local ProfileThemes = {
    MM2 = {
        Background = Color3.fromRGB(5, 10, 17),
        Surface = Color3.fromRGB(7, 20, 33),
        Surface2 = Color3.fromRGB(9, 29, 48),
        Surface3 = Color3.fromRGB(12, 39, 63),
        Accent = Color3.fromRGB(0, 187, 255),
        Accent2 = Color3.fromRGB(0, 104, 225),
        Text = Color3.fromRGB(240, 250, 255),
        SubText = Color3.fromRGB(121, 170, 202),
        Stroke = Color3.fromRGB(25, 75, 105),
        Green = Color3.fromRGB(74, 229, 189),
        Red = Color3.fromRGB(255, 83, 111),
    },
    AIM = {
        Background = Color3.fromRGB(11, 8, 14),
        Surface = Color3.fromRGB(20, 14, 25),
        Surface2 = Color3.fromRGB(28, 19, 35),
        Surface3 = Color3.fromRGB(37, 25, 46),
        Accent = Color3.fromRGB(226, 78, 154),
        Accent2 = Color3.fromRGB(144, 70, 201),
        Text = Color3.fromRGB(252, 246, 251),
        SubText = Color3.fromRGB(173, 144, 165),
        Stroke = Color3.fromRGB(70, 49, 68),
        Green = Color3.fromRGB(80, 229, 147),
        Red = Color3.fromRGB(255, 79, 110),
    },
}

local DefaultTheme = {}
for key, value in pairs(Theme) do
    DefaultTheme[key] = value
end

local Config = {
    MenuOpen = true,
    CurrentTab = "Visuals",
    CurrentProfile = nil,
    UIScale = 0.90,
    Animations = true,

    ESP = false,
    ESPColor = Color3.fromHSV(0.73, 0.78, 1),

    Fly = false,
    FlySpeed = 85,
    FlyTilt = 28,

    Speed = false,
    WalkSpeed = 32,

    ImpactSpin = false,
    AntiFling = false,

    Aim = false,
    AimTab = "Aim",
    ShowFOV = true,
    FOVRadius = 145,
    FOVOpacity = 40,
    FOVThickness = 2,
    AimSharpness = 100,
    AimMaxDistance = 1200,
    AimWallCheck = true,
    AimTeamCheck = false,
    AimHighlight = true,
    AimTargetPart = "Head",

    DetailLanguage = "RU",

    TimerEnabled = false,
    TimerSeconds = 2,
    TimerSpeed = 80,
    TimerRunning = false,

    SelectedTargetUserId = nil,
    TargetOrbit = false,
    TargetOrbitRadius = 5,
    TargetOrbitSpeed = 2.2,
    TargetRing = true,
}

local ThemeBindings = {}
local ThemeRefreshers = {}

local function BindTheme(object, bindings)
    ThemeBindings[object] = bindings
end

local function AddThemeRefresher(callback)
    table.insert(ThemeRefreshers, callback)
end

local function ApplyTheme()
    for object, bindings in pairs(ThemeBindings) do
        if object and object.Parent then
            for property, key in pairs(bindings) do
                pcall(function()
                    object[property] = Theme[key]
                end)
            end
        else
            ThemeBindings[object] = nil
        end
    end

    for _, callback in ipairs(ThemeRefreshers) do
        pcall(callback)
    end
end

local function SetTheme(themeTable)
    for key in pairs(Theme) do
        Theme[key] = nil
    end
    for key, value in pairs(themeTable) do
        Theme[key] = value
    end
    ApplyTheme()
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

--============================================================
-- CORE GUI - CREATED BEFORE FEATURE MODULES
--============================================================

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
    Size = 7,
})
Blur.Parent = Lighting

local OpenButton = New("TextButton", {
    Name = "OpenButton",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 16, 0.5, 0),
    Size = UDim2.fromOffset(48, 48),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "⚡",
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
    ZIndex = 100,
})
Round(OpenButton, 18)
local OpenStroke = Stroke(OpenButton, Theme.Accent, 0.12, 1.4)
OpenButton.Parent = Gui
BindTheme(OpenButton, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
BindTheme(OpenStroke, {Color = "Accent"})

local MainGroup = New("CanvasGroup", {
    Name = "MainGroup",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(600, 380),
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
local MainStroke = Stroke(MainFrame, Theme.Stroke, 0.08, 1.2)
MainFrame.Parent = MainGroup
BindTheme(MainFrame, {BackgroundColor3 = "Background"})
BindTheme(MainStroke, {Color = "Stroke"})

local Header = New("Frame", {
    Position = UDim2.fromOffset(10, 10),
    Size = UDim2.new(1, -20, 0, 50),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ZIndex = 4,
})
Round(Header, 18)
local HeaderStroke = Stroke(Header, Theme.Stroke, 0.42, 1)
Header.Parent = MainFrame
BindTheme(Header, {BackgroundColor3 = "Surface"})
BindTheme(HeaderStroke, {Color = "Stroke"})

local HeaderAccent = New("Frame", {
    Position = UDim2.fromOffset(9, 8),
    Size = UDim2.fromOffset(4, 34),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
})
Round(HeaderAccent, 4)
HeaderAccent.Parent = Header
BindTheme(HeaderAccent, {BackgroundColor3 = "Accent"})

local BackButton = New("TextButton", {
    Position = UDim2.fromOffset(18, 9),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = Theme.Surface3,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "<",
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
    Visible = false,
    ZIndex = 6,
})
Round(BackButton, 12)
local BackStroke = Stroke(BackButton, Theme.Stroke, 0.35, 1)
BackButton.Parent = Header
BindTheme(BackButton, {BackgroundColor3 = "Surface3", TextColor3 = "Text"})
BindTheme(BackStroke, {Color = "Stroke"})

local Logo = New("Frame", {
    Position = UDim2.fromOffset(20, 9),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
})
Round(Logo, 12)
Logo.Parent = Header
BindTheme(Logo, {BackgroundColor3 = "Accent"})

local LogoText = New("TextLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Text = "⚡",
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.new(1, 1, 1),
})
LogoText.Parent = Logo

local HeaderTitle = New("TextLabel", {
    Position = UDim2.fromOffset(64, 7),
    Size = UDim2.new(0, 250, 0, 19),
    BackgroundTransparency = 1,
    Text = "AntiFreak Hub",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
})
HeaderTitle.Parent = Header
BindTheme(HeaderTitle, {TextColor3 = "Text"})

local HeaderSubtitle = New("TextLabel", {
    Position = UDim2.fromOffset(64, 26),
    Size = UDim2.new(0, 320, 0, 15),
    BackgroundTransparency = 1,
    Text = "Compact Minimal Interface",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.SubText,
})
HeaderSubtitle.Parent = Header
BindTheme(HeaderSubtitle, {TextColor3 = "SubText"})

local StatusDot = New("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -51, 0.5, 0),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Theme.Green,
    BorderSizePixel = 0,
})
Round(StatusDot, 4)
StatusDot.Parent = Header
BindTheme(StatusDot, {BackgroundColor3 = "Green"})

local CloseButton = New("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -9, 0, 9),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = Theme.Surface3,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "X",
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.SubText,
})
Round(CloseButton, 12)
local CloseStroke = Stroke(CloseButton, Theme.Stroke, 0.35, 1)
CloseButton.Parent = Header
BindTheme(CloseButton, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
BindTheme(CloseStroke, {Color = "Stroke"})

local Sidebar = New("Frame", {
    Position = UDim2.fromOffset(10, 70),
    Size = UDim2.new(0, 122, 1, -80),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})
Round(Sidebar, 20)
local SidebarStroke = Stroke(Sidebar, Theme.Stroke, 0.42, 1)
Sidebar.Parent = MainFrame
BindTheme(Sidebar, {BackgroundColor3 = "Surface"})
BindTheme(SidebarStroke, {Color = "Stroke"})

local NavigationLabel = New("TextLabel", {
    Position = UDim2.fromOffset(13, 12),
    Size = UDim2.new(1, -26, 0, 14),
    BackgroundTransparency = 1,
    Text = "NAVIGATION",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.SubText,
})
NavigationLabel.Parent = Sidebar
BindTheme(NavigationLabel, {TextColor3 = "SubText"})

local TabsHolder = New("Frame", {
    Position = UDim2.fromOffset(8, 34),
    Size = UDim2.new(1, -16, 1, -64),
    BackgroundTransparency = 1,
})
TabsHolder.Parent = Sidebar

local TabsLayout = New("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
TabsLayout.Parent = TabsHolder

local VersionLabel = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -8),
    Size = UDim2.new(1, -20, 0, 14),
    BackgroundTransparency = 1,
    Text = "v6.0 stable",
    TextSize = 7,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.SubText,
})
VersionLabel.Parent = Sidebar
BindTheme(VersionLabel, {TextColor3 = "SubText"})

local Content = New("Frame", {
    Position = UDim2.fromOffset(142, 70),
    Size = UDim2.new(1, -152, 1, -80),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
Round(Content, 20)
local ContentStroke = Stroke(Content, Theme.Stroke, 0.42, 1)
Content.Parent = MainFrame
BindTheme(Content, {BackgroundColor3 = "Surface"})
BindTheme(ContentStroke, {Color = "Stroke"})

--============================================================
-- CORE INTERACTION HELPERS
--============================================================

local function AnimateButton(button)
    local scale = New("UIScale", {Scale = 1})
    scale.Parent = button

    button.MouseEnter:Connect(function()
        if UserInputService.MouseEnabled then
            Tween(scale, 0.32, {Scale = 1.035}, Enum.EasingStyle.Quint)
        end
    end)

    button.MouseLeave:Connect(function()
        if UserInputService.MouseEnabled then
            Tween(scale, 0.36, {Scale = 1}, Enum.EasingStyle.Quint)
        end
    end)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, 0.14, {Scale = 0.94}, Enum.EasingStyle.Quart)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scale, 0.48, {Scale = 1}, Enum.EasingStyle.Back)
        end
    end)
end

AnimateButton(OpenButton)
AnimateButton(BackButton)
AnimateButton(CloseButton)

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPosition = nil
    local dragInput = nil

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

MakeDraggable(MainGroup, Header)

local OpenDrag = false
local OpenMoved = false
local OpenDragStart = nil
local OpenStartPosition = nil

OpenButton.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    OpenDrag = true
    OpenMoved = false
    OpenDragStart = input.Position
    OpenStartPosition = OpenButton.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if not OpenDrag then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - OpenDragStart
    if delta.Magnitude > 7 then
        OpenMoved = true
    end

    OpenButton.Position = UDim2.new(
        OpenStartPosition.X.Scale,
        OpenStartPosition.X.Offset + delta.X,
        OpenStartPosition.Y.Scale,
        OpenStartPosition.Y.Offset + delta.Y
    )
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        OpenDrag = false
    end
end)

--============================================================
-- SAFE MODULE SYSTEM
--============================================================

local ModuleErrors = {}
local StatusLabel = nil

local function UpdateModuleStatus()
    if not StatusLabel then
        return
    end

    if #ModuleErrors == 0 then
        StatusLabel.Text = "System Status  ·  Ready"
        StatusLabel.TextColor3 = Theme.Green
        StatusDot.BackgroundColor3 = Theme.Green
    else
        StatusLabel.Text = "System Status  ·  " .. tostring(#ModuleErrors) .. " module issue(s)"
        StatusLabel.TextColor3 = Theme.Red
        StatusDot.BackgroundColor3 = Theme.Red
    end
end

local function SafeModule(name, callback)
    local ok, err = pcall(callback)
    if not ok then
        table.insert(ModuleErrors, name .. ": " .. tostring(err))
        warn("[AntiFreak Hub] " .. name .. " failed: " .. tostring(err))
        UpdateModuleStatus()
    end
    return ok
end

print("[AntiFreak Hub] Core GUI loaded")

--============================================================
-- PAGE / COMPONENT FACTORY
--============================================================

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
local TimerPage = CreatePage("Timer")
local SettingsPage = CreatePage("Settings")

local function CreateSection(parent, title, description)
    local holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, description and 38 or 23),
        BackgroundTransparency = 1,
    })
    holder.Parent = parent

    local titleLabel = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = holder
    BindTheme(titleLabel, {TextColor3 = "Text"})

    if description then
        local desc = New("TextLabel", {
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = description,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 8,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Theme.SubText,
        })
        desc.Parent = holder
        BindTheme(desc, {TextColor3 = "SubText"})
    end

    return holder
end

local function CreateCard(parent, height)
    local card = New("Frame", {
        Size = UDim2.new(1, 0, 0, height or 57),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    Round(card, 17)
    local cardStroke = Stroke(card, Theme.Stroke, 0.42, 1)
    card.Parent = parent
    BindTheme(card, {BackgroundColor3 = "Surface2"})
    BindTheme(cardStroke, {Color = "Stroke"})
    return card
end

local function CreateToggle(parent, title, description, defaultValue, callback)
    local collapsedHeight = 42
    local expandedHeight = 68
    local card = CreateCard(parent, collapsedHeight)
    local expanded = false

    local infoButton = New("TextButton", {
        Position = UDim2.fromOffset(9, 9),
        Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ">",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.SubText,
    })
    Round(infoButton, 8)
    infoButton.Parent = card
    BindTheme(infoButton, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
    AnimateButton(infoButton)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 8),
        Size = UDim2.new(1, -112, 0, 25),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local descriptionLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 40),
        Size = UDim2.new(1, -55, 0, 18),
        BackgroundTransparency = 1,
        Text = description or "",
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
        Visible = false,
    })
    descriptionLabel.Parent = card
    BindTheme(descriptionLabel, {TextColor3 = "SubText"})

    local toggle = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0, 21),
        Size = UDim2.fromOffset(40, 22),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    Round(toggle, 11)
    toggle.Parent = card

    local knob = New("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.SubText,
        BorderSizePixel = 0,
    })
    Round(knob, 8)
    knob.Parent = toggle

    local value = defaultValue == true
    local controller = {}

    local function render(animated)
        local switchColor = value and Theme.Accent or Theme.Surface3
        local knobColor = value and Color3.new(1, 1, 1) or Theme.SubText
        local knobPosition = value and UDim2.new(1, -19, 0, 3) or UDim2.fromOffset(3, 3)

        if animated then
            Tween(toggle, 0.26, {BackgroundColor3 = switchColor})
            Tween(knob, 0.34, {Position = knobPosition, BackgroundColor3 = knobColor}, Enum.EasingStyle.Back)
        else
            toggle.BackgroundColor3 = switchColor
            knob.BackgroundColor3 = knobColor
            knob.Position = knobPosition
        end
    end

    local function setExpanded(state)
        expanded = state
        infoButton.Text = expanded and "v" or ">"
        if expanded then
            descriptionLabel.Visible = true
        end
        Tween(card, 0.34, {Size = UDim2.new(1, 0, 0, expanded and expandedHeight or collapsedHeight)}, Enum.EasingStyle.Quint)
        if not expanded then
            task.delay(0.28, function()
                if card.Parent and not expanded then
                    descriptionLabel.Visible = false
                end
            end)
        end
    end

    function controller:Set(newValue, fireCallback)
        value = newValue == true
        render(true)
        if fireCallback ~= false and callback then
            callback(value)
        end
    end

    function controller:Get()
        return value
    end

    AddThemeRefresher(function()
        render(false)
    end)

    infoButton.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    toggle.MouseButton1Click:Connect(function()
        controller:Set(not value, true)
    end)

    AnimateButton(toggle)
    render(false)
    return controller, card
end

local function CreateSlider(parent, title, minimum, maximum, defaultValue, callback, suffix, description)
    local collapsedHeight = 50
    local expandedHeight = 76
    local card = CreateCard(parent, collapsedHeight)
    local value = math.clamp(defaultValue, minimum, maximum)
    local dragging = false
    local expanded = false

    local infoButton = New("TextButton", {
        Position = UDim2.fromOffset(9, 7),
        Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ">",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.SubText,
    })
    Round(infoButton, 8)
    infoButton.Parent = card
    BindTheme(infoButton, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
    AnimateButton(infoButton)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 7),
        Size = UDim2.new(1, -130, 0, 20),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local valueLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -10, 0, 7),
        Size = UDim2.fromOffset(80, 20),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    valueLabel.Parent = card

    local bar = New("Frame", {
        Position = UDim2.fromOffset(40, 34),
        Size = UDim2.new(1, -52, 0, 6),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Active = true,
    })
    Round(bar, 3)
    bar.Parent = card
    BindTheme(bar, {BackgroundColor3 = "Surface3"})

    local fill = New("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    })
    Round(fill, 3)
    fill.Parent = bar

    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Round(knob, 7)
    local knobStroke = Stroke(knob, Theme.Accent, 0, 1.3)
    knob.Parent = bar

    local descLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 52),
        Size = UDim2.new(1, -52, 0, 16),
        BackgroundTransparency = 1,
        Text = description or ("Adjust " .. title:lower() .. "."),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
        Visible = false,
    })
    descLabel.Parent = card
    BindTheme(descLabel, {TextColor3 = "SubText"})

    local controller = {}

    local function render(animated)
        local alpha = (value - minimum) / (maximum - minimum)
        valueLabel.Text = tostring(math.floor(value + 0.5)) .. (suffix or "")
        valueLabel.TextColor3 = Theme.Accent
        fill.BackgroundColor3 = Theme.Accent
        knobStroke.Color = Theme.Accent

        if animated then
            Tween(fill, 0.18, {Size = UDim2.fromScale(alpha, 1)})
            Tween(knob, 0.18, {Position = UDim2.fromScale(alpha, 0.5)})
        else
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.fromScale(alpha, 0.5)
        end
    end

    local function setExpanded(state)
        expanded = state
        infoButton.Text = expanded and "v" or ">"
        if expanded then
            descLabel.Visible = true
        end
        Tween(card, 0.34, {Size = UDim2.new(1, 0, 0, expanded and expandedHeight or collapsedHeight)}, Enum.EasingStyle.Quint)
        if not expanded then
            task.delay(0.28, function()
                if card.Parent and not expanded then
                    descLabel.Visible = false
                end
            end)
        end
    end

    local function setFromX(x)
        local width = bar.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / width, 0, 1)
        value = minimum + ((maximum - minimum) * alpha)
        value = math.floor(value + 0.5)
        render(false)
        if callback then
            callback(value)
        end
    end

    function controller:Set(newValue, fireCallback)
        value = math.clamp(newValue, minimum, maximum)
        render(true)
        if fireCallback ~= false and callback then
            callback(value)
        end
    end

    function controller:Get()
        return value
    end

    AddThemeRefresher(function()
        render(false)
    end)

    infoButton.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render(false)
    return controller, card
end

local function CreateAction(parent, title, description, buttonText, callback)
    local collapsedHeight = 42
    local expandedHeight = 68
    local card = CreateCard(parent, collapsedHeight)
    local expanded = false

    local infoButton = New("TextButton", {
        Position = UDim2.fromOffset(9, 9),
        Size = UDim2.fromOffset(24, 24),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ">",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.SubText,
    })
    Round(infoButton, 8)
    infoButton.Parent = card
    BindTheme(infoButton, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
    AnimateButton(infoButton)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 8),
        Size = UDim2.new(1, -132, 0, 25),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local descLabel = New("TextLabel", {
        Position = UDim2.fromOffset(40, 40),
        Size = UDim2.new(1, -55, 0, 18),
        BackgroundTransparency = 1,
        Text = description or "",
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
        Visible = false,
    })
    descLabel.Parent = card
    BindTheme(descLabel, {TextColor3 = "SubText"})

    local button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0, 21),
        Size = UDim2.fromOffset(67, 26),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = buttonText,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    Round(button, 9)
    local buttonStroke = Stroke(button, Theme.Stroke, 0.35, 1)
    button.Parent = card
    BindTheme(button, {BackgroundColor3 = "Surface3", TextColor3 = "Text"})
    BindTheme(buttonStroke, {Color = "Stroke"})
    AnimateButton(button)

    local function setExpanded(state)
        expanded = state
        infoButton.Text = expanded and "v" or ">"
        if expanded then
            descLabel.Visible = true
        end
        Tween(card, 0.34, {Size = UDim2.new(1, 0, 0, expanded and expandedHeight or collapsedHeight)}, Enum.EasingStyle.Quint)
        if not expanded then
            task.delay(0.28, function()
                if card.Parent and not expanded then
                    descLabel.Visible = false
                end
            end)
        end
    end

    infoButton.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    button.MouseButton1Click:Connect(function()
        if callback then
            callback(button, descLabel)
        end
    end)

    return card, button, descLabel
end

--============================================================
-- TAB SYSTEM
--============================================================

local TabData = {
    {"Visuals", "◉"},
    {"Player", "●"},
    {"Game", "◆"},
    {"Hub", "◇"},
    {"Misc", "✦"},
    {"Timer", "◷"},
    {"Settings", "⚙"},
}

local function RefreshTabs()
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

local function SwitchTab(name)
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
    selected.Group.Position = UDim2.fromOffset(15, 0)

    if Config.Animations then
        Tween(selected.Group, 0.55, {
            GroupTransparency = 0,
            Position = UDim2.fromOffset(0, 0),
        }, Enum.EasingStyle.Quint)
    else
        selected.Group.GroupTransparency = 0
        selected.Group.Position = UDim2.fromOffset(0, 0)
    end

    RefreshTabs()
end

for index, data in ipairs(TabData) do
    local name = data[1]
    local icon = data[2]

    local button = New("TextButton", {
        Name = name .. "Tab",
        Size = UDim2.new(1, 0, 0, 32),
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
    Round(button, 12)
    button.Parent = TabsHolder

    local indicator = New("Frame", {
        Name = "Indicator",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(3, 14),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    })
    Round(indicator, 3)
    indicator.Parent = button

    TabButtons[name] = button
    AnimateButton(button)

    button.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

AddThemeRefresher(RefreshTabs)

--============================================================
-- UNIVERSAL UI CONTENT - V6 COMPACT GROUPED BUILD
--============================================================

local DetailBindings = {}
local SettingBindings = {}

local function DetailText(en, ru)
    if Config.DetailLanguage == "RU" then
        return ru or en
    end
    return en
end

local function BindDetail(label, en, ru)
    table.insert(DetailBindings, {Label = label, EN = en, RU = ru or en})
    label.Text = DetailText(en, ru)
end

local function BindSetting(label, en, ru)
    table.insert(SettingBindings, {Label = label, EN = en, RU = ru or en})
    label.Text = DetailText(en, ru)
end

local function RefreshLanguage()
    for _, item in ipairs(DetailBindings) do
        if item.Label and item.Label.Parent then
            item.Label.Text = DetailText(item.EN, item.RU)
        end
    end
    for _, item in ipairs(SettingBindings) do
        if item.Label and item.Label.Parent then
            item.Label.Text = DetailText(item.EN, item.RU)
        end
    end
end

local function PlayUISound()
    -- UI sounds intentionally disabled in v7.
end

local function CreateFeaturePanel(parent, title, descriptionEN, descriptionRU, defaultValue, callback)
    local collapsedHeight = 38
    local card = CreateCard(parent, collapsedHeight)
    local expanded = false
    local value = defaultValue == true

    local arrow = New("TextButton", {
        Position = UDim2.fromOffset(5, 4),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = ">",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.SubText,
    })
    Round(arrow, 9)
    arrow.Parent = card
    BindTheme(arrow, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
    AnimateButton(arrow)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(43, 5),
        Size = UDim2.new(1, callback and -104 or -52, 0, 28),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local toggle
    local knob
    if callback then
        toggle = New("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -8, 0, 19),
            Size = UDim2.fromOffset(44, 24),
            BackgroundColor3 = Theme.Surface3,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            Visible = false,
        })
        Round(toggle, 11)
        toggle.Parent = card
        AnimateButton(toggle)

        knob = New("Frame", {
            Position = UDim2.fromOffset(3, 3),
            Size = UDim2.fromOffset(18, 18),
            BackgroundColor3 = Theme.SubText,
            BorderSizePixel = 0,
        })
        Round(knob, 999)
        knob.Parent = toggle
    end

    local description = New("TextLabel", {
        Position = UDim2.fromOffset(43, 42),
        Size = UDim2.new(1, -52, 0, 30),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
        Visible = false,
    })
    description.Parent = card
    BindTheme(description, {TextColor3 = "SubText"})
    BindDetail(description, descriptionEN, descriptionRU)

    local content = New("Frame", {
        Position = UDim2.fromOffset(43, 76),
        Size = UDim2.new(1, -55, 0, 0),
        BackgroundTransparency = 1,
        Visible = false,
    })
    content.Parent = card

    local layout = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = content

    local controller = {}

    local function renderToggle(animated)
        if not toggle then
            return
        end
        local bg = value and Theme.Accent or Theme.Surface3
        local knobColor = value and Color3.new(1, 1, 1) or Theme.SubText
        local knobPos = value and UDim2.new(1, -21, 0, 3) or UDim2.fromOffset(3, 3)
        if animated then
            Tween(toggle, 0.34, {BackgroundColor3 = bg}, Enum.EasingStyle.Quint)
            Tween(knob, 0.46, {Position = knobPos, BackgroundColor3 = knobColor}, Enum.EasingStyle.Back)
        else
            toggle.BackgroundColor3 = bg
            knob.BackgroundColor3 = knobColor
            knob.Position = knobPos
        end
    end

    local function recalc(animated)
        content.Size = UDim2.new(1, -52, 0, layout.AbsoluteContentSize.Y)
        local targetHeight = collapsedHeight
        if expanded then
            targetHeight = 84 + layout.AbsoluteContentSize.Y + 9
        end
        if animated ~= false and Config.Animations then
            Tween(card, 0.58, {Size = UDim2.new(1, 0, 0, targetHeight)}, Enum.EasingStyle.Quint)
        else
            card.Size = UDim2.new(1, 0, 0, targetHeight)
        end
    end

    local function setExpanded(state)
        expanded = state
        arrow.Text = expanded and "v" or ">"
        if expanded then
            description.Visible = true
            content.Visible = true
            if toggle then
                toggle.Visible = true
                toggle.BackgroundTransparency = 1
                Tween(toggle, 0.38, {BackgroundTransparency = 0}, Enum.EasingStyle.Quint)
            end
            task.defer(function()
                recalc(true)
            end)
        else
            recalc(true)
            if toggle then
                Tween(toggle, 0.24, {BackgroundTransparency = 1}, Enum.EasingStyle.Quint)
            end
            task.delay(0.48, function()
                if card.Parent and not expanded then
                    description.Visible = false
                    content.Visible = false
                    if toggle then
                        toggle.Visible = false
                        toggle.BackgroundTransparency = 0
                    end
                end
            end)
        end
        PlayUISound("click")
    end

    function controller:Set(newValue, fireCallback)
        value = newValue == true
        renderToggle(true)
        PlayUISound("click")
        if fireCallback ~= false and callback then
            callback(value)
        end
    end

    function controller:Get()
        return value
    end

    function controller:SetExpanded(state)
        setExpanded(state)
    end

    function controller:IsExpanded()
        return expanded
    end

    function controller:Recalculate()
        recalc(false)
    end

    arrow.MouseButton1Click:Connect(function()
        setExpanded(not expanded)
    end)

    if toggle then
        toggle.MouseButton1Click:Connect(function()
            controller:Set(not value, true)
        end)
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if expanded then
            recalc(false)
        end
    end)

    AddThemeRefresher(function()
        renderToggle(false)
    end)

    renderToggle(false)
    return controller, content, card
end

local function AddMiniToggle(parent, labelEN, labelRU, defaultValue, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(row, 11)
    row.Parent = parent
    BindTheme(row, {BackgroundColor3 = "Surface3"})

    local label = New("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -66, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
    })
    label.Parent = row
    BindTheme(label, {TextColor3 = "Text"})
    BindSetting(label, labelEN, labelRU)

    local button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(46, 24),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
    })
    Round(button, 10)
    button.Parent = row

    local knob = New("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(13, 13),
        BackgroundColor3 = Theme.SubText,
        BorderSizePixel = 0,
    })
    Round(knob, 999)
    knob.Parent = button

    local value = defaultValue == true
    local control = {}

    local function render(animated)
        local bg = value and Theme.Accent or Theme.Surface2
        local kp = value and UDim2.new(1, -21, 0, 3) or UDim2.fromOffset(3, 3)
        if animated then
            Tween(button, 0.28, {BackgroundColor3 = bg})
            Tween(knob, 0.38, {Position = kp, BackgroundColor3 = value and Color3.new(1, 1, 1) or Theme.SubText}, Enum.EasingStyle.Back)
        else
            button.BackgroundColor3 = bg
            knob.Position = kp
            knob.BackgroundColor3 = value and Color3.new(1, 1, 1) or Theme.SubText
        end
    end

    function control:Set(newValue, fire)
        value = newValue == true
        render(true)
        PlayUISound("click")
        if fire ~= false and callback then
            callback(value)
        end
    end

    function control:Get()
        return value
    end

    button.MouseButton1Click:Connect(function()
        control:Set(not value, true)
    end)

    AddThemeRefresher(function()
        render(false)
    end)
    AnimateButton(button)
    render(false)
    return control, row
end

local function AddMiniSlider(parent, labelEN, labelRU, minimum, maximum, defaultValue, callback, suffix)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(row, 11)
    row.Parent = parent
    BindTheme(row, {BackgroundColor3 = "Surface3"})

    local label = New("TextLabel", {
        Position = UDim2.fromOffset(10, 4),
        Size = UDim2.new(1, -90, 0, 18),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
    })
    label.Parent = row
    BindTheme(label, {TextColor3 = "Text"})
    BindSetting(label, labelEN, labelRU)

    local valueLabel = New("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -9, 0, 4),
        Size = UDim2.fromOffset(70, 18),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    valueLabel.Parent = row

    local bar = New("Frame", {
        Position = UDim2.fromOffset(10, 29),
        Size = UDim2.new(1, -20, 0, 10),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Active = true,
    })
    Round(bar, 4)
    bar.Parent = row
    BindTheme(bar, {BackgroundColor3 = "Surface2"})

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
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Round(knob, 999)
    local knobStroke = Stroke(knob, Theme.Accent, 0, 1.2)
    knob.Parent = bar

    local value = math.clamp(defaultValue, minimum, maximum)
    local dragging = false
    local control = {}

    local function render(animated)
        local alpha = (value - minimum) / (maximum - minimum)
        valueLabel.Text = tostring(math.floor(value + 0.5)) .. (suffix or "")
        valueLabel.TextColor3 = Theme.Accent
        fill.BackgroundColor3 = Theme.Accent
        knobStroke.Color = Theme.Accent
        if animated then
            Tween(fill, 0.20, {Size = UDim2.fromScale(alpha, 1)})
            Tween(knob, 0.20, {Position = UDim2.fromScale(alpha, 0.5)})
        else
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.fromScale(alpha, 0.5)
        end
    end

    local function setFromX(x)
        if bar.AbsoluteSize.X <= 0 then
            return
        end
        local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        value = math.floor(minimum + ((maximum - minimum) * alpha) + 0.5)
        render(false)
        if callback then
            callback(value)
        end
    end

    function control:Set(newValue, fire)
        value = math.clamp(newValue, minimum, maximum)
        render(true)
        if fire ~= false and callback then
            callback(value)
        end
    end

    function control:Get()
        return value
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    AddThemeRefresher(function()
        render(false)
    end)
    render(false)
    return control, row
end

local function AddMiniAction(parent, labelEN, labelRU, buttonText, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(row, 11)
    row.Parent = parent
    BindTheme(row, {BackgroundColor3 = "Surface3"})

    local label = New("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -92, 1, 0),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
    })
    label.Parent = row
    BindTheme(label, {TextColor3 = "Text"})
    BindSetting(label, labelEN, labelRU)

    local button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(78, 28),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = buttonText,
        TextSize = 7,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    Round(button, 9)
    button.Parent = row
    BindTheme(button, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
    AnimateButton(button)

    button.MouseButton1Click:Connect(function()
        PlayUISound("click")
        if callback then
            callback(button, label)
        end
    end)
    return row, button, label
end

CreateSection(VisualsPage, "Visuals", nil)
CreateSection(PlayerPage, "Player", nil)
CreateSection(GamePage, "Game", nil)
CreateSection(HubPage, "Hub", nil)
CreateSection(MiscPage, "Misc", nil)
CreateSection(TimerPage, "Timer", nil)
CreateSection(SettingsPage, "Settings", nil)

local ESPController
local FlyController
local SpeedController
local ImpactController
local AntiFlingController
local TimerController
local AimController
local AimStatus

local SetESP
local SetFly
local SetSpeed
local SetImpactSpin
local SetAntiFling

--============================================================
-- ESP
--============================================================

SafeModule("ESP", function()
    local highlights = {}
    local connections = {}

    local function remove(player)
        if highlights[player] then
            highlights[player]:Destroy()
            highlights[player] = nil
        end
    end

    local function add(player)
        if player == LocalPlayer then
            return
        end
        remove(player)
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
        highlights[player] = highlight
    end

    local function refreshColor()
        for _, highlight in pairs(highlights) do
            if highlight and highlight.Parent then
                highlight.FillColor = Config.ESPColor
                highlight.OutlineColor = Config.ESPColor
            end
        end
    end

    SetESP = function(state)
        Config.ESP = state
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                add(player)
            end
        else
            for player in pairs(highlights) do
                remove(player)
            end
        end
    end

    local espContent
    ESPController, espContent = CreateFeaturePanel(
        VisualsPage,
        "Player ESP",
        "Highlights other players and keeps the color controls hidden until this panel is expanded.",
        "Подсвечивает других игроков. Настройки цвета находятся внутри этой раскрываемой панели.",
        Config.ESP,
        SetESP
    )

    local h, s, v = Config.ESPColor:ToHSV()
    local hue = math.floor(h * 360 + 0.5)
    local saturation = math.floor(s * 100 + 0.5)
    local brightness = math.floor(v * 100 + 0.5)

    local function updateColor()
        Config.ESPColor = Color3.fromHSV(hue / 360, saturation / 100, brightness / 100)
        refreshColor()
    end

    AddMiniSlider(espContent, "Hue", "Оттенок", 0, 360, hue, function(value)
        hue = value
        updateColor()
    end, "°")

    AddMiniSlider(espContent, "Saturation", "Насыщенность", 0, 100, saturation, function(value)
        saturation = value
        updateColor()
    end, "%")

    AddMiniSlider(espContent, "Brightness", "Яркость", 10, 100, brightness, function(value)
        brightness = value
        updateColor()
    end, "%")

    local presetRow = New("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(presetRow, 11)
    presetRow.Parent = espContent
    BindTheme(presetRow, {BackgroundColor3 = "Surface3"})

    local presetLabel = New("TextLabel", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.fromOffset(62, 34),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.Text,
    })
    presetLabel.Parent = presetRow
    BindTheme(presetLabel, {TextColor3 = "Text"})
    BindSetting(presetLabel, "Presets", "Готовые цвета")

    local presets = {
        Color3.fromRGB(255, 84, 111), Color3.fromRGB(255, 173, 70), Color3.fromRGB(70, 225, 143),
        Color3.fromRGB(61, 203, 255), Color3.fromRGB(91, 126, 255), Color3.fromRGB(170, 91, 255),
        Color3.fromRGB(255, 87, 206), Color3.fromRGB(245, 245, 255),
    }
    for index, color in ipairs(presets) do
        local b = New("TextButton", {
            Position = UDim2.fromOffset(72 + ((index - 1) * 29), 6),
            Size = UDim2.fromOffset(22, 22),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
        })
        Round(b, 7)
        Stroke(b, Color3.new(1, 1, 1), 0.7, 1)
        b.Parent = presetRow
        AnimateButton(b)
        b.MouseButton1Click:Connect(function()
            local ph, ps, pv = color:ToHSV()
            hue = math.floor(ph * 360 + 0.5)
            saturation = math.floor(ps * 100 + 0.5)
            brightness = math.floor(pv * 100 + 0.5)
            updateColor()
            PlayUISound("click")
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            connections[player] = player.CharacterAdded:Connect(function()
                task.wait(0.3)
                if Config.ESP then
                    add(player)
                end
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then
            return
        end
        connections[player] = player.CharacterAdded:Connect(function()
            task.wait(0.3)
            if Config.ESP then
                add(player)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        remove(player)
        if connections[player] then
            connections[player]:Disconnect()
            connections[player] = nil
        end
    end)
end)

--============================================================
-- PLAYER INFO
--============================================================

SafeModule("Player Info", function()
    local card = CreateCard(PlayerPage, 84)
    local labels = {
        {"Player  ·  " .. LocalPlayer.Name, 10, true},
        {"Display Name  ·  " .. LocalPlayer.DisplayName, 32, false},
        {UserInputService.TouchEnabled and "Input  ·  Touch" or "Input  ·  Keyboard / Mouse", 52, false},
    }
    for _, data in ipairs(labels) do
        local label = New("TextLabel", {
            Position = UDim2.fromOffset(13, data[2]),
            Size = UDim2.new(1, -26, 0, 16),
            BackgroundTransparency = 1,
            Text = data[1],
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = data[3] and 9 or 8,
            Font = data[3] and Enum.Font.GothamBold or Enum.Font.GothamMedium,
            TextColor3 = data[3] and Theme.Text or Theme.SubText,
        })
        label.Parent = card
        BindTheme(label, {TextColor3 = data[3] and "Text" or "SubText"})
    end
end)

--============================================================
-- SPEED
--============================================================

local StoredWalkSpeed
SafeModule("Speed", function()
    SetSpeed = function(state)
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

    local speedContent
    SpeedController, speedContent = CreateFeaturePanel(
        GamePage,
        "Speed",
        "Overrides your local WalkSpeed. Expand this function to change the speed value.",
        "Изменяет локальную скорость ходьбы. Раскройте функцию, чтобы настроить значение скорости.",
        Config.Speed,
        SetSpeed
    )

    AddMiniSlider(speedContent, "WalkSpeed", "Скорость ходьбы", 16, 250, Config.WalkSpeed, function(value)
        Config.WalkSpeed = value
        if Config.Speed then
            local humanoid = GetHumanoid()
            if humanoid then
                humanoid.WalkSpeed = value
            end
        end
    end)
end)

--============================================================
-- SUPERHERO FLY
--============================================================

local FlyBodyVelocity
local FlyBodyGyro
local FlyConnection
local FlyUp = false
local FlyDown = false
local FlyMotors = {}

SafeModule("Fly", function()
    local function cacheMotors()
        table.clear(FlyMotors)
        local character = GetCharacter()
        if not character then
            return
        end
        local upper = character:FindFirstChild("UpperTorso")
        local torso = character:FindFirstChild("Torso")
        if upper then
            FlyMotors.Right = upper:FindFirstChild("RightShoulder")
            FlyMotors.Left = upper:FindFirstChild("LeftShoulder")
            FlyMotors.Waist = upper:FindFirstChild("Waist")
            FlyMotors.Neck = upper:FindFirstChild("Neck")
        elseif torso then
            FlyMotors.Right = torso:FindFirstChild("Right Shoulder")
            FlyMotors.Left = torso:FindFirstChild("Left Shoulder")
            FlyMotors.Neck = torso:FindFirstChild("Neck")
        end
    end

    local function resetPose()
        for _, motor in pairs(FlyMotors) do
            if motor and motor.Parent then
                motor.Transform = CFrame.new()
            end
        end
    end

    local function stopFly()
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        resetPose()
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

    local function startFly()
        stopFly()
        local root = GetRoot()
        local humanoid = GetHumanoid()
        if not root or not humanoid then
            Config.Fly = false
            return
        end
        cacheMotors()
        humanoid.AutoRotate = false
        FlyBodyVelocity = New("BodyVelocity", {
            Name = "AntiFreakFlyVelocity",
            MaxForce = Vector3.new(math.huge, math.huge, math.huge),
            P = 10000,
            Velocity = Vector3.zero,
        })
        FlyBodyVelocity.Parent = root
        FlyBodyGyro = New("BodyGyro", {
            Name = "AntiFreakFlyGyro",
            MaxTorque = Vector3.new(math.huge, math.huge, math.huge),
            P = 26000,
            D = 700,
            CFrame = root.CFrame,
        })
        FlyBodyGyro.Parent = root
        local started = os.clock()
        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Config.Fly then
                return
            end
            local currentRoot = GetRoot()
            local currentHumanoid = GetHumanoid()
            local camera = Workspace.CurrentCamera
            if not currentRoot or not currentHumanoid or not camera then
                return
            end
            local direction = currentHumanoid.MoveDirection
            if direction.Magnitude > 1 then
                direction = direction.Unit
            end
            local vertical = (FlyUp and 1 or 0) - (FlyDown and 1 or 0)
            FlyBodyVelocity.Velocity = (direction * Config.FlySpeed) + Vector3.new(0, vertical * Config.FlySpeed, 0)

            local facing = direction.Magnitude > 0.05 and Vector3.new(direction.X, 0, direction.Z) or Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            if facing.Magnitude < 0.01 then
                facing = currentRoot.CFrame.LookVector
            else
                facing = facing.Unit
            end
            local moving = direction.Magnitude > 0.05 or vertical ~= 0
            local tilt = moving and Config.FlyTilt or 3
            local roll = direction.Magnitude > 0.05 and (-camera.CFrame.RightVector:Dot(direction) * 9) or 0
            FlyBodyGyro.CFrame = CFrame.lookAt(currentRoot.Position, currentRoot.Position + facing) * CFrame.Angles(math.rad(-tilt), 0, math.rad(roll))

            local t = os.clock() - started
            local wave = math.sin(t * 4.5) * 2.5
            if FlyMotors.Right then
                FlyMotors.Right.Transform = CFrame.Angles(math.rad(-120 + wave), math.rad(-4), math.rad(11))
            end
            if FlyMotors.Left then
                FlyMotors.Left.Transform = CFrame.Angles(math.rad(-120 - wave), math.rad(4), math.rad(-11))
            end
            if FlyMotors.Waist then
                FlyMotors.Waist.Transform = CFrame.Angles(math.rad(-7), 0, math.rad(math.sin(t * 2.2) * 2))
            end
            if FlyMotors.Neck then
                FlyMotors.Neck.Transform = CFrame.Angles(math.rad(8), 0, 0)
            end
        end)
    end

    SetFly = function(state)
        Config.Fly = state
        if state then
            startFly()
        else
            stopFly()
        end
    end

    local flyContent
    FlyController, flyContent = CreateFeaturePanel(
        GamePage,
        "Superhero Fly",
        "Camera-based flight with a forward superhero body pose. Expand to configure speed and tilt.",
        "Полёт с управлением от камеры и позой супергероя. Раскройте функцию для настройки скорости и наклона.",
        Config.Fly,
        SetFly
    )

    AddMiniSlider(flyContent, "Flight Speed", "Скорость полёта", 10, 300, Config.FlySpeed, function(value)
        Config.FlySpeed = value
    end)
    AddMiniSlider(flyContent, "Flight Tilt", "Наклон тела", 0, 55, Config.FlyTilt, function(value)
        Config.FlyTilt = value
    end, "°")
end)

-- Touch flight buttons
SafeModule("Fly Touch", function()
    local holder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(58, 122),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 92,
    })
    holder.Parent = Gui

    local function make(y, text)
        local b = New("TextButton", {
            Position = UDim2.fromOffset(0, y),
            Size = UDim2.fromOffset(56, 56),
            BackgroundColor3 = Theme.Surface2,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = text,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            TextColor3 = Theme.Text,
            ZIndex = 93,
        })
        Round(b, 20)
        local st = Stroke(b, Theme.Accent, 0.12, 1.3)
        b.Parent = holder
        BindTheme(b, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
        BindTheme(st, {Color = "Accent"})
        AnimateButton(b)
        return b
    end

    local up = make(0, "▲\nUP")
    local down = make(65, "▼\nDOWN")
    local function hold(button, fn)
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fn(true)
            end
        end)
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                fn(false)
            end
        end)
    end
    hold(up, function(v) FlyUp = v end)
    hold(down, function(v) FlyDown = v end)

    RunService.RenderStepped:Connect(function()
        holder.Visible = Config.Fly and UserInputService.TouchEnabled and Config.CurrentProfile == nil
    end)
end)

--============================================================
-- MISC
--============================================================

SafeModule("Touch Fling", function()
    local connection
    local function stop()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        local root = GetRoot()
        if root then
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
    local function start()
        stop()
        connection = RunService.Heartbeat:Connect(function()
            if not Config.ImpactSpin then
                return
            end
            local root = GetRoot()
            if root then
                root.AssemblyAngularVelocity = Vector3.new(0, 44, 0)
                if root.AssemblyLinearVelocity.Magnitude > 125 then
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity.Unit * 85
                end
            end
        end)
    end
    SetImpactSpin = function(state)
        Config.ImpactSpin = state
        if state then start() else stop() end
    end
    ImpactController = CreateFeaturePanel(
        MiscPage,
        "Touch Fling",
        "Applies a high-energy local spin while limiting extreme self velocity.",
        "Создаёт сильное локальное вращение персонажа и ограничивает слишком большую собственную скорость.",
        Config.ImpactSpin,
        SetImpactSpin
    )
end)

SafeModule("Anti-Fling", function()
    local connection
    local cache = {}
    local function stop()
        if connection then connection:Disconnect() connection = nil end
        for part, old in pairs(cache) do
            if part and part.Parent then
                pcall(function() part.CanCollide = old end)
            end
        end
        table.clear(cache)
    end
    local function start()
        stop()
        connection = RunService.Heartbeat:Connect(function()
            if not Config.AntiFling then return end
            local root = GetRoot()
            if root then
                if root.AssemblyLinearVelocity.Magnitude > 115 then root.AssemblyLinearVelocity = Vector3.zero end
                if root.AssemblyAngularVelocity.Magnitude > 75 then root.AssemblyAngularVelocity = Vector3.zero end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, object in ipairs(player.Character:GetDescendants()) do
                        if object:IsA("BasePart") then
                            if cache[object] == nil then cache[object] = object.CanCollide end
                            object.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
    SetAntiFling = function(state)
        Config.AntiFling = state
        if state then start() else stop() end
    end
    AntiFlingController = CreateFeaturePanel(
        MiscPage,
        "Anti-Fling",
        "Suppresses abnormal local velocity and disables collision with other player characters.",
        "Гасит аномальную локальную скорость и отключает столкновения с персонажами других игроков.",
        Config.AntiFling,
        SetAntiFling
    )
end)

--============================================================
-- TIMER
--============================================================

local TimerButton = New("TextButton", {
    Name = "AntiFreakTimerButton",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 76, 0.5, 0),
    Size = UDim2.fromOffset(64, 64),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "TIMER\nREADY",
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
    Visible = false,
    ZIndex = 94,
})
Round(TimerButton, 22)
local TimerButtonStroke = Stroke(TimerButton, Theme.Accent, 0.12, 1.4)
TimerButton.Parent = Gui
BindTheme(TimerButton, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
BindTheme(TimerButtonStroke, {Color = "Accent"})
AnimateButton(TimerButton)

local timerToken = 0
local timerOriginalSpeed = nil
local function RunTimedSpeed()
    if not Config.TimerEnabled or Config.TimerRunning then
        return
    end
    local humanoid = GetHumanoid()
    if not humanoid then
        return
    end
    Config.TimerRunning = true
    timerToken = timerToken + 1
    local myToken = timerToken
    local originalSpeed = humanoid.WalkSpeed
    timerOriginalSpeed = originalSpeed
    humanoid.WalkSpeed = Config.TimerSpeed
    PlayUISound("click")

    task.spawn(function()
        local started = os.clock()
        while Config.TimerRunning and myToken == timerToken do
            local left = math.max(0, Config.TimerSeconds - (os.clock() - started))
            TimerButton.Text = string.format("TIMER\n%.1fs", left)
            if left <= 0 then
                break
            end
            task.wait(0.05)
        end
        if myToken ~= timerToken then
            return
        end
        local currentHumanoid = GetHumanoid()
        if currentHumanoid then
            if Config.Speed then
                currentHumanoid.WalkSpeed = Config.WalkSpeed
            else
                currentHumanoid.WalkSpeed = originalSpeed
            end
        end
        Config.TimerRunning = false
        timerOriginalSpeed = nil
        TimerButton.Text = "TIMER\nREADY"
    end)
end

SafeModule("Timer", function()
    local timerContent
    TimerController, timerContent = CreateFeaturePanel(
        TimerPage,
        "Timed Speed",
        "Enables an on-screen trigger. Press it to use the configured speed for a limited number of seconds, then restore your previous speed.",
        "Включает экранную кнопку. Нажмите её, чтобы получить заданную скорость на указанное число секунд, после чего прежняя скорость восстановится.",
        Config.TimerEnabled,
        function(state)
            Config.TimerEnabled = state
            TimerButton.Visible = state
            if not state and Config.TimerRunning then
                timerToken = timerToken + 1
                Config.TimerRunning = false
                local humanoid = GetHumanoid()
                if humanoid then
                    humanoid.WalkSpeed = Config.Speed and Config.WalkSpeed or (timerOriginalSpeed or humanoid.WalkSpeed)
                end
                timerOriginalSpeed = nil
                TimerButton.Text = "TIMER\nREADY"
            end
        end
    )

    AddMiniSlider(timerContent, "Duration", "Время", 1, 15, Config.TimerSeconds, function(value)
        Config.TimerSeconds = value
    end, " s")
    AddMiniSlider(timerContent, "Timer Speed", "Скорость таймера", 16, 250, Config.TimerSpeed, function(value)
        Config.TimerSpeed = value
    end)
    AddMiniAction(timerContent, "Start Now", "Запустить сейчас", "START", function()
        RunTimedSpeed()
    end)
end)

TimerButton.MouseButton1Click:Connect(RunTimedSpeed)

--============================================================
-- AIM + TARGET INSIDE HUB DETAILS
--============================================================

local FOVRing = New("Frame", {
    Name = "AntiFreakFOV",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2),
    BackgroundTransparency = 1,
    Visible = false,
    ZIndex = 30,
})
Round(FOVRing, 999)
local FOVStroke = Stroke(FOVRing, ProfileThemes.AIM.Accent, Config.FOVOpacity / 100, Config.FOVThickness)
FOVRing.Parent = Gui

local AimTouchButton = New("TextButton", {
    Name = "AimTouchButton",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -15, 0.5, 0),
    Size = UDim2.fromOffset(76, 76),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "AIM\nOFF",
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
    Visible = false,
    ZIndex = 95,
})
Round(AimTouchButton, 26)
local AimTouchStroke = Stroke(AimTouchButton, ProfileThemes.AIM.Accent, 0.10, 1.5)
AimTouchButton.Parent = Gui
AnimateButton(AimTouchButton)

local CurrentAimTarget
local AimHighlight
local AIM_RENDER_NAME = "AntiFreakHubAimRenderV7"

local function RemoveAimHighlight()
    if AimHighlight then
        AimHighlight:Destroy()
        AimHighlight = nil
    end
end

local function SetAimTarget(player)
    if CurrentAimTarget == player then
        return
    end
    CurrentAimTarget = player
    RemoveAimHighlight()
    if player and Config.AimHighlight and player.Character then
        AimHighlight = New("Highlight", {
            Name = "AntiFreakAimTarget",
            Adornee = player.Character,
            FillColor = ProfileThemes.AIM.Accent,
            FillTransparency = 0.80,
            OutlineColor = ProfileThemes.AIM.Accent,
            OutlineTransparency = 0,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        })
        AimHighlight.Parent = player.Character
    end
end

local function AimTargetPart(character)
    if not character then return nil end
    if Config.AimTargetPart == "Head" then
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

local function IsVisible(character, part)
    if not Config.AimWallCheck then return true end
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local localCharacter = GetCharacter()
    params.FilterDescendantsInstances = localCharacter and {localCharacter} or {}
    params.IgnoreWater = true
    local result = Workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
    return not result or result.Instance:IsDescendantOf(character)
end

local function BestAimTarget()
    local camera = Workspace.CurrentCamera
    if not camera then return nil, nil end
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local localRoot = GetRoot()
    local bestPlayer, bestPart
    local bestScreenDistance = Config.FOVRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local part = character and AimTargetPart(character)
            local valid = humanoid and humanoid.Health > 0 and part ~= nil
            if valid and Config.AimTeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
                valid = false
            end
            if valid and localRoot and (part.Position - localRoot.Position).Magnitude > Config.AimMaxDistance then
                valid = false
            end
            if valid then
                local point, onScreen = camera:WorldToViewportPoint(part.Position)
                if not onScreen or point.Z <= 0 then
                    valid = false
                else
                    local screenDistance = (Vector2.new(point.X, point.Y) - center).Magnitude
                    if screenDistance > Config.FOVRadius or screenDistance >= bestScreenDistance then
                        valid = false
                    elseif not IsVisible(character, part) then
                        valid = false
                    else
                        bestPlayer = player
                        bestPart = part
                        bestScreenDistance = screenDistance
                    end
                end
            end
        end
    end
    return bestPlayer, bestPart
end

local function RefreshAimButton()
    AimTouchButton.Text = Config.Aim and "AIM\nON" or "AIM\nOFF"
    AimTouchButton.BackgroundColor3 = Config.Aim and ProfileThemes.AIM.Accent or Theme.Surface2
    AimTouchButton.TextColor3 = Config.Aim and Color3.new(1, 1, 1) or Theme.Text
end

local function SetAim(state)
    Config.Aim = state
    if AimController and AimController:Get() ~= state then
        AimController:Set(state, false)
    end
    if not state then
        SetAimTarget(nil)
    end
    if AimStatus then
        AimStatus.Text = state and "AIM\nON" or "AIM\nOFF"
        AimStatus.TextColor3 = state and Theme.Green or Theme.SubText
    end
    RefreshAimButton()
end

local function AimRender(dt)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    FOVRing.Position = UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVRing.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
    FOVRing.Visible = Config.Aim and Config.ShowFOV and Config.CurrentProfile == "AIM"
    FOVStroke.Color = ProfileThemes.AIM.Accent
    FOVStroke.Transparency = Config.FOVOpacity / 100
    FOVStroke.Thickness = Config.FOVThickness
    AimTouchButton.Visible = UserInputService.TouchEnabled and Config.CurrentProfile == "AIM"

    if not Config.Aim or Config.CurrentProfile ~= "AIM" then
        if CurrentAimTarget then SetAimTarget(nil) end
        return
    end
    local player, part = BestAimTarget()
    SetAimTarget(player)
    if not part then return end
    local target = CFrame.lookAt(camera.CFrame.Position, part.Position)
    if Config.AimSharpness >= 95 then
        camera.CFrame = target
    else
        local alpha = 1 - math.exp(-(Config.AimSharpness * 0.65) * dt)
        camera.CFrame = camera.CFrame:Lerp(target, math.clamp(alpha, 0, 1))
    end
end

pcall(function() RunService:UnbindFromRenderStep(AIM_RENDER_NAME) end)
RunService:BindToRenderStep(AIM_RENDER_NAME, Enum.RenderPriority.Camera.Value + 1, AimRender)

AimTouchButton.MouseButton1Click:Connect(function()
    SetAim(not Config.Aim)
    PlayUISound("click")
end)

-- Target selector/orbit
local SelectedTargetPlayer
local TargetRingGui
local OrbitConnection
local OrbitReturnCFrame
local TargetOrbitController
local targetSelectorList
local targetSelectorButton
local targetSelectedText

local function RemoveTargetRing()
    if TargetRingGui then
        TargetRingGui:Destroy()
        TargetRingGui = nil
    end
end

local function RefreshTargetRing()
    RemoveTargetRing()
    if not Config.TargetRing or not SelectedTargetPlayer or not SelectedTargetPlayer.Character then
        return
    end
    local root = SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local billboard = New("BillboardGui", {
        Name = "AntiFreakTargetRing",
        Adornee = root,
        AlwaysOnTop = true,
        Size = UDim2.fromOffset(78, 78),
        StudsOffset = Vector3.new(0, 0.2, 0),
    })
    local ring = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
    })
    Round(ring, 999)
    Stroke(ring, ProfileThemes.AIM.Accent, 0.05, 2)
    ring.Parent = billboard
    billboard.Parent = Gui
    TargetRingGui = billboard
end

local function SetSelectedTarget(player)
    SelectedTargetPlayer = player
    Config.SelectedTargetUserId = player and player.UserId or nil
    if targetSelectorButton then
        targetSelectorButton.Text = player and player.Name or "SELECT"
    end
    if targetSelectedText then
        targetSelectedText.Text = player and ("Selected  ·  " .. player.DisplayName .. " (@" .. player.Name .. ")") or "Selected  ·  None"
    end
    RefreshTargetRing()
end

local function StopOrbit(restore)
    if OrbitConnection then
        OrbitConnection:Disconnect()
        OrbitConnection = nil
    end
    Config.TargetOrbit = false
    if restore and OrbitReturnCFrame then
        local root = GetRoot()
        if root then
            root.CFrame = OrbitReturnCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
    OrbitReturnCFrame = nil
end

local function StartOrbit()
    StopOrbit(false)
    local root = GetRoot()
    local targetRoot = SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then
        Config.TargetOrbit = false
        if TargetOrbitController then TargetOrbitController:Set(false, false) end
        return
    end
    OrbitReturnCFrame = root.CFrame
    Config.TargetOrbit = true
    local angle = 0
    OrbitConnection = RunService.RenderStepped:Connect(function(dt)
        if not Config.TargetOrbit or Config.CurrentProfile ~= "AIM" then return end
        local localRoot = GetRoot()
        local currentTargetRoot = SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not localRoot or not currentTargetRoot or not humanoid or humanoid.Health <= 0 then
            StopOrbit(true)
            if TargetOrbitController then TargetOrbitController:Set(false, false) end
            return
        end
        angle = angle + (dt * Config.TargetOrbitSpeed * math.pi)
        local offset = Vector3.new(math.cos(angle) * Config.TargetOrbitRadius, 0.5, math.sin(angle) * Config.TargetOrbitRadius)
        local position = currentTargetRoot.Position + offset
        localRoot.CFrame = CFrame.lookAt(position, currentTargetRoot.Position)
        localRoot.AssemblyLinearVelocity = Vector3.zero
        localRoot.AssemblyAngularVelocity = Vector3.zero
    end)
end

-- Hub profile launch cards
local HubProfileHolder = New("Frame", {
    Size = UDim2.new(1, 0, 0, 108),
    BackgroundTransparency = 1,
})
HubProfileHolder.Parent = HubPage

local HubProfileGrid = New("UIGridLayout", {
    CellPadding = UDim2.fromOffset(8, 0),
    CellSize = UDim2.new(0.5, -4, 1, 0),
    FillDirectionMaxCells = 2,
    SortOrder = Enum.SortOrder.LayoutOrder,
})
HubProfileGrid.Parent = HubProfileHolder

local function CreateHubProfileCard(title, tag, descriptionEN, descriptionRU, icon, order)
    local card = New("Frame", {
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = order,
    })
    Round(card, 17)
    local cardStroke = Stroke(card, Theme.Stroke, 0.40, 1)
    card.Parent = HubProfileHolder
    BindTheme(card, {BackgroundColor3 = "Surface2"})
    BindTheme(cardStroke, {Color = "Stroke"})

    local iconBox = New("Frame", {
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(30, 30),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(iconBox, 10)
    iconBox.Parent = card
    BindTheme(iconBox, {BackgroundColor3 = "Surface3"})

    local iconText = New("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = icon,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    iconText.Parent = iconBox
    BindTheme(iconText, {TextColor3 = "Accent"})

    local tagLabel = New("TextLabel", {
        Position = UDim2.fromOffset(48, 9),
        Size = UDim2.new(1, -58, 0, 13),
        BackgroundTransparency = 1,
        Text = tag,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 7,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    tagLabel.Parent = card
    BindTheme(tagLabel, {TextColor3 = "Accent"})

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(48, 23),
        Size = UDim2.new(1, -58, 0, 17),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local desc = New("TextLabel", {
        Position = UDim2.fromOffset(10, 48),
        Size = UDim2.new(1, -20, 0, 24),
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 7,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    desc.Parent = card
    BindTheme(desc, {TextColor3 = "SubText"})
    BindDetail(desc, descriptionEN, descriptionRU)

    local open = New("TextButton", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -8),
        Size = UDim2.new(1, -20, 0, 27),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "OPEN",
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    Round(open, 10)
    open.Parent = card
    BindTheme(open, {BackgroundColor3 = "Surface3", TextColor3 = "Text"})
    AnimateButton(open)
    return open
end

local mm2Open = CreateHubProfileCard(
    "Murder Mystery 2",
    "MM2 PROFILE",
    "Open the independent MM2 profile.",
    "Открыть отдельный профиль MM2.",
    "◆",
    1
)

local aimOpen = CreateHubProfileCard(
    "Aim",
    "AIM PROFILE",
    "Open a separate aim interface with its own tabs and controls.",
    "Открыть отдельное AIM-меню со своими вкладками и настройками.",
    "◎",
    2
)

Players.PlayerRemoving:Connect(function(player)
    if player == SelectedTargetPlayer then
        StopOrbit(true)
        SetSelectedTarget(nil)
        if TargetOrbitController then TargetOrbitController:Set(false, false) end
    end
end)

--============================================================
-- SETTINGS
--============================================================

local function UpdateResponsiveScale()
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local fitScale = math.min((viewport.X - 18) / 600, (viewport.Y - 18) / 380, 1.2)
    MainScale.Scale = math.min(Config.UIScale, fitScale)
end

local InterfacePanel, InterfaceContent = CreateFeaturePanel(
    SettingsPage,
    "Interface Options",
    "Language affects detailed descriptions and setting labels only. Main tabs and feature names remain English.",
    "Язык влияет только на подробные описания и названия настроек. Основные вкладки и названия функций остаются на английском.",
    false,
    nil
)

AddMiniToggle(InterfaceContent, "Smooth Animations", "Плавные анимации", Config.Animations, function(state)
    Config.Animations = state
end)
AddMiniSlider(InterfaceContent, "Interface Size", "Размер интерфейса", 65, 115, math.floor(Config.UIScale * 100), function(value)
    Config.UIScale = value / 100
    UpdateResponsiveScale()
end, "%")
local languageRow, languageButton = AddMiniAction(InterfaceContent, "Detail Language", "Язык подробностей", Config.DetailLanguage, function(button)
    Config.DetailLanguage = Config.DetailLanguage == "RU" and "EN" or "RU"
    button.Text = Config.DetailLanguage
    RefreshLanguage()
end)
languageButton.Text = Config.DetailLanguage
AddMiniAction(InterfaceContent, "Reset Window", "Сбросить положение меню", "RESET", function()
    Tween(MainGroup, 0.86, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Quint)
end)
AddMiniAction(InterfaceContent, "Reset Open Button", "Сбросить кнопку открытия", "RESET", function()
    Tween(OpenButton, 0.86, {Position = UDim2.new(0, 16, 0.5, 0)}, Enum.EasingStyle.Quint)
end)

local statusCard = CreateCard(SettingsPage, 54)
local statusTitle = New("TextLabel", {
    Position = UDim2.fromOffset(13, 7),
    Size = UDim2.new(1, -26, 0, 18),
    BackgroundTransparency = 1,
    Text = "Diagnostics",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 9,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
})
statusTitle.Parent = statusCard
BindTheme(statusTitle, {TextColor3 = "Text"})
StatusLabel = New("TextLabel", {
    Position = UDim2.fromOffset(13, 28),
    Size = UDim2.new(1, -26, 0, 16),
    BackgroundTransparency = 1,
    Text = "System Status  ·  Ready",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Green,
})
StatusLabel.Parent = statusCard

--============================================================
-- INDEPENDENT HUB PROFILES: MM2 / AIM
--============================================================

local ProfileContainer = New("CanvasGroup", {
    Position = UDim2.fromOffset(10, 70),
    Size = UDim2.new(1, -20, 1, -80),
    BackgroundTransparency = 1,
    GroupTransparency = 1,
    Visible = false,
    ZIndex = 20,
})
ProfileContainer.Parent = MainFrame

-- MM2 profile
local MM2Profile = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    Visible = false,
})
Round(MM2Profile, 21)
local MM2ProfileStroke = Stroke(MM2Profile, Theme.Stroke, 0.35, 1)
MM2Profile.Parent = ProfileContainer
BindTheme(MM2Profile, {BackgroundColor3 = "Surface"})
BindTheme(MM2ProfileStroke, {Color = "Stroke"})

local MM2Center = New("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(320, 165),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
})
Round(MM2Center, 25)
local MM2CenterStroke = Stroke(MM2Center, Theme.Accent, 0.28, 1.2)
MM2Center.Parent = MM2Profile
BindTheme(MM2Center, {BackgroundColor3 = "Surface2"})
BindTheme(MM2CenterStroke, {Color = "Accent"})

local MM2CenterTitle = New("TextLabel", {
    Position = UDim2.fromOffset(20, 42),
    Size = UDim2.new(1, -40, 0, 24),
    BackgroundTransparency = 1,
    Text = "Murder Mystery 2",
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
})
MM2CenterTitle.Parent = MM2Center
BindTheme(MM2CenterTitle, {TextColor3 = "Text"})

local MM2CenterDesc = New("TextLabel", {
    Position = UDim2.fromOffset(24, 78),
    Size = UDim2.new(1, -48, 0, 45),
    BackgroundTransparency = 1,
    TextWrapped = true,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.SubText,
})
MM2CenterDesc.Parent = MM2Center
BindTheme(MM2CenterDesc, {TextColor3 = "SubText"})
BindDetail(MM2CenterDesc,
    "MM2 profile is active. Universal modules are temporarily disabled.",
    "Профиль MM2 активен. Универсальные функции временно отключены."
)

-- AIM profile shell
local AimProfile = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
})
AimProfile.Parent = ProfileContainer

local AimSidebar = New("Frame", {
    Size = UDim2.new(0, 112, 1, 0),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})
Round(AimSidebar, 19)
local AimSidebarStroke = Stroke(AimSidebar, Theme.Stroke, 0.35, 1)
AimSidebar.Parent = AimProfile
BindTheme(AimSidebar, {BackgroundColor3 = "Surface"})
BindTheme(AimSidebarStroke, {Color = "Stroke"})

local AimProfileLabel = New("TextLabel", {
    Position = UDim2.fromOffset(12, 11),
    Size = UDim2.new(1, -24, 0, 16),
    BackgroundTransparency = 1,
    Text = "AIM PROFILE",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Accent,
})
AimProfileLabel.Parent = AimSidebar
BindTheme(AimProfileLabel, {TextColor3 = "Accent"})

local AimTabsHolder = New("Frame", {
    Position = UDim2.fromOffset(7, 36),
    Size = UDim2.new(1, -14, 0, 126),
    BackgroundTransparency = 1,
})
AimTabsHolder.Parent = AimSidebar
local AimTabsLayout = New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
AimTabsLayout.Parent = AimTabsHolder

AimStatus = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -12),
    Size = UDim2.new(1, -18, 0, 28),
    BackgroundTransparency = 1,
    Text = "AIM\nOFF",
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.SubText,
})
AimStatus.Parent = AimSidebar

local AimContent = New("Frame", {
    Position = UDim2.fromOffset(122, 0),
    Size = UDim2.new(1, -122, 1, 0),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
Round(AimContent, 19)
local AimContentStroke = Stroke(AimContent, Theme.Stroke, 0.35, 1)
AimContent.Parent = AimProfile
BindTheme(AimContent, {BackgroundColor3 = "Surface"})
BindTheme(AimContentStroke, {Color = "Stroke"})

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
        ScrollingDirection = Enum.ScrollingDirection.Y,
    })
    Padding(scroll, 10, 10, 10, 12)
    scroll.Parent = group

    local layout = New("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    layout.Parent = scroll
    AimPages[name] = {Group = group, Scroll = scroll}
    return scroll
end

local AimMainPage = CreateAimPage("Aim")
local AimVisualsPage = CreateAimPage("Visuals")
local AimTargetPage = CreateAimPage("Target")

local function RefreshAimTabs()
    for name, button in pairs(AimTabButtons) do
        local active = Config.AimTab == name
        button.BackgroundTransparency = active and 0 or 1
        button.BackgroundColor3 = Theme.Surface3
        button.TextColor3 = active and Theme.Text or Theme.SubText
    end
end

local function SwitchAimTab(name)
    if not AimPages[name] then return end
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
    selected.Group.Position = UDim2.fromOffset(12, 0)
    if Config.Animations then
        Tween(selected.Group, 0.48, {
            GroupTransparency = 0,
            Position = UDim2.fromOffset(0, 0),
        }, Enum.EasingStyle.Quint)
    else
        selected.Group.GroupTransparency = 0
        selected.Group.Position = UDim2.fromOffset(0, 0)
    end
    RefreshAimTabs()
end

for index, data in ipairs({
    {"Aim", "◎"},
    {"Visuals", "◉"},
    {"Target", "◇"},
}) do
    local name, icon = data[1], data[2]
    local button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
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
    Round(button, 12)
    button.Parent = AimTabsHolder
    AimTabButtons[name] = button
    AnimateButton(button)
    button.MouseButton1Click:Connect(function()
        SwitchAimTab(name)
    end)
end
AddThemeRefresher(RefreshAimTabs)

CreateSection(AimMainPage, "Aim", nil)
AimController = AddMiniToggle(AimMainPage, "Aim Assist", "Включить AIM", Config.Aim, function(state)
    SetAim(state)
    AimStatus.Text = state and "AIM\nON" or "AIM\nOFF"
    AimStatus.TextColor3 = state and Theme.Green or Theme.SubText
end)
AddMiniSlider(AimMainPage, "Aim Response", "Резкость наведения", 20, 100, Config.AimSharpness, function(value)
    Config.AimSharpness = value
end, "%")
AddMiniSlider(AimMainPage, "Max Distance", "Макс. дистанция", 100, 2500, Config.AimMaxDistance, function(value)
    Config.AimMaxDistance = value
end, " studs")
AddMiniToggle(AimMainPage, "Wall Check", "Проверка стен", Config.AimWallCheck, function(state)
    Config.AimWallCheck = state
end)
AddMiniToggle(AimMainPage, "Team Check", "Проверка команды", Config.AimTeamCheck, function(state)
    Config.AimTeamCheck = state
end)
AddMiniAction(AimMainPage, "Target Part", "Часть тела", Config.AimTargetPart == "Head" and "HEAD" or "ROOT", function(button)
    if Config.AimTargetPart == "Head" then
        Config.AimTargetPart = "HumanoidRootPart"
        button.Text = "ROOT"
    else
        Config.AimTargetPart = "Head"
        button.Text = "HEAD"
    end
end)

CreateSection(AimVisualsPage, "Visuals", nil)
AddMiniToggle(AimVisualsPage, "Show FOV", "Показывать FOV", Config.ShowFOV, function(state)
    Config.ShowFOV = state
end)
AddMiniSlider(AimVisualsPage, "FOV Radius", "Радиус FOV", 45, 320, Config.FOVRadius, function(value)
    Config.FOVRadius = value
end, " px")
AddMiniSlider(AimVisualsPage, "FOV Opacity", "Прозрачность FOV", 5, 95, Config.FOVOpacity, function(value)
    Config.FOVOpacity = value
end, "%")
AddMiniSlider(AimVisualsPage, "FOV Thickness", "Толщина FOV", 1, 5, Config.FOVThickness, function(value)
    Config.FOVThickness = value
end)
AddMiniToggle(AimVisualsPage, "Target Highlight", "Подсветка цели", Config.AimHighlight, function(state)
    Config.AimHighlight = state
    if not state then
        RemoveAimHighlight()
    elseif CurrentAimTarget then
        local p = CurrentAimTarget
        CurrentAimTarget = nil
        SetAimTarget(p)
    end
end)

CreateSection(AimTargetPage, "Target", nil)
local selectorRow = New("Frame", {
    Size = UDim2.new(1, 0, 0, 54),
    BackgroundColor3 = Theme.Surface3,
    BorderSizePixel = 0,
})
Round(selectorRow, 12)
selectorRow.Parent = AimTargetPage
BindTheme(selectorRow, {BackgroundColor3 = "Surface3"})

local selectorTitle = New("TextLabel", {
    Position = UDim2.fromOffset(9, 4),
    Size = UDim2.new(1, -104, 0, 17),
    BackgroundTransparency = 1,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.Text,
})
selectorTitle.Parent = selectorRow
BindTheme(selectorTitle, {TextColor3 = "Text"})
BindSetting(selectorTitle, "Target Player", "Выбор игрока")

targetSelectedText = New("TextLabel", {
    Position = UDim2.fromOffset(9, 25),
    Size = UDim2.new(1, -18, 0, 16),
    BackgroundTransparency = 1,
    Text = "Selected  ·  None",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 7,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.SubText,
})
targetSelectedText.Parent = selectorRow
BindTheme(targetSelectedText, {TextColor3 = "SubText"})

targetSelectorButton = New("TextButton", {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -6, 0, 5),
    Size = UDim2.fromOffset(86, 27),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "SELECT",
    TextSize = 7,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
})
Round(targetSelectorButton, 10)
targetSelectorButton.Parent = selectorRow
BindTheme(targetSelectorButton, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
AnimateButton(targetSelectorButton)

targetSelectorList = New("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 0),
    BackgroundColor3 = Theme.Surface3,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = ProfileThemes.AIM.Accent,
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    CanvasSize = UDim2.fromOffset(0, 0),
    ClipsDescendants = true,
})
Round(targetSelectorList, 12)
targetSelectorList.Parent = AimTargetPage
BindTheme(targetSelectorList, {BackgroundColor3 = "Surface3"})
local targetListLayout = New("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
targetListLayout.Parent = targetSelectorList
Padding(targetSelectorList, 5, 5, 5, 5)

local targetListOpen = false
local function RefreshTargetList()
    for _, child in ipairs(targetSelectorList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then table.insert(list, player) end
    end
    table.sort(list, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)
    for index, player in ipairs(list) do
        local row = New("TextButton", {
            Size = UDim2.new(1, -2, 0, 30),
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = player.DisplayName .. "  (@" .. player.Name .. ")",
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 8,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Theme.Text,
            LayoutOrder = index,
        })
        Round(row, 9)
        Padding(row, 9, 6, 0, 0)
        row.Parent = targetSelectorList
        BindTheme(row, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
        AnimateButton(row)
        row.MouseButton1Click:Connect(function()
            SetSelectedTarget(player)
            targetListOpen = false
            Tween(targetSelectorList, 0.28, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quint)
        end)
    end
end

targetSelectorButton.MouseButton1Click:Connect(function()
    targetListOpen = not targetListOpen
    if targetListOpen then RefreshTargetList() end
    Tween(targetSelectorList, 0.32, {
        Size = UDim2.new(1, 0, 0, targetListOpen and 112 or 0),
    }, Enum.EasingStyle.Quint)
end)

TargetOrbitController = AddMiniToggle(AimTargetPage, "Orbit Target", "Вращаться вокруг цели", Config.TargetOrbit, function(state)
    if state then StartOrbit() else StopOrbit(true) end
end)
AddMiniSlider(AimTargetPage, "Orbit Radius", "Радиус вращения", 2, 12, Config.TargetOrbitRadius, function(value)
    Config.TargetOrbitRadius = value
end, " studs")
AddMiniSlider(AimTargetPage, "Orbit Speed", "Скорость вращения", 1, 6, math.floor(Config.TargetOrbitSpeed + 0.5), function(value)
    Config.TargetOrbitSpeed = value
end)
AddMiniToggle(AimTargetPage, "Target Ring", "Кольцо вокруг цели", Config.TargetRing, function(state)
    Config.TargetRing = state
    RefreshTargetRing()
end)
AddMiniAction(AimTargetPage, "Teleport Once", "Телепортироваться к цели", "GO", function()
    local localRoot = GetRoot()
    local targetRoot = SelectedTargetPlayer and SelectedTargetPlayer.Character and SelectedTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if localRoot and targetRoot then
        localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, Config.TargetOrbitRadius)
        localRoot.AssemblyLinearVelocity = Vector3.zero
        localRoot.AssemblyAngularVelocity = Vector3.zero
    end
end)

local SavedUniversalState = {}
local function SaveUniversalState()
    SavedUniversalState = {
        ESP = Config.ESP,
        Fly = Config.Fly,
        Speed = Config.Speed,
        ImpactSpin = Config.ImpactSpin,
        AntiFling = Config.AntiFling,
        TimerEnabled = Config.TimerEnabled,
    }
end

local function DisableUniversalModules()
    if ESPController then ESPController:Set(false, true) end
    if FlyController then FlyController:Set(false, true) end
    if SpeedController then SpeedController:Set(false, true) end
    if ImpactController then ImpactController:Set(false, true) end
    if AntiFlingController then AntiFlingController:Set(false, true) end
    if TimerController then TimerController:Set(false, true) end
end

local function RestoreUniversalState()
    if SavedUniversalState.ESP and ESPController then ESPController:Set(true, true) end
    if SavedUniversalState.Fly and FlyController then FlyController:Set(true, true) end
    if SavedUniversalState.Speed and SpeedController then SpeedController:Set(true, true) end
    if SavedUniversalState.ImpactSpin and ImpactController then ImpactController:Set(true, true) end
    if SavedUniversalState.AntiFling and AntiFlingController then AntiFlingController:Set(true, true) end
    if SavedUniversalState.TimerEnabled and TimerController then TimerController:Set(true, true) end
end

local function OpenProfile(profileName)
    if Config.CurrentProfile then return end
    if profileName ~= "MM2" and profileName ~= "AIM" then return end

    SaveUniversalState()
    DisableUniversalModules()
    SetAim(false)
    if Config.TargetOrbit then StopOrbit(true) end

    Config.CurrentProfile = profileName
    Sidebar.Visible = false
    Content.Visible = false
    ProfileContainer.Visible = true
    ProfileContainer.GroupTransparency = 1
    MM2Profile.Visible = false
    AimProfile.Visible = false

    BackButton.Visible = true
    Logo.Visible = false
    HeaderAccent.Visible = false
    HeaderTitle.Position = UDim2.fromOffset(60, 7)
    HeaderSubtitle.Position = UDim2.fromOffset(60, 26)

    if profileName == "MM2" then
        MM2Profile.Visible = true
        HeaderTitle.Text = "AntiFreak Hub · MM2"
        HeaderSubtitle.Text = "Murder Mystery 2 Profile"
        SetTheme(ProfileThemes.MM2)
    else
        AimProfile.Visible = true
        HeaderTitle.Text = "AntiFreak Hub · AIM"
        HeaderSubtitle.Text = "Independent Aim Profile"
        SetTheme(ProfileThemes.AIM)
        SwitchAimTab(Config.AimTab or "Aim")
        AimStatus.Text = "AIM\nOFF"
        AimStatus.TextColor3 = Theme.SubText
        RefreshTargetRing()
    end

    if Config.Animations then
        Tween(ProfileContainer, 0.62, {GroupTransparency = 0}, Enum.EasingStyle.Quint)
        if profileName == "MM2" then
            MM2Center.Position = UDim2.fromScale(0.5, 0.56)
            Tween(MM2Center, 0.82, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back)
        end
    else
        ProfileContainer.GroupTransparency = 0
    end
end

local function ExitProfile()
    if not Config.CurrentProfile then return end

    if Config.CurrentProfile == "AIM" then
        SetAim(false)
        if Config.TargetOrbit then StopOrbit(true) end
        RemoveTargetRing()
        AimTouchButton.Visible = false
        FOVRing.Visible = false
    end

    Config.CurrentProfile = nil
    MM2Profile.Visible = false
    AimProfile.Visible = false
    ProfileContainer.Visible = false
    ProfileContainer.GroupTransparency = 1
    Sidebar.Visible = true
    Content.Visible = true
    BackButton.Visible = false
    Logo.Visible = true
    HeaderAccent.Visible = true
    HeaderTitle.Position = UDim2.fromOffset(64, 7)
    HeaderSubtitle.Position = UDim2.fromOffset(64, 26)
    HeaderTitle.Text = "AntiFreak Hub"
    HeaderSubtitle.Text = "Compact Minimal Interface"
    SetTheme(DefaultTheme)
    RestoreUniversalState()
    SwitchTab("Hub")
end

BackButton.MouseButton1Click:Connect(ExitProfile)
mm2Open.MouseButton1Click:Connect(function()
    OpenProfile("MM2")
end)
aimOpen.MouseButton1Click:Connect(function()
    OpenProfile("AIM")
end)

RefreshLanguage()
UpdateModuleStatus()
SwitchAimTab("Aim")

--============================================================
-- MENU OPEN / CLOSE
--============================================================

local MenuBusy = false

local function OpenMenu()
    if Config.MenuOpen or MenuBusy then
        return
    end

    MenuBusy = true
    Config.MenuOpen = true
    PlayUISound("menu")
    MainGroup.Visible = true
    UpdateResponsiveScale()

    local targetScale = MainScale.Scale

    if Config.Animations then
        MainScale.Scale = targetScale * 0.78
        MainGroup.GroupTransparency = 1
        MainGroup.Position = UDim2.new(0.5, 0, 0.5, 14)

        Tween(MainScale, 0.82, {Scale = targetScale}, Enum.EasingStyle.Back)
        Tween(MainGroup, 0.62, {
            GroupTransparency = 0,
            Position = UDim2.fromScale(0.5, 0.5),
        }, Enum.EasingStyle.Quint)
        Tween(Blur, 0.60, {Size = 7}, Enum.EasingStyle.Quint)

        task.delay(0.85, function()
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
    PlayUISound("menu")

    if Config.Animations then
        local currentScale = MainScale.Scale
        Tween(MainScale, 0.42, {Scale = currentScale * 0.86}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(MainGroup, 0.40, {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.5, 12),
        }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        Tween(Blur, 0.45, {Size = 0})

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

CloseButton.MouseButton1Click:Connect(CloseMenu)

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

--============================================================
-- INPUT / RESPAWN / CAMERA
--============================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Space then
        FlyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
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
    if input.KeyCode == Enum.KeyCode.Space then
        FlyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.LeftControl then
        FlyDown = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid", 10)
    character:WaitForChild("HumanoidRootPart", 10)
    task.wait(0.30)

    if Config.Speed and SetSpeed then
        local humanoid = GetHumanoid()
        if humanoid then
            humanoid.WalkSpeed = Config.WalkSpeed
        end
    end

    if Config.Fly and SetFly then
        SetFly(true)
    end
    if Config.ImpactSpin and SetImpactSpin then
        SetImpactSpin(true)
    end
    if Config.AntiFling and SetAntiFling then
        SetAntiFling(true)
    end
end)

local cameraConnection = nil

local function HookCamera()
    if cameraConnection then
        cameraConnection:Disconnect()
        cameraConnection = nil
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale)
    UpdateResponsiveScale()
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(HookCamera)
HookCamera()

--============================================================
-- STARTUP
--============================================================

ApplyTheme()
SwitchTab("Visuals")
SwitchAimTab("Aim")
UpdateResponsiveScale()
UpdateModuleStatus()

MainGroup.Visible = true
MainGroup.GroupTransparency = 1

local startupScale = MainScale.Scale
MainScale.Scale = startupScale * 0.76
MainGroup.Position = UDim2.new(0.5, 0, 0.5, 16)
Blur.Size = 0

if Config.Animations then
    Tween(MainScale, 0.95, {Scale = startupScale}, Enum.EasingStyle.Back)
    Tween(MainGroup, 0.72, {
        GroupTransparency = 0,
        Position = UDim2.fromScale(0.5, 0.5),
    }, Enum.EasingStyle.Quint)
    Tween(Blur, 0.80, {Size = 7}, Enum.EasingStyle.Quint)
else
    MainScale.Scale = startupScale
    MainGroup.GroupTransparency = 0
    MainGroup.Position = UDim2.fromScale(0.5, 0.5)
    Blur.Size = 7
end

print("[AntiFreak Hub] v7 independent AIM build finished loading")
