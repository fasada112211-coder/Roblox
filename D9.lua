--[[
    AntiFreak Hub - Stable Minimal Build
    LocalScript -> StarterPlayer > StarterPlayerScripts
    UI language: English only
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
    AimSharpness = 12,
    AimMaxDistance = 1200,
    AimWallCheck = true,
    AimTeamCheck = false,
    AimHighlight = true,
    AimTargetPart = "Head",
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
    Text = "Stable Minimal Interface",
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
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
TabsLayout.Parent = TabsHolder

local VersionLabel = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -8),
    Size = UDim2.new(1, -20, 0, 14),
    BackgroundTransparency = 1,
    Text = "v5.0 stable",
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
    local card = CreateCard(parent, 57)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -82, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local descriptionLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -88, 0, 15),
        BackgroundTransparency = 1,
        Text = description or "",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    descriptionLabel.Parent = card
    BindTheme(descriptionLabel, {TextColor3 = "SubText"})

    local toggle = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
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
    Round(knob, 9)
    knob.Parent = toggle

    local value = defaultValue == true
    local controller = {}

    local function render(animated)
        local switchColor = value and Theme.Accent or Theme.Surface3
        local knobColor = value and Color3.new(1, 1, 1) or Theme.SubText
        local knobPosition = value and UDim2.new(1, -21, 0, 3) or UDim2.fromOffset(3, 3)

        if animated then
            Tween(toggle, 0.42, {BackgroundColor3 = switchColor})
            Tween(knob, 0.52, {
                Position = knobPosition,
                BackgroundColor3 = knobColor,
            }, Enum.EasingStyle.Back)
        else
            toggle.BackgroundColor3 = switchColor
            knob.BackgroundColor3 = knobColor
            knob.Position = knobPosition
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

    toggle.MouseButton1Click:Connect(function()
        controller:Set(not value, true)
    end)

    AnimateButton(toggle)
    render(false)
    return controller, card
end

local function CreateSlider(parent, title, minimum, maximum, defaultValue, callback, suffix)
    local card = CreateCard(parent, 66)
    local value = math.clamp(defaultValue, minimum, maximum)
    local dragging = false

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -92, 0, 17),
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
        Position = UDim2.new(1, -13, 0, 8),
        Size = UDim2.fromOffset(82, 17),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    valueLabel.Parent = card

    local bar = New("Frame", {
        Position = UDim2.fromOffset(13, 41),
        Size = UDim2.new(1, -26, 0, 7),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Active = true,
    })
    Round(bar, 4)
    bar.Parent = card
    BindTheme(bar, {BackgroundColor3 = "Surface3"})

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
    Round(knob, 8)
    local knobStroke = Stroke(knob, Theme.Accent, 0, 1.5)
    knob.Parent = bar

    local controller = {}

    local function render(animated)
        local alpha = (value - minimum) / (maximum - minimum)
        valueLabel.Text = tostring(math.floor(value + 0.5)) .. (suffix or "")
        valueLabel.TextColor3 = Theme.Accent
        fill.BackgroundColor3 = Theme.Accent
        knobStroke.Color = Theme.Accent

        if animated then
            Tween(fill, 0.24, {Size = UDim2.fromScale(alpha, 1)})
            Tween(knob, 0.24, {Position = UDim2.fromScale(alpha, 0.5)})
        else
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.fromScale(alpha, 0.5)
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

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            setFromX(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    render(false)
    return controller, card
end

local function CreateAction(parent, title, description, buttonText, callback)
    local card = CreateCard(parent, 57)

    local titleLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -105, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

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
    BindTheme(descLabel, {TextColor3 = "SubText"})

    local button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
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
    local buttonStroke = Stroke(button, Theme.Stroke, 0.35, 1)
    button.Parent = card
    BindTheme(button, {BackgroundColor3 = "Surface3", TextColor3 = "Text"})
    BindTheme(buttonStroke, {Color = "Stroke"})
    AnimateButton(button)

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
        Size = UDim2.new(1, 0, 0, 34),
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
        SwitchTab(name)
    end)
end

AddThemeRefresher(RefreshTabs)

--============================================================
-- UNIVERSAL UI CONTENT
--============================================================

CreateSection(VisualsPage, "Visuals", "Player rendering and color customization.")
CreateSection(PlayerPage, "Player", "Local character and device information.")
CreateSection(GamePage, "Game", "Movement and superhero flight controls.")
CreateSection(HubPage, "Hub", "Open an independent profile.")
CreateSection(MiscPage, "Misc", "Local physics utilities and protection.")
CreateSection(SettingsPage, "Settings", "Interface size, motion and diagnostics.")

local ESPController = nil
local FlyController = nil
local SpeedController = nil
local ImpactController = nil
local AntiFlingController = nil

--============================================================
-- ESP MODULE
--============================================================

