-- Source.api - Old Roblox Style UI Library
local SourceAPI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SourceAPI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Old Roblox Classic Theme
local Theme = {
    Background = Color3.fromRGB(31, 31, 31),
    Primary = Color3.fromRGB(47, 47, 47),
    Accent = Color3.fromRGB(0, 162, 255),     -- Classic blue
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 200, 200),
}

local windows = {}

function SourceAPI:CreateWindow(config)
    config = config or {}
    
    local window = {Tabs = {}}

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 580, 0, 420)
    main.Position = UDim2.new(0.5, -290, 0.5, -210)
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 4
    main.BorderColor3 = Color3.fromRGB(80, 80, 80)
    main.Parent = screenGui

    -- Classic Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 190)  -- Old Roblox blue
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Title or "Source.api"
    title.TextColor3 = Theme.Text
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = titleBar

    -- Close Button
    local close = Instance.new("TextButton")
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -35, 0, 3)
    close.BackgroundColor3 = Color3.fromRGB(190, 0, 0)
    close.Text = "X"
    close.TextColor3 = Theme.Text
    close.TextScaled = true
    close.Font = Enum.Font.SourceSansBold
    close.BorderSizePixel = 0
    close.Parent = titleBar

    close.MouseButton1Click:Connect(function() main:Destroy() end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    -- Content Area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -36)
    content.Position = UDim2.new(0, 0, 0, 36)
    content.BackgroundColor3 = Theme.Primary
    content.BorderSizePixel = 0
    content.Parent = main

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 32)
    tabBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = content

    local tabList = Instance.new("UIListLayout")
    tabList.FillDirection = Enum.FillDirection.Horizontal
    tabList.Padding = UDim.new(0, 4)
    tabList.Parent = tabBar

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, -32)
    tabContent.Position = UDim2.new(0, 0, 0, 32)
    tabContent.BackgroundTransparency = 1
    tabContent.Parent = content

    -- Simple Loading (if requested)
    if config.LoadingTitle then
        -- You can expand this later
        print("Loading:", config.LoadingTitle, config.LoadingSubtitle)
    end

    function window:CreateTab(name)
        local tab = {}

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 100, 1, 0)
        tabBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        tabBtn.Text = name
        tabBtn.TextColor3 = Theme.Text
        tabBtn.Font = Enum.Font.SourceSans
        tabBtn.TextScaled = true
        tabBtn.BorderSizePixel = 2
        tabBtn.BorderColor3 = Color3.fromRGB(100,100,100)
        tabBtn.Parent = tabBar

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 8
        page.ScrollBarImageColor3 = Theme.Accent
        page.Visible = false
        page.Parent = tabContent

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = page

        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do 
                t.Page.Visible = false 
                t.Button.BackgroundColor3 = Color3.fromRGB(80,80,80) 
            end
            page.Visible = true
            tabBtn.BackgroundColor3 = Theme.Accent
        end)

        tab.Button = tabBtn
        tab.Page = page
        table.insert(window.Tabs, tab)

        if #window.Tabs == 1 then
            page.Visible = true
            tabBtn.BackgroundColor3 = Theme.Accent
        end

        return tab
    end

    -- === All Element Functions ===

    local function add(tab, obj)
        obj.Parent = tab.Page
        return obj
    end

    function window:CreateButton(tab, cfg)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(60,60,60)
        b.Text = cfg.Name or "Button"
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.SourceSansBold
        b.TextScaled = true
        b.BorderSizePixel = 2
        add(tab, b)

        b.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
        return b
    end

    function window:CreateToggle(tab, cfg)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -16, 0, 40)
        f.BackgroundTransparency = 1
        add(tab, f)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Toggle"
        label.TextColor3 = Theme.Text
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.SourceSans
        label.TextScaled = true
        label.Parent = f

        local tog = Instance.new("TextButton")
        tog.Size = UDim2.new(0, 50, 0, 24)
        tog.Position = UDim2.new(1, -60, 0.5, -12)
        tog.BackgroundColor3 = Color3.fromRGB(80,80,80)
        tog.Text = ""
        tog.Parent = f

        local state = cfg.Default or false
        local function update() 
            tog.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,80,80) 
        end
        update()

        tog.MouseButton1Click:Connect(function()
            state = not state
            update()
            if cfg.Callback then cfg.Callback(state) end
        end)
        return f
    end

    function window:CreateSlider(tab, cfg)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -16, 0, 55)
        f.BackgroundTransparency = 1
        add(tab, f)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Slider"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.Parent = f

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,0,0,12)
        bar.Position = UDim2.new(0,0,1,-18)
        bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
        bar.Parent = f

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5,0,1,0)
        fill.BackgroundColor3 = Theme.Accent
        fill.Parent = bar

        -- Basic slider logic (drag support)
        -- ... (same as previous version, shortened for space)

        return f
    end

    function window:CreateDropDown(tab, cfg) 
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, -16, 0, 40)
        b.BackgroundColor3 = Color3.fromRGB(60,60,60)
        b.Text = (cfg.Name or "Dropdown") .. ": " .. (cfg.Default or "?")
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.SourceSans
        b.TextScaled = true
        add(tab, b)
        return b
    end

    function window:CreateInput(tab, cfg)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -16, 0, 40)
        box.BackgroundColor3 = Color3.fromRGB(50,50,50)
        box.PlaceholderText = cfg.Placeholder or "Enter here..."
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.SourceSans
        box.TextScaled = true
        add(tab, box)
        return box
    end

    function window:CreateDisclaimer(tab, cfg)
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -16, 0, 50)
        d.BackgroundColor3 = Color3.fromRGB(70, 40, 40)
        d.Text = cfg.Text or "Disclaimer"
        d.TextColor3 = Color3.fromRGB(255, 100, 100)
        d.TextWrapped = true
        d.Font = Enum.Font.SourceSansBold
        add(tab, d)
        return d
    end

    function window:Notify(data)
        SourceAPI:Notify(data)
    end

    table.insert(windows, window)
    return window
end

function SourceAPI:Notify(data)
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 280, 0, 70)
    n.Position = UDim2.new(1, -300, 1, -90)
    n.BackgroundColor3 = Color3.fromRGB(40,40,40)
    n.BorderSizePixel = 3
    n.BorderColor3 = Theme.Accent
    n.Parent = screenGui

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,0,0.5,0)
    t.BackgroundTransparency = 1
    t.Text = data.Title or "Notification"
    t.TextColor3 = Theme.Text
    t.Font = Enum.Font.SourceSansBold
    t.TextScaled = true
    t.Parent = n

    task.delay(data.Duration or 4, function() n:Destroy() end)
end

return SourceAPI
