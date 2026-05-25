--[[
    ========================================================================
    DEGRAD - PREMIUM ROBLOX UI LIBRARY (BLACK, WHITE & GRAY MODERNIST STYLE)
    ========================================================================
    A modern, high-fidelity, high-performance UI library written in Luau.
    Color Palette: Deep Obsidian, Premium Charcoal, Architectural Grays, Pure White.
    Animations: Ultra-smooth, physical-feeling micro-interactions (TweenService).
    Design Aesthetics: Glassmorphism-border strokes, capsule tab sliders, fading
    transitions, neon status indicators, and clean typography.
    
    API compatible with Sirius Rayfield (Rebranded as Degrad).
    ========================================================================
]]
local Degrad = {
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(10, 10, 10),
        Sidebar = Color3.fromRGB(6, 6, 6),
        ElementBackground = Color3.fromRGB(18, 18, 18),
        ElementHover = Color3.fromRGB(26, 26, 26),
        Border = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(255, 255, 255),
        AccentMuted = Color3.fromRGB(150, 150, 150),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(140, 140, 140),
        IndicatorGreen = Color3.fromRGB(255, 255, 255), -- Monochrome style
        IndicatorRed = Color3.fromRGB(45, 45, 45),
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold
    },
    Open = true,
    SaveSettings = false,
    ConfigFolder = "DegradConfigs",
    ConfigFile = "config.json"
}
-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
-- Environment Compatibility
local LocalPlayer = Players.LocalPlayer
local PlayerGui = nil
do
    local success, err = pcall(function()
        PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    end)
    if not success or not PlayerGui then
        PlayerGui = CoreGui
    end
end
-- ScreenGui Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DegradUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
-- Dynamic Safe Environment Protection
local function SafeParent(gui)
    local success, err = pcall(function()
        gui.Parent = CoreGui
    end)
    if not success then
        gui.Parent = PlayerGui
    end
end
-- Standard Icons Mapping (Lucide Fallbacks / High Quality Assets)
local Icons = {
    home = "rbxassetid://10723424505",
    settings = "rbxassetid://10723346959",
    user = "rbxassetid://10723394665",
    play = "rbxassetid://10723374626",
    terminal = "rbxassetid://10723386000",
    info = "rbxassetid://10723348649",
    bell = "rbxassetid://10723347091",
    chevron_right = "rbxassetid://10723347805",
    lock = "rbxassetid://10723358356",
    eye = "rbxassetid://10723350250",
    plus = "rbxassetid://10723376137",
    minus = "rbxassetid://10723375806",
    search = "rbxassetid://10723378801",
    cross = "rbxassetid://10723348126",
    rewind = "rbxassetid://10723381677",
    check = "rbxassetid://10723347639"
}
local function GetIcon(iconInput)
    if type(iconInput) == "number" then
        return "rbxassetid://" .. tostring(iconInput)
    elseif type(iconInput) == "string" then
        local lower = iconInput:lower()
        if Icons[lower] then
            return Icons[lower]
        elseif iconInput:find("rbxassetid://") or iconInput:find("http") then
            return iconInput
        end
    end
    return Icons.settings -- Default fallback
end
-- Tween Helper
local function QuickTween(instance, duration, properties, easingStyle, easingDir)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        easingStyle or Enum.EasingStyle.Quad,
        easingDir or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end
-- Smooth Drag Support
local function MakeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local targetPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            -- Smooth physical drag lerp
            QuickTween(targetFrame, 0.15, {Position = targetPos}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    end)
end
-- Configuration Save/Load Logic
local function SaveConfig()
    if not Degrad.SaveSettings then return end
    local configData = {}
    for flag, value in pairs(Degrad.Flags) do
        -- Convert Color3 to tables for JSON serialization
        if type(value) == "userdata" and value.ClassName == "Color3" then
            configData[flag] = {r = value.R, g = value.G, b = value.B, isColor = true}
        else
            configData[flag] = value
        end
    end
    
    pcall(function()
        if writefile then
            if not isfolder(Degrad.ConfigFolder) then
                makefolder(Degrad.ConfigFolder)
            end
            local path = Degrad.ConfigFolder .. "/" .. Degrad.ConfigFile
            writefile(path, HttpService:JSONEncode(configData))
        end
    end)
end
local function LoadConfig(elementsMap)
    if not Degrad.SaveSettings then return end
    local path = Degrad.ConfigFolder .. "/" .. Degrad.ConfigFile
    local success, content = pcall(function()
        if readfile and isfile(path) then
            return readfile(path)
        end
    end)
    
    if success and content then
        local successDec, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if successDec and type(data) == "table" then
            for flag, savedValue in pairs(data) do
                -- Unpack colors if needed
                if type(savedValue) == "table" and savedValue.isColor then
                    savedValue = Color3.new(savedValue.r, savedValue.g, savedValue.b)
                end
                
                Degrad.Flags[flag] = savedValue
                
                -- Proactively update element visuals if element exists
                local element = elementsMap[flag]
                if element and element.Set then
                    pcall(function()
                        element:Set(savedValue, true) -- true to skip double callback recursion
                    end)
                end
            end
        end
    end