SafeModule("ESP", function()
    local ESPHighlights = {}
    local ESPConnections = {}

    local function removeESP(player)
        local highlight = ESPHighlights[player]
        if highlight then
            highlight:Destroy()
        end
        ESPHighlights[player] = nil
    end

    local function addESP(player)
        if player == LocalPlayer then
            return
        end

        removeESP(player)
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

    local function refreshESPColor()
        for _, highlight in pairs(ESPHighlights) do
            if highlight and highlight.Parent then
                highlight.FillColor = Config.ESPColor
                highlight.OutlineColor = Config.ESPColor
            end
        end
    end

    local function setESP(state)
        Config.ESP = state
        if state then
            for _, player in ipairs(Players:GetPlayers()) do
                addESP(player)
            end
        else
            for player in pairs(ESPHighlights) do
                removeESP(player)
            end
        end
    end

    ESPController = CreateToggle(
        VisualsPage,
        "Player ESP",
        "Highlight players through geometry.",
        Config.ESP,
        setESP
    )

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ESPConnections[player] = player.CharacterAdded:Connect(function()
                task.wait(0.35)
                if Config.ESP then
                    addESP(player)
                end
            end)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then
            return
        end
        ESPConnections[player] = player.CharacterAdded:Connect(function()
            task.wait(0.35)
            if Config.ESP then
                addESP(player)
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(player)
        removeESP(player)
        if ESPConnections[player] then
            ESPConnections[player]:Disconnect()
            ESPConnections[player] = nil
        end
    end)

    -- Full HSV picker
    local PickerCard = CreateCard(VisualsPage, 57)

    local PickerTitle = New("TextLabel", {
        Position = UDim2.fromOffset(13, 8),
        Size = UDim2.new(1, -100, 0, 18),
        BackgroundTransparency = 1,
        Text = "ESP Color",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    PickerTitle.Parent = PickerCard
    BindTheme(PickerTitle, {TextColor3 = "Text"})

    local PickerSub = New("TextLabel", {
        Position = UDim2.fromOffset(13, 29),
        Size = UDim2.new(1, -110, 0, 15),
        BackgroundTransparency = 1,
        Text = "Full HSV palette with quick presets.",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    PickerSub.Parent = PickerCard
    BindTheme(PickerSub, {TextColor3 = "SubText"})

    local Preview = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -47, 0.5, 0),
        Size = UDim2.fromOffset(23, 23),
        BackgroundColor3 = Config.ESPColor,
        BorderSizePixel = 0,
    })
    Round(Preview, 8)
    Stroke(Preview, Color3.new(1, 1, 1), 0.62, 1)
    Preview.Parent = PickerCard

    local Arrow = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(25, 25),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "v",
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.SubText,
    })
    Round(Arrow, 9)
    Arrow.Parent = PickerCard
    BindTheme(Arrow, {BackgroundColor3 = "Surface3", TextColor3 = "SubText"})
    AnimateButton(Arrow)

    local Body = New("Frame", {
        Position = UDim2.fromOffset(13, 66),
        Size = UDim2.new(1, -26, 0, 188),
        BackgroundTransparency = 1,
    })
    Body.Parent = PickerCard

    local SVBox = New("Frame", {
        Size = UDim2.new(1, 0, 0, 108),
        BackgroundColor3 = Color3.fromHSV(0.73, 1, 1),
        BorderSizePixel = 0,
        Active = true,
    })
    Round(SVBox, 13)
    SVBox.Parent = Body

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
        Position = UDim2.fromScale(0.78, 0),
        Size = UDim2.fromOffset(14, 14),
        BackgroundTransparency = 1,
    })
    Round(SVMarker, 7)
    Stroke(SVMarker, Color3.new(1, 1, 1), 0, 2)
    SVMarker.Parent = SVBox

    local HueBar = New("Frame", {
        Position = UDim2.fromOffset(0, 118),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Active = true,
    })
    Round(HueBar, 7)
    HueBar.Parent = Body

    local huePoints = {}
    for i = 0, 12 do
        local hue = i / 12
        table.insert(huePoints, ColorSequenceKeypoint.new(hue, Color3.fromHSV(hue, 1, 1)))
    end
    local HueGradient = New("UIGradient", {Color = ColorSequence.new(huePoints)})
    HueGradient.Parent = HueBar

    local HueMarker = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.73, 0.5),
        Size = UDim2.fromOffset(5, 21),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    })
    Round(HueMarker, 3)
    Stroke(HueMarker, Color3.new(0, 0, 0), 0.4, 1)
    HueMarker.Parent = HueBar

    local Presets = New("Frame", {
        Position = UDim2.fromOffset(0, 143),
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
    })
    Presets.Parent = Body

    local PresetLayout = New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 7),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    PresetLayout.Parent = Presets

    local hue = 0.73
    local saturation = 0.78
    local value = 1
    local hueDragging = false
    local svDragging = false
    local pickerOpen = false

    local function refreshPicker()
        Config.ESPColor = Color3.fromHSV(hue, saturation, value)
        Preview.BackgroundColor3 = Config.ESPColor
        SVBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        refreshESPColor()
    end

    local function setPickerColor(color)
        local h, s, v = color:ToHSV()
        hue = h
        saturation = s
        value = v
        HueMarker.Position = UDim2.fromScale(hue, 0.5)
        SVMarker.Position = UDim2.fromScale(saturation, 1 - value)
        refreshPicker()
    end

    local presetColors = {
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

    for index, color in ipairs(presetColors) do
        local preset = New("TextButton", {
            Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Text = "",
            LayoutOrder = index,
        })
        Round(preset, 8)
        Stroke(preset, Color3.new(1, 1, 1), 0.72, 1)
        preset.Parent = Presets
        AnimateButton(preset)
        preset.MouseButton1Click:Connect(function()
            setPickerColor(color)
        end)
    end

    local function updateHue(x)
        if HueBar.AbsoluteSize.X <= 0 then
            return
        end
        hue = math.clamp((x - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
        HueMarker.Position = UDim2.fromScale(hue, 0.5)
        refreshPicker()
    end

    local function updateSV(position)
        local size = SVBox.AbsoluteSize
        if size.X <= 0 or size.Y <= 0 then
            return
        end
        local x = math.clamp((position.X - SVBox.AbsolutePosition.X) / size.X, 0, 1)
        local y = math.clamp((position.Y - SVBox.AbsolutePosition.Y) / size.Y, 0, 1)
        saturation = x
        value = 1 - y
        SVMarker.Position = UDim2.fromScale(x, y)
        refreshPicker()
    end

    HueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = true
            updateHue(input.Position.X)
        end
    end)

    SVBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            svDragging = true
            updateSV(input.Position)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        if hueDragging then
            updateHue(input.Position.X)
        end
        if svDragging then
            updateSV(input.Position)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            hueDragging = false
            svDragging = false
        end
    end)

    Arrow.MouseButton1Click:Connect(function()
        pickerOpen = not pickerOpen
        Arrow.Text = pickerOpen and "^" or "v"
        local targetHeight = pickerOpen and 263 or 57
        if Config.Animations then
            Tween(PickerCard, 0.68, {Size = UDim2.new(1, 0, 0, targetHeight)})
        else
            PickerCard.Size = UDim2.new(1, 0, 0, targetHeight)
        end
    end)
end)

