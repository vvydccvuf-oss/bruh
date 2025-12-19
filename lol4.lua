local Kavo = {
    Config = {
        DefaultPosition = UDim2.new(0.5, -262, 0.5, -159), -- Centered
        ToggleKey = Enum.KeyCode.RightControl,
        LibName = "Kavo_v2_" .. math.random(100, 999)
    }
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Utility = {}
local Objects = {}

-- Fixed Dragging Logic
function Kavo:DraggingEnabled(frame, parent)
    parent = parent or frame
    local dragging, dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = parent.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            parent.Position = UDim2.new(
                framePos.X.Scale, framePos.X.Offset + delta.X, 
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

function Utility:Tween(obj, prop, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), prop):Play()
end

local themeStyles = {
    DarkTheme = {SchemeColor = Color3.fromRGB(64, 64, 64), Background = Color3.fromRGB(15, 15, 15), Header = Color3.fromRGB(10, 10, 10), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(25, 25, 25)},
    LightTheme = {SchemeColor = Color3.fromRGB(150, 150, 150), Background = Color3.fromRGB(255, 255, 255), Header = Color3.fromRGB(200, 200, 200), TextColor = Color3.fromRGB(0, 0, 0), ElementColor = Color3.fromRGB(224, 224, 224)},
    BloodTheme = {SchemeColor = Color3.fromRGB(227, 27, 27), Background = Color3.fromRGB(10, 10, 10), Header = Color3.fromRGB(5, 5, 5), TextColor = Color3.fromRGB(255, 255, 255), ElementColor = Color3.fromRGB(20, 20, 20)},
    Ocean = {SchemeColor = Color3.fromRGB(86, 76, 251), Background = Color3.fromRGB(26, 32, 58), Header = Color3.fromRGB(38, 45, 71), TextColor = Color3.fromRGB(200, 200, 200), ElementColor = Color3.fromRGB(38, 45, 71)}
    -- (Other themes can be added here)
}

function Kavo.CreateLib(kavName, themeName)
    local themeList = themeStyles[themeName] or themeStyles.DarkTheme
    kavName = kavName or "Library"

    -- Cleanup old UI
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == Kavo.Config.LibName then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = Kavo.Config.LibName
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "Main"
    Main.BackgroundColor3 = themeList.Background
    Main.Position = Kavo.Config.DefaultPosition -- Coordinates set here
    Main.Size = UDim2.new(0, 525, 0, 318)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 4)

    local MainHeader = Instance.new("Frame", Main)
    MainHeader.Name = "Header"
    MainHeader.Size = UDim2.new(1, 0, 0, 30)
    MainHeader.BackgroundColor3 = themeList.Header
    Kavo:DraggingEnabled(MainHeader, Main)

    local Title = Instance.new("TextLabel", MainHeader)
    Title.Text = kavName
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextColor3 = themeList.TextColor
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("ImageButton", MainHeader)
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -25, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Image = "rbxassetid://3926305904"
    CloseBtn.ImageRectOffset = Vector2.new(284, 4)
    CloseBtn.ImageRectSize = Vector2.new(24, 24)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local SideBar = Instance.new("Frame", Main)
    SideBar.Name = "SideBar"
    SideBar.Position = UDim2.new(0, 0, 0, 30)
    SideBar.Size = UDim2.new(0, 140, 1, -30)
    SideBar.BackgroundColor3 = themeList.Header
    
    local TabContainer = Instance.new("ScrollingFrame", SideBar)
    TabContainer.Size = UDim2.new(1, 0, 1, 0)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0

    local TabLayout = Instance.new("UIListLayout", TabContainer)
    TabLayout.Padding = UDim.new(0, 5)

    local PageContainer = Instance.new("Frame", Main)
    PageContainer.Position = UDim2.new(0, 145, 0, 35)
    PageContainer.Size = UDim2.new(1, -150, 1, -40)
    PageContainer.BackgroundTransparency = 1

    -- Toggle visibility with Keybind
    UserInputService.InputBegan:Connect(function(io, gpe)
        if not gpe and io.KeyCode == Kavo.Config.ToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    local Tabs = {}
    local firstPage = true

    function Tabs:NewTab(tabName)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.BackgroundColor3 = themeList.SchemeColor
        TabBtn.Text = tabName
        TabBtn.TextColor3 = themeList.TextColor
        TabBtn.Font = Enum.Font.Gotham
        TabBtn.TextSize = 13
        TabBtn.BackgroundTransparency = firstPage and 0 or 1

        local Page = Instance.new("ScrollingFrame", PageContainer)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = firstPage
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        
        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 5)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
            for _, b in pairs(TabContainer:GetChildren()) do 
                if b:IsA("TextButton") then b.BackgroundTransparency = 1 end 
            end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
        end)

        firstPage = false
        
        local Sections = {}
        function Sections:NewSection(secName)
            local SecFrame = Instance.new("Frame", Page)
            SecFrame.Size = UDim2.new(1, -5, 0, 30)
            SecFrame.BackgroundColor3 = themeList.ElementColor
            
            local SecTitle = Instance.new("TextLabel", SecFrame)
            SecTitle.Text = secName
            SecTitle.Size = UDim2.new(1, 0, 1, 0)
            SecTitle.TextColor3 = themeList.SchemeColor
            SecTitle.BackgroundTransparency = 1
            SecTitle.Font = Enum.Font.GothamBold
            SecTitle.TextSize = 12

            local Elements = {}
            function Elements:NewButton(btnText, callback)
                local Btn = Instance.new("TextButton", Page)
                Btn.Size = UDim2.new(1, -5, 0, 35)
                Btn.BackgroundColor3 = themeList.ElementColor
                Btn.Text = btnText
                Btn.TextColor3 = themeList.TextColor
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 13
                
                Btn.MouseButton1Click:Connect(callback)
            end
            -- Add further elements (Toggles, Sliders) here using same logic
            return Elements
        end
        return Sections
    end
    return Tabs
end

return Kavo