end
-- ========================================================================
-- MODERNIZED NOTIFICATIONS SYSTEM
-- ========================================================================
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "Notifications"
NotificationContainer.Size = UDim2.new(0, 300, 1, -40)
NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.BorderSizePixel = 0
NotificationContainer.ClipsDescendants = false
SafeParent(NotificationContainer)
local UIListLayout_Notify = Instance.new("UIListLayout")
UIListLayout_Notify.Parent = NotificationContainer
UIListLayout_Notify.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Notify.Padding = UDim.new(0, 12)
UIListLayout_Notify.VerticalAlignment = Enum.VerticalAlignment.Bottom
function Degrad:Notify(options)
    local titleText = options.Title or "Notification"
    local contentText = options.Content or "Content here"
    local duration = options.Duration or 5
    local iconAsset = options.Image
    
    local Card = Instance.new("Frame")
    Card.Name = "NotificationCard"
    Card.Size = UDim2.new(1, 0, 0, 0) -- Starts at 0 height, tweens open
    Card.BackgroundColor3 = Degrad.Theme.Background
    Card.BackgroundTransparency = 0.05
    Card.BorderSizePixel = 0
    Card.ClipsDescendants = true
    Card.LayoutOrder = -os.time()
    Card.Parent = NotificationContainer
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Card
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Degrad.Theme.Border
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.Parent = Card
    
    -- Content Packing Container
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Size = UDim2.new(1, -20, 1, -20)
    ContentHolder.Position = UDim2.new(0, 10, 0, 10)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = Card
    
    local HasIcon = (iconAsset ~= nil)
    
    local Icon = Instance.new("ImageLabel")
    if HasIcon then
        Icon.Size = UDim2.new(0, 24, 0, 24)
        Icon.Position = UDim2.new(0, 0, 0, 2)
        Icon.Image = GetIcon(iconAsset)
        Icon.ImageColor3 = Degrad.Theme.Accent
        Icon.BackgroundTransparency = 1
        Icon.Parent = ContentHolder
    end
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, HasIcon and -34 or 0, 0, 16)
    Title.Position = UDim2.new(0, HasIcon and 30 or 0, 0, 0)
    Title.Text = titleText
    Title.TextColor3 = Degrad.Theme.Text
    Title.TextSize = 13
    Title.Font = Degrad.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = ContentHolder
    
    local CloseBtn = Instance.new("ImageButton")
    CloseBtn.Size = UDim2.new(0, 12, 0, 12)
    CloseBtn.Position = UDim2.new(1, -12, 0, 2)
    CloseBtn.Image = Icons.cross
    CloseBtn.ImageColor3 = Degrad.Theme.TextMuted
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = ContentHolder
    
    local Body = Instance.new("TextLabel")
    Body.Size = UDim2.new(1, 0, 0, 0) -- Auto adjusts
    Body.Position = UDim2.new(0, 0, 0, 22)
    Body.Text = contentText
    Body.TextColor3 = Degrad.Theme.TextMuted
    Body.TextSize = 12
    Body.Font = Degrad.Theme.Font
    Body.TextWrapped = true
    Body.TextXAlignment = Enum.TextXAlignment.Left
    Body.TextYAlignment = Enum.TextYAlignment.Top
    Body.BackgroundTransparency = 1
    Body.Parent = ContentHolder
    
    -- Calculate height
    local estimatedHeight = 55 + math.max(16, Body.TextBounds.Y)
    Card.Size = UDim2.new(1, 0, 0, 0)
    
    -- Progress Line at Bottom
    local ProgressLine = Instance.new("Frame")
    ProgressLine.Size = UDim2.new(1, 20, 0, 2)
    ProgressLine.Position = UDim2.new(0, -10, 1, -2)
    ProgressLine.BackgroundColor3 = Degrad.Theme.Accent
    ProgressLine.BorderSizePixel = 0
    ProgressLine.Parent = ContentHolder
    
    -- Auto layout sizing
    Body.Size = UDim2.new(1, 0, 0, estimatedHeight - 50)
    
    -- Slide In & Open Height Tweens
    Card.Position = UDim2.new(1, 100, 0, 0)
    QuickTween(Card, 0.4, {Size = UDim2.new(1, 0, 0, estimatedHeight)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    task.wait(0.1)
    QuickTween(Card, 0.35, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Progress Line shrink
    QuickTween(ProgressLine, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)
    
    local function Dismiss()
        QuickTween(Card, 0.3, {Position = UDim2.new(1, 150, 0, 0), BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
        task.wait(0.2)
        local contract = QuickTween(Card, 0.3, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quad)
        contract.Completed:Connect(function()
            Card:Destroy()
        end)
    end
    
    CloseBtn.MouseButton1Click:Connect(Dismiss)
    CloseBtn.MouseEnter:Connect(function()
        QuickTween(CloseBtn, 0.2, {ImageColor3 = Degrad.Theme.Accent})
    end)
    CloseBtn.MouseLeave:Connect(function()
        QuickTween(CloseBtn, 0.2, {ImageColor3 = Degrad.Theme.TextMuted})
    end)
    
    task.delay(duration, function()
        if Card and Card.Parent then
            Dismiss()
        end
    end)
end
-- ========================================================================
-- MAIN WINDOW SYSTEM
-- ========================================================================
function Degrad:CreateWindow(options)
    local windowName = options.Name or "Degrad"
    local showText = options.ShowText or "Open Degrad"
    local loadingTitle = options.LoadingTitle or "Degrad Suite"
    local loadingSubtitle = options.LoadingSubtitle or "Modernist Architecture"
    local keybind = options.ToggleUIKeybind or "K"
    
    -- Config setting details
    if options.ConfigurationSaving then
        Degrad.SaveSettings = options.ConfigurationSaving.Enabled or false
        if options.ConfigurationSaving.FolderName then
            Degrad.ConfigFolder = options.ConfigurationSaving.FolderName
        end
        if options.ConfigurationSaving.FileName then
            Degrad.ConfigFile = options.ConfigurationSaving.FileName .. ".json"
        end
    end
    
    local ElementsRegistry = {} -- Flat registry to bind flag -> element update mechanisms
    
    -- Setup Core GUI Screen
    ScreenGui.Parent = PlayerGui
    SafeParent(ScreenGui)
    
    -- Mobile Toggle button
    local MobileBtn = Instance.new("TextButton")
    MobileBtn.Name = "MobileToggle"
    MobileBtn.Size = UDim2.new(0, 110, 0, 30)
    MobileBtn.Position = UDim2.new(0.05, 0, 0.05, 0)
    MobileBtn.BackgroundColor3 = Degrad.Theme.Background
    MobileBtn.BorderSizePixel = 0
    MobileBtn.Text = showText
    MobileBtn.TextColor3 = Degrad.Theme.Text
    MobileBtn.Font = Degrad.Theme.FontBold
    MobileBtn.TextSize = 12
    MobileBtn.ZIndex = 5
    MobileBtn.Visible = false
    MobileBtn.Parent = ScreenGui
    
    local MobileBtnCorner = Instance.new("UICorner")
    MobileBtnCorner.CornerRadius = UDim.new(0, 6)
    MobileBtnCorner.Parent = MobileBtn
    
    local MobileBtnStroke = Instance.new("UIStroke")
    MobileBtnStroke.Thickness = 1
    MobileBtnStroke.Color = Degrad.Theme.Border
    MobileBtnStroke.Parent = MobileBtn
    
    -- Check if touch device for mobile button visibility
    if UserInputService.TouchEnabled then
        MobileBtn.Visible = true
    end
    
    -- Main Window Shell
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 560, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
    MainFrame.BackgroundColor3 = Degrad.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1
    MainStroke.Color = Degrad.Theme.Border
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame
    
    -- Header bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = windowName
    Title.TextColor3 = Degrad.Theme.Text
    Title.TextSize = 14
    Title.Font = Degrad.Theme.FontBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = Header
    
    -- Window Actions
    local Actions = Instance.new("Frame")
    Actions.Name = "Actions"
    Actions.Size = UDim2.new(0, 60, 1, 0)
    Actions.Position = UDim2.new(1, -70, 0, 0)
    Actions.BackgroundTransparency = 1
    Actions.Parent = Header
    
    local Minimize = Instance.new("ImageButton")
    Minimize.Size = UDim2.new(0, 16, 0, 16)
    Minimize.Position = UDim2.new(0, 10, 0.5, -8)
    Minimize.Image = Icons.minus
    Minimize.ImageColor3 = Degrad.Theme.TextMuted
    Minimize.BackgroundTransparency = 1
    Minimize.Parent = Actions
    
    local Close = Instance.new("ImageButton")
    Close.Size = UDim2.new(0, 16, 0, 16)
    Close.Position = UDim2.new(0, 36, 0.5, -8)
    Close.Image = Icons.cross
    Close.ImageColor3 = Degrad.Theme.TextMuted
    Close.BackgroundTransparency = 1
    Close.Parent = Actions
    
    local HeaderDivider = Instance.new("Frame")
    HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
    HeaderDivider.Position = UDim2.new(0, 0, 1, -1)
    HeaderDivider.BackgroundColor3 = Degrad.Theme.Border
    HeaderDivider.BorderSizePixel = 0
    HeaderDivider.Parent = Header
    
    MakeDraggable(Header, MainFrame)
    
    -- Body Split Panel (Sidebar Left / Contents Right)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = Degrad.Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar
    
    -- Visual patch to cover the right side of sidebar corner
    local SidebarPatch = Instance.new("Frame")
    SidebarPatch.Size = UDim2.new(0, 10, 1, 0)
    SidebarPatch.Position = UDim2.new(1, -10, 0, 0)
    SidebarPatch.BackgroundColor3 = Degrad.Theme.Sidebar
    SidebarPatch.BorderSizePixel = 0
    SidebarPatch.Parent = Sidebar
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Degrad.Theme.Border
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar
    
    -- Sidebar Scrolling list
    local TabScroll = Instance.new("ScrollingFrame")
    TabScroll.Size = UDim2.new(1, -10, 1, -20)
    TabScroll.Position = UDim2.new(0, 5, 0, 10)
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.ScrollBarThickness = 0
    TabScroll.Parent = Sidebar
    
    local TabScrollList = Instance.new("UIListLayout")
    TabScrollList.Padding = UDim.new(0, 4)
    TabScrollList.Parent = TabScroll
    
    -- Sidebar Active Indicator pill (Sliding Capsule)
    local SidebarIndicator = Instance.new("Frame")
    SidebarIndicator.Name = "ActivePill"
    SidebarIndicator.Size = UDim2.new(1, 0, 0, 30)
    SidebarIndicator.Position = UDim2.new(0, 0, 0, 0)
    SidebarIndicator.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SidebarIndicator.BorderSizePixel = 0
    SidebarIndicator.Visible = false
    SidebarIndicator.Parent = TabScroll
    
    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 6)
    PillCorner.Parent = SidebarIndicator
    
    local PillBorder = Instance.new("UIStroke")
    PillBorder.Thickness = 1
    PillBorder.Color = Color3.fromRGB(45, 45, 45)
    PillBorder.Parent = SidebarIndicator
    
    -- Content container
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentContainer"
    ContentHolder.Size = UDim2.new(1, -161, 1, -42)
    ContentHolder.Position = UDim2.new(0, 161, 0, 42)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.BorderSizePixel = 0
    ContentHolder.ClipsDescendants = true
    ContentHolder.Parent = MainFrame
    
    -- Standard Loading Screen
    local LoadingFrame = Instance.new("Frame")
    LoadingFrame.Name = "LoadingScreen"
    LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
    LoadingFrame.Position = UDim2.new(0, 0, 0, 0)
    LoadingFrame.BackgroundColor3 = Degrad.Theme.Background
    LoadingFrame.BorderSizePixel = 0
    LoadingFrame.ZIndex = 10
    LoadingFrame.Parent = MainFrame
    
    local LoadingCorner = Instance.new("UICorner")
    LoadingCorner.CornerRadius = UDim.new(0, 8)
    LoadingCorner.Parent = LoadingFrame
    
    local LoadingCenter = Instance.new("Frame")
    LoadingCenter.Size = UDim2.new(0, 300, 0, 100)
    LoadingCenter.Position = UDim2.new(0.5, -150, 0.5, -50)
    LoadingCenter.BackgroundTransparency = 1
    LoadingCenter.Parent = LoadingFrame
    
    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Size = UDim2.new(1, 0, 0, 24)
    LoadTitle.Text = loadingTitle
    LoadTitle.TextColor3 = Degrad.Theme.Text
    LoadTitle.TextSize = 18
    LoadTitle.Font = Degrad.Theme.FontBold
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.Parent = LoadingCenter
    
    local LoadSub = Instance.new("TextLabel")
    LoadSub.Size = UDim2.new(1, 0, 0, 20)
    LoadSub.Position = UDim2.new(0, 0, 0, 26)
    LoadSub.Text = loadingSubtitle
    LoadSub.TextColor3 = Degrad.Theme.TextMuted
    LoadSub.TextSize = 12
    LoadSub.Font = Degrad.Theme.Font
    LoadSub.BackgroundTransparency = 1
    LoadSub.Parent = LoadingCenter
    
    -- Animated loading charging line
    local LoaderTrack = Instance.new("Frame")
    LoaderTrack.Size = UDim2.new(0.7, 0, 0, 2)
    LoaderTrack.Position = UDim2.new(0.15, 0, 0, 65)
    LoaderTrack.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    LoaderTrack.BorderSizePixel = 0
    LoaderTrack.Parent = LoadingCenter
    
    local LoaderBar = Instance.new("Frame")
    LoaderBar.Size = UDim2.new(0, 0, 1, 0)
    LoaderBar.BackgroundColor3 = Degrad.Theme.Accent
    LoaderBar.BorderSizePixel = 0
    LoaderBar.Parent = LoaderTrack
    
    -- Play Loading Animation
    task.spawn(function()
        task.wait(0.2)
        local loadingProgress = QuickTween(LoaderBar, 1.4, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quad)
        loadingProgress.Completed:Wait()
        task.wait(0.2)
        -- Fade Out Loading Screen
        local fadeOut = QuickTween(LoadingFrame, 0.4, {BackgroundTransparency = 1}, Enum.EasingStyle.Quad)
        QuickTween(LoadTitle, 0.35, {TextTransparency = 1})
        QuickTween(LoadSub, 0.35, {TextTransparency = 1})
        QuickTween(LoaderTrack, 0.35, {BackgroundTransparency = 1})
        QuickTween(LoaderBar, 0.35, {BackgroundTransparency = 1})
        
        fadeOut.Completed:Wait()
        LoadingFrame:Destroy()
    end)
    
    -- Toggle UI Visibility Mechanics
    local function ToggleUI()
        Degrad.Open = not Degrad.Open
        local targetScale = Degrad.Open and 1 or 0.85
        local targetTrans = Degrad.Open and 0 or 1
        
        MainFrame.Visible = true
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        -- Scaling Transition
        local sizeTween = TweenService:Create(MainFrame, tweenInfo, {
            Size = Degrad.Open and UDim2.new(0, 560, 0, 390) or UDim2.new(0, 480, 0, 330),
            Position = Degrad.Open and UDim2.new(0.5, -280, 0.5, -195) or UDim2.new(0.5, -240, 0.5, -165)
        })
        sizeTween:Play()
        
        -- Fade components recursively
        local function fadeAll(instance, trans)
            if instance:IsA("Frame") and instance ~= LoadingFrame then
                if instance.Name ~= "ActivePill" then
                    QuickTween(instance, 0.25, {BackgroundTransparency = trans})
                end
            elseif instance:IsA("TextLabel") or instance:IsA("TextBox") then
                QuickTween(instance, 0.25, {TextTransparency = trans})
            elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
                QuickTween(instance, 0.25, {ImageTransparency = trans})
            elseif instance:IsA("UIStroke") then
                QuickTween(instance, 0.25, {Transparency = trans})
            end
            for _, child in ipairs(instance:GetChildren()) do
                fadeAll(child, trans)
            end
        end
        
        fadeAll(MainFrame, targetTrans)
        
        sizeTween.Completed:Connect(function()
            if not Degrad.Open then
                MainFrame.Visible = false
            end
        end)
    end
    
    -- Binding Actions
    Minimize.MouseButton1Click:Connect(ToggleUI)
    Close.MouseButton1Click:Connect(function()
        Degrad:Destroy()
    end)
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    
    -- Keybind to toggle
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed then
            local matched = false
            if type(keybind) == "string" and input.KeyCode.Name == keybind then
                matched = true
            elseif typeof(keybind) == "EnumItem" and input.KeyCode == keybind then
                matched = true
            end
            if matched then
                ToggleUI()
            end
        end
    end)
    
    -- Elements mapping & tabs collection
    local Tabs = {}
    local FirstTab = nil
    
    local WindowAPI = {}
    
    -- ====================================================================
    -- TAB CLASS DEFINITION
    -- ====================================================================
    function WindowAPI:CreateTab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "TabBtn"
        TabBtn.Size = UDim2.new(1, 0, 0, 30)
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.Parent = TabScroll
        
        local TabBtnLabel = Instance.new("TextLabel")
        TabBtnLabel.Size = UDim2.new(1, -35, 1, 0)
        TabBtnLabel.Position = UDim2.new(0, 30, 0, 0)
        TabBtnLabel.Text = name
        TabBtnLabel.TextColor3 = Degrad.Theme.TextMuted
        TabBtnLabel.TextSize = 13
        TabBtnLabel.Font = Degrad.Theme.Font
        TabBtnLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabBtnLabel.BackgroundTransparency = 1
        TabBtnLabel.Parent = TabBtn
        
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Size = UDim2.new(0, 16, 0, 16)
        TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
        TabIcon.Image = GetIcon(icon)
        TabIcon.ImageColor3 = Degrad.Theme.TextMuted
        TabIcon.BackgroundTransparency = 1
        TabIcon.Parent = TabBtn
        
        -- The Element Page scrolling viewport
        local PageScroll = Instance.new("ScrollingFrame")
        PageScroll.Name = name .. "Page"
        PageScroll.Size = UDim2.new(1, -20, 1, -20)
        PageScroll.Position = UDim2.new(0, 10, 0, 10)
        PageScroll.BackgroundTransparency = 1
        PageScroll.BorderSizePixel = 0
        PageScroll.ScrollBarThickness = 2
        PageScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 45)
        PageScroll.Visible = false
        PageScroll.Parent = ContentHolder
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = PageScroll
        
        -- Automatically resize canvas size
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            PageScroll.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Selection System
        local TabAPI = {}
        
        local function Select()
            for _, t in ipairs(Tabs) do
                t.Page.Visible = false
                QuickTween(t.BtnLabel, 0.2, {TextColor3 = Degrad.Theme.TextMuted, Font = Degrad.Theme.Font})
                QuickTween(t.Icon, 0.2, {ImageColor3 = Degrad.Theme.TextMuted})
            end
            
            -- Setup Pill positioning
            if not SidebarIndicator.Visible then
                SidebarIndicator.Visible = true
            end
            
            -- Smooth transition of Sidebar capsule
            QuickTween(SidebarIndicator, 0.25, {
                Position = UDim2.new(0, 0, 0, TabBtn.AbsolutePosition.Y - TabScroll.AbsolutePosition.Y)
            }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            
            PageScroll.Visible = true
            QuickTween(TabBtnLabel, 0.2, {TextColor3 = Degrad.Theme.Text, Font = Degrad.Theme.FontBold})
            QuickTween(TabIcon, 0.2, {ImageColor3 = Degrad.Theme.Text})
            
            -- Cool Tab switching fade-in micro-animation
            PageScroll.CanvasPosition = Vector2.new(0, 0)
            local originalPos = UDim2.new(0, 10, 0, 10)
            PageScroll.Position = UDim2.new(0, 10, 0, 20)
            PageScroll.GroupColor3 = Color3.fromRGB(0, 0, 0) -- Fades through clipping
            
            QuickTween(PageScroll, 0.35, {Position = originalPos}, Enum.EasingStyle.Quad)
        end
        
        TabBtn.MouseButton1Click:Connect(Select)
        
        TabBtn.MouseEnter:Connect(function()
            if TabBtnLabel.TextColor3 ~= Degrad.Theme.Text then
                QuickTween(TabBtnLabel, 0.2, {TextColor3 = Color3.fromRGB(200, 200, 200)})
                QuickTween(TabIcon, 0.2, {ImageColor3 = Color3.fromRGB(200, 200, 200)})
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if TabBtnLabel.TextColor3 ~= Degrad.Theme.Text then
                QuickTween(TabBtnLabel, 0.2, {TextColor3 = Degrad.Theme.TextMuted})
                QuickTween(TabIcon, 0.2, {ImageColor3 = Degrad.Theme.TextMuted})
            end
        end)
        
        local tabItem = {Btn = TabBtn, BtnLabel = TabBtnLabel, Icon = TabIcon, Page = PageScroll, Select = Select}
        table.insert(Tabs, tabItem)
        
        if not FirstTab then
            FirstTab = tabItem
            -- Delayed execution to ensure UI initialization complete
            task.spawn(function()
                task.wait(0.1)
                Select()
            end)
        end
        
        -- Helper: Create Standard Shell for Elements
        local function ElementShell(elemName, parentFrame)
            local Elem = Instance.new("Frame")
            Elem.Name = elemName .. "Element"
            Elem.Size = UDim2.new(1, -10, 0, 38)
            Elem.BackgroundColor3 = Degrad.Theme.ElementBackground
            Elem.BorderSizePixel = 0
            Elem.Parent = parentFrame or PageScroll
            
            local ElemCorner = Instance.new("UICorner")
            ElemCorner.CornerRadius = UDim.new(0, 6)
            ElemCorner.Parent = Elem
            
            local ElemStroke = Instance.new("UIStroke")
            ElemStroke.Thickness = 1
            ElemStroke.Color = Degrad.Theme.Border
            ElemStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ElemStroke.Parent = Elem
            
            -- Standard title label
            local ElemLabel = Instance.new("TextLabel")
            ElemLabel.Size = UDim2.new(0.6, 0, 1, 0)
            ElemLabel.Position = UDim2.new(0, 12, 0, 0)
            ElemLabel.Text = elemName
            ElemLabel.TextColor3 = Degrad.Theme.Text
            ElemLabel.TextSize = 13
            ElemLabel.Font = Degrad.Theme.Font
            ElemLabel.TextXAlignment = Enum.TextXAlignment.Left
            ElemLabel.BackgroundTransparency = 1
            ElemLabel.Parent = Elem
            
            -- Responsive Hover animations
            Elem.MouseEnter:Connect(function()
                QuickTween(Elem, 0.2, {BackgroundColor3 = Degrad.Theme.ElementHover})
                QuickTween(ElemStroke, 0.2, {Color = Color3.fromRGB(60, 60, 60)})
            end)
            Elem.MouseLeave:Connect(function()
                QuickTween(Elem, 0.2, {BackgroundColor3 = Degrad.Theme.ElementBackground})
                QuickTween(ElemStroke, 0.2, {Color = Degrad.Theme.Border})
            end)
            
            return Elem, ElemLabel, ElemStroke
        end
        
        -- ====================================================================
        -- 1. SECTION
        -- ====================================================================
        function TabAPI:CreateSection(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = text .. "Section"
            SectionFrame.Size = UDim2.new(1, -10, 0, 24)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = PageScroll
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 1, 0)
            Label.Position = UDim2.new(0, 8, 0, 0)
            Label.Text = text:upper()
            Label.TextColor3 = Color3.fromRGB(130, 130, 130)
            Label.TextSize = 10
            Label.Font = Degrad.Theme.FontBold
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SectionFrame
            
            local SectionAPI = {}
            function SectionAPI:Set(newText)
                Label.Text = newText:upper()
            end
            return SectionAPI
        end
        
        -- ====================================================================
        -- 2. BUTTON
        -- ====================================================================
        function TabAPI:CreateButton(btnOptions)
            local name = btnOptions.Name or "Button"
            local callback = btnOptions.Callback or function() end
            
            local Elem, ElemLabel = ElementShell(name)
            
            -- Click trigger button cover
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Elem
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -26, 0.5, -8)
            Arrow.Image = Icons.chevron_right
            Arrow.ImageColor3 = Degrad.Theme.TextMuted
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = Elem
            
            local ButtonAPI = {}
            
            local function Trigger()
                -- Dynamic scale compression visual feedback
                QuickTween(Elem, 0.05, {Size = UDim2.new(1, -16, 0, 36)}, Enum.EasingStyle.Quad)
                task.wait(0.05)
                QuickTween(Elem, 0.15, {Size = UDim2.new(1, -10, 0, 38)}, Enum.EasingStyle.Back)
                
                task.spawn(function()
                    local success, err = pcall(callback)
                    if not success then warn("[Degrad Button Error]: " .. tostring(err)) end
                end)
            end
            
            ClickBtn.MouseButton1Click:Connect(Trigger)
            
            function ButtonAPI:Set(newTitle)
                ElemLabel.Text = newTitle
            end
            
            return ButtonAPI
        end
        
        -- ====================================================================
        -- 3. TOGGLE
        -- ====================================================================
        function TabAPI:CreateToggle(tglOptions)
            local name = tglOptions.Name or "Toggle"
            local currentVal = tglOptions.CurrentValue or false
            local flag = tglOptions.Flag
            local callback = tglOptions.Callback or function() end
            
            if flag then
                Degrad.Flags[flag] = currentVal
            end
            
            local Elem, ElemLabel = ElementShell(name)
            
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Elem
            
            -- Modern minimalist slider switch
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 32, 0, 18)
            Switch.Position = UDim2.new(1, -44, 0.5, -9)
            Switch.BackgroundColor3 = Degrad.Theme.Sidebar
            Switch.BorderSizePixel = 0
            Switch.Parent = Elem
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(0, 9)
            SwitchCorner.Parent = Switch
            
            local SwitchStroke = Instance.new("UIStroke")
            SwitchStroke.Thickness = 1
            SwitchStroke.Color = Color3.fromRGB(50, 50, 50)
            SwitchStroke.Parent = Switch
            
            -- Sliding circular node
            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 12, 0, 12)
            Dot.Position = UDim2.new(0, 3, 0.5, -6)
            Dot.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            Dot.BorderSizePixel = 0
            Dot.Parent = Switch
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot
            
            local ToggleAPI = {CurrentValue = currentVal}
            
            local function RenderState(state)
                local targetPos = state and UDim2.new(0, 17, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                local targetDotColor = state and Degrad.Theme.Accent or Color3.fromRGB(120, 120, 120)
                local targetSwitchBg = state and Color3.fromRGB(30, 30, 30) or Degrad.Theme.Sidebar
                
                QuickTween(Dot, 0.2, {Position = targetPos, BackgroundColor3 = targetDotColor})
                QuickTween(Switch, 0.2, {BackgroundColor3 = targetSwitchBg})
                QuickTween(SwitchStroke, 0.2, {Color = state and Degrad.Theme.Accent or Color3.fromRGB(50, 50, 50)})
            end
            
            local function Update(value, skipCallback)
                ToggleAPI.CurrentValue = value
                if flag then
                    Degrad.Flags[flag] = value
                    SaveConfig()
                end
                RenderState(value)
                if not skipCallback then
                    task.spawn(function()
                        local success, err = pcall(callback, value)
                        if not success then warn("[Degrad Toggle Error]: " .. tostring(err)) end
                    end)
                end
            end
            
            ClickBtn.MouseButton1Click:Connect(function()
                Update(not ToggleAPI.CurrentValue)
            end)
            
            function ToggleAPI:Set(newValue, skipCallback)
                Update(newValue, skipCallback)
            end
            
            -- Init visual state
            RenderState(currentVal)
            
            if flag then
                ElementsRegistry[flag] = ToggleAPI
            end
            
            return ToggleAPI
        end
        
        -- ====================================================================
        -- 4. SLIDER
        -- ====================================================================
        function TabAPI:CreateSlider(sldOptions)
            local name = sldOptions.Name or "Slider"
            local min = sldOptions.Range[1] or 0
            local max = sldOptions.Range[2] or 100
            local increment = sldOptions.Increment or 1
            local suffix = sldOptions.Suffix or ""
            local currentVal = sldOptions.CurrentValue or min
            local flag = sldOptions.Flag
            local callback = sldOptions.Callback or function() end
            
            if flag then
                Degrad.Flags[flag] = currentVal
            end
            
            local Elem, ElemLabel = ElementShell(name)
            Elem.Size = UDim2.new(1, -10, 0, 48) -- Taller to fit track
            
            -- Center align elements
            ElemLabel.Size = UDim2.new(0.6, 0, 0, 24)
            
            -- Value indicator label
            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.35, 0, 0, 24)
            ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
            ValLabel.Text = tostring(currentVal) .. " " .. suffix
            ValLabel.TextColor3 = Degrad.Theme.TextMuted
            ValLabel.TextSize = 12
            ValLabel.Font = Degrad.Theme.Font
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.BackgroundTransparency = 1
            ValLabel.Parent = Elem
            
            -- Slider track
            local Track = Instance.new("TextButton")
            Track.Name = "Track"
            Track.Size = UDim2.new(1, -24, 0, 4)
            Track.Position = UDim2.new(0, 12, 0, 32)
            Track.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Track.BorderSizePixel = 0
            Track.Text = ""
            Track.Parent = Elem
            
            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(0, 2)
            TrackCorner.Parent = Track
            
            -- Slider Fill
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Degrad.Theme.Accent
            Fill.BorderSizePixel = 0
            Fill.Parent = Track
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 2)
            FillCorner.Parent = Fill
            
            -- Dynamic dragging logic
            local SliderAPI = {CurrentValue = currentVal}
            
            local dragging = false
            
            local function UpdateVisuals(value)
                local percentage = math.clamp((value - min) / (max - min), 0, 1)
                QuickTween(Fill, 0.1, {Size = UDim2.new(percentage, 0, 1, 0)})
                ValLabel.Text = tostring(value) .. " " .. suffix
            end
            
            local function CalculateValue(inputPosition)
                local relativeX = inputPosition.X - Track.AbsolutePosition.X
                local relativeY = inputPosition.Y - Track.AbsolutePosition.Y
                
                local percentage = math.clamp(relativeX / Track.AbsoluteWidth, 0, 1)
                local rawValue = min + (max - min) * percentage
                local rounded = math.round(rawValue / increment) * increment
                return math.clamp(rounded, min, max)
            end
            
            local function SetValue(value, skipCallback)
                SliderAPI.CurrentValue = value
                if flag then
                    Degrad.Flags[flag] = value
                    SaveConfig()
                end
                UpdateVisuals(value)
                if not skipCallback then
                    task.spawn(function()
                        local success, err = pcall(callback, value)
                        if not success then warn("[Degrad Slider Error]: " .. tostring(err)) end
                    end)
                end
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    SetValue(CalculateValue(input.Position))
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    SetValue(CalculateValue(input.Position))
                end
            end)
            
            function SliderAPI:Set(newValue, skipCallback)
                SetValue(newValue, skipCallback)
            end
            
            -- Init
            UpdateVisuals(currentVal)
            
            if flag then
                ElementsRegistry[flag] = SliderAPI
            end
            
            return SliderAPI
        end
        
        -- ====================================================================
        -- 5. INPUT
        -- ====================================================================
        function TabAPI:CreateInput(inpOptions)
            local name = inpOptions.Name or "Input"
            local placeholder = inpOptions.PlaceholderText or "Enter text..."
            local clearFocus = inpOptions.RemoveTextAfterFocusLost or false
            local defaultVal = inpOptions.CurrentValue or ""
            local flag = inpOptions.Flag
            local callback = inpOptions.Callback or function() end
            
            if flag then
                Degrad.Flags[flag] = defaultVal
            end
            
            local Elem, ElemLabel = ElementShell(name)
            
            -- Premium TextBox outline container
            local BoxContainer = Instance.new("Frame")
            BoxContainer.Size = UDim2.new(0, 140, 0, 24)
            BoxContainer.Position = UDim2.new(1, -152, 0.5, -12)
            BoxContainer.BackgroundColor3 = Degrad.Theme.Sidebar
            BoxContainer.BorderSizePixel = 0
            BoxContainer.Parent = Elem
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 5)
            BoxCorner.Parent = BoxContainer
            
            local BoxStroke = Instance.new("UIStroke")
            BoxStroke.Thickness = 1
            BoxStroke.Color = Color3.fromRGB(50, 50, 50)
            BoxStroke.Parent = BoxContainer
            
            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, -10, 1, 0)
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.BackgroundTransparency = 1
            Box.Text = defaultVal
            Box.PlaceholderText = placeholder
            Box.TextColor3 = Degrad.Theme.Text
            Box.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
            Box.TextSize = 12
            Box.Font = Degrad.Theme.Font
            Box.ClipsDescendants = true
            Box.ClearTextOnFocus = false
            Box.Parent = BoxContainer
            
            local InputAPI = {CurrentValue = defaultVal}
            
            local function Update(value, skipCallback)
                InputAPI.CurrentValue = value
                Box.Text = value
                if flag then
                    Degrad.Flags[flag] = value
                    SaveConfig()
                end
                if not skipCallback then
                    task.spawn(function()
                        local success, err = pcall(callback, value)
                        if not success then warn("[Degrad Input Error]: " .. tostring(err)) end
                    end)
                end
            end
            
            Box.FocusLost:Connect(function(enterPressed)
                local txt = Box.Text
                Update(txt)
                if clearFocus then
                    Box.Text = ""
                end
                QuickTween(BoxStroke, 0.2, {Color = Color3.fromRGB(50, 50, 50)})
            end)
            
            Box.Focused:Connect(function()
                QuickTween(BoxStroke, 0.2, {Color = Degrad.Theme.Accent})
            end)
            
            function InputAPI:Set(newValue, skipCallback)
                Update(newValue, skipCallback)
            end
            
            if flag then
                ElementsRegistry[flag] = InputAPI
            end
            
            return InputAPI
        end
        
        -- ====================================================================
        -- 6. DROPDOWN
        -- ====================================================================
        function TabAPI:CreateDropdown(drpOptions)
            local name = drpOptions.Name or "Dropdown"
            local optionsList = drpOptions.Options or {}
            local currentOpt = drpOptions.CurrentOption or {}
            local multiSelect = drpOptions.MultipleOptions or false
            local flag = drpOptions.Flag
            local callback = drpOptions.Callback or function() end
            
            -- Normalization of current option to table
            if type(currentOpt) == "string" then
                currentOpt = {currentOpt}
            end
            
            if flag then
                Degrad.Flags[flag] = currentOpt
            end
            
            local Elem, ElemLabel = ElementShell(name)
            Elem.ClipsDescendants = true
            
            -- Selection preview text label
            local SelectedText = Instance.new("TextLabel")
            SelectedText.Size = UDim2.new(0.35, 0, 0, 24)
            SelectedText.Position = UDim2.new(0.6, -34, 0.5, -12)
            SelectedText.Text = table.concat(currentOpt, ", ")
            SelectedText.TextColor3 = Degrad.Theme.TextMuted
            SelectedText.TextSize = 12
            SelectedText.Font = Degrad.Theme.Font
            SelectedText.TextXAlignment = Enum.TextXAlignment.Right
            SelectedText.BackgroundTransparency = 1
            SelectedText.Parent = Elem
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -26, 0, 11)
            Arrow.Image = "rbxassetid://10723347519" -- Arrow down
            Arrow.ImageColor3 = Degrad.Theme.TextMuted
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = Elem
            
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Size = UDim2.new(1, 0, 0, 38)
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Text = ""
            ClickBtn.Parent = Elem
            
            -- Dropdown Container for items
            local ItemsHolder = Instance.new("Frame")
            ItemsHolder.Size = UDim2.new(1, -20, 0, 0)
            ItemsHolder.Position = UDim2.new(0, 10, 0, 42)
            ItemsHolder.BackgroundTransparency = 1
            ItemsHolder.BorderSizePixel = 0
            ItemsHolder.ClipsDescendants = true
            ItemsHolder.Parent = Elem
            
            local ItemsList = Instance.new("UIListLayout")
            ItemsList.Padding = UDim.new(0, 4)
            ItemsList.Parent = ItemsHolder
            
            local open = false
            local DropdownAPI = {CurrentOption = currentOpt, Options = optionsList}
            
            local function RenderOptions()
                -- Clear previous elements safely
                for _, child in ipairs(ItemsHolder:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                for _, option in ipairs(DropdownAPI.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 26)
                    OptBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    OptBtn.BorderSizePixel = 0
                    OptBtn.Text = ""
                    OptBtn.Parent = ItemsHolder
                    
                    local OptCorner = Instance.new("UICorner")
                    OptCorner.CornerRadius = UDim.new(0, 4)
                    OptCorner.Parent = OptBtn
                    
                    local OptStroke = Instance.new("UIStroke")
                    OptStroke.Thickness = 1
                    OptStroke.Color = Color3.fromRGB(30, 30, 30)
                    OptStroke.Parent = OptBtn
                    
                    local OptLabel = Instance.new("TextLabel")
                    OptLabel.Size = UDim2.new(1, -20, 1, 0)
                    OptLabel.Position = UDim2.new(0, 10, 0, 0)
                    OptLabel.Text = option
                    OptLabel.TextColor3 = Degrad.Theme.TextMuted
                    OptLabel.TextSize = 12
                    OptLabel.Font = Degrad.Theme.Font
                    OptLabel.TextXAlignment = Enum.TextXAlignment.Left
                    OptLabel.BackgroundTransparency = 1
                    OptLabel.Parent = OptBtn
                    
                    -- Micro check icon
                    local Check = Instance.new("ImageLabel")
                    Check.Size = UDim2.new(0, 12, 0, 12)
                    Check.Position = UDim2.new(1, -22, 0.5, -6)
                    Check.Image = Icons.check
                    Check.ImageColor3 = Degrad.Theme.Accent
                    Check.BackgroundTransparency = 1
                    Check.Visible = false
                    Check.Parent = OptBtn
                    
                    -- Active selection visuals
                    if table.find(DropdownAPI.CurrentOption, option) then
                        OptLabel.TextColor3 = Degrad.Theme.Text
                        OptLabel.Font = Degrad.Theme.FontBold
                        Check.Visible = true
                        OptBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                        OptStroke.Color = Color3.fromRGB(60, 60, 60)
                    end
                    
                    OptBtn.MouseEnter:Connect(function()
                        QuickTween(OptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)})
                    end)
                    OptBtn.MouseLeave:Connect(function()
                        if not table.find(DropdownAPI.CurrentOption, option) then
                            QuickTween(OptBtn, 0.2, {BackgroundColor3 = Color3.fromRGB(14, 14, 14)})
                        end
                    end)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if multiSelect then
                            local index = table.find(DropdownAPI.CurrentOption, option)
                            if index then
                                table.remove(DropdownAPI.CurrentOption, index)
                            else
                                table.insert(DropdownAPI.CurrentOption, option)
                            end
                        else
                            DropdownAPI.CurrentOption = {option}
                            -- Close accordion on single select
                            ClickBtn:Click()
                        end
                        
                        SelectedText.Text = table.concat(DropdownAPI.CurrentOption, ", ")
                        RenderOptions()
                        
                        if flag then
                            Degrad.Flags[flag] = DropdownAPI.CurrentOption
                            SaveConfig()
                        end
                        
                        task.spawn(function()
                            local success, err = pcall(callback, DropdownAPI.CurrentOption)
                            if not success then warn("[Degrad Dropdown Error]: " .. tostring(err)) end
                        end)
                    end)
                end
            end
            
            local function ToggleDropdown()
                open = not open
                
                local targetArrowRotation = open and 180 or 0
                local contentHeight = ItemsList.AbsoluteContentSize.Y + 12
                local targetHeight = open and (46 + contentHeight) or 38
                
                QuickTween(Arrow, 0.25, {Rotation = targetArrowRotation})
                QuickTween(Elem, 0.25, {Size = UDim2.new(1, -10, 0, targetHeight)}, Enum.EasingStyle.Quad)
                
                if open then
                    ItemsHolder.Size = UDim2.new(1, -20, 0, contentHeight)
                else
                    ItemsHolder.Size = UDim2.new(1, -20, 0, 0)
                end
            end
            
            ClickBtn.MouseButton1Click:Connect(ToggleDropdown)
            ClickBtn.Click = ToggleDropdown -- bind reference
            
            function DropdownAPI:Set(newSelection, skipCallback)
                if type(newSelection) == "string" then
                    newSelection = {newSelection}
                end
                DropdownAPI.CurrentOption = newSelection
                SelectedText.Text = table.concat(newSelection, ", ")
                RenderOptions()
                
                if flag then
                    Degrad.Flags[flag] = newSelection
                    SaveConfig()
                end
                
                if not skipCallback then
                    task.spawn(function()
                        local success, err = pcall(callback, newSelection)
                        if not success then warn("[Degrad Dropdown Set Error]: " .. tostring(err)) end
                    end)
                end
            end
            
            function DropdownAPI:Refresh(newOptionsList)
                DropdownAPI.Options = newOptionsList
                DropdownAPI.CurrentOption = {}
                SelectedText.Text = ""
                RenderOptions()
                
                if open then
                    -- Re-adjust open height dynamically
                    local contentHeight = ItemsList.AbsoluteContentSize.Y + 12
                    Elem.Size = UDim2.new(1, -10, 0, 46 + contentHeight)
                    ItemsHolder.Size = UDim2.new(1, -20, 0, contentHeight)
                end
            end
            
            RenderOptions()
            
            if flag then
                ElementsRegistry[flag] = DropdownAPI
            end
            
            return DropdownAPI
        end
        
        -- ====================================================================
        -- 7. KEYBIND
        -- ====================================================================
        function TabAPI:CreateKeybind(kbOptions)
            local name = kbOptions.Name or "Keybind"
            local currentBind = kbOptions.CurrentKeybind or "None"
            local holdToInteract = kbOptions.HoldToInteract or false
            local flag = kbOptions.Flag
            local callback = kbOptions.Callback or function() end
            
            if flag then
                Degrad.Flags[flag] = currentBind
            end
            
            local Elem, ElemLabel = ElementShell(name)
            
            -- Styled key label box
            local KeyBox = Instance.new("TextButton")
            KeyBox.Size = UDim2.new(0, 75, 0, 22)
            KeyBox.Position = UDim2.new(1, -87, 0.5, -11)
            KeyBox.BackgroundColor3 = Degrad.Theme.Sidebar
            KeyBox.BorderSizePixel = 0
            KeyBox.Text = currentBind
            KeyBox.TextColor3 = Degrad.Theme.TextMuted
            KeyBox.TextSize = 11
            KeyBox.Font = Degrad.Theme.FontBold
            KeyBox.Parent = Elem
            
            local KeyBoxCorner = Instance.new("UICorner")
            KeyBoxCorner.CornerRadius = UDim.new(0, 4)
            KeyBoxCorner.Parent = KeyBox
            
            local KeyBoxStroke = Instance.new("UIStroke")
            KeyBoxStroke.Thickness = 1
            KeyBoxStroke.Color = Color3.fromRGB(50, 50, 50)
            KeyBoxStroke.Parent = KeyBox
            
            local KeybindAPI = {CurrentKeybind = currentBind}
            local recording = false
            
            local function UpdateKey(newKey)
                recording = false
                KeybindAPI.CurrentKeybind = newKey
                KeyBox.Text = newKey
                QuickTween(KeyBoxStroke, 0.2, {Color = Color3.fromRGB(50, 50, 50)})
                KeyBox.TextColor3 = Degrad.Theme.TextMuted
                
                if flag then
                    Degrad.Flags[flag] = newKey
                    SaveConfig()
                end
            end
            
            KeyBox.MouseButton1Click:Connect(function()
                recording = true
                KeyBox.Text = "..."
                QuickTween(KeyBoxStroke, 0.2, {Color = Degrad.Theme.Accent})
                KeyBox.TextColor3 = Degrad.Theme.Text
            end)
            
            -- Capture raw input
            UserInputService.InputBegan:Connect(function(input, processed)
                if recording and not processed then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        UpdateKey(input.KeyCode.Name)
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        UpdateKey("LClick")
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        UpdateKey("RClick")
                    end
                elseif not recording and not processed then
                    local matched = (input.KeyCode.Name == KeybindAPI.CurrentKeybind)
                    if matched then
                        task.spawn(function()
                            local success, err = pcall(callback, true)
                            if not success then warn("[Degrad Keybind Callback Error]: " .. tostring(err)) end
                        end)
                    end
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input, processed)
                if not recording and not processed and holdToInteract then
                    local matched = (input.KeyCode.Name == KeybindAPI.CurrentKeybind)
                    if matched then
                        task.spawn(function()
                            local success, err = pcall(callback, false)
                            if not success then warn("[Degrad Keybind Callback End Error]: " .. tostring(err)) end
                        end)
                    end
                end
            end)
            
            function KeybindAPI:Set(newKey)
                UpdateKey(newKey)
            end
            
            if flag then
                ElementsRegistry[flag] = KeybindAPI
            end
            
            return KeybindAPI
        end
        
        -- ====================================================================
        -- 8. COLOR PICKER
        -- ====================================================================
        function TabAPI:CreateColorPicker(cpOptions)
            local name = cpOptions.Name or "Color Picker"
            local defaultColor = cpOptions.Color or Color3.fromRGB(255, 255, 255)
            local flag = cpOptions.Flag
            local callback = cpOptions.Callback or function() end
            
            if flag then
                Degrad.Flags[flag] = defaultColor
            end
            
            local Elem, ElemLabel = ElementShell(name)
            Elem.ClipsDescendants = true
            
            -- Static Preview indicator
            local ColorIndicator = Instance.new("TextButton")
            ColorIndicator.Size = UDim2.new(0, 36, 0, 18)
            ColorIndicator.Position = UDim2.new(1, -48, 0, 10)
            ColorIndicator.BackgroundColor3 = defaultColor
            ColorIndicator.BorderSizePixel = 0
            ColorIndicator.Text = ""
            ColorIndicator.Parent = Elem
            
            local IndicatorCorner = Instance.new("UICorner")
            IndicatorCorner.CornerRadius = UDim.new(0, 4)
            IndicatorCorner.Parent = ColorIndicator
            
            local IndicatorStroke = Instance.new("UIStroke")
            IndicatorStroke.Thickness = 1
            IndicatorStroke.Color = Color3.fromRGB(50, 50, 50)
            IndicatorStroke.Parent = ColorIndicator
            
            -- Color Selection panel accordion
            local Panel = Instance.new("Frame")
            Panel.Size = UDim2.new(1, -24, 0, 100)
            Panel.Position = UDim2.new(0, 12, 0, 38)
            Panel.BackgroundTransparency = 1
            Panel.BorderSizePixel = 0
            Panel.ClipsDescendants = true
            Panel.Parent = Elem
            
            -- Saturation/Value gradient canvas
            local SatValGrid = Instance.new("ImageButton")
            SatValGrid.Size = UDim2.new(0.7, -10, 1, -10)
            SatValGrid.Image = "rbxassetid://4155801252" -- Saturation picker template
            SatValGrid.BackgroundColor3 = defaultColor
            SatValGrid.BorderSizePixel = 0
            SatValGrid.Parent = Panel
            
            local SatValCorner = Instance.new("UICorner")
            SatValCorner.CornerRadius = UDim.new(0, 4)
            SatValCorner.Parent = SatValGrid
            
            local PickerNode = Instance.new("Frame")
            PickerNode.Size = UDim2.new(0, 6, 0, 6)
            PickerNode.Position = UDim2.new(0.5, -3, 0.5, -3)
            PickerNode.BackgroundColor3 = Color3.new(1, 1, 1)
            PickerNode.BorderSizePixel = 0
            PickerNode.Parent = SatValGrid
            
            local PickerNodeCorner = Instance.new("UICorner")
            PickerNodeCorner.CornerRadius = UDim.new(1, 0)
            PickerNodeCorner.Parent = PickerNode
            
            -- Hue vertical strip slider
            local HueSlider = Instance.new("ImageButton")
            HueSlider.Size = UDim2.new(0.3, 0, 1, -10)
            HueSlider.Position = UDim2.new(0.7, 0, 0, 0)
            HueSlider.Image = "rbxassetid://3641079629" -- Hue bar template
            HueSlider.BorderSizePixel = 0
            HueSlider.Parent = Panel
            
            local HueCorner = Instance.new("UICorner")
            HueCorner.CornerRadius = UDim.new(0, 4)
            HueCorner.Parent = HueSlider
            
            local HueNode = Instance.new("Frame")
            HueNode.Size = UDim2.new(1, 4, 0, 2)
            HueNode.Position = UDim2.new(0, -2, 0.5, -1)
            HueNode.BackgroundColor3 = Color3.new(1, 1, 1)
            HueNode.BorderSizePixel = 0
            HueNode.Parent = HueSlider
            
            local ColorPickerAPI = {CurrentColor = defaultColor}
            
            local h, s, v = defaultColor:ToHSV()
            local open = false
            
            local function UpdateColor(skipCallback)
                local currentRGB = Color3.fromHSV(h, s, v)
                ColorPickerAPI.CurrentColor = currentRGB
                SatValGrid.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                ColorIndicator.BackgroundColor3 = currentRGB
                
                if flag then
                    Degrad.Flags[flag] = currentRGB
                    SaveConfig()
                end
                
                if not skipCallback then
                    task.spawn(function()
                        local success, err = pcall(callback, currentRGB)
                        if not success then warn("[Degrad ColorPicker Callback Error]: " .. tostring(err)) end
                    end)
                end
            end
            
            -- Sat/Val Picking Input
            local draggingSatVal = false
            local function TrackSatVal(inputPos)
                local relativeX = inputPos.X - SatValGrid.AbsolutePosition.X
                local relativeY = inputPos.Y - SatValGrid.AbsolutePosition.Y
                
                s = math.clamp(relativeX / SatValGrid.AbsoluteWidth, 0, 1)
                v = 1 - math.clamp(relativeY / SatValGrid.AbsoluteHeight, 0, 1)
                
                PickerNode.Position = UDim2.new(s, -3, 1 - v, -3)
                UpdateColor()
            end
            
            SatValGrid.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSatVal = true
                    TrackSatVal(input.Position)
                end
            end)
            
            -- Hue Picking Input
            local draggingHue = false
            local function TrackHue(inputPos)
                local relativeY = inputPos.Y - HueSlider.AbsolutePosition.Y
                h = 1 - math.clamp(relativeY / HueSlider.AbsoluteHeight, 0, 1)
                
                HueNode.Position = UDim2.new(0, -2, 1 - h, -1)
                UpdateColor()
            end
            
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                    TrackHue(input.Position)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    draggingSatVal = false
                    draggingHue = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if draggingSatVal then
                        TrackSatVal(input.Position)
                    elseif draggingHue then
                        TrackHue(input.Position)
                    end
                end
            end)
            
            local function TogglePanel()
                open = not open
                local targetHeight = open and 144 or 38
                QuickTween(Elem, 0.25, {Size = UDim2.new(1, -10, 0, targetHeight)})
            end
            
            ColorIndicator.MouseButton1Click:Connect(TogglePanel)
            
            function ColorPickerAPI:Set(newColor, skipCallback)
                h, s, v = newColor:ToHSV()
                PickerNode.Position = UDim2.new(s, -3, 1 - v, -3)
                HueNode.Position = UDim2.new(0, -2, 1 - h, -1)
                UpdateColor(skipCallback)
            end
            
            -- Init visual nodes
            PickerNode.Position = UDim2.new(s, -3, 1 - v, -3)
            HueNode.Position = UDim2.new(0, -2, 1 - h, -1)
            SatValGrid.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            
            if flag then
                ElementsRegistry[flag] = ColorPickerAPI
            end
            
            return ColorPickerAPI
        end
        
        -- ====================================================================
        -- 9. LABEL
        -- ====================================================================
        function TabAPI:CreateLabel(text, icon, color, ignoreTheme)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Name = "Label"
            LabelFrame.Size = UDim2.new(1, -10, 0, 32)
            LabelFrame.BackgroundColor3 = Degrad.Theme.ElementBackground
            LabelFrame.BorderSizePixel = 0
            LabelFrame.Parent = PageScroll
            
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 5)
            LabelCorner.Parent = LabelFrame
            
            local LabelStroke = Instance.new("UIStroke")
            LabelStroke.Thickness = 1
            LabelStroke.Color = Degrad.Theme.Border
            LabelStroke.Parent = LabelFrame
            
            local HasIcon = (icon ~= nil)
            
            local Icon = Instance.new("ImageLabel")
            if HasIcon then
                Icon.Size = UDim2.new(0, 16, 0, 16)
                Icon.Position = UDim2.new(0, 10, 0.5, -8)
                Icon.Image = GetIcon(icon)
                Icon.ImageColor3 = (not ignoreTheme and color) or color or Degrad.Theme.Text
                Icon.BackgroundTransparency = 1
                Icon.Parent = LabelFrame
            end
            
            local LabelText = Instance.new("TextLabel")
            LabelText.Size = UDim2.new(1, HasIcon and -36 or -20, 1, 0)
            LabelText.Position = UDim2.new(0, HasIcon and 30 or 10, 0, 0)
            LabelText.Text = text
            LabelText.TextColor3 = color or Degrad.Theme.Text
            if ignoreTheme then
                LabelText.TextColor3 = color
            end
            LabelText.TextSize = 12
            LabelText.Font = Degrad.Theme.Font
            LabelText.TextXAlignment = Enum.TextXAlignment.Left
            LabelText.BackgroundTransparency = 1
            LabelText.Parent = LabelFrame
            
            local LabelAPI = {}
            function LabelAPI:Set(newText, newIcon, newColor, newIgnoreTheme)
                LabelText.Text = newText
                if newIcon then
                    Icon.Image = GetIcon(newIcon)
                    Icon.Visible = true
                    LabelText.Position = UDim2.new(0, 30, 0, 0)
                    LabelText.Size = UDim2.new(1, -36, 1, 0)
                end
                if newColor then
                    LabelText.TextColor3 = newColor
                    if Icon then
                        Icon.ImageColor3 = newColor
                    end
                end
            end
            return LabelAPI
        end
        
        -- ====================================================================
        -- 10. PARAGRAPH
        -- ====================================================================
        function TabAPI:CreateParagraph(pgOptions)
            local titleText = pgOptions.Title or "Paragraph"
            local bodyText = pgOptions.Content or ""
            
            local ParaFrame = Instance.new("Frame")
            ParaFrame.Name = "Paragraph"
            ParaFrame.Size = UDim2.new(1, -10, 0, 50) -- Dynamic height
            ParaFrame.BackgroundColor3 = Degrad.Theme.ElementBackground
            ParaFrame.BorderSizePixel = 0
            ParaFrame.Parent = PageScroll
            
            local ParaCorner = Instance.new("UICorner")
            ParaCorner.CornerRadius = UDim.new(0, 6)
            ParaCorner.Parent = ParaFrame
            
            local ParaStroke = Instance.new("UIStroke")
            ParaStroke.Thickness = 1
            ParaStroke.Color = Degrad.Theme.Border
            ParaStroke.Parent = ParaFrame
            
            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.Text = titleText
            Title.TextColor3 = Degrad.Theme.Text
            Title.TextSize = 12
            Title.Font = Degrad.Theme.FontBold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = ParaFrame
            
            local Body = Instance.new("TextLabel")
            Body.Size = UDim2.new(1, -20, 0, 0)
            Body.Position = UDim2.new(0, 10, 0, 24)
            Body.Text = bodyText
            Body.TextColor3 = Degrad.Theme.TextMuted
            Body.TextSize = 11
            Body.Font = Degrad.Theme.Font
            Body.TextWrapped = true
            Body.TextXAlignment = Enum.TextXAlignment.Left
            Body.TextYAlignment = Enum.TextYAlignment.Top
            Body.BackgroundTransparency = 1
            Body.Parent = ParaFrame
            
            -- Real-time height allocation based on text boundary
            local function Resize()
                local height = 32 + math.max(14, Body.TextBounds.Y)
                ParaFrame.Size = UDim2.new(1, -10, 0, height)
                Body.Size = UDim2.new(1, -20, 0, height - 32)
            end
            
            Resize()
            Body:GetPropertyChangedSignal("TextBounds"):Connect(Resize)
            
            local ParagraphAPI = {}
            function ParagraphAPI:Set(newOptions)
                if newOptions.Title then
                    Title.Text = newOptions.Title
                end
                if newOptions.Content then
                    Body.Text = newOptions.Content
                end
                Resize()
            end
            return ParagraphAPI
        end
        
        -- ====================================================================
        -- 11. DIVIDER
        -- ====================================================================
        function TabAPI:CreateDivider()
            local DivFrame = Instance.new("Frame")
            DivFrame.Name = "Divider"
            DivFrame.Size = UDim2.new(1, -10, 0, 9)
            DivFrame.BackgroundTransparency = 1
            DivFrame.BorderSizePixel = 0
            DivFrame.Parent = PageScroll
            
            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, -16, 0, 1)
            Line.Position = UDim2.new(0, 8, 0.5, 0)
            Line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            Line.BorderSizePixel = 0
            Line.Parent = DivFrame
            
            local DividerAPI = {}
            function DividerAPI:Set(visible)
                DivFrame.Visible = visible
            end
            return DividerAPI
        end
        
        return TabAPI
    end
    
    -- Global actions
    function WindowAPI:SetVisibility(visible)
        MainFrame.Visible = visible
    end
    
    function WindowAPI:IsVisible()
        return MainFrame.Visible
    end
    
    function WindowAPI:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Keybind mapping configurations save
    function Degrad:LoadConfiguration()
        LoadConfig(ElementsRegistry)
    end
    
    return WindowAPI
end
return Degrad
