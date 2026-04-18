```lua
--[[local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Arguments = {...}
    if Self and Self.ClassName == "RemoteFunction" then
        if Self.Name == "Economy" then
            print(getcallingscript())
        end
    end
    return OldNamecall(Self, ...)
end)]]

-- // Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- // Init character related vars
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer and LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character and Character:WaitForChild("HumanoidRootPart")

-- // Reassign dead references to new objects
LocalPlayer.CharacterAdded:Connect(function(Child)
    Character = Child
    HumanoidRootPart = Character and Character:WaitForChild("HumanoidRootPart")
end)

-- // General vars
local MapFolder = workspace:WaitForChild("Map")
local PlotsFolder = MapFolder and MapFolder:WaitForChild("Plots")
local GearShopFolder = PlotsFolder and MapFolder:WaitForChild("CenterSquare"):WaitForChild("GearShop")

-- // Init all modules
local PlotModule = {}
PlotModule.ClaimedPlots = {}

local MovementModule = {}
MovementModule.TweeningBusy = false -- << allow global scope access
MovementModule.MiddleManYAxisOffset = Vector3.new(0, 10, 0)
MovementModule.PlotTweenYAxisOffset = Vector3.new(0, 10, 0)

function GetMiddleManTweenPart()
    return GearShopFolder and GearShopFolder:FindFirstChild("Part")
end  

do 
    function PlotModule.GetRandomActiveBase()
        local ClaimedPlots = {}
        
        for _, BaseFolder in PlotsFolder:GetChildren() do
            local IsBaseUnclaimed = BaseFolder:FindFirstChild("BaseOwner"):FindFirstChild("Billboard"):FindFirstChild("NameLabel").Text == "Available"
            if IsBaseUnclaimed then continue end
            
            table.insert(ClaimedPlots, BaseFolder)
        end

        return ClaimedPlots and ClaimedPlots[math.random(1, #ClaimedPlots)] -- << select a random index in the claimed plots
    end

    function PlotModule.GetRawBaseRoot(BaseFolder)
        return BaseFolder and BaseFolder:FindFirstChild("Root")
    end
end

do 
    function MovementModule.TweenToCFrame(TargetCFrame, Speed)
        local Tween = TweenService:Create(
            HumanoidRootPart, 
            TweenInfo.new((TargetCFrame.Position - HumanoidRootPart.Position).Magnitude / Speed, Enum.EasingStyle.Linear), {
                CFrame = TargetCFrame
            }
        )

        MovementModule.TweeningBusy = true

        Tween:Play()
        Tween.Completed:Wait()

        MovementModule.TweeningBusy = false
    end

    function MovementModule.TweenToPlot(TargetPlotRoot)
        if not TargetPlotRoot then return end

        --// Tween to middle man
        local MiddleManPart = GetMiddleManTweenPart()
        if not MiddleManPart then return end

        MovementModule.TweenToCFrame(MiddleManPart.CFrame * CFrame.new(MovementModule.MiddleManYAxisOffset), 30)
        --// Tween to plot
        MovementModule.TweenToCFrame(TargetPlotRoot.CFrame * CFrame.new(MovementModule.PlotTweenYAxisOffset), 30)
    end
end

local RandomBase = PlotModule.GetRandomActiveBase()
local BaseRoot = PlotModule.GetRawBaseRoot(RandomBase)
MovementModule.TweenToPlot(BaseRoot)

-- // TODO: ?
```