--============================================================
-- PLAYER PAGE
--============================================================

SafeModule("Player Page", function()
    local infoCard = CreateCard(PlayerPage, 92)

    local nameLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 10),
        Size = UDim2.new(1, -26, 0, 17),
        BackgroundTransparency = 1,
        Text = "Player  ·  " .. LocalPlayer.Name,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    nameLabel.Parent = infoCard
    BindTheme(nameLabel, {TextColor3 = "Text"})

    local displayLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 32),
        Size = UDim2.new(1, -26, 0, 15),
        BackgroundTransparency = 1,
        Text = "Display Name  ·  " .. LocalPlayer.DisplayName,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    displayLabel.Parent = infoCard
    BindTheme(displayLabel, {TextColor3 = "SubText"})

    local inputLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 52),
        Size = UDim2.new(1, -26, 0, 15),
        BackgroundTransparency = 1,
        Text = UserInputService.TouchEnabled and "Input  ·  Touch" or "Input  ·  Keyboard / Mouse",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    inputLabel.Parent = infoCard
    BindTheme(inputLabel, {TextColor3 = "SubText"})

    local speedLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 71),
        Size = UDim2.new(1, -26, 0, 14),
        BackgroundTransparency = 1,
        Text = "WalkSpeed  ·  16",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    speedLabel.Parent = infoCard

    RunService.RenderStepped:Connect(function()
        local humanoid = GetHumanoid()
        if humanoid and speedLabel.Parent then
            speedLabel.Text = "WalkSpeed  ·  " .. tostring(math.floor(humanoid.WalkSpeed))
            speedLabel.TextColor3 = Theme.Accent
        end
    end)
end)

--============================================================
-- SPEED MODULE
--============================================================

