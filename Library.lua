local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local sC = setclipboard or toclipboard or (syn and syn.write_clipboard) or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function()
    return CoreGui
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Mouse = cloneref(LocalPlayer:GetMouse())

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}
local Tooltips = {}

local BaseURL = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local CustomImageManager = {}
local CustomImageManagerAssets = {
    TransparencyTexture = {
        RobloxId = 139785960036434,
        Path = "Obsidian/assets/TransparencyTexture.png",
        URL = BaseURL .. "assets/TransparencyTexture.png",

        Id = nil,
    },

    SaturationMap = {
        RobloxId = 4155801252,
        Path = "Obsidian/assets/SaturationMap.png",
        URL = BaseURL .. "assets/SaturationMap.png",

        Id = nil,
    },

    LoadingIcon = {
        RobloxId = 97544096941083,
        Path = "Obsidian/assets/LoadingIcon.png",
        URL = BaseURL .. "assets/LoadingIcon.png",

        Id = nil,
    },

    CheckIcon = {
        RobloxId = 97682394690683,
        Path = "Obsidian/assets/CheckIcon.png",
        URL = BaseURL .. "assets/CheckIcon.png",

        Id = nil,
    },
}
do
    local function RecursiveCreatePath(Path: string, IsFile: boolean?)
        if not isfolder or not makefolder then
            return
        end

        local Segments = Path:split("/")
        local TraversedPath = ""

        if IsFile then
            table.remove(Segments, #Segments)
        end

        for _, Segment in ipairs(Segments) do
            if not isfolder(TraversedPath .. Segment) then
                makefolder(TraversedPath .. Segment)
            end

            TraversedPath = TraversedPath .. Segment .. "/"
        end

        return TraversedPath
    end

    function CustomImageManager.AddAsset(
        AssetName: string,
        RobloxAssetId: number,
        URL: string,
        ForceRedownload: boolean?
    )
        if CustomImageManagerAssets[AssetName] ~= nil then
            error(string.format("Asset %q already exists", AssetName))
        end

        assert(typeof(RobloxAssetId) == "number", "RobloxAssetId must be a number")

        CustomImageManagerAssets[AssetName] = {
            RobloxId = RobloxAssetId,
            Path = string.format("Obsidian/custom_assets/%s", AssetName),
            URL = URL,

            Id = nil,
        }

        CustomImageManager.DownloadAsset(AssetName, ForceRedownload)
    end

    function CustomImageManager.GetAsset(AssetName: string)
        if not CustomImageManagerAssets[AssetName] then
            return nil
        end

        local AssetData = CustomImageManagerAssets[AssetName]
        if AssetData.Id then
            return AssetData.Id
        end

        local AssetID = string.format("rbxassetid://%s", AssetData.RobloxId)

        if getcustomasset then
            local Success, NewID = pcall(getcustomasset, AssetData.Path)

            if Success and NewID then
                AssetID = NewID
            end
        end

        AssetData.Id = AssetID
        return AssetID
    end

    function CustomImageManager.DownloadAsset(AssetName: string, ForceRedownload: boolean?)
        if not getcustomasset or not writefile or not isfile then
            return false, "missing functions"
        end

        local AssetData = CustomImageManagerAssets[AssetName]

        RecursiveCreatePath(AssetData.Path, true)

        if ForceRedownload ~= true and isfile(AssetData.Path) then
            return true, nil
        end

        local success, errorMessage = pcall(function()
            writefile(AssetData.Path, game:HttpGet(AssetData.URL))
        end)

        return success, errorMessage
    end

    for AssetName, _ in CustomImageManagerAssets do
        CustomImageManager.DownloadAsset(AssetName)
    end
end

local Library = {
    LocalPlayer = LocalPlayer,
    IsRobloxFocused = true,

    --// Device \\--
    DevicePlatform = nil,
    IsMobile = false,

    --// Obsidian Windows \\--
    ScreenGui = nil,
    Window = nil,
    WindowContainer = nil,

    --// Search \\--
    SearchText = "",
    Searching = false,
    GlobalSearch = false,
    LastSearchTab = nil,

    --// Tabs \\--
    ActiveTab = nil,
    Tabs = {},
    TabButtons = {},

    --// Dependency Boxes \\--
    DependencyBoxes = {},

    --// Keybinds Frame \\--
    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    --// Notifications \\--
    Notifications = {},
    NotifySide = "Right",
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    NotificationHistory = {},
    NotificationHistoryLimit = 100,
    NotificationHistoryKeybind = Enum.KeyCode.RightAlt,
    NotificationHistoryFrame = nil,
    NotificationHistoryContainer = nil,
    NotificationHistoryOpen = false,
    NotificationHistoryRestPos = nil,
    NotificationUnreadCount = 0,
    NotificationBadge = nil,
    NotificationBadges = {},
    NotificationBell = nil,
    NotificationBellMini = nil,

    NotificationSound = 131661992591924,

    NotificationTypeColors = {
        Error = Color3.fromRGB(255, 76, 76),
        Warning = Color3.fromRGB(255, 176, 32),
        Warn = Color3.fromRGB(255, 176, 32),
        Success = Color3.fromRGB(96, 216, 118),
        Info = Color3.fromRGB(96, 165, 255),
    },

    NotificationTypeIcons = {
        Error = "circle-x",
        Warning = "circle-alert",
        Warn = "circle-alert",
        Success = "check",
        Info = "info",
    },

    --// Enabled Features \\--
    EnabledFeaturesFrame = nil,
    EnabledFeaturesContainer = nil,
    EnabledFeaturesButton = nil,
    EnabledFeaturesButtonMini = nil,
    EnabledFeaturesOpen = false,
    EnabledFeaturesRestPos = nil,

    --// Dialogues \\--
    Dialogues = {},
    ActiveDialog = nil,
    MainFrame = nil,
    ActiveExpandedDropdown = nil,

    --// Loading Window \\--
    ActiveLoading = nil,

    --// Corners \\--
    Corners = {},
    SpecificCorners = {},
    PillCorners = {},

    --// Animations \\--
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    TabTransitionInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    TabSwipeOffset = 26,
    TabSwipeFrom = "bottom",

    WindowAnimationInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    DropdownTransitionInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    KeyPickerTransitionInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    GroupboxTweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    RotatingChevronTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    Animations = {
        ToggleWindow = false,
        TabSwitch = false,
        Groupbox = false,
        Dropdown = false,
        KeyPicker = false
    },

    --// States \\--
    Toggled = false,
    Unloaded = false,

    --// Elements \\--
    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    --// Options \\--
    ToggleKeybind = Enum.KeyCode.RightControl,
    ShowToggleFrameInKeybinds = true,

    NotifyOnError = false,
    ShowCustomCursor = true,
    ForceCheckbox = false,

    CantDragForced = false,
    DraggableElements = {},

    --// Signals \\--
    Signals = {},
    UnloadSignals = {},

    OriginalMinSize = Vector2.new(480, 360),
    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    --// Scheme \\--
    IsLightTheme = false,
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 15, 15),
        MainColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(125, 85, 255),
        OutlineColor = Color3.fromRGB(40, 40, 40),
        FontColor = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.Code),

        RedColor = Color3.fromRGB(255, 50, 50),
        DestructiveColor = Color3.fromRGB(220, 38, 38),
        DarkColor = Color3.new(0, 0, 0),
        WhiteColor = Color3.new(1, 1, 1),
        BlueColor = Color3.fromRGB(80, 155, 255),

        BackgroundImage = ""
    },

    --// Registry \\--
    Registry = {},
	Scales = {},
	ScalesOffset = {},

    --// Misc \\--
    ImageManager = CustomImageManager,
    ShowCursorBinding = string.sub(tostring({}), 10),

    Notify = nil, Toggle = nil -- we love luau lsp
}

if RunService:IsStudio() then
    if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
        Library.IsMobile = true
        Library.OriginalMinSize = Vector2.new(480, 240)
    else
        Library.IsMobile = false
        Library.OriginalMinSize = Vector2.new(480, 360)
    end
else
    pcall(function()
        Library.DevicePlatform = UserInputService:GetPlatform()
    end)

    Library.IsMobile = (Library.DevicePlatform == Enum.Platform.Android or Library.DevicePlatform == Enum.Platform.IOS)
    Library.OriginalMinSize = Library.IsMobile and Vector2.new(480, 240) or Vector2.new(480, 360)
end

local Templates = {
    --// UI \\--
    Frame = {
        BorderSizePixel = 0,
    },
    ImageLabel = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
    },
    ImageButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
    },
    ScrollingFrame = {
        BorderSizePixel = 0,
    },
    TextLabel = {
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextButton = {
        AutoButtonColor = false,
        BorderSizePixel = 0,
        FontFace = "Font",
        RichText = true,
        TextColor3 = "FontColor",
    },
    TextBox = {
        BorderSizePixel = 0,
        FontFace = "Font",
        PlaceholderColor3 = function()
            local H, S, V = Library.Scheme.FontColor:ToHSV()
            return Color3.fromHSV(H, S, V / 2)
        end,
        Text = "",
        TextColor3 = "FontColor",
    },
    UIListLayout = {
        SortOrder = Enum.SortOrder.LayoutOrder,
    },
    UIStroke = {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    },

    --// Library \\--
    Window = {
        Title = "No Title",
        Footer = "No Footer",

        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(720, 600),
        IconSize = UDim2.fromOffset(30, 30),

        AutoShow = true,
        Center = true,
        Resizable = true,
        AlwaysOnTop = false,

        SearchbarSize = UDim2.fromScale(0.5, 1),
        GlobalSearch = false,
        FuzzySearch = true,
        SearchValues = true,
        SearchKeybind = Enum.KeyCode.F,
        DisableSearchKeybind = false,

        Minimizable = true,
        MinimizeKeybind = nil,
        MinimizedWidth = 300,
        MinimizedSubtitle = "",

        CornerRadius = 4,
        NotifySide = "Right",
        ShowCustomCursor = true,

        Font = Enum.Font.Code,
        ToggleKeybind = Enum.KeyCode.RightControl,

        ShowMobileButtons = true,
        MobileButtonsSide = "Left",

        UnlockMouseWhileOpen = true,

        EnableSidebarResize = false,
        EnableCompacting = true,
        DisableCompactingSnap = false,
        SidebarCompacted = false,
        MinContainerWidth = 256,

        --// Snapping \\--
        MinSidebarWidth = 128,
        SidebarCompactWidth = 48,
        SidebarCollapseThreshold = 0.5,

        --// Dragging \\--
        CompactWidthActivation = 128,

        --// Background \\--
        BackgroundImage = "",

        --// Animations \\--
        Animations = {
            ToggleWindow = false,
            TabSwitch = false,
            Groupbox = false,
            Dropdown = false,
            KeyPicker = false
        },

        TabTransitionTime = 0.22,
        TabSwipeOffset = 26,
        TabSwipeFrom = "bottom"
    },
    Dialog = {
        Title = "Dialog",
        Description = "Description",
        AutoDismiss = true,
        OutsideClickDismiss = true,
        FooterButtons = {}
    },
    Loading = {
        Title = "mspaint",
        Icon = 95816097006870,
        IconSize = UDim2.fromOffset(30, 30),

        AlwaysOnTop = true,

        LoadingIcon = CustomImageManager.GetAsset("LoadingIcon"),
        LoadingIconColor = nil,
        LoadingIconTweenTime = 1,

        CurrentStep = 0,
        TotalSteps = 10,

        ShowSidebar = false,
        AutoResizeHeight = false,

        WindowWidth = 450,
        WindowHeight = 275,

        ContentWidth = 450,
        SidebarWidth = 250,
    },
    Toggle = {
        Text = "Toggle",
        Default = false,

        Callback = function() end,
        Changed = function() end,

        Risky = false,
        Disabled = false,
        Visible = true,
    },
    Input = {
        Text = "Input",
        Default = "",
        Finished = false,
        Numeric = false,
        ClearTextOnFocus = true,
        ClearTextOnBlur = false,
        Placeholder = "",
        AllowEmpty = true,
        EmptyReset = "---",

        Callback = function() end,
        Changed = function() end,
        VerifyValue = nil,

        Disabled = false,
        Visible = true,
    },
    Slider = {
        Text = "Slider",
        Default = 0,
        Min = 0,
        Max = 100,
        Rounding = 0,

        Prefix = "",
        Suffix = "",

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,

        AllowRightClickInput = true
    },
    Dropdown = {
        Values = {},
        DisabledValues = {},
        ValueImages = {},

        Multi = false,
        DragSelect = false,
        MaxVisibleDropdownItems = 8,

        Expandable = true,
        ExpandColumns = 2,

        Callback = function() end,
        Changed = function() end,

        Disabled = false,
        Visible = true,
    },
    PriorityList = {
        Text = "Priority List",
        Values = {},
        Default = {},
        Callback = function() end,
        Changed = function() end,
        Disabled = false,
        Visible = true,
    },
    Viewport = {
        Object = nil,
        Camera = nil,
        Clone = true,
        AutoFocus = true,
        Interactive = false,
        Height = 200,
        Visible = true,
    },
    Image = {
        Image = "",
        Transparency = 0,
        BackgroundTransparency = 0,
        Color = Color3.new(1, 1, 1),
        RectOffset = Vector2.zero,
        RectSize = Vector2.zero,
        ScaleType = Enum.ScaleType.Fit,
        Height = 200,
        Visible = true,
    },
    Video = {
        Video = "",
        Looped = false,
        Playing = false,
        Volume = 1,
        Height = 200,
        Visible = true,
    },
    UIPassthrough = {
        Instance = nil,
        Height = 24,
        Visible = true,
    },

    --// Addons \\-
    KeyPicker = {
        Text = "KeyPicker",

        Default = "None",
        DefaultModifiers = {},

        Blacklisted = {},
        BlacklistedModifiers = {},
        Whitelisted = {},
        WhitelistedModifiers = {},

        Mode = "Toggle",
        Modes = { "Always", "Toggle", "Hold" },
        SyncToggleState = false,

        Callback = function() end,
        ChangedCallback = function() end,
        Changed = function() end,
        Clicked = function() end,
    },
    ColorPicker = {
        Default = Color3.new(1, 1, 1),

        Callback = function() end,
        Changed = function() end,
    },
}

local Places = {
    Bottom = { 0, 1 },
    Right = { 1, 0 },
}
local Sizes = {
    Left = { 0.5, 1 },
    Right = { 0.5, 1 },
}

--// Scheme Functions \\--
local SchemeReplaceAlias = {
    RedColor = "Red",
    WhiteColor = "White",
    DarkColor = "Dark"
}

local SchemeAlias = {
    Red = "RedColor",
    Blue = "BlueColor",
    White = "WhiteColor",
    Dark = "DarkColor"
}

local function GetSchemeValue(Index)
    if not Index then
        return nil
    end

    local ReplaceAliasIndex = SchemeReplaceAlias[Index]
    if ReplaceAliasIndex and Library.Scheme[ReplaceAliasIndex] ~= nil then
        Library.Scheme[Index] = Library.Scheme[ReplaceAliasIndex]
        Library.Scheme[ReplaceAliasIndex] = nil

        return Library.Scheme[Index]
    end

    local AliasIndex = SchemeAlias[Index]
    if AliasIndex and Library.Scheme[AliasIndex] ~= nil then
        warn(string.format("Scheme Value %q is deprecated, please use %q instead.", Index, AliasIndex))
        return Library.Scheme[AliasIndex]
    end

    return Library.Scheme[Index]
end

--// Basic Functions \\--
local function WaitForEvent(Event, Timeout, Condition)
    local Bindable = Instance.new("BindableEvent")
    local Connection = Event:Once(function(...)
        if not Condition or typeof(Condition) == "function" and Condition(...) then
            Bindable:Fire(true)
        else
            Bindable:Fire(false)
        end
    end)
    task.delay(Timeout, function()
        Connection:Disconnect()
        Bindable:Fire(false)
    end)

    local Result = Bindable.Event:Wait()
    Bindable:Destroy()

    return Result
end

local function IsMouseInput(Input: InputObject, IncludeM2: boolean?)
    return Input.UserInputType == Enum.UserInputType.MouseButton1
        or (IncludeM2 == true and Input.UserInputType == Enum.UserInputType.MouseButton2)
        or Input.UserInputType == Enum.UserInputType.Touch
end
local function IsClickInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and Input.UserInputState == Enum.UserInputState.Begin
        and Library.IsRobloxFocused
end
local function IsHoverInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Input.UserInputState == Enum.UserInputState.Change
end
local function IsDragInput(Input: InputObject, IncludeM2: boolean?)
    return IsMouseInput(Input, IncludeM2)
        and (Input.UserInputState == Enum.UserInputState.Begin or Input.UserInputState == Enum.UserInputState.Change)
        and Library.IsRobloxFocused
end
local function IsMouseClickInput(Input: InputObject)
    return Input.UserInputType == Enum.UserInputType.MouseButton1 or 
        Input.UserInputType == Enum.UserInputType.MouseButton2 or 
        Input.UserInputType == Enum.UserInputType.MouseButton3
end
local function IsMovementInput(Input: InputObject)
    return (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
        and Library.IsRobloxFocused
end

local function GetTableSize(Table: { [any]: any })
    local Size = 0

    for _, _ in Table do
        Size += 1
    end

    return Size
end

local function IsSequentialArray(t: { [any]: any })
    for k in t do
        if typeof(k) ~= "number" or k < 1 or k % 1 ~= 0 then
            return false
        end
    end
    return true
end

local function StopTween(Tween: TweenBase, Destroy: boolean?)
    if not Tween then
        return
    end

    if Tween.PlaybackState == Enum.PlaybackState.Playing then
        Tween:Cancel()
    end

    if Destroy == true then
        pcall(Tween.Destroy, Tween)
    end
end
local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end
local function Round(Value, Rounding)
    assert(Rounding >= 0, "Invalid rounding number.")

    if Rounding == 0 then
        return math.floor(Value)
    end

    return tonumber(string.format("%." .. Rounding .. "f", Value))
end

local function GetPlayers(ExcludeLocalPlayer: boolean?)
    local PlayerList = Players:GetPlayers()

    if ExcludeLocalPlayer then
        local Idx = table.find(PlayerList, LocalPlayer)
        if Idx then
            table.remove(PlayerList, Idx)
        end
    end

    table.sort(PlayerList, function(Player1, Player2)
        return Player1.Name:lower() < Player2.Name:lower()
    end)

    return PlayerList
end
local function GetTeams()
    local TeamList = Teams:GetTeams()

    table.sort(TeamList, function(Team1, Team2)
        return Team1.Name:lower() < Team2.Name:lower()
    end)

    return TeamList
end

function Library:GetActiveSides()
    local t = Library.ActiveTab
    if not t then
        return {}
    end
    if t.ActiveSubTab then
        return t.ActiveSubTab.Sides
    end
    return t.Sides or {}
end

function Library:UpdateDependencyBoxes()
    for _, Depbox in Library.DependencyBoxes do
        Depbox:Update(true)
    end

    if Library.Searching then
        Library:UpdateSearch(Library.SearchText)
    end
end

local MaxSearchedValues = 100

local function IsSubsequence(Haystack: string, Needle: string): boolean
    local HaystackLen = #Haystack
    local Index = 1

    for Position = 1, #Needle do
        local Char = Needle:sub(Position, Position)

        if Char == " " then
            continue
        end

        local Found = Haystack:find(Char, Index, true)
        if not Found then
            return false
        end

        Index = Found + 1
        if Index > HaystackLen + 1 then
            return false
        end
    end

    return true
end

local function TextMatches(Text, Search: string): boolean
    if Search == "" then
        return true
    end
    if typeof(Text) ~= "string" or Text == "" then
        return false
    end

    local Lowered = Text:lower()

    if Lowered:find(Search, 1, true) then
        return true
    end

    if not Library.FuzzySearch then
        return false
    end

    local Stripped = Search:gsub("%s", "")
    if #Stripped < 2 then
        return false
    end

    return IsSubsequence(Lowered, Search)
end

local function FormatSearchValue(ElementInfo, Value): string?
    if Value == nil then
        return nil
    end

    local Formatter = ElementInfo.FormatListValue or ElementInfo.FormatDisplayValue
    if Formatter then
        local Success, Formatted = pcall(Formatter, Value)
        if Success and Formatted ~= nil then
            return tostring(Formatted)
        end
    end

    local Success, Text = pcall(tostring, Value)
    return Success and Text or nil
end

local function ValueMatches(ElementInfo, Search: string): boolean
    local Type = ElementInfo.Type

    if Type == "Dropdown" then
        local Scanned = 0

        if typeof(ElementInfo.Values) == "table" then
            for _, Value in ElementInfo.Values do
                Scanned += 1
                if Scanned > MaxSearchedValues then
                    break
                end

                if TextMatches(FormatSearchValue(ElementInfo, Value), Search) then
                    return true
                end
            end
        end

        local Value = ElementInfo.Value
        if ElementInfo.Multi and typeof(Value) == "table" then
            for Selected, Active in Value do
                if Active and TextMatches(FormatSearchValue(ElementInfo, Selected), Search) then
                    return true
                end
            end
        elseif Value ~= nil and TextMatches(FormatSearchValue(ElementInfo, Value), Search) then
            return true
        end

        return false
    elseif Type == "Input" then
        return TextMatches(ElementInfo.Value, Search)
    elseif Type == "KeyPicker" then
        return TextMatches(ElementInfo.Value, Search) or TextMatches(ElementInfo.Mode, Search)
    end

    return false
end

function Library:MatchesSearch(ElementInfo, Search: string): boolean
    if typeof(ElementInfo) ~= "table" then
        return false
    end
    if typeof(Search) ~= "string" or Trim(Search) == "" then
        return true
    end

    if TextMatches(ElementInfo.Text, Search) then
        return true
    end

    if not Library.SearchValues then
        return false
    end

    if ValueMatches(ElementInfo, Search) then
        return true
    end

    if typeof(ElementInfo.Addons) == "table" then
        for _, Addon in ElementInfo.Addons do
            if typeof(Addon) == "table" and ValueMatches(Addon, Search) then
                return true
            end
        end
    end

    return false
end

local function CheckDepbox(Box, Search)
    local VisibleElements = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            local Visible = false

            if Library:MatchesSearch(ElementInfo, Search) and ElementInfo.Visible then
                Visible = true
            else
                ElementInfo.Base.Visible = false
            end
            if Library:MatchesSearch(ElementInfo.SubButton, Search) and ElementInfo.SubButton.Visible then
                Visible = true
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        if Library:MatchesSearch(ElementInfo, Search) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        VisibleElements += CheckDepbox(Depbox, Search)
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements
end

local ResetTab

local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return
    end

    local HasVisible = false

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        local BoxMatched = TextMatches(Groupbox.Name, Search)

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = BoxMatched and ElementInfo.Visible ~= false
                continue
            elseif ElementInfo.SubButton then
                local Visible = false

                if (BoxMatched or Library:MatchesSearch(ElementInfo, Search)) and ElementInfo.Visible then
                    Visible = true
                else
                    ElementInfo.Base.Visible = false
                end
                if
                    (BoxMatched or Library:MatchesSearch(ElementInfo.SubButton, Search))
                    and ElementInfo.SubButton.Visible
                then
                    Visible = true
                else
                    ElementInfo.SubButton.Base.Visible = false
                end
                ElementInfo.Holder.Visible = Visible

                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            if (BoxMatched or Library:MatchesSearch(ElementInfo, Search)) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            VisibleElements += CheckDepbox(Depbox, Search)
        end

        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            local BoxMatched = TextMatches(SubTab.Name, Search)

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = BoxMatched and ElementInfo.Visible ~= false
                    continue
                elseif ElementInfo.SubButton then
                    local Visible = false

                    if (BoxMatched or Library:MatchesSearch(ElementInfo, Search)) and ElementInfo.Visible then
                        Visible = true
                    else
                        ElementInfo.Base.Visible = false
                    end
                    if
                        (BoxMatched or Library:MatchesSearch(ElementInfo.SubButton, Search))
                        and ElementInfo.SubButton.Visible
                    then
                        Visible = true
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end
                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                if (BoxMatched or Library:MatchesSearch(ElementInfo, Search)) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                VisibleElements[SubTab] += CheckDepbox(Depbox, Search)
            end
        end

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                if Tabbox.ActiveTab == SubTab then
                    SubTab:Resize()
                elseif Tabbox.ActiveTab and VisibleElements[Tabbox.ActiveTab] == 0 then
                    SubTab:Show()
                end
            end
        end

        Tabbox.BoxHolder.Visible = VisibleTabs > 0
    end

    if Tab.SubTabs then
        local VisibleSubTabs = {}

        for _, SubTab in Tab.SubTabs do
            local SubVisible
            if TextMatches(SubTab.Name, Search) then
                ResetTab(SubTab)
                SubVisible = true
            else
                SubVisible = ApplySearchToTab(SubTab, Search)
            end
            VisibleSubTabs[SubTab] = SubVisible

            SubTab.Button.Visible = SubVisible
            if SubVisible then
                HasVisible = true
            end
        end

        local Active = Tab.ActiveSubTab
        if Active and VisibleSubTabs[Active] == false then
            for SubTab, SubVisible in VisibleSubTabs do
                if SubVisible then
                    SubTab:Show()
                    break
                end
            end
        end
    end

    return HasVisible
end

local function CheckDepbox(Box, Search)
    local VisibleElements = 0

    for _, ElementInfo in Box.Elements do
        if ElementInfo.Type == "Divider" then
            ElementInfo.Holder.Visible = false
            continue
        elseif ElementInfo.SubButton then
            --// Check if any of the Buttons Name matches with Search
            local Visible = false

            --// Check if Search matches Element's Name and if Element is Visible
            if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                Visible = true
            else
                ElementInfo.Base.Visible = false
            end
            if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                Visible = true
            else
                ElementInfo.SubButton.Base.Visible = false
            end
            ElementInfo.Holder.Visible = Visible
            if Visible then
                VisibleElements += 1
            end

            continue
        end

        --// Check if Search matches Element's Name and if Element is Visible
        if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
            ElementInfo.Holder.Visible = true
            VisibleElements += 1
        else
            ElementInfo.Holder.Visible = false
        end
    end

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        VisibleElements += CheckDepbox(Depbox, Search)
    end

    Box.Holder.Visible = VisibleElements > 0
    return VisibleElements
end
local function RestoreDepbox(Box)
    for _, ElementInfo in Box.Elements do
        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

        if ElementInfo.SubButton then
            ElementInfo.Base.Visible = ElementInfo.Visible
            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
        end
    end

    Box:Resize()
    Box.Holder.Visible = true

    for _, Depbox in Box.DependencyBoxes do
        if not Depbox.Visible then
            continue
        end

        RestoreDepbox(Depbox)
    end
end

local function ApplySearchToTab(Tab, Search)
    if not Tab then
        return
    end

    local HasVisible = false

    for _, Groupbox in Tab.Groupboxes do
        if Groupbox.Visible == false then
            continue
        end

        local VisibleElements = 0
        for _, ElementInfo in Groupbox.Elements do
            if ElementInfo.Type == "Divider" then
                ElementInfo.Holder.Visible = false
                continue
            elseif ElementInfo.SubButton then
                local Visible = false

                if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    Visible = true
                else
                    ElementInfo.Base.Visible = false
                end
                if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                    Visible = true
                else
                    ElementInfo.SubButton.Base.Visible = false
                end
                ElementInfo.Holder.Visible = Visible

                if Visible then
                    VisibleElements += 1
                end

                continue
            end

            if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                ElementInfo.Holder.Visible = true
                VisibleElements += 1
            else
                ElementInfo.Holder.Visible = false
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            VisibleElements += CheckDepbox(Depbox, Search)
        end

        if Groupbox.Tabboxes then
            for _, Tabbox in Groupbox.Tabboxes do
                local VisibleTabs = 0
                local VisibleElementsInTabbox = {}

                for _, SubTab in Tabbox.Tabs do
                    VisibleElementsInTabbox[SubTab] = 0

                    for _, ElementInfo in SubTab.Elements do
                        if ElementInfo.Type == "Divider" then
                            ElementInfo.Holder.Visible = false
                            continue
                        elseif ElementInfo.SubButton then
                            local Visible = false

                            if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                                Visible = true
                            else
                                ElementInfo.Base.Visible = false
                            end
                            if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                                Visible = true
                            else
                                ElementInfo.SubButton.Base.Visible = false
                            end
                            ElementInfo.Holder.Visible = Visible
                            if Visible then
                                VisibleElementsInTabbox[SubTab] += 1
                            end

                            continue
                        end

                        if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                            ElementInfo.Holder.Visible = true
                            VisibleElementsInTabbox[SubTab] += 1
                        else
                            ElementInfo.Holder.Visible = false
                        end
                    end

                    for _, Depbox in SubTab.DependencyBoxes do
                        if not Depbox.Visible then
                            continue
                        end

                        VisibleElementsInTabbox[SubTab] += CheckDepbox(Depbox, Search)
                    end
                end

                for SubTab, Visible in VisibleElementsInTabbox do
                    SubTab.ButtonHolder.Visible = Visible > 0
                    if Visible > 0 then
                        VisibleTabs += 1
                        VisibleElements += 1

                        if Tabbox.ActiveTab == SubTab then
                            SubTab:Resize()
                        elseif Tabbox.ActiveTab and (VisibleElementsInTabbox[Tabbox.ActiveTab] or 0) == 0 then
                            SubTab:Show()
                        end
                    end
                end

                Tabbox.BoxHolder.Visible = VisibleTabs > 0
            end
        end

        if VisibleElements > 0 then
            Groupbox:Resize()
            HasVisible = true
        end
        Groupbox.BoxHolder.Visible = VisibleElements > 0
    end

    for _, Tabbox in Tab.Tabboxes do
        local VisibleTabs = 0
        local VisibleElements = {}

        for _, SubTab in Tabbox.Tabs do
            VisibleElements[SubTab] = 0

            for _, ElementInfo in SubTab.Elements do
                if ElementInfo.Type == "Divider" then
                    ElementInfo.Holder.Visible = false
                    continue
                elseif ElementInfo.SubButton then
                    local Visible = false

                    if ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                        Visible = true
                    else
                        ElementInfo.Base.Visible = false
                    end
                    if ElementInfo.SubButton.Text:lower():match(Search) and ElementInfo.SubButton.Visible then
                        Visible = true
                    else
                        ElementInfo.SubButton.Base.Visible = false
                    end
                    ElementInfo.Holder.Visible = Visible
                    if Visible then
                        VisibleElements[SubTab] += 1
                    end

                    continue
                end

                if ElementInfo.Text and ElementInfo.Text:lower():match(Search) and ElementInfo.Visible then
                    ElementInfo.Holder.Visible = true
                    VisibleElements[SubTab] += 1
                else
                    ElementInfo.Holder.Visible = false
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                VisibleElements[SubTab] += CheckDepbox(Depbox, Search)
            end
        end

        for SubTab, Visible in VisibleElements do
            SubTab.ButtonHolder.Visible = Visible > 0
            if Visible > 0 then
                VisibleTabs += 1
                HasVisible = true

                if Tabbox.ActiveTab == SubTab then
                    SubTab:Resize()
                elseif Tabbox.ActiveTab and (VisibleElements[Tabbox.ActiveTab] or 0) == 0 then
                    SubTab:Show()
                end
            end
        end

        Tabbox.BoxHolder.Visible = VisibleTabs > 0
    end

    return HasVisible
end

local function ResetTab(Tab)
    if not Tab then
        return
    end

    for _, Groupbox in Tab.Groupboxes do
        for _, ElementInfo in Groupbox.Elements do
            ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

            if ElementInfo.SubButton then
                ElementInfo.Base.Visible = ElementInfo.Visible
                ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
            end
        end

        for _, Depbox in Groupbox.DependencyBoxes do
            if not Depbox.Visible then
                continue
            end

            RestoreDepbox(Depbox)
        end

        if Groupbox.Tabboxes then
            for _, Tabbox in Groupbox.Tabboxes do
                for _, SubTab in Tabbox.Tabs do
                    for _, ElementInfo in SubTab.Elements do
                        ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                        if ElementInfo.SubButton then
                            ElementInfo.Base.Visible = ElementInfo.Visible
                            ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                        end
                    end

                    for _, Depbox in SubTab.DependencyBoxes do
                        if not Depbox.Visible then
                            continue
                        end

                        RestoreDepbox(Depbox)
                    end

                    SubTab.ButtonHolder.Visible = true
                end

                if Tabbox.ActiveTab then
                    Tabbox.ActiveTab:Resize()
                end
                Tabbox.BoxHolder.Visible = true
            end
        end

        Groupbox:Resize()
        Groupbox.BoxHolder.Visible = Groupbox.Visible ~= false
    end

    for _, Tabbox in Tab.Tabboxes do
        for _, SubTab in Tabbox.Tabs do
            for _, ElementInfo in SubTab.Elements do
                ElementInfo.Holder.Visible = ElementInfo.Visible ~= false

                if ElementInfo.SubButton then
                    ElementInfo.Base.Visible = ElementInfo.Visible
                    ElementInfo.SubButton.Base.Visible = ElementInfo.SubButton.Visible
                end
            end

            for _, Depbox in SubTab.DependencyBoxes do
                if not Depbox.Visible then
                    continue
                end

                RestoreDepbox(Depbox)
            end

            SubTab.ButtonHolder.Visible = true
        end

        if Tabbox.ActiveTab then
            Tabbox.ActiveTab:Resize()
        end
        Tabbox.BoxHolder.Visible = true
    end
end

function Library:UpdateSearch(SearchText)
    Library.SearchText = SearchText

    local TabsToReset = {}

    if Library.GlobalSearch then
        for _, Tab in Library.Tabs do
            if typeof(Tab) == "table" and not Tab.IsKeyTab then
                table.insert(TabsToReset, Tab)
            end
        end
    elseif Library.LastSearchTab and typeof(Library.LastSearchTab) == "table" then
        table.insert(TabsToReset, Library.LastSearchTab)
    end

    for _, Tab in ipairs(TabsToReset) do
        ResetTab(Tab)
    end

    local Search = SearchText:lower()
    if Trim(Search) == "" then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end
    if not Library.GlobalSearch and Library.ActiveTab and Library.ActiveTab.IsKeyTab then
        Library.Searching = false
        Library.LastSearchTab = nil
        return
    end

    Library.Searching = true

    local TabsToSearch = {}

    if Library.GlobalSearch then
        TabsToSearch = TabsToReset
        if #TabsToSearch == 0 then
            for _, Tab in Library.Tabs do
                if typeof(Tab) == "table" and not Tab.IsKeyTab then
                    table.insert(TabsToSearch, Tab)
                end
            end
        end
    elseif Library.ActiveTab then
        table.insert(TabsToSearch, Library.ActiveTab)
    end

    local FirstVisibleTab = nil
    local ActiveHasVisible = false

    for _, Tab in ipairs(TabsToSearch) do
        local HasVisible = ApplySearchToTab(Tab, Search)
        if HasVisible then
            if not FirstVisibleTab then
                FirstVisibleTab = Tab
            end
            if Tab == Library.ActiveTab then
                ActiveHasVisible = true
            end
        end
    end

    if Library.GlobalSearch then
        if ActiveHasVisible and Library.ActiveTab then
            Library.ActiveTab:RefreshSides()
        elseif FirstVisibleTab then
            local SearchMarker = SearchText
            task.defer(function()
                if Library.SearchText ~= SearchMarker then
                    return
                end

                if Library.ActiveTab ~= FirstVisibleTab then
                    FirstVisibleTab:Show()
                end
            end)
        end
        Library.LastSearchTab = nil
    else
        Library.LastSearchTab = Library.ActiveTab
    end
end

function Library:AddToRegistry(Instance, Properties)
    Library.Registry[Instance] = Properties
end

function Library:RemoveFromRegistry(Instance)
    Library.Registry[Instance] = nil
end

function Library:UpdateColorsUsingRegistry()
    for Instance, Properties in Library.Registry do
        for Property, Index in Properties do
            local SchemeValue = GetSchemeValue(Index)

            if SchemeValue or typeof(Index) == "function" then
                Instance[Property] = SchemeValue or Index()
            end
        end
    end
end

function Library:SetDPIScale(DPIScale: number)
    Library.DPIScale = DPIScale / 100
    Library.MinSize = Library.OriginalMinSize * Library.DPIScale

	for _, UIScale in Library.Scales do
        UIScale.Scale = Library.DPIScale - (tonumber(Library.ScalesOffset[UIScale]) or 0)
    end

    for _, Option in Options do
        if Option.Type == "Dropdown" then
            Option:RecalculateListSize()
        end
    end

    for _, Notification in Library.Notifications do
        Notification:Resize()
    end

    Library:UpdateNotificationPositions(true)
end

function Library:GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
    local ConnectionType = typeof(Connection)
    if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
        table.insert(Library.Signals, Connection)
    end

    return Connection
end

function IsValidCustomIcon(Icon: string)
    return typeof(Icon) == "string" and (Icon:match("^rbxasset://textures/") or Icon:match("roblox%.com/asset/%?id=") or Icon:match("rbxthumb://type="))
end

local function IsCustomAssetIcon(Icon: string, IncludeAssetId: boolean)
	return typeof(Icon) == "string" and (Icon:match("^content://") or (Icon:match("^rbxasset://%x+/") or Icon:match("^rbxasset://[^/]+/")) or (IncludeAssetId == true and Icon:match("^rbxassetid://")))
end

type Icon = {
    Url: string,
    Id: number,
    IconName: string,
    ImageRectOffset: Vector2,
    ImageRectSize: Vector2,
}

type IconModule = {
    Icons: { string },
    GetAsset: (Name: string) -> Icon?,
}

local FetchIcons = false
local Icons: IconModule | nil = nil

function Library:GetIcon(n: string)
    if not FetchIcons or not Icons then return end
    local s, ic = pcall(Icons.GetAsset, n)
    if not s then return end
    return ic
end

function Library:GetCustomIcon(n: string): any
    if not n then return nil end
    if tonumber(n) then n = string.format("rbxassetid://%s", tostring(n)) end
    if IsCustomAssetIcon(n, true) then
        return { Url = n, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
    elseif IsValidCustomIcon(n) then
        return { Url = n, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero, Custom = true }
    end
    local li = Library:GetIcon(n)
    if li then return li end
    return nil
end

function Library:Validate(Table: { [string]: any }, Template: { [string]: any }): { [string]: any }
    if typeof(Table) ~= "table" then
        return Template
    end

    for k, v in Template do
        if typeof(k) == "number" then
            continue
        end

        if typeof(v) == "table" then
            Table[k] = Library:Validate(Table[k], v)
        elseif Table[k] == nil then
            Table[k] = v
        end
    end

    return Table
end

--// Creator Functions \\--
local function FillInstance(Table: { [string]: any }, Instance: GuiObject)
    local ThemeProperties = Library.Registry[Instance] or {}

    for key, value in Table do
        if key ~= "Text" then
            local SchemeValue = GetSchemeValue(value)

            if SchemeValue or typeof(value) == "function" then
                ThemeProperties[key] = value
                value = SchemeValue or value()
            else
                ThemeProperties[key] = nil
            end
        end

        Instance[key] = value
    end

    if GetTableSize(ThemeProperties) > 0 then
        Library.Registry[Instance] = ThemeProperties
    end
end

local function New(ClassName: string, Properties: { [string]: any }): any
    local Instance = Instance.new(ClassName)

    if Templates[ClassName] then
        FillInstance(Templates[ClassName], Instance)
    end
    FillInstance(Properties, Instance)

    if Properties["Parent"] and not Properties["ZIndex"] then
        pcall(function()
            Instance.ZIndex = Properties.Parent.ZIndex
        end)
    end

    return Instance
end

--// Main Instances \\-
local function SafeParentUI(Instance: Instance, Parent: Instance | () -> Instance)
    local success, _error = pcall(function()
        if not Parent then
            Parent = CoreGui
        end

        local DestinationParent
        if typeof(Parent) == "function" then
            DestinationParent = Parent()
        else
            DestinationParent = Parent
        end

        Instance.Parent = DestinationParent
    end)

    if not (success and Instance.Parent) then
        Instance.Parent = Library.LocalPlayer:WaitForChild("PlayerGui", math.huge)
    end
end

local function ParentUI(UI: Instance, SkipHiddenUI: boolean?)
    if SkipHiddenUI then
        SafeParentUI(UI, CoreGui)
        return
    end

    pcall(protectgui, UI)
    SafeParentUI(UI, gethui)
end

local function SetAlwaysOnTop(g: ScreenGui, en: boolean)
    if not g then return end
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(g, "OnTopOfCoreBlur", en)
        elseif setscriptable then
            setscriptable(g, "OnTopOfCoreBlur", true)
            g.OnTopOfCoreBlur = en
            setscriptable(g, "OnTopOfCoreBlur", false)
        end
    end)
end

local ScreenGui = New("ScreenGui", {
    Name = "Obsidian",
    DisplayOrder = 998,
    ResetOnSpawn = false,
})
ParentUI(ScreenGui)
Library.ScreenGui = ScreenGui

ScreenGui.DescendantRemoving:Connect(function(Instance)
    Library:RemoveFromRegistry(Instance)
end)

local ModalElement = New("TextButton", {
    BackgroundTransparency = 1,
    Modal = false,
    Size = UDim2.fromScale(0, 0),
    AnchorPoint = Vector2.zero,
    Text = "",
    ZIndex = -999,
    Parent = ScreenGui,
})

--// Cursor
local Cursor, CursorCustomImage
do
    Cursor = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Size = UDim2.fromOffset(9, 1),
        Visible = false,
        ZIndex = 11000,
        Parent = ScreenGui,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 10999,
        Parent = Cursor,
    })

    local CursorV = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "WhiteColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(1, 9),
        ZIndex = 11000,
        Parent = Cursor,
    })
    New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 2, 1, 2),
        ZIndex = 10999,
        Parent = CursorV,
    })

    CursorCustomImage = New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 11000,
        Visible = false,
        Parent = Cursor
    })
end

--// Notification \\--
local NotificationArea
local NotifyOrder = {}
do
    NotificationArea = New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -6, 0, 6),
        Size = UDim2.new(0, 300, 1, -6),
        Parent = ScreenGui,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = NotificationArea,
        })
    )
end

--// Lib Functions \\--
function Library:ResetCursorIcon()
    CursorCustomImage.Visible = false
    CursorCustomImage.Size = UDim2.fromOffset(20, 20)
end

function Library:ChangeCursorIcon(ImageId: string)
    if not ImageId or ImageId == "" then
        Library:ResetCursorIcon()
        return
    end

    local Icon = Library:GetCustomIcon(ImageId)
    assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

    CursorCustomImage.Visible = true
    CursorCustomImage.Image = Icon.Url
    CursorCustomImage.ImageRectOffset = Icon.ImageRectOffset
    CursorCustomImage.ImageRectSize = Icon.ImageRectSize
end

function Library:ChangeCursorIconSize(Size: UDim2)
    assert(typeof(Size) == "UDim2", "UDim2 expected.")
    CursorCustomImage.Size = Size
end

function Library:GetBetterColor(Color: Color3, Add: number): Color3
    Add = Add * (Library.IsLightTheme and -4 or 2)
    return Color3.fromRGB(
        math.clamp(Color.R * 255 + Add, 0, 255),
        math.clamp(Color.G * 255 + Add, 0, 255),
        math.clamp(Color.B * 255 + Add, 0, 255)
    )
end

function Library:GetLighterColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, math.max(0, S - 0.1), math.min(1, V + 0.1))
end

function Library:GetDarkerColor(Color: Color3): Color3
    local H, S, V = Color:ToHSV()
    return Color3.fromHSV(H, S, V / 2)
end

function Library:GetKeyString(KeyCode: Enum.KeyCode)
    if KeyCode.EnumType == Enum.KeyCode and KeyCode.Value > 33 and KeyCode.Value < 127 then
        return string.char(KeyCode.Value)
    end

    return KeyCode.Name
end

function Library:GetTextBounds(Text: string, Font: Font, Size: number, Width: number?): (number, number)
    local Params = Instance.new("GetTextBoundsParams")
    Params.Text = Text
    Params.RichText = true
    Params.Font = Font
    Params.Size = Size
    Params.Width = Width or workspace.CurrentCamera.ViewportSize.X - 32

    local Bounds = TextService:GetTextBoundsAsync(Params)
    return Bounds.X, Bounds.Y
end

function Library:MouseIsOverFrame(Frame: GuiObject, Mouse: Vector2): boolean
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize
    return Mouse.X >= AbsPos.X
        and Mouse.X <= AbsPos.X + AbsSize.X
        and Mouse.Y >= AbsPos.Y
        and Mouse.Y <= AbsPos.Y + AbsSize.Y
end

function Library:IsInsideFrame(ParentFrame: GuiObject, Frame: GuiObject)
    local GuiPos = Frame.AbsolutePosition
	local GuiSize = Frame.AbsoluteSize

	local FramePos = ParentFrame.AbsolutePosition
	local FrameSize = ParentFrame.AbsoluteSize

	return GuiPos.X >= FramePos.X
		and GuiPos.X + GuiSize.X <= FramePos.X + FrameSize.X
		and GuiPos.Y >= FramePos.Y
		and GuiPos.Y + GuiSize.Y <= FramePos.Y + FrameSize.Y
end

function Library:SafeCallback(Func: (...any) -> ...any, ...: any)
    if not (Func and typeof(Func) == "function") then
        return
    end

    local Result = table.pack(xpcall(Func, function(Error)
        task.defer(error, debug.traceback(Error, 2))
        if Library.NotifyOnError and Library.Notify then
            Library:Notify(Error)
        end

        return Error
    end, ...))

    if not Result[1] then
        return nil
    end

    return table.unpack(Result, 2, Result.n)
end

function GetOverlappingDraggable(UI: GuiObject, TargetPos: Vector2?)
    local Pos1 = TargetPos or UI.AbsolutePosition
    local Size1 = UI.AbsoluteSize
    
    for _, Other in ipairs(Library.DraggableElements) do
        if Other == UI or not Other.Visible or not Other.Parent then
            continue
        end

        local Pos2 = Other.AbsolutePosition
        local Size2 = Other.AbsoluteSize
        
        if Pos1.X < Pos2.X + Size2.X and
            Pos1.X + Size1.X > Pos2.X and
            Pos1.Y < Pos2.Y + Size2.Y and
            Pos1.Y + Size1.Y > Pos2.Y then
            return Other
        end
    end
    
    return nil
end

function GetNonOverlappingPosition(UI: GuiObject, StartPos: UDim2?)
    local ScreenSize = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)) - Vector2.new(100, 100)
    local Start = StartPos and Vector2.new(StartPos.X.Offset, StartPos.Y.Offset) or Vector2.new(6, 6)
    local Padding = 6
    
    local CurrentX = Start.X
    local CurrentY = Start.Y
    
    local Size = UI.AbsoluteSize
    if Size.X == 0 and Size.Y == 0 then
        RunService.RenderStepped:Wait()
        Size = UI.AbsoluteSize
    end
    
    if Size.X == 0 then Size = Vector2.new(150, 40) end

    local MaxXInColumn = Size.X

    while true do
        local Obstacle = GetOverlappingDraggable(UI, Vector2.new(CurrentX, CurrentY))
        if not Obstacle then
            break
        end
        
        if Obstacle.AbsoluteSize.X > MaxXInColumn then
            MaxXInColumn = Obstacle.AbsoluteSize.X
        end
        
        local NextY = Obstacle.AbsolutePosition.Y + Obstacle.AbsoluteSize.Y + Padding
        if NextY + Size.Y > ScreenSize.Y - Padding then
            local NextX = CurrentX + MaxXInColumn + Padding
            
            if NextX + Size.X > ScreenSize.X - Padding then
                break
            end
            
            CurrentY = Start.Y
            CurrentX = NextX
            MaxXInColumn = Size.X
        else
            CurrentY = NextY
        end
    end
    
    return UDim2.fromOffset(CurrentX, CurrentY)
end

function PositionDraggable(UI: GuiObject, StartPos: UDim2?)
    UI.Position = GetNonOverlappingPosition(UI, StartPos)
end

function Library:MakeDraggable(UI: GuiObject, DragFrame: GuiObject, IgnoreToggled: boolean?, IsMainWindow: boolean?)
    local StartPos
    local FramePos
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) or IsMainWindow and Library.CantDragForced then
            return
        end

        StartPos = Input.Position
        FramePos = UI.Position
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if
            (not IgnoreToggled and not Library.Toggled)
            or (IsMainWindow and Library.CantDragForced)
            or not (ScreenGui and ScreenGui.Parent)
        then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Position =
                UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)
    
    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeResizable(UI: GuiObject, DragFrame: GuiObject, Callback: () -> ()?)
    local StartPos
    local FrameSize
    local Dragging = false
    local Changed
    local InputBegan
    local InputChanged

    InputBegan = DragFrame.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end

        StartPos = Input.Position
        FrameSize = UI.Size
        Dragging = true

        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    InputChanged = UserInputService.InputChanged:Connect(function(Input: InputObject)
        if not UI.Visible or not (ScreenGui and ScreenGui.Parent) then
            Dragging = false
            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end

            return
        end

        if Dragging and IsHoverInput(Input) then
            local Delta = Input.Position - StartPos
            UI.Size = UDim2.new(
                FrameSize.X.Scale,
                math.clamp(FrameSize.X.Offset + Delta.X, Library.MinSize.X, math.huge),
                FrameSize.Y.Scale,
                math.clamp(FrameSize.Y.Offset + Delta.Y, Library.MinSize.Y, math.huge)
            )
            if Callback then
                Library:SafeCallback(Callback)
            end
        end
    end)

    Library:GiveSignal(InputChanged)
    Library:GiveSignal(InputBegan)

    UI.Destroying:Once(function()
        if InputChanged and InputChanged.Connected then
            InputChanged:Disconnect()
        end

        if InputBegan and InputBegan.Connected then
            InputBegan:Disconnect()
        end

        if Changed and Changed.Connected then
            Changed:Disconnect()
        end

        local IdxChanged = table.find(Library.Signals, InputChanged)
        if IdxChanged then
            table.remove(Library.Signals, IdxChanged)
        end

        local IdxBegan = table.find(Library.Signals, InputBegan)
        if IdxBegan then
            table.remove(Library.Signals, IdxBegan)
        end
    end)
end

function Library:MakeCover(Holder: GuiObject, Place: string)
    local Pos = Places[Place] or { 0, 0 }
    local Size = Sizes[Place] or { 1, 0.5 }

    local Cover = New("Frame", {
        AnchorPoint = Vector2.new(Pos[1], Pos[2]),
        BackgroundColor3 = Holder.BackgroundColor3,
        Position = UDim2.fromScale(Pos[1], Pos[2]),
        Size = UDim2.fromScale(Size[1], Size[2]),
        Parent = Holder,
    })

    return Cover
end

function Library:MakeLine(Frame: GuiObject, Info)
    local Line = New("Frame", {
        AnchorPoint = Info.AnchorPoint or Vector2.zero,
        BackgroundColor3 = "OutlineColor",
        Position = Info.Position,
        Size = Info.Size,
        ZIndex = Info.ZIndex or Frame.ZIndex,
        Parent = Frame,
    })

    return Line
end

function Library:AddOutline(Frame: GuiObject)
    local OutlineStroke = New("UIStroke", {
        Color = "OutlineColor",
        Thickness = 1,
        ZIndex = 2,
        Parent = Frame,
    })
    local ShadowStroke = New("UIStroke", {
        Color = "DarkColor",
        Thickness = 1.5,
        ZIndex = 1,
        Parent = Frame,
    })
    return OutlineStroke, ShadowStroke
end

function Library:AddBlank(Frame: GuiObject, Size: UDim2)
    return New("Frame", {
        BackgroundTransparency = 1,
        Size = Size or UDim2.fromScale(0, 0),
        Parent = Frame,
    })
end

--// Animations \\--
local TransparencyCache = {}
local ActiveTabTweens = setmetatable({}, { __mode = "k" })
local SUBTAB_BAR_HEIGHT = 32
local SUBTAB_IDLE_TRANSPARENCY = 0.4
local SUBTAB_ICON_SIZE = 16
local SUBTAB_SLIDE_TWEEN = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SUBTAB_UNDERLINE_WIDTH = 0.66
local SUBTAB_UNDERLINE_GAP = 3
local SUBTAB_SHADOW_TRANSPARENCY = { 0.55, 0.75 }
local SUBTAB_HOVER_SCALE = 0.94
local SUBTAB_HOVER_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local SUBTAB_SIDEBAR_INDENT = 30
local SUBTAB_SIDEBAR_ICON_COLUMN = 20

local DROPDOWN_EXPAND_TWEEN = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local SLIDER_BAR_HEIGHT = 16
local SLIDER_BALL_SIZE = 18
local SLIDER_BALL_SIZE_ACTIVE = 24
local SLIDER_BALL_TWEEN = TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local SLIDER_BALL_MARGIN = math.ceil((SLIDER_BALL_SIZE_ACTIVE - SLIDER_BAR_HEIGHT) / 2)
local SLIDER_TRACK_GRADIENT_FROM = Color3.fromRGB(138, 138, 138)
local SLIDER_TRACK_GRADIENT_TO = Color3.fromRGB(64, 64, 64)

local SEARCHBOX_TEXT_INSET = 38

function Library:PlayTabAnimation(TabCanvas: CanvasGroup, Showing: boolean, OnComplete: (() -> ())?)
    if not TabCanvas then
        if OnComplete then
            OnComplete()
        end

        return
    end

    local Existing = ActiveTabTweens[TabCanvas]
    if Existing then
        StopTween(Existing, true)
        ActiveTabTweens[TabCanvas] = nil
    end

    local BaseZIndex = TabCanvas.ZIndex
    if not (Library.Animations and Library.Animations.TabSwitch) then
        TabCanvas.Visible = Showing
        TabCanvas.GroupTransparency = Showing and 0 or 1
        TabCanvas.Position = UDim2.fromScale(0, 0)
        TabCanvas.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end

        return
    end

    if Showing then
        local TweenInfo = Library.TabTransitionInfo or TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local Offset = Library.TabSwipeOffset or 26
        local SwipeFrom = string.lower(Library.TabSwipeFrom or "bottom")
        local StartPosition

        if SwipeFrom == "left" then
            StartPosition = UDim2.fromOffset(-Offset, 0)
        elseif SwipeFrom == "top" then
            StartPosition = UDim2.fromOffset(0, -Offset)
        elseif SwipeFrom == "right" then
            StartPosition = UDim2.fromOffset(Offset, 0)
        else -- bottom (Default)
            StartPosition = UDim2.fromOffset(0, Offset)
        end

        TabCanvas.ZIndex = BaseZIndex + 1
        TabCanvas.GroupTransparency = 1
        TabCanvas.Position = StartPosition
        TabCanvas.Visible = true

        local Tween = TweenService:Create(TabCanvas, TweenInfo, {
            GroupTransparency = 0,
            Position = UDim2.fromScale(0, 0)
        })

        ActiveTabTweens[TabCanvas] = Tween
        Tween:Play()

        local Connection; Connection = Tween.Completed:Connect(function(PlaybackState)
            if Connection then
                Connection:Disconnect()
            end

            if ActiveTabTweens[TabCanvas] == Tween then
                ActiveTabTweens[TabCanvas] = nil
            end

            if PlaybackState == Enum.PlaybackState.Cancelled then
                return
            end

            TabCanvas.ZIndex = BaseZIndex
            if OnComplete then
                OnComplete()
            end
        end)
    else
        TabCanvas.GroupTransparency = 1
        TabCanvas.Visible = false
        TabCanvas.Position = UDim2.fromScale(0, 0)
        TabCanvas.ZIndex = BaseZIndex

        if OnComplete then
            OnComplete()
        end
    end
end

--// Deprecated \\--
function Library:MakeOutline(Frame: GuiObject, Corner: number?, ZIndex: number?)
    warn("Obsidian:MakeOutline is deprecated, please use Obsidian:AddOutline instead.")
    local Holder = New("Frame", {
        BackgroundColor3 = "DarkColor",
        Position = UDim2.fromOffset(-2, -2),
        Size = UDim2.new(1, 4, 1, 4),
        ZIndex = ZIndex,
        Parent = Frame,
    })

    local Outline = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        ZIndex = ZIndex,
        Parent = Holder,
    })

    if Corner and Corner > 0 then
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner + 1),
            Parent = Holder,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Corner),
            Parent = Outline,
        })
    end

    return Holder, Outline
end

function Library:AddDraggableLabel(...)
    local Params = select(1, ...)
    local Text
    local Icon
    local IconPosition = "left"

    if typeof(Params) == "table" then
        Text = Params.Text
        Icon = Params.Icon
        IconPosition = Params.IconPosition or "left"
    elseif typeof(Params) == "string" then
        Text = Params
        Icon = select(2, ...)
        IconPosition = select(3, ...) or "left"
    end

    if typeof(IconPosition) ~= "string" then
        IconPosition = "left"
    end

    IconPosition = string.lower(IconPosition)
    assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

    local DraggableLabel = {
        Connections = {},
        Destroyed = false
    }

    local IconImage
    local Label = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Size = UDim2.fromOffset(0, 0),
        Position = UDim2.fromOffset(6, 6),
        Text = Text,
        TextSize = 15,
        ZIndex = 10,
        Parent = ScreenGui,
    })

    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Label,
        })
    )

    local Padding = New("UIPadding", {
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 6),
        Parent = Label,
    })
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Label,
        })
    )

    Library:AddOutline(Label)
    Library:MakeDraggable(Label, Label, true)

    function DraggableLabel:SetText(Text: string)
        Label.Text = Text
    end

    function DraggableLabel:SetIcon(NewIcon: string)
        Icon = NewIcon

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        if IsNotEmpty then
            local CustomIcon = Library:GetCustomIcon(Icon)
            assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            IconImage = IconImage or New("ImageLabel", {
                BackgroundTransparency = 1,
                ImageColor3 = "FontColor",
                Size = UDim2.fromOffset(16, 16),
                ZIndex = 11,
                Parent = Label,
            })

            IconImage.Image = CustomIcon.Url
            IconImage.ImageRectOffset = CustomIcon.ImageRectOffset
            IconImage.ImageRectSize = CustomIcon.ImageRectSize
        end

        if IconImage then IconImage.Visible = IsNotEmpty end
        DraggableLabel:SetIconPosition(IconPosition)
    end

    function DraggableLabel:SetIconPosition(NewPosition: string)
        IconPosition = string.lower(NewPosition)
        assert(IconPosition == "left" or IconPosition == "right", "Icon Position needs to be either 'left' or 'right'.")

        local IsNotEmpty = Icon and Trim(tostring(Icon)) ~= ""
        Padding.PaddingLeft = UDim.new(0, (IsNotEmpty and IconPosition == "left") and 34 or 12)
        Padding.PaddingRight = UDim.new(0, (IsNotEmpty and IconPosition == "right") and 34 or 12)

        if IconImage then
            if IconPosition == "left" then
                IconImage.AnchorPoint = Vector2.new(0, 0.5)
                IconImage.Position = UDim2.new(0, -22, 0.5, 0)
            else
                IconImage.AnchorPoint = Vector2.new(1, 0.5)
                IconImage.Position = UDim2.new(1, 22, 0.5, 0)
            end
        end
    end

    function DraggableLabel:SetVisible(Visible: boolean)
        Label.Visible = Visible
    end
    
    DraggableLabel:SetIcon(Icon)
    DraggableLabel.Label = Label

    if not table.find(Library.DraggableElements, Label) then
        table.insert(Library.DraggableElements, Label)
    end

    PositionDraggable(Label, Label.Position)

    function DraggableLabel:Destroy()
        DraggableLabel.Destroyed = true

        if DraggableLabel.Connections then
            for _, connection in DraggableLabel.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Label)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Label then
            Label:Destroy()
        end
    end

    return DraggableLabel
end

function Library:AddDraggableButton(...)
    local Params = select(1, ...)

    local Text
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Text = Params.Text
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" then
        Text = Params
        Func = select(2, ...)
        ExcludeScaling = select(3, ...)
        ExcludeDragging = select(4, ...)
    end

    local DraggableButton = {
        Connections = {},
        Destroyed = false
    }

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        TextSize = 16,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local DragThreshold = if ExcludeDragging then 0.25 else math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end
        
        local Start = tick()

        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            local IsLikelyDragging = tick() - Start > DragThreshold
            if IsLikelyDragging then
                return
            end

            Library:SafeCallback(Func, DraggableButton)

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableButton:SetText(Text: string)
        local X, Y = Library:GetTextBounds(Text, Library.Scheme.Font, 16)

        Button.Text = Text
        Button.Size = UDim2.fromOffset(X * 2, Y * 2)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableButton:SetText(Text)
    DraggableButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    function DraggableButton:Destroy()
        DraggableButton.Destroyed = true

        if DraggableButton.Connections then
            for _, connection in DraggableButton.Connections do
                connection:Disconnect()
            end
        end

        local ElemIdx = table.find(Library.DraggableElements, Button)
        if ElemIdx then
            table.remove(Library.DraggableElements, ElemIdx)
        end

        if Button then
            Button:Destroy()
        end
    end

    return DraggableButton
end

function Library:AddDraggableMenu(Name: string)
    local Holder = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(0, 0),
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = Name,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = Label,
    })

    local Container = New("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 35),
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 7),
        Parent = Container,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 7),
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        Parent = Container,
    })

    Library:MakeDraggable(Holder, Label, true)

    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    PositionDraggable(Holder, Holder.Position)

    return Holder, Container
end

function Library:AddDraggableImageButton(...)
    local Params = select(1, ...)

    local Icon
    local IconSize
    local Func
    local ExcludeScaling
    local ExcludeDragging

    if typeof(Params) == "table" then
        Icon = Params.Icon
        IconSize = Params.IconSize or 24
        Func = Params.Callback or Params.Func
        ExcludeScaling = Params.ExcludeScaling
        ExcludeDragging = Params.ExcludeDragging
    elseif typeof(Params) == "string" or typeof(Params) == "number" then
        Icon = Params
        IconSize = select(2, ...)
        Func = select(3, ...)
        ExcludeScaling = select(4, ...)
        ExcludeDragging = select(5, ...)
    end

    local DraggableImageButton = {}

    local Button = New("TextButton", {
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.fromOffset(6, 6),
        Size = UDim2.fromOffset(IconSize + 12, IconSize + 12),
        Text = "",
        ZIndex = 10,
        Parent = ScreenGui,
    })
    
    local IconImage = New("ImageLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(IconSize, IconSize),
        ImageColor3 = "FontColor",
        ZIndex = 11,
        Parent = Button,
    })

    table.insert(
        Library.Corners, 
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Button,
        })
    )
    if not ExcludeScaling then
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = Button,
            })
        )
    end
    Library:AddOutline(Button)

    local DragThreshold = if ExcludeDragging then 0.25 else math.huge
    Button.InputBegan:Connect(function(Input: InputObject)
        if not IsClickInput(Input) then
            return
        end
        
        local Start = tick()

        local Changed
        Changed = Input.Changed:Connect(function()
            if Input.UserInputState ~= Enum.UserInputState.End then
                return
            end

            local IsLikelyDragging = tick() - Start > DragThreshold
            if IsLikelyDragging then
                return
            end

            Library:SafeCallback(Func, DraggableImageButton)

            if Changed and Changed.Connected then
                Changed:Disconnect()
                Changed = nil
            end
        end)
    end)

    function DraggableImageButton:SetIcon(NewIcon: string)
        Icon = NewIcon or Icon
        
        local CustomIcon = Library:GetCustomIcon(Icon)
        assert(CustomIcon, "Icon must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        IconImage.Image = CustomIcon.Url
        IconImage.ImageRectOffset = CustomIcon.ImageRectOffset
        IconImage.ImageRectSize = CustomIcon.ImageRectSize
    end

    function DraggableImageButton:SetIconSize(NewSize: number)
        IconSize = NewSize
        IconImage.Size = UDim2.fromOffset(IconSize, IconSize)
        Button.Size = UDim2.fromOffset(IconSize + 12, IconSize + 12)
    end

    Library:MakeDraggable(Button, Button, true)
    DraggableImageButton:SetIcon(Icon)
    DraggableImageButton.Button = Button

    if not table.find(Library.DraggableElements, Button) then
        table.insert(Library.DraggableElements, Button)
    end

    PositionDraggable(Button, Button.Position)

    return DraggableImageButton
end

--// Watermark - Deprecated \\--
do
    local WatermarkLabel = Library:AddDraggableLabel("")
    WatermarkLabel:SetVisible(false)

    function Library:SetWatermark(Text: string)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetText(Text)
    end

    function Library:SetWatermarkVisibility(Visible: boolean)
        warn("Watermark is deprecated, please use Library:AddDraggableLabel instead.")
        WatermarkLabel:SetVisible(Visible)
    end
end

--// Context Menu \\--
local CurrentMenu
function Library:AddContextMenu(
    h: GuiObject,
    sz: UDim2 | () -> (),
    off: { [number]: number } | () -> {},
    lst: number?,
    cb: (boolean) -> ()?,
    noCr: boolean?,
    spCr: ("top" | "bottom" | "no_left" | "no_top_left")?,
    anim: ("Dropdown" | "KeyPicker" | "none")?
)
    local m
    local pG = h:FindFirstAncestorOfClass("ScreenGui")
    local mZ = math.max(10, h.ZIndex + 1)
    if pG ~= ScreenGui and (Library.ActiveLoading and pG ~= Library.ActiveLoading.ScreenGui) then
        pG = ScreenGui
    end

    if lst then
        m = New("ScrollingFrame", {
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            AutomaticSize = lst == 1 and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
            BackgroundColor3 = "BackgroundColor",
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            CanvasSize = UDim2.fromOffset(0, 0),
            ScrollBarImageColor3 = "OutlineColor",
            ScrollBarThickness = lst == 2 and 2 or 0,
            Size = typeof(sz) == "function" and sz() or sz,
            TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            Visible = false,
            ZIndex = mZ,
            Parent = pG,
        })
    else
        m = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            Size = typeof(sz) == "function" and sz() or sz,
            Visible = false,
            ZIndex = mZ,
            Parent = pG,
        })
    end

    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = m,
        })
    )

    New("UIStroke", {
        Color = "OutlineColor",
        Parent = m,
    })

    local c
    if noCr ~= true then
        local r = Library.CornerRadius / 2
        if spCr == "top" then
            c = New("UICorner", {
                TopLeftRadius = UDim.new(0, r),
                TopRightRadius = UDim.new(0, r),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = m,
            }); table.insert(Library.SpecificCorners, c)
        elseif spCr == "bottom" then
            c = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, r),
                BottomLeftRadius = UDim.new(0, r),
                Parent = m,
            }); table.insert(Library.SpecificCorners, c)
        elseif spCr == "no_left" then
            c = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, r),
                BottomRightRadius = UDim.new(0, r),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = m,
            }); table.insert(Library.SpecificCorners, c)
        elseif spCr == "no_top_left" then
            c = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, r),
                BottomRightRadius = UDim.new(0, r),
                BottomLeftRadius = UDim.new(0, r),
                Parent = m,
            }); table.insert(Library.SpecificCorners, c)
        else
            c = New("UICorner", {
                CornerRadius = UDim.new(0, r),
                Parent = m,
            }); table.insert(Library.Corners, c)
        end
    end

    local t = {
        Connections = {},
        Destroyed = false,
        Active = false,
        Holder = h,
        Menu = m,
        List = nil,
        Signal = nil,
        Size = sz,
        AutoSizeY = lst == 1,
        OpenCloseTween = nil,
        Animated = function()
            if not anim or anim == "none" then return false end
            if not (Library.Animations and Library.Animations[anim] == true) then return false end
            return true, Library[string.format("%sTransitionInfo", anim)] or TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        end
    }

    if lst == 1 then
        t.List = New("UIListLayout", {
            Parent = m,
        })
    end

    function t:Open()
        if CurrentMenu == t then
            return
        elseif CurrentMenu then
            CurrentMenu:Close()
        end

        CurrentMenu = t
        t.Active = true

        local oPos = typeof(off) == "function" and off() or off
        m.Position = UDim2.fromOffset(
            math.floor(h.AbsolutePosition.X + oPos[1]),
            math.floor(h.AbsolutePosition.Y + oPos[2])
        )

        local tSz = typeof(t.Size) == "function" and t.Size() or t.Size

        if typeof(cb) == "function" then
            Library:SafeCallback(cb, true)
        end

        if t.OpenCloseTween then
            StopTween(t.OpenCloseTween, true)
            t.OpenCloseTween = nil
        end

        local isA, ti = t.Animated()
        if isA == true then
            local oSz = tSz
            if t.AutoSizeY then
                local fH = m.AbsoluteSize.Y
                m.AutomaticSize = Enum.AutomaticSize.None
                oSz = UDim2.new(tSz.X.Scale, tSz.X.Offset, 0, fH)
            end

            m.Size = UDim2.new(oSz.X.Scale, oSz.X.Offset, 0, 0)
            m.Visible = true

            local tw = TweenService:Create(m, ti, { Size = oSz })
            t.OpenCloseTween = tw

            local conn; conn = Library:GiveSignal(tw.Completed:Once(function()
                if conn then conn:Disconnect() end
                if t.OpenCloseTween == tw then
                    StopTween(t.OpenCloseTween, true)
                    t.OpenCloseTween = nil
                    if t.AutoSizeY then
                        m.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            tw:Play()
        else
            m.Size = tSz
            m.Visible = true
        end

        t.Signal = h:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            local cPos = typeof(off) == "function" and off() or off
            m.Position = UDim2.fromOffset(
                math.floor(h.AbsolutePosition.X + cPos[1]),
                math.floor(h.AbsolutePosition.Y + cPos[2])
            )

            if not Library:IsInsideFrame(Library.WindowContainer, h) and t.Active then
                t:Close()
            end
        end)
    end

    function t:Close()
        if CurrentMenu ~= t then return end

        if t.Signal then
            t.Signal:Disconnect()
            t.Signal = nil
        end

        t.Active = false
        CurrentMenu = nil

        if typeof(cb) == "function" then
            Library:SafeCallback(cb, false)
        end

        if t.OpenCloseTween then
            StopTween(t.OpenCloseTween, true)
            t.OpenCloseTween = nil
        end

        local isA, ti = t.Animated()
        if isA == true then
            if t.AutoSizeY then
                m.AutomaticSize = Enum.AutomaticSize.None
            end

            local curSz = m.Size
            local clpSz = UDim2.new(curSz.X.Scale, curSz.X.Offset, 0, 0)

            local tw = TweenService:Create(m, ti, { Size = clpSz })
            t.OpenCloseTween = tw

            local conn; conn = Library:GiveSignal(tw.Completed:Once(function()
                if conn then conn:Disconnect() end
                if t.OpenCloseTween == tw then
                    StopTween(t.OpenCloseTween, true)
                    t.OpenCloseTween = nil
                    m.Visible = false
                    if t.AutoSizeY then
                        m.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end
            end))

            tw:Play()
        else
            m.Visible = false
        end
    end

    function t:Toggle()
        if t.Active then t:Close() else t:Open() end
    end

    function t:SetSize(s)
        t.Size = s
        m.Size = typeof(s) == "function" and s() or s
    end

    function t:Destroy()
        t.Destroyed = true

        if t.Connections then
            for _, cn in t.Connections do cn:Disconnect() end
        end

        if CurrentMenu == t then
            t:Close()
        end

        if t.OpenCloseTween then
            StopTween(t.OpenCloseTween, true)
            t.OpenCloseTween = nil
        end

        if m then
            m:Destroy()
        end
    end

    return t
end

Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
    if Library.Unloaded then
        return
    end

    if IsClickInput(Input, true) then
        local Location = Input.Position

        if
            CurrentMenu
            and not (
                Library:MouseIsOverFrame(CurrentMenu.Menu, Location)
                or Library:MouseIsOverFrame(CurrentMenu.Holder, Location)
            )
        then
            CurrentMenu:Close()
        end
    end
end))

--// Tooltip \\--
local TooltipLabel = New("TextLabel", {
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundColor3 = "BackgroundColor",
    TextSize = 14,
    TextWrapped = true,
    Visible = false,
    ZIndex = 20,
    Parent = ScreenGui,
})
New("UIPadding", {
    PaddingBottom = UDim.new(0, 2),
    PaddingLeft = UDim.new(0, 4),
    PaddingRight = UDim.new(0, 4),
    PaddingTop = UDim.new(0, 2),
    Parent = TooltipLabel,
})
table.insert(
    Library.Scales,
    New("UIScale", {
        Parent = TooltipLabel,
    })
)
New("UIStroke", {
    Color = "OutlineColor",
    Parent = TooltipLabel,
})
table.insert(
    Library.Corners,
    New("UICorner", {
        CornerRadius = UDim.new(0, Library.CornerRadius / 2),
        Parent = TooltipLabel,
    })
)
TooltipLabel:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
    if Library.Unloaded then
        return
    end

    local X, _ = Library:GetTextBounds(
        TooltipLabel.Text,
        TooltipLabel.FontFace,
        TooltipLabel.TextSize,
        (workspace.CurrentCamera.ViewportSize.X - TooltipLabel.AbsolutePosition.X - 8) / Library.DPIScale
    )

    TooltipLabel.Size = UDim2.fromOffset(X + 8, 0)
end)

local CurrentHoverInstance
function Library:AddTooltip(InfoStr: string, DisabledInfoStr: string, HoverInstance: GuiObject)
    local TooltipTable = {
        Disabled = false,
        Hovering = false,
        Signals = {},
    }

    local function DoHover()
        if
            CurrentHoverInstance == HoverInstance
            or Library.ActiveDialog
            or (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
            or (TooltipTable.Disabled and typeof(DisabledInfoStr) ~= "string")
            or (not TooltipTable.Disabled and typeof(InfoStr) ~= "string")
        then
            return
        end
        CurrentHoverInstance = HoverInstance

        local ParentGui = HoverInstance:FindFirstAncestorOfClass("ScreenGui")
        if ParentGui ~= ScreenGui and (Library.ActiveLoading and ParentGui ~= Library.ActiveLoading.ScreenGui) then
            ParentGui = ScreenGui
        end
        TooltipLabel.Parent = ParentGui

        TooltipLabel.Text = TooltipTable.Disabled and DisabledInfoStr or InfoStr
        TooltipLabel.Visible = true

        while
            (Library.Toggled or Library.ActiveLoading)
            and not Library.ActiveDialog
            and Library:MouseIsOverFrame(HoverInstance, Mouse)
            and not (CurrentMenu and Library:MouseIsOverFrame(CurrentMenu.Menu, Mouse))
        do
            local Camera = workspace.CurrentCamera
            local ViewportSize = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
            
            local TooltipWidth = TooltipLabel.AbsoluteSize.X
            local TooltipHeight = TooltipLabel.AbsoluteSize.Y
            
            local TargetX = Mouse.X + (Library.ShowCustomCursor and 8 or 14)
            local TargetY = Mouse.Y + (Library.ShowCustomCursor and 8 or 12)
            
            if TargetX + TooltipWidth > ViewportSize.X then
                TargetX = Mouse.X - TooltipWidth - (Library.ShowCustomCursor and 8 or 14)
            end
            
            if TargetY + TooltipHeight > ViewportSize.Y then
                TargetY = Mouse.Y - TooltipHeight - (Library.ShowCustomCursor and 8 or 12)
            end
            
            TargetX = math.max(4, TargetX)
            TargetY = math.max(4, TargetY)

            TooltipLabel.Position = UDim2.fromOffset(TargetX, TargetY)

            RunService.RenderStepped:Wait()
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end

    local function GiveSignal(Connection: RBXScriptConnection | RBXScriptSignal)
        local ConnectionType = typeof(Connection)
        if Connection and (ConnectionType == "RBXScriptConnection" or ConnectionType == "RBXScriptSignal") then
            table.insert(TooltipTable.Signals, Connection)
        end

        return Connection
    end

    GiveSignal(HoverInstance.MouseEnter:Connect(DoHover))
    GiveSignal(HoverInstance.MouseMoved:Connect(DoHover))
    GiveSignal(HoverInstance.MouseLeave:Connect(function()
        if CurrentHoverInstance ~= HoverInstance then
            return
        end

        TooltipLabel.Visible = false
        CurrentHoverInstance = nil
    end))

    function TooltipTable:Destroy()
        for Index = #TooltipTable.Signals, 1, -1 do
            local Connection = table.remove(TooltipTable.Signals, Index)
            if Connection and Connection.Connected then
                Connection:Disconnect()
            end
        end

        if CurrentHoverInstance == HoverInstance then
            if TooltipLabel then
                TooltipLabel.Visible = false
            end

            CurrentHoverInstance = nil
        end
    end

    table.insert(Tooltips, TooltipLabel)
    return TooltipTable
end

function Library:OnUnload(Callback)
    table.insert(Library.UnloadSignals, Callback)
end

local CheckIcon, ArrowIcon, ResizeIcon, KeyIcon, MoveIcon
function Library:SetIconModule(m: IconModule)
    FetchIcons = true
    Icons = m
    CheckIcon = Library:GetIcon("check")
    ArrowIcon = Library:GetIcon("chevron-up")
    ResizeIcon = Library:GetIcon("move-diagonal-2")
    KeyIcon = Library:GetIcon("key")
    MoveIcon = Library:GetIcon("move")
end

local oFI, oI = pcall(function()
    return (loadstring(
        game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua")
    ) :: () -> IconModule)()
end)
if oFI and oI then
    Library:SetIconModule(oI)
end

local BaseAddons = {}
do
    local Funcs = {}

    function Funcs:AddKeyPicker(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.KeyPicker)

        local ParentObj = self
        local ToggleLabel = ParentObj.TextLabel

        if ParentObj.Type == "Button" or ParentObj.Type == "SubButton" then
            assert(Info.Mode == "Press", "KeyPicker on Buttons can only be applied with the 'Press' mode.")

            ToggleLabel = ParentObj.Base
        end

        local KeyPicker = {
            Connections = {},

            Text = Info.Text,
            Value = Info.Default, -- Key
            Modifiers = Info.DefaultModifiers, -- Modifiers
            DisplayValue = Info.Default, -- Picker Text

            Blacklisted = Info.Blacklisted,
            BlacklistedModifiers = Info.BlacklistedModifiers,
            Whitelisted = Info.Whitelisted,
            WhitelistedModifiers = Info.WhitelistedModifiers,

            Toggled = false,
            Mode = Info.Mode,
            SyncToggleState = Info.SyncToggleState,

            Callback = Info.Callback,
            ChangedCallback = Info.ChangedCallback,
            Changed = Info.Changed,
            Clicked = Info.Clicked,

            Type = "KeyPicker",
        }

        if KeyPicker.Mode == "Press" then
            assert(ParentObj.Type == "Label" or ParentObj.Type == "Button" or ParentObj.Type == "SubButton", "KeyPicker with the mode 'Press' can be only applied on Labels and Buttons.")

            KeyPicker.SyncToggleState = false
            Info.Modes = { "Press" }
            Info.Mode = "Press"
        end

        if KeyPicker.SyncToggleState then
            Info.Modes = { "Toggle", "Hold" }

            if not table.find(Info.Modes, Info.Mode) then
                Info.Mode = "Toggle"
            end
        end

        local Picking = false
        local IsForButton = ParentObj.Type == "Button" or ParentObj.Type == "SubButton"

        -- Special Keys
        local SpecialKeys = {
            ["MB1"] = Enum.UserInputType.MouseButton1,
            ["MB2"] = Enum.UserInputType.MouseButton2,
            ["MB3"] = Enum.UserInputType.MouseButton3,
        }

        local SpecialKeysInput = {
            [Enum.UserInputType.MouseButton1] = "MB1",
            [Enum.UserInputType.MouseButton2] = "MB2",
            [Enum.UserInputType.MouseButton3] = "MB3",
        }

        -- Modifiers
        local Modifiers = {
            ["LAlt"] = Enum.KeyCode.LeftAlt,
            ["RAlt"] = Enum.KeyCode.RightAlt,

            ["LCtrl"] = Enum.KeyCode.LeftControl,
            ["RCtrl"] = Enum.KeyCode.RightControl,

            ["LShift"] = Enum.KeyCode.LeftShift,
            ["RShift"] = Enum.KeyCode.RightShift,

            ["Tab"] = Enum.KeyCode.Tab,
            ["CapsLock"] = Enum.KeyCode.CapsLock,
        }

        local ModifiersInput = {
            [Enum.KeyCode.LeftAlt] = "LAlt",
            [Enum.KeyCode.RightAlt] = "RAlt",

            [Enum.KeyCode.LeftControl] = "LCtrl",
            [Enum.KeyCode.RightControl] = "RCtrl",

            [Enum.KeyCode.LeftShift] = "LShift",
            [Enum.KeyCode.RightShift] = "RShift",

            [Enum.KeyCode.Tab] = "Tab",
            [Enum.KeyCode.CapsLock] = "CapsLock",
        }

        local IsModifierInput = function(Input)
            return Input.UserInputType == Enum.UserInputType.Keyboard and ModifiersInput[Input.KeyCode] ~= nil
        end

        local GetActiveModifiers = function()
            local ActiveModifiers = {}

            for Name, Input in Modifiers do
                if table.find(ActiveModifiers, Name) then
                    continue
                end
                if not UserInputService:IsKeyDown(Input) then
                    continue
                end

                table.insert(ActiveModifiers, Name)
            end

            return ActiveModifiers
        end

        local AreModifiersHeld = function(Required)
            if not (typeof(Required) == "table" and GetTableSize(Required) > 0) then
                return true
            end

            local ActiveModifiers = GetActiveModifiers()
            local Holding = true

            for _, Name in Required do
                if table.find(ActiveModifiers, Name) then
                    continue
                end

                Holding = false
                break
            end

            return Holding
        end

        local IsInputDown = function(Input)
            if not Input then
                return false
            end

            if SpecialKeysInput[Input.UserInputType] ~= nil then
                return UserInputService:IsMouseButtonPressed(Input.UserInputType)
                    and not UserInputService:GetFocusedTextBox()
            elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                return UserInputService:IsKeyDown(Input.KeyCode) and not UserInputService:GetFocusedTextBox()
            else
                return false
            end
        end

        local ConvertToInputModifiers = function(CurrentModifiers)
            local InputModifiers = {}

            for _, name in CurrentModifiers do
                table.insert(InputModifiers, Modifiers[name])
            end

            return InputModifiers
        end

        local VerifyModifiers = function(CurrentModifiers)
            if typeof(CurrentModifiers) ~= "table" then
                return {}
            end

            local ValidModifiers = {}

            for _, name in CurrentModifiers do
                if not Modifiers[name] then
                    continue
                end

                table.insert(ValidModifiers, name)
            end

            return ValidModifiers
        end

        KeyPicker.Modifiers = VerifyModifiers(KeyPicker.Modifiers)

        local SlideOverflow = true
        local MaxPickerWidth = 75
        local SlidingLabel

        local LastPickerWidth = 0
        local SlideForwardTween
        local SlideBackTween
        local HandleForwardTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideBackTween then
                SlideBackTween:Play()
            end
        end

        local HandleBackTween = function(State)
            if State ~= Enum.PlaybackState.Completed then
                return
            end

            task.wait(1.5)
            if SlideForwardTween then
                SlideForwardTween:Play()
            end
        end

        local CancelSlidingTweens = function()
            if SlideForwardTween then
                StopTween(SlideForwardTween, true)
                SlideForwardTween = nil
            end

            if SlideBackTween then
                SlideForwardTween(SlideBackTween, true)
                SlideBackTween = nil
            end
        end

        local Picker = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromOffset(18, 18),
            Text = (IsForButton and SlideOverflow) and "" or KeyPicker.Value,
            TextSize = 14,
            Parent = ToggleLabel,
        })

        if IsForButton and SlideOverflow then
            Picker.ClipsDescendants = true

            SlidingLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = KeyPicker.Value,
                TextSize = 14,
                FontFace = Picker.FontFace,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = Picker,
            })

            Library:AddToRegistry(SlidingLabel, {
                TextColor3 = "FontColor",
            })
        end

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Picker,
        })

        local PickerCorner = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = Picker,
        }); table.insert(Library.SpecificCorners, PickerCorner)

        if IsForButton then
            local Holder = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Parent = ToggleLabel.Parent,
            })

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDim.new(0, 9),
                Parent = Holder,
            })

            ToggleLabel.Parent = Holder
            Picker.Parent = Holder

            Picker.Size = UDim2.new(0, 18, 1, 0)
        end

        local KeybindsToggle = { Normal = KeyPicker.Mode ~= "Toggle" }
        do
            local Holder = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 16),
                Text = "",
                Visible = not Info.NoUI,
                Parent = Library.KeybindContainer,
            })

            local Label = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(0, 1),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = Holder,
            })

            local Checkbox = New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(14, 14),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = Holder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Checkbox,
                })
            )
            New("UIStroke", {
                Color = "OutlineColor",
                Parent = Checkbox,
            })

            local CheckImage = New("ImageLabel", {
                Image = CheckIcon and CheckIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
                ImageTransparency = 1,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = Checkbox,
            })

            function KeybindsToggle:Display(State)
                Label.TextTransparency = State and 0 or 0.5
                CheckImage.ImageTransparency = State and 0 or 1
            end

            function KeybindsToggle:SetText(Text)
                Label.Text = Text
            end

            function KeybindsToggle:SetVisibility(Visibility)
                Holder.Visible = Visibility
            end

            function KeybindsToggle:SetNormal(Normal)
                KeybindsToggle.Normal = Normal

                Holder.Active = not Normal
                Label.Position = Normal and UDim2.fromOffset(0, 0) or UDim2.fromOffset(22, 0)
                Checkbox.Visible = not Normal
            end

            KeyPicker.DoClick = function(...) end --// make luau lsp shut up
            Holder.MouseButton1Click:Connect(function()
                if KeybindsToggle.Normal then
                    return
                end

                KeyPicker.Toggled = not KeyPicker.Toggled
                KeyPicker:DoClick()
            end)

            KeybindsToggle.Holder = Holder
            KeybindsToggle.Label = Label
            KeybindsToggle.Checkbox = Checkbox
            KeybindsToggle.Loaded = true
            table.insert(Library.KeybindToggles, KeybindsToggle)
        end

        local ModeButtons = {}
        local TotalModeButtons = GetTableSize(Info.Modes)
        local MenuTable = Library:AddContextMenu(Picker, UDim2.fromOffset(62, 0), function()
            return { Picker.AbsoluteSize.X + 1.5, 0.5 }
        end, 1, function(Active: boolean)
            PickerCorner.TopRightRadius = Active and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
            PickerCorner.BottomRightRadius = Active and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
        end, false, if TotalModeButtons == 1 then "no_left" else "no_top_left", "KeyPicker")
        KeyPicker.Menu = MenuTable

        for Index, Mode in Info.Modes do
            local ModeButton = {}

            local Button = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, IsForButton and 21 or (TotalModeButtons == 1 and 18 or 19)),
                Text = Mode,
                TextSize = 14,
                TextTransparency = 0.5,
                Parent = MenuTable.Menu,
            })
            
            if Index == 1 and TotalModeButtons == 1 then
                table.insert(Library.SpecificCorners, New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                }))
            elseif Index == 1 then
                table.insert(Library.SpecificCorners, New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomLeftRadius = UDim.new(0, 0),
                    BottomRightRadius = UDim.new(0, 0),
                    Parent = Button,
                }))
            elseif Index == TotalModeButtons then
                table.insert(Library.SpecificCorners, New("UICorner", {
                    TopLeftRadius = UDim.new(0, 0),
                    TopRightRadius = UDim.new(0, 0),
                    BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
                    BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Button,
                }))
            end

            function ModeButton:Select()
                for _, Button in ModeButtons do
                    Button:Deselect()
                end

                KeyPicker.Mode = Mode

                Button.BackgroundTransparency = 0
                Button.TextTransparency = 0

                MenuTable:Close()
            end

            function ModeButton:Deselect()
                KeyPicker.Mode = nil

                Button.BackgroundTransparency = 1
                Button.TextTransparency = 0.5
            end

            Button.MouseButton1Click:Connect(function()
                ModeButton:Select()
            end)

            if KeyPicker.Mode == Mode then
                ModeButton:Select()
            end

            ModeButtons[Mode] = ModeButton
        end

        function KeyPicker:Display(PickerText)
            if Library.Unloaded then
                return
            end

            local DisplayText = PickerText or KeyPicker.DisplayValue
            if IsForButton and SlideOverflow then
                if LastPickerWidth == Picker.AbsoluteSize.X then
                    return
                end

                local X, _Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    10000
                )

                SlidingLabel.Text = DisplayText

                local OffsetScale = X + 9
                local PickerWidth = math.min(OffsetScale, MaxPickerWidth)
                Picker.Size = UDim2.new(0, PickerWidth, 1, 0)

                if OffsetScale > PickerWidth then
                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SlidingLabel.Size = UDim2.new(0, OffsetScale, 1, 0)
                    SlidingLabel.Position = UDim2.fromOffset(4.5, 0)

                    RunService.RenderStepped:Wait()

                    local RealPickerWidth = Picker.AbsoluteSize.X
                    if RealPickerWidth <= 0 then RealPickerWidth = PickerWidth end

                    LastPickerWidth = RealPickerWidth

                    local OverflowDistance = OffsetScale - RealPickerWidth - 4.5
                    if OverflowDistance > 0 then
                        CancelSlidingTweens()

                        local Duration = OverflowDistance / 25
                        local TweenInfo = TweenInfo.new(
                            Duration,
                            Enum.EasingStyle.Linear, Enum.EasingDirection.InOut
                        )

                        SlideForwardTween = TweenService:Create(SlidingLabel, TweenInfo, {
                            Position = UDim2.fromOffset(-OverflowDistance, 0)
                        })

                        SlideBackTween = TweenService:Create(SlidingLabel, TweenInfo, {
                            Position = UDim2.fromOffset(4.5, 0)
                        })

                        SlideForwardTween:Play()

                        SlideForwardTween.Completed:Connect(HandleForwardTween)
                        SlideBackTween.Completed:Connect(HandleBackTween)
                    else
                        CancelSlidingTweens()

                        SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                        SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                        SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                    end
                else
                    CancelSlidingTweens()

                    SlidingLabel.TextXAlignment = Enum.TextXAlignment.Center
                    SlidingLabel.Size = UDim2.new(1, 0, 1, 0)
                    SlidingLabel.Position = UDim2.new(0, 0, 0, 0)
                end
            else
                local X, Y = Library:GetTextBounds(
                    DisplayText,
                    Picker.FontFace,
                    Picker.TextSize,
                    ToggleLabel.AbsoluteSize.X
                )
                Picker.Text = DisplayText
                Picker.Size = IsForButton and UDim2.new(0, X + 9, 1, 0) or UDim2.fromOffset((X + 9), (Y + 4))
            end
        end

        function KeyPicker:Update()
            KeyPicker:Display()

            if Info.NoUI then
                return
            end

            if KeyPicker.Mode == "Toggle" and ParentObj.Type == "Toggle" and ParentObj.Disabled then
                KeybindsToggle:SetVisibility(false)
                return
            end

            local State = KeyPicker:GetState()
            local ShowToggle = Library.ShowToggleFrameInKeybinds and KeyPicker.Mode == "Toggle"

            if KeyPicker.SyncToggleState and ParentObj.Value ~= State then
                ParentObj:SetValue(State)
            end

            if KeybindsToggle.Loaded then
                if ShowToggle then
                    KeybindsToggle:SetNormal(false)
                else
                    KeybindsToggle:SetNormal(true)
                end

                KeybindsToggle:SetText(("[%s] %s (%s)"):format(KeyPicker.DisplayValue, KeyPicker.Text, KeyPicker.Mode))
                KeybindsToggle:SetVisibility(true)
                KeybindsToggle:Display(State)
            end
        end

        function KeyPicker:GetState()
            if KeyPicker.Mode == "Always" then
                return true
            elseif KeyPicker.Mode == "Hold" then
                local Key = KeyPicker.Value
                if Key == "None" then
                    return false
                end

                if not AreModifiersHeld(KeyPicker.Modifiers) then
                    return false
                end

                if Picking then
                    return false
                end

                if SpecialKeys[Key] ~= nil then
                    if Library.Toggled then
                        return false
                    end

                    return UserInputService:IsMouseButtonPressed(SpecialKeys[Key])
                        and not UserInputService:GetFocusedTextBox()
                else
                    return UserInputService:IsKeyDown(Enum.KeyCode[Key] :: any) and not UserInputService:GetFocusedTextBox()
                end
            else
                return KeyPicker.Toggled
            end
        end

        function KeyPicker:OnChanged(Func)
            KeyPicker.Changed = Func
        end

        function KeyPicker:OnClick(Func)
            KeyPicker.Clicked = Func
        end

        function KeyPicker:DoClick()
            if Picking then
                return
            end

            if KeyPicker.Mode == "Press" then
                if KeyPicker.Toggled and Info.WaitForCallback == true then
                    return
                end

				KeyPicker.Toggled = true
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)

            if IsForButton then
                Library:SafeCallback(ParentObj.Func, KeyPicker.Toggled)
			end
			
			if Library.ToggleKeybind == KeyPicker and Library.Toggle then
                Library:Toggle()
            end

			if KeyPicker.Mode == "Press" then
                KeyPicker.Toggled = false
            end
        end

        function KeyPicker:RunChanged(IsKeyValid, KeyCode)
            if IsKeyValid == nil or KeyCode == nil then
                IsKeyValid, KeyCode = pcall(function()
                    if KeyPicker.Value == "None" then
                        return nil
                    end

                    if SpecialKeys[KeyPicker.Value] == nil then
                        return Enum.KeyCode[KeyPicker.Value]
                    end

                    return SpecialKeys[KeyPicker.Value]
                end)
            end

            local NewModifiers = ConvertToInputModifiers(KeyPicker.Modifiers)
            Library:SafeCallback(KeyPicker.ChangedCallback, KeyCode, NewModifiers)
            Library:SafeCallback(KeyPicker.Changed, KeyCode, NewModifiers)
        end

        function KeyPicker:SetValue(Data)
            local Key, Mode, Modifiers = Data[1], Data[2], Data[3]

            local IsKeyValid, KeyCode = pcall(function()
                if Key == "None" then
                    Key = nil
                    return nil
                end

                if SpecialKeys[Key] == nil then
                    return Enum.KeyCode[Key]
                end

                return SpecialKeys[Key]
            end)

            if Key == nil then
                KeyPicker.Value = "None"
            elseif IsKeyValid then
                KeyPicker.Value = Key
            else
                KeyPicker.Value = "Unknown"
            end

            KeyPicker.Modifiers =
                VerifyModifiers(if typeof(Modifiers) == "table" then Modifiers else KeyPicker.Modifiers)
            KeyPicker.DisplayValue = if GetTableSize(KeyPicker.Modifiers) > 0
                then (table.concat(KeyPicker.Modifiers, " + ") .. " + " .. KeyPicker.Value)
                else KeyPicker.Value

            if ModeButtons[Mode] then
                ModeButtons[Mode]:Select()
            end

            KeyPicker:Update()
            KeyPicker:RunChanged(IsKeyValid, KeyCode)
        end

        function KeyPicker:SetText(Text)
            KeybindsToggle:SetText(Text)
            KeyPicker:Update()
        end

        local SetPickingState = function(State)
            Picking = State
            Library.IsPicking = State

            if ParentObj then
                ParentObj.AnyKeyPickerPicking = Picking
            end

            if IsForButton then
                ToggleLabel.Visible = not Picking
                RunService.RenderStepped:Wait()
            end

            KeyPicker:Update()
        end

        Picker.MouseButton1Click:Connect(function()
            if Picking or Library.IsPicking then
                return
            end

            SetPickingState(true)

            if IsForButton and SlideOverflow then
                KeyPicker:Display("...")
            else
                Picker.Text = "..."
                Picker.Size = IsForButton and UDim2.new(0, 29, 1, 0) or UDim2.fromOffset(29, 18)
            end

            -- Wait for any input --
            local ActiveModifiers = {}
            local CurrentInput = nil

            local IsValidInput = function(InputObj)
                if InputObj.KeyCode == Enum.KeyCode.Escape then
                    return true
                end

                local IsMod = IsModifierInput(InputObj)
                local KeyName
                if SpecialKeysInput[InputObj.UserInputType] ~= nil then
                    KeyName = SpecialKeysInput[InputObj.UserInputType]
                elseif InputObj.UserInputType == Enum.UserInputType.Keyboard then
                    if IsMod then
                        KeyName = ModifiersInput[InputObj.KeyCode]
                    else
                        KeyName = InputObj.KeyCode.Name
                    end
                end

                if KeyName then
                    if IsMod then
                        if KeyPicker.WhitelistedModifiers and #KeyPicker.WhitelistedModifiers > 0 and not table.find(KeyPicker.WhitelistedModifiers, KeyName) then
                            return false
                        end

                        if KeyPicker.BlacklistedModifiers and table.find(KeyPicker.BlacklistedModifiers, KeyName) then
                            return false
                        end
                    else
                        if KeyPicker.Whitelisted and #KeyPicker.Whitelisted > 0 and not table.find(KeyPicker.Whitelisted, KeyName) then
                            return false
                        end

                        if KeyPicker.Blacklisted and table.find(KeyPicker.Blacklisted, KeyName) then
                            return false
                        end
                    end
                end

                return true
            end

            -- Wait for the first valid InputBegan --
            while true do
                local InputObj = UserInputService.InputBegan:Wait()
                if UserInputService:GetFocusedTextBox() ~= nil then
                    SetPickingState(false)
                    return
                end

                if IsValidInput(InputObj) then
                    CurrentInput = InputObj
                    break
                end
            end

            -- If it's a modifier key, we wait for either its release or another input --
            while IsModifierInput(CurrentInput) do
                if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                    break
                end

                -- Display the current state including the current modifier key --
                local ModName = ModifiersInput[CurrentInput.KeyCode]
                if ModName then
                    local text = if #ActiveModifiers > 0 then table.concat(ActiveModifiers, " + ") .. " + " .. ModName .. " + ..." else ModName .. " + ..."
                    KeyPicker:Display(text)
                end

                local NextInput = nil
                local Released = false

                local BeganConn
                local EndedConn

                BeganConn = UserInputService.InputBegan:Connect(function(InputObj)
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return
                    end
                    if IsValidInput(InputObj) then
                        NextInput = InputObj
                    end
                end)

                EndedConn = UserInputService.InputEnded:Connect(function(InputObj)
                    if InputObj.KeyCode == CurrentInput.KeyCode then
                        Released = true
                    end
                end)

                repeat
                    task.wait()
                until Released or NextInput or UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded

                if BeganConn then BeganConn:Disconnect() end
                if EndedConn then EndedConn:Disconnect() end

                if UserInputService:GetFocusedTextBox() ~= nil or Library.Unloaded then
                    SetPickingState(false)
                    return
                end

                if Released then
                    break -- Use modifier key as bind
                elseif NextInput then
                    -- Add another modifier or continue to normal key
                    local OldModName = ModifiersInput[CurrentInput.KeyCode]
                    if OldModName and not table.find(ActiveModifiers, OldModName) then
                        ActiveModifiers[#ActiveModifiers + 1] = OldModName
                    end

                    CurrentInput = NextInput
                    if CurrentInput.KeyCode == Enum.KeyCode.Escape then
                        break
                    end
                end
            end

            local Key = "Unknown"
            if SpecialKeysInput[CurrentInput.UserInputType] ~= nil then
                Key = SpecialKeysInput[CurrentInput.UserInputType]
            elseif CurrentInput.UserInputType == Enum.UserInputType.Keyboard then
                Key = CurrentInput.KeyCode == Enum.KeyCode.Escape and "None" or CurrentInput.KeyCode.Name
            end

            ActiveModifiers = if CurrentInput.KeyCode == Enum.KeyCode.Escape or Key == "Unknown" then {} else ActiveModifiers

            KeyPicker.Toggled = if ParentObj.Type == "Toggle" then ParentObj.Value else false
            KeyPicker:SetValue({ Key, KeyPicker.Mode, ActiveModifiers })

            repeat
                task.wait()
            until not IsInputDown(CurrentInput) or UserInputService:GetFocusedTextBox()

            SetPickingState(false)
        end)
        Picker.MouseButton2Click:Connect(MenuTable.Toggle)

        table.insert(KeyPicker.Connections, UserInputService.InputBegan:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                KeyPicker.Mode == "Always"
                or KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            local Key = KeyPicker.Value
            local HoldingModifiers = AreModifiersHeld(KeyPicker.Modifiers)
            local HoldingKey = false

            if
                Key
                and HoldingModifiers == true
                and (
                    SpecialKeysInput[Input.UserInputType] == Key
                    or (Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key)
                )
            then
                HoldingKey = true
            end

            if KeyPicker.Mode == "Toggle" then
                if HoldingKey then
                    KeyPicker.Toggled = not KeyPicker.Toggled
                    KeyPicker:DoClick()
                end
            elseif KeyPicker.Mode == "Press" then
                if HoldingKey then
                    KeyPicker:DoClick()
                end
            end

            KeyPicker:Update()
        end))

        table.insert(KeyPicker.Connections, UserInputService.InputEnded:Connect(function(Input: InputObject)
            if Library.Unloaded then
                return
            end

            local IsMouse = IsMouseClickInput(Input)
            if
                KeyPicker.Value == "Unknown"
                or KeyPicker.Value == "None"
                or Picking
                or Library.IsPicking
                or UserInputService:GetFocusedTextBox()
                or (IsMouse and Library.Toggled)
            then
                return
            end

            KeyPicker:Update()
        end))

        KeyPicker:Update()

        if ParentObj.Addons then
            table.insert(ParentObj.Addons, KeyPicker)
        end

        KeyPicker.Default = KeyPicker.Value
        KeyPicker.DefaultModifiers = table.clone(KeyPicker.Modifiers or {})

        function KeyPicker:Destroy()
            KeyPicker.Destroyed = true

            if KeyPicker.Connections then
                for _, Connection in KeyPicker.Connections do
                    Connection:Disconnect()
                end
            end

            if KeybindsToggle and KeybindsToggle.Loaded then
                if KeybindsToggle.Holder then 
                    KeybindsToggle.Holder:Destroy()
                end
                local KTIdx = table.find(Library.KeybindToggles, KeybindsToggle)
                if KTIdx then
                    table.remove(Library.KeybindToggles, KTIdx)
                end
            end

            if MenuTable then 
                MenuTable:Destroy() 
            end

            if IsForButton and SlideOverflow then
                if SlideForwardTween then 
                    SlideForwardTween:Destroy() 
                end

                if SlideBackTween then 
                    SlideBackTween:Destroy() 
                end
            end

            if Picker then
                Picker:Destroy()
            end

            if ParentObj and ParentObj.Addons then
                local AddonIdx = table.find(ParentObj.Addons, KeyPicker)
                
                if AddonIdx then 
                    table.remove(ParentObj.Addons, AddonIdx) 
                end
            end

            Options[Idx] = nil
        end

        Options[Idx] = KeyPicker

        return self
    end

    local HueSequenceTable = {}
    for Hue = 0, 1, 0.1 do
        table.insert(HueSequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)))
    end

    function Funcs:AddColorPicker(i, d)
        if self.Destroyed then return nil end
        d = Library:Validate(d, Templates.ColorPicker)
        local p = self
        local tl = p.TextLabel

        local o = {
            Connections = {},
            Destroyed = false,
            Value = d.Default,
            Transparency = d.Transparency or 0,
            Title = d.Title,
            Callback = d.Callback,
            Changed = d.Changed,
            Type = "ColorPicker",
        }
        o.Hue, o.Sat, o.Vib = o.Value:ToHSV()

        local h = New("TextButton", {
            BackgroundColor3 = o.Value,
            Size = UDim2.fromOffset(18, 18),
            Text = "",
            Parent = tl,
        })

        local hs = New("UIStroke", {
            Color = Library:GetDarkerColor(o.Value),
            Parent = h,
        })

        local cr = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = h,
        })
        table.insert(Library.SpecificCorners, cr)

        local ht = New("ImageLabel", {
            Image = CustomImageManager.GetAsset("TransparencyTexture"),
            ImageTransparency = (1 - o.Transparency),
            ScaleType = Enum.ScaleType.Tile,
            Position = UDim2.new(0, -1, 0, -1),
            Size = UDim2.new(1, 2, 1, 2),
            TileSize = UDim2.fromOffset(9, 9),
            Parent = h,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = ht }))

        local cm = Library:AddContextMenu(
            h,
            UDim2.fromOffset(d.Transparency and 256 or 234, 0),
            function() return { 0.5, h.AbsoluteSize.Y + 1.5 } end,
            1,
            function(act)
                cr.BottomRightRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
                cr.BottomLeftRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
            end,
            false,
            "no_top_left"
        )
        cm.List.Padding = UDim.new(0, 0)
        o.ColorMenu = cm

        local ch = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            Parent = cm.Menu,
        })
        New("UIListLayout", { Padding = UDim.new(0, 8), Parent = ch })
        New("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = ch })

        local fH = Library.IsMobile and 30 or 22
        local fb = New("Frame", {
            BackgroundColor3 = function() return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4) end,
            Size = UDim2.new(1, 0, 0, fH),
            Parent = cm.Menu,
        })
        table.insert(Library.SpecificCorners, New("UICorner", {
            TopLeftRadius = UDim.new(0, 0),
            TopRightRadius = UDim.new(0, 0),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = fb,
        }))
        Library:MakeLine(fb, { Position = UDim2.fromScale(0, 0), Size = UDim2.new(1, 0, 0, 1) })

        local fbr = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = fb,
        })
        New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, d.Resizable and (fH + 4) or 6), Parent = fbr })

        local fil = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = 0.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = fbr,
        })

        local function rFI()
            fil.Text = string.format("#%s • %d, %d, %d", o.Value:ToHex(), math.floor(o.Value.R * 255), math.floor(o.Value.G * 255), math.floor(o.Value.B * 255))
        end
        rFI()

        if typeof(o.Title) == "string" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                Text = o.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ch,
            })
        end

        local clh = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 200),
            Parent = ch,
        })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = clh })

        local svm = New("ImageButton", {
            BackgroundColor3 = o.Value,
            Image = CustomImageManager.GetAsset("SaturationMap"),
            Size = UDim2.fromOffset(200, 200),
            Parent = clh,
        })
        local svc = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            Size = UDim2.fromOffset(6, 6),
            Parent = svm,
        })
        New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = svc })
        New("UIStroke", { Color = "DarkColor", Parent = svc })

        local hslt = New("TextButton", {
            Size = UDim2.fromOffset(16, 200),
            Text = "",
            Parent = clh,
        })
        New("UIGradient", { Color = ColorSequence.new(HueSequenceTable), Rotation = 90, Parent = hslt })

        local hc = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = "WhiteColor",
            BorderColor3 = "DarkColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0.5, o.Hue),
            Size = UDim2.new(1, 2, 0, 1),
            Parent = hslt,
        })

        local ts, tc, trc
        if d.Transparency then
            ts = New("ImageButton", {
                Image = CustomImageManager.GetAsset("TransparencyTexture"),
                ScaleType = Enum.ScaleType.Tile,
                Size = UDim2.fromOffset(16, 200),
                TileSize = UDim2.fromOffset(8, 8),
                Parent = clh,
            })
            tc = New("Frame", {
                BackgroundColor3 = o.Value,
                Size = UDim2.fromScale(1, 1),
                Parent = ts,
            })
            New("UIGradient", {
                Rotation = 90,
                Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) }),
                Parent = tc,
            })
            trc = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "WhiteColor",
                BorderColor3 = "DarkColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0.5, o.Transparency),
                Size = UDim2.new(1, 2, 0, 1),
                Parent = ts,
            })
        end

        local rzG
        if d.Resizable then
            local bMS = 200
            local bBW = 16
            local bPad = 6
            local mMS = 140
            o.MapWidth = bMS
            o.MapHeight = bMS

            local function gBW(mW) return math.clamp(math.floor((mW / bMS) * bBW + 0.5), 12, 24) end
            local function gCW(mW)
                local bw = gBW(mW)
                local w = mW + bw + bPad
                if d.Transparency then w += (bw + bPad) end
                return w + 12
            end

            local fVO = 6 + 6 + 8 + 20 + 8 + 20 + fH
            if typeof(o.Title) == "string" then fVO += 16 end

            local function cTV(nW, nH)
                local cam = workspace.CurrentCamera
                if not cam then return nW, nH end
                local vp = cam.ViewportSize
                local mw = vp.X - cm.Menu.AbsolutePosition.X - 12
                local mh = vp.Y - cm.Menu.AbsolutePosition.Y - 12 - fVO
                while nW > mMS and gCW(nW) > mw do nW -= 4 end
                if nH > mh then nH = math.max(mMS, math.floor(mh)) end
                return nW, nH
            end

            local function uCMS(nW, nH)
                nW = math.max(mMS, math.floor(nW + 0.5))
                nH = math.max(mMS, math.floor(nH + 0.5))
                nW, nH = cTV(nW, nH)
                if nW == o.MapWidth and nH == o.MapHeight then return end

                local bw = gBW(nW)
                local cs = math.clamp(math.floor((math.min(nW, nH) / bMS) * 6 + 0.5), 4, 10)
                clh.Size = UDim2.new(1, 0, 0, nH)
                svm.Size = UDim2.fromOffset(nW, nH)
                svc.Size = UDim2.fromOffset(cs, cs)
                hslt.Size = UDim2.new(0, bw, 0, nH)
                if ts then ts.Size = UDim2.new(0, bw, 0, nH) end
                o.MapWidth = nW
                o.MapHeight = nH
                cm:SetSize(UDim2.new(0, gCW(nW), 0, 0))
            end

            rzG = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -Library.CornerRadius / 4, 0, 0),
                Size = UDim2.fromScale(1, 1),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Text = "",
                Parent = fb,
            })
            New("ImageLabel", {
                Image = ResizeIcon and ResizeIcon.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = ResizeIcon and ResizeIcon.ImageRectOffset or Vector2.zero,
                ImageRectSize = ResizeIcon and ResizeIcon.ImageRectSize or Vector2.zero,
                ImageTransparency = 0.5,
                Position = UDim2.fromOffset(2, 2),
                Size = UDim2.new(1, -4, 1, -4),
                Parent = rzG,
            })

            table.insert(o.Connections, rzG.InputBegan:Connect(function(inp)
                Library.CantDragForced = true
                local sm = Vector2.new(Mouse.X, Mouse.Y)
                local sw = o.MapWidth
                local sh = o.MapHeight
                while IsDragInput(inp) and not o.Destroyed do
                    local dlt = Vector2.new(Mouse.X, Mouse.Y) - sm
                    uCMS(sw + dlt.X, sh + dlt.Y)
                    RunService.RenderStepped:Wait()
                end
                Library.CantDragForced = false
            end))
        end

        local ih = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ch,
        })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 8), Parent = ih })

        local hb = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "#??????",
            TextSize = 14,
            Parent = ih,
        })
        local hbs = New("UIStroke", { Color = "OutlineColor", Parent = hb })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = hb }))

        local rb = New("TextBox", {
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = false,
            Size = UDim2.fromScale(1, 1),
            Text = "?, ?, ?",
            TextSize = 14,
            Parent = ih,
        })
        local rbs = New("UIStroke", { Color = "OutlineColor", Parent = rb })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = rb }))

        local cxm = Library:AddContextMenu(
            h,
            UDim2.fromOffset(93, 0),
            function() return { h.AbsoluteSize.X + 1.5, 0.5 } end,
            1,
            function(act)
                cr.TopRightRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
                cr.BottomRightRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
            end,
            false,
            "no_top_left"
        )
        o.ContextMenu = cxm
        cxm.List.Padding = UDim.new(0, 6)

        local function cCB(txt, fn)
            local btn = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 21),
                Text = txt,
                TextSize = 14,
                Parent = cxm.Menu,
            })
            btn.MouseButton1Click:Connect(function()
                Library:SafeCallback(fn)
                cxm:Close()
            end)
            btn.MouseEnter:Connect(function() TweenService:Create(btn, Library.TweenInfo, { BackgroundTransparency = 0.7 }):Play() end)
            btn.MouseLeave:Connect(function() TweenService:Create(btn, Library.TweenInfo, { BackgroundTransparency = 1 }):Play() end)
        end

        cCB("Copy color", function()
            Library.CopiedColor = { o.Value, o.Transparency }
        end)

        cCB("Paste color", function()
            if Library.CopiedColor then
                o:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
            end
        end)
        if sC then
            cCB("Copy Hex", function() sC(tostring(o.Value:ToHex())) end)
            cCB("Copy RGB", function()
                sC(table.concat({ math.floor(o.Value.R * 255), math.floor(o.Value.G * 255), math.floor(o.Value.B * 255) }, ", "))
            end)
        end

        local ah = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Parent = ch,
        })
        New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalFlex = Enum.UIFlexAlignment.Fill, Padding = UDim.new(0, 8), Parent = ah })

        local ccb = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Copy color",
            TextSize = 14,
            Parent = ah,
        })
        New("UIStroke", { Color = "OutlineColor", Parent = ccb })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = ccb }))

        local pcb = New("TextButton", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            Text = "Paste color",
            TextSize = 14,
            Parent = ah,
        })
        New("UIStroke", { Color = "OutlineColor", Parent = pcb })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = pcb }))

        local ccOT = ccb.Text
        local pcOT = pcb.Text
        local ccRID = 0
        local pcRID = 0

        table.insert(o.Connections, ccb.MouseEnter:Connect(function() TweenService:Create(ccb, Library.TweenInfo, { BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10) }):Play() end))
        table.insert(o.Connections, ccb.MouseLeave:Connect(function() TweenService:Create(ccb, Library.TweenInfo, { BackgroundColor3 = Library.Scheme.MainColor }):Play() end))
        table.insert(o.Connections, pcb.MouseEnter:Connect(function() TweenService:Create(pcb, Library.TweenInfo, { BackgroundColor3 = Library:GetBetterColor(Library.Scheme.MainColor, 10) }):Play() end))
        table.insert(o.Connections, pcb.MouseLeave:Connect(function() TweenService:Create(pcb, Library.TweenInfo, { BackgroundColor3 = Library.Scheme.MainColor }):Play() end))

        table.insert(o.Connections, ccb.MouseButton1Click:Connect(function()
            Library.CopiedColor = { o.Value, o.Transparency }
            ccRID += 1
            local tid = ccRID
            ccb.Text = "Copied color"
            task.delay(1, function()
                if not o.Destroyed and tid == ccRID then ccb.Text = ccOT end
            end)
        end))

        table.insert(o.Connections, pcb.MouseButton1Click:Connect(function()
            pcRID += 1
            local tid = pcRID
            if not Library.CopiedColor then
                pcb.Text = "Nothing to paste"
            else
                o:SetValueRGB(Library.CopiedColor[1], Library.CopiedColor[2])
                pcb.Text = "Pasted color"
            end
            task.delay(1, function()
                if not o.Destroyed and tid == pcRID then pcb.Text = pcOT end
            end)
        end))

        function o:SetHSVFromRGB(clr)
            o.Hue, o.Sat, o.Vib = clr:ToHSV()
        end

        function o:Display()
            if Library.Unloaded then return end
            o.Value = Color3.fromHSV(o.Hue, o.Sat, o.Vib)
            h.BackgroundColor3 = o.Value
            hs.Color = Library:GetDarkerColor(o.Value)
            ht.ImageTransparency = (1 - o.Transparency)

            svm.BackgroundColor3 = Color3.fromHSV(o.Hue, 1, 1)
            if tc then tc.BackgroundColor3 = o.Value end

            svc.Position = UDim2.fromScale(o.Sat, 1 - o.Vib)
            hc.Position = UDim2.fromScale(0.5, o.Hue)
            if trc then trc.Position = UDim2.fromScale(0.5, o.Transparency) end

            hb.Text = "#" .. o.Value:ToHex()
            rb.Text = table.concat({ math.floor(o.Value.R * 255), math.floor(o.Value.G * 255), math.floor(o.Value.B * 255) }, ", ")
            rFI()
        end

        function o:RunChanged()
            Library:SafeCallback(o.Callback, o.Value)
            Library:SafeCallback(o.Changed, o.Value)
        end

        function o:Update()
            o:Display()
            o:RunChanged()
        end

        function o:OnChanged(fn) o.Changed = fn end

        function o:SetValue(hsv, tr)
            if typeof(hsv) == "Color3" then
                o:SetValueRGB(hsv, tr)
                return
            end
            o.Transparency = d.Transparency and tr or 0
            o:SetHSVFromRGB(Color3.fromHSV(hsv[1], hsv[2], hsv[3]))
            o:Update()
        end

        function o:SetValueRGB(clr, tr)
            o.Transparency = d.Transparency and tr or 0
            o:SetHSVFromRGB(clr)
            o:Update()
        end

        table.insert(o.Connections, h.MouseButton1Click:Connect(cm.Toggle))
        table.insert(o.Connections, h.MouseButton2Click:Connect(cxm.Toggle))

        table.insert(o.Connections, svm.InputBegan:Connect(function(inp)
            while IsDragInput(inp) and not o.Destroyed do
                local minX = svm.AbsolutePosition.X
                local locX = math.clamp(Mouse.X, minX, minX + svm.AbsoluteSize.X)
                local minY = svm.AbsolutePosition.Y
                local locY = math.clamp(Mouse.Y, minY, minY + svm.AbsoluteSize.Y)

                local oS, oV = o.Sat, o.Vib
                o.Sat = (locX - minX) / svm.AbsoluteSize.X
                o.Vib = 1 - ((locY - minY) / svm.AbsoluteSize.Y)
                if o.Sat ~= oS or o.Vib ~= oV then o:Update() end
                RunService.RenderStepped:Wait()
            end
        end))

        table.insert(o.Connections, hslt.InputBegan:Connect(function(inp)
            while IsDragInput(inp) and not o.Destroyed do
                local minY = hslt.AbsolutePosition.Y
                local locY = math.clamp(Mouse.Y, minY, minY + hslt.AbsoluteSize.Y)
                local oH = o.Hue
                o.Hue = (locY - minY) / hslt.AbsoluteSize.Y
                if o.Hue ~= oH then o:Update() end
                RunService.RenderStepped:Wait()
            end
        end))

        if ts then
            table.insert(o.Connections, ts.InputBegan:Connect(function(inp)
                while IsDragInput(inp) and not o.Destroyed do
                    local minY = ts.AbsolutePosition.Y
                    local locY = math.clamp(Mouse.Y, minY, minY + ts.AbsoluteSize.Y)
                    local oT = o.Transparency
                    o.Transparency = (locY - minY) / ts.AbsoluteSize.Y
                    if o.Transparency ~= oT then o:Update() end
                    RunService.RenderStepped:Wait()
                end
            end))
        end

        table.insert(o.Connections, hb.FocusLost:Connect(function(enter)
            if not enter then return end
            local s, clr = pcall(Color3.fromHex, hb.Text)
            if s and typeof(clr) == "Color3" then o.Hue, o.Sat, o.Vib = clr:ToHSV() end
            o:Update()
        end))

        table.insert(o.Connections, rb.FocusLost:Connect(function(enter)
            if not enter then return end
            local r, gv, b = rb.Text:match("(%d+),%s*(%d+),%s*(%d+)")
            if r and gv and b then o:SetHSVFromRGB(Color3.fromRGB(r, gv, b)) end
            o:Update()
        end))

        for _, bp in { { hb, hbs }, { rb, rbs } } do
            local tbox, strk = bp[1], bp[2]
            table.insert(o.Connections, tbox.Focused:Connect(function()
                Library.Registry[strk].Color = "AccentColor"
                TweenService:Create(strk, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()
            end))
            table.insert(o.Connections, tbox.FocusLost:Connect(function()
                Library.Registry[strk].Color = "OutlineColor"
                TweenService:Create(strk, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()
            end))
        end

        o:Display()
        if p.Addons then table.insert(p.Addons, o) end
        o.Default = o.Value

        function o:Destroy()
            o.Destroyed = true
            if o.Connections then
                for _, cn in o.Connections do cn:Disconnect() end
            end
            if cm then cm:Destroy() end
            if rzG then rzG:Destroy() end
            if cxm then cxm:Destroy() end
            if h then h:Destroy() end
            if p and p.Addons then
                local aIdx = table.find(p.Addons, o)
                if aIdx then table.remove(p.Addons, aIdx) end
            end
            Options[i] = nil
        end

        Options[i] = o
        return self
    end

    BaseAddons.__index = Funcs
    BaseAddons.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

local BaseGroupbox = {}
do
    local Funcs = {}

    function Funcs:AddDivider(...)
        if self.Destroyed then return nil end

        local Params = select(1, ...)
        local Text
        local MarginTop = 0
        local MarginBottom = 0

        if typeof(Params) == "table" then
            Text = Params.Text
            MarginTop = Params.MarginTop or Params.Margin or 0
            MarginBottom = Params.MarginBottom or Params.Margin or 0
        elseif typeof(Params) == "string" then
            Text = Params
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 6 + MarginTop + MarginBottom),
            Parent = Container,
        })

        local InnerHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingTop = UDim.new(0, MarginTop),
            PaddingBottom = UDim.new(0, MarginBottom),
            Parent = Holder,
        })

        if Text then
            local TextLabel = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 0),
                Text = Text,
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = InnerHolder,
            })

            local X, _ = Library:GetTextBounds(Text, TextLabel.FontFace, TextLabel.TextSize, TextLabel.AbsoluteSize.X)
            local SizeX = X // 2 + 10

            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
            New("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(1, 0.5),
                Size = UDim2.new(0.5, -SizeX, 0, 2),
                Parent = InnerHolder,
            })
        else
            New("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = "MainColor",
                BorderColor3 = "OutlineColor",
                BorderSizePixel = 1,
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.new(1, 0, 0, 2),
                Parent = InnerHolder,
            })
        end

        Groupbox:Resize()

        local Divider = {
            Connections = {},
            Destroyed = false,

            Holder = Holder,
            Text = Text,
            MarginTop = MarginTop,
            MarginBottom = MarginBottom,
            Type = "Divider",
        }

        function Divider:SetVisible(Value)
            Holder.Visible = Value == true
            Groupbox:Resize()
        end

        function Divider:Destroy()
            Divider.Destroyed = true

            if Divider.Connections then
                for _, Connection in Divider.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Divider)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
        end

        table.insert(Groupbox.Elements, Divider)
        return Divider
    end

    function Funcs:AddLabel(...)
        if self.Destroyed then return nil end

        local Data = {}
        local Addons = {}

        local First = select(1, ...)
        local Second = select(2, ...)

        if typeof(First) == "table" or typeof(Second) == "table" then
            local Params = typeof(First) == "table" and First or Second

            Data.Text = Params.Text or ""
            Data.DoesWrap = Params.DoesWrap or false
            Data.Size = Params.Size or 14
            Data.Visible = Params.Visible or true
            Data.Idx = typeof(Second) == "table" and First or nil
        else
            Data.Text = First or ""
            Data.DoesWrap = Second or false
            Data.Size = 14
            Data.Visible = true
            Data.Idx = select(3, ...) or nil
        end

        local Groupbox = self
        local Container = Groupbox.Container

        local Label = {
            Connections = {},
            Destroyed = false,

            Text = Data.Text,
            DoesWrap = Data.DoesWrap,

            Addons = Addons,

            Visible = Data.Visible,
            Type = "Label",
        }

        local TextLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = Label.Text,
            TextSize = Data.Size,
            TextWrapped = Label.DoesWrap,
            TextXAlignment = Groupbox.IsKeyTab and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
            Parent = Container,
        })

        function Label:Display()
            if not Label.DoesWrap then
                return
            end

            local Width = TextLabel.AbsoluteSize.X
            if Width <= 0 then return end

            local _, Y = Library:GetTextBounds(Label.Text, TextLabel.FontFace, TextLabel.TextSize, Width)
            TextLabel.Size = UDim2.new(1, 0, 0, Y + 4)
        end

        function Label:SetVisible(Visible: boolean)
            Label.Visible = Visible

            TextLabel.Visible = Label.Visible
            Groupbox:Resize()
        end

        function Label:SetText(Text: string)
            Label.Text = Text
            TextLabel.Text = Text

            Label:Display()
            Groupbox:Resize()
        end

        if Label.DoesWrap then
            Label:Display()

            local Last = TextLabel.AbsoluteSize
            TextLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                if TextLabel.AbsoluteSize == Last then
                    return
                end

                Label:Display()
                Last = TextLabel.AbsoluteSize

                Groupbox:Resize()
            end)
        else
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
                Padding = UDim.new(0, 6),
                Parent = TextLabel,
            })
        end

        Groupbox:Resize()

        Label.TextLabel = TextLabel
        Label.Container = Container
        if not Data.DoesWrap then
            setmetatable(Label, BaseAddons)
        end

        Label.Holder = TextLabel
        table.insert(Groupbox.Elements, Label)

        if Data.Idx then
            Labels[Data.Idx] = Label
        else
            table.insert(Labels, Label)
        end

        function Label:Destroy()
            Label.Destroyed = true

            if Label.Connections then
                for _, Connection in Label.Connections do
                    Connection:Disconnect()
                end
            end

            if Label.Addons then
                for Index = #Label.Addons, 1, -1 do
                    local Addon = table.remove(Label.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            if TextLabel then 
                TextLabel:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Label)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()

            if Data.Idx then
                Labels[Data.Idx] = nil
            else
                local LblIdx = table.find(Labels, Label)
                
                if LblIdx then 
                    table.remove(Labels, LblIdx) 
                end
            end
        end

        return Label
    end

    function Funcs:AddButton(...)
        if self.Destroyed then return nil end

        local function GetInfo(...)
            local Info = {}

            local First = select(1, ...)
            local Second = select(2, ...)

            if typeof(First) == "table" or typeof(Second) == "table" then
                local Params = typeof(First) == "table" and First or Second

                Info.Text = Params.Text or ""
                Info.Func = Params.Func or Params.Callback or function() end
                Info.DoubleClick = Params.DoubleClick

                Info.Tooltip = Params.Tooltip
                Info.DisabledTooltip = Params.DisabledTooltip

                Info.Risky = Params.Risky or false
                Info.Disabled = Params.Disabled or false
                Info.Visible = Params.Visible or true
                Info.Idx = typeof(Second) == "table" and First or nil
            else
                Info.Text = First or ""
                Info.Func = Second or function() end
                Info.DoubleClick = false

                Info.Tooltip = nil
                Info.DisabledTooltip = nil

                Info.Risky = false
                Info.Disabled = false
                Info.Visible = true
                Info.Idx = select(3, ...) or nil
            end

            return Info
        end
        local Info = GetInfo(...)

        local Groupbox = self
        local Container = Groupbox.Container

        local Button = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Func = Info.Func,
            DoubleClick = Info.DoubleClick,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Tween = nil,
            Type = "Button",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Parent = Container,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDim.new(0, 9),
            Parent = Holder,
        })

        local function CreateButton(Button)
            local Base = New("TextButton", {
                Active = not Button.Disabled,
                BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor",
                Size = UDim2.fromScale(1, 1),
                Text = Button.Text,
                TextSize = 14,
                TextTransparency = 0.4,
                Visible = Button.Visible,
                Parent = Holder,
            })

            local Stroke = New("UIStroke", {
                Color = "OutlineColor",
                Transparency = Button.Disabled and 0.5 or 0,
                Parent = Base,
            })

            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Base,
                })
            )

            return Base, Stroke
        end

        local function InitEvents(Button)
            Button.Base.MouseEnter:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0,
                })
                Button.Tween:Play()
            end)
            Button.Base.MouseLeave:Connect(function()
                if Button.Disabled then
                    return
                end

                Button.Tween = TweenService:Create(Button.Base, Library.TweenInfo, {
                    TextTransparency = 0.4,
                })
                Button.Tween:Play()
            end)

            Button.Base.MouseButton1Click:Connect(function()
                if Button.Disabled or Button.Locked then
                    return
                end

                if Button.DoubleClick then
                    Button.Locked = true

                    Button.Base.Text = "Are you sure?"
                    Button.Base.TextColor3 = Library.Scheme.AccentColor
                    Library.Registry[Button.Base].TextColor3 = "AccentColor"

                    local Clicked = WaitForEvent(Button.Base.MouseButton1Click, 0.5)

                    Button.Base.Text = Button.Text
                    Button.Base.TextColor3 = Button.Risky and Library.Scheme.RedColor or Library.Scheme.FontColor
                    Library.Registry[Button.Base].TextColor3 = Button.Risky and "RedColor" or "FontColor"

                    if Clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    RunService.RenderStepped:Wait() --// Mouse Button fires without waiting (i hate roblox)
                    Button.Locked = false
                    return
                end

                Library:SafeCallback(Button.Func)
            end)
        end

        Button.Base, Button.Stroke = CreateButton(Button)
        InitEvents(Button)

        function Button:AddButton(...)
            local Info = GetInfo(...)

            local SubButton = {
                Connections = {},
                Destroyed = false,

                Text = Info.Text,
                Func = Info.Func,
                DoubleClick = Info.DoubleClick,

                Tooltip = Info.Tooltip,
                DisabledTooltip = Info.DisabledTooltip,
                TooltipTable = nil,

                Risky = Info.Risky,
                Disabled = Info.Disabled,
                Visible = Info.Visible,

                Tween = nil,
                Type = "SubButton",
            }

            Button.SubButton = SubButton
            SubButton.Base, SubButton.Stroke = CreateButton(SubButton)
            InitEvents(SubButton)

            function SubButton:UpdateColors()
                if Library.Unloaded then
                    return
                end

                StopTween(SubButton.Tween)

                SubButton.Base.BackgroundColor3 = SubButton.Disabled and Library.Scheme.BackgroundColor
                    or Library.Scheme.MainColor
                SubButton.Base.TextTransparency = SubButton.Disabled and 0.8 or 0.4
                SubButton.Stroke.Transparency = SubButton.Disabled and 0.5 or 0

                Library.Registry[SubButton.Base].BackgroundColor3 = SubButton.Disabled and "BackgroundColor"
                    or "MainColor"
            end

            function SubButton:SetDisabled(Disabled: boolean)
                SubButton.Disabled = Disabled

                if SubButton.TooltipTable then
                    SubButton.TooltipTable.Disabled = SubButton.Disabled
                end

                SubButton.Base.Active = not SubButton.Disabled
                SubButton:UpdateColors()
            end

            function SubButton:SetVisible(Visible: boolean)
                SubButton.Visible = Visible

                SubButton.Base.Visible = SubButton.Visible
                Groupbox:Resize()
            end

            function SubButton:SetText(Text: string)
                SubButton.Text = Text
                SubButton.Base.Text = Text
            end

            if typeof(SubButton.Tooltip) == "string" or typeof(SubButton.DisabledTooltip) == "string" then
                SubButton.TooltipTable =
                    Library:AddTooltip(SubButton.Tooltip, SubButton.DisabledTooltip, SubButton.Base)
                SubButton.TooltipTable.Disabled = SubButton.Disabled
            end

            if SubButton.Risky then
                SubButton.Base.TextColor3 = Library.Scheme.RedColor
                Library.Registry[SubButton.Base].TextColor3 = "RedColor"
            end

            SubButton:UpdateColors()

            if Info.Idx then
                Buttons[Info.Idx] = SubButton
            else
                table.insert(Buttons, SubButton)
            end

            SubButton.AddKeyPicker = BaseAddons.__index.AddKeyPicker

            function SubButton:Destroy()
                SubButton.Destroyed = true

                if SubButton.TooltipTable then 
                    SubButton.TooltipTable:Destroy() 
                end

                if SubButton.Tween then 
                    SubButton.Tween:Destroy() 
                end

                if SubButton.Base then 
                    SubButton.Base:Destroy() 
                end

                if Info.Idx then
                    Buttons[Info.Idx] = nil
                else
                    local BIdx = table.find(Buttons, SubButton)
                    
                    if BIdx then 
                        table.remove(Buttons, BIdx) 
                    end
                end
            end

            return SubButton
        end

        function Button:UpdateColors()
            if Library.Unloaded then
                return
            end

            StopTween(Button.Tween)

            Button.Base.BackgroundColor3 = Button.Disabled and Library.Scheme.BackgroundColor
                or Library.Scheme.MainColor
            Button.Base.TextTransparency = Button.Disabled and 0.8 or 0.4
            Button.Stroke.Transparency = Button.Disabled and 0.5 or 0

            Library.Registry[Button.Base].BackgroundColor3 = Button.Disabled and "BackgroundColor" or "MainColor"
        end

        function Button:SetDisabled(Disabled: boolean)
            Button.Disabled = Disabled

            if Button.TooltipTable then
                Button.TooltipTable.Disabled = Button.Disabled
            end

            Button.Base.Active = not Button.Disabled
            Button:UpdateColors()
        end

        function Button:SetVisible(Visible: boolean)
            Button.Visible = Visible

            Holder.Visible = Button.Visible
            Groupbox:Resize()
        end

        function Button:SetText(Text: string)
            Button.Text = Text
            Button.Base.Text = Text
        end

        if typeof(Button.Tooltip) == "string" or typeof(Button.DisabledTooltip) == "string" then
            Button.TooltipTable = Library:AddTooltip(Button.Tooltip, Button.DisabledTooltip, Button.Base)
            Button.TooltipTable.Disabled = Button.Disabled
        end

        if Button.Risky then
            Button.Base.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Button.Base].TextColor3 = "RedColor"
        end

        Button:UpdateColors()
        Groupbox:Resize()

        Button.Holder = Holder
        table.insert(Groupbox.Elements, Button)

        if Info.Idx then
            Buttons[Info.Idx] = Button
        else
            table.insert(Buttons, Button)
        end

        Button.AddKeyPicker = BaseAddons.__index.AddKeyPicker

        function Button:Destroy()
            Button.Destroyed = true

            if Button.TooltipTable then 
                Button.TooltipTable:Destroy() 
            end

            if Button.Tween then 
                Button.Tween:Destroy() 
            end

            if Button.SubButton then 
                Button.SubButton:Destroy() 
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Button)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()

            if Info.Idx then
                Buttons[Info.Idx] = nil
            else
                local BIdx = table.find(Buttons, Button)
                
                if BIdx then 
                    table.remove(Buttons, BIdx) 
                end
            end
        end

        return Button
    end

    function Funcs:AddCheckbox(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Checkbox",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(26, 0),
            Size = UDim2.new(1, -26, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Checkbox = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Button,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Checkbox,
            })
        )

        local CheckboxStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Checkbox,
        })

        local CheckImage = New("ImageLabel", {
            Image = CheckIcon and CheckIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = CheckIcon and CheckIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = CheckIcon and CheckIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 1,
            Position = UDim2.fromOffset(2, 2),
            Size = UDim2.new(1, -4, 1, -4),
            Parent = Checkbox,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            CheckboxStroke.Transparency = Toggle.Disabled and 0.5 or 0

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                CheckImage.ImageTransparency = Toggle.Value and 0.8 or 1

                Checkbox.BackgroundColor3 = Library.Scheme.BackgroundColor
                Library.Registry[Checkbox].BackgroundColor3 = "BackgroundColor"

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(CheckImage, Library.TweenInfo, {
                ImageTransparency = Toggle.Value and 0 or 1,
            }):Play()

            Checkbox.BackgroundColor3 = Library.Scheme.MainColor
            Library.Registry[Checkbox].BackgroundColor3 = "MainColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then 
                Toggle.TooltipTable:Destroy() 
            end

            if Button then 
                Button:Destroy() 
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddToggle(Idx, Info)
        if self.Destroyed then return nil end

        if Library.ForceCheckbox then
            return Funcs.AddCheckbox(self, Idx, Info)
        end

        Info = Library:Validate(Info, Templates.Toggle)

        local Groupbox = self
        local Container = Groupbox.Container

        local Toggle = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Risky = Info.Risky,
            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Addons = {},
            AnyKeyPickerPicking = false,

            Variant = "Switch",
            Type = "Toggle",
        }

        local Button = New("TextButton", {
            Active = not Toggle.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            Text = "",
            Visible = Toggle.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Text = Toggle.Text,
            TextSize = 14,
            TextTransparency = 0.4,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Button,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Padding = UDim.new(0, 6),
            Parent = Label,
        })

        local Switch = New("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromOffset(32, 18),
            Parent = Button,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Switch,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 2),
            PaddingLeft = UDim.new(0, 2),
            PaddingRight = UDim.new(0, 2),
            PaddingTop = UDim.new(0, 2),
            Parent = Switch,
        })
        local SwitchStroke = New("UIStroke", {
            Color = "OutlineColor",
            Parent = Switch,
        })

        local Ball = New("Frame", {
            BackgroundColor3 = "FontColor",
            Size = UDim2.fromScale(1, 1),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            Parent = Switch,
        })
        New("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = Ball,
        })

        function Toggle:UpdateColors()
            Toggle:Display()
        end

        function Toggle:Display()
            if Library.Unloaded then
                return
            end

            local Offset = Toggle.Value and 1 or 0

            Switch.BackgroundTransparency = Toggle.Disabled and 0.75 or 0
            SwitchStroke.Transparency = Toggle.Disabled and 0.75 or 0

            Switch.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.MainColor
            SwitchStroke.Color = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.OutlineColor

            Library.Registry[Switch].BackgroundColor3 = Toggle.Value and "AccentColor" or "MainColor"
            Library.Registry[SwitchStroke].Color = Toggle.Value and "AccentColor" or "OutlineColor"

            if Toggle.Disabled then
                Label.TextTransparency = 0.8
                Ball.AnchorPoint = Vector2.new(Offset, 0)
                Ball.Position = UDim2.fromScale(Offset, 0)

                Ball.BackgroundColor3 = Library:GetDarkerColor(Library.Scheme.FontColor)
                Library.Registry[Ball].BackgroundColor3 = function()
                    return Library:GetDarkerColor(Library.Scheme.FontColor)
                end

                return
            end

            TweenService:Create(Label, Library.TweenInfo, {
                TextTransparency = Toggle.Value and 0 or 0.4,
            }):Play()
            TweenService:Create(Ball, Library.TweenInfo, {
                AnchorPoint = Vector2.new(Offset, 0),
                Position = UDim2.fromScale(Offset, 0),
            }):Play()

            Ball.BackgroundColor3 = Library.Scheme.FontColor
            Library.Registry[Ball].BackgroundColor3 = "FontColor"
        end

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func
        end

        function Toggle:RunChanged()
            Library:SafeCallback(Toggle.Callback, Toggle.Value)
            Library:SafeCallback(Toggle.Changed, Toggle.Value)
        end

        function Toggle:SetValue(Value)
            if Toggle.Disabled then
                return
            end

            Toggle.Value = Value
            Toggle:Display()

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon.Toggled = Toggle.Value
                    Addon:Update()
                end
            end

            Library:UpdateDependencyBoxes()

            if not Toggle.AnyKeyPickerPicking then
                Toggle:RunChanged()
            end
        end

        function Toggle:SetDisabled(Disabled: boolean)
            Toggle.Disabled = Disabled

            if Toggle.TooltipTable then
                Toggle.TooltipTable.Disabled = Toggle.Disabled
            end

            for _, Addon in Toggle.Addons do
                if Addon.Type == "KeyPicker" and Addon.SyncToggleState then
                    Addon:Update()
                end
            end

            Button.Active = not Toggle.Disabled
            Toggle:Display()
        end

        function Toggle:SetVisible(Visible: boolean)
            Toggle.Visible = Visible

            Button.Visible = Toggle.Visible
            Groupbox:Resize()
        end

        function Toggle:SetText(Text: string)
            Toggle.Text = Text
            Label.Text = Text
        end

        table.insert(Toggle.Connections, Button.MouseButton1Click:Connect(function()
            if Toggle.Disabled then
                return
            end

            Toggle:SetValue(not Toggle.Value)
        end))

        if typeof(Toggle.Tooltip) == "string" or typeof(Toggle.DisabledTooltip) == "string" then
            Toggle.TooltipTable = Library:AddTooltip(Toggle.Tooltip, Toggle.DisabledTooltip, Button)
            Toggle.TooltipTable.Disabled = Toggle.Disabled
        end

        if Toggle.Risky then
            Label.TextColor3 = Library.Scheme.RedColor
            Library.Registry[Label].TextColor3 = "RedColor"
        end

        Toggle:Display()
        Groupbox:Resize()

        Toggle.TextLabel = Label
        Toggle.Container = Container
        setmetatable(Toggle, BaseAddons)

        Toggle.Holder = Button
        table.insert(Groupbox.Elements, Toggle)

        Toggle.Default = Toggle.Value

        Toggles[Idx] = Toggle

        function Toggle:Destroy()
            Toggle.Destroyed = true

            if Toggle.Connections then
                for _, Connection in Toggle.Connections do
                    Connection:Disconnect()
                end
            end

            if Toggle.TooltipTable then 
                Toggle.TooltipTable:Destroy() 
            end

            if Button then 
                Button:Destroy() 
            end

            if Toggle.Addons then
                for Index = #Toggle.Addons, 1, -1 do
                    local Addon = table.remove(Toggle.Addons, Index)
                    if Addon and Addon.Destroy then
                        Addon:Destroy()
                    end
                end
            end

            local ElemIdx = table.find(Groupbox.Elements, Toggle)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Toggles[Idx] = nil
        end

        return Toggle
    end

    function Funcs:AddInput(Idx, Info)
        if self.Destroyed then return nil end

        if typeof(Info) == "table" and (typeof(Info.VerifyValue) == "function" and Info.Finished ~= true) then
            Info.Finished = true
        end

        Info = Library:Validate(Info, Templates.Input)

        local Groupbox = self
        local Container = Groupbox.Container

        local Input = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Finished = Info.Finished,
            Numeric = Info.Numeric,
            ClearTextOnFocus = Info.ClearTextOnFocus,
            ClearTextOnBlur = Info.ClearTextOnBlur,
            Placeholder = Info.Placeholder,
            AllowEmpty = Info.AllowEmpty,
            EmptyReset = Info.EmptyReset,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,
            VerifyValue = Info.VerifyValue,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            Type = "Input",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 39),
            Visible = Input.Visible,
            Parent = Container,
        })

        local Label = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = Input.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        local Box = New("TextBox", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus,
            PlaceholderText = Input.Placeholder,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = Input.Value,
            TextEditable = not Input.Disabled,
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Box,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                Parent = Box,
            })
        )

        function Input:UpdateColors()
            if Library.Unloaded then
                return
            end

            Label.TextTransparency = Input.Disabled and 0.8 or 0
            Box.TextTransparency = Input.Disabled and 0.8 or 0
        end

        function Input:OnChanged(Func)
            Input.Changed = Func
        end

        function Input:RunChanged()
            Library:SafeCallback(Input.Callback, Input.Value)
            Library:SafeCallback(Input.Changed, Input.Value)
        end

        function Input:SetValue(Text)
            if not Input.AllowEmpty and Trim(Text) == "" then
                Text = Input.EmptyReset
            end

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength)
            end

            if Input.Numeric then
                if #tostring(Text) > 0 and not tonumber(Text) then
                    Text = Input.Value
                end
            end

            if typeof(Info.VerifyValue) == "function" and (Text ~= Input.EmptyReset and Info.VerifyValue(Text) ~= true) then
                Text = Input.EmptyReset
            end

            Input.Value = Text
            Box.Text = Text

            if not Input.Disabled then
                Input:RunChanged()
            end
        end

        function Input:SetDisabled(Disabled: boolean)
            Input.Disabled = Disabled

            if Input.TooltipTable then
                Input.TooltipTable.Disabled = Input.Disabled
            end

            Box.ClearTextOnFocus = not Input.Disabled and Input.ClearTextOnFocus
            Box.TextEditable = not Input.Disabled
            Input:UpdateColors()
        end

        function Input:SetVisible(Visible: boolean)
            Input.Visible = Visible

            Holder.Visible = Input.Visible
            Groupbox:Resize()
        end

        function Input:SetText(Text: string)
            Input.Text = Text
            Label.Text = Text
        end

        if Input.Finished then
            table.insert(Input.Connections, Box.FocusLost:Connect(function(Enter)
                if not Enter then
                    if Input.ClearTextOnBlur then
                        Box.Text = Input.Value
                    end

                    return
                end

                Input:SetValue(Box.Text)
            end))
        else
            table.insert(Input.Connections, Box:GetPropertyChangedSignal("Text"):Connect(function()
                if Box.Text == Input.Value then return end
                
                Input:SetValue(Box.Text)
            end))
        end

        if typeof(Input.Tooltip) == "string" or typeof(Input.DisabledTooltip) == "string" then
            Input.TooltipTable = Library:AddTooltip(Input.Tooltip, Input.DisabledTooltip, Box)
            Input.TooltipTable.Disabled = Input.Disabled
        end

        Groupbox:Resize()

        Input.Holder = Holder
        table.insert(Groupbox.Elements, Input)

        Input.Default = Input.Value
        if typeof(Info.VerifyValue) == "function" and (Input.Default ~= Input.EmptyReset and Info.VerifyValue(Input.Default) ~= true) then
            Input:SetValue(Input.EmptyReset)
            Input.Default = Input.EmptyReset
        end
        
        Options[Idx] = Input

        function Input:Destroy()
            Input.Destroyed = true

            if Input.Connections then
                for _, Connection in Input.Connections do
                    Connection:Disconnect()
                end
            end

            if Input.TooltipTable then 
                Input.TooltipTable:Destroy() 
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Input)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Input
    end

    function Funcs:AddSlider(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Slider)

        local Groupbox = self
        local Container = Groupbox.Container
        local IsBall = Info.BallSlider == true or Info.Style == "Ball"

        local Slider = {
            Connections = {},
            Destroyed = false,

            Text = Info.Text,
            Value = Info.Default,

            Min = Info.Min,
            Max = Info.Max,

            Prefix = Info.Prefix,
            Suffix = Info.Suffix,
            Compact = Info.Compact,
            Rounding = Info.Rounding,
            HideMax = Info.HideMax,

            Tooltip = Info.Tooltip,
            DisabledTooltip = Info.DisabledTooltip,
            TooltipTable = nil,

            Callback = Info.Callback,
            Changed = Info.Changed,

            Disabled = Info.Disabled,
            Visible = Info.Visible,

            AllowRightClickInput = Info.AllowRightClickInput,

            Type = "Slider",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(
                1,
                0,
                0,
                Info.Compact and 15 or (IsBall and (22 + SLIDER_BAR_HEIGHT + SLIDER_BALL_MARGIN) or 33)
            ),
            Visible = Slider.Visible,
            Parent = Container,
        })

        local SliderLabel
        local TopRow
        if not Info.Compact then
            if IsBall then
                TopRow = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Parent = Holder,
                })
                SliderLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -70, 1, 0),
                    Text = Slider.Text,
                    TextSize = 14,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = TopRow,
                })
            else
                SliderLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = Slider.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Holder,
                })
            end
        end

        local Bar = New("TextButton", {
            Active = not Slider.Disabled,
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = (IsBall and not Info.Compact) and "FontColor" or "MainColor",
            Position = (IsBall and not Info.Compact)
                and UDim2.new(0, 0, 1, -SLIDER_BALL_MARGIN)
                or UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, (IsBall and not Info.Compact) and SLIDER_BAR_HEIGHT or 15),
            Text = "",
            Parent = Holder,
        })

        New("UIStroke", {
            Color = "OutlineColor",
            Parent = Bar,
        })

        if IsBall and not Info.Compact then
            New("UIGradient", {
                Color = ColorSequence.new(SLIDER_TRACK_GRADIENT_FROM, SLIDER_TRACK_GRADIENT_TO),
                Parent = Bar,
            })
        end

        local DisplayLabel = New("TextLabel", {
            AnchorPoint = (IsBall and not Info.Compact) and Vector2.new(1, 0) or Vector2.new(0, 0),
            BackgroundTransparency = 1,
            Position = (IsBall and not Info.Compact) and UDim2.fromScale(1, 0) or UDim2.fromScale(0, 0),
            Size = (IsBall and not Info.Compact) and UDim2.new(0, 70, 1, 0) or UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 14,
            TextTransparency = (IsBall and not Info.Compact) and 0.4 or 0,
            TextXAlignment = (IsBall and not Info.Compact) and Enum.TextXAlignment.Right or Enum.TextXAlignment.Center,
            ZIndex = Bar.ZIndex + 3,
            Parent = (IsBall and not Info.Compact) and TopRow or Bar,
        })
        if not IsBall or Info.Compact then
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = DisplayLabel,
            })
        end

        local InputTextBox
        if Info.AllowRightClickInput then
            InputTextBox = New("TextBox", {
                AnchorPoint = DisplayLabel.AnchorPoint,
                BackgroundTransparency = 1,
                Position = DisplayLabel.Position,
                Size = DisplayLabel.Size,
                Text = "",
                TextSize = 14,
                TextXAlignment = DisplayLabel.TextXAlignment,
                ZIndex = Bar.ZIndex + 4,
                Visible = false,
                ClearTextOnFocus = false,
                Parent = DisplayLabel.Parent,
            })
            New("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Color = "DarkColor",
                LineJoinMode = Enum.LineJoinMode.Miter,
                Parent = InputTextBox,
            })
        end

        local Fill = New("Frame", {
            BackgroundColor3 = "AccentColor",
            Size = UDim2.fromScale(0.5, 1),
            ZIndex = Bar.ZIndex + 1,
            Parent = Bar,
        })

        local Ball
        local BallShadow
        local BallActive = false
        if IsBall and not Info.Compact then
            local InnerOutline = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(1, -2, 1, -2),
                ZIndex = Bar.ZIndex + 2,
                Parent = Bar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = InnerOutline,
            })
            New("UIStroke", {
                Color = "DarkColor",
                Transparency = 0.7,
                Parent = InnerOutline,
            })

            BallShadow = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "DarkColor",
                BackgroundTransparency = 0.55,
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(SLIDER_BALL_SIZE, SLIDER_BALL_SIZE),
                ZIndex = Bar.ZIndex + 3,
                Parent = Bar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = BallShadow,
            })

            Ball = New("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = "FontColor",
                Position = UDim2.fromScale(0, 0.5),
                Size = UDim2.fromOffset(SLIDER_BALL_SIZE, SLIDER_BALL_SIZE),
                ZIndex = Bar.ZIndex + 4,
                Parent = Bar,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = Ball,
            })
            New("UIStroke", {
                Color = "DarkColor",
                Transparency = 0.75,
                Parent = Ball,
            })
        end

        if IsBall then
            table.insert(
                Library.PillCorners,
                New("UICorner", {
                    CornerRadius = Library.CornerRadius > 0 and UDim.new(1, 0) or UDim.new(0, 0),
                    Parent = Bar,
                })
            )
            table.insert(
                Library.PillCorners,
                New("UICorner", {
                    CornerRadius = Library.CornerRadius > 0 and UDim.new(1, 0) or UDim.new(0, 0),
                    Parent = Fill,
                })
            )
        else
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Bar,
                })
            )
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                    Parent = Fill,
                })
            )
        end

        local function SetBallActive(act)
            if not Ball or BallActive == act or Slider.Disabled then
                return
            end

            BallActive = act
            local d = act and SLIDER_BALL_SIZE_ACTIVE or SLIDER_BALL_SIZE
            local sz = UDim2.fromOffset(d, d)

            local x = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
            local edge = UDim.new(x, (0.5 - x) * d)
            local pos = UDim2.new(edge.Scale, edge.Offset, 0.5, 0)

            TweenService:Create(Ball, SLIDER_BALL_TWEEN, { Size = sz, Position = pos }):Play()
            TweenService:Create(BallShadow, SLIDER_BALL_TWEEN, { Size = sz, Position = pos + UDim2.fromOffset(0, 1) }):Play()
            TweenService:Create(Fill, SLIDER_BALL_TWEEN, { Size = UDim2.new(edge.Scale, edge.Offset, 1, 0) }):Play()
        end

        function Slider:UpdateColors()
            if Library.Unloaded then
                return
            end

            if SliderLabel then
                SliderLabel.TextTransparency = Slider.Disabled and 0.8 or 0
            end
            DisplayLabel.TextTransparency = Slider.Disabled and 0.8 or ((IsBall and not Info.Compact) and 0.4 or 0)

            if Ball then
                Ball.BackgroundTransparency = Slider.Disabled and 0.5 or 0
                BallShadow.BackgroundTransparency = Slider.Disabled and 1 or 0.55
                Bar.BackgroundTransparency = Slider.Disabled and 0.6 or 0
            end

            if Info.AllowRightClickInput then
                InputTextBox.TextTransparency = Slider.Disabled and 0.8 or 0
            end

            Fill.BackgroundColor3 = Slider.Disabled and Library.Scheme.OutlineColor or Library.Scheme.AccentColor
            Library.Registry[Fill].BackgroundColor3 = Slider.Disabled and "OutlineColor" or "AccentColor"
        end

        function Slider:Display()
            if Library.Unloaded then
                return
            end

            local cdt = nil
            if Info.FormatDisplayValue then
                cdt = Info.FormatDisplayValue(Slider, Slider.Value)
            end

            if cdt then
                DisplayLabel.Text = tostring(cdt)
            else
                if Info.Compact then
                    DisplayLabel.Text =
                        string.format("%s: %s%s%s", Slider.Text, Slider.Prefix, Slider.Value, Slider.Suffix)
                elseif Info.HideMax then
                    DisplayLabel.Text = string.format("%s%s%s", Slider.Prefix, Slider.Value, Slider.Suffix)
                else
                    DisplayLabel.Text = string.format(
                        "%s%s%s/%s%s%s",
                        Slider.Prefix,
                        Slider.Value,
                        Slider.Suffix,
                        Slider.Prefix,
                        Slider.Max,
                        Slider.Suffix
                    )
                end
            end

            local x = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)

            if not Ball then
                Fill.Size = UDim2.fromScale(x, 1)
                return
            end

            local d = BallActive and SLIDER_BALL_SIZE_ACTIVE or SLIDER_BALL_SIZE
            local edge = UDim.new(x, (0.5 - x) * d)

            Fill.Size = UDim2.new(edge.Scale, edge.Offset, 1, 0)
            local pos = UDim2.new(edge.Scale, edge.Offset, 0.5, 0)
            Ball.Position = pos
            BallShadow.Position = pos + UDim2.fromOffset(0, 1)
        end

        function Slider:OnChanged(Func)
            Slider.Changed = Func
        end

        function Slider:SetMax(Value)
            assert(Value > Slider.Min, "Max value cannot be less than the current min value.")
            Slider:SetValue(math.clamp(Slider.Value, Slider.Min, Value))
            Slider.Max = Value
            Slider:Display()
        end

        function Slider:SetMin(Value)
            assert(Value < Slider.Max, "Min value cannot be greater than the current max value.")
            Slider:SetValue(math.clamp(Slider.Value, Value, Slider.Max))
            Slider.Min = Value
            Slider:Display()
        end

        function Slider:RunChanged()
            Library:SafeCallback(Slider.Callback, Slider.Value)
            Library:SafeCallback(Slider.Changed, Slider.Value)
        end

        function Slider:SetValue(Str)
            if Slider.Disabled then
                return
            end

            local Num = tonumber(Str)
            if not Num or Num == Slider.Value then
                return
            end

            Num = math.clamp(Num, Slider.Min, Slider.Max)

            Slider.Value = Num
            Slider:Display()

            Slider:RunChanged()
        end

        function Slider:SetDisabled(Disabled: boolean)
            Slider.Disabled = Disabled

            if Slider.TooltipTable then
                Slider.TooltipTable.Disabled = Slider.Disabled
            end

            Bar.Active = not Slider.Disabled
            Slider:UpdateColors()
        end

        function Slider:SetVisible(Visible: boolean)
            Slider.Visible = Visible

            Holder.Visible = Slider.Visible
            Groupbox:Resize()
        end

        function Slider:SetText(Text: string)
            Slider.Text = Text
            if SliderLabel then
                SliderLabel.Text = Text
                return
            end
            Slider:Display()
        end

        function Slider:SetPrefix(Prefix: string)
            Slider.Prefix = Prefix
            Slider:Display()
        end

        function Slider:SetSuffix(Suffix: string)
            Slider.Suffix = Suffix
            Slider:Display()
        end

        if Info.AllowRightClickInput then
            local lvt = ""
            table.insert(Slider.Connections, InputTextBox:GetPropertyChangedSignal("Text"):Connect(function()
                local txt = InputTextBox.Text
                local num = tonumber(txt)

                if #tostring(txt) > 0 and not num and txt ~= "-" then
                    InputTextBox.Text = lvt
                else
                    if Slider.Rounding == 0 and txt:find("%.") then
                        InputTextBox.Text = lvt
                        return
                    end

                    local dec = txt:find("%.")
                    if dec and Slider.Rounding > 0 then
                        if #txt - dec > Slider.Rounding then
                            InputTextBox.Text = lvt
                            return
                        end
                    end

                    lvt = txt

                    if num then
                        if num > Slider.Max then
                            InputTextBox.Text = tostring(Slider.Max)
                        elseif num < Slider.Min then
                            InputTextBox.Text = tostring(Slider.Min)
                        end
                    end
                end
            end))

            table.insert(Slider.Connections, InputTextBox.FocusLost:Connect(function()
                InputTextBox.Visible = false
                DisplayLabel.Visible = true

                local num = tonumber(InputTextBox.Text)
                if not num then
                    return
                end

                num = Round(num, Slider.Rounding)
                Slider:SetValue(num)
            end))
        end

        local lt = 0
        table.insert(Slider.Connections, Bar.InputBegan:Connect(function(inp: InputObject)
            local vi = IsClickInput(inp) or inp.UserInputType == Enum.UserInputType.MouseButton2
            if not vi or Slider.Disabled then
                return
            end

            if Info.AllowRightClickInput then
                local rc = inp.UserInputType == Enum.UserInputType.MouseButton2
                local dt = false

                if Library.IsMobile and inp.UserInputType == Enum.UserInputType.Touch then
                    if tick() - lt < 0.3 then
                        dt = true
                    end
                    lt = tick()
                end

                if rc or dt then
                    InputTextBox.Text = tostring(Slider.Value)
                    InputTextBox.Visible = true
                    DisplayLabel.Visible = false

                    task.spawn(InputTextBox.CaptureFocus, InputTextBox)
                    return
                end
            end

            if not IsClickInput(inp) then
                return
            end

            for _, side in Library:GetActiveSides() do
                side.ScrollingEnabled = false
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = false
            end

            SetBallActive(true)

            while IsDragInput(inp) and not Slider.Destroyed do
                local loc = Mouse.X
                local sc = math.clamp((loc - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)

                local ov = Slider.Value
                Slider.Value = Round(Slider.Min + ((Slider.Max - Slider.Min) * sc), Slider.Rounding)

                Slider:Display()
                if Slider.Value ~= ov then
                    Slider:RunChanged()
                end

                RunService.RenderStepped:Wait()
            end

            for _, side in Library:GetActiveSides() do
                side.ScrollingEnabled = true
            end

            if Library.ActiveLoading and Library.ActiveLoading.Sidebar then
                Library.ActiveLoading.Sidebar.Container.ScrollingEnabled = true
            end

            SetBallActive(Library:MouseIsOverFrame(Bar, Mouse))
        end))

        if Ball then
            table.insert(
                Slider.Connections,
                Bar.MouseEnter:Connect(function()
                    SetBallActive(true)
                end)
            )
            table.insert(
                Slider.Connections,
                Bar.MouseLeave:Connect(function()
                    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        return
                    end
                    SetBallActive(false)
                end)
            )
        end

        if typeof(Slider.Tooltip) == "string" or typeof(Slider.DisabledTooltip) == "string" then
            Slider.TooltipTable = Library:AddTooltip(Slider.Tooltip, Slider.DisabledTooltip, Bar)
            Slider.TooltipTable.Disabled = Slider.Disabled
        end

        Slider:UpdateColors()
        Slider:Display()
        Groupbox:Resize()

        Slider.Holder = Holder
        table.insert(Groupbox.Elements, Slider)

        Slider.Default = Slider.Value

        Options[Idx] = Slider

        function Slider:Destroy()
            Slider.Destroyed = true

            if Slider.Connections then
                for _, conn in Slider.Connections do
                    conn:Disconnect()
                end
            end

            if Slider.TooltipTable then
                Slider.TooltipTable:Destroy()
            end

            if Holder then
                Holder:Destroy()
            end

            local elemIdx = table.find(Groupbox.Elements, Slider)
            if elemIdx then
                table.remove(Groupbox.Elements, elemIdx)
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Slider
    end

    local function vE(v, t)
        if not t or typeof(t) ~= "table" then return false end
        for k, val in t do
            if val == v or k == v then return true end
        end
        return false
    end

    function Funcs:AddDropdown(i, d)
        if self.Destroyed then return nil end
        d = Library:Validate(d, Templates.Dropdown)
        local g = self
        local c = g.Container

        if d.SpecialType == "Player" then
            d.Values = GetPlayers(d.ExcludeLocalPlayer)
            d.AllowNull = true
        elseif d.SpecialType == "Team" then
            d.Values = GetTeams()
            d.AllowNull = true
        end

        local o = {
            Connections = {},
            Destroyed = false,
            Text = typeof(d.Text) == "string" and d.Text or nil,
            Value = d.Multi and {} or nil,
            Values = d.Values,
            DisabledValues = d.DisabledValues,
            ValueImages = d.ValueImages,
            Multi = d.Multi,
            DragSelect = d.Multi and not Library.IsMobile and d.DragSelect == true,
            SpecialType = d.SpecialType,
            ExcludeLocalPlayer = d.ExcludeLocalPlayer,
            EnablePlayerImages = d.EnablePlayerImages,
            Tooltip = d.Tooltip,
            DisabledTooltip = d.DisabledTooltip,
            TooltipTable = nil,
            Callback = d.Callback,
            Changed = d.Changed,
            Disabled = d.Disabled,
            Visible = d.Visible,
            Type = "Dropdown",
        }

        local h = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, o.Text and 39 or 21),
            Visible = o.Visible,
            Parent = c,
        })

        local l = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = o.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not d.Text,
            ZIndex = 3,
            Parent = h,
        })

        local dc = New("TextButton", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 21),
            Text = "",
            TextTransparency = 1,
            ZIndex = 2,
            Parent = h,
        })
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 4), Parent = dc })
        New("UIStroke", { Color = "OutlineColor", Parent = dc })

        local cr = New("UICorner", {
            TopLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            TopRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomRightRadius = UDim.new(0, Library.CornerRadius / 2),
            BottomLeftRadius = UDim.new(0, Library.CornerRadius / 2),
            Parent = dc,
        })
        table.insert(Library.SpecificCorners, cr)

        local di = New("ImageLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-4, 3),
            Size = UDim2.fromOffset(16, 16),
            Image = "",
            ImageTransparency = 1,
            ZIndex = 2,
            Parent = dc,
        })

        local db = New("TextButton", {
            Active = not o.Disabled,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 21),
            Text = "---",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = dc,
        })

        local ai = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Image = ArrowIcon and ArrowIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(16, 16),
            Parent = dc,
        })

        local eb, ei
        if d.Expandable ~= false then
            local xi = Library:GetIcon("maximize-2")
            eb = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -18, 0.5, 0),
                Size = UDim2.fromOffset(16, 16),
                Text = "",
                ZIndex = 3,
                Parent = dc,
            })
            ei = New("ImageLabel", {
                Image = xi and xi.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = xi and xi.ImageRectOffset or Vector2.zero,
                ImageRectSize = xi and xi.ImageRectSize or Vector2.zero,
                ImageTransparency = 0.5,
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2.fromScale(1, 1),
                ZIndex = 3,
                Parent = eb,
            })
            eb.MouseEnter:Connect(function()
                if not o.Disabled then TweenService:Create(ei, Library.TweenInfo, { ImageTransparency = 0 }):Play() end
            end)
            eb.MouseLeave:Connect(function()
                if not o.Disabled then TweenService:Create(ei, Library.TweenInfo, { ImageTransparency = 0.5 }):Play() end
            end)
            Library:AddTooltip("Expand", nil, eb)
        end

        local sb
        if d.Searchable then
            sb = New("TextBox", {
                BackgroundTransparency = 1,
                PlaceholderText = "Search...",
                Position = UDim2.fromOffset(-8, 0),
                Size = UDim2.new(1, -12, 1, 0),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = false,
                Parent = db,
            })
            New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = sb })
        end

        local function gVI(val, raw)
            if not val then return nil end
            if o.SpecialType == "Player" and o.EnablePlayerImages == true then
                local pl = typeof(val) == "Instance" and val or raw
                if typeof(pl) == "Instance" and pl:IsA("Player") then
                    return { Url = string.format("rbxthumb://type=AvatarHeadShot&id=%s&w=48&h=48", tostring(pl.UserId)) }
                end
            elseif d.ValueImages then
                local ir = d.ValueImages[val] or (raw and d.ValueImages[raw])
                if ir then return Library:GetCustomIcon(ir) end
            end
            return nil
        end

        local mt = Library:AddContextMenu(
            dc,
            function() return UDim2.fromOffset(dc.AbsoluteSize.X / (Library.DPIScale or 1), 0) end,
            function() return { 0.5, dc.AbsoluteSize.Y + 1.5 } end,
            2,
            function(act)
                db.TextTransparency = (act and sb) and 1 or 0
                ai.ImageTransparency = act and 0 or 0.5
                ai.Rotation = act and 180 or 0
                if sb then
                    sb.Text = ""
                    sb.Visible = act
                end
                cr.BottomRightRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
                cr.BottomLeftRadius = act and UDim.new(0, 0) or UDim.new(0, Library.CornerRadius / 2)
            end,
            false,
            "bottom",
            "Dropdown"
        )
        o.Menu = mt

        local rH = 21
        local pS = math.max(1, (d.MaxVisibleDropdownItems or 8) + 4)
        local pool = {}
        local fE = {}

        function o:RecalculateListSize(cnt)
            local n = cnt or #fE
            local y = math.clamp(n * rH, 0, (d.MaxVisibleDropdownItems or 8) * rH)
            mt.Menu.CanvasSize = UDim2.fromOffset(0, n * rH)
            mt:SetSize(function() return UDim2.fromOffset(dc.AbsoluteSize.X / (Library.DPIScale or 1), y) end)
        end

        function o:UpdateColors()
            if Library.Unloaded then return end
            l.TextTransparency = o.Disabled and 0.8 or 0
            db.TextTransparency = o.Disabled and 0.8 or 0
            di.ImageTransparency = o.Disabled and 0.8 or 0
            ai.ImageTransparency = o.Disabled and 0.8 or mt.Active and 0 or 0.5
        end

        function o:Display()
            if Library.Unloaded then return end
            local s = ""
            local img = nil
            local isD = not IsSequentialArray(o.Values)

            if d.Multi then
                for k, rv in o.Values do
                    local v = isD and k or rv
                    if o.Value[v] then
                        if not img then img = gVI(v, rv) end
                        s ..= (d.FormatDisplayValue and tostring(d.FormatDisplayValue(rv)) or tostring(rv)) .. ", "
                    end
                end
                s = s:sub(1, #s - 2)
            else
                local dv = o.Value
                if isD and o.Value ~= nil then dv = o.Values[o.Value] end
                img = gVI(o.Value, dv)
                s = dv and tostring(dv) or ""
                if s ~= "" and d.FormatDisplayValue then s = tostring(d.FormatDisplayValue(s)) end
            end

            if #s > 25 then s = s:sub(1, 22) .. "..." end
            db.Text = (s == "" and "---" or s)

            if img then
                di.Image = img.Url
                di.ImageRectOffset = img.ImageRectOffset or Vector2.zero
                di.ImageRectSize = img.ImageRectSize or Vector2.zero
                di.ImageTransparency = 0
            else
                di.Image = ""
                di.ImageTransparency = 1
            end

            db.Size = img and UDim2.new(1, -8, 0, 21) or UDim2.new(1, 0, 0, 21)
            db.Position = img and UDim2.fromOffset(14, 0) or UDim2.fromOffset(0, 0)
        end

        function o:OnChanged(fn) o.Changed = fn end

        function o:GetActiveValues(retC)
            local t = {}
            if d.Multi then
                for v in o.Value do table.insert(t, v) end
            else
                if o.Value then table.insert(t, o.Value) end
            end
            return retC == true and GetTableSize(t) or t
        end

        local dSel = false
        local dStart = nil
        local dPMin, dPMax, dLast = nil, nil, nil
        local dInit = {}
        local dEndConn, dChgConn = nil, nil

        local function rFE()
            local vs = o.Values
            local dis = o.DisabledValues or {}
            local isD = not IsSequentialArray(vs)
            local eL, dL = {}, {}
            local pnd = {}

            for k, rv in vs do
                local v = isD and k or rv
                local fv = tostring(d.FormatListValue and d.FormatListValue(rv) or rv)
                if not sb or sb.Text == "" or fv:lower():find(sb.Text:lower(), 1, true) then
                    local isDis = table.find(dis, v) ~= nil or (rv ~= nil and rv ~= v and table.find(dis, rv) ~= nil)
                    table.insert(pnd, {
                        Value = v,
                        RawValue = rv,
                        FormattedValue = fv,
                        IsDisabled = isDis,
                        ValueImage = gVI(v, rv),
                        SortKey = k,
                    })
                end
            end

            if not isD then
                table.sort(pnd, function(a, b) return a.SortKey < b.SortKey end)
            end

            for _, e in pnd do
                if e.IsDisabled then table.insert(dL, e) else table.insert(eL, e) end
            end

            table.clear(fE)
            for _, e in eL do table.insert(fE, e) end
            for _, e in dL do table.insert(fE, e) end
        end

        local function gFVI()
            local tot = #fE
            if tot <= pS then return 1 end
            local scY = mt.Menu.CanvasPosition.Y / (Library.DPIScale or 1)
            local idx = math.floor(scY / rH) + 1
            return math.clamp(idx, 1, math.max(1, tot - pS + 1))
        end

        function o:RefreshPool()
            local tot = #fE
            local fst = gFVI()

            for slot, row in pool do
                local idx = fst + slot - 1
                local ent = fE[idx]
                row.Entry = ent
                row.Index = ent and idx or nil

                if not ent then
                    row.Container.Visible = false
                    continue
                end

                row.Container.Visible = true
                row.Container.Position = UDim2.fromOffset(0, (idx - 1) * rH)
                local isL = idx == tot
                row.Corner.BottomRightRadius = isL and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                row.Corner.BottomLeftRadius = isL and UDim.new(0, Library.CornerRadius / 2) or UDim.new(0, 0)
                row.Button.Text = ent.FormattedValue

                if ent.ValueImage then
                    row.Image.Visible = true
                    row.Image.Image = ent.ValueImage.Url
                    row.Image.ImageRectOffset = ent.ValueImage.ImageRectOffset or Vector2.zero
                    row.Image.ImageRectSize = ent.ValueImage.ImageRectSize or Vector2.zero
                    row.Button.Size = UDim2.new(1, -18, 0, rH)
                    row.Button.Position = UDim2.fromOffset(18, 0)
                else
                    row.Image.Visible = false
                    row.Button.Size = UDim2.new(1, 0, 0, rH)
                    row.Button.Position = UDim2.fromOffset(0, 0)
                end

                row:UpdateButton()
            end
        end

        function o:RunChanged()
            Library:SafeCallback(o.Callback, o.Value)
            Library:SafeCallback(o.Changed, o.Value)
        end

        local function sDS()
            dSel = false
            dStart, dPMin, dPMax, dLast = nil, nil, nil, nil
            table.clear(dInit)
            if dEndConn then dEndConn:Disconnect() dEndConn = nil end
            if dChgConn then dChgConn:Disconnect() dChgConn = nil end
        end

        local dActC = 0

        local function aDI(idx, inR)
            local e = fE[idx]
            if not e or e.IsDisabled then return end
            local try = dInit[e.Value]
            if inR then try = not try end
            local want = try and true or false
            local isA = o.Value[e.Value] and true or false
            if want == isA then return end
            if not want and dActC == 1 and not d.AllowNull then return end
            o.Value[e.Value] = want and true or nil
            dActC += want and 1 or -1
        end

        local function aDR(from, to, inR)
            for idx = from, to do aDI(idx, inR) end
        end

        local function uD(cur)
            if cur == nil or cur == dLast then return end
            dLast = cur
            local mn = math.min(dStart, cur)
            local mx = math.max(dStart, cur)
            dActC = o:GetActiveValues(true)

            if dPMin == nil then
                aDR(mn, mx, true)
            else
                if dPMin < mn then aDR(dPMin, mn - 1, false) end
                if dPMax > mx then aDR(mx + 1, dPMax, false) end
                if mn < dPMin then aDR(mn, dPMin - 1, true) end
                if mx > dPMax then aDR(dPMax + 1, mx, true) end
            end

            dPMin, dPMax = mn, mx
            for _, r in pool do r:UpdateButton() end
        end

        local function cPR()
            local r = { Entry = nil, Index = nil }
            local cnt = New("Frame", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, rH),
                Visible = false,
                Parent = mt.Menu,
            })
            local uic = New("UICorner", {
                TopLeftRadius = UDim.new(0, 0),
                TopRightRadius = UDim.new(0, 0),
                BottomRightRadius = UDim.new(0, 0),
                BottomLeftRadius = UDim.new(0, 0),
                Parent = cnt,
            })
            table.insert(Library.SpecificCorners, uic)

            local img = New("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "",
                ImageTransparency = 0.5,
                Size = UDim2.fromOffset(16, 16),
                Position = UDim2.fromOffset(4, 3),
                Visible = false,
                Parent = cnt,
            })

            local btn = New("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, rH),
                Text = "",
                TextSize = 14,
                TextTransparency = 0.5,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = cnt,
            })
            New("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = btn })

            r.Container = cnt
            r.Corner = uic
            r.Image = img
            r.Button = btn

            function r:UpdateButton()
                local ent = r.Entry
                if not ent then return end
                local sel = d.Multi and o.Value[ent.Value] or (o.Value == ent.Value)
                r.Selected = sel and true or false
                cnt.BackgroundTransparency = sel and 0 or 1
                btn.TextTransparency = ent.IsDisabled and 0.8 or sel and 0 or 0.5
                if ent.ValueImage then
                    img.ImageTransparency = ent.IsDisabled and 0.8 or sel and 0 or 0.5
                end
            end

            btn.MouseButton1Click:Connect(function()
                local ent = r.Entry
                if not ent or ent.IsDisabled or dSel then return end
                local sel = d.Multi and o.Value[ent.Value] or (o.Value == ent.Value)
                local try = not sel

                if not (o:GetActiveValues(true) == 1 and not try and not d.AllowNull) then
                    if d.Multi then
                        o.Value[ent.Value] = try and true or nil
                    else
                        o.Value = try and ent.Value or nil
                    end
                    for _, orw in pool do orw:UpdateButton() end
                end

                r:UpdateButton()
                o:Display()
                Library:UpdateDependencyBoxes()
                o:RunChanged()
            end)

            btn.MouseEnter:Connect(function()
                local ent = r.Entry
                if not ent or ent.IsDisabled or r.Selected then return end
                TweenService:Create(cnt, Library.TweenInfo, { BackgroundTransparency = 0.85 }):Play()
                TweenService:Create(btn, Library.TweenInfo, { TextTransparency = 0.25 }):Play()
                if img then TweenService:Create(img, Library.TweenInfo, { ImageTransparency = 0.25 }):Play() end
            end)

            btn.MouseLeave:Connect(function()
                local ent = r.Entry
                if not ent or ent.IsDisabled or r.Selected then return end
                TweenService:Create(cnt, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(btn, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                if img then TweenService:Create(img, Library.TweenInfo, { ImageTransparency = 0.5 }):Play() end
            end)

            btn.InputBegan:Connect(function(sIn)
                if not (d.Multi and o.DragSelect and not Library.IsMobile) then return end
                local ent = r.Entry
                if not ent or ent.IsDisabled or not IsMouseInput(sIn) then return end

                dSel = true
                dStart = r.Index
                table.clear(dInit)
                for _, fe in fE do dInit[fe.Value] = o.Value[fe.Value] end
                uD(r.Index)

                if dEndConn then dEndConn:Disconnect() end
                if dChgConn then dChgConn:Disconnect() end

                dChgConn = Library:GiveSignal(UserInputService.InputChanged:Connect(function(cIn)
                    if not IsMovementInput(cIn) and cIn ~= sIn then return end
                    local p = cIn.Position
                    for _, orw in pool do
                        if orw.Entry and Library:MouseIsOverFrame(orw.Button, p) then
                            uD(orw.Index)
                            break
                        end
                    end
                end))

                dEndConn = Library:GiveSignal(UserInputService.InputEnded:Connect(function(eIn)
                    if eIn ~= sIn and not (IsMouseInput(eIn) and eIn.UserInputType == sIn.UserInputType) then return end
                    o:Display()
                    Library:UpdateDependencyBoxes()
                    o:RunChanged()
                    sDS()
                end))

                table.insert(o.Connections, dEndConn)
                table.insert(o.Connections, dChgConn)
            end)

            return r
        end

        function o:BuildDropdownList()
            sDS()
            rFE()
            mt.Menu.CanvasPosition = Vector2.zero
            o:RefreshPool()
            o:RecalculateListSize(#fE)
        end

        for _ = 1, pS do table.insert(pool, cPR()) end

        table.insert(o.Connections, mt.Menu:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            o:RefreshPool()
        end))

        local expO, expF, expSc, expL, expG, expSB, expEL
        local expBtns = {}
        local rExpL

        local function isValSel(v)
            if d.Multi then return o.Value[v] == true end
            return o.Value == v
        end

        local function refAllBtns()
            for _, r in pool do r:UpdateButton() end
            for _, tb in expBtns do tb:UpdateButton() end
        end

        local function togVal(v)
            local try = not isValSel(v)
            if not (o:GetActiveValues(true) == 1 and not try and not d.AllowNull) then
                if d.Multi then
                    o.Value[v] = try and true or nil
                else
                    o.Value = try and v or nil
                end
            end
            refAllBtns()
            o:Display()
            Library:UpdateDependencyBoxes()
            o:RunChanged()
        end

        local function bExpP()
            if expO then return end
            local par = Library.MainFrame
            if not par then return end

            expO = New("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = "DarkColor",
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                Visible = false,
                ZIndex = 8000,
                Parent = par,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = expO }))

            expF = New("TextButton", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                AutoButtonColor = false,
                BackgroundColor3 = "BackgroundColor",
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.new(0.7, 0, 0.72, 0),
                Text = "",
                ZIndex = 8001,
                Parent = expO,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = expF }))
            Library:AddOutline(expF)

            expSc = New("UIScale", { Scale = 1, Parent = expF })

            local hdr = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Parent = expF,
            })
            Library:MakeLine(hdr, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1) })

            New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 0),
                Size = UDim2.new(1, -56, 1, 0),
                Text = o.Text or "Select a value",
                TextSize = 15,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = hdr,
            })

            local ci = Library:GetIcon("x")
            local cb = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -8, 0.5, 0),
                Size = UDim2.fromOffset(22, 22),
                Text = "",
                Parent = hdr,
            })
            table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = cb }))
            New("UIPadding", { PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), Parent = cb })
            New("ImageLabel", {
                Image = ci and ci.Url or "",
                ImageColor3 = "FontColor",
                ImageRectOffset = ci and ci.ImageRectOffset or Vector2.zero,
                ImageRectSize = ci and ci.ImageRectSize or Vector2.zero,
                ImageTransparency = 0.4,
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2.fromScale(1, 1),
                Parent = cb,
            })

            cb.MouseEnter:Connect(function() TweenService:Create(cb, Library.TweenInfo, { BackgroundTransparency = 0 }):Play() end)
            cb.MouseLeave:Connect(function() TweenService:Create(cb, Library.TweenInfo, { BackgroundTransparency = 1 }):Play() end)
            cb.MouseButton1Click:Connect(function() o:Collapse() end)

            local lTop = 34
            if d.Searchable then
                lTop = 34 + 38
                expSB = New("TextBox", {
                    BackgroundColor3 = "MainColor",
                    PlaceholderText = "Search...",
                    Position = UDim2.fromOffset(10, 42),
                    Size = UDim2.new(1, -20, 0, 26),
                    Text = "",
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = expF,
                })
                table.insert(Library.PillCorners, New("UICorner", { CornerRadius = Library.CornerRadius > 0 and UDim.new(1, 0) or UDim.new(0, 0), Parent = expSB }))
                New("UIPadding", { PaddingLeft = UDim.new(0, 32), PaddingRight = UDim.new(0, 12), Parent = expSB })
                New("UIStroke", { Color = "OutlineColor", Parent = expSB })

                local si = Library:GetIcon("search")
                New("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    Image = si and si.Url or "",
                    ImageColor3 = "FontColor",
                    ImageRectOffset = si and si.ImageRectOffset or Vector2.zero,
                    ImageRectSize = si and si.ImageRectSize or Vector2.zero,
                    ImageTransparency = 0.4,
                    Position = UDim2.new(0, -22, 0.5, 0),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(15, 15),
                    Parent = expSB,
                })

                table.insert(o.Connections, expSB:GetPropertyChangedSignal("Text"):Connect(function() rExpL() end))
            end

            expL = New("ScrollingFrame", {
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),
                Position = UDim2.fromOffset(0, lTop),
                ScrollBarImageColor3 = "OutlineColor",
                ScrollBarThickness = 2,
                Size = UDim2.new(1, 0, 1, -lTop),
                Parent = expF,
            })
            expG = New("UIGridLayout", {
                CellPadding = UDim2.fromOffset(6, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = expL,
            })
            New("UIPadding", { PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 10), Parent = expL })

            expEL = New("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(0, lTop + 14),
                Size = UDim2.new(1, 0, 0, 16),
                Text = "No matching values",
                TextSize = 14,
                TextTransparency = 0.5,
                Visible = false,
                Parent = expF,
            })

            expO.MouseButton1Click:Connect(function() o:Collapse() end)
        end

        function rExpL()
            if not expL then return end
            for btn in expBtns do
                if btn and btn.Parent then btn.Parent:Destroy() end
            end
            table.clear(expBtns)

            local cols = math.max(1, d.ExpandColumns or 2)
            local srch = expSB and expSB.Text:lower() or ""
            local cnt = 0
            local isD = not IsSequentialArray(o.Values)

            for k, rv in o.Values do
                local v = isD and k or rv
                local fmt = tostring(d.FormatListValue and d.FormatListValue(rv) or rv)
                if srch ~= "" and not fmt:lower():find(srch, 1, true) then continue end

                cnt += 1
                local dis = table.find(o.DisabledValues or {}, v) ~= nil
                local vi = gVI(v, rv)
                local tbl = {}

                local item = New("Frame", {
                    BackgroundColor3 = "MainColor",
                    BackgroundTransparency = 1,
                    LayoutOrder = dis and 1 or 0,
                    Parent = expL,
                })
                table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = item }))
                local stroke = New("UIStroke", { Color = "OutlineColor", Transparency = 0.5, Parent = item })

                local img = vi and New("ImageLabel", {
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Image = vi.Url,
                    ImageRectOffset = vi.ImageRectOffset or Vector2.zero,
                    ImageRectSize = vi.ImageRectSize or Vector2.zero,
                    ImageTransparency = 0.5,
                    Position = UDim2.new(0, 8, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    Parent = item,
                })

                local btn = New("TextButton", {
                    BackgroundTransparency = 1,
                    Position = vi and UDim2.fromOffset(30, 0) or UDim2.fromOffset(0, 0),
                    Size = vi and UDim2.new(1, -30, 1, 0) or UDim2.fromScale(1, 1),
                    Text = fmt,
                    TextSize = 14,
                    TextTransparency = 0.5,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = item,
                })
                New("UIPadding", { PaddingLeft = UDim.new(0, vi and 0 or 10), PaddingRight = UDim.new(0, 10), Parent = btn })

                function tbl:UpdateButton()
                    local sel = isValSel(v)
                    item.BackgroundTransparency = sel and 0 or 1
                    stroke.Transparency = sel and 0.2 or 0.7
                    btn.TextTransparency = dis and 0.8 or sel and 0 or 0.4
                    if img then img.ImageTransparency = dis and 0.8 or sel and 0 or 0.4 end
                end

                tbl.Value = v

                if not dis then
                    btn.MouseEnter:Connect(function()
                        if isValSel(v) then return end
                        TweenService:Create(item, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                    end)
                    btn.MouseLeave:Connect(function()
                        if isValSel(v) then return end
                        TweenService:Create(item, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                    end)
                    btn.MouseButton1Click:Connect(function()
                        togVal(v)
                        if not d.Multi then o:Collapse() end
                    end)
                end

                tbl:UpdateButton()
                expBtns[btn] = tbl
            end

            expG.CellSize = UDim2.new(1 / cols, -6 * (cols - 1) / cols, 0, 28)
            expEL.Visible = cnt == 0
        end

        local expanded = false
        local expFade, expScTw

        local function sExpT()
            if expFade then StopTween(expFade, true) expFade = nil end
            if expScTw then StopTween(expScTw, true) expScTw = nil end
        end

        function o:Expand()
            if o.Disabled or d.Expandable == false or expanded then return end
            bExpP()
            if not expO then return end
            if Library.ActiveExpandedDropdown and Library.ActiveExpandedDropdown ~= o then
                Library.ActiveExpandedDropdown:Collapse()
            end

            mt:Close()
            if expSB then expSB.Text = "" end
            expanded = true
            Library.ActiveExpandedDropdown = o
            rExpL()
            sExpT()

            expO.BackgroundTransparency = 1
            expSc.Scale = 0.94
            expO.Visible = true

            expFade = TweenService:Create(expO, DROPDOWN_EXPAND_TWEEN, { BackgroundTransparency = 0.5 })
            expScTw = TweenService:Create(expSc, DROPDOWN_EXPAND_TWEEN, { Scale = 1 })
            expFade:Play()
            expScTw:Play()
        end

        function o:Collapse()
            if not expanded or not expO then return end
            expanded = false
            if Library.ActiveExpandedDropdown == o then
                Library.ActiveExpandedDropdown = nil
            end
            sExpT()

            expFade = TweenService:Create(expO, DROPDOWN_EXPAND_TWEEN, { BackgroundTransparency = 1 })
            expScTw = TweenService:Create(expSc, DROPDOWN_EXPAND_TWEEN, { Scale = 0.96 })

            expFade.Completed:Once(function(st)
                if st == Enum.PlaybackState.Cancelled or expanded then return end
                expO.Visible = false
            end)
            expFade:Play()
            expScTw:Play()
        end

        function o:IsExpanded() return expanded end

        function o:ToggleExpanded()
            if o:IsExpanded() then o:Collapse() else o:Expand() end
        end

        function o:SetValue(val)
            if d.Multi then
                local t = {}
                for k, act in val or {} do
                    if typeof(act) ~= "boolean" then
                        t[act] = true
                    elseif act and vE(k, o.Values) then
                        t[k] = true
                    end
                end
                o.Value = t
            else
                if vE(val, o.Values) then
                    o.Value = val
                elseif not val then
                    o.Value = nil
                end
            end

            o:Display()
            refAllBtns()

            if not o.Disabled then
                Library:UpdateDependencyBoxes()
                o:RunChanged()
            end
        end

        function o:SetValues(val)
            o.Values = val
            local chg = false
            if d.Multi then
                for k in o.Value do
                    if not vE(k, o.Values) then o.Value[k] = nil chg = true end
                end
            elseif o.Value ~= nil and not vE(o.Value, o.Values) then
                o.Value = nil
                chg = true
            end

            o:BuildDropdownList()
            if expanded then rExpL() end
            o:Display()

            if chg and not o.Disabled then
                Library:UpdateDependencyBoxes()
                o:RunChanged()
            end
        end

        function o:AddValues(val)
            if typeof(val) ~= "table" and typeof(val) ~= "string" then return end
            local isD = not IsSequentialArray(o.Values)
            if isD then
                if typeof(val) == "string" then
                    o.Values[val] = val
                elseif IsSequentialArray(val) then
                    for _, v in val do o.Values[v] = v end
                else
                    for k, v in val do o.Values[k] = v end
                end
            else
                if typeof(val) == "table" then
                    for _, v in val do table.insert(o.Values, v) end
                else
                    table.insert(o.Values, val)
                end
            end
            o:BuildDropdownList()
            if expanded then rExpL() end
        end

        function o:SetDisabledValues(dis)
            o.DisabledValues = dis
            o:BuildDropdownList()
            if expanded then rExpL() end
        end

        function o:AddDisabledValues(dis)
            if typeof(dis) == "table" then
                for _, v in dis do table.insert(o.DisabledValues, v) end
            elseif typeof(dis) == "string" then
                table.insert(o.DisabledValues, dis)
            else
                return
            end
            o:BuildDropdownList()
            if expanded then rExpL() end
        end

        function o:SetValueImages(vi)
            if typeof(vi) ~= "table" then return end
            o.ValueImages = vi
            o:BuildDropdownList()
            if expanded then rExpL() end
        end

        function o:AddValueImages(vi)
            if typeof(vi) ~= "table" then return end
            for k, v in vi do o.ValueImages[k] = v end
            o:BuildDropdownList()
            if expanded then rExpL() end
        end

        function o:SetDisabled(dis)
            o.Disabled = dis
            if o.TooltipTable then o.TooltipTable.Disabled = o.Disabled end
            mt:Close()
            o:Collapse()
            db.Active = not o.Disabled
            o:UpdateColors()
        end

        function o:SetVisible(vis)
            o.Visible = vis
            h.Visible = o.Visible
            g:Resize()
        end

        function o:SetText(txt)
            o.Text = txt
            h.Size = UDim2.new(1, 0, 0, txt and 39 or 21)
            l.Text = txt and txt or ""
            l.Visible = not not txt
        end

        function o:SetDragSelect(val)
            if not d.Multi or Library.IsMobile then val = false end
            o.DragSelect = val == true
            o:BuildDropdownList()
        end

        local function tDD()
            if o.Disabled then return end
            mt:Toggle()
        end

        table.insert(o.Connections, dc.MouseButton1Click:Connect(tDD))
        table.insert(o.Connections, db.MouseButton1Click:Connect(tDD))
        if sb then
            table.insert(o.Connections, sb:GetPropertyChangedSignal("Text"):Connect(function()
                o:BuildDropdownList()
            end))
        end

        local dflts = (function()
            local r = {}
            local df = d.Default
            if df == nil then return r end
            local isD = not IsSequentialArray(o.Values)
            local function rO(cnd)
                if isD then return o.Values[cnd] ~= nil and cnd or nil end
                for _, ex in o.Values do if ex == cnd then return ex end end
                return nil
            end
            local dt = typeof(df)
            if dt == "string" then
                local v = rO(df)
                if v ~= nil then table.insert(r, v) end
            elseif dt == "table" then
                for _, cnd in df do
                    local v = rO(cnd)
                    if v ~= nil then table.insert(r, v) end
                end
            elseif o.Values[df] ~= nil then
                table.insert(r, isD and df or o.Values[df])
            end
            return r
        end)()

        for _, sv in dflts do
            if d.Multi then o.Value[sv] = true else o.Value = sv break end
        end

        if typeof(o.Tooltip) == "string" or typeof(o.DisabledTooltip) == "string" then
            o.TooltipTable = Library:AddTooltip(o.Tooltip, o.DisabledTooltip, dc)
            o.TooltipTable.Disabled = o.Disabled
        end

        if eb then
            table.insert(o.Connections, eb.MouseButton1Click:Connect(function()
                o:ToggleExpanded()
            end))
        end

        o:UpdateColors()
        o:Display()
        o:BuildDropdownList()
        g:Resize()

        o.Holder = h
        table.insert(g.Elements, o)
        o.Default = dflts
        o.DefaultValues = o.Values
        Options[i] = o

        function o:Destroy()
            o.Destroyed = true
            sDS()
            o:Collapse()
            if o.Connections then
                for _, cn in o.Connections do cn:Disconnect() end
            end
            if o.TooltipTable then o.TooltipTable:Destroy() end
            if mt then mt:Destroy() end
            if expO then expO:Destroy() end
            if h then h:Destroy() end
            local eIdx = table.find(g.Elements, o)
            if eIdx then table.remove(g.Elements, eIdx) end
            g:Resize()
            Options[i] = nil
        end

        return o
    end

    function Funcs:AddList(Idx, Info)
        Info = Library:Validate(Info, {
            Title = "",
            Values = {},
            Height = 150,
            Default = nil,
            Callback = function() end,
            Visible = true,
        })

        local Groupbox = self
        local Container = Groupbox.Container

        local List = {
            Values = Info.Values,
            Value = nil,
            Buttons = {},
            Callback = Info.Callback,
            Type = "List",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, (Info.Title ~= "" and 20 or 0) + Info.Height),
            Visible = Info.Visible,
            Parent = Container,
        })

        if Info.Title ~= "" then
            New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Text = Info.Title,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Holder,
            })
        end

        local Box = New("ScrollingFrame", {
            BackgroundColor3 = "MainColor",
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, Info.Title ~= "" and 20 or 0),
            Size = UDim2.new(1, 0, 0, Info.Height),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = "OutlineColor",
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = Holder,
        })
        
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius/2), Parent = Box }))
        New("UIStroke", { Color = "OutlineColor", Parent = Box })

        local ListLayout = New("UIListLayout", { Parent = Box })

        function List:BuildList()
            for _, btn in pairs(List.Buttons) do btn:Destroy() end
            table.clear(List.Buttons)

            for _, val in ipairs(List.Values) do
                local Button = New("TextButton", {
                    BackgroundColor3 = "AccentColor",
                    BackgroundTransparency = 1, 
                    Size = UDim2.new(1, 0, 0, 25),
                    Text = tostring(val),
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = Box,
                })
                New("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = Button })
                table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius/2), Parent = Button }))

                Button.MouseButton1Click:Connect(function()
                    List:SetValue(val)
                end)

                List.Buttons[val] = Button
            end
            if List.Value then List:SetValue(List.Value) end
        end

        function List:SetValue(val)
            List.Value = val
            for item, btn in pairs(List.Buttons) do
                local isSelected = (item == val)
                btn.BackgroundTransparency = isSelected and 0.4 or 1
                btn.TextColor3 = isSelected and Color3.new(1,1,1) or Library.Scheme.FontColor
            end
            Library:SafeCallback(List.Callback, val)
        end

        function List:SetValues(newValues)
            List.Values = newValues
            List:BuildList()
        end

        List:BuildList()
        if Info.Default then List:SetValue(Info.Default) end
        
        Groupbox:Resize()
        table.insert(Groupbox.Elements, List)
        Options[Idx] = List
        return List
    end

    local function normList(src, opts)
        local res = {}
        local seen = {}
        if typeof(src) == "table" then
            for _, v in src do
                local s = tostring(v)
                if not seen[s] then
                    seen[s] = true
                    table.insert(res, s)
                end
            end
        end
        if typeof(opts) == "table" then
            for _, v in opts do
                local s = tostring(v)
                if not seen[s] then
                    seen[s] = true
                    table.insert(res, s)
                end
            end
        end
        return res
    end

    function Funcs:AddPriorityList(i, d)
        if self.Destroyed then return nil end
        d = Library:Validate(d, Templates.PriorityList)
        local g = self
        local c = g.Container

        local o = {
            Connections = {},
            Destroyed = false,
            Text = d.Text,
            Values = d.Values or {},
            Value = normList(d.Default, d.Values),
            Tooltip = d.Tooltip,
            DisabledTooltip = d.DisabledTooltip,
            TooltipTable = nil,
            Callback = d.Callback,
            Changed = d.Changed,
            Disabled = d.Disabled,
            Visible = d.Visible,
            Type = "PriorityList",
        }

        local h = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = o.Visible,
            Parent = c,
        })
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = h })

        local l = New("TextLabel", {
            BackgroundTransparency = 1,
            LayoutOrder = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Text = o.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not not d.Text,
            Parent = h,
        })

        local hb = New("TextButton", {
            BackgroundColor3 = "MainColor",
            LayoutOrder = 2,
            Size = UDim2.new(1, 0, 0, 24),
            Text = "",
            Parent = h,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = hb }))
        New("UIStroke", { Color = "OutlineColor", Parent = hb })
        New("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 24), Parent = hb })

        local ht = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 13,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = hb,
        })

        local hbx = New("TextBox", {
            BackgroundTransparency = 1,
            ClearTextOnFocus = false,
            PlaceholderText = "Search...",
            Size = UDim2.fromScale(1, 1),
            Text = "",
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            Parent = hb,
        })

        local ai = New("ImageLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            Image = ArrowIcon and ArrowIcon.Url or "",
            ImageColor3 = "FontColor",
            ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
            ImageTransparency = 0.5,
            Position = UDim2.new(1, 18, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Parent = hb,
        })

        local lf = New("Frame", {
            BackgroundColor3 = "BackgroundColor",
            ClipsDescendants = true,
            LayoutOrder = 3,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = h,
        })
        table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = lf }))
        New("UIStroke", { Color = "OutlineColor", Parent = lf })
        local lfp = New("UIPadding", { PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), Parent = lf })

        local cards = {}
        local open = false
        local openTw = nil
        local cStride = 30
        local isDrag = false
        local dCard = nil
        local dIdx = 1
        local dStY = 0
        local dCardStY = 0

        local function uSummary()
            local list = o.Value or {}
            ht.Text = #list > 0 and table.concat(list, " > ") or "None"
        end

        local function gFullH()
            local vCnt = 0
            for _, c in cards do
                if c.f.Visible then vCnt += 1 end
            end
            return vCnt * cStride + 8
        end

        local function twH(tgH, onDone)
            if openTw then StopTween(openTw, true) openTw = nil end
            openTw = TweenService:Create(lf, Library.TweenInfo, { Size = UDim2.new(1, 0, 0, tgH) })
            if onDone then
                local c; c = openTw.Completed:Once(function()
                    if c then c:Disconnect() end
                    onDone()
                end)
            end
            openTw:Play()
            task.defer(function() g:Resize() end)
        end

        local function setOpen(st)
            if o.Disabled then return end
            open = st
            ai.Rotation = open and 180 or 0
            ai.ImageTransparency = open and 0 or 0.5
            if open then
                lf.Size = UDim2.new(1, 0, 0, 0)
                lf.Visible = true
                ht.Visible = false
                hbx.Visible = true
                hbx.Text = ""
                twH(gFullH())
            else
                twH(0, function()
                    lf.Visible = false
                    ht.Visible = true
                    hbx.Visible = false
                end)
            end
        end

        local function uCardLbl(idx)
            local itm = cards[idx]
            if not itm then return end
            itm.l.Text = string.format("<b>%d.</b> %s", idx, itm.name)
            itm.tb.Text = tostring(idx)
        end

        local function swap(oI, nI)
            if oI == nI or oI < 1 or oI > #o.Value or nI < 1 or nI > #o.Value then return end
            local c1 = cards[oI]
            local c2 = cards[nI]
            if not c1 or not c2 then return end

            local tv = o.Value[oI]
            o.Value[oI] = o.Value[nI]
            o.Value[nI] = tv

            cards[oI] = c2
            cards[nI] = c1

            uCardLbl(oI)
            uCardLbl(nI)
            uSummary()

            TweenService:Create(c1.f, Library.TweenInfo, { Position = UDim2.fromOffset(0, (nI - 1) * cStride) }):Play()
            TweenService:Create(c2.f, Library.TweenInfo, { Position = UDim2.fromOffset(0, (oI - 1) * cStride) }):Play()

            Library:SafeCallback(o.Callback, o.Value)
            Library:SafeCallback(o.Changed, o.Value)
        end

        local function rebuildCards()
            for _, itm in cards do itm.f:Destroy() end
            table.clear(cards)

            for idx, val in ipairs(o.Value) do
                local cf = New("Frame", {
                    BackgroundColor3 = "MainColor",
                    Position = UDim2.fromOffset(0, (idx - 1) * cStride),
                    Size = UDim2.new(1, 0, 0, 26),
                    ZIndex = 2,
                    Parent = lf,
                })
                table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = cf }))
                local cfs = New("UIStroke", { Color = "OutlineColor", Parent = cf })

                local cl = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -52, 1, 0),
                    Text = string.format("<b>%d.</b> %s", idx, tostring(val)),
                    TextSize = 13,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 3,
                    Parent = cf,
                })

                local tbw = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = "BackgroundColor",
                    Position = UDim2.new(1, -4, 0.5, 0),
                    Size = UDim2.fromOffset(36, 18),
                    ZIndex = 3,
                    Parent = cf,
                })
                table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = tbw }))
                New("UIStroke", { Color = "OutlineColor", Parent = tbw })

                local tb = New("TextBox", {
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    Size = UDim2.fromScale(1, 1),
                    Text = tostring(idx),
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    ZIndex = 4,
                    Parent = tbw,
                })

                local function gIdx()
                    for i, itm in ipairs(cards) do
                        if itm.f == cf then return i end
                    end
                    return idx
                end

                table.insert(o.Connections, tb:GetPropertyChangedSignal("Text"):Connect(function()
                    local cln = string.gsub(tb.Text, "%D", "")
                    if cln ~= tb.Text then tb.Text = cln end
                end))

                table.insert(o.Connections, tb.FocusLost:Connect(function()
                    local cur = gIdx()
                    local np = tonumber(tb.Text)
                    if np and np >= 1 and np <= #o.Value and np ~= cur then
                        swap(cur, np)
                    else
                        tb.Text = tostring(cur)
                    end
                end))

                table.insert(o.Connections, cf.InputBegan:Connect(function(inp)
                    if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and not isDrag and not tb:IsFocused() then
                        local cur = gIdx()
                        isDrag = true
                        dCard = cf
                        dIdx = cur
                        dStY = inp.Position.Y
                        dCardStY = (cur - 1) * cStride
                        cf.ZIndex = 25
                        TweenService:Create(cfs, Library.TweenInfo, { Color = Library.Scheme.AccentColor }):Play()

                        for _, side in Library:GetActiveSides() do side.ScrollingEnabled = false end

                        local endC
                        endC = UserInputService.InputEnded:Connect(function(eInp)
                            if eInp.UserInputType == Enum.UserInputType.MouseButton1 or eInp.UserInputType == Enum.UserInputType.Touch then
                                isDrag = false
                                endC:Disconnect()
                                cf.ZIndex = 2
                                TweenService:Create(cfs, Library.TweenInfo, { Color = Library.Scheme.OutlineColor }):Play()

                                for _, side in Library:GetActiveSides() do side.ScrollingEnabled = true end

                                local cy = cf.Position.Y.Offset
                                local tg = math.clamp(math.floor((cy + cStride / 2) / cStride) + 1, 1, #o.Value)
                                if tg ~= dIdx then
                                    swap(dIdx, tg)
                                else
                                    TweenService:Create(cf, Library.TweenInfo, { Position = UDim2.fromOffset(0, (dIdx - 1) * cStride) }):Play()
                                end
                                dCard = nil
                            end
                        end)
                    end
                end))

                table.insert(cards, { f = cf, s = cfs, l = cl, tb = tb, name = tostring(val) })
            end

            if open then twH(gFullH()) end
        end

        table.insert(o.Connections, UserInputService.InputChanged:Connect(function(inp)
            if isDrag and dCard and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local dy = inp.Position.Y - dStY
                local maxB = math.max(0, (#o.Value - 1) * cStride)
                local clpY = math.clamp(dCardStY + dy, 0, maxB)
                dCard.Position = UDim2.fromOffset(0, clpY)
            end
        end))

        local function flt(q)
            local lq = string.lower(q or "")
            local vIdx = 0
            for _, itm in ipairs(cards) do
                local m = lq == "" or string.find(string.lower(itm.name), lq, 1, true) ~= nil
                itm.f.Visible = m
                if m then
                    itm.f.Position = UDim2.fromOffset(0, vIdx * cStride)
                    vIdx += 1
                end
            end
            if open then twH(math.max(vIdx * cStride + 8, 32)) end
        end

        table.insert(o.Connections, hbx:GetPropertyChangedSignal("Text"):Connect(function() flt(hbx.Text) end))
        table.insert(o.Connections, hb.MouseButton1Click:Connect(function() setOpen(not open) end))

        function o:SetValue(val)
            if typeof(val) ~= "table" then return end
            o.Value = normList(val, o.Values)
            uSummary()
            rebuildCards()
            Library:SafeCallback(o.Callback, o.Value)
            Library:SafeCallback(o.Changed, o.Value)
        end

        function o:SetValues(val)
            if typeof(val) ~= "table" then return end
            o.Values = val
            o.Value = normList(o.Value, val)
            uSummary()
            rebuildCards()
            Library:SafeCallback(o.Callback, o.Value)
            Library:SafeCallback(o.Changed, o.Value)
        end

        function o:GetValue()
            return o.Value
        end

        function o:SetDisabled(dis)
            o.Disabled = dis
            if o.TooltipTable then o.TooltipTable.Disabled = o.Disabled end
            if o.Disabled and open then setOpen(false) end
            hb.Active = not o.Disabled
            ht.TextTransparency = o.Disabled and 0.8 or 0
            l.TextTransparency = o.Disabled and 0.8 or 0
            ai.ImageTransparency = o.Disabled and 0.8 or (open and 0 or 0.5)
        end

        function o:SetVisible(vis)
            o.Visible = vis
            h.Visible = o.Visible
            g:Resize()
        end

        function o:OnChanged(fn)
            o.Changed = fn
        end

        if typeof(o.Tooltip) == "string" or typeof(o.DisabledTooltip) == "string" then
            o.TooltipTable = Library:AddTooltip(o.Tooltip, o.DisabledTooltip, hb)
            o.TooltipTable.Disabled = o.Disabled
        end

        uSummary()
        rebuildCards()
        g:Resize()

        o.Holder = h
        table.insert(g.Elements, o)
        o.Default = d.Default or o.Value
        Options[i] = o

        function o:Destroy()
            o.Destroyed = true
            if openTw then StopTween(openTw, true) openTw = nil end
            if o.Connections then
                for _, cn in o.Connections do cn:Disconnect() end
            end
            if o.TooltipTable then o.TooltipTable:Destroy() end
            if h then h:Destroy() end
            local eIdx = table.find(g.Elements, o)
            if eIdx then table.remove(g.Elements, eIdx) end
            g:Resize()
            Options[i] = nil
        end

        return o
    end

    Funcs.AddPriorityDropdown = Funcs.AddPriorityList

    function Funcs:AddViewport(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Viewport)

        local Groupbox = self
        local Container = Groupbox.Container

        local Dragging, Pinching = false, false
        local LastMousePos, LastPinchDist = nil, 0

        local ViewportObject = Info.Object
        if Info.Clone and typeof(Info.Object) == "Instance" then
            if Info.Object.Archivable then
                ViewportObject = ViewportObject:Clone()
            else
                Info.Object.Archivable = true
                ViewportObject = ViewportObject:Clone()
                Info.Object.Archivable = false
            end
        end

        local Viewport = {
            Connections = {},
            Destroyed = false,

            Object = ViewportObject :: PVInstance,
            Camera = if not Info.Camera then Instance.new("Camera") else Info.Camera,
            Interactive = Info.Interactive,
            AutoFocus = Info.AutoFocus,
            Visible = Info.Visible,
            Type = "Viewport",
        }

        assert(
            typeof(Viewport.Object) == "Instance" and (Viewport.Object:IsA("BasePart") or Viewport.Object:IsA("Model")),
            "Instance must be a BasePart or Model."
        )

        assert(
            typeof(Viewport.Camera) == "Instance" and Viewport.Camera:IsA("Camera"),
            "Camera must be a valid Camera instance."
        )

        local function GetModelSize(model)
            if model:IsA("BasePart") then
                return model.Size
            end

            return select(2, model:GetBoundingBox())
        end

        local function FocusCamera()
            local ModelSize = GetModelSize(Viewport.Object)
            local MaxExtent = math.max(ModelSize.X, ModelSize.Y, ModelSize.Z)
            local CameraDistance = MaxExtent * 2
            local ModelPosition = (Viewport.Object :: PVInstance):GetPivot().Position

            Viewport.Camera.CFrame = CFrame.new(ModelPosition + Vector3.new(0, MaxExtent / 2, CameraDistance), ModelPosition)
        end

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Viewport.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ViewportFrame = New("ViewportFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = Box,
            CurrentCamera = Viewport.Camera,
            Active = Viewport.Interactive,
        })

        table.insert(Viewport.Connections, ViewportFrame.MouseEnter:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = false
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.MouseLeave:Connect(function()
            if not Viewport.Interactive then
                return
            end

            for _, Side in Groupbox.Tab.Sides do
                Side.ScrollingEnabled = true
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputBegan:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = true
                LastMousePos = input.Position
            elseif input.UserInputType == Enum.UserInputType.Touch and not Pinching then
                Dragging = true
                LastMousePos = input.Position
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputEnded:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                Dragging = false
            elseif input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
            end
        end))

        table.insert(Viewport.Connections, UserInputService.InputChanged:Connect(function(input)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Dragging or Pinching then
                return
            end

            if
                input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch
            then
                local MouseDelta = input.Position - LastMousePos
                LastMousePos = input.Position

                local Position = (Viewport.Object :: PVInstance):GetPivot().Position
                local Camera = Viewport.Camera

                local RotationY = CFrame.fromAxisAngle(Vector3.new(0, 1, 0), -MouseDelta.X * 0.01)
                Camera.CFrame = CFrame.new(Position) * RotationY * CFrame.new(-Position) * Camera.CFrame

                local RotationX = CFrame.fromAxisAngle(Camera.CFrame.RightVector, -MouseDelta.Y * 0.01)
                local PitchedCFrame = CFrame.new(Position) * RotationX * CFrame.new(-Position) * Camera.CFrame

                if PitchedCFrame.UpVector.Y > 0.1 then
                    Camera.CFrame = PitchedCFrame
                end
            end
        end))

        table.insert(Viewport.Connections, ViewportFrame.InputChanged:Connect(function(input)
            if not Viewport.Interactive then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local ZoomAmount = input.Position.Z * 2
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * ZoomAmount
            end
        end))

        table.insert(Viewport.Connections, UserInputService.TouchPinch:Connect(function(touchPositions, scale, velocity, state)
            if Library.Unloaded then
                return
            end

            if not Viewport.Interactive or not Library:MouseIsOverFrame(ViewportFrame, touchPositions[1]) then
                return
            end

            if state == Enum.UserInputState.Begin then
                Pinching = true
                Dragging = false
                LastPinchDist = (touchPositions[1] - touchPositions[2]).Magnitude
            elseif state == Enum.UserInputState.Change then
                local currentDist = (touchPositions[1] - touchPositions[2]).Magnitude
                local delta = (currentDist - LastPinchDist) * 0.1
                LastPinchDist = currentDist
                Viewport.Camera.CFrame += Viewport.Camera.CFrame.LookVector * delta
            elseif state == Enum.UserInputState.End or state == Enum.UserInputState.Cancel then
                Pinching = false
            end
        end))

        ;(Viewport.Object :: PVInstance).Parent = ViewportFrame
        if Viewport.AutoFocus then
            FocusCamera()
        end

        function Viewport:SetObject(Object: Instance, Clone: boolean?)
            assert(Object, "Object cannot be nil.")

            if Clone then
                Object = Object:Clone()
            end

            if Viewport.Object then
                Viewport.Object:Destroy()
            end

            Viewport.Object = Object
            ;(Viewport.Object :: PVInstance).Parent = ViewportFrame

            Groupbox:Resize()
        end

        function Viewport:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Viewport:Focus()
            if not Viewport.Object then
                return
            end

            FocusCamera()
        end

        function Viewport:SetCamera(Camera: Instance)
            assert(
                Camera and typeof(Camera) == "Instance" and Camera:IsA("Camera"),
                "Camera must be a valid Camera instance."
            )

            Viewport.Camera = Camera
            ViewportFrame.CurrentCamera = Camera
        end

        function Viewport:SetInteractive(Interactive: boolean)
            Viewport.Interactive = Interactive
            ViewportFrame.Active = Interactive
        end

        function Viewport:SetVisible(Visible: boolean)
            Viewport.Visible = Visible

            Holder.Visible = Viewport.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Viewport.Holder = Holder
        table.insert(Groupbox.Elements, Viewport)

        Options[Idx] = Viewport

        function Viewport:Destroy()
            Viewport.Destroyed = true

            if Viewport.Connections then
                for _, Connection in Viewport.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Viewport)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Viewport
    end

    function Funcs:AddImage(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Image)

        local Groupbox = self
        local Container = Groupbox.Container

        local Image = {
            Connections = {},
            Destroyed = false,

            Image = Info.Image,
            Color = Info.Color,
            RectOffset = Info.RectOffset,
            RectSize = Info.RectSize,
            Height = Info.Height,
            ScaleType = Info.ScaleType,
            Transparency = Info.Transparency,
            BackgroundTransparency = Info.BackgroundTransparency,

            Visible = Info.Visible,
            Type = "Image",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Image.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            BackgroundTransparency = Image.BackgroundTransparency,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local ImageProperties = {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Image = Image.Image,
            ImageTransparency = Image.Transparency,
            ImageColor3 = Image.Color,
            ImageRectOffset = Image.RectOffset,
            ImageRectSize = Image.RectSize,
            ScaleType = Image.ScaleType,
            Parent = Box,
        }

        local Icon = Library:GetCustomIcon(ImageProperties.Image)
        assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        ImageProperties.Image = Icon.Url
        ImageProperties.ImageRectOffset = Icon.ImageRectOffset
        ImageProperties.ImageRectSize = Icon.ImageRectSize

        local ImageLabel = New("ImageLabel", ImageProperties)

        function Image:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Image.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Image:SetImage(NewImage: string)
            assert(typeof(NewImage) == "string", "Image must be a string.")

            local Icon = Library:GetCustomIcon(NewImage)
            assert(Icon, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

            NewImage = Icon.Url
            Image.RectOffset = Icon.ImageRectOffset
            Image.RectSize = Icon.ImageRectSize

            ImageLabel.Image = NewImage
            Image.Image = NewImage
        end

        function Image:SetColor(Color: Color3)
            assert(typeof(Color) == "Color3", "Color must be a Color3 value.")

            ImageLabel.ImageColor3 = Color
            Image.Color = Color
        end

        function Image:SetRectOffset(RectOffset: Vector2)
            assert(typeof(RectOffset) == "Vector2", "RectOffset must be a Vector2 value.")

            ImageLabel.ImageRectOffset = RectOffset
            Image.RectOffset = RectOffset
        end

        function Image:SetRectSize(RectSize: Vector2)
            assert(typeof(RectSize) == "Vector2", "RectSize must be a Vector2 value.")

            ImageLabel.ImageRectSize = RectSize
            Image.RectSize = RectSize
        end

        function Image:SetScaleType(ScaleType: Enum.ScaleType)
            assert(
                typeof(ScaleType) == "EnumItem" and ScaleType:IsA("ScaleType"),
                "ScaleType must be a valid Enum.ScaleType."
            )

            ImageLabel.ScaleType = ScaleType
            Image.ScaleType = ScaleType
        end

        function Image:SetTransparency(Transparency: number)
            assert(typeof(Transparency) == "number", "Transparency must be a number between 0 and 1.")
            assert(Transparency >= 0 and Transparency <= 1, "Transparency must be between 0 and 1.")

            ImageLabel.ImageTransparency = Transparency
            Image.Transparency = Transparency
        end

        function Image:SetVisible(Visible: boolean)
            Image.Visible = Visible

            Holder.Visible = Image.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Image.Holder = Holder
        table.insert(Groupbox.Elements, Image)

        Options[Idx] = Image

        function Image:Destroy()
            Image.Destroyed = true

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Image)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Image
    end

    function Funcs:AddVideo(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.Video)

        local Groupbox = self
        local Container = Groupbox.Container

        local Video = {
            Connections = {},
            Destroyed = false,

            Video = Info.Video,
            Looped = Info.Looped,
            Playing = Info.Playing,
            Volume = Info.Volume,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "Video",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Video.Visible,
            Parent = Container,
        })

        local Box = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
            BorderSizePixel = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.fromScale(1, 1),
            Parent = Holder,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 3),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            Parent = Box,
        })

        local VideoFrameInstance = New("VideoFrame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Video = Video.Video,
            Looped = Video.Looped,
            Volume = Video.Volume,
            Parent = Box,
        })

        VideoFrameInstance.Playing = Video.Playing

        function Video:SetHeight(Height: number)
            assert(Height > 0, "Height must be greater than 0.")

            Video.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Video:SetVideo(NewVideo: string)
            assert(typeof(NewVideo) == "string", "Video must be a string.")

            VideoFrameInstance.Video = NewVideo
            Video.Video = NewVideo
        end

        function Video:SetLooped(Looped: boolean)
            assert(typeof(Looped) == "boolean", "Looped must be a boolean.")

            VideoFrameInstance.Looped = Looped
            Video.Looped = Looped
        end

        function Video:SetVolume(Volume: number)
            assert(typeof(Volume) == "number", "Volume must be a number between 0 and 10.")

            VideoFrameInstance.Volume = Volume
            Video.Volume = Volume
        end

        function Video:SetPlaying(Playing: boolean)
            assert(typeof(Playing) == "boolean", "Playing must be a boolean.")

            VideoFrameInstance.Playing = Playing
            Video.Playing = Playing
        end

        function Video:Play()
            VideoFrameInstance.Playing = true
            Video.Playing = true
        end

        function Video:Pause()
            VideoFrameInstance.Playing = false
            Video.Playing = false
        end

        function Video:SetVisible(Visible: boolean)
            Video.Visible = Visible

            Holder.Visible = Video.Visible
            Groupbox:Resize()
        end

        Groupbox:Resize()

        Video.Holder = Holder
        Video.VideoFrame = VideoFrameInstance
        table.insert(Groupbox.Elements, Video)

        Options[Idx] = Video

        function Video:Destroy()
            Video.Destroyed = true

            if Video.Connections then
                for _, Connection in Video.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Video)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Video
    end

    function Funcs:AddUIPassthrough(Idx, Info)
        if self.Destroyed then return nil end

        Info = Library:Validate(Info, Templates.UIPassthrough)

        local Groupbox = self
        local Container = Groupbox.Container

        assert(Info.Instance, "Instance must be provided.")
        assert(
            typeof(Info.Instance) == "Instance" and Info.Instance:IsA("GuiBase2d"),
            "Instance must inherit from GuiBase2d."
        )
        assert(typeof(Info.Height) == "number" and Info.Height > 0, "Height must be a number greater than 0.")

        local Passthrough = {
            Connections = {},
            Destroyed = false,

            Instance = Info.Instance,
            Height = Info.Height,
            Visible = Info.Visible,

            Type = "UIPassthrough",
        }

        local Holder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, Info.Height),
            Visible = Passthrough.Visible,
            Parent = Container,
        })

        Passthrough.Instance.Parent = Holder

        Groupbox:Resize()

        function Passthrough:SetHeight(Height: number)
            assert(typeof(Height) == "number" and Height > 0, "Height must be a number greater than 0.")

            Passthrough.Height = Height
            Holder.Size = UDim2.new(1, 0, 0, Height)
            Groupbox:Resize()
        end

        function Passthrough:SetInstance(Instance: Instance)
            assert(Instance, "Instance must be provided.")
            assert(
                typeof(Instance) == "Instance" and Instance:IsA("GuiBase2d"),
                "Instance must inherit from GuiBase2d."
            )

            if Passthrough.Instance then
                Passthrough.Instance.Parent = nil
            end

            Passthrough.Instance = Instance
            Passthrough.Instance.Parent = Holder
        end

        function Passthrough:SetVisible(Visible: boolean)
            Passthrough.Visible = Visible

            Holder.Visible = Passthrough.Visible
            Groupbox:Resize()
        end

        Passthrough.Holder = Holder
        table.insert(Groupbox.Elements, Passthrough)

        Options[Idx] = Passthrough

        function Passthrough:Destroy()
            Passthrough.Destroyed = true

            if Passthrough.Connections then
                for _, Connection in Passthrough.Connections do
                    Connection:Disconnect()
                end
            end

            if Holder then 
                Holder:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.Elements, Passthrough)
            if ElemIdx then 
                table.remove(Groupbox.Elements, ElemIdx) 
            end

            Groupbox:Resize()
            Options[Idx] = nil
        end

        return Passthrough
    end

    function Funcs:AddDependencyBox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Container = Groupbox.Container

        local DepboxContainer
        local DepboxList

        do
            DepboxContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = Container,
            })

            DepboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepboxContainer,
            })
        end

        local Depbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            Holder = DepboxContainer,
            Container = DepboxContainer,

            Elements = {},
            DependencyBoxes = {}
        }

        function Depbox:Resize()
            DepboxContainer.Size = UDim2.new(1, 0, 0, DepboxList.AbsoluteContentSize.Y / Library.DPIScale)
            Groupbox:Resize()
        end

        function Depbox:Update(CancelSearch)
            for _, Dependency in Depbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepboxContainer.Visible = false
                    Depbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepboxContainer.Visible = false
                            Depbox.Visible = false
                            return
                        end
                    end
                end
            end

            Depbox.Visible = true
            DepboxContainer.Visible = true
            if not Library.Searching then
                task.defer(function()
                    Depbox:Resize()
                end)
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        DepboxList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if not Depbox.Visible then
                return
            end

            Depbox:Resize()
        end)

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            Depbox.Dependencies = Dependencies
            Depbox:Update()
        end

        DepboxContainer:GetPropertyChangedSignal("Visible"):Connect(function()
            Depbox:Resize()
        end)

        setmetatable(Depbox, BaseGroupbox)

        table.insert(Groupbox.DependencyBoxes, Depbox)
        table.insert(Library.DependencyBoxes, Depbox)

        function Depbox:Destroy()
            Depbox.Destroyed = true

            if Depbox.Connections then
                for _, Connection in Depbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in Depbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in Depbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepboxContainer then 
                DepboxContainer:Destroy() 
            end

            local ElemIdx = table.find(Groupbox.DependencyBoxes, Depbox)
            if ElemIdx then 
                table.remove(Groupbox.DependencyBoxes, ElemIdx)
            end

            local LibIdx = table.find(Library.DependencyBoxes, Depbox)
            if LibIdx then 
                table.remove(Library.DependencyBoxes, LibIdx) 
            end
        end

        return Depbox
    end

    function Funcs:AddDependencyGroupbox()
        if self.Destroyed then return nil end

        local Groupbox = self
        local Tab = Groupbox.Tab
        local BoxHolder = Groupbox.BoxHolder

        local DepGroupboxContainer
        local DepGroupboxList

        do
            DepGroupboxContainer = New("Frame", {
                BackgroundColor3 = "BackgroundColor",
                Size = UDim2.fromScale(1, 0),
                Visible = false,
                Parent = BoxHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, Library.CornerRadius),
                    Parent = DepGroupboxContainer,
                })
            )
            Library:AddOutline(DepGroupboxContainer)

            DepGroupboxList = New("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = DepGroupboxContainer,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 7),
                PaddingLeft = UDim.new(0, 7),
                PaddingRight = UDim.new(0, 7),
                PaddingTop = UDim.new(0, 7),
                Parent = DepGroupboxContainer,
            })
        end

        local DepGroupbox = {
            Connections = {},
            Destroyed = false,

            Visible = false,
            Dependencies = {},

            BoxHolder = BoxHolder,
            Holder = DepGroupboxContainer,
            Container = DepGroupboxContainer,

            Tab = Tab,
            Elements = {},
            DependencyBoxes = {},
        }

        function DepGroupbox:Resize()
            DepGroupboxContainer.Size = UDim2.new(1, 0, 0, (DepGroupboxList.AbsoluteContentSize.Y / Library.DPIScale) + 18)
        end

        function DepGroupbox:Update(CancelSearch)
            for _, Dependency in DepGroupbox.Dependencies do
                local Element = Dependency[1]
                local Value = Dependency[2]

                if Element.Type == "Toggle" and Element.Value ~= Value then
                    DepGroupboxContainer.Visible = false
                    DepGroupbox.Visible = false
                    return
                elseif Element.Type == "Dropdown" then
                    if typeof(Element.Value) == "table" then
                        if not Element.Value[Value] then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    else
                        if Element.Value ~= Value then
                            DepGroupboxContainer.Visible = false
                            DepGroupbox.Visible = false
                            return
                        end
                    end
                end
            end

            DepGroupbox.Visible = true
            if not Library.Searching then
                DepGroupboxContainer.Visible = true
                DepGroupbox:Resize()
            elseif not CancelSearch then
                Library:UpdateSearch(Library.SearchText)
            end
        end

        function DepGroupbox:SetupDependencies(Dependencies)
            for _, Dependency in Dependencies do
                assert(typeof(Dependency) == "table", "Dependency should be a table.")
                assert(Dependency[1] ~= nil, "Dependency is missing element.")
                assert(Dependency[2] ~= nil, "Dependency is missing expected value.")
            end

            DepGroupbox.Dependencies = Dependencies
            DepGroupbox:Update()
        end

        setmetatable(DepGroupbox, BaseGroupbox)

        table.insert(Tab.DependencyGroupboxes, DepGroupbox)
        table.insert(Library.DependencyBoxes, DepGroupbox :: any)

        function DepGroupbox:Destroy()
            DepGroupbox.Destroyed = true

            if DepGroupbox.Connections then
                for _, Connection in DepGroupbox.Connections do
                    Connection:Disconnect()
                end
            end

            for _, Element in DepGroupbox.Elements do
                if Element.Destroy then
                    Element:Destroy()
                end
            end

            for _, SubDepbox in DepGroupbox.DependencyBoxes do
                if SubDepbox.Destroy then
                    SubDepbox:Destroy()
                end
            end

            if DepGroupboxContainer then 
                DepGroupboxContainer:Destroy() 
            end

            local ElemIdx = table.find(Tab.DependencyGroupboxes, DepGroupbox)
            if ElemIdx then 
                table.remove(Tab.DependencyGroupboxes, ElemIdx) 
            end

            local LibIdx = table.find(Library.DependencyBoxes, DepGroupbox)
            if LibIdx then 
                table.remove(Library.DependencyBoxes, LibIdx) 
            end
        end

        return DepGroupbox
    end

    BaseGroupbox.__index = Funcs
    BaseGroupbox.__namecall = function(_, Key, ...)
        return Funcs[Key](...)
    end
end

function Library:SetFont(FontFace)
    if typeof(FontFace) == "EnumItem" then
        FontFace = Font.fromEnum(FontFace :: any)
    end

    Library.Scheme.Font = FontFace
    Library:UpdateColorsUsingRegistry()
end

function Library:SetBackgroundImage(Image: string | number)
    assert(typeof(Image) == "string" or typeof(Image) == "number", "Expected string/number got " .. typeof(Image))
    
    Library.Scheme.BackgroundImage = Image
    if Library.Window then
        Library.Window:SetBackgroundImage(Image)
    end

    Library:UpdateColorsUsingRegistry()
end

function Library:UpdateNotificationPositions(Snap: boolean?)
    local IsLeft = Library.NotifySide:lower() == "left"
    local XScale = IsLeft and 0 or 1
    local RunningY = 0

    for _, FakeBackground in NotifyOrder do
        local Data = Library.Notifications[FakeBackground]
        if not (Data and FakeBackground.Parent) then continue end

        local Target = UDim2.new(XScale, 0, 0, RunningY)
        if Snap or not Data.PositionInitialized then
            FakeBackground.Position = Target
            Data.PositionInitialized = true

        elseif FakeBackground.Position ~= Target then
            TweenService:Create(FakeBackground, Library.NotifyTweenInfo, {
                Position = Target,
            }):Play()
        end

        RunningY = RunningY + FakeBackground.AbsoluteSize.Y + 8
    end
end

function Library:SetNotifySide(Side: string)
    Library.NotifySide = Side

    local IsLeft = Side:lower() == "left"
    if IsLeft then
        NotificationArea.AnchorPoint = Vector2.new(0, 0)
        NotificationArea.Position = UDim2.fromOffset(6, 6)
    else
        NotificationArea.AnchorPoint = Vector2.new(1, 0)
        NotificationArea.Position = UDim2.new(1, -6, 0, 6)
    end

    for FakeBackground in Library.Notifications do
        if not (FakeBackground and FakeBackground.Parent) then continue end
        FakeBackground.AnchorPoint = if IsLeft then Vector2.new(0, 0) else Vector2.new(1, 0)
    end

    Library:UpdateNotificationPositions(true)
end

function Library:Notify(...)
    local d = {}
    local inf = select(1, ...)

    if typeof(inf) == "table" then
        d.Title = inf.Title and tostring(inf.Title) or nil
        d.TitleColor = inf.TitleColor

        d.Description = tostring(inf.Description)
        d.DescriptionColor = inf.DescriptionColor

        d.Time = inf.Time or 5
        d.SoundId = if inf.SoundId ~= nil then inf.SoundId else Library.NotificationSound
        d.Steps = inf.Steps
        d.Persist = inf.Persist

        d.Type = inf.Type
        local tk = typeof(d.Type) == "string" and (d.Type:sub(1, 1):upper() .. d.Type:sub(2):lower()) or nil

        d.Icon = inf.Icon or (tk and Library.NotificationTypeIcons[tk]) or (d.Type and Library.NotificationTypeIcons[d.Type])
        d.BigIcon = inf.BigIcon
        d.IconColor = inf.IconColor or (tk and Library.NotificationTypeColors[tk]) or (d.Type and Library.NotificationTypeColors[d.Type])

        if not d.Title and d.Type then
            d.Title = tk or tostring(d.Type)
        end

        d.Volume = tonumber(inf.Volume) or 3
    else
        d.Description = tostring(inf)
        d.Time = select(2, ...) or 5
        d.SoundId = select(3, ...) or Library.NotificationSound
        d.Volume = select(4, ...) or 3
    end
    d.Destroyed = false

    local tc = d.Type and (Library.NotificationTypeColors[d.Type] or (d.Title and Library.NotificationTypeColors[d.Title]))
    if tc then
        if d.Title and d.Title ~= "nil" then
            d.TitleColor = d.TitleColor or tc
        else
            d.DescriptionColor = d.DescriptionColor or tc
        end
    end

    local dIns = false
    local dConn = nil
    if typeof(d.Time) == "Instance" then
        dConn = d.Time.Destroying:Connect(function()
            dIns = true
            dConn:Disconnect()
            dConn = nil
        end)
    end

    local fb = New("Frame", {
        AnchorPoint = Library.NotifySide:lower() == "left" and Vector2.new(0, 0) or Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        Visible = false,
        Parent = NotificationArea,
    })

    local h = New("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = "MainColor",
        Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
        Size = UDim2.fromScale(1, 1),
        ZIndex = 5,
        Parent = fb,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = h }))
    New("UIListLayout", { Padding = UDim.new(0, 4), Parent = h })
    New("UIPadding", { PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8), Parent = h })
    Library:AddOutline(h)

    local cc = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(1, 0),
        Parent = h,
    })

    if d.BigIcon then
        New("UIListLayout", {
            Padding = UDim.new(0, 8),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = cc,
        })
    end

    local biL
    if d.BigIcon then
        local pI = Library:GetCustomIcon(d.BigIcon)
        if pI then
            biL = New("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(24, 24),
                Image = pI.Url,
                ImageColor3 = d.IconColor or "AccentColor",
                ImageRectOffset = pI.ImageRectOffset,
                ImageRectSize = pI.ImageRectSize,
                Parent = cc,
            })
        end
    end

    local tcH = New("Frame", {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromScale(0, 0),
        Parent = cc,
    })
    New("UIListLayout", { Padding = UDim.new(0, 4), Parent = tcH })

    local ttC
    if d.Title then
        ttC = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Parent = tcH,
        })
    end

    local icL
    if d.Icon and ttC then
        local pI = Library:GetCustomIcon(d.Icon)
        if pI then
            icL = New("ImageLabel", {
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 1),
                Size = UDim2.fromOffset(15, 15),
                Image = pI.Url,
                ImageColor3 = d.IconColor or "FontColor",
                ImageRectOffset = pI.ImageRectOffset,
                ImageRectSize = pI.ImageRectSize,
                Parent = ttC,
            })
        end
    end

    local ttl, dsc
    local tX, dX = 0, 0
    local tmF

    if d.Title then
        ttl = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, (d.Icon and 21 or 0), 0.5, 0),
            Size = UDim2.fromScale(0, 0),
            Text = d.Title,
            TextColor3 = d.TitleColor or "FontColor",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true,
            Parent = ttC,
        })
    end

    if d.Description then
        dsc = New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 0),
            Text = d.Description,
            TextColor3 = d.DescriptionColor or "FontColor",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = tcH,
        })
    end

    function d:Resize()
        local eW = biL and 32 or 0
        local iW = icL and 21 or 0

        if ttl then
            local x, y = Library:GetTextBounds(ttl.Text, ttl.FontFace, ttl.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - eW - iW)
            ttl.Size = UDim2.fromOffset(x, y)
            tX = x + iW
            ttC.Size = UDim2.fromOffset(tX, math.max(y, icL and 16 or 0))
        end

        if dsc then
            local x, y = Library:GetTextBounds(dsc.Text, dsc.FontFace, dsc.TextSize, (NotificationArea.AbsoluteSize.X / Library.DPIScale) - 24 - eW)
            dsc.Size = UDim2.fromOffset(x, y)
            dX = x
        end

        fb.Size = UDim2.fromOffset(math.max(tX, dX) + 24 + eW, 0)
        if Library.Notifications[fb] then Library:UpdateNotificationPositions() end
    end

    function d:ChangeTitle(txt)
        if ttl then
            d.Title = tostring(txt)
            ttl.Text = d.Title
            d:Resize()
        end
    end

    function d:ChangeDescription(txt)
        if dsc then
            d.Description = tostring(txt)
            dsc.Text = d.Description
            d:Resize()
        end
    end

    function d:ChangeStep(st)
        if tmF and d.Steps then
            st = math.clamp(st or 0, 0, d.Steps)
            tmF.Size = UDim2.fromScale(st / d.Steps, 1)
        end
    end

    function d:Destroy()
        d.Destroyed = true
        if typeof(d.Time) == "Instance" then pcall(d.Time.Destroy, d.Time) end
        if dConn then dConn:Disconnect() end

        if fb then
            local idx = table.find(NotifyOrder, fb)
            if idx then table.remove(NotifyOrder, idx) end
        end

        Library:UpdateNotificationPositions()
        TweenService:Create(h, Library.NotifyTweenInfo, {
            Position = Library.NotifySide:lower() == "left" and UDim2.new(-1, -8, 0, -2) or UDim2.new(1, 8, 0, -2),
        }):Play()

        task.delay(Library.NotifyTweenInfo.Time, function()
            Library.Notifications[fb] = nil
            fb:Destroy()
        end)
    end

    d:Resize()

    local tmH = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 7),
        Visible = (d.Persist ~= true and typeof(d.Time) ~= "Instance") or typeof(d.Steps) == "number",
        Parent = h,
    })
    local tmB = New("Frame", {
        BackgroundColor3 = "BackgroundColor",
        BorderColor3 = "OutlineColor",
        BorderSizePixel = 1,
        Position = UDim2.fromOffset(0, 3),
        Size = UDim2.new(1, 0, 0, 2),
        Parent = tmH,
    })
    tmF = New("Frame", {
        BackgroundColor3 = "AccentColor",
        Size = UDim2.fromScale(1, 1),
        Parent = tmB,
    })

    if typeof(d.Time) == "Instance" then tmF.Size = UDim2.fromScale(0, 1) end
    if d.SoundId and d.SoundId ~= false then
        local sid = d.SoundId
        if typeof(sid) == "number" then sid = string.format("rbxassetid://%d", sid) end
        New("Sound", {
            SoundId = sid,
            Volume = tonumber(d.Volume) or 3,
            PlayOnRemove = true,
            Parent = SoundService,
        }):Destroy()
    end

    d.Holder = h
    table.insert(NotifyOrder, fb)
    Library.Notifications[fb] = d
    Library:UpdateNotificationPositions()

    fb.Visible = true
    TweenService:Create(h, Library.NotifyTweenInfo, { Position = UDim2.fromOffset(0, 0) }):Play()

    task.delay(Library.NotifyTweenInfo.Time, function()
        if d.Persist then
            return
        elseif typeof(d.Time) == "Instance" then
            repeat task.wait() until dIns or d.Destroyed
        else
            TweenService:Create(tmF, TweenInfo.new(d.Time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
                Size = UDim2.fromScale(0, 1),
            }):Play()
            task.wait(d.Time)
        end
        if not d.Destroyed then d:Destroy() end
    end)

    Library:AddNotificationToHistory({
        Title = d.Title,
        Description = d.Description,
        TitleColor = d.TitleColor,
        DescriptionColor = d.DescriptionColor,
        Icon = d.Icon,
        IconColor = d.IconColor,
        Type = d.Type,
    })

    return d
end

function Library:AddNotificationToHistory(Entry)
    if typeof(Entry) ~= "table" then
        return
    end

    Entry.Timestamp = Entry.Timestamp or os.time()
    Entry.TimeString = Entry.TimeString or os.date("%H:%M:%S", Entry.Timestamp)

    table.insert(Library.NotificationHistory, 1, Entry)

    local Limit = tonumber(Library.NotificationHistoryLimit) or 100
    while #Library.NotificationHistory > Limit do
        table.remove(Library.NotificationHistory)
    end

    if Library.NotificationHistoryOpen then
        Library:RefreshNotificationHistory()
    else
        Library.NotificationUnreadCount = (Library.NotificationUnreadCount or 0) + 1
        Library:UpdateNotificationBadge()
    end
end

function Library:UpdateNotificationBadge()
    local Count = Library.NotificationUnreadCount or 0
    local Text = Count > 99 and "99+" or tostring(Count)

    for _, Badge in Library.NotificationBadges do
        if Badge.Holder and Badge.Holder.Parent then
            Badge.Holder.Visible = Count > 0
            Badge.Label.Text = Text
        end
    end
end

function Library:GetNotificationHistory()
    return Library.NotificationHistory
end

function Library:ClearNotificationHistory()
    table.clear(Library.NotificationHistory)
    if Library.NotificationHistoryFrame and Library.NotificationHistoryFrame.Visible then
        Library:RefreshNotificationHistory()
    end
end

local NOTIFY_HISTORY_SIZE = Vector2.new(288, 328)
local NOTIFY_HISTORY_SLIDE = UDim2.fromOffset(0, -22)
local NotifyHistoryOpenTween = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local NotifyHistoryCloseTween = TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

local function GetDropPanelPos(Button, Size)
    local Camera = workspace.CurrentCamera
    local Viewport = (Camera and Camera.ViewportSize) or Vector2.new(1280, 720)
    local MaxX = math.max(6, Viewport.X - Size.X - 6)
    local MaxY = math.max(6, Viewport.Y - Size.Y - 6)

    if Button and Button.Parent then
        local ButtonPos, ButtonSize = Button.AbsolutePosition, Button.AbsoluteSize
        local X = (ButtonPos.X + ButtonSize.X) - Size.X
        local Y = ButtonPos.Y + ButtonSize.Y + 10
        return UDim2.fromOffset(math.clamp(X, 6, MaxX), math.clamp(Y, 6, MaxY))
    end

    return UDim2.fromOffset(MaxX, 56)
end

local function IsGuiEffectivelyVisible(Gui)
    local Current = Gui
    while Current and Current:IsA("GuiObject") do
        if not Current.Visible then
            return false
        end
        Current = Current.Parent
    end
    return true
end

local function PickVisibleButton(Main, Mini)
    if Mini and IsGuiEffectivelyVisible(Mini) then
        return Mini
    end
    return Main
end

local function GetNotifyHistoryDefaultPos()
    return GetDropPanelPos(PickVisibleButton(Library.NotificationBell, Library.NotificationBellMini), NOTIFY_HISTORY_SIZE)
end

function Library:_BuildNotificationHistory()
    if Library.NotificationHistoryFrame then
        return
    end

    local Holder = New("CanvasGroup", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = GetNotifyHistoryDefaultPos(),
        Size = UDim2.fromOffset(NOTIFY_HISTORY_SIZE.X, NOTIFY_HISTORY_SIZE.Y),
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = "Notification History",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 36),
        Parent = TitleLabel,
    })

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local CloseIcon = Library:GetIcon("x")
    local CloseButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 17),
        Size = UDim2.fromOffset(20, 20),
        Text = CloseIcon and "" or "X",
        TextColor3 = "FontColor",
        TextSize = 14,
        TextTransparency = 0.35,
        ZIndex = 11,
        Parent = Holder,
    })
    local CloseImage
    if CloseIcon then
        CloseImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = CloseIcon.Url,
            ImageColor3 = "FontColor",
            ImageRectOffset = CloseIcon.ImageRectOffset,
            ImageRectSize = CloseIcon.ImageRectSize,
            ImageTransparency = 0.35,
            Position = UDim2.fromScale(0.5, 0.5),
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 12,
            Parent = CloseButton,
        })
    end
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, Library.TweenInfo, { TextTransparency = 0 }):Play()
        if CloseImage then
            TweenService:Create(CloseImage, Library.TweenInfo, { ImageTransparency = 0 }):Play()
        end
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, Library.TweenInfo, { TextTransparency = 0.35 }):Play()
        if CloseImage then
            TweenService:Create(CloseImage, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
        end
    end)
    CloseButton.MouseButton1Click:Connect(function()
        Library:SetNotificationHistoryVisible(false)
    end)

    local Scroller = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        Position = UDim2.fromOffset(0, 35),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = "AccentColor",
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = Scroller,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Scroller,
    })

    Library:MakeDraggable(Holder, TitleLabel, true)
    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded or not Library.NotificationHistoryOpen then
            return
        end
        if not IsClickInput(Input, true) then
            return
        end

        local Location = Input.Position
        if Library:MouseIsOverFrame(Holder, Location) then
            return
        end
        if Library.NotificationBell and Library:MouseIsOverFrame(Library.NotificationBell, Location) then
            return
        end
        if Library.NotificationBellMini and Library:MouseIsOverFrame(Library.NotificationBellMini, Location) then
            return
        end

        Library:SetNotificationHistoryVisible(false)
    end))

    Library.NotificationHistoryFrame = Holder
    Library.NotificationHistoryContainer = Scroller
    Library.NotificationHistoryRestPos = Holder.Position
end

function Library:RefreshNotificationHistory()
    Library:_BuildNotificationHistory()

    local Scroller = Library.NotificationHistoryContainer
    for _, Child in Scroller:GetChildren() do
        if not (Child:IsA("UIListLayout") or Child:IsA("UIPadding")) then
            Child:Destroy()
        end
    end

    if #Library.NotificationHistory == 0 then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Text = "No notifications yet.",
            TextColor3 = "FontColor",
            TextTransparency = 0.4,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Scroller,
        })
        return
    end

    local ClipboardIcon = Library:GetIcon("copy")
    local ClipboardCheckIcon = Library:GetIcon("clipboard-check") or Library:GetIcon("check")
    local SuccessColor = Library.NotificationTypeColors.Success or Color3.fromRGB(96, 216, 118)
    local Clipboard = (setclipboard or (typeof(toclipboard) == "function" and toclipboard) or (typeof(writeclipboard) == "function" and writeclipboard))

    for _, Entry in Library.NotificationHistory do
        local Card = New("TextButton", {
            AutomaticSize = Enum.AutomaticSize.Y,
            AutoButtonColor = false,
            BackgroundColor3 = "MainColor",
            Size = UDim2.new(1, 0, 0, 0),
            Text = "",
            Parent = Scroller,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Card,
        })
        Library:AddOutline(Card)

        local Content = New("Frame", {
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Parent = Card,
        })
        New("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = Content,
        })
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 24),
            PaddingTop = UDim.new(0, 6),
            Parent = Content,
        })

        local CopyImage
        if ClipboardIcon then
            CopyImage = New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Image = ClipboardIcon.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = ClipboardIcon.ImageRectOffset,
                ImageRectSize = ClipboardIcon.ImageRectSize,
                ImageTransparency = 0.55,
                Position = UDim2.new(1, -7, 0, 7),
                Size = UDim2.fromOffset(13, 13),
                ZIndex = 6,
                Parent = Card,
            })
        end

        local CopiedLabel = New("TextLabel", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -24, 0, 5),
            Size = UDim2.fromOffset(50, 14),
            Text = "Copied!",
            TextColor3 = SuccessColor,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTransparency = 1,
            ZIndex = 6,
            Parent = Card,
        })

        Library:AddTooltip("Click to copy", nil, Card)
        Card.MouseEnter:Connect(function()
            if CopyImage then
                TweenService:Create(CopyImage, Library.TweenInfo, { ImageTransparency = 0.1 }):Play()
            end
        end)
        Card.MouseLeave:Connect(function()
            if CopyImage then
                TweenService:Create(CopyImage, Library.TweenInfo, { ImageTransparency = 0.55 }):Play()
            end
        end)
        Card.MouseButton1Click:Connect(function()
            local Parts = {}
            if Entry.TimeString then
                table.insert(Parts, string.format("[%s]", tostring(Entry.TimeString)))
            end
            if Entry.Title and Entry.Title ~= "nil" then
                table.insert(Parts, tostring(Entry.Title))
            end
            if Entry.Description and Entry.Description ~= "nil" then
                table.insert(Parts, tostring(Entry.Description))
            end
            local Text = table.concat(Parts, "\n")

            local Ok = Clipboard ~= nil
            if Ok then
                Ok = pcall(Clipboard, Text)
            end

            if CopyImage then
                if Ok and ClipboardCheckIcon then
                    CopyImage.Image = ClipboardCheckIcon.Url
                    CopyImage.ImageRectOffset = ClipboardCheckIcon.ImageRectOffset
                    CopyImage.ImageRectSize = ClipboardCheckIcon.ImageRectSize
                end
                CopyImage.ImageColor3 = Ok and SuccessColor or (Library.NotificationTypeColors.Error or Color3.fromRGB(255, 76, 76))
                CopyImage.ImageTransparency = 0

                CopyImage.Size = UDim2.fromOffset(9, 9)
                TweenService:Create(CopyImage, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(13, 13),
                }):Play()
            end

            CopiedLabel.Text = Ok and "Copied!" or "No clipboard"
            CopiedLabel.TextColor3 = Ok and SuccessColor or (Library.NotificationTypeColors.Error or Color3.fromRGB(255, 76, 76))
            CopiedLabel.TextTransparency = 0
            CopiedLabel.Position = UDim2.new(1, -24, 0, 9)
            TweenService:Create(CopiedLabel, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -24, 0, 5),
            }):Play()
            TweenService:Create(CopiedLabel, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                TextTransparency = 1,
            }):Play()

            task.delay(0.9, function()
                if CopyImage and CopyImage.Parent then
                    if ClipboardIcon then
                        CopyImage.Image = ClipboardIcon.Url
                        CopyImage.ImageRectOffset = ClipboardIcon.ImageRectOffset
                        CopyImage.ImageRectSize = ClipboardIcon.ImageRectSize
                    end
                    CopyImage.ImageColor3 = Library.Scheme.FontColor
                    TweenService:Create(CopyImage, Library.TweenInfo, { ImageTransparency = 0.55 }):Play()
                end
            end)
        end)

        local Header = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 14),
            Parent = Content,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = Header,
        })
        New("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            Text = string.format("[%s]", tostring(Entry.TimeString or "")),
            TextColor3 = "AccentColor",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Header,
        })
        if Entry.Type then
            New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                Text = string.upper(tostring(Entry.Type)),
                TextColor3 = Library.NotificationTypeColors[Entry.Type] or "FontColor",
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Header,
            })
        end

        if Entry.Title and Entry.Title ~= "nil" then
            New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Text = tostring(Entry.Title),
                TextColor3 = Entry.TitleColor or "FontColor",
                TextSize = 15,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Content,
            })
        end

        if Entry.Description and Entry.Description ~= "nil" then
            New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Text = tostring(Entry.Description),
                TextColor3 = Entry.DescriptionColor or "FontColor",
                TextSize = 14,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Content,
            })
        end
    end
end

function Library:SetNotificationHistoryVisible(Visible: boolean)
    Library:_BuildNotificationHistory()

    local Frame = Library.NotificationHistoryFrame
    Visible = Visible and true or false

    if Library.NotificationHistoryOpen == Visible then
        return
    end
    Library.NotificationHistoryOpen = Visible

    Library._NotifHistoryAnim = (Library._NotifHistoryAnim or 0) + 1
    local AnimId = Library._NotifHistoryAnim

    if Visible then
        Library:RefreshNotificationHistory()
        Library.NotificationUnreadCount = 0
        Library:UpdateNotificationBadge()

        local RestPos = GetNotifyHistoryDefaultPos()
        Library.NotificationHistoryRestPos = RestPos
        Frame.Position = RestPos + NOTIFY_HISTORY_SLIDE
        Frame.GroupTransparency = 1
        Frame.Visible = true

        TweenService:Create(Frame, NotifyHistoryOpenTween, {
            Position = RestPos,
            GroupTransparency = 0,
        }):Play()
    else
        local RestPos = Frame.Position

        TweenService:Create(Frame, NotifyHistoryCloseTween, {
            Position = RestPos + NOTIFY_HISTORY_SLIDE,
            GroupTransparency = 1,
        }):Play()

        task.delay(NotifyHistoryCloseTween.Time, function()
            if Library._NotifHistoryAnim == AnimId and not Library.NotificationHistoryOpen and Frame and Frame.Parent then
                Frame.Visible = false
            end
        end)
    end
end

function Library:ToggleNotificationHistory()
    Library:_BuildNotificationHistory()
    Library:SetNotificationHistoryVisible(not Library.NotificationHistoryOpen)
end

--// Enabled Features \\--
local ENABLED_FEATURES_SIZE = Vector2.new(300, 340)

local function GetEnabledFeaturesDefaultPos()
    return GetDropPanelPos(PickVisibleButton(Library.EnabledFeaturesButton, Library.EnabledFeaturesButtonMini), ENABLED_FEATURES_SIZE)
end

function Library:_BuildEnabledFeatures()
    if Library.EnabledFeaturesFrame then
        return
    end

    local Holder = New("CanvasGroup", {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = "BackgroundColor",
        Position = GetEnabledFeaturesDefaultPos(),
        Size = UDim2.fromOffset(ENABLED_FEATURES_SIZE.X, ENABLED_FEATURES_SIZE.Y),
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 10,
        Parent = ScreenGui,
    })
    table.insert(
        Library.Corners,
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Holder,
        })
    )
    table.insert(
        Library.Scales,
        New("UIScale", {
            Parent = Holder,
        })
    )
    Library:AddOutline(Holder)

    local TitleLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        Text = "Enabled Features",
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Holder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 36),
        Parent = TitleLabel,
    })

    Library:MakeLine(Holder, {
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 1),
    })

    local CloseIcon = Library:GetIcon("x")
    local CloseButton = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -8, 0, 17),
        Size = UDim2.fromOffset(20, 20),
        Text = CloseIcon and "" or "X",
        TextColor3 = "FontColor",
        TextSize = 14,
        TextTransparency = 0.35,
        ZIndex = 11,
        Parent = Holder,
    })
    local CloseImage
    if CloseIcon then
        CloseImage = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = CloseIcon.Url,
            ImageColor3 = "FontColor",
            ImageRectOffset = CloseIcon.ImageRectOffset,
            ImageRectSize = CloseIcon.ImageRectSize,
            ImageTransparency = 0.35,
            Position = UDim2.fromScale(0.5, 0.5),
            ScaleType = Enum.ScaleType.Fit,
            Size = UDim2.fromOffset(14, 14),
            ZIndex = 12,
            Parent = CloseButton,
        })
    end
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, Library.TweenInfo, { TextTransparency = 0 }):Play()
        if CloseImage then
            TweenService:Create(CloseImage, Library.TweenInfo, { ImageTransparency = 0 }):Play()
        end
    end)
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, Library.TweenInfo, { TextTransparency = 0.35 }):Play()
        if CloseImage then
            TweenService:Create(CloseImage, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
        end
    end)
    CloseButton.MouseButton1Click:Connect(function()
        Library:SetEnabledFeaturesVisible(false)
    end)

    local Scroller = New("ScrollingFrame", {
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        Position = UDim2.fromOffset(0, 35),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = "AccentColor",
        Size = UDim2.new(1, 0, 1, -35),
        Parent = Holder,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = Scroller,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        Parent = Scroller,
    })

    Library:MakeDraggable(Holder, TitleLabel, true)
    if not table.find(Library.DraggableElements, Holder) then
        table.insert(Library.DraggableElements, Holder)
    end

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
        if Library.Unloaded or not Library.EnabledFeaturesOpen then
            return
        end
        if not IsClickInput(Input, true) then
            return
        end

        local Location = Input.Position
        if Library:MouseIsOverFrame(Holder, Location) then
            return
        end
        if Library.EnabledFeaturesButton and Library:MouseIsOverFrame(Library.EnabledFeaturesButton, Location) then
            return
        end
        if Library.EnabledFeaturesButtonMini and Library:MouseIsOverFrame(Library.EnabledFeaturesButtonMini, Location) then
            return
        end

        Library:SetEnabledFeaturesVisible(false)
    end))

    Library.EnabledFeaturesFrame = Holder
    Library.EnabledFeaturesContainer = Scroller
    Library.EnabledFeaturesRestPos = Holder.Position
end

local function FeatureValuesEqual(A, B)
    if type(A) == "table" and type(B) == "table" then
        for K, V in A do
            if B[K] ~= V then
                return false
            end
        end
        for K, V in B do
            if A[K] ~= V then
                return false
            end
        end
        return true
    end
    return A == B
end

local function DropdownDefaultValue(Dropdown)
    local Indices = Dropdown.Default
    if Dropdown.Multi then
        local Map = {}
        if type(Indices) == "table" then
            for _, Index in Indices do
                local Value = Dropdown.Values and Dropdown.Values[Index]
                if Value ~= nil then
                    Map[Value] = true
                end
            end
        end
        return Map
    else
        if type(Indices) == "table" and Indices[1] then
            return Dropdown.Values and Dropdown.Values[Indices[1]] or nil
        end
        return nil
    end
end

local function FeatureIsAltered(Element)
    if Element.Type == "Dropdown" then
        local Default = DropdownDefaultValue(Element)
        if Element.Multi then
            return not FeatureValuesEqual(Element.Value or {}, Default)
        end
        return Element.Value ~= Default
    end

    if Element.Default == nil then
        return false
    end
    return Element.Value ~= Element.Default
end

local function BuildFeatureReset(Parent, Element)
    local Icon = Library:GetIcon("rotate-ccw")
    local Button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        Text = Icon and "" or "↺",
        TextColor3 = "FontColor",
        TextSize = 13,
        TextTransparency = 0.4,
        Parent = Parent,
    })
    local Image
    if Icon then
        Image = New("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            Image = Icon.Url,
            ImageColor3 = "FontColor",
            ImageRectOffset = Icon.ImageRectOffset,
            ImageRectSize = Icon.ImageRectSize,
            ImageTransparency = 0.4,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(13, 13),
            Parent = Button,
        })
    end
    Library:AddTooltip("Reset to default", nil, Button)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, Library.TweenInfo, { TextTransparency = 0 }):Play()
        if Image then
            TweenService:Create(Image, Library.TweenInfo, { ImageTransparency = 0 }):Play()
        end
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, Library.TweenInfo, { TextTransparency = 0.4 }):Play()
        if Image then
            TweenService:Create(Image, Library.TweenInfo, { ImageTransparency = 0.4 }):Play()
        end
    end)
    Button.MouseButton1Click:Connect(function()
        local DefaultValue = Element.Default
        if Element.Type == "Dropdown" then
            DefaultValue = DropdownDefaultValue(Element)
        end
        pcall(function()
            Element:SetValue(DefaultValue)
        end)
        Library:RefreshEnabledFeatures()
    end)
    return Button
end

local function BuildFeatureSwitch(Parent, Toggle)
    local Switch = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(34, 18),
        Text = "",
        Parent = Parent,
    })
    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Switch,
    })
    New("UIStroke", {
        Color = "OutlineColor",
        Parent = Switch,
    })
    local Ball = New("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = "FontColor",
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        Parent = Switch,
    })
    New("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = Ball,
    })

    local function Sync(Animated)
        local On = Toggle.Value and true or false
        local BallPos = On and UDim2.new(1, -15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
        local BgColor = On and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor

        if Animated then
            TweenService:Create(Ball, Library.TweenInfo, { Position = BallPos }):Play()
            TweenService:Create(Switch, Library.TweenInfo, { BackgroundColor3 = BgColor }):Play()
        else
            Ball.Position = BallPos
            Switch.BackgroundColor3 = BgColor
        end
    end

    Switch.MouseButton1Click:Connect(function()
        if Toggle.Disabled then
            return
        end
        Toggle:SetValue(not Toggle.Value)
        Sync(true)
    end)

    Sync(false)
    return Switch
end

local function BuildFeatureSlider(Parent, Slider)
    local Bar = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, -24, 0.5, 0),
        Size = UDim2.fromOffset(116, 16),
        Text = "",
        Parent = Parent,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Bar })
    New("UIStroke", { Color = "OutlineColor", Parent = Bar })
    local Fill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = Bar,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Fill })
    local ValueLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextColor3 = "FontColor",
        TextSize = 12,
        ZIndex = 2,
        Parent = Bar,
    })

    local function Update()
        local Range = Slider.Max - Slider.Min
        local Alpha = Range > 0 and (Slider.Value - Slider.Min) / Range or 0
        Fill.Size = UDim2.new(math.clamp(Alpha, 0, 1), 0, 1, 0)
        ValueLabel.Text = string.format("%s%s%s", tostring(Slider.Prefix or ""), tostring(Slider.Value), tostring(Slider.Suffix or ""))
    end

    local function SetFromX(PX)
        local Rel = (PX - Bar.AbsolutePosition.X) / math.max(1, Bar.AbsoluteSize.X)
        local Alpha = math.clamp(Rel, 0, 1)
        local Raw = Slider.Min + Alpha * (Slider.Max - Slider.Min)
        local Factor = 10 ^ (Slider.Rounding or 0)
        Slider:SetValue(math.floor(Raw * Factor + 0.5) / Factor)
        Update()
    end

    local MoveConn, EndConn
    Bar.InputBegan:Connect(function(Input: InputObject)
        if Slider.Disabled then
            return
        end
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        SetFromX(Input.Position.X)
        MoveConn = UserInputService.InputChanged:Connect(function(Move: InputObject)
            if Move.UserInputType == Enum.UserInputType.MouseMovement or Move.UserInputType == Enum.UserInputType.Touch then
                SetFromX(Move.Position.X)
            end
        end)
        EndConn = UserInputService.InputEnded:Connect(function(Ended: InputObject)
            if Ended.UserInputType == Enum.UserInputType.MouseButton1 or Ended.UserInputType == Enum.UserInputType.Touch then
                if MoveConn then MoveConn:Disconnect() MoveConn = nil end
                if EndConn then EndConn:Disconnect() EndConn = nil end
            end
        end)
    end)

    Update()
    return Bar
end

local function BuildFeatureInput(Parent, Input)
    local Box = New("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "BackgroundColor",
        ClearTextOnFocus = false,
        Position = UDim2.new(1, -24, 0.5, 0),
        Size = UDim2.fromOffset(116, 20),
        Text = tostring(Input.Value or ""),
        TextColor3 = "FontColor",
        TextSize = 13,
        TextEditable = not Input.Disabled,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Parent,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Box })
    New("UIStroke", { Color = "OutlineColor", Parent = Box })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = Box,
    })
    Box.FocusLost:Connect(function()
        pcall(function()
            Input:SetValue(Box.Text)
        end)
        Box.Text = tostring(Input.Value or "")
    end)
    return Box
end

local function BuildFeatureDropdown(Parent, Dropdown)
    local Button = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = "BackgroundColor",
        Position = UDim2.new(1, -24, 0.5, 0),
        Size = UDim2.fromOffset(116, 20),
        Text = "",
        Parent = Parent,
    })
    New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = Button })
    New("UIStroke", { Color = "OutlineColor", Parent = Button })
    local Label = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        Text = "",
        TextColor3 = "FontColor",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Button,
    })

    local function Display()
        if Dropdown.Multi then
            local Parts = {}
            if type(Dropdown.Value) == "table" then
                for Val, On in Dropdown.Value do
                    if On then
                        table.insert(Parts, tostring(Val))
                    end
                end
            end
            Label.Text = #Parts > 0 and table.concat(Parts, ", ") or "None"
        else
            Label.Text = tostring(Dropdown.Value or "None")
        end
    end

    if not Dropdown.Multi then
        Library:AddTooltip("Click to cycle", nil, Button)
        Button.MouseButton1Click:Connect(function()
            local Values = Dropdown.Values
            if not Values or #Values == 0 then
                return
            end
            local Idx = (Dropdown.Value ~= nil and table.find(Values, Dropdown.Value)) or 0
            for Step = 1, #Values do
                local Candidate = Values[((Idx - 1 + Step) % #Values) + 1]
                local IsDisabled = Dropdown.DisabledValues and table.find(Dropdown.DisabledValues, Candidate)
                if not IsDisabled then
                    Dropdown:SetValue(Candidate)
                    break
                end
            end
            Display()
        end)
    end

    Display()
    return Button
end

function Library:RefreshEnabledFeatures()
    Library:_BuildEnabledFeatures()

    local Scroller = Library.EnabledFeaturesContainer
    for _, Child in Scroller:GetChildren() do
        if not (Child:IsA("UIListLayout") or Child:IsA("UIPadding")) then
            Child:Destroy()
        end
    end

    local Items = {}
    for _, Toggle in Library.Toggles do
        if typeof(Toggle) == "table" and Toggle.Type == "Toggle" and not Toggle.Disabled and FeatureIsAltered(Toggle) then
            table.insert(Items, Toggle)
        end
    end
    for _, Option in Library.Options do
        if typeof(Option) == "table" and not Option.Disabled then
            local T = Option.Type
            if (T == "Slider" or T == "Input" or T == "Dropdown") and FeatureIsAltered(Option) then
                table.insert(Items, Option)
            end
        end
    end
    table.sort(Items, function(A, B)
        return tostring(A.Text or ""):lower() < tostring(B.Text or ""):lower()
    end)

    if #Items == 0 then
        New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            Text = "No features changed from default.",
            TextColor3 = "FontColor",
            TextTransparency = 0.4,
            TextSize = 14,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Scroller,
        })
        return
    end

    for _, Element in Items do
        local Row = New("Frame", {
            BackgroundColor3 = "MainColor",
            Size = UDim2.new(1, 0, 0, 34),
            Parent = Scroller,
        })
        New("UICorner", {
            CornerRadius = UDim.new(0, Library.CornerRadius),
            Parent = Row,
        })
        Library:AddOutline(Row)
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = Row,
        })

        local IsToggle = Element.Type == "Toggle"
        New("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(1, IsToggle and -44 or -150, 1, 0),
            Text = tostring(Element.Text or "Feature"),
            TextColor3 = "FontColor",
            TextSize = 14,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Row,
        })

        if Element.Type == "Toggle" then
            BuildFeatureSwitch(Row, Element)
        elseif Element.Type == "Slider" then
            BuildFeatureSlider(Row, Element)
            BuildFeatureReset(Row, Element)
        elseif Element.Type == "Input" then
            BuildFeatureInput(Row, Element)
            BuildFeatureReset(Row, Element)
        elseif Element.Type == "Dropdown" then
            BuildFeatureDropdown(Row, Element)
            BuildFeatureReset(Row, Element)
        end
    end
end

function Library:SetEnabledFeaturesVisible(Visible: boolean)
    Library:_BuildEnabledFeatures()

    local Frame = Library.EnabledFeaturesFrame
    Visible = Visible and true or false

    if Library.EnabledFeaturesOpen == Visible then
        return
    end
    Library.EnabledFeaturesOpen = Visible

    Library._EFAnim = (Library._EFAnim or 0) + 1
    local AnimId = Library._EFAnim

    if Visible then
        Library:RefreshEnabledFeatures()

        local RestPos = GetEnabledFeaturesDefaultPos()
        Library.EnabledFeaturesRestPos = RestPos
        Frame.Position = RestPos + NOTIFY_HISTORY_SLIDE
        Frame.GroupTransparency = 1
        Frame.Visible = true

        TweenService:Create(Frame, NotifyHistoryOpenTween, {
            Position = RestPos,
            GroupTransparency = 0,
        }):Play()
    else
        local RestPos = Frame.Position

        TweenService:Create(Frame, NotifyHistoryCloseTween, {
            Position = RestPos + NOTIFY_HISTORY_SLIDE,
            GroupTransparency = 1,
        }):Play()

        task.delay(NotifyHistoryCloseTween.Time, function()
            if Library._EFAnim == AnimId and not Library.EnabledFeaturesOpen and Frame and Frame.Parent then
                Frame.Visible = false
            end
        end)
    end
end

function Library:ToggleEnabledFeatures()
    Library:_BuildEnabledFeatures()
    Library:SetEnabledFeaturesVisible(not Library.EnabledFeaturesOpen)
end

function Library:CreateWindow(WindowInfo)
    WindowInfo = Library:Validate(WindowInfo, Templates.Window)
    local ViewportSize: Vector2 = workspace.CurrentCamera.ViewportSize
    if RunService:IsStudio() and ViewportSize.X <= 5 and ViewportSize.Y <= 5 then
        repeat
            ViewportSize = workspace.CurrentCamera.ViewportSize
            task.wait()
        until ViewportSize.X > 5 and ViewportSize.Y > 5
    end

    local MaxX = ViewportSize.X - 64
    local MaxY = ViewportSize.Y - 64

    Library.OriginalMinSize =
        Vector2.new(math.min(Library.OriginalMinSize.X, MaxX), math.min(Library.OriginalMinSize.Y, MaxY))
    Library.MinSize = Library.OriginalMinSize

    WindowInfo.Size = UDim2.fromOffset(
        math.clamp(WindowInfo.Size.X.Offset, Library.MinSize.X, MaxX),
        math.clamp(WindowInfo.Size.Y.Offset, Library.MinSize.Y, MaxY)
    )
    if typeof(WindowInfo.Font) == "EnumItem" then
        WindowInfo.Font = Font.fromEnum(WindowInfo.Font :: any)
    end
    WindowInfo.CornerRadius = math.min(WindowInfo.CornerRadius, 20)
    
    --// Old Naming \\--
    if WindowInfo.Compact ~= nil then
        WindowInfo.SidebarCompacted = WindowInfo.Compact
    end
    if WindowInfo.SidebarMinWidth ~= nil then
        WindowInfo.MinSidebarWidth = WindowInfo.SidebarMinWidth
    end
    WindowInfo.MinSidebarWidth = math.max(64, WindowInfo.MinSidebarWidth)
    WindowInfo.SidebarCompactWidth = math.max(48, WindowInfo.SidebarCompactWidth)
    WindowInfo.SidebarCollapseThreshold = math.clamp(WindowInfo.SidebarCollapseThreshold, 0.1, 0.9)
    WindowInfo.CompactWidthActivation = math.max(48, WindowInfo.CompactWidthActivation)

    Library.CornerRadius = WindowInfo.CornerRadius
    Library:SetNotifySide(WindowInfo.NotifySide)
    Library.ShowCustomCursor = WindowInfo.ShowCustomCursor
    Library.Scheme.Font = WindowInfo.Font
    Library.ToggleKeybind = WindowInfo.ToggleKeybind
    Library.GlobalSearch = WindowInfo.GlobalSearch
    Library.FuzzySearch = WindowInfo.FuzzySearch
    Library.SearchValues = WindowInfo.SearchValues
    
    Library.Animations = WindowInfo.Animations
    Library.TabTransitionInfo = TweenInfo.new(
        math.max(0, WindowInfo.TabTransitionTime or 0.22),
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    Library.TabSwipeOffset = math.max(1, WindowInfo.TabSwipeOffset or 26)
    Library.TabSwipeFrom = WindowInfo.TabSwipeFrom or "right"

    local IsDefaultSearchbarSize = WindowInfo.SearchbarSize == UDim2.fromScale(1, 1)
    local MainFrame
    local DividerLine
    local TitleHolder
    local WindowTitle
    local WindowIcon
    local RightWrapper
    local SearchBox
    local CurrentTabInfo
    local CurrentTabLabel
    local CurrentTabDescription
    local ResizeButton
    local Tabs
    local Container
    local BackgroundImage
    local BottomBackground
    local FooterSegments = {}
    local FooterSegments = {}
    local BuildFooter
    local BuildMiniFooter
    local TopBar
    local ActiveMarker
    local UpdateMarker
    local MiniFrame
    local MiniSubtitle
    local MiniBody
    local MiniFooterHolder
    local MiniFooter
    local MiniLabels = {}
    local MiniSubtitleExplicit = (WindowInfo.MinimizedSubtitle or "") ~= ""
    local Minimized = false
    local ApplyWindowVisibility
    local RightBarInset = (WindowInfo.Minimizable and 28 or 0) + 60

    local InitialLeftWidth = math.ceil(WindowInfo.Size.X.Offset * 0.3)
    local IsCompact = WindowInfo.SidebarCompacted
    local LastExpandedWidth = InitialLeftWidth

    do
        Library.KeybindFrame, Library.KeybindContainer = Library:AddDraggableMenu("Keybinds")
        Library.KeybindFrame.AnchorPoint = Vector2.new(0, 0.5)
        Library.KeybindFrame.Position = UDim2.new(0, 6, 0.5, 0)
        Library.KeybindFrame.Visible = false

        MainFrame = New("TextButton", {
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
            end,
            Name = "Main",
            Text = "",
            Position = WindowInfo.Position,
            Size = WindowInfo.Size,
            Visible = false,
            Parent = ScreenGui,
        })
        Library.MainFrame = MainFrame
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = MainFrame,
            })
        )
        table.insert(
            Library.Scales,
            New("UIScale", {
                Parent = MainFrame,
            })
        )
        Library:AddOutline(MainFrame)
        Library:MakeLine(MainFrame, {
            Position = UDim2.fromOffset(0, 48),
            Size = UDim2.new(1, 0, 0, 1),
        })

        DividerLine = New("Frame", {
            BackgroundColor3 = "OutlineColor",
            Position = UDim2.fromOffset(InitialLeftWidth, 0),
            Size = UDim2.new(0, 1, 1, -21),
            Parent = MainFrame,
            ZIndex = 2
        })

        local BackgroundIcon = Library:GetCustomIcon(WindowInfo.BackgroundImage)
        BackgroundImage = New("ImageLabel", {
            Image = BackgroundIcon and BackgroundIcon.Url or "",
            ImageRectOffset = BackgroundIcon and BackgroundIcon.ImageRectOffset or Vector2.zero,
            ImageRectSize = BackgroundIcon and BackgroundIcon.ImageRectSize or Vector2.zero,
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromScale(1, 1),
            ScaleType = Enum.ScaleType.Stretch,
            ZIndex = 999,
            BackgroundTransparency = 1,
            ImageTransparency = 0.75,
            Visible = BackgroundIcon ~= nil,
            Parent = MainFrame,
        })

        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BackgroundImage,
            })
        )

        if WindowInfo.Center then
            MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset / 2, 0.5, -MainFrame.Size.Y.Offset / 2)
        end

        TopBar = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 48),
            Parent = MainFrame,
        })
        Library:MakeDraggable(MainFrame, TopBar, false, true)

        TitleHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, InitialLeftWidth, 1, 0),
            Parent = TopBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = TitleHolder,
        })

        if WindowInfo.Icon then
            local Icon = Library:GetCustomIcon(WindowInfo.Icon)
            WindowIcon = New("ImageLabel", {
                Image = Icon.Url,
                ImageRectOffset = Icon.ImageRectOffset,
                ImageRectSize = Icon.ImageRectSize,
                Size = WindowInfo.IconSize,
                Parent = TitleHolder,
            })
        else
            WindowIcon = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = WindowInfo.IconSize,
                Text = WindowInfo.Title:sub(1, 1),
                TextScaled = true,
                Visible = false,
                Parent = TitleHolder,
            })
        end

        local X = Library:GetTextBounds(
            WindowInfo.Title,
            Library.Scheme.Font,
            20,
            TitleHolder.AbsoluteSize.X - (WindowInfo.Icon and WindowInfo.IconSize.X.Offset + 6 or 0) - 12
        )
        WindowTitle = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, X, 1, 0),
            Text = WindowInfo.Title,
            TextSize = 20,
            Parent = TitleHolder,
        })

        RightWrapper = New("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, InitialLeftWidth + 8, 0.5, 0),
            Size = UDim2.new(1, -InitialLeftWidth - 8 - 49 - RightBarInset, 1, -16),
            Parent = TopBar,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
            Parent = RightWrapper,
        })

        CurrentTabInfo = New("Frame", {
            Size = UDim2.fromScale(WindowInfo.DisableSearch and 1 or 0.5, 1),
            Visible = false,
            BackgroundTransparency = 1,
            Parent = RightWrapper,
        })

        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Grow,
            Parent = CurrentTabInfo,
        })

        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = CurrentTabInfo,
        })

        New("UIPadding", {
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 8),
            Parent = CurrentTabInfo,
        })

        CurrentTabLabel = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = CurrentTabInfo,
        })

        CurrentTabDescription = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = "",
            TextWrapped = true,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTransparency = 0.5,
            Parent = CurrentTabInfo,
        })

        SearchBox = New("TextBox", {
            BackgroundColor3 = "MainColor",
            PlaceholderText = "Search...",
            Size = WindowInfo.SearchbarSize,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = not (WindowInfo.DisableSearch or false),
            Parent = RightWrapper,
        })
        New("UIFlexItem", {
            FlexMode = Enum.UIFlexMode.Fill,
            Parent = SearchBox,
        })
        table.insert(
            Library.PillCorners,
            New("UICorner", {
                CornerRadius = WindowInfo.CornerRadius > 0 and UDim.new(1, 0) or UDim.new(0, 0),
                Parent = SearchBox,
            })
        )
        New("UIPadding", {
            PaddingBottom = UDim.new(0, 6),
            PaddingLeft = UDim.new(0, SEARCHBOX_TEXT_INSET),
            PaddingRight = UDim.new(0, 14),
            PaddingTop = UDim.new(0, 6),
            Parent = SearchBox,
        })
        New("UIStroke", {
            Color = "OutlineColor",
            Parent = SearchBox,
        })

        local SearchIcon = Library:GetIcon("search")
        if SearchIcon then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                Image = SearchIcon.Url,
                ImageColor3 = "FontColor",
                ImageRectOffset = SearchIcon.ImageRectOffset,
                ImageRectSize = SearchIcon.ImageRectSize,
                ImageTransparency = 0.4,
                Position = UDim2.new(0, -(SEARCHBOX_TEXT_INSET - 14), 0.5, 0),
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2.fromOffset(16, 16),
                Parent = SearchBox,
            })
        end

        if not (WindowInfo.DisableSearch or WindowInfo.DisableSearchKeybind) then
            Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject, Processed: boolean)
                if Library.Unloaded or Input.UserInputType ~= Enum.UserInputType.Keyboard then
                    return
                end

                if Input.KeyCode == Enum.KeyCode.Escape then
                    if UserInputService:GetFocusedTextBox() == SearchBox then
                        SearchBox.Text = ""
                        SearchBox:ReleaseFocus()
                    end

                    return
                end

                if Processed or not Library.Toggled then
                    return
                end

                if Input.KeyCode ~= WindowInfo.SearchKeybind then
                    return
                end

                local CtrlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
                    or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                if not CtrlHeld then
                    return
                end

                local Focused = UserInputService:GetFocusedTextBox()
                if Focused and Focused ~= SearchBox then
                    return
                end

                SearchBox.Text = ""
                SearchBox:CaptureFocus()
            end))
        end

        if WindowInfo.Minimizable then
            local MinimizeIcon = Library:GetIcon("minus")

            local MinimizeButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -44, 0.5, 0),
                Size = UDim2.fromOffset(24, 24),
                Text = MinimizeIcon and "" or "—",
                TextSize = 14,
                TextTransparency = 0.35,
                ZIndex = 3,
                Parent = TopBar,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = MinimizeButton,
                })
            )

            local MinimizeImage
            if MinimizeIcon then
                MinimizeImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = MinimizeIcon.Url,
                    ImageColor3 = "FontColor",
                    ImageRectOffset = MinimizeIcon.ImageRectOffset,
                    ImageRectSize = MinimizeIcon.ImageRectSize,
                    ImageTransparency = 0.35,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = MinimizeButton,
                })
            end

            Library:AddTooltip("Minimize", nil, MinimizeButton)
            MinimizeButton.MouseEnter:Connect(function()
                TweenService:Create(MinimizeButton, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                if MinimizeImage then
                    TweenService:Create(MinimizeImage, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                end
            end)
            MinimizeButton.MouseLeave:Connect(function()
                TweenService:Create(MinimizeButton, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                if MinimizeImage then
                    TweenService:Create(MinimizeImage, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
                end
            end)
            MinimizeButton.MouseButton1Click:Connect(function()
                Library.Window:SetMinimized(true)
            end)

            MiniFrame = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = function()
                    return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
                end,
                Name = "Minimized",
                Position = WindowInfo.Position,
                Size = UDim2.fromOffset(WindowInfo.MinimizedWidth, 0),
                Visible = false,
                Parent = ScreenGui,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = MiniFrame,
                })
            )
            table.insert(
                Library.Scales,
                New("UIScale", {
                    Parent = MiniFrame,
                })
            )
            Library:AddOutline(MiniFrame)

            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = MiniFrame,
            })

            local MiniHeader = New("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.new(1, 0, 0, 46),
                Parent = MiniFrame,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 10),
                Parent = MiniHeader,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = MiniHeader,
            })

            local MiniIconData = WindowInfo.Icon and Library:GetCustomIcon(WindowInfo.Icon) or nil
            if MiniIconData then
                local IconHolder = New("Frame", {
                    BackgroundColor3 = "MainColor",
                    LayoutOrder = 0,
                    Size = UDim2.fromOffset(26, 26),
                    Parent = MiniHeader,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, math.max(2, WindowInfo.CornerRadius)),
                        Parent = IconHolder,
                    })
                )

                New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = MiniIconData.Url,
                    ImageRectOffset = MiniIconData.ImageRectOffset,
                    ImageRectSize = MiniIconData.ImageRectSize,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = IconHolder,
                })
            end

            local MiniTitleHolder = New("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Parent = MiniHeader,
            })
            New("UIFlexItem", {
                FlexMode = Enum.UIFlexMode.Shrink,
                Parent = MiniTitleHolder,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Parent = MiniTitleHolder,
            })

            New("TextLabel", {
                BackgroundTransparency = 1,
                LayoutOrder = 0,
                Size = UDim2.new(1, 0, 0, 17),
                Text = `<b>{WindowInfo.Title}</b>`,
                TextSize = 15,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = MiniTitleHolder,
            })

            MiniSubtitle = New("TextLabel", {
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Text = WindowInfo.MinimizedSubtitle or "",
                TextSize = 12,
                TextTransparency = 0.55,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Visible = (WindowInfo.MinimizedSubtitle or "") ~= "",
                Parent = MiniTitleHolder,
            })

            local function MiniActionButton(Icon, Order, TooltipText, OnClick, FallbackText)
                local Btn = New("TextButton", {
                    BackgroundTransparency = 1,
                    LayoutOrder = Order,
                    Size = UDim2.fromOffset(22, 22),
                    Text = Icon and "" or (FallbackText or "?"),
                    TextColor3 = "FontColor",
                    TextSize = 15,
                    TextTransparency = 0.35,
                    Parent = MiniHeader,
                })
                local Img
                if Icon then
                    Img = New("ImageLabel", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Image = Icon.Url,
                        ImageColor3 = "FontColor",
                        ImageRectOffset = Icon.ImageRectOffset,
                        ImageRectSize = Icon.ImageRectSize,
                        ImageTransparency = 0.35,
                        Position = UDim2.fromScale(0.5, 0.5),
                        ScaleType = Enum.ScaleType.Fit,
                        Size = UDim2.fromOffset(16, 16),
                        Parent = Btn,
                    })
                end
                Btn.MouseEnter:Connect(function()
                    TweenService:Create(Btn, Library.TweenInfo, { TextTransparency = 0 }):Play()
                    if Img then
                        TweenService:Create(Img, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                    end
                end)
                Btn.MouseLeave:Connect(function()
                    TweenService:Create(Btn, Library.TweenInfo, { TextTransparency = 0.35 }):Play()
                    if Img then
                        TweenService:Create(Img, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
                    end
                end)
                if TooltipText then
                    Library:AddTooltip(TooltipText, nil, Btn)
                end
                Btn.MouseButton1Click:Connect(OnClick)
                return Btn
            end

            local MiniFeatures = MiniActionButton(
                Library:GetIcon("sliders-horizontal") or Library:GetIcon("list"),
                2,
                "Enabled Features",
                function() Library:ToggleEnabledFeatures() end,
                "≡"
            )
            Library.EnabledFeaturesButtonMini = MiniFeatures

            local MiniBell = MiniActionButton(
                Library:GetIcon("bell"),
                3,
                "Notification History",
                function() Library:ToggleNotificationHistory() end,
                "!"
            )
            Library.NotificationBellMini = MiniBell

            do
                local BadgeHolder = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = "AccentColor",
                    Position = UDim2.new(1, 2, 0, 0),
                    Size = UDim2.fromOffset(14, 14),
                    Visible = false,
                    ZIndex = 5,
                    Parent = MiniBell,
                })
                New("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = BadgeHolder,
                })
                local BadgeLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "0",
                    TextColor3 = "BackgroundColor",
                    TextSize = 11,
                    ZIndex = 6,
                    Parent = BadgeHolder,
                })
                New("UIPadding", {
                    PaddingLeft = UDim.new(0, 2),
                    PaddingRight = UDim.new(0, 2),
                    Parent = BadgeLabel,
                })
                table.insert(Library.NotificationBadges, { Holder = BadgeHolder, Label = BadgeLabel })
                Library:UpdateNotificationBadge()
            end

            local RestoreIcon = Library:GetIcon("chevron-up")
            local RestoreButton = New("TextButton", {
                BackgroundTransparency = 1,
                LayoutOrder = 4,
                Size = UDim2.fromOffset(22, 22),
                Text = RestoreIcon and "" or "^",
                TextSize = 14,
                TextTransparency = 0.35,
                Parent = MiniHeader,
            })

            if RestoreIcon then
                New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = RestoreIcon.Url,
                    ImageColor3 = "FontColor",
                    ImageRectOffset = RestoreIcon.ImageRectOffset,
                    ImageRectSize = RestoreIcon.ImageRectSize,
                    ImageTransparency = 0.35,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(16, 16),
                    Parent = RestoreButton,
                })
            end

            Library:AddTooltip("Restore", nil, RestoreButton)
            RestoreButton.MouseButton1Click:Connect(function()
                Library.Window:SetMinimized(false)
            end)

            MiniBody = New("Frame", {
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                Parent = MiniFrame,
            })
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                Parent = MiniBody,
            })
            New("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = MiniBody,
            })

            --// Footer \\--
            MiniFooterHolder = New("Frame", {
                BackgroundTransparency = 1,
                LayoutOrder = 2,
                Size = UDim2.new(1, 0, 0, 26),
                Parent = MiniFrame,
            })
            Library:MakeLine(MiniFooterHolder, {
                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.new(1, 0, 0, 1),
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                Parent = MiniFooterHolder,
            })

            MiniFooter = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "",
                TextSize = 12,
                TextTransparency = 0.6,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = MiniFooterHolder,
            })

            Library:MakeDraggable(MiniFrame, MiniHeader, true)
        end

        if MoveIcon then
            New("ImageLabel", {
                AnchorPoint = Vector2.new(1, 0.5),
                Image = MoveIcon.Url,
                ImageColor3 = "OutlineColor",
                ImageRectOffset = MoveIcon.ImageRectOffset,
                ImageRectSize = MoveIcon.ImageRectSize,
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.fromOffset(28, 28),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                Parent = TopBar,
            })
        end

        do
            local BellIcon = Library:GetIcon("bell")
            local BellRightOffset = WindowInfo.Minimizable and 72 or 42

            local BellButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -BellRightOffset, 0.5, 0),
                Size = UDim2.fromOffset(24, 24),
                Text = BellIcon and "" or "!",
                TextSize = 14,
                TextTransparency = 0.35,
                ZIndex = 3,
                Parent = TopBar,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = BellButton,
                })
            )

            local BellImage
            if BellIcon then
                BellImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = BellIcon.Url,
                    ImageColor3 = "FontColor",
                    ImageRectOffset = BellIcon.ImageRectOffset,
                    ImageRectSize = BellIcon.ImageRectSize,
                    ImageTransparency = 0.35,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 4,
                    Parent = BellButton,
                })
            end

            local BadgeHolder = New("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = "AccentColor",
                Position = UDim2.new(1, 2, 0, -2),
                Size = UDim2.fromOffset(14, 14),
                Visible = false,
                ZIndex = 5,
                Parent = BellButton,
            })
            New("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = BadgeHolder,
            })
            local BadgeLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = "0",
                TextColor3 = "BackgroundColor",
                TextSize = 11,
                ZIndex = 6,
                Parent = BadgeHolder,
            })
            New("UIPadding", {
                PaddingLeft = UDim.new(0, 2),
                PaddingRight = UDim.new(0, 2),
                Parent = BadgeLabel,
            })

            Library.NotificationBadge = { Holder = BadgeHolder, Label = BadgeLabel }
            table.insert(Library.NotificationBadges, Library.NotificationBadge)
            Library.NotificationBell = BellButton
            Library:UpdateNotificationBadge()

            Library:AddTooltip("Notification History", nil, BellButton)
            BellButton.MouseEnter:Connect(function()
                TweenService:Create(BellButton, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                if BellImage then
                    TweenService:Create(BellImage, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                end
            end)
            BellButton.MouseLeave:Connect(function()
                TweenService:Create(BellButton, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                if BellImage then
                    TweenService:Create(BellImage, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
                end
            end)
            BellButton.MouseButton1Click:Connect(function()
                Library:ToggleNotificationHistory()
            end)
        end

        do
            local FeaturesIcon = Library:GetIcon("sliders-horizontal") or Library:GetIcon("list")
            local FeaturesRightOffset = (WindowInfo.Minimizable and 72 or 42) + 30

            local FeaturesButton = New("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -FeaturesRightOffset, 0.5, 0),
                Size = UDim2.fromOffset(24, 24),
                Text = FeaturesIcon and "" or "≡",
                TextColor3 = "FontColor",
                TextSize = 16,
                TextTransparency = 0.35,
                ZIndex = 3,
                Parent = TopBar,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = FeaturesButton,
                })
            )

            local FeaturesImage
            if FeaturesIcon then
                FeaturesImage = New("ImageLabel", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Image = FeaturesIcon.Url,
                    ImageColor3 = "FontColor",
                    ImageRectOffset = FeaturesIcon.ImageRectOffset,
                    ImageRectSize = FeaturesIcon.ImageRectSize,
                    ImageTransparency = 0.35,
                    Position = UDim2.fromScale(0.5, 0.5),
                    ScaleType = Enum.ScaleType.Fit,
                    Size = UDim2.fromOffset(16, 16),
                    ZIndex = 4,
                    Parent = FeaturesButton,
                })
            end

            Library.EnabledFeaturesButton = FeaturesButton

            Library:AddTooltip("Enabled Features", nil, FeaturesButton)
            FeaturesButton.MouseEnter:Connect(function()
                TweenService:Create(FeaturesButton, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                if FeaturesImage then
                    TweenService:Create(FeaturesImage, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                end
            end)
            FeaturesButton.MouseLeave:Connect(function()
                TweenService:Create(FeaturesButton, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                if FeaturesImage then
                    TweenService:Create(FeaturesImage, Library.TweenInfo, { ImageTransparency = 0.35 }):Play()
                end
            end)
            FeaturesButton.MouseButton1Click:Connect(function()
                Library:ToggleEnabledFeatures()
            end)
        end

        --// Bottom Bar \\--
        BottomBackground = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = function()
                return Library:GetBetterColor(Library.Scheme.BackgroundColor, 4)
            end,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20 + WindowInfo.CornerRadius),
            Parent = MainFrame
        })
        Library:MakeLine(MainFrame, {
            AnchorPoint = Vector2.new(0, 1),
            Position = UDim2.new(0, 0, 1, -20),
            Size = UDim2.new(1, 0, 0, 1),
        })

        local BottomBar = New("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Position = UDim2.fromScale(0, 1),
            Size = UDim2.new(1, 0, 0, 20),
            Parent = MainFrame,
        })
        table.insert(
            Library.Corners,
            New("UICorner", {
                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                Parent = BottomBackground,
            })
        )

        --// Footer \\-
        local FooterHolder = New("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Parent = BottomBar,
        })
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            Parent = FooterHolder,
        })

        local function AddFooterSegment(i)
            local t = tostring(i.Text or "")
            local c = i.Copyable == true and sC ~= nil

            local l = New("TextLabel", {
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0),
                Text = t,
                TextColor3 = c and "BlueColor" or "FontColor",
                TextSize = 14,
                TextTransparency = c and 0 or 0.5,
                Parent = FooterHolder,
            })
            table.insert(FooterSegments, l)

            if not c then
                return l
            end

            local cv = tostring(i.CopyText or t)
            local ci = Library:GetIcon("copy")
            local cd = Library:GetIcon("check")

            local cb = New("TextButton", {
                BackgroundColor3 = "MainColor",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(18, 18),
                Text = "",
                Parent = FooterHolder,
            })
            table.insert(
                Library.Corners,
                New("UICorner", {
                    CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                    Parent = cb,
                })
            )
            New("UIPadding", {
                PaddingBottom = UDim.new(0, 3),
                PaddingLeft = UDim.new(0, 3),
                PaddingRight = UDim.new(0, 3),
                PaddingTop = UDim.new(0, 3),
                Parent = cb,
            })

            local cm = New("ImageLabel", {
                Image = ci and ci.Url or "",
                ImageColor3 = "BlueColor",
                ImageRectOffset = ci and ci.ImageRectOffset or Vector2.zero,
                ImageRectSize = ci and ci.ImageRectSize or Vector2.zero,
                ScaleType = Enum.ScaleType.Fit,
                Size = UDim2.fromScale(1, 1),
                Parent = cb,
            })

            Library:AddTooltip("Copy to clipboard", nil, cb)

            local rt
            local function cp()
                local s = pcall(sC, cv)
                if not s then
                    return
                end

                if cd then
                    cm.Image = cd.Url
                    cm.ImageRectOffset = cd.ImageRectOffset
                    cm.ImageRectSize = cd.ImageRectSize
                end

                if rt then
                    task.cancel(rt)
                end

                rt = task.delay(1.5, function()
                    rt = nil

                    if ci then
                        cm.Image = ci.Url
                        cm.ImageRectOffset = ci.ImageRectOffset
                        cm.ImageRectSize = ci.ImageRectSize
                    end
                end)
            end

            cb.MouseButton1Click:Connect(cp)
            cb.MouseEnter:Connect(function()
                TweenService:Create(cb, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
            end)
            cb.MouseLeave:Connect(function()
                TweenService:Create(cb, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
            end)

            l.InputBegan:Connect(function(inp)
                if IsClickInput(inp) then
                    cp()
                end
            end)

            table.insert(FooterSegments, cb)
            return l
        end

        function BuildFooter(f)
            for _, o in FooterSegments do
                o:Destroy()
            end
            table.clear(FooterSegments)

            if typeof(f) == "string" then
                AddFooterSegment({
                    Text = f,
                    Copyable = WindowInfo.CopyableFooter ~= false,
                })

                return
            end

            for _, seg in f do
                if typeof(seg) == "string" then
                    seg = { Text = seg, Copyable = false }
                end

                AddFooterSegment(seg)
            end
        end

        function BuildMiniFooter(Footer)
            if not MiniFooter then
                return
            end

            if typeof(Footer) == "string" then
                MiniFooter.Text = Footer
            else
                local Parts = {}

                for _, Segment in Footer do
                    if typeof(Segment) == "string" then
                        table.insert(Parts, Segment)
                    elseif typeof(Segment) == "table" and Segment.Text ~= nil then
                        table.insert(Parts, tostring(Segment.Text))
                    end
                end

                MiniFooter.Text = table.concat(Parts, " ")
            end

            MiniFooterHolder.Visible = MiniFooter.Text ~= ""
        end

        BuildFooter(WindowInfo.Footer)

                --// Resize Button \\--
                if WindowInfo.Resizable then
                    ResizeButton = New("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -WindowInfo.CornerRadius / 4, 0, 0),
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        Text = "",
                        Parent = BottomBar,
                    })

                    Library:MakeResizable(MainFrame, ResizeButton, function()
                        for _, Tab in Library.Tabs do
                            Tab:Resize(true)
                        end
                    end)
                end

                New("ImageLabel", {
                    Image = ResizeIcon and ResizeIcon.Url or "",
                    ImageColor3 = "FontColor",
                    ImageRectOffset = ResizeIcon and ResizeIcon.ImageRectOffset or Vector2.zero,
                    ImageRectSize = ResizeIcon and ResizeIcon.ImageRectSize or Vector2.zero,
                    ImageTransparency = 0.5,
                    Position = UDim2.fromOffset(2, 2),
                    Size = UDim2.new(1, -4, 1, -4),
                    Parent = ResizeButton,
                })

                --// Tabs \\--
                Tabs = New("ScrollingFrame", {
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = "BackgroundColor",
                    CanvasSize = UDim2.fromScale(0, 0),
                    Position = UDim2.fromOffset(0, 49),
                    ScrollBarThickness = 0,
                    Size = UDim2.new(0, InitialLeftWidth, 1, -70),
                    Parent = MainFrame,
                })
                New("UIListLayout", {
                    Parent = Tabs,
                })

                --// Container \\--
                Container = New("Frame", {
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = function()
                        return Library:GetBetterColor(Library.Scheme.BackgroundColor, 1)
                    end,
                    ClipsDescendants = true,
                    Name = "Container",
                    Position = UDim2.new(1, 0, 0, 49),
                    Size = UDim2.new(1, -InitialLeftWidth - 1, 1, -70),
                    Parent = MainFrame,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 0),
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 0),
                    Parent = Container,
                })

                Library.WindowContainer = Container

                ActiveMarker = New("Frame", {
                    BackgroundColor3 = "AccentColor",
                    Position = UDim2.fromOffset(2, 0),
                    Size = UDim2.fromOffset(3, 0),
                    Visible = false,
                    ZIndex = 6,
                    Parent = MainFrame,
                })
                table.insert(Library.Corners, New("UICorner", {
                    CornerRadius = UDim.new(0, 1.5),
                    Parent = ActiveMarker
                }))

                UpdateMarker = function(instant)
                    if not Library.ActiveTab then 
                        ActiveMarker.Visible = false
                        return 
                    end
                    
                    local activeBtn = nil
                    for _, Entry in ipairs(Library.TabButtons) do
                        if Entry.Tab == Library.ActiveTab then
                            activeBtn = Entry.Button
                            break
                        end
                    end
                    
                    if not activeBtn then 
                        ActiveMarker.Visible = false
                        return 
                    end

                    if activeBtn.AbsolutePosition.Y == 0 then
                        task.defer(function()
                            UpdateMarker(instant)
                        end)
                        return
                    end
                    
                    ActiveMarker.Visible = IsCompact
                    if IsCompact then
                        local dpiScale = Library.DPIScale or 1
                        local markerY = (activeBtn.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) / dpiScale
                        local markerHeight = 22
                        
                        if instant then
                            ActiveMarker.Position = UDim2.fromOffset(2, markerY + (40 - markerHeight) / 2)
                            ActiveMarker.Size = UDim2.fromOffset(3, markerHeight)
                        else
                            TweenService:Create(ActiveMarker, Library.TweenInfo, {
                                Position = UDim2.fromOffset(2, markerY + (40 - markerHeight) / 2),
                                Size = UDim2.fromOffset(3, markerHeight),
                            }):Play()
                        end
                    else
                        ActiveMarker.Size = UDim2.fromOffset(3, 0)
                    end
                end

                Tabs:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
                    UpdateMarker(true)
                end)
            end

            --// Window Table \\--
            local Window = {}
            local Fading = false

            local function SetUICorner(UICorner, Corner, HalfCurrent, HalfValue, Value)
                local Current = UICorner[Corner]
                if Current.Offset == 0 and Current.Scale == 0 then
                    return
                end

                UICorner[Corner] = Current.Offset == HalfCurrent and HalfValue or Value
            end

            function Window:ChangeTitle(title)
                assert(typeof(title) == "string", "Expected string for title got: " .. typeof(title))

                WindowTitle.Text = title
                WindowInfo.Title = title
            end

            function Window:SetBackgroundImage(Image: string)
                local ValidIcon = false

                if typeof(Image) == "string" then
                    local BackgroundIcon = Library:GetCustomIcon(Image)

                    if BackgroundIcon then
                        ValidIcon = true

                        BackgroundImage.Image = BackgroundIcon.Url
                        BackgroundImage.ImageRectOffset = BackgroundIcon.ImageRectOffset
                        BackgroundImage.ImageRectSize = BackgroundIcon.ImageRectSize
                        BackgroundImage.Visible = true
                    elseif Image:match("http://") or Image:match("https://") then
                        local RawFileName = Image:match("(.+)%..+$")
                        local _, Domain = Image:match("^(https?://)([^/]+)"); 

                        if RawFileName and Domain then
                            local Extention = string.sub(Image, #RawFileName + 1, #Image)
                            local FileNamePos = RawFileName:gsub("\\", "/"):find("/[^/]*$")
                            local FileName = FileNamePos and Image:sub(FileNamePos + 1) or nil

                            if FileName then
                                ValidIcon = true

                                local AssetName = Domain .. FileName
                                if #AssetName > 255 then
                                    local NewLength = 255 - #Domain - #Extention
                                    if NewLength < 0 then
                                        AssetName = Domain .. Extention
                                    else
                                        AssetName = Domain .. string.sub(FileName:sub(1, #FileName - #Extention), 1, NewLength) .. Extention
                                    end
                                end

                                if CustomImageManagerAssets[FileName] == nil then
                                    CustomImageManager.AddAsset(FileName, 0, Image)
                                else
                                    CustomImageManager.DownloadAsset(FileName, true)
                                end

                                BackgroundImage.Image = CustomImageManager.GetAsset(FileName)
                                BackgroundImage.ImageRectOffset = Vector2.zero
                                BackgroundImage.ImageRectSize = Vector2.zero
                                BackgroundImage.Visible = true
                            end
                        end
                    end
                end

                if not ValidIcon then
                    BackgroundImage.Image = ""
                    BackgroundImage.ImageRectOffset = Vector2.zero
                    BackgroundImage.ImageRectSize = Vector2.zero
                    BackgroundImage.Visible = false
                end
            
                WindowInfo.BackgroundImage = Image
            end

            function Window:SetFooter(f)
                assert(
                    typeof(f) == "string" or typeof(f) == "table",
                    "Expected string or table for footer got: " .. typeof(f)
                )

                BuildFooter(f)
                WindowInfo.Footer = f
            end

            function Window:SetAlwaysOnTop(en: boolean)
                WindowInfo.AlwaysOnTop = en == true
                SetAlwaysOnTop(Library.ScreenGui, WindowInfo.AlwaysOnTop)
            end

            function Window:SetCornerRadius(r)
                assert(typeof(r) == "number", "Expected number for Radius got: " .. typeof(r))
                r = math.min(r, 20)

                local rh = UDim.new(0, r / 2)
                local ru = UDim.new(0, r)
                local hc = Library.CornerRadius / 2

                for _, c in Library.Corners do
                    if c.CornerRadius.Offset == hc then
                        c.CornerRadius = rh
                    else
                        c.CornerRadius = ru
                    end
                end

                for _, c in Library.PillCorners do
                    c.CornerRadius = r > 0 and UDim.new(1, 0) or UDim.new(0, 0)
                end

                for _, c in Library.SpecificCorners do
                    SetUICorner(c, "TopRightRadius", hc, rh, ru)
                    SetUICorner(c, "TopLeftRadius", hc, rh, ru)
                    SetUICorner(c, "BottomRightRadius", hc, rh, ru)
                    SetUICorner(c, "BottomLeftRadius", hc, rh, ru)
                end

                Library.CornerRadius = r
                WindowInfo.CornerRadius = r

                ResizeButton.Position = UDim2.new(1, -r / 4, 0, 0)
                BottomBackground.Size = UDim2.new(1, 0, 0, 20 + r)

                for _, t in Library.Tabs do
                    if t.IsKeyTab then
                        continue
                    end

                    for _, tb in t.Tabboxes do
                        tb:UpdateCorners()
                    end
                end
            end

            function Window:SetAnimations(Animations: { [string]: boolean }?, TabTransitionTime: number?, TabSwipeOffset: number?, TabSwipeFrom: ("left" | "right" | "top" | "bottom" | string)?)
                if typeof(Animations) == "table" then
                    WindowInfo.Animations = Animations
                    Library.Animations = Animations
                end

                if typeof(TabTransitionTime) == "number" then
                    local TweenInfo = TweenInfo.new(
                        math.max(0, TabTransitionTime or 0.22),
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    )

                    WindowInfo.TabTransitionInfo = TweenInfo
                    Library.TabTransitionInfo = TweenInfo
                end

                if typeof(TabSwipeOffset) == "number" then
                    TabSwipeOffset = math.max(1, TabSwipeOffset)

                    WindowInfo.TabSwipeOffset = TabSwipeOffset
                    Library.TabSwipeOffset = TabSwipeOffset
                end

                if typeof(TabSwipeFrom) == "string" then
                    TabSwipeFrom = string.lower(TabSwipeFrom)

                    WindowInfo.TabSwipeFrom = TabSwipeFrom
                    Library.TabSwipeFrom = TabSwipeFrom
                end
            end

            local function ApplyCompact()
                IsCompact = Window:GetSidebarWidth() == WindowInfo.SidebarCompactWidth
                if WindowInfo.DisableCompactingSnap then
                    IsCompact = Window:GetSidebarWidth() <= WindowInfo.CompactWidthActivation
                end

                WindowTitle.Visible = not IsCompact
                if not WindowInfo.Icon then
                    WindowIcon.Visible = IsCompact
                end

                for _, Button in Library.TabButtons do
                    if Button.Tooltip then
                        Button.Tooltip.Disabled = not IsCompact
                    end

                    if not Button.Icon then
                        continue
                    end

                    Button.Label.Visible = not IsCompact
                    Button.Padding.PaddingBottom = UDim.new(0, IsCompact and 6 or 11)
                    Button.Padding.PaddingLeft = UDim.new(0, IsCompact and 6 or 12)
                    Button.Padding.PaddingRight = UDim.new(0, IsCompact and 6 or 12)
                    Button.Padding.PaddingTop = UDim.new(0, IsCompact and 6 or 11)
                    Button.Icon.SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY

                    if Button.Chevron then
                        Button.Chevron.Visible = not IsCompact
                    end
                    if Button.SidebarList and IsCompact then
                        Button.SidebarList.Size = UDim2.new(1, 0, 0, 0)
                        Button.SidebarList.Visible = false
                    end
                end

                if not IsCompact and Library.ActiveTab and Library.ActiveTab.SetExpanded then
                    Library.ActiveTab:SetExpanded(true)
                end

                UpdateMarker()
            end

            function Window:IsSidebarCompacted()
                return IsCompact
            end

            function Window:IsMinimized()
                return Minimized
            end

            function Window:SetMinimized(Value: boolean?)
                if not MiniFrame then
                    return
                end

                if Value == nil then
                    Value = not Minimized
                end
                Value = Value and true or false

                if Value == Minimized then
                    return
                end
                Minimized = Value

                if Minimized then
                    MiniFrame.Position = MainFrame.Position
                    MiniFrame.AnchorPoint = MainFrame.AnchorPoint
                else
                    MainFrame.Position = MiniFrame.Position
                    MainFrame.AnchorPoint = MiniFrame.AnchorPoint
                end

                ApplyWindowVisibility()
            end

            function Window:ToggleMinimized()
                Window:SetMinimized(not Minimized)
            end

            function Window:SetMinimizedSubtitle(Text: string?)
                if not MiniSubtitle then
                    return
                end

                Text = Text or ""
                MiniSubtitleExplicit = Text ~= ""

                if MiniSubtitleExplicit then
                    MiniSubtitle.Text = Text
                    MiniSubtitle.Visible = true
                elseif Library.ActiveTab then
                    MiniSubtitle.Text = Library.ActiveTab.Name or ""
                    MiniSubtitle.Visible = MiniSubtitle.Text ~= ""
                else
                    MiniSubtitle.Visible = false
                end
            end

            function Window:AddMinimizedLabel(Text: string?)
                if not MiniBody then
                    return
                end

                local Label = New("TextLabel", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = #MiniLabels,
                    Size = UDim2.new(1, 0, 0, 0),
                    Text = Text or "",
                    TextSize = 13,
                    TextTransparency = 0.25,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = MiniBody,
                })

                local Handle = {
                    Label = Label,
                    Type = "MinimizedLabel",
                }

                function Handle:SetText(Value: string?)
                    Label.Text = Value or ""
                end

                function Handle:SetVisible(Value: boolean)
                    Label.Visible = Value and true or false
                end

                function Handle:Destroy()
                    local Index = table.find(MiniLabels, Handle)
                    if Index then
                        table.remove(MiniLabels, Index)
                    end

                    Label:Destroy()
                    MiniBody.Visible = #MiniLabels > 0
                end

                table.insert(MiniLabels, Handle)
                MiniBody.Visible = true

                return Handle
            end

            function Window:ClearMinimizedLabels()
                for Index = #MiniLabels, 1, -1 do
                    MiniLabels[Index]:Destroy()
                end
            end

            function Window:SetCompact(State)
                Window:SetSidebarWidth(State and WindowInfo.SidebarCompactWidth or LastExpandedWidth)
            end

            function Window:GetSidebarWidth()
                return Tabs.Size.X.Offset
            end

            function Window:SetSidebarWidth(w)
                w = math.clamp(w, 48, MainFrame.Size.X.Offset - WindowInfo.MinContainerWidth - 1)

                DividerLine.Position = UDim2.fromOffset(w, 0)
                TitleHolder.Size = UDim2.new(0, w, 1, 0)
                RightWrapper.Position = UDim2.new(0, w + 8, 0.5, 0)
                RightWrapper.Size = UDim2.new(1, -w - 8 - 49 - RightBarInset, 1, -16)
                Tabs.Size = UDim2.new(0, w, 1, -70)
                Container.Size = UDim2.new(1, -w - 1, 1, -70)

                if WindowInfo.EnableCompacting then
                    ApplyCompact()
                end
                if not IsCompact then
                    LastExpandedWidth = w
                end
            end

            function Window:ShowTabInfo(n, d)
                CurrentTabLabel.Text = string.format("<b>%s</b>", tostring(n or ""))
                d = d or ""
                CurrentTabDescription.Text = d
                CurrentTabDescription.Visible = d ~= ""
                CurrentTabInfo.Visible = true

                if MiniSubtitle and not MiniSubtitleExplicit then
                    Name = Name or ""
                    MiniSubtitle.Text = Name
                    MiniSubtitle.Visible = Name ~= ""
                end
            end

            function Window:HideTabInfo()
                CurrentTabInfo.Visible = false
            end

            function Window:AddTab(...)
                local Name = nil
                local Icon = nil
                local Description = nil
                local Order = nil

                if select("#", ...) == 1 and typeof(...) == "table" then
                    local Info = select(1, ...)
                    Name = Info.Name or "Tab"
                    Icon = Info.Icon
                    Description = Info.Description
                    Order = Info.Order
                else
                    Name = select(1, ...)
                    Icon = select(2, ...)
                    Description = select(3, ...)
                    Order = select(4, ...)
                end

                local TabButton
                local TabLabel
                local TabIcon
                local TabHolder
                local TabCanvas
                local TabContainer
                local TabLeft
                local TabRight
                local TabChevron
                local TabButtonInfo
                local SidebarList
                local SidebarListLayout
                local SidebarListTween
                local SidebarEntries = {}
                local Expanded = false

                Icon = Library:GetCustomIcon(Icon)
                do
                    TabHolder = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        Parent = Tabs,
                    })
                    New("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = TabHolder,
                    })

                    TabButton = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 1,
                        LayoutOrder = 0,
                        Size = UDim2.new(1, 0, 0, 40),
                        Text = "",
                        Parent = TabHolder,
                    })
                    local ButtonPadding = New("UIPadding", {
                        PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                        PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                        PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                        PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                        Parent = TabButton,
                    })

                    TabLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(30, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Text = Name,
                        TextSize = 16,
                        TextTransparency = 0.5,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Visible = not IsCompact,
                        Parent = TabButton,
                    })

                    if Icon then
                        TabIcon = New("ImageLabel", {
                            Image = Icon.Url,
                            ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                            ImageRectOffset = Icon.ImageRectOffset,
                            ImageRectSize = Icon.ImageRectSize,
                            ImageTransparency = 0.5,
                            ScaleType = Enum.ScaleType.Fit,
                            Size = UDim2.fromScale(1, 1),
                            SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                            Parent = TabButton,
                        })
                    end

                    local TabTooltip = Library:AddTooltip(Name, nil, TabButton)
                    TabTooltip.Disabled = not IsCompact

                    table.insert(Library.TabButtons, {
                        Label = TabLabel,
                        Padding = ButtonPadding,
                        Icon = TabIcon,
                        Button = TabButton,
                        Tab = nil,
                        Tooltip = TabTooltip,
                    })

                    TabCanvas = New("CanvasGroup", {
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        GroupTransparency = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        Parent = Container,
                    })

                    TabContainer = New("Frame", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(1, 1),
                        Visible = true,
                        Parent = TabCanvas,
                    })

                    TabLeft = New("ScrollingFrame", {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2.fromScale(0, 0),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                        Size = UDim2.new(0.5, -3, 1, 0),
                        Parent = TabContainer,
                    })
                    New("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        Parent = TabLeft,
                    })
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 2),
                        PaddingLeft = UDim.new(0, 2),
                        PaddingRight = UDim.new(0, 2),
                        PaddingTop = UDim.new(0, 2),
                        Parent = TabLeft,
                    })
                    do
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = -1,
                            Parent = TabLeft,
                        })
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            Parent = TabLeft,
                        })
                    end

                    TabRight = New("ScrollingFrame", {
                        AnchorPoint = Vector2.new(1, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2.fromScale(0, 0),
                        Position = UDim2.fromScale(1, 0),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                        Size = UDim2.new(0.5, -3, 1, 0),
                        Parent = TabContainer,
                    })
                    New("UIListLayout", {
                        Padding = UDim.new(0, 2),
                        Parent = TabRight,
                    })
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 2),
                        PaddingLeft = UDim.new(0, 2),
                        PaddingRight = UDim.new(0, 2),
                        PaddingTop = UDim.new(0, 2),
                        Parent = TabRight,
                    })
                    do
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = -1,
                            Parent = TabRight,
                        })
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            Parent = TabRight,
                        })
                    end
                end

                local WarningBoxHolder = New("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(0, 7),
                    Size = UDim2.fromScale(1, 0),
                    Visible = false,
                    Parent = TabContainer,
                })

                local WarningBox
                local WarningBoxOutline
                local WarningBoxShadowOutline
                local WarningBoxScrollingFrame
                local WarningTitle
                local WarningStroke
                local WarningText
                do
                    WarningBox = New("Frame", {
                        BackgroundColor3 = "BackgroundColor",
                        Position = UDim2.fromOffset(2, 0),
                        Size = UDim2.new(1, -5, 0, 0),
                        Parent = WarningBoxHolder,
                    })
                    table.insert(
                        Library.Corners,
                        New("UICorner", {
                            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                            Parent = WarningBox,
                        })
                    )
                    WarningBoxOutline, WarningBoxShadowOutline = Library:AddOutline(WarningBox)

                    WarningBoxScrollingFrame = New("ScrollingFrame", {
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        CanvasSize = UDim2.new(0, 0, 0, 0),
                        ScrollBarThickness = 3,
                        ScrollingDirection = Enum.ScrollingDirection.Y,
                        Parent = WarningBox,
                    })
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 6),
                        PaddingRight = UDim.new(0, 6),
                        PaddingTop = UDim.new(0, 4),
                        Parent = WarningBoxScrollingFrame,
                    })

                    WarningTitle = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -4, 0, 14),
                        Text = "",
                        TextColor3 = Color3.fromRGB(255, 50, 50),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = WarningBoxScrollingFrame,
                    })

                    WarningStroke = New("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                        Color = Color3.fromRGB(169, 0, 0),
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Parent = WarningTitle,
                    })

                    WarningText = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(0, 16),
                        Size = UDim2.new(1, -4, 0, 0),
                        Text = "",
                        TextSize = 14,
                        TextWrapped = true,
                        Parent = WarningBoxScrollingFrame,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                    })

                    New("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                        Color = "DarkColor",
                        LineJoinMode = Enum.LineJoinMode.Miter,
                        Parent = WarningText,
                    })
                end

                local Tab = {
                    Type = "Tab",
                    Name = Name,
                    Description = Description,

                    Connections = {},
                    Destroyed = false,

                    Window = Window,
                    Canvas = TabCanvas,
                    Sides = {
                        TabLeft,
                        TabRight,
                    },
                    WarningBox = {
                        IsNormal = false,
                        LockSize = false,
                        Visible = false,
                        Title = "WARNING",
                        Text = "",
                    },

                    Groupboxes = {},
                    Tabboxes = {},
                    DependencyGroupboxes = {},
                    SubTabs = {},
                    ActiveSubTab = nil,
                }

                function Tab:UpdateWarningBox(Info)
                    if typeof(Info.IsNormal) == "boolean" then
                        Tab.WarningBox.IsNormal = Info.IsNormal
                    end
                    if typeof(Info.LockSize) == "boolean" then
                        Tab.WarningBox.LockSize = Info.LockSize
                    end
                    if typeof(Info.Visible) == "boolean" then
                        Tab.WarningBox.Visible = Info.Visible
                    end
                    if typeof(Info.Title) == "string" then
                        Tab.WarningBox.Title = Info.Title
                    end
                    if typeof(Info.Text) == "string" then
                        Tab.WarningBox.Text = Info.Text
                    end

                    WarningBoxHolder.Visible = Tab.WarningBox.Visible
                    WarningTitle.Text = Tab.WarningBox.Title
                    WarningText.Text = Tab.WarningBox.Text
                    Tab:Resize(true)

                    WarningBox.BackgroundColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor
                        or Color3.fromRGB(127, 0, 0)

                    WarningBoxShadowOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor
                        or Color3.fromRGB(85, 0, 0)
                    WarningBoxOutline.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                        or Color3.fromRGB(255, 50, 50)

                    WarningTitle.TextColor3 = Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor
                        or Color3.fromRGB(255, 50, 50)
                    WarningStroke.Color = Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor
                        or Color3.fromRGB(169, 0, 0)

                    if not Library.Registry[WarningBox] then
                        Library:AddToRegistry(WarningBox, {})
                    end
                    if not Library.Registry[WarningBoxShadowOutline] then
                        Library:AddToRegistry(WarningBoxShadowOutline, {})
                    end
                    if not Library.Registry[WarningBoxOutline] then
                        Library:AddToRegistry(WarningBoxOutline, {})
                    end
                    if not Library.Registry[WarningTitle] then
                        Library:AddToRegistry(WarningTitle, {})
                    end
                    if not Library.Registry[WarningStroke] then
                        Library:AddToRegistry(WarningStroke, {})
                    end

                    Library.Registry[WarningBox].BackgroundColor3 = function()
                        return Tab.WarningBox.IsNormal == true and Library.Scheme.BackgroundColor or Color3.fromRGB(127, 0, 0)
                    end

                    Library.Registry[WarningBoxShadowOutline].Color = function()
                        return Tab.WarningBox.IsNormal == true and Library.Scheme.DarkColor or Color3.fromRGB(85, 0, 0)
                    end

                    Library.Registry[WarningBoxOutline].Color = function()
                        return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(255, 50, 50)
                    end

                    Library.Registry[WarningTitle].TextColor3 = function()
                        return Tab.WarningBox.IsNormal == true and Library.Scheme.FontColor or Color3.fromRGB(255, 50, 50)
                    end

                    Library.Registry[WarningStroke].Color = function()
                        return Tab.WarningBox.IsNormal == true and Library.Scheme.OutlineColor or Color3.fromRGB(169, 0, 0)
                    end
                end

                function Tab:RefreshSides()
                    local off = Tab:GetContentOffset()
                    for _, side in Tab.Sides do
                        side.Position = UDim2.new(side.Position.X.Scale, 0, 0, off)
                        side.Size = UDim2.new(0.5, -3, 1, -off)
                    end

                    if Tab.SubTabs then
                        for _, st in Tab.SubTabs do
                            st:RefreshSides()
                        end
                    end
                end

                function Tab:Resize(ResizeWarningBox: boolean?)
                    if ResizeWarningBox then
                        local MaximumSize = math.floor(TabContainer.AbsoluteSize.Y / 3.25)
                        local _, YText = Library:GetTextBounds(
                            WarningText.Text,
                            Library.Scheme.Font,
                            WarningText.TextSize,
                            WarningText.AbsoluteSize.X
                        )

                        local YBox = 24 + YText
                        if Tab.WarningBox.LockSize == true and YBox >= MaximumSize then
                            WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, YBox)
                            YBox = MaximumSize
                        else
                            WarningBoxScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
                        end

                        WarningText.Size = UDim2.new(1, -4, 0, YText)
                        WarningBox.Size = UDim2.new(1, -5, 0, YBox + 4)
                    end

                    Tab:RefreshSides()
                end

                local function AddTabbox(self, Info)
                    local ParentObj = self

                    if typeof(Info) == "string" or Info == nil then
                        Info = { Name = Info }
                    end

                    local BoxHolder = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        Parent = if ParentObj.Type == "Groupbox" then ParentObj.Container else ((Info and Info.Side == 1) and TabLeft or TabRight),
                    })
                    New("UIListLayout", {
                        Padding = UDim.new(0, 6),
                        Parent = BoxHolder,
                    })
                    New("UIPadding", {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingTop = UDim.new(0, 4),
                        Parent = BoxHolder,
                    })

                    local TabboxHolder
                    local TabboxButtons

                    do
                        TabboxHolder = New("Frame", {
                            BackgroundColor3 = "BackgroundColor",
                            Size = UDim2.fromScale(1, 0),
                            Parent = BoxHolder,
                        })
                        table.insert(
                            Library.Corners,
                            New("UICorner", {
                                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                                Parent = TabboxHolder,
                            })
                        )
                        Library:AddOutline(TabboxHolder)

                        TabboxButtons = New("Frame", {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 34),
                            Parent = TabboxHolder,
                        })
                        New("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalFlex = Enum.UIFlexAlignment.Fill,
                            Parent = TabboxButtons,
                        })
                    end

                    local TotalTabs = 0
                    local FirstTab
                    local LastTab

                    local Tabbox = {
                        Connections = {},
                        Destroyed = false,

                        ActiveTab = nil,

                        BoxHolder = BoxHolder,
                        Holder = TabboxHolder,
                        Tabs = {}
                    }

                    function Tabbox:UpdateCorners()
                        for _, Tab in Tabbox.Tabs do
                            Tab:UpdateCorners()
                        end
                    end

                    function Tabbox:AddTab(Name, IconName)
                        TotalTabs = TotalTabs + 1
                        local TabIndex = TotalTabs

                        LastTab = TabIndex
                        if not FirstTab then
                            FirstTab = TabIndex
                        end

                        local IsNameEmpty = Name == nil or Trim(tostring(Name)) == ""
                        local TabStoringIndex = IsNameEmpty and tostring(TabIndex) or Name

                        local Button = New("TextButton", {
                            BackgroundColor3 = "MainColor",
                            BackgroundTransparency = 0,
                            Size = UDim2.fromOffset(0, 34),
                            Text = "",
                            Parent = TabboxButtons,
                        })

                        local ButtonCorner = New("UICorner", {
                            TopLeftRadius = UDim.new(0, WindowInfo.CornerRadius),
                            TopRightRadius = UDim.new(0, WindowInfo.CornerRadius),
                            BottomRightRadius = UDim.new(0, 0),
                            BottomLeftRadius = UDim.new(0, 0),
                            Parent = Button,
                        }); table.insert(Library.SpecificCorners, ButtonCorner)

                        local ButtonContent = New("Frame", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(0, 16),
                            Parent = Button,
                        })
                        New("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Center,
                            VerticalAlignment = Enum.VerticalAlignment.Center,
                            Padding = UDim.new(0, 8),
                            Parent = ButtonContent,
                        })

                        local ButtonIcon                
                        local BoxIcon = Library:GetCustomIcon(IconName)
                        if BoxIcon then
                            ButtonIcon = New("ImageLabel", {
                                Image = BoxIcon.Url,
                                ImageColor3 = BoxIcon.Custom and "WhiteColor" or "AccentColor",
                                ImageRectOffset = BoxIcon.ImageRectOffset,
                                ImageRectSize = BoxIcon.ImageRectSize,
                                ImageTransparency = 0.5,
                                Size = IsNameEmpty and UDim2.fromOffset(16, 16) or UDim2.fromOffset(18, 18),
                                Parent = ButtonContent,
                            })
                        end

                        local ButtonLabel
                        if not IsNameEmpty then
                            ButtonLabel = New("TextLabel", {
                                AutomaticSize = Enum.AutomaticSize.X,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(0, 16),
                                Text = Name,
                                TextSize = 15,
                                TextTransparency = 0.5,
                                Parent = ButtonContent,
                            })
                        end

                        local Line = Library:MakeLine(Button, {
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.new(0, 0, 1, 1),
                            Size = UDim2.new(1, 0, 0, 1),
                        })

                        local Container = New("Frame", {
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(0, 35),
                            Size = UDim2.new(1, 0, 1, -35),
                            Visible = false,
                            Parent = TabboxHolder,
                        })
                        local List = New("UIListLayout", {
                            Padding = UDim.new(0, 8),
                            Parent = Container,
                        })
                        New("UIPadding", {
                            PaddingBottom = UDim.new(0, 7),
                            PaddingLeft = UDim.new(0, 7),
                            PaddingRight = UDim.new(0, 7),
                            PaddingTop = UDim.new(0, 7),
                            Parent = Container,
                        })

                        local Tab = {
                            Connections = {},
                            Destroyed = false,

                            ButtonHolder = Button,
                            Container = Container,
                            ButtonCorner = ButtonCorner,

                            Tab = Tab,
                            Elements = {},
                            DependencyBoxes = {},
                        }

                        function Tab:Show()
                            if Tabbox.ActiveTab then
                                Tabbox.ActiveTab:Hide()
                            end

                            Button.BackgroundTransparency = 1

                            if ButtonLabel then
                                ButtonLabel.TextTransparency = 0
                            end
                            if ButtonIcon then
                                ButtonIcon.ImageTransparency = 0
                            end

                            Line.Visible = false

                            Container.Visible = true

                            Tabbox.ActiveTab = Tab
                            Tab:Resize()
                        end

                        function Tab:Hide()
                            Button.BackgroundTransparency = 0

                            if ButtonLabel then
                                ButtonLabel.TextTransparency = 0.5
                            end
                            if ButtonIcon then
                                ButtonIcon.ImageTransparency = 0.5
                            end
                            Line.Visible = true
                            Container.Visible = false

                            Tabbox.ActiveTab = nil
                        end

                        function Tab:Resize()
                            if Tabbox.ActiveTab ~= Tab then
                                return
                            end

                            TabboxHolder.Size = UDim2.new(1, 0, 0, (List.AbsoluteContentSize.Y / Library.DPIScale) + 49)
                            if ParentObj.Type == "Groupbox" then
                                ParentObj:Resize()
                            end
                        end

                        function Tab:UpdateCorners()
                            local Radius = WindowInfo.CornerRadius

                            ButtonCorner.TopLeftRadius = UDim.new(0, TabIndex == FirstTab and Radius or 0)
                            ButtonCorner.TopRightRadius = UDim.new(0, TabIndex == LastTab and Radius or 0)
                        end

                        function Tab:Destroy()
                            Tab.Destroyed = true

                            if Tab.Connections then
                                for _, Connection in Tab.Connections do
                                    Connection:Disconnect()
                                end
                            end

                            for _, Element in Tab.Elements do
                                if Element.Destroy then
                                    Element:Destroy()
                                end
                            end

                            for _, SubDepbox in Tab.DependencyBoxes do
                                if SubDepbox.Destroy then
                                    SubDepbox:Destroy()
                                end
                            end

                            if Container then
                                Container:Destroy()
                            end

                            if Button then
                                Button:Destroy()
                            end
                        end

                        if not Tabbox.ActiveTab then
                            Tab:Show()
                        end

                        Button.MouseButton1Click:Connect(Tab.Show)

                        setmetatable(Tab, BaseGroupbox)

                        Tabbox.Tabs[TabStoringIndex] = Tab
                        Tabbox:UpdateCorners()

                        return Tab, TabStoringIndex
                    end

                    function Tabbox:Destroy()
                        Tabbox.Destroyed = true

                        if Tabbox.Connections then
                            for _, Connection in Tabbox.Connections do
                                Connection:Disconnect()
                            end
                        end

                        for _, Tab in Tabbox.Tabs do
                            if Tab.Destroy then
                                Tab:Destroy()
                            end
                        end

                        if TabboxHolder then
                            TabboxHolder:Destroy()
                        end

                        if BoxHolder then
                            BoxHolder:Destroy()
                        end
                    end

                    if Info.Name then
                        Tab.Tabboxes[Info.Name] = Tabbox
                    else
                        table.insert(Tab.Tabboxes, Tabbox)
                    end

                    if ParentObj.Type == "Groupbox" then
                        ParentObj.Tabboxes = ParentObj.Tabboxes or {}
                        if Info.Name then
                            ParentObj.Tabboxes[Info.Name] = Tabbox
                        else
                            table.insert(ParentObj.Tabboxes, Tabbox)
                        end
                    end

                    return Tabbox
                end

                Tab.AddTabbox = AddTabbox

                function Tab:AddLeftTabbox(Name)
                    return self:AddTabbox({ Side = 1, Name = Name })
                end

                function Tab:AddRightTabbox(Name)
                    return self:AddTabbox({ Side = 2, Name = Name })
                end

                function Tab:AddGroupbox(i)
                    local o = self or Tab
                    local s = i.Side or 1
                    if typeof(s) == "string" then
                        s = s:lower() == "left" and 1 or 2
                    end

                    local bh = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        Parent = s == 1 and o.Sides[1] or o.Sides[2],
                    })
                    New("UIListLayout", { Padding = UDim.new(0, 6), Parent = bh })
                    New("UIPadding", { PaddingBottom = UDim.new(0, 4), PaddingTop = UDim.new(0, 4), Parent = bh })

                    local gh = New("Frame", {
                        BackgroundColor3 = "BackgroundColor",
                        Size = UDim2.fromScale(1, 0),
                        Parent = bh,
                    })
                    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, WindowInfo.CornerRadius), Parent = gh }))
                    New("UIListLayout", { Parent = gh })
                    Library:AddOutline(gh)

                    local gt = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        Parent = gh,
                    })
                    New("UIPadding", { PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), Parent = gt })

                    local bi = Library:GetCustomIcon(i.IconName)
                    if bi then
                        New("ImageLabel", {
                            AnchorPoint = Vector2.new(0, 0.5),
                            Image = bi.Url,
                            ImageColor3 = bi.Custom and "WhiteColor" or "AccentColor",
                            ImageRectOffset = bi.ImageRectOffset,
                            ImageRectSize = bi.ImageRectSize,
                            Position = UDim2.fromScale(0, 0.5),
                            Size = UDim2.fromOffset(22, 22),
                            Parent = gt,
                        })
                    end

                    local tf = New("Frame", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(bi and 24 or 0, 0),
                        Size = UDim2.new(1, -22 - (bi and 24 or 0), 0, 0),
                        Parent = gt,
                    })
                    New("UIListLayout", { Parent = tf })
                    New("UIPadding", { PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 3), Parent = tf })

                    local gl = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        Text = i.Name,
                        TextSize = 15,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = tf,
                    })
                    New("UIPadding", { PaddingBottom = UDim.new(0, 1), Parent = gl })

                    local gd = New("TextLabel", {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                        Text = i.Description or "",
                        TextSize = 14,
                        TextTransparency = 0.5,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Visible = (i.Description ~= nil),
                        Parent = tf,
                    })

                    local gca
                    if i.DisableCollapsing ~= true then
                        gca = New("ImageButton", {
                            AnchorPoint = Vector2.new(1, 0.5),
                            BackgroundTransparency = 1,
                            Image = ArrowIcon and ArrowIcon.Url or "",
                            ImageColor3 = "WhiteColor",
                            ImageRectOffset = ArrowIcon and ArrowIcon.ImageRectOffset or Vector2.zero,
                            ImageRectSize = ArrowIcon and ArrowIcon.ImageRectSize or Vector2.zero,
                            Rotation = 180,
                            Position = UDim2.fromScale(1, 0.5),
                            Size = UDim2.fromOffset(22, 22),
                            Parent = gt,
                        })
                    end

                    local gln = Library:MakeLine(gh, {
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 1),
                    })

                    local gc = New("Frame", {
                        BackgroundTransparency = 1,
                        LayoutOrder = 2,
                        Size = UDim2.fromScale(1, 0),
                        Parent = gh,
                    })
                    local glist = New("UIListLayout", { Padding = UDim.new(0, 8), Parent = gc })
                    New("UIPadding", { PaddingBottom = UDim.new(0, 7), PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), PaddingTop = UDim.new(0, 7), Parent = gc })

                    local gbox = {
                        Type = "Groupbox",
                        Connections = {},
                        Destroyed = false,
                        Visible = true,
                        Collapsed = false,
                        BoxHolder = bh,
                        Holder = gh,
                        Container = gc,
                        Tab = Tab,
                        DependencyBoxes = {},
                        Elements = {}
                    }

                    local rzT, caT

                    function gbox:Resize()
                        if rzT then StopTween(rzT, true) rzT = nil end
                        local tS = (gt.AbsoluteSize.Y / Library.DPIScale)
                        local cS = (glist.AbsoluteContentSize.Y / Library.DPIScale) + 14
                        local tgS = UDim2.new(1, 0, 0, if gbox.Collapsed then tS else (tS + 1 + cS))

                        gc.Size = UDim2.new(1, 0, 0, cS)
                        gln.Visible = not gbox.Collapsed
                        if Library.Animations and Library.Animations.Groupbox then
                            local ti = Library.GroupboxTweenInfo or TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                            local tw = TweenService:Create(gh, ti, { Size = tgS })
                            rzT = tw
                            local conn; conn = Library:GiveSignal(tw.Completed:Once(function()
                                if conn then conn:Disconnect() end
                                if rzT == tw then StopTween(rzT, true) rzT = nil end
                            end))
                            tw:Play()
                        else
                            gh.Size = tgS
                        end
                    end

                    function gbox:SetDescription(desc)
                        gd.Text = desc or ""
                        gd.Visible = (desc ~= nil)
                        gbox:Resize()
                    end

                    function gbox:SetCollapsed(col)
                        if i.DisableCollapsing == true then return end
                        gbox.Collapsed = col
                        if caT then StopTween(caT, true) caT = nil end
                        local rot = col and 0 or 180
                        gc.Visible = not col

                        if Library.Animations and Library.Animations.Groupbox then
                            local ti = Library.GroupboxTweenInfo or TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                            local tw = TweenService:Create(gca, ti, { Rotation = rot })
                            caT = tw
                            local conn; conn = Library:GiveSignal(tw.Completed:Connect(function()
                                if conn then conn:Disconnect() end
                                if caT == tw then StopTween(caT, true) caT = nil end
                            end))
                            tw:Play()
                        elseif gca then
                            gca.Rotation = rot
                        end
                        gbox:Resize()
                    end

                    function gbox:ToggleCollapsed()
                        if i.DisableCollapsing == true then return end
                        gbox:SetCollapsed(not gbox.Collapsed)
                    end

                    function gbox:Destroy()
                        gbox.Destroyed = true
                        if rzT then StopTween(rzT, true) rzT = nil end
                        if caT then StopTween(caT, true) caT = nil end
                        if gbox.Connections then
                            for _, cn in gbox.Connections do cn:Disconnect() end
                        end
                        for _, el in gbox.Elements do
                            if el.Destroy then el:Destroy() end
                        end
                        table.clear(gbox.Elements)
                        for _, sdb in gbox.DependencyBoxes do
                            if sdb.Destroy then sdb:Destroy() end
                        end
                        table.clear(gbox.DependencyBoxes)
                        if gh then gh:Destroy() end
                        if bh then bh:Destroy() end
                    end

                    function gbox:SetVisible(vis)
                        gbox.Visible = vis
                        bh.Visible = vis
                        if vis == true and Library.Searching then
                            Library:UpdateSearch(Library.SearchText)
                        end
                    end

                    function gbox:Show() gbox:SetVisible(true) end
                    function gbox:Hide() gbox:SetVisible(false) end

                    if gca then
                        gca.MouseButton1Click:Connect(function()
                            gbox:ToggleCollapsed()
                        end)
                    end

                    gbox.AddTabbox = AddTabbox
                    setmetatable(gbox, BaseGroupbox)

                    gbox:Resize()
                    Tab.Groupboxes[i.Name] = gbox

                    if i.Visible == false then gbox:Hide() end
                    if i.DisableCollapsing ~= true and i.Collapsed == true then gbox:SetCollapsed(true) end

                    return gbox
                end

                function Tab:AddLeftGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
                    return self:AddGroupbox({ Side = 1, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
                end

                function Tab:AddRightGroupbox(Name, IconName, Visible, Collapsed, DisableCollapsing)
                    return self:AddGroupbox({ Side = 2, Name = Name, IconName = IconName, Visible = Visible, Collapsed = Collapsed, DisableCollapsing = DisableCollapsing })
                end

                local function SidebarListHeight(): number
                    return SidebarListLayout and SidebarListLayout.AbsoluteContentSize.Y or 0
                end

                local function ResizeSidebarList(Animate: boolean?)
                    if not SidebarList then
                        return
                    end

                    local Open = Expanded and not IsCompact
                    local Target = Open and SidebarListHeight() or 0
                    local Animated = Animate and Library.Animations and Library.Animations.SidebarSubTabs ~= false

                    if SidebarListTween then
                        StopTween(SidebarListTween, true)
                        SidebarListTween = nil
                    end

                    if Target > 0 then
                        SidebarList.Visible = true
                    end

                    if Animated then
                        SidebarListTween = TweenService:Create(SidebarList, Library.GroupboxTweenInfo, {
                            Size = UDim2.new(1, 0, 0, Target),
                        })

                        if Target == 0 then
                            local Connection
                            Connection = SidebarListTween.Completed:Connect(function(State: Enum.PlaybackState)
                                Connection:Disconnect()

                                if State == Enum.PlaybackState.Completed and SidebarList.Size.Y.Offset == 0 then
                                    SidebarList.Visible = false
                                end
                            end)
                        end

                        SidebarListTween:Play()
                    else
                        SidebarList.Size = UDim2.new(1, 0, 0, Target)
                        SidebarList.Visible = Target > 0
                    end

                    if TabChevron then
                        local Rotation = Open and 180 or 0

                        if Animated then
                            TweenService:Create(TabChevron, Library.RotatingChevronTweenInfo, {
                                Rotation = Rotation,
                            }):Play()
                        else
                            TabChevron.Rotation = Rotation
                        end
                    end
                end

                local function EnsureSidebarList()
                    if SidebarList then
                        return
                    end

                    SidebarList = New("Frame", {
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        Visible = false,
                        Parent = TabHolder,
                    })
                    SidebarListLayout = New("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Parent = SidebarList,
                    })

                    local ChevronIcon = Library:GetIcon("chevron-down")
                    TabChevron = New("ImageButton", {
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Image = ChevronIcon and ChevronIcon.Url or "",
                        ImageColor3 = "FontColor",
                        ImageRectOffset = ChevronIcon and ChevronIcon.ImageRectOffset or Vector2.zero,
                        ImageRectSize = ChevronIcon and ChevronIcon.ImageRectSize or Vector2.zero,
                        ImageTransparency = 0.5,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Visible = not IsCompact,
                        ZIndex = 3,
                        Parent = TabButton,
                    })

                    TabLabel.Size = UDim2.new(1, -30 - 18, 1, 0)

                    TabChevron.MouseButton1Click:Connect(function()
                        Tab:SetExpanded(not Expanded)
                    end)

                    if TabButtonInfo then
                        TabButtonInfo.Chevron = TabChevron
                        TabButtonInfo.SidebarList = SidebarList
                    end

                    if Library.ActiveTab == Tab then
                        Expanded = true
                    end

                    Library:GiveSignal(SidebarListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if Expanded then
                            ResizeSidebarList(false)
                        end
                    end))
                end

                local function CreateSidebarEntry(SubTab, SubName: string, SubIcon)
                    EnsureSidebarList()

                    if not SidebarList then
                        return nil
                    end

                    local Entry = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 1,
                        LayoutOrder = #SidebarEntries,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = "",
                        Parent = SidebarList,
                    })

                    local Marker = New("Frame", {
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = "AccentColor",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 14, 0.5, 0),
                        Size = UDim2.fromOffset(2, 16),
                        Parent = Entry,
                    })
                    table.insert(
                        Library.PillCorners,
                        New("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = Marker,
                        })
                    )

                    local TextOffset = SUBTAB_SIDEBAR_INDENT + SUBTAB_SIDEBAR_ICON_COLUMN

                    local EntryIcon
                    if SubIcon then
                        EntryIcon = New("ImageLabel", {
                            AnchorPoint = Vector2.new(0, 0.5),
                            BackgroundTransparency = 1,
                            Image = SubIcon.Url,
                            ImageColor3 = SubIcon.Custom and "WhiteColor" or "FontColor",
                            ImageRectOffset = SubIcon.ImageRectOffset,
                            ImageRectSize = SubIcon.ImageRectSize,
                            ImageTransparency = SUBTAB_IDLE_TRANSPARENCY,
                            Position = UDim2.new(0, SUBTAB_SIDEBAR_INDENT, 0.5, 0),
                            ScaleType = Enum.ScaleType.Fit,
                            Size = UDim2.fromOffset(14, 14),
                            Parent = Entry,
                        })
                    end

                    local EntryLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(TextOffset, 0),
                        Size = UDim2.new(1, -TextOffset - 10, 1, 0),
                        Text = SubName,
                        TextSize = 14,
                        TextTransparency = SUBTAB_IDLE_TRANSPARENCY,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Entry,
                    })

                    local Handle = {
                        Button = Entry,
                        Label = EntryLabel,
                        Active = false,
                    }

                    function Handle:SetActive(Value: boolean)
                        Handle.Active = Value and true or false

                        Library:AddToRegistry(EntryLabel, { TextColor3 = Handle.Active and "AccentColor" or "FontColor" })
                        EntryLabel.TextColor3 = Handle.Active and Library.Scheme.AccentColor or Library.Scheme.FontColor

                        TweenService:Create(Entry, Library.TweenInfo, {
                            BackgroundTransparency = Handle.Active and 0.5 or 1,
                        }):Play()
                        TweenService:Create(Marker, Library.TweenInfo, {
                            BackgroundTransparency = Handle.Active and 0 or 1,
                        }):Play()
                        TweenService:Create(EntryLabel, Library.TweenInfo, {
                            TextTransparency = Handle.Active and 0 or SUBTAB_IDLE_TRANSPARENCY,
                        }):Play()

                        if EntryIcon then
                            TweenService:Create(EntryIcon, Library.TweenInfo, {
                                ImageTransparency = Handle.Active and 0 or SUBTAB_IDLE_TRANSPARENCY,
                            }):Play()
                        end
                    end

                    function Handle:SetVisible(Value: boolean)
                        Entry.Visible = Value and true or false
                        ResizeSidebarList(false)
                    end

                    function Handle:Destroy()
                        local Index = table.find(SidebarEntries, Handle)
                        if Index then
                            table.remove(SidebarEntries, Index)
                        end

                        Entry:Destroy()
                        ResizeSidebarList(false)
                    end

                    Entry.MouseEnter:Connect(function()
                        if Handle.Active then
                            return
                        end

                        TweenService:Create(EntryLabel, Library.TweenInfo, { TextTransparency = 0.2 }):Play()
                    end)
                    Entry.MouseLeave:Connect(function()
                        if Handle.Active then
                            return
                        end

                        TweenService:Create(EntryLabel, Library.TweenInfo, {
                            TextTransparency = SUBTAB_IDLE_TRANSPARENCY,
                        }):Play()
                    end)

                    Entry.MouseButton1Click:Connect(function()
                        if Library.ActiveTab ~= Tab then
                            Tab:Show()
                        end

                        SubTab:Show()
                    end)

                    table.insert(SidebarEntries, Handle)
                    ResizeSidebarList(false)

                    return Handle
                end

                function Tab:IsExpanded(): boolean
                    return Expanded
                end

                function Tab:SetExpanded(Value: boolean?)
                    if Value == nil then
                        Value = not Expanded
                    end
                    Expanded = Value and true or false

                    ResizeSidebarList(true)
                end

                function Tab:ToggleExpanded()
                    Tab:SetExpanded(not Expanded)
                end

                local SubTabBar
                local SubTabButtons
                local SubTabBarLayout
                local SubTabUnderline
                local SubTabUnderlineTween
                local SubTabAlignment = "Center"
                local MoveSubTabUnderline

                local function CreateSubTabBar()
                    if SubTabBar then
                        return
                    end

                    SubTabBar = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -4, 0, SUBTAB_BAR_HEIGHT),
                        Position = UDim2.fromOffset(2, 0),
                        ZIndex = 2,
                        Parent = TabContainer,
                    })
                    SubTabButtons = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Parent = SubTabBar,
                    })
                    SubTabBarLayout = New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment[SubTabAlignment],
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6),
                        Parent = SubTabButtons,
                    })

                    SubTabUnderline = New("Frame", {
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = "AccentColor",
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 1, 0),
                        Size = UDim2.fromOffset(0, 1),
                        Visible = false,
                        Parent = SubTabBar,
                    })
                    New("UIGradient", {
                        Color = function()
                            return ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Library.Scheme.FontColor),
                                ColorSequenceKeypoint.new(0.5, Library.Scheme.AccentColor),
                                ColorSequenceKeypoint.new(1, Library.Scheme.FontColor),
                            })
                        end,
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(0.2, 0.85),
                            NumberSequenceKeypoint.new(0.5, 0.1),
                            NumberSequenceKeypoint.new(0.8, 0.85),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                        Parent = SubTabUnderline,
                    })

                    table.insert(
                        Tab.Connections,
                        SubTabBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                            if Tab.ActiveSubTab then
                                SubTabUnderline.Visible = false
                                MoveSubTabUnderline(Tab.ActiveSubTab.Button)
                            end
                        end)
                    )

                    TabLeft.Visible = false
                    TabRight.Visible = false

                    Tab:RefreshSides()
                end

                function MoveSubTabUnderline(btn)
                    if not SubTabUnderline then
                        return
                    end

                    if btn.AbsoluteSize.X == 0 then
                        task.defer(function()
                            if Tab.ActiveSubTab and Tab.ActiveSubTab.Button == btn then
                                MoveSubTabUnderline(btn)
                            end
                        end)
                        return
                    end

                    local sc = Library.DPIScale
                    local ox = (btn.AbsolutePosition.X - SubTabBar.AbsolutePosition.X) / sc
                    local w = btn.AbsoluteSize.X / sc
                    local bot = (btn.AbsolutePosition.Y + btn.AbsoluteSize.Y - SubTabBar.AbsolutePosition.Y) / sc
                    local lw = math.floor(w * SUBTAB_UNDERLINE_WIDTH)

                    local target = {
                        Position = UDim2.fromOffset(
                            math.floor(ox + (w - lw) / 2),
                            bot - SUBTAB_UNDERLINE_GAP
                        ),
                        Size = UDim2.fromOffset(lw, 1),
                    }

                    if SubTabUnderlineTween then
                        StopTween(SubTabUnderlineTween, true)
                        SubTabUnderlineTween = nil
                    end

                    if not SubTabUnderline.Visible then
                        SubTabUnderline.Position = target.Position
                        SubTabUnderline.Size = target.Size
                        SubTabUnderline.Visible = true
                        return
                    end

                    if Library.Animations and Library.Animations.SubTabUnderline == false then
                        SubTabUnderline.Position = target.Position
                        SubTabUnderline.Size = target.Size
                        return
                    end

                    SubTabUnderlineTween = TweenService:Create(SubTabUnderline, SUBTAB_SLIDE_TWEEN, target)
                    SubTabUnderlineTween:Play()
                end

                function Tab:SetSubTabAlignment(align)
                    assert(Enum.HorizontalAlignment[align], "Alignment must be Left, Center or Right.")
                    SubTabAlignment = align
                    if SubTabBarLayout then
                        SubTabBarLayout.HorizontalAlignment = Enum.HorizontalAlignment[align]
                    end
                end

                function Tab:GetContentOffset()
                    local off = WarningBoxHolder.Visible and WarningBox.Size.Y.Offset + 8 or 0
                    if SubTabBar then
                        SubTabBar.Position = UDim2.new(0, 2, 0, off)
                        off += SUBTAB_BAR_HEIGHT + 6
                    end
                    return off
                end

                function Tab:AddSubTab(...)
                    local sName = nil
                    local sIcon = nil

                    if select("#", ...) == 1 and typeof(...) == "table" then
                        local info = select(1, ...)
                        sName = info.Name or "SubTab"
                        sIcon = info.Icon
                    else
                        sName = select(1, ...) or "SubTab"
                        sIcon = select(2, ...)
                    end

                    CreateSubTabBar()

                    sIcon = Library:GetCustomIcon(sIcon)

                    local icW = sIcon and SUBTAB_ICON_SIZE + 6 or 0
                    local txtW = math.ceil(Library:GetTextBounds(sName, Library.Scheme.Font, 15))

                    local btn = New("TextButton", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(txtW + icW + 24, SUBTAB_BAR_HEIGHT - 8),
                        Text = "",
                        Parent = SubTabButtons,
                    })

                    local btnVis = New("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromScale(1, 1),
                        Parent = btn,
                    })
                    local btnScale = New("UIScale", {
                        Scale = 1,
                        Parent = btnVis,
                    })

                    local btnShadows = {}
                    for idx = 1, 2 do
                        local sh = New("Frame", {
                            BackgroundColor3 = "DarkColor",
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(0, idx),
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 1,
                            Parent = btnVis,
                        })
                        table.insert(
                            Library.Corners,
                            New("UICorner", {
                                CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                                Parent = sh,
                            })
                        )
                        table.insert(btnShadows, sh)
                    end

                    local chip = New("Frame", {
                        BackgroundColor3 = function()
                            return Library:GetBetterColor(Library.Scheme.MainColor, 10)
                        end,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 2,
                        Parent = btnVis,
                    })
                    table.insert(
                        Library.Corners,
                        New("UICorner", {
                            CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                            Parent = chip,
                        })
                    )
                    local btnStroke = New("UIStroke", {
                        Color = "OutlineColor",
                        Transparency = 1,
                        Parent = chip,
                    })

                    local btnCnt = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Parent = chip,
                    })
                    New("UIListLayout", {
                        FillDirection = Enum.FillDirection.Horizontal,
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6),
                        Parent = btnCnt,
                    })

                    local btnIcon
                    if sIcon then
                        btnIcon = New("ImageLabel", {
                            Image = sIcon.Url,
                            ImageColor3 = sIcon.Custom and "WhiteColor" or "AccentColor",
                            ImageRectOffset = sIcon.ImageRectOffset,
                            ImageRectSize = sIcon.ImageRectSize,
                            ImageTransparency = SUBTAB_IDLE_TRANSPARENCY,
                            ScaleType = Enum.ScaleType.Fit,
                            Size = UDim2.fromOffset(SUBTAB_ICON_SIZE, SUBTAB_ICON_SIZE),
                            Parent = btnCnt,
                        })
                    end

                    local btnLbl = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(txtW, 16),
                        Text = sName,
                        TextSize = 15,
                        TextTransparency = SUBTAB_IDLE_TRANSPARENCY,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Parent = btnCnt,
                    })

                    local subCanvas = New("CanvasGroup", {
                        BackgroundTransparency = 1,
                        GroupTransparency = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        Parent = TabContainer,
                    })

                    local subLeft = New("ScrollingFrame", {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2.fromScale(0, 0),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                        Size = UDim2.new(0.5, -3, 1, 0),
                        Parent = subCanvas,
                    })
                    local subRight = New("ScrollingFrame", {
                        AnchorPoint = Vector2.new(1, 0),
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2.fromScale(0, 0),
                        Position = UDim2.fromScale(1, 0),
                        ScrollBarImageTransparency = 1,
                        ScrollBarThickness = 0,
                        Size = UDim2.new(0.5, -3, 1, 0),
                        Parent = subCanvas,
                    })

                    for _, side in { subLeft, subRight } do
                        New("UIListLayout", {
                            Padding = UDim.new(0, 2),
                            Parent = side,
                        })
                        New("UIPadding", {
                            PaddingBottom = UDim.new(0, 2),
                            PaddingLeft = UDim.new(0, 2),
                            PaddingRight = UDim.new(0, 2),
                            PaddingTop = UDim.new(0, 2),
                            Parent = side,
                        })
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = -1,
                            Parent = side,
                        })
                        New("Frame", {
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            Parent = side,
                        })
                    end

                    local subTab = {
                        Type = "SubTab",
                        Name = sName,
                        Connections = {},
                        Destroyed = false,
                        Window = Window,
                        Tab = Tab,
                        Canvas = subCanvas,
                        Button = btn,
                        Sides = { subLeft, subRight },
                        Groupboxes = {},
                        Tabboxes = {},
                        DependencyGroupboxes = {},
                    }

                    subTab.AddGroupbox = Tab.AddGroupbox
                    subTab.AddLeftGroupbox = Tab.AddLeftGroupbox
                    subTab.AddRightGroupbox = Tab.AddRightGroupbox
                    subTab.AddTabbox = AddTabbox
                    subTab.AddLeftTabbox = Tab.AddLeftTabbox
                    subTab.AddRightTabbox = Tab.AddRightTabbox

                    function subTab:RefreshSides()
                        local off = Tab:GetContentOffset()
                        for _, side in subTab.Sides do
                            side.Position = UDim2.new(side.Position.X.Scale, 0, 0, off)
                            side.Size = UDim2.new(0.5, -3, 1, -off)
                        end
                    end

                    function subTab:Resize()
                        subTab:RefreshSides()
                    end

                    function subTab:Hover(hov)
                        TweenService:Create(btnScale, SUBTAB_HOVER_TWEEN, {
                            Scale = hov and SUBTAB_HOVER_SCALE or 1,
                        }):Play()

                        if Tab.ActiveSubTab == subTab then
                            return
                        end

                        TweenService:Create(chip, Library.TweenInfo, {
                            BackgroundTransparency = hov and 0.45 or 1,
                        }):Play()
                        TweenService:Create(btnStroke, Library.TweenInfo, {
                            Transparency = hov and 0.7 or 1,
                        }):Play()
                        for idx, sh in btnShadows do
                            TweenService:Create(sh, Library.TweenInfo, {
                                BackgroundTransparency = hov and SUBTAB_SHADOW_TRANSPARENCY[idx] + 0.2 or 1,
                            }):Play()
                        end
                        TweenService:Create(btnLbl, Library.TweenInfo, {
                            TextTransparency = hov and 0.1 or SUBTAB_IDLE_TRANSPARENCY,
                        }):Play()
                        if btnIcon then
                            TweenService:Create(btnIcon, Library.TweenInfo, {
                                ImageTransparency = hov and 0.1 or SUBTAB_IDLE_TRANSPARENCY,
                            }):Play()
                        end
                    end

                    function subTab:Show()
                        if Tab.ActiveSubTab == subTab then
                            return
                        end

                        if Tab.ActiveSubTab then
                            Tab.ActiveSubTab:Hide()
                        end

                        Library:AddToRegistry(btnLbl, { TextColor3 = "AccentColor" })
                        btnLbl.TextColor3 = Library.Scheme.AccentColor

                        TweenService:Create(chip, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                        TweenService:Create(btnStroke, Library.TweenInfo, { Transparency = 0.25 }):Play()
                        for idx, sh in btnShadows do
                            TweenService:Create(sh, Library.TweenInfo, { BackgroundTransparency = SUBTAB_SHADOW_TRANSPARENCY[idx] }):Play()
                        end
                        TweenService:Create(btnLbl, Library.TweenInfo, { TextTransparency = 0 }):Play()
                        if btnIcon then
                            TweenService:Create(btnIcon, Library.TweenInfo, { ImageTransparency = 0 }):Play()
                        end

                        if subTab.SidebarEntry then
                            subTab.SidebarEntry:SetActive(true)
                        end

                        Tab.ActiveSubTab = subTab
                        MoveSubTabUnderline(btn)

                        subTab:RefreshSides()
                        Library:PlayTabAnimation(subCanvas, true)

                        if Library.Searching then
                            Library:UpdateSearch(Library.SearchText)
                        end
                    end

                    function subTab:Hide()
                        Library:AddToRegistry(btnLbl, { TextColor3 = "FontColor" })
                        btnLbl.TextColor3 = Library.Scheme.FontColor

                        TweenService:Create(chip, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                        TweenService:Create(btnStroke, Library.TweenInfo, { Transparency = 1 }):Play()
                        for _, sh in btnShadows do
                            TweenService:Create(sh, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                        end
                        TweenService:Create(btnLbl, Library.TweenInfo, { TextTransparency = SUBTAB_IDLE_TRANSPARENCY }):Play()
                        if btnIcon then
                            TweenService:Create(btnIcon, Library.TweenInfo, { ImageTransparency = SUBTAB_IDLE_TRANSPARENCY }):Play()
                        end

                        if subTab.SidebarEntry then
                            subTab.SidebarEntry:SetActive(false)
                        end

                        Library:PlayTabAnimation(subCanvas, false)

                        if Tab.ActiveSubTab == subTab then
                            Tab.ActiveSubTab = nil
                        end
                    end

                    function subTab:SetVisible(vis)
                        btn.Visible = vis

                        if subTab.SidebarEntry then
                            subTab.SidebarEntry:SetVisible(vis)
                        end
                        if not vis then
                            btnScale.Scale = 1
                        end

                        if not vis and Tab.ActiveSubTab == subTab then
                            subTab:Hide()
                            for _, ot in Tab.SubTabs do
                                if ot ~= subTab and ot.Button.Visible then
                                    ot:Show()
                                    break
                                end
                            end

                            if not Tab.ActiveSubTab and SubTabUnderline then
                                SubTabUnderline.Visible = false
                            end
                        end
                    end

                    function subTab:Destroy()
                        subTab.Destroyed = true

                        if subTab.SidebarEntry then
                            subTab.SidebarEntry:Destroy()
                            subTab.SidebarEntry = nil
                        end

                        for _, conn in subTab.Connections do
                            conn:Disconnect()
                        end

                        for _, gb in subTab.Groupboxes do
                            if gb.Destroy then gb:Destroy() end
                        end
                        table.clear(subTab.Groupboxes)

                        for _, tb in subTab.Tabboxes do
                            if tb.Destroy then tb:Destroy() end
                        end
                        table.clear(subTab.Tabboxes)

                        for _, dgb in subTab.DependencyGroupboxes do
                            if dgb.Destroy then dgb:Destroy() end
                        end

                        Library:RemoveFromRegistry(btnLbl)
                        subCanvas:Destroy()
                        btn:Destroy()

                        if Tab.ActiveSubTab == subTab then
                            Tab.ActiveSubTab = nil
                            if SubTabUnderline then
                                SubTabUnderline.Visible = false
                            end
                        end
                        Tab.SubTabs[sName] = nil
                    end

                    btn.MouseEnter:Connect(function() subTab:Hover(true) end)
                    btn.MouseLeave:Connect(function() subTab:Hover(false) end)
                    btn.MouseButton1Click:Connect(function() subTab:Show() end)

                    Tab.SubTabs[sName] = subTab

                    subTab.SidebarEntry = CreateSidebarEntry(subTab, sName, sIcon)

                    if not Tab.ActiveSubTab then
                        subTab:Show()
                    else
                        subTab:RefreshSides()
                    end

                    return subTab
                end

                function Tab:Hover(Hovering)
                    if Library.ActiveTab == Tab then
                        return
                    end

                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = Hovering and 0.25 or 0.5,
                    }):Play()
                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = Hovering and 0.25 or 0.5,
                        }):Play()
                    end
                end

                function Tab:Show()
                    if Library.ActiveTab == Tab then
                        return
                    end

                    if Library.ActiveTab then
                        Library.ActiveTab:Hide()
                    end

                    TweenService:Create(TabButton, Library.TweenInfo, {
                        BackgroundTransparency = 0,
                    }):Play()
                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = 0,
                    }):Play()
                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = 0,
                        }):Play()
                    end

                    if Description then
                        Window:ShowTabInfo(Name, Description)
                    end

                    if SidebarList then
                        Tab:SetExpanded(true)
                    end

                    Library:PlayTabAnimation(TabCanvas, true)
                    Tab:RefreshSides()

                    Library.ActiveTab = Tab

                    if Library.Searching then
                        Library:UpdateSearch(Library.SearchText)
                    end

                    UpdateMarker()
                end

                function Tab:Hide()
                    TweenService:Create(TabButton, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()

                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = 0.5,
                    }):Play()

                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = 0.5,
                        }):Play()
                    end

                    Library:PlayTabAnimation(TabCanvas, false)
                    Window:HideTabInfo()

                    Library.ActiveTab = nil
                end

                function Tab:SetVisible(Visible: boolean)
                    TabHolder.Visible = Visible
                    TabButton.Visible = Visible

                    if not Visible and Library.ActiveTab == Tab then
                        Tab:Hide()
                    end
                end

                function Tab:SetOrder(Order: number)
                    TabButton.LayoutOrder = Order
                end

                function Tab:Destroy()
                    Tab.Destroyed = true

                    if Tab.Connections then
                        for _, Connection in Tab.Connections do
                            Connection:Disconnect()
                        end
                    end

                    for _, Groupbox in Tab.Groupboxes do
                        if Groupbox.Destroy then
                            Groupbox:Destroy()
                        end
                    end
                    table.clear(Tab.Groupboxes)

                    for _, Tabbox in Tab.Tabboxes do
                        if Tabbox.Destroy then
                            Tabbox:Destroy()
                        end
                    end
                    table.clear(Tab.Tabboxes)

                    for _, DepGroupbox in Tab.DependencyGroupboxes do
                        if DepGroupbox.Destroy then
                            DepGroupbox:Destroy()
                        end
                    end

                    if TabCanvas then
                        TabCanvas:Destroy()
                    elseif TabContainer then
                        TabContainer:Destroy()
                    end

                    if TabButton then
                        for Index, Entry in Library.TabButtons do
                            if typeof(Entry) == "table" and Entry.Button == TabButton then
                                table.remove(Library.TabButtons, Index)
                                break
                            end
                        end
                        
                        TabButton:Destroy()
                    end
                    
                    Library.Tabs[Name] = nil
                end

                for _, Entry in ipairs(Library.TabButtons) do
                    if Entry.Button == TabButton then
                        Entry.Tab = Tab
                        break
                    end
                end

                if not Library.ActiveTab then
                    Tab:Show()
                end

                TabButton.MouseEnter:Connect(function()
                    Tab:Hover(true)
                end)
                TabButton.MouseLeave:Connect(function()
                    Tab:Hover(false)
                end)
                TabButton.MouseButton1Click:Connect(function()
                    if Library.ActiveTab == Tab and next(Tab.SubTabs) ~= nil then
                        Tab:ToggleExpanded()
                        return
                    end

                    Tab:Show()
                end)

                Library.Tabs[Name] = Tab

                return Tab
            end

            function Window:AddKeyTab(...)
                local Name = nil
                local Icon = nil
                local Description = nil

                if select("#", ...) == 1 and typeof(...) == "table" then
                    local Info = select(1, ...)
                    Name = Info.Name or "Tab"
                    Icon = Info.Icon
                    Description = Info.Description
                else
                    Name = select(1, ...) or "Tab"
                    Icon = select(2, ...)
                    Description = select(3, ...)
                end

                Icon = Icon or "key"

                local TabButton
                local TabLabel
                local TabIcon

                local TabCanvas
                local TabContainer

                Icon = if Icon == "key" then KeyIcon else Library:GetCustomIcon(Icon)
                do
                    TabButton = New("TextButton", {
                        BackgroundColor3 = "MainColor",
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40),
                        Text = "",
                        Parent = Tabs,
                    })
                    local ButtonPadding = New("UIPadding", {
                        PaddingBottom = UDim.new(0, IsCompact and 6 or 11),
                        PaddingLeft = UDim.new(0, IsCompact and 6 or 12),
                        PaddingRight = UDim.new(0, IsCompact and 6 or 12),
                        PaddingTop = UDim.new(0, IsCompact and 6 or 11),
                        Parent = TabButton,
                    })

                    TabLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(30, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Text = Name,
                        TextSize = 16,
                        TextTransparency = 0.5,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Visible = not IsCompact,
                        Parent = TabButton,
                    })

                    if Icon then
                        TabIcon = New("ImageLabel", {
                            Image = Icon.Url,
                            ImageColor3 = Icon.Custom and "WhiteColor" or "AccentColor",
                            ImageRectOffset = Icon.ImageRectOffset,
                            ImageRectSize = Icon.ImageRectSize,
                            ImageTransparency = 0.5,
                            Size = UDim2.fromScale(1, 1),
                            SizeConstraint = IsCompact and Enum.SizeConstraint.RelativeXY or Enum.SizeConstraint.RelativeYY,
                            Parent = TabButton,
                        })
                    end

                    local TabTooltip = Library:AddTooltip(Name, nil, TabButton)
                    TabTooltip.Disabled = not IsCompact

                    table.insert(Library.TabButtons, {
                        Label = TabLabel,
                        Padding = ButtonPadding,
                        Icon = TabIcon,
                        Button = TabButton,
                        Tab = nil,
                        Tooltip = TabTooltip,
                    })

                    TabCanvas = New("CanvasGroup", {
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        GroupTransparency = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        Parent = Container,
                    })

                    TabContainer = New("ScrollingFrame", {
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        CanvasSize = UDim2.fromScale(0, 0),
                        ScrollBarThickness = 0,
                        Position = UDim2.fromScale(0, 0),
                        Size = UDim2.fromScale(1, 1),
                        Visible = true,
                        Parent = TabCanvas,
                    })
                    New("UIListLayout", {
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        Padding = UDim.new(0, 8),
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Parent = TabContainer,
                    })
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 1),
                        PaddingRight = UDim.new(0, 1),
                        Parent = TabContainer,
                    })
                end

                local Tab = {
                    Description = Description,
                    IsKeyTab = true,

                    Elements = {},

                    Window = Window,
                    Canvas = TabCanvas
                }

                function Tab:AddKeyBox(Callback)
                    assert(typeof(Callback) == "function", "Callback must be a function")

                    local Holder = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.75, 0, 0, 21),
                        Parent = TabContainer,
                    })

                    local Box = New("TextBox", {
                        BackgroundColor3 = "MainColor",
                        PlaceholderText = "Key",
                        Size = UDim2.new(1, -71, 1, 0),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = Holder,
                        })
                    New("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        Parent = Box,
                    })
                    New("UIStroke", {
                        Color = "OutlineColor",
                        Parent = Box,
                    })
                    table.insert(
                        Library.Corners,
                        New("UICorner", {
                            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                            Parent = Box,
                        })
                    )

                    local Button = New("TextButton", {
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundColor3 = "MainColor",
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.new(0, 63, 1, 0),
                        Text = "Execute",
                        TextSize = 14,
                        Parent = Holder,
                    })
                    New("UIStroke", {
                        Color = "OutlineColor",
                        Parent = Button,
                    })
                    table.insert(
                        Library.Corners,
                        New("UICorner", {
                            CornerRadius = UDim.new(0, Library.CornerRadius / 2),
                            Parent = Button,
                        })
                    )

                    Button.InputBegan:Connect(function(Input)
                        if not IsClickInput(Input) then
                            return
                        end

                        if not Library:MouseIsOverFrame(Button, Input.Position) then
                            return
                        end

                        Callback(Box.Text)
                    end)
                end
                
                function Tab:Destroy()
                    if TabCanvas then
                        TabCanvas:Destroy()
                    elseif TabContainer then
                        TabContainer:Destroy()
                    end

                    if TabButton then
                        for Index, Entry in Library.TabButtons do
                            if typeof(Entry) == "table" and Entry.Button == TabButton then
                                table.remove(Library.TabButtons, Index)
                                break
                            end
                        end
                        
                        TabButton:Destroy()
                    end

                    if TabHolder then
                        TabHolder:Destroy()
                    end
                    
                    Library.Tabs[Name] = nil
                end

                function Tab:RefreshSides() end
                function Tab:Resize() end
                function Tab:UpdateCorners() end

                function Tab:Hover(Hovering)
                    if Library.ActiveTab == Tab then
                        return
                    end

                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = Hovering and 0.25 or 0.5,
                    }):Play()
                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = Hovering and 0.25 or 0.5,
                        }):Play()
                    end
                end

                function Tab:Show()
                    if Library.ActiveTab == Tab then
                        return
                    end

                    if Library.ActiveTab then
                        Library.ActiveTab:Hide()
                    end

                    TweenService:Create(TabButton, Library.TweenInfo, {
                        BackgroundTransparency = 0,
                    }):Play()

                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = 0,
                    }):Play()

                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = 0,
                        }):Play()
                    end

                    Library:PlayTabAnimation(TabCanvas, true)

                    if Description then
                        Window:ShowTabInfo(Name, Description)
                    end

                    Tab:RefreshSides()

                    Library.ActiveTab = Tab

                    if Library.Searching then
                        Library:UpdateSearch(Library.SearchText)
                    end

                    UpdateMarker()
                end

                function Tab:Hide()
                    TweenService:Create(TabButton, Library.TweenInfo, {
                        BackgroundTransparency = 1,
                    }):Play()

                    TweenService:Create(TabLabel, Library.TweenInfo, {
                        TextTransparency = 0.5,
                    }):Play()

                    if TabIcon then
                        TweenService:Create(TabIcon, Library.TweenInfo, {
                            ImageTransparency = 0.5,
                        }):Play()
                    end

                    Library:PlayTabAnimation(TabCanvas, false)
                    Window:HideTabInfo()

                    Library.ActiveTab = nil
                end

                function Tab:SetVisible(Visible: boolean)
                    TabButton.Visible = Visible

                    if not Visible and Library.ActiveTab == Tab then
                        Tab:Hide()
                    end
                end

                for _, Entry in ipairs(Library.TabButtons) do
                    if Entry.Button == TabButton then
                        Entry.Tab = Tab
                        break
                    end
                end

                if not Library.ActiveTab then
                    Tab:Show()
                end

                TabButton.MouseEnter:Connect(function()
                    Tab:Hover(true)
                end)
                TabButton.MouseLeave:Connect(function()
                    Tab:Hover(false)
                end)
                TabButton.MouseButton1Click:Connect(function()
                    Tab:Show()
                end)

                Tab.Container = TabContainer
                setmetatable(Tab, BaseGroupbox)

                Library.Tabs[Name] = Tab

                return Tab
            end

            function Window:AddDialog(Idx, Info)
                Info = Library:Validate(Info, Templates.Dialog)

                local DialogFrame
                local DialogOverlay
                local DialogContainer
                local ButtonsHolder
                local FooterButtonsList = {}

                DialogOverlay = New("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = "DarkColor",
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Text = "",
                    Active = false,
                    ZIndex = 9000,
                    Visible = true,
                    Parent = MainFrame,
                })
                TweenService:Create(DialogOverlay, Library.TweenInfo, {
                    BackgroundTransparency = 0.5,
                }):Play()

                DialogFrame = New("TextButton", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = "BackgroundColor",
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(300, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9001,
                    Parent = DialogOverlay,
                })
                table.insert(
                    Library.Corners,
                    New("UICorner", {
                        CornerRadius = UDim.new(0, WindowInfo.CornerRadius),
                        Parent = DialogFrame,
                    })
                )
                Library:AddOutline(DialogFrame)

                local InnerContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 9002,
                    Parent = DialogFrame,
                })
                local DialogScale = New("UIScale", {
                    Scale = 0.95,
                    Parent = DialogFrame,
                })
                TweenService:Create(DialogScale, Library.TweenInfo, {
                    Scale = 1
                }):Play()
                local _InnerPadding = New("UIPadding", {
                    PaddingBottom = UDim.new(0, 15),
                    PaddingLeft = UDim.new(0, 15),
                    PaddingRight = UDim.new(0, 15),
                    PaddingTop = UDim.new(0, 15),
                    Parent = InnerContainer,
                })
                local _InnerLayout = New("UIListLayout", {
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = InnerContainer,
                })

                local HeaderContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 1,
                    ZIndex = 9002,
                    Parent = InnerContainer,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = HeaderContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 5),
                    Parent = HeaderContainer,
                })

                local TitleRow = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 1,
                    ZIndex = 9002,
                    Parent = HeaderContainer,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    FillDirection = Enum.FillDirection.Horizontal,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = TitleRow,
                })

                if Info.Icon then
                    local ParsedIcon = Library:GetCustomIcon(Info.Icon)
                    if ParsedIcon then
                        local IconImg = New("ImageLabel", {
                            BackgroundTransparency = 1,
                            Size = UDim2.fromOffset(16, 16),
                            Image = ParsedIcon.Url,
                            ImageColor3 = "FontColor",
                            ImageRectOffset = ParsedIcon.ImageRectOffset,
                            ImageRectSize = ParsedIcon.ImageRectSize,
                            LayoutOrder = 1,
                            ZIndex = 9002,
                            Parent = TitleRow,
                        })
                        if Info.TitleColor then
                            IconImg.ImageColor3 = Info.TitleColor
                        end
                    end
                end

                local TitleLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = Info.Title,
                    TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = 2,
                    ZIndex = 9002,
                    Parent = TitleRow,
                })
                if Info.TitleColor then
                    TitleLabel.TextColor3 = Info.TitleColor
                end

                local DescriptionLabel = New("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Text = Info.Description,
                    TextSize = 14,
                    TextTransparency = Info.DescriptionColor and 0 or 0.2,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = true,
                    LayoutOrder = 2,
                    ZIndex = 9002,
                    Parent = HeaderContainer,
                })
                if Info.DescriptionColor then
                    DescriptionLabel.TextColor3 = Info.DescriptionColor
                end

                DialogContainer = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 4,
                    ZIndex = 9002,
                    Parent = InnerContainer,
                })
                local _DialogContainerLayout = New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DialogContainer,
                })
                New("UIPadding", {
                    PaddingBottom = UDim.new(0, 5),
                    Parent = DialogContainer,
                })
                
                local _Sep2 = New("Frame", {
                    BackgroundColor3 = "OutlineColor",
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 1),
                    LayoutOrder = 5,
                    ZIndex = 9002,
                    Parent = InnerContainer,
                })

                ButtonsHolder = New("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    LayoutOrder = 6,
                    ZIndex = 9002,
                    Parent = InnerContainer,
                })
                New("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    Wraps = true,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = ButtonsHolder,
                })
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 5),
                    Parent = ButtonsHolder,
                })

                local Dialog = {
                    Destroyed = false,
                    Elements = {},
                    Container = DialogContainer,
                }

                function Dialog:Resize()
                    local MaxWidth = MainFrame.AbsoluteSize.X * 0.75
                    local MinWidth = 400

                    local TotalButtonWidth = 0
                    local ButtonCount = 0
                    local HasButtons = false

                    for _, BtnWrap in FooterButtonsList do
                        HasButtons = true
                        ButtonCount = ButtonCount + 1
                        TotalButtonWidth = TotalButtonWidth + BtnWrap.Container.Size.X.Offset
                    end

                    local TargetWidth = MinWidth
                    if HasButtons then
                        local RequiredWidth = TotalButtonWidth + ((ButtonCount - 1) * 8) + 30
                        TargetWidth = math.max(MinWidth, math.min(RequiredWidth, MaxWidth))
                    end

                    DialogFrame.Size = UDim2.fromOffset(TargetWidth, 0)

                    local _DescX, DescY = Library:GetTextBounds(DescriptionLabel.Text, Library.Scheme.Font, 14, TargetWidth - 30)
                    DescriptionLabel.Size = UDim2.new(1, 0, 0, DescY)

                    local HasElements = false
                    for _, v in DialogContainer:GetChildren() do
                        if not v:IsA("UIListLayout") and not v:IsA("UIPadding") then
                            HasElements = true
                            break
                        end
                    end
                    DialogContainer.Visible = HasElements

                    ButtonsHolder.Visible = HasButtons
                    _Sep2.Visible = HasButtons
                end

                function Dialog:SetTitle(Title)
                    TitleLabel.Text = Title
                    Dialog:Resize()
                end

                function Dialog:SetDescription(Description)
                    DescriptionLabel.Text = Description
                    Dialog:Resize()
                end

                function Dialog:Dismiss()
                    if Dialog.Destroyed then
                        return
                    end

                    Dialog.Destroyed = true

                    if Library.ActiveDialog == Dialog then
                        Library.ActiveDialog = nil
                    end

                    for Index = #Dialog.Elements, 1, -1 do
                        local Element = Dialog.Elements[Index]
                        if Element and Element.Destroy then
                            Element:Destroy()
                        end
                    end
                    table.clear(Dialog.Elements)

                    local CloseTween = TweenService:Create(DialogScale, Library.TweenInfo, { Scale = 0.95 })
                    TweenService:Create(DialogOverlay, Library.TweenInfo, { BackgroundTransparency = 1 }):Play()
                    CloseTween:Play()
                    
                    task.delay(Library.TweenInfo.Time, function()
                        DialogOverlay:Destroy()
                    end)
                    Library.Dialogues[Idx] = nil
                end

                DialogOverlay.MouseButton1Click:Connect(function()
                    if Info.OutsideClickDismiss then
                        Dialog:Dismiss()
                    end
                end)

                function Dialog:RemoveFooterButton(ButtonIdx)
                    if FooterButtonsList[ButtonIdx] then
                        FooterButtonsList[ButtonIdx].Container:Destroy()
                        FooterButtonsList[ButtonIdx] = nil
                    end
                end

                function Dialog:SetButtonDisabled(ButtonIdx, Disabled)
                    if FooterButtonsList[ButtonIdx] and type(FooterButtonsList[ButtonIdx].SetDisabled) == "function" then
                        FooterButtonsList[ButtonIdx]:SetDisabled(Disabled)
                    end
                end

                function Dialog:SetButtonOrder(ButtonIdx, Order)
                    if FooterButtonsList[ButtonIdx] and FooterButtonsList[ButtonIdx].Container then
                        FooterButtonsList[ButtonIdx].Container.LayoutOrder = Order
                    end
                end

                function Dialog:AddFooterButton(ButtonIdx, ButtonInfo)
                    Dialog:RemoveFooterButton(ButtonIdx)

                    local WaitTime = ButtonInfo.WaitTime or 0

                    local ButtonContainer = New("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromOffset(0, 26),
                        LayoutOrder = ButtonInfo.Order or 0,
                        ZIndex = 9002,
                        Parent = ButtonsHolder,
                    })
                    
                    local BtnColor = "MainColor"
                    local BtnOutline = "OutlineColor"
                    local Variant = ButtonInfo.Variant or "Primary"
                    
                    if Variant == "Primary" then
                        BtnColor = "FontColor"
                        BtnOutline = "FontColor"
                    elseif Variant == "Secondary" then
                        BtnColor = "MainColor"
                        BtnOutline = "OutlineColor"
                    elseif Variant == "Destructive" then
                        BtnColor = "DestructiveColor"
                        BtnOutline = "DestructiveColor"
                    elseif Variant == "Ghost" then
                        BtnColor = "BackgroundColor"
                        BtnOutline = "BackgroundColor"
                    end

                    local TextBtn = New("TextButton", {
                        BackgroundColor3 = BtnColor,
                        BorderColor3 = BtnOutline,
                        BackgroundTransparency = WaitTime > 0 and 0.5 or 0,
                        Size = UDim2.fromOffset(0, 26),
                        Text = "",
                        AutoButtonColor = false,
                        ZIndex = 9002,
                        Parent = ButtonContainer,
                    })
                    Library:AddOutline(TextBtn)
                    table.insert(
                        Library.Corners,
                        New("UICorner", { 
                            CornerRadius = UDim.new(0, Library.CornerRadius), 
                            Parent = TextBtn 
                        })
                    )

                    local _BtnPadding = New("UIPadding", {
                        PaddingLeft = UDim.new(0, 15),
                        PaddingRight = UDim.new(0, 15),
                        Parent = TextBtn,
                    })

                    local TextColor = Library.Scheme.FontColor
                    if Variant == "Primary" then
                        TextColor = Library.Scheme.BackgroundColor
                    elseif Variant == "Destructive" then
                        TextColor = Color3.new(1, 1, 1)
                    end
                    
                    local BtnLabel = New("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        Text = ButtonInfo.Title or ButtonIdx,
                        TextColor3 = TextColor,
                        TextTransparency = WaitTime > 0 and 0.5 or 0,
                        TextSize = 14,
                        ZIndex = 9002,
                        Parent = TextBtn,
                    })
                    
                    local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
                    ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
                    TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

                    local ProgressBar
                    if WaitTime > 0 then
                        ProgressBar = New("Frame", {
                            BackgroundColor3 = "AccentColor",
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 1, -2),
                            Size = UDim2.new(0, 0, 0, 2),
                            ZIndex = 2,
                            Parent = TextBtn,
                        })
                        table.insert(
                            Library.Corners,
                            New("UICorner", { 
                                CornerRadius = UDim.new(0, Library.CornerRadius), 
                                Parent = ProgressBar 
                            })
                        )
                    end

                    local IsActive = WaitTime <= 0

                    local ButtonWrap = {
                        Container = ButtonContainer,
                        SetDisabled = function(self, Disabled)
                            IsActive = not Disabled
                            if Disabled then
                                TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0.5 }):Play()
                                TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0.5 }):Play()
                            else
                                TweenService:Create(TextBtn, Library.TweenInfo, { BackgroundTransparency = 0 }):Play()
                                TweenService:Create(BtnLabel, Library.TweenInfo, { TextTransparency = 0 }):Play()
                            end
                        end
                    }

                    local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
                    local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

                    TextBtn.MouseEnter:Connect(function()
                        if not IsActive then return end
                        TweenService:Create(TextBtn, Library.TweenInfo, {
                            BackgroundColor3 = HoverColor
                        }):Play()
                    end)
                    TextBtn.MouseLeave:Connect(function()
                        if not IsActive then return end
                        TweenService:Create(TextBtn, Library.TweenInfo, {
                            BackgroundColor3 = ActiveColor
                        }):Play()
                    end)

                    TextBtn.MouseButton1Click:Connect(function()
                        if not IsActive then return end
                        if ButtonInfo.Callback then
                            ButtonInfo.Callback(Dialog)
                        end
                        if Info.AutoDismiss then
                            Dialog:Dismiss()
                        end
                    end)

                    if WaitTime > 0 then
                        TweenService:Create(ProgressBar, TweenInfo.new(WaitTime, Enum.EasingStyle.Linear), {
                            Size = UDim2.new(1, 0, 0, 2)
                        }):Play()
                        
                        task.delay(WaitTime, function()
                            ButtonWrap:SetDisabled(false)
                            if ProgressBar then
                                TweenService:Create(ProgressBar, Library.TweenInfo, {
                                    BackgroundTransparency = 1
                                }):Play()
                            end
                        end)
                    end

                    FooterButtonsList[ButtonIdx] = ButtonWrap
                end

                for BIdx, BInfo in Info.FooterButtons do
                    if type(BIdx) == "number" and BInfo.Id then BIdx = BInfo.Id end
                    Dialog:AddFooterButton(BIdx, BInfo)
                end

                setmetatable(Dialog, BaseGroupbox)
                Library.Dialogues[Idx] = Dialog

                Dialog:Resize()
                
                Library.ActiveDialog = Dialog
                return Dialog
            end

            local GuiProperties = { "BackgroundTransparency" }
            local ImageProperties = { "BackgroundTransparency", "ImageTransparency" }
            local TextProperties = { "BackgroundTransparency", "TextTransparency" }
            local StrokeProperties = { "Transparency" }

            local function FadeInstance(Desc, Properties)
                local Cache = TransparencyCache[Desc]
                if not Cache then
                    Cache = {}
                    TransparencyCache[Desc] = Cache
                end

                for _, Prop in Properties do
                    if not Library.Toggled then
                        Cache[Prop] = Desc[Prop]
                    end

                    if Cache[Prop] ~= nil and Cache[Prop] ~= 1 then
                        TweenService:Create(Desc, Library.WindowAnimationInfo, {
                            [Prop] = Library.Toggled and Cache[Prop] or 1,
                        }):Play()
                    end
                end
            end

            function ApplyWindowVisibility()
                MainFrame.Visible = Library.Toggled and not Minimized

                if MiniFrame then
                    MiniFrame.Visible = Library.Toggled and Minimized
                end
            end

            function Window:Toggle(Value: boolean?)
                if Fading then
                    return
                end

                if Library.ActiveLoading then
                    if Value == true then
                        return
                    end

                    if not Library.Toggled then
                        return
                    end
                end

                if typeof(Value) == "boolean" then
                    Library.Toggled = Value
                else
                    Library.Toggled = not Library.Toggled
                end

                if Library.Animations and Library.Animations.ToggleWindow == true then
                    local FadeTime = Library.WindowAnimationInfo.Time
                    Fading = true

                    if Library.Toggled then
                        MainFrame.Visible = true
                    end

                    if Library.Toggled then 
                        FadeInstance(MainFrame, { "BackgroundTransparency" })
                        task.wait(FadeTime / 2)
                    else
                        task.delay(FadeTime / 2, FadeInstance, MainFrame, { "BackgroundTransparency" })
                    end

                    for _, Instance in MainFrame:GetDescendants() do
                        if Instance == TopBar then
                            continue
                        end

                        if Instance:IsA("GuiObject") then
                            local ClassName = Instance.ClassName
                            if ClassName == "ImageLabel" or ClassName == "ImageButton" then
                                FadeInstance(Instance, ImageProperties)
                            elseif ClassName == "TextLabel" or ClassName == "TextBox" or ClassName == "TextButton" then
                                FadeInstance(Instance, TextProperties)
                            else
                                FadeInstance(Instance, GuiProperties)
                            end
                        elseif Instance.ClassName == "UIStroke" then
                            FadeInstance(Instance, StrokeProperties)
                        end
                    end

                    task.delay(FadeTime, function()
                        MainFrame.Visible = Library.Toggled
                        Fading = false
                    end)
                else
                    MainFrame.Visible = Library.Toggled
                end

                if WindowInfo.UnlockMouseWhileOpen then
                    ModalElement.Modal = Library.Toggled
                end

                if Library.Toggled and not Library.IsMobile then
                    local OldMouseIconEnabled = UserInputService.MouseIconEnabled
                    local ShowCursorBinding = Library.ShowCursorBinding
                    pcall(function()
                        RunService:UnbindFromRenderStep(ShowCursorBinding)
                    end)
                    RunService:BindToRenderStep(ShowCursorBinding, Enum.RenderPriority.Last.Value, function()
                        UserInputService.MouseIconEnabled = not Library.ShowCustomCursor

                        Cursor.Position = UDim2.fromOffset(Mouse.X, Mouse.Y)
                        Cursor.Visible = Library.ShowCustomCursor

                        if not (Library.Toggled and ScreenGui and ScreenGui.Parent) then
                            UserInputService.MouseIconEnabled = OldMouseIconEnabled
                            Cursor.Visible = false
                            RunService:UnbindFromRenderStep(ShowCursorBinding)
                        end
                    end)
                elseif not Library.Toggled then
                    TooltipLabel.Visible = false

                    for _, Option in Library.Options do
                        if Option.Type == "ColorPicker" then
                            Option.ColorMenu:Close()
                            Option.ContextMenu:Close()
                        elseif Option.Type == "Dropdown" or Option.Type == "KeyPicker" then
                            Option.Menu:Close()
                        end
                    end
                end
            end

            function Library:Toggle(Value: boolean?)
                return Window:Toggle(Value)
            end

            if WindowInfo.Minimizable and WindowInfo.MinimizeKeybind then
                Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject, Processed: boolean)
                    if Processed or Library.Unloaded or not Library.Toggled then
                        return
                    end
                    if Input.UserInputType ~= Enum.UserInputType.Keyboard then
                        return
                    end
                    if Input.KeyCode ~= WindowInfo.MinimizeKeybind then
                        return
                    end
                    if UserInputService:GetFocusedTextBox() then
                        return
                    end

                    Window:ToggleMinimized()
                end))
            end

            if WindowInfo.EnableSidebarResize then
                local Threshold = (WindowInfo.MinSidebarWidth + WindowInfo.SidebarCompactWidth) * WindowInfo.SidebarCollapseThreshold
                local StartPos, StartWidth
                local Dragging = false
                local Changed

                local SidebarGrabber = New("TextButton", {
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2.fromScale(0.5, 0),
                    Size = UDim2.new(0, 8, 1, 0),
                    Text = "",
                    Parent = DividerLine,
                })
                SidebarGrabber.MouseEnter:Connect(function()
                    TweenService:Create(DividerLine, Library.TweenInfo, {
                        BackgroundColor3 = Library:GetLighterColor(Library.Scheme.OutlineColor),
                    }):Play()
                end)
                SidebarGrabber.MouseLeave:Connect(function()
                    if Dragging then
                        return
                    end
                    TweenService:Create(DividerLine, Library.TweenInfo, {
                        BackgroundColor3 = Library.Scheme.OutlineColor,
                    }):Play()
                end)

                SidebarGrabber.InputBegan:Connect(function(Input: InputObject)
                    if not IsClickInput(Input) then
                        return
                    end

                    Library.CantDragForced = true

                    StartPos = Input.Position
                    StartWidth = Window:GetSidebarWidth()
                    Dragging = true

                    Changed = Input.Changed:Connect(function()
                        if Input.UserInputState ~= Enum.UserInputState.End then
                            return
                        end

                        Library.CantDragForced = false
                        TweenService:Create(DividerLine, Library.TweenInfo, {
                            BackgroundColor3 = Library.Scheme.OutlineColor,
                        }):Play()

                        Dragging = false
                        if Changed and Changed.Connected then
                            Changed:Disconnect()
                            Changed = nil
                        end
                    end)
                end)

                Library:GiveSignal(UserInputService.InputChanged:Connect(function(Input: InputObject)
                    if not Library.Toggled or not (ScreenGui and ScreenGui.Parent) then
                        Dragging = false
                        if Changed and Changed.Connected then
                            Changed:Disconnect()
                            Changed = nil
                        end

                        return
                    end

                    if Dragging and IsHoverInput(Input) then
                        local Delta = Input.Position - StartPos
                        local Width = StartWidth + Delta.X

                        if WindowInfo.DisableCompactingSnap then
                            Window:SetSidebarWidth(Width)
                            return
                        end

                        if Width > Threshold then
                            Window:SetSidebarWidth(math.max(Width, WindowInfo.MinSidebarWidth))
                        else
                            Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
                        end
                    end
                end))
            end
            if WindowInfo.EnableCompacting and WindowInfo.SidebarCompacted then
                Window:SetSidebarWidth(WindowInfo.SidebarCompactWidth)
            else
                ApplyCompact()
            end
            if WindowInfo.AutoShow and not Library.ActiveLoading then
                task.spawn(Library.Toggle)
            end

            if Library.IsMobile then
                local ToggleButton = Library:AddDraggableButton("Toggle", function()
                    Library:Toggle()
                end, true, true)

                local LockButton = Library:AddDraggableButton("Lock", function(self)
                    Library.CantDragForced = not Library.CantDragForced
                    self:SetText(Library.CantDragForced and "Unlock" or "Lock")
                end, true, true)

                if WindowInfo.MobileButtonsSide == "Right" then
                    ToggleButton.Button.AnchorPoint = Vector2.new(1, 0)
                    ToggleButton.Button.Position = UDim2.new(1, -6, 0, 6)

                    LockButton.Button.AnchorPoint = Vector2.new(1, 0)
                    LockButton.Button.Position = UDim2.new(1, -(ToggleButton.Button.Size.X.Offset + 12), 0, 6)
                else
                    ToggleButton.Button.AnchorPoint = Vector2.new(0, 0)
                    ToggleButton.Button.Position = UDim2.fromOffset(6, 6)

                    LockButton.Button.AnchorPoint = Vector2.new(0, 0)
                    LockButton.Button.Position = UDim2.fromOffset(ToggleButton.Button.Size.X.Offset + 12, 6)
                end

                if WindowInfo.ShowMobileButtons == false then
                    ToggleButton.Button.Visible = false
                    LockButton.Button.Visible = false
                end
            end

            --// Execution \\--
            Library:GiveSignal(SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                Library:UpdateSearch(SearchBox.Text)
            end))

            Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input: InputObject)
                if Library.Unloaded then
                    return
                end

                if UserInputService:GetFocusedTextBox() then
                    return
                end

                if Input.KeyCode == Library.ToggleKeybind then
                    Library:Toggle()
                end

                if Library.NotificationHistoryKeybind and Input.KeyCode == Library.NotificationHistoryKeybind then
                    Library:ToggleNotificationHistory()
                end
            end))

            Library:GiveSignal(UserInputService.WindowFocused:Connect(function()
                Library.IsRobloxFocused = true
            end))
            Library:GiveSignal(UserInputService.WindowFocusReleased:Connect(function()
                Library.IsRobloxFocused = false
            end))

            Library.Window = Window
            return Window
        end

function Library:CreateLoading(LoadingInfo)
    if Library.ActiveLoading then
        warn("Loading GUI already exists, you cannot create multiple Loading GUIs.")
        return Library.ActiveLoading
    end

    LoadingInfo = Library:Validate(LoadingInfo, Templates.Loading)

    local Loading = {
        CurrentStep = LoadingInfo.CurrentStep,
        TotalSteps = LoadingInfo.TotalSteps,

        ShowSidebar = LoadingInfo.ShowSidebar,
        AutoResizeHeight = LoadingInfo.AutoResizeHeight,
        IsError = false,
        Destroyed = false,

        WindowWidth = LoadingInfo.WindowWidth,
        WindowHeight = LoadingInfo.WindowHeight,
        BaseWindowHeight = LoadingInfo.WindowHeight,
        WindowErrorHeight = LoadingInfo.WindowHeight,

        ContentWidth = LoadingInfo.ContentWidth,
        SidebarWidth = LoadingInfo.SidebarWidth,
    }

    --// ScreenGui \\--
    local ScreenGui = New("ScreenGui", {
        Name = "ObsidianLoading",
        DisplayOrder = 999,
        ResetOnSpawn = false
    })
    ParentUI(ScreenGui)
    Loading.ScreenGui = ScreenGui
    SetAlwaysOnTop(ScreenGui, LoadingInfo.AlwaysOnTop)

    ScreenGui.DescendantRemoving:Connect(function(Instance)
        Library:RemoveFromRegistry(Instance)
    end)

    --// Main Frame \\--
    local MainFrame = New("TextButton", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = function()
            return Library:GetBetterColor(Library.Scheme.BackgroundColor, -1)
        end,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(Loading.ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth, Loading.WindowHeight),
        ClipsDescendants = true,
        Text = "",
        AutoButtonColor = false,
        Parent = ScreenGui,
    })
    Library:AddOutline(MainFrame)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = MainFrame }))
    
	local MainScale = New("UIScale", {
		Scale = Library.IsMobile and 0.8 or 1,
		Parent = MainFrame
	})
	table.insert(Library.Scales, MainScale)
	Library.ScalesOffset[MainScale] = Library.IsMobile and 0.2 or 0

    --// Layout Containers \\--
    local Container = New("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, Loading.ContentWidth, 1, 0),
        Parent = MainFrame,
    })

    local SideBar = New("Frame", {
        Name = "SideBar",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(Loading.ContentWidth, 0),
        Size = UDim2.new(0, Loading.ShowSidebar and Loading.SidebarWidth or 0, 1, 0),
        ClipsDescendants = true,
        Visible = Loading.ShowSidebar,
        Parent = MainFrame,
    })
    local SidebarCorner = New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius), Parent = SideBar })
    table.insert(Library.Corners, SidebarCorner)
    
    Library:AddOutline(SideBar)
    
    local SidebarDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        Visible = Loading.ShowSidebar,
        Parent = SideBar,
    })

    --// Top Bar \\--
    local TopBar = New("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        ZIndex = 2,
        Parent = Container,
    })
    Library:MakeDraggable(MainFrame, TopBar, true, true)

    local TitleHolder = New("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = TopBar,
    })
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = TitleHolder,
    })
    New("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        Parent = TitleHolder,
    })

    if LoadingInfo.Icon then
        local Icon = Library:GetCustomIcon(LoadingInfo.Icon)
        local _WindowIcon = New("ImageLabel", {
            Image = Icon.Url,
            ImageRectOffset = Icon.ImageRectOffset,
            ImageRectSize = Icon.ImageRectSize,
            Size = LoadingInfo.IconSize,
            Parent = TitleHolder,
        })
    else
        local _WindowIcon = New("TextLabel", {
            BackgroundTransparency = 1,
            Size = LoadingInfo.IconSize,
            Text = LoadingInfo.Title:sub(1, 1),
            TextScaled = true,
            Visible = false,
            Parent = TitleHolder,
        })
    end

    local TitleX = Library:GetTextBounds(
        LoadingInfo.Title,
        Library.Scheme.Font,
        20,
        TitleHolder.AbsoluteSize.X - (LoadingInfo.Icon and (LoadingInfo.IconSize.X.Offset + 6) or 0) - 12
    )
    local _WindowTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, TitleX, 1, 0),
        Text = LoadingInfo.Title,
        TextSize = 20,
        Parent = TitleHolder,
    })

    Library:MakeLine(Container, {
        Position = UDim2.fromOffset(0, 48),
        Size = UDim2.new(1, 0, 0, 1),
    })

    --// Loading Content Elements \\--
    local InnerContent = New("Frame", {
        Name = "InnerContent",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        Parent = Container,
    })

    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = InnerContent,
    })

    local IconHolder = New("Frame", {
        Name = "IconHolder",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(64, 64),
        Parent = InnerContent,
    })

    local LoaderIcon = Library:GetCustomIcon(LoadingInfo.LoadingIcon)
    local LoadingIcon = New("ImageLabel", {
        Name = "LoaderIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(1, 1),
        Image = LoaderIcon.Url,
        ImageRectOffset = LoaderIcon.ImageRectOffset,
        ImageRectSize = LoaderIcon.ImageRectSize,
        ImageColor3 = LoadingInfo.LoadingIconColor or ((LoadingInfo.LoadingIcon == Templates.Loading.LoadingIcon) and "AccentColor" or "WhiteColor"),
        Parent = IconHolder,
    })

    local RotationTween
    if LoadingInfo.LoadingIconTweenTime > 0 then
        RotationTween = TweenService:Create(
            LoadingIcon,
            TweenInfo.new(LoadingInfo.LoadingIconTweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
            { Rotation = 360 }
        )
        RotationTween:Play()
    end

    local MessageLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 18,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    local DescriptionLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        AutomaticSize = Loading.AutoResizeHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
        Size = Loading.AutoResizeHeight and UDim2.new(1, -60, 0, 0) or UDim2.fromOffset(0, 0),
        Text = "",
        TextSize = 14,
        TextTransparency = 0.5,
        TextWrapped = Loading.AutoResizeHeight,
        Parent = InnerContent,
    })

    --// Progress Bar \\--
    local SliderBar = New("Frame", {
        BackgroundColor3 = "MainColor",
        Size = UDim2.new(0.7, 0, 0, 15),
        Parent = InnerContent,
    })
    Library:AddOutline(SliderBar)
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderBar }))

    local SliderFill = New("Frame", {
        BackgroundColor3 = "AccentColor",
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = SliderBar,
    })
    table.insert(Library.Corners, New("UICorner", { CornerRadius = UDim.new(0, Library.CornerRadius / 2), Parent = SliderFill }))

    local ProgressLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        TextSize = 14,
        ZIndex = 2,
        Parent = SliderBar,
    })
    New("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
        Color = "DarkColor",
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = ProgressLabel,
    })

    --// Sidebar Object \\--
    local SidebarScrolling = New("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = "OutlineColor",
        Parent = SideBar,
    })
    local SidebarList = New("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarScrolling,
    })
    New("UIPadding", {
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 12),
        Parent = SidebarScrolling,
    })

    local SidebarObject = {
        Elements = {},
        DependencyBoxes = {},
        Tabboxes = {},
        
        BoxHolder = SidebarScrolling,
        Container = SidebarScrolling,
        
        Resize = function(self)
            SidebarScrolling.CanvasSize = UDim2.fromOffset(0, SidebarList.AbsoluteContentSize.Y + 24)
        end,
        Tab = {
            Elements = {},
            DependencyBoxes = {},
            DependencyGroupboxes = {},
            Tabboxes = {},
        },
    }

    SidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SidebarObject:Resize()
    end)

    setmetatable(SidebarObject, BaseGroupbox)
    Loading.Sidebar = SidebarObject

    --// Error Frame \\--
    local ErrorFrame = New("Frame", {
        Name = "Error",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 49),
        Size = UDim2.new(1, 0, 1, -49),
        ClipsDescendants = true,
        Visible = false,
        Parent = Container,
    })

    local _ErrorTitle = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 15),
        Size = UDim2.new(1, -30, 0, 18),
        Text = "Error",
        TextColor3 = "RedColor",
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ErrorFrame,
    })

    local ErrorLabel = New("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(15, 39),
        Size = UDim2.new(1, -30, 1, -90),
        Text = "Error Message",
        TextSize = 14,
        TextTransparency = 0.2,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = ErrorFrame,
    })

    local ErrorButtonsDivider = New("Frame", {
        BackgroundColor3 = "OutlineColor",
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 1, -48),
        Size = UDim2.new(1, -30, 0, 1),
        Visible = false,
        Parent = ErrorFrame,
    })

    local ErrorButtonsHolder = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 42),
        Visible = false,
        Parent = ErrorFrame,
    })
    New("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = ErrorButtonsHolder,
    })
    New("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15),
        Parent = ErrorButtonsHolder,
    })

    function Loading:UpdateLayout()
        if Loading.IsError then
            Loading:RecalculateErrorHeight()
        end

        local ShowSidebar = Loading.ShowSidebar
        local FinalWidth = ShowSidebar and (Loading.ContentWidth + Loading.SidebarWidth) or Loading.WindowWidth
        local FinalHeight = Loading.IsError and Loading.WindowErrorHeight or Loading.WindowHeight
        
        if ShowSidebar then
            SideBar.Visible = true
            SidebarDivider.Visible = true
        end

        TweenService:Create(MainFrame, Library.TweenInfo, { Size = UDim2.fromOffset(FinalWidth, FinalHeight) }):Play()
        TweenService:Create(SideBar, Library.TweenInfo, { Position = UDim2.fromOffset(Loading.ContentWidth, 0), Size = UDim2.new(0, ShowSidebar and Loading.SidebarWidth or 0, 1, 0) }):Play()
        TweenService:Create(Container, Library.TweenInfo, { Size = UDim2.new(0, ShowSidebar and Loading.ContentWidth or Loading.WindowWidth, 1, 0) }):Play()

        if not ShowSidebar then
            task.delay(Library.TweenInfo.Time, function()
                if not Loading.ShowSidebar then
                    SideBar.Visible = false
                    SidebarDivider.Visible = false
                end
            end)
        end
    end

    --// Content Page \\--
    function Loading:RecalculateLoadingHeight()
        if not Loading.AutoResizeHeight then
            return
        end

        local RequiredHeight = 
              49 -- TopBar
            + 48 -- Padding
            + InnerContent.UIListLayout.AbsoluteContentSize.Y

        Loading.WindowHeight = math.max(Loading.BaseWindowHeight, RequiredHeight)
    end

    function Loading:SetMessage(Text)
        MessageLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetDescription(Text)
        DescriptionLabel.Text = Text

        if Loading.AutoResizeHeight then
            Loading:RecalculateLoadingHeight()
            Loading:UpdateLayout()
        end
    end

    function Loading:SetLoadingIcon(Icon)
        local IconData = Library:GetCustomIcon(Icon)
        assert(IconData, "Image must be a valid Roblox asset or a valid URL or a valid lucide icon.")

        LoadingIcon.Image = IconData.Url
        LoadingIcon.ImageRectOffset = IconData.ImageRectOffset
        LoadingIcon.ImageRectSize = IconData.ImageRectSize
    end

    function Loading:SetLoadingIconTweenTime(TweenTime)
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        if TweenTime > 0 then
            RotationTween = TweenService:Create(
                LoadingIcon,
                TweenInfo.new(TweenTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
                { Rotation = 360 }
            )
            RotationTween:Play()
        else
            LoadingIcon.Rotation = 0
        end
    end

    function Loading:SetLoadingIconColor(Color)
        LoadingIcon.ImageColor3 = Color
    end

    function Loading:SetCurrentStep(Step)
        Loading.CurrentStep = math.clamp(Step, 0, Loading.TotalSteps)

        local Progress = Loading.CurrentStep / Loading.TotalSteps
        TweenService:Create(SliderFill, Library.TweenInfo, { Size = UDim2.fromScale(Progress, 1) }):Play()

        ProgressLabel.Text = string.format("%d/%d", Loading.CurrentStep, Loading.TotalSteps)
    end

    function Loading:SetTotalSteps(Steps)
        Loading.TotalSteps = Steps
        Loading:SetCurrentStep(Loading.CurrentStep)
    end

    --// Size \\--
    function Loading:SetWindowHeight(Height)
        Loading.WindowHeight = Height
        Loading:UpdateLayout()
    end

    function Loading:SetWindowWidth(Width)
        Loading.WindowWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetContentWidth(Width)
        Loading.ContentWidth = Width
        Loading:UpdateLayout()
    end

    function Loading:SetSidebarWidth(Width)
        Loading.SidebarWidth = Width
        Loading:UpdateLayout()
    end

    --// Sidebar \\--
    function Loading:ShowSidebarPage(Bool)
        Loading.ShowSidebar = Bool
        Loading:UpdateLayout()
    end

    --// Error Page \\--
    function Loading:ShowErrorPage(Enabled)
        Loading.IsError = Enabled
        InnerContent.Visible = not Enabled
        ErrorFrame.Visible = Enabled

        if Loading.ShowSidebar then
            Loading:ShowSidebarPage(not Enabled)
        else
            Loading:UpdateLayout()
        end
    end

    function Loading:RecalculateErrorHeight()
        local TargetWidth = (Loading.ShowSidebar and Loading.ContentWidth or Loading.WindowWidth) - 30
        local _, ErrorY = Library:GetTextBounds(ErrorLabel.Text, Library.Scheme.Font, 14, TargetWidth)

        ErrorLabel.Size = UDim2.new(1, -30, 0, ErrorY)

        local HasButtons = ErrorButtonsHolder.Visible
        local RequiredHeight =
              49                        -- TopBar
            + 15                        -- Padding Top
            + 18                        -- Title Height
            + 6                         -- Padding between Title and Label
            + ErrorY                    -- Label Height
            + 15                        -- Padding between Label and Buttons
            + (HasButtons and 48 or 0)  -- Buttons Area

        Loading.WindowErrorHeight = RequiredHeight -- math.max(Loading.WindowHeight, RequiredHeight)
    end

    function Loading:SetErrorMessage(Text)
        ErrorLabel.Text = Text
        Loading:UpdateLayout()
    end

    function Loading:SetErrorButtons(Buttons)
        assert(typeof(Buttons) == "table", "Buttons must be a table")

        for _, button in ErrorButtonsHolder:GetChildren() do
            if button:IsA("Frame") then 
                button:Destroy() 
            end
        end

        local HasButtons = GetTableSize(Buttons) > 0
        ErrorButtonsHolder.Visible = HasButtons
        ErrorButtonsDivider.Visible = HasButtons

        for Idx, ButtonInfo in Buttons do
            local ButtonContainer = New("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 26),
                Parent = ErrorButtonsHolder,
            })
            
            local BtnColor = "MainColor"
            local BtnOutline = "OutlineColor"
            local Variant = ButtonInfo.Variant or "Primary"
            
            if Variant == "Primary" then
                BtnColor = "FontColor"
                BtnOutline = "FontColor"
            elseif Variant == "Secondary" then
                BtnColor = "MainColor"
                BtnOutline = "OutlineColor"
            elseif Variant == "Destructive" then
                BtnColor = "DestructiveColor"
                BtnOutline = "DestructiveColor"
            elseif Variant == "Ghost" then
                BtnColor = "BackgroundColor"
                BtnOutline = "BackgroundColor"
            end

            local TextBtn = New("TextButton", {
                BackgroundColor3 = BtnColor,
                BorderColor3 = BtnOutline,
                Size = UDim2.fromOffset(0, 26),
                Text = "",
                AutoButtonColor = false,
                Parent = ButtonContainer,
            })
            Library:AddOutline(TextBtn)
            table.insert(
                Library.Corners,
                New("UICorner", { 
                    CornerRadius = UDim.new(0, Library.CornerRadius), 
                    Parent = TextBtn 
                })
            )

            New("UIPadding", {
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                Parent = TextBtn,
            })

            local TextColor = Library.Scheme.FontColor
            if Variant == "Primary" then
                TextColor = Library.Scheme.BackgroundColor
            elseif Variant == "Destructive" then
                TextColor = Color3.new(1, 1, 1)
            end

            local BtnLabel = New("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Text = ButtonInfo.Title or Idx,
                TextColor3 = TextColor,
                TextSize = 14,
                Parent = TextBtn,
            })
            
            local LabelX, _ = Library:GetTextBounds(BtnLabel.Text, Library.Scheme.Font, 14, 250)
            ButtonContainer.Size = UDim2.fromOffset(LabelX + 30, 26)
            TextBtn.Size = UDim2.fromOffset(LabelX + 30, 26)

            local ActiveColor = typeof(BtnColor) == "Color3" and BtnColor or Library.Scheme[BtnColor]
            local HoverColor = Variant == "Ghost" and Library.Scheme.MainColor or Library:GetBetterColor(ActiveColor, 10)

            TextBtn.MouseEnter:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = HoverColor
                }):Play()
            end)
            TextBtn.MouseLeave:Connect(function()
                TweenService:Create(TextBtn, Library.TweenInfo, {
                    BackgroundColor3 = ActiveColor
                }):Play()
            end)

            TextBtn.MouseButton1Click:Connect(function()
                if ButtonInfo.Callback then
                    ButtonInfo.Callback(Loading)
                end
            end)
        end

        Loading:UpdateLayout()
    end

    --// Destroy/Continue \\--
    function Loading:Destroy()
        if RotationTween then
            StopTween(RotationTween, true)
            RotationTween = nil
        end

        ScreenGui:Destroy()
        Loading.Destroyed = true
        Library.ActiveLoading = nil

        if Library.Toggle and Library.Toggled == false and Library.Unloaded ~= true then
            Library:Toggle(true)
        end
    end

    Loading.Continue = Loading.Destroy;

    if Library.Toggle and Library.Toggled and Library.Unloaded ~= true then
        Library:Toggle(false)
    end

    Loading:SetCurrentStep(Loading.CurrentStep)

    Library.ActiveLoading = Loading
    return Loading
end

local function OnPlayerChange()
    if Library.Unloaded then
        return
    end

    local PlayerList, ExcludedPlayerList = GetPlayers(), GetPlayers(true)
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Player" then
            Dropdown:SetValues(Dropdown.ExcludeLocalPlayer and ExcludedPlayerList or PlayerList)
        end
    end
end

local function OnTeamChange()
    if Library.Unloaded then
        return
    end

    local TeamList = GetTeams()
    for _, Dropdown in Options do
        if Dropdown.Type == "Dropdown" and Dropdown.SpecialType == "Team" then
            Dropdown:SetValues(TeamList)
        end
    end
end

Library:GiveSignal(Players.PlayerAdded:Connect(OnPlayerChange))
Library:GiveSignal(Players.PlayerRemoving:Connect(OnPlayerChange))

Library:GiveSignal(Teams.ChildAdded:Connect(OnTeamChange))
Library:GiveSignal(Teams.ChildRemoved:Connect(OnTeamChange))

function Library:Unload()
    Library.Unloaded = true

    for Index = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Index)
        if Connection and Connection.Connected then
            Connection:Disconnect()
        end
    end

    for _ = 1, #Library.UnloadSignals do
        local Callback = table.remove(Library.UnloadSignals, 1)
        if Callback then
            Library:SafeCallback(Callback)
        end
    end

    for Index = #Library.Tabs, 1, -1 do
        local Tab = table.remove(Library.Tabs, Index)
        if Tab and Tab.Destroy then
            Library:SafeCallback(Tab.Destroy, Tab)
        end
    end

    for Index = #Tooltips, 1, -1 do
        local Tooltip = table.remove(Tooltips, Index)
        if Tooltip and Tooltip.Destroy then
            Library:SafeCallback(Tooltip.Destroy, Tooltip)
        end
    end

    if Library.ActiveExpandedDropdown then
        Library.ActiveExpandedDropdown:Collapse()
    end

    if Library.ActiveLoading then
        Library.ActiveLoading:Destroy()
    end

    if ScreenGui then
        ScreenGui:Destroy()
    end

    table.clear(Library.Registry)

    table.clear(Options)
    table.clear(Toggles)
    table.clear(Buttons)
    table.clear(Labels)
    table.clear(Tooltips)

    table.clear(Library.Tabs)
    table.clear(Library.TabButtons)

    table.clear(Library.Scales)
    table.clear(Library.ScalesOffset)

    table.clear(Library.Corners)
    table.clear(Library.SpecificCorners)
    table.clear(Library.PillCorners)

    table.clear(Library.Notifications)
    table.clear(Library.NotificationHistory)
    table.clear(Library.Dialogues)
    table.clear(Library.DraggableElements)
    table.clear(Library.KeybindToggles)
    table.clear(Library.DependencyBoxes)

    table.clear(TransparencyCache)
    table.clear(ActiveTabTweens)
    
    Library.Toggle = function(...) end
    Library.ScreenGui = nil
    Library.WindowContainer = nil
    Library.MainFrame = nil
    Library.KeybindFrame = nil
    Library.KeybindContainer = nil
    Library.NotificationHistoryFrame = nil
    Library.NotificationHistoryContainer = nil
    Library.NotificationHistoryOpen = false
    Library.NotificationHistoryRestPos = nil
    Library.NotificationBadge = nil
    table.clear(Library.NotificationBadges)
    Library.NotificationBell = nil
    Library.NotificationBellMini = nil
    Library.NotificationUnreadCount = 0

    Library.EnabledFeaturesFrame = nil
    Library.EnabledFeaturesContainer = nil
    Library.EnabledFeaturesButton = nil
    Library.EnabledFeaturesButtonMini = nil
    Library.EnabledFeaturesOpen = false
    Library.EnabledFeaturesRestPos = nil

    getgenv().Library = nil
end

getgenv().Library = Library
return Library

