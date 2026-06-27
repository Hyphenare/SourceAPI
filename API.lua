-- Source.api - Old Roblox Classic Style UI Library
local SourceAPI = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SourceAPI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local Theme = {
    Background = Color3.fromRGB(31, 31, 31),
    Primary = Color3.fromRGB(47, 47, 47),
    Accent = Color3.fromRGB(0, 162, 255),
    Text = Color3.fromRGB(255, 255, 255),
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

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(0, 110, 190)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title or "Source.api"
    titleLabel.TextColor3 = Theme.Text
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = titleBar

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(190, 0, 0)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Theme.Text
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar

    closeBtn.MouseButton1Click:Connect(function() main:Destroy() end)

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

    -- Content
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -36)
    content.Position = UDim2.new(0, 0, 0, 36)
    content.BackgroundColor3 = Theme.Primary
    content.BorderSizePixel = 0
    content.Parent = main

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 32)
    tabBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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
        f.Size = UDim2.new(1, -16, 0, 60)
        f.BackgroundTransparency = 1
        add(tab, f)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Slider"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.SourceSans
        label.Parent = f

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Position = UDim2.new(1, -60, 0, 0)
        valueLabel.Size = UDim2.new(0, 60, 0, 20)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(cfg.Default or cfg.Min or 0)
        valueLabel.TextColor3 = Theme.Accent
        valueLabel.Font = Enum.Font.SourceSans
        valueLabel.Parent = f

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1,0,0,12)
        bar.Position = UDim2.new(0,0,1,-22)
        bar.BackgroundColor3 = Color3.fromRGB(70,70,70)
        bar.Parent = f

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5,0,1,0)
        fill.BackgroundColor3 = Theme.Accent
        fill.Parent = bar

        local min = cfg.Min or 0
        local max = cfg.Max or 100
        local value = cfg.Default or min

        local function updateSlider()
            local percent = math.clamp((value - min) / (max - min), 0, 1)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(math.floor(value))
        end
        updateSlider()

        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = UserInputService:GetMouseLocation().X
                local barPos = bar.AbsolutePosition.X
                local barSize = bar.AbsoluteSize.X
                local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
                value = min + percent * (max - min)
                updateSlider()
                if cfg.Callback then cfg.Callback(value) end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)

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
        b.BorderSizePixel = 2
        add(tab, b)
        return b
    end

    function window:CreateInput(tab, cfg)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -16, 0, 40)
        box.BackgroundColor3 = Color3.fromRGB(50,50,50)
        box.PlaceholderText = cfg.Placeholder or "Type here..."
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.SourceSans
        box.TextScaled = true
        box.ClearTextOnFocus = false
        add(tab, box)
        return box
    end

    function window:CreateDisclaimer(tab, cfg)
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, -16, 0, 60)
        d.BackgroundColor3 = Color3.fromRGB(70, 30, 30)
        d.Text = cfg.Text or "Disclaimer Text"
        d.TextColor3 = Color3.fromRGB(255, 100, 100)
        d.TextWrapped = true
        d.Font = Enum.Font.SourceSansBold
        d.TextScaled = true
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
    n.Size = UDim2.new(0, 280, 0, 80)
    n.Position = UDim2.new(1, -300, 1, -100)
    n.BackgroundColor3 = Color3.fromRGB(40,40,40)
    n.BorderSizePixel = 3
    n.BorderColor3 = Theme.Accent
    n.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0.4,0)
    title.BackgroundTransparency = 1
    title.Text = data.Title or "Notification"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.SourceSansBold
    title.TextScaled = true
    title.Parent = n

    task.delay(data.Duration or 4, function() n:Destroy() end)
end

return SourceAPI