local StoredWalkSpeed = nil
local SetSpeed = nil

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

    SpeedController = CreateToggle(
        GamePage,
        "Speed",
        "Override the local character WalkSpeed.",
        Config.Speed,
        SetSpeed
    )

    CreateSlider(GamePage, "WalkSpeed", 16, 250, Config.WalkSpeed, function(value)
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
-- FLY MODULE
--============================================================

local FlyBodyVelocity = nil
local FlyBodyGyro = nil
local FlyConnection = nil
local FlyUp = false
local FlyDown = false
local FlyMotors = {}
local SetFly = nil

SafeModule("Fly", function()
    local function resetPose()
        for _, motor in pairs(FlyMotors) do
            if motor and motor.Parent then
                motor.Transform = CFrame.new()
            end
        end
    end

    local function cacheMotors()
        table.clear(FlyMotors)
        local character = GetCharacter()
        if not character then
            return
        end

        local upperTorso = character:FindFirstChild("UpperTorso")
        local torso = character:FindFirstChild("Torso")

        if upperTorso then
            FlyMotors.RightShoulder = upperTorso:FindFirstChild("RightShoulder")
            FlyMotors.LeftShoulder = upperTorso:FindFirstChild("LeftShoulder")
            FlyMotors.Waist = upperTorso:FindFirstChild("Waist")
            FlyMotors.Neck = upperTorso:FindFirstChild("Neck")
        elseif torso then
            FlyMotors.RightShoulder = torso:FindFirstChild("Right Shoulder")
            FlyMotors.LeftShoulder = torso:FindFirstChild("Left Shoulder")
            FlyMotors.Neck = torso:FindFirstChild("Neck")
        end
    end

    local function updatePose(timeValue, moving)
        local wave = math.sin(timeValue * 4.5) * 2.8
        local shoulderAngle = moving and -122 or -96

        local right = FlyMotors.RightShoulder
        local left = FlyMotors.LeftShoulder
        local waist = FlyMotors.Waist
        local neck = FlyMotors.Neck

        if right and right:IsA("Motor6D") then
            right.Transform = CFrame.Angles(math.rad(shoulderAngle + wave), math.rad(-4), math.rad(10))
        end
        if left and left:IsA("Motor6D") then
            left.Transform = CFrame.Angles(math.rad(shoulderAngle - wave), math.rad(4), math.rad(-10))
        end
        if waist and waist:IsA("Motor6D") then
            waist.Transform = CFrame.Angles(math.rad(-7), 0, math.rad(math.sin(timeValue * 2.5) * 2))
        end
        if neck and neck:IsA("Motor6D") then
            neck.Transform = CFrame.Angles(math.rad(8), 0, 0)
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
            MaxForce = Vector3.new(1e9, 1e9, 1e9),
            P = 9000,
            Velocity = Vector3.zero,
        })
        FlyBodyVelocity.Parent = root

        FlyBodyGyro = New("BodyGyro", {
            Name = "AntiFreakFlyGyro",
            MaxTorque = Vector3.new(1e9, 1e9, 1e9),
            P = 25000,
            D = 700,
            CFrame = root.CFrame,
        })
        FlyBodyGyro.Parent = root

        local startTime = os.clock()
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

            local moveDirection = currentHumanoid.MoveDirection
            local direction = Vector3.zero
            if moveDirection.Magnitude > 0.05 then
                direction = moveDirection.Unit
            end

            local vertical = 0
            if FlyUp then
                vertical = vertical + 1
            end
            if FlyDown then
                vertical = vertical - 1
            end

            local moving = direction.Magnitude > 0.05 or vertical ~= 0
            FlyBodyVelocity.Velocity = (direction * Config.FlySpeed) + Vector3.new(0, vertical * Config.FlySpeed, 0)

            local facing
            if direction.Magnitude > 0.05 then
                facing = Vector3.new(direction.X, 0, direction.Z)
            else
                facing = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            end

            if facing.Magnitude < 0.01 then
                facing = currentRoot.CFrame.LookVector
            else
                facing = facing.Unit
            end

            local tilt = moving and Config.FlyTilt or 4
            local roll = 0
            if direction.Magnitude > 0.05 then
                roll = -camera.CFrame.RightVector:Dot(direction) * 10
            end

            FlyBodyGyro.CFrame = CFrame.lookAt(currentRoot.Position, currentRoot.Position + facing)
                * CFrame.Angles(math.rad(-tilt), 0, math.rad(roll))

            updatePose(os.clock() - startTime, moving)
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

    FlyController = CreateToggle(
        GamePage,
        "Superhero Fly",
        "Smooth flight with a cinematic superhero pose.",
        Config.Fly,
        SetFly
    )

    CreateSlider(GamePage, "Flight Speed", 10, 300, Config.FlySpeed, function(value)
        Config.FlySpeed = value
    end)

    CreateSlider(GamePage, "Flight Tilt", 0, 55, Config.FlyTilt, function(value)
        Config.FlyTilt = value
    end, "°")
end)

--============================================================
-- TOUCH FLIGHT CONTROLS
--============================================================

SafeModule("Touch Flight Controls", function()
    local holder = New("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -15, 0.5, 0),
        Size = UDim2.fromOffset(60, 126),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 92,
    })
    holder.Parent = Gui

    local function createButton(y, text)
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
            ZIndex = 93,
        })
        Round(button, 21)
        local buttonStroke = Stroke(button, Theme.Accent, 0.15, 1.3)
        button.Parent = holder
        BindTheme(button, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
        BindTheme(buttonStroke, {Color = "Accent"})
        AnimateButton(button)
        return button
    end

    local up = createButton(0, "▲\nUP")
    local down = createButton(68, "▼\nDOWN")

    local function bindHold(button, callback)
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

    bindHold(up, function(state)
        FlyUp = state
    end)
    bindHold(down, function(state)
        FlyDown = state
    end)

    RunService.RenderStepped:Connect(function()
        holder.Visible = UserInputService.TouchEnabled and Config.Fly and Config.CurrentProfile == nil
    end)
end)

--============================================================
-- IMPACT SPIN / ANTI-FLING
--============================================================

local SetImpactSpin = nil
local SetAntiFling = nil

SafeModule("Impact Spin", function()
    local connection = nil

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
            if not root then
                return
            end
            root.AssemblyAngularVelocity = Vector3.new(0, 95, 0)
            if root.AssemblyLinearVelocity.Magnitude > 125 then
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity.Unit * 85
            end
        end)
    end

    SetImpactSpin = function(state)
        Config.ImpactSpin = state
        if state then
            start()
        else
            stop()
        end
    end

    ImpactController = CreateToggle(
        MiscPage,
        "Touch Fling",
        "High-energy local contact spin with velocity protection.",
        Config.ImpactSpin,
        SetImpactSpin
    )
end)

SafeModule("Anti-Fling", function()
    local connection = nil
    local collisionCache = {}

    local function stop()
        if connection then
            connection:Disconnect()
            connection = nil
        end
        for part, oldState in pairs(collisionCache) do
            if part and part.Parent then
                pcall(function()
                    part.CanCollide = oldState
                end)
            end
        end
        table.clear(collisionCache)
    end

    local function start()
        stop()
        connection = RunService.Heartbeat:Connect(function()
            if not Config.AntiFling then
                return
            end

            local root = GetRoot()
            if root then
                if root.AssemblyLinearVelocity.Magnitude > 115 then
                    root.AssemblyLinearVelocity = Vector3.zero
                end
                if root.AssemblyAngularVelocity.Magnitude > 75 then
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            end

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, object in ipairs(player.Character:GetDescendants()) do
                        if object:IsA("BasePart") then
                            if collisionCache[object] == nil then
                                collisionCache[object] = object.CanCollide
                            end
                            object.CanCollide = false
                        end
                    end
                end
            end
        end)
    end

    SetAntiFling = function(state)
        Config.AntiFling = state
        if state then
            start()
        else
            stop()
        end
    end

    AntiFlingController = CreateToggle(
        MiscPage,
        "Anti-Fling",
        "Suppress abnormal velocity and player collisions.",
        Config.AntiFling,
        SetAntiFling
    )
end)

--============================================================
-- SETTINGS PAGE
--============================================================

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
    MainScale.Scale = math.min(Config.UIScale, fitScale)
end

SafeModule("Settings", function()
    CreateToggle(
        SettingsPage,
        "Smooth Animations",
        "Enable longer, softer transitions.",
        Config.Animations,
        function(state)
            Config.Animations = state
        end
    )

    CreateSlider(
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

    CreateAction(SettingsPage, "Reset Window", "Move the menu back to the center.", "RESET", function()
        Tween(MainGroup, 0.72, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Quint)
    end)

    CreateAction(SettingsPage, "Reset Open Button", "Restore the floating button position.", "RESET", function()
        Tween(OpenButton, 0.72, {Position = UDim2.new(0, 16, 0.5, 0)}, Enum.EasingStyle.Quint)
    end)

    local statusCard = CreateCard(SettingsPage, 74)
    local statusTitle = New("TextLabel", {
        Position = UDim2.fromOffset(13, 9),
        Size = UDim2.new(1, -26, 0, 18),
        BackgroundTransparency = 1,
        Text = "Diagnostics",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    statusTitle.Parent = statusCard
    BindTheme(statusTitle, {TextColor3 = "Text"})

    StatusLabel = New("TextLabel", {
        Position = UDim2.fromOffset(13, 31),
        Size = UDim2.new(1, -26, 0, 16),
        BackgroundTransparency = 1,
        Text = "System Status  ·  Ready",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Green,
    })
    StatusLabel.Parent = statusCard

    local hint = New("TextLabel", {
        Position = UDim2.fromOffset(13, 49),
        Size = UDim2.new(1, -26, 0, 15),
        BackgroundTransparency = 1,
        Text = "Check Studio Output if this status reports an issue.",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 7,
        Font = Enum.Font.GothamMedium,
        TextColor3 = Theme.SubText,
    })
    hint.Parent = statusCard
    BindTheme(hint, {TextColor3 = "SubText"})

    UpdateModuleStatus()
end)

--============================================================
-- HUB PROFILE CARDS
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

local HubGridHolder = New("Frame", {
    Size = UDim2.new(1, 0, 0, 144),
    BackgroundTransparency = 1,
})
HubGridHolder.Parent = HubPage

local HubGrid = New("UIGridLayout", {
    CellPadding = UDim2.fromOffset(8, 0),
    CellSize = UDim2.new(0.5, -4, 1, 0),
    FillDirectionMaxCells = 2,
    SortOrder = Enum.SortOrder.LayoutOrder,
})
HubGrid.Parent = HubGridHolder

local function CreateProfileCard(title, tag, description, icon, order, callback)
    local card = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = order,
    })
    Round(card, 19)
    local cardStroke = Stroke(card, Theme.Stroke, 0.38, 1)
    card.Parent = HubGridHolder
    BindTheme(card, {BackgroundColor3 = "Surface2"})
    BindTheme(cardStroke, {Color = "Stroke"})

    local iconBox = New("Frame", {
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
    })
    Round(iconBox, 11)
    iconBox.Parent = card
    BindTheme(iconBox, {BackgroundColor3 = "Surface3"})

    local iconLabel = New("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = icon,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Accent,
    })
    iconLabel.Parent = iconBox
    BindTheme(iconLabel, {TextColor3 = "Accent"})

    local tagLabel = New("TextLabel", {
        Position = UDim2.fromOffset(52, 12),
        Size = UDim2.new(1, -64, 0, 13),
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
        Position = UDim2.fromOffset(52, 26),
        Size = UDim2.new(1, -64, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    titleLabel.Parent = card
    BindTheme(titleLabel, {TextColor3 = "Text"})

    local descriptionLabel = New("TextLabel", {
        Position = UDim2.fromOffset(12, 54),
        Size = UDim2.new(1, -24, 0, 38),
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
    BindTheme(descriptionLabel, {TextColor3 = "SubText"})

    local open = New("TextButton", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -11),
        Size = UDim2.new(1, -24, 0, 30),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "OPEN",
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
    })
    Round(open, 11)
    local openStroke = Stroke(open, Theme.Stroke, 0.25, 1)
    open.Parent = card
    BindTheme(open, {BackgroundColor3 = "Surface3", TextColor3 = "Text"})
    BindTheme(openStroke, {Color = "Stroke"})
    AnimateButton(open)
    open.MouseButton1Click:Connect(callback)
end

--============================================================
-- MM2 PROFILE
--============================================================

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

local MM2Card = New("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(320, 170),
    BackgroundColor3 = Theme.Surface2,
    BorderSizePixel = 0,
})
Round(MM2Card, 25)
local MM2CardStroke = Stroke(MM2Card, Theme.Accent, 0.30, 1.2)
MM2Card.Parent = MM2Profile
BindTheme(MM2Card, {BackgroundColor3 = "Surface2"})
BindTheme(MM2CardStroke, {Color = "Accent"})

local MM2Icon = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 20),
    Size = UDim2.fromOffset(46, 46),
    BackgroundColor3 = Theme.Surface3,
    BorderSizePixel = 0,
    Text = "◆",
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Accent,
})
Round(MM2Icon, 16)
MM2Icon.Parent = MM2Card
BindTheme(MM2Icon, {BackgroundColor3 = "Surface3", TextColor3 = "Accent"})

local MM2Title = New("TextLabel", {
    Position = UDim2.fromOffset(15, 80),
    Size = UDim2.new(1, -30, 0, 22),
    BackgroundTransparency = 1,
    Text = "Murder Mystery 2",
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Text,
})
MM2Title.Parent = MM2Card
BindTheme(MM2Title, {TextColor3 = "Text"})

local MM2Sub = New("TextLabel", {
    Position = UDim2.fromOffset(22, 108),
    Size = UDim2.new(1, -44, 0, 38),
    BackgroundTransparency = 1,
    Text = "MM2 profile is active.\nUniversal modules are hidden and disabled.",
    TextWrapped = true,
    TextSize = 8,
    Font = Enum.Font.GothamMedium,
    TextColor3 = Theme.SubText,
})
MM2Sub.Parent = MM2Card
BindTheme(MM2Sub, {TextColor3 = "SubText"})

--============================================================
-- AIM PROFILE UI
--============================================================

local AimProfile = New("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Visible = false,
})
AimProfile.Parent = ProfileContainer

local AimSidebar = New("Frame", {
    Size = UDim2.new(0, 116, 1, 0),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
})
Round(AimSidebar, 20)
local AimSidebarStroke = Stroke(AimSidebar, Theme.Stroke, 0.38, 1)
AimSidebar.Parent = AimProfile
BindTheme(AimSidebar, {BackgroundColor3 = "Surface"})
BindTheme(AimSidebarStroke, {Color = "Stroke"})

local AimNavTitle = New("TextLabel", {
    Position = UDim2.fromOffset(13, 12),
    Size = UDim2.new(1, -26, 0, 15),
    BackgroundTransparency = 1,
    Text = "AIM PROFILE",
    TextXAlignment = Enum.TextXAlignment.Left,
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.Accent,
})
AimNavTitle.Parent = AimSidebar
BindTheme(AimNavTitle, {TextColor3 = "Accent"})

local AimTabsHolder = New("Frame", {
    Position = UDim2.fromOffset(8, 38),
    Size = UDim2.new(1, -16, 0, 82),
    BackgroundTransparency = 1,
})
AimTabsHolder.Parent = AimSidebar

local AimTabsLayout = New("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
})
AimTabsLayout.Parent = AimTabsHolder

local AimStatus = New("TextLabel", {
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -13),
    Size = UDim2.new(1, -20, 0, 30),
    BackgroundTransparency = 1,
    Text = "AIM\nOFF",
    TextSize = 8,
    Font = Enum.Font.GothamBold,
    TextColor3 = Theme.SubText,
})
AimStatus.Parent = AimSidebar

local AimContent = New("Frame", {
    Position = UDim2.fromOffset(126, 0),
    Size = UDim2.new(1, -126, 1, 0),
    BackgroundColor3 = Theme.Surface,
    BorderSizePixel = 0,
    ClipsDescendants = true,
})
Round(AimContent, 20)
local AimContentStroke = Stroke(AimContent, Theme.Stroke, 0.38, 1)
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

local AimVisualsPage = CreateAimPage("Visuals")
local AimSettingsPage = CreateAimPage("Aim")

CreateSection(AimVisualsPage, "Visuals", "FOV and target appearance.")
CreateSection(AimSettingsPage, "Aim", "Target selection and camera assistance.")

local function RefreshAimTabs()
    for name, button in pairs(AimTabButtons) do
        local active = Config.AimTab == name
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
    selected.Group.Position = UDim2.fromOffset(12, 0)

    if Config.Animations then
        Tween(selected.Group, 0.55, {
            GroupTransparency = 0,
            Position = UDim2.fromOffset(0, 0),
        }, Enum.EasingStyle.Quint)
    else
        selected.Group.GroupTransparency = 0
    end

    RefreshAimTabs()
end

local aimTabData = {
    {"Visuals", "◉"},
    {"Aim", "◎"},
}

for index, data in ipairs(aimTabData) do
    local name = data[1]
    local icon = data[2]
    local button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 35),
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

--============================================================
-- AIM FOV + MOBILE BUTTON
--============================================================

local FOVRing = New("Frame", {
    Name = "AimFOV",
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
    Position = UDim2.new(1, -16, 0.5, 0),
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
Round(AimTouchButton, 24)
local AimTouchStroke = Stroke(AimTouchButton, Theme.Accent, 0.1, 1.5)
AimTouchButton.Parent = Gui
BindTheme(AimTouchButton, {BackgroundColor3 = "Surface2", TextColor3 = "Text"})
BindTheme(AimTouchStroke, {Color = "Accent"})
AnimateButton(AimTouchButton)
MakeDraggable(AimTouchButton, AimTouchButton)

--============================================================
-- AIM ENGINE
--============================================================

local AimController = nil
local CurrentAimTarget = nil
local CurrentAimHighlight = nil
local AIM_RENDER_NAME = "AntiFreakHubAimRender"

local function RemoveAimHighlight()
    if CurrentAimHighlight then
        CurrentAimHighlight:Destroy()
        CurrentAimHighlight = nil
    end
end

local function RefreshAimStateUI()
    if Config.Aim then
        AimStatus.Text = "AIM\nON"
        AimStatus.TextColor3 = Theme.Green
        AimTouchButton.Text = "AIM\nON"
        AimTouchButton.BackgroundColor3 = Theme.Accent
        AimTouchButton.TextColor3 = Color3.new(1, 1, 1)
    else
        AimStatus.Text = "AIM\nOFF"
        AimStatus.TextColor3 = Theme.SubText
        AimTouchButton.Text = "AIM\nOFF"
        AimTouchButton.BackgroundColor3 = Theme.Surface2
        AimTouchButton.TextColor3 = Theme.Text
    end
end

local function SetAimTarget(player)
    if CurrentAimTarget == player then
        return
    end

    CurrentAimTarget = player
    RemoveAimHighlight()

    if not player or not Config.AimHighlight then
        return
    end

    local character = player.Character
    if not character then
        return
    end

    CurrentAimHighlight = New("Highlight", {
        Name = "AntiFreakAimTarget",
        Adornee = character,
        FillColor = Theme.Accent,
        FillTransparency = 0.78,
        OutlineColor = Theme.Accent,
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
    })
    CurrentAimHighlight.Parent = character
end

local function GetAimPart(character)
    if Config.AimTargetPart == "Head" then
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
end

local function TargetVisible(character, targetPart)
    if not Config.AimWallCheck then
        return true
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return false
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {GetCharacter()}
    params.IgnoreWater = true

    local direction = targetPart.Position - camera.CFrame.Position
    local result = Workspace:Raycast(camera.CFrame.Position, direction, params)
    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(character)
end

local function GetBestAimTarget()
    local camera = Workspace.CurrentCamera
    if not camera then
        return nil, nil
    end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local bestPlayer = nil
    local bestPart = nil
    local bestScreenDistance = Config.FOVRadius
    local localRoot = GetRoot()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local valid = humanoid and humanoid.Health > 0

                if valid and Config.AimTeamCheck and LocalPlayer.Team ~= nil and player.Team == LocalPlayer.Team then
                    valid = false
                end

                local targetPart = valid and GetAimPart(character) or nil

                if valid and targetPart and localRoot then
                    local worldDistance = (targetPart.Position - localRoot.Position).Magnitude
                    if worldDistance > Config.AimMaxDistance then
                        valid = false
                    end
                end

                if valid and targetPart then
                    local point, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if not onScreen or point.Z <= 0 then
                        valid = false
                    else
                        local screenPosition = Vector2.new(point.X, point.Y)
                        local screenDistance = (screenPosition - center).Magnitude
                        if screenDistance > Config.FOVRadius then
                            valid = false
                        elseif not TargetVisible(character, targetPart) then
                            valid = false
                        elseif screenDistance < bestScreenDistance then
                            bestScreenDistance = screenDistance
                            bestPlayer = player
                            bestPart = targetPart
                        end
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart
end

local function AimRenderStep(deltaTime)
    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local activeProfile = Config.CurrentProfile == "AIM"

    FOVRing.Visible = activeProfile and Config.ShowFOV
    FOVRing.Position = UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    FOVRing.Size = UDim2.fromOffset(Config.FOVRadius * 2, Config.FOVRadius * 2)
    FOVStroke.Thickness = Config.FOVThickness
    FOVStroke.Transparency = Config.FOVOpacity / 100
    FOVStroke.Color = ProfileThemes.AIM.Accent

    AimTouchButton.Visible = activeProfile and UserInputService.TouchEnabled

    if not activeProfile or not Config.Aim then
        if CurrentAimTarget then
            SetAimTarget(nil)
        end
        return
    end

    local player, part = GetBestAimTarget()
    SetAimTarget(player)

    if not player or not part then
        return
    end

    local targetCFrame = CFrame.lookAt(camera.CFrame.Position, part.Position)
    local alpha = 1 - math.exp(-Config.AimSharpness * deltaTime)
    camera.CFrame = camera.CFrame:Lerp(targetCFrame, math.clamp(alpha, 0, 1))
end

SafeModule("Aim Engine", function()
    pcall(function()
        RunService:UnbindFromRenderStep(AIM_RENDER_NAME)
    end)

    RunService:BindToRenderStep(
        AIM_RENDER_NAME,
        Enum.RenderPriority.Camera.Value + 1,
        AimRenderStep
    )

    AimController = CreateToggle(
        AimSettingsPage,
        "Aim Assist",
        "Smoothly track the closest target inside FOV.",
        Config.Aim,
        function(state)
            Config.Aim = state
            if not state then
                SetAimTarget(nil)
            end
            RefreshAimStateUI()
        end
    )

    CreateSlider(AimSettingsPage, "Aim Sharpness", 2, 35, Config.AimSharpness, function(value)
        Config.AimSharpness = value
    end)

    CreateSlider(AimSettingsPage, "Max Distance", 100, 2500, Config.AimMaxDistance, function(value)
        Config.AimMaxDistance = value
    end, " studs")

    CreateToggle(AimSettingsPage, "Wall Check", "Only target players visible from the camera.", Config.AimWallCheck, function(state)
        Config.AimWallCheck = state
    end)

    CreateToggle(AimSettingsPage, "Team Check", "Ignore players on your team.", Config.AimTeamCheck, function(state)
        Config.AimTeamCheck = state
    end)

    CreateAction(AimSettingsPage, "Target Part", "Current target: Head", "HEAD", function(button, descLabel)
        if Config.AimTargetPart == "Head" then
            Config.AimTargetPart = "HumanoidRootPart"
            button.Text = "ROOT"
            descLabel.Text = "Current target: Root"
        else
            Config.AimTargetPart = "Head"
            button.Text = "HEAD"
            descLabel.Text = "Current target: Head"
        end
    end)

    CreateToggle(AimVisualsPage, "Show FOV", "Display the aim field-of-view circle.", Config.ShowFOV, function(state)
        Config.ShowFOV = state
    end)

    CreateSlider(AimVisualsPage, "FOV Radius", 45, 320, Config.FOVRadius, function(value)
        Config.FOVRadius = value
    end, " px")

    CreateSlider(AimVisualsPage, "FOV Opacity", 5, 95, Config.FOVOpacity, function(value)
        Config.FOVOpacity = value
    end, "%")

    CreateSlider(AimVisualsPage, "FOV Thickness", 1, 5, Config.FOVThickness, function(value)
        Config.FOVThickness = value
    end)

    CreateToggle(AimVisualsPage, "Target Highlight", "Highlight the current aim target.", Config.AimHighlight, function(state)
        Config.AimHighlight = state
        if not state then
            RemoveAimHighlight()
        elseif CurrentAimTarget then
            local target = CurrentAimTarget
            CurrentAimTarget = nil
            SetAimTarget(target)
        end
    end)

    AimTouchButton.MouseButton1Click:Connect(function()
        Config.Aim = not Config.Aim
        if AimController then
            AimController:Set(Config.Aim, false)
        end
        if not Config.Aim then
            SetAimTarget(nil)
        end
        RefreshAimStateUI()
    end)

    RefreshAimStateUI()
end)

--============================================================
-- PROFILE STATE + OPEN/CLOSE
--============================================================

local SavedUniversalState = {}

local function SaveUniversalState()
    SavedUniversalState = {
        ESP = Config.ESP,
        Fly = Config.Fly,
        Speed = Config.Speed,
        ImpactSpin = Config.ImpactSpin,
        AntiFling = Config.AntiFling,
    }
end

local function DisableUniversalModules()
    if ESPController then
        ESPController:Set(false, true)
    else
        Config.ESP = false
    end

    if FlyController then
        FlyController:Set(false, true)
    elseif SetFly then
        SetFly(false)
    else
        Config.Fly = false
    end

    if SpeedController then
        SpeedController:Set(false, true)
    elseif SetSpeed then
        SetSpeed(false)
    else
        Config.Speed = false
    end

    if ImpactController then
        ImpactController:Set(false, true)
    elseif SetImpactSpin then
        SetImpactSpin(false)
    else
        Config.ImpactSpin = false
    end

    if AntiFlingController then
        AntiFlingController:Set(false, true)
    elseif SetAntiFling then
        SetAntiFling(false)
    else
        Config.AntiFling = false
    end
end

local function RestoreUniversalState()
    if SavedUniversalState.ESP and ESPController then
        ESPController:Set(true, true)
    end
    if SavedUniversalState.Fly and FlyController then
        FlyController:Set(true, true)
    end
    if SavedUniversalState.Speed and SpeedController then
        SpeedController:Set(true, true)
    end
    if SavedUniversalState.ImpactSpin and ImpactController then
        ImpactController:Set(true, true)
    end
    if SavedUniversalState.AntiFling and AntiFlingController then
        AntiFlingController:Set(true, true)
    end
end

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
    HeaderTitle.Position = UDim2.fromOffset(60, 7)
    HeaderSubtitle.Position = UDim2.fromOffset(60, 26)

    MM2Profile.Visible = false
    AimProfile.Visible = false

    if profileName == "MM2" then
        SetTheme(ProfileThemes.MM2)
        HeaderTitle.Text = "AntiFreak Hub · MM2"
        HeaderSubtitle.Text = "Murder Mystery 2 Profile"
        MM2Profile.Visible = true
        MM2Card.Position = UDim2.fromScale(0.5, 0.56)
    elseif profileName == "AIM" then
        SetTheme(ProfileThemes.AIM)
        HeaderTitle.Text = "AntiFreak Hub · AIM"
        HeaderSubtitle.Text = "Independent Aim Profile"
        AimProfile.Visible = true
        Config.Aim = false
        if AimController then
            AimController:Set(false, false)
        end
        RefreshAimStateUI()
        SwitchAimTab("Aim")
    end

    if Config.Animations then
        Tween(ProfileContainer, 0.65, {GroupTransparency = 0}, Enum.EasingStyle.Quint)
        if profileName == "MM2" then
            Tween(MM2Card, 0.82, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back)
        end
    else
        ProfileContainer.GroupTransparency = 0
        if profileName == "MM2" then
            MM2Card.Position = UDim2.fromScale(0.5, 0.5)
        end
    end
end

local function ExitProfile()
    if not Config.CurrentProfile then
        return
    end

    Config.Aim = false
    if AimController then
        AimController:Set(false, false)
    end
    SetAimTarget(nil)
    FOVRing.Visible = false
    AimTouchButton.Visible = false

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
    HeaderSubtitle.Text = "Stable Minimal Interface"

    SetTheme(DefaultTheme)
    RestoreUniversalState()
    SwitchTab("Hub")
end

BackButton.MouseButton1Click:Connect(ExitProfile)

CreateProfileCard(
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
    "Aim",
    "AIM PROFILE",
    "Open a separate aim interface with FOV and targeting controls.",
    "◎",
    2,
    function()
        OpenProfile("AIM")
    end
)

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

print("[AntiFreak Hub] Stable build finished loading")
