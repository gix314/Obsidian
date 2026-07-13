local cloneref = (cloneref or clonereference or function(i)
    return i
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService = cloneref(game:GetService("HttpService"))
local o_isfolder, o_isfile, o_listfiles = isfolder, isfile, listfiles

local function isfolder(p)
    local s, r = pcall(o_isfolder, p)
    return s and r == true
end

local function isfile(p)
    local s, r = pcall(o_isfile, p)
    return s and r == true
end

local function listfiles(p)
    local s, r = pcall(o_listfiles, p)
    return s and type(r) == "table" and r or {}
end

if typeof(clonefunction) == "function" then
    -- Fix is_____ functions for shitsploits, those functions should never error, only return a boolean.

    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local SchemeIndexes = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
local ThemeManager = {
    Library = nil,

    Folder = "ObsidianLibSettings",

    AppliedToTab = false,
    DefaultThemeName = nil,

    BuiltInThemes = {
    ["Demara"] = {
        1,
        { FontColor = "dce1df", MainColor = "202225", AccentColor = "98c43c", BackgroundColor = "151618", OutlineColor = "35393f" },
    },
    ["Starlight"] = {
        2,
        { FontColor = "ececee", MainColor = "252528", AccentColor = "cf2a30", BackgroundColor = "19191a", OutlineColor = "44444a" },
    },
    ["Cunning Hares"] = {
        3,
        { FontColor = "f2f2f5", MainColor = "212022", AccentColor = "e397a6", BackgroundColor = "131214", OutlineColor = "423e42" },
    },
    ["Soldier"] = {
        4,
        { FontColor = "e2e7e9", MainColor = "2a292c", AccentColor = "e89c1a", BackgroundColor = "1c1b1d", OutlineColor = "4b494d" },
    },
    ["Wickes"] = {
        5,
        { FontColor = "eceef2", MainColor = "24262b", AccentColor = "9eb2a0", BackgroundColor = "171719", OutlineColor = "3a3d42" },
    },
    ["Sebastiane"] = {
        6,
        { FontColor = "ededf0", MainColor = "222123", AccentColor = "c0272b", BackgroundColor = "141314", OutlineColor = "424043" },
    },
    ["Lycaon"] = {
        7,
        { FontColor = "f5f7fa", MainColor = "1d1d22", AccentColor = "a31c21", BackgroundColor = "131215", OutlineColor = "403e45" },
    },
    ["Ben"] = {
        8,
        { FontColor = "e6e4eb", MainColor = "2b2a2d", AccentColor = "db4316", BackgroundColor = "1c1b1c", OutlineColor = "48464a" },
    },
    ["Belobog"] = {
        9,
        { FontColor = "e7e5ec", MainColor = "252528", AccentColor = "e54714", BackgroundColor = "161618", OutlineColor = "cca33d" },
    },
    ["Piper"] = {
        10,
        { FontColor = "e5dfc5", MainColor = "262525", AccentColor = "c6502a", BackgroundColor = "171616", OutlineColor = "4a494a" },
    },
    ["Soukaku"] = {
        11,
        { FontColor = "eef6fa", MainColor = "232b35", AccentColor = "59bde5", BackgroundColor = "14161a", OutlineColor = "365e69" },
    },
    ["Officer"] = {
        12,
        { FontColor = "e8ebf0", MainColor = "1d2636", AccentColor = "3168cc", BackgroundColor = "131315", OutlineColor = "414754" },
    },
    ["Neo-Genesis"] = {
        13,
        { FontColor = "e6ebe8", MainColor = "23262d", AccentColor = "18856a", BackgroundColor = "16171a", OutlineColor = "383d47" },
    },
    ["Catppuccin"] = {
        14,
        { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" },
    },
    ["One Dark"] = {
        15,
        { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" },
    },
    ["Cyberpunk"] = {
        16,
        { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" },
    },
    ["Oceanic Next"] = {
        17,
        { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
    },
    ["Material"] = {
        18,
        { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
    },
    ["Chief Angel"] = {
        19,
        { FontColor = "ebebf5", MainColor = "181f30", AccentColor = "416bae", BackgroundColor = "0d111b", OutlineColor = "354158" },
    },
    ["Mebius"] = {
        20,
        { FontColor = "e2efe0", MainColor = "2d322e", AccentColor = "d4fa43", BackgroundColor = "1e1f22", OutlineColor = "535e4b" },
    },
    ["Guard of Staves"] = {
        21,
        { FontColor = "ebe7f3", MainColor = "1d1826", AccentColor = "df849d", BackgroundColor = "120e17", OutlineColor = "3c344a" },
    }
}
}

function ThemeManager:SetLibrary(Library)
    ThemeManager.Library = Library
end

--// Helpers \\--
local function Trim(Text: string)
    return Text:match("^%s*(.-)%s*$")
end

local function IsStringEmpty(String: string): boolean
    return if typeof(String) == "string" then Trim(String) == "" else true
end

local function IsValidFolderPath(Name: string): boolean
    return typeof(Name) == "string" and (
        Trim(Name) ~= "" and 
        not Name:match("^%s*$") and 
        not Name:find('[<>:"|%?%*%z]')
    )
end

--// Folder helper \\--
local function SplitPath(Path: string): {string}
	local Result = {}
	local Current = ""

	for Part in string.gmatch(Path, "[^/]+") do
		Current = if Current == "" then Part else (Current .. "/" .. Part)
		table.insert(Result, Current)
	end

	return Result
end

local function GetFolderPath(): false | string
    if IsStringEmpty(ThemeManager.Folder) then
        return false
    end

    return string.format("%s/themes", ThemeManager.Folder)
end

local GetCurrentThemesPath = GetFolderPath

--// Files helper \\--
local function GetThemePath(ThemeName: string): false | string
    local CurrentThemesPath = GetCurrentThemesPath()
    return if CurrentThemesPath == false then false else string.format("%s/%s.json", CurrentThemesPath, ThemeName)
end

local function DoesThemeExist(ThemeName: string, IncludeBuiltIn: boolean): boolean
    if ThemeName == "Default" or ThemeManager.BuiltInThemes[ThemeName] then
        return true
    end

    local ThemePath = GetThemePath(ThemeName)
    return if ThemePath == false then false else isfile(ThemePath)
end

local function GetDefaultThemePath(): false | string
    local CurrentThemesPath = GetCurrentThemesPath()
    return if CurrentThemesPath == false then false else string.format("%s/default.txt", CurrentThemesPath)
end

--// Folders \\--
function ThemeManager:GetPaths(): {string}
    local FolderPath = GetFolderPath()
    return if FolderPath == false then {} else SplitPath(FolderPath)
end

function ThemeManager:BuildFolderTree(SkipWhenCreated: boolean?)
    local Paths = ThemeManager:GetPaths()
    if #Paths == 0 then
        return false
    end

    if SkipWhenCreated == true then
        if isfolder(Paths[1]) then
            return true
        end
    end

    for _, Path in Paths do
        if isfolder(Path) then continue end
        
        makefolder(Path)
    end

    return true
end

function ThemeManager:CheckFolderTree()
    return ThemeManager:BuildFolderTree(true)
end

function ThemeManager:SetFolder(Folder: string)
    assert(IsValidFolderPath(Folder), "Invalid path provided")

    ThemeManager.Folder = Folder
    ThemeManager:BuildFolderTree()
end

--// Theme Management \\--
function ThemeManager:ReloadCustomThemes()
    local SettingsPath = GetCurrentThemesPath()
    if SettingsPath == false then
        return {}
    end

    local SuccessList, Files = pcall(listfiles, SettingsPath)
    if not (SuccessList and typeof(Files) == "table") then
        ThemeManager.Library:Notify(string.format("Failed to load theme list: %s", tostring(Files)))
        return {}
    end

    local FileNames = {}
    for _, FilePath in Files do
        local RawFileName = FilePath:match("(.+)%..+$")
        if not RawFileName then continue end

        local Position = RawFileName:gsub("\\", "/"):find("/[^/]*$")
        local FileName = Position and RawFileName:sub(Position + 1) or RawFileName
        if not FileName or FileName == "default" then continue end

        table.insert(FileNames, FileName)
    end

    return FileNames
end

function ThemeManager:GetCustomTheme(ThemeName: string): any
    if IsStringEmpty(ThemeName) then
        return nil
    end

    local ThemePath = GetThemePath(ThemeName)
    if ThemePath == false or not isfile(ThemePath) then
        return nil
    end

    local SuccessRead, Content = pcall(readfile, ThemePath)
    if not SuccessRead then
        return nil
    end

    local SuccessDecode, Decoded = pcall(HttpService.JSONDecode, HttpService, Content)
    if not SuccessDecode or typeof(Decoded) ~= "table" then
        return nil
    end

    return Decoded
end

function ThemeManager:SaveCustomTheme(ThemeName: string): any
    if IsStringEmpty(ThemeName) then
        return false, "Invalid theme name provided"
    end

    if string.lower(ThemeName) == "default" then
        return false, "Invalid theme name provided"
    end

    local ThemePath = GetThemePath(ThemeName)
    if ThemePath == false then
        return false, "Invalid theme name provided"
    end

    ThemeManager:CheckFolderTree()

    local Library = ThemeManager.Library
    local ThemeData = {
        FontFace = Library.Options.FontFace.Value,
        BackgroundImage = Library.Options.BackgroundImage.Value
    }

    for _, SchemeIndex in SchemeIndexes do
        ThemeData[SchemeIndex] = Library.Options[SchemeIndex].Value:ToHex()
    end

    local SuccessEncode, EncodedData = pcall(HttpService.JSONEncode, HttpService, ThemeData)
    if not SuccessEncode then
        return false, "Failed to encode data"
    end

    local SuccessWrite, ErrorMessage = pcall(writefile, ThemePath, EncodedData)
    if not SuccessWrite then
        return false, "Failed to write theme file: " .. tostring(ErrorMessage)
    end

    return true
end

function ThemeManager:Delete(ThemeName: string): (boolean | string?)
    if IsStringEmpty(ThemeName) then
        return false, "No theme is selected"
    end

    local ThemePath = GetThemePath(ThemeName)
    if ThemePath == false or not isfile(ThemePath) then
        return false, "Theme file does not exist"
    end

    local SuccessDelete, ErrorMessage = pcall(delfile, ThemePath)
    if not SuccessDelete then
        return false, "Failed to delete theme file: " .. tostring(ErrorMessage)
    end

    if ThemeName == ThemeManager.DefaultThemeName then
        ThemeManager:DeleteDefaultTheme()
    end

    return true
end

--// Default Theme \\--
function ThemeManager:GetDefaultTheme(): (string, boolean, string?)
    ThemeManager:CheckFolderTree()

    local DefaultThemePath = GetDefaultThemePath()
    if DefaultThemePath == false then
        return "none", false, "Invalid path provided"
    end

    if not isfile(DefaultThemePath) then
        return "none", false, "Default theme is not set"
    end

    local SuccessRead, DefaultThemeName = pcall(readfile, DefaultThemePath)
    if not (SuccessRead and typeof(DefaultThemeName) == "string") then
        return "none", false, DefaultThemeName
    end

    local ConfigExists = DoesThemeExist(DefaultThemeName, true)
    if not ConfigExists then
        return "none", false, "Theme file not found"
    end

    ThemeManager.DefaultThemeName = DefaultThemeName
    return DefaultThemeName, true
end

function ThemeManager:SetDefaultTheme(Theme: any)
    assert(ThemeManager.Library, "Library is not set, call ThemeManager:SetLibrary(Library) first.")
    assert(not ThemeManager.AppliedToTab, "Cannot set default theme after applying ThemeManager to a tab!")

    local Library = ThemeManager.Library
    local DefaultThemeData = ThemeManager.BuiltInThemes["Wickes"][2]

    if Theme == nil or Theme == "Default" or Theme == (ThemeManager.BuiltInThemes["Default"] or {}) then
        Theme = DefaultThemeData
    elseif typeof(Theme) == "string" then
        local found = ThemeManager.BuiltInThemes[Theme]
        Theme = found and found[2] or DefaultThemeData
    elseif typeof(Theme) == "table" then
        if Theme[2] and typeof(Theme[2]) == "table" then
            Theme = Theme[2]
        end
    else
        Theme = DefaultThemeData
    end

    local LibraryScheme = {}
    local FinalTheme = {}

    for _, SchemeIndex in SchemeIndexes do
        local IndexData = Theme[SchemeIndex]
        local IndexType = typeof(IndexData)
        
        if IndexType == "Color3" then
            LibraryScheme[SchemeIndex] = IndexData
            FinalTheme[SchemeIndex] = string.format("#%s", IndexData:ToHex())

        elseif IndexType == "string" then
            LibraryScheme[SchemeIndex] = Color3.fromHex(IndexData)
            FinalTheme[SchemeIndex] = if IndexData:sub(1, 1) == "#" then IndexData else string.format("#%s", IndexData)
        
        else
            local Value = DefaultThemeData[SchemeIndex]
            LibraryScheme[SchemeIndex] = Color3.fromHex(Value)
            FinalTheme[SchemeIndex] = Value
        end
    end

    --// Font
    local FontFace = Theme["FontFace"]
    local FontFaceType = typeof(FontFace)
    
    if FontFaceType == "EnumItem" then
        LibraryScheme.Font = Font.fromEnum(FontFace)
        FinalTheme.FontFace = FontFace.Name

    elseif FontFaceType == "string" then
        LibraryScheme.Font = Font.fromEnum(Enum.Font[FontFace])
        FinalTheme.FontFace = FontFace
    
    else
        LibraryScheme.Font = Font.fromEnum(Enum.Font.Code)
        FinalTheme.FontFace = "Code"
    end

    --// Default Scheme Colors
    for _, DefaultSchemeColor in { "RedColor", "DestructiveColor", "DarkColor", "WhiteColor" } do
        LibraryScheme[DefaultSchemeColor] = Library.Scheme[DefaultSchemeColor]
    end

    --// Apply
    Library.Scheme = LibraryScheme
    ThemeManager.BuiltInThemes["Wickes"] = { 1, FinalTheme }

    Library:UpdateColorsUsingRegistry()
end

function ThemeManager:SaveDefault(ThemeName: string): (boolean, string?)
    if IsStringEmpty(ThemeName) then
        return false, "No theme is selected"
    end

    ThemeManager:CheckFolderTree()

    local DefaultThemePath = GetDefaultThemePath()
    if DefaultThemePath == false then
        return false, "Invalid path provided"
    end

    if not DoesThemeExist(ThemeName, true) then
        return false, "Theme does not exist"
    end

    local SuccessWrite, ErrorMessage = pcall(writefile, DefaultThemePath, ThemeName)
    if not SuccessWrite then
        return false, ErrorMessage
    end

    ThemeManager.DefaultThemeName = ThemeName
    return true
end

function ThemeManager:LoadDefault()
    local ThemeName, Success, FetchErrorMessage = ThemeManager:GetDefaultTheme()
    
    if not Success then
        if FetchErrorMessage == "Default theme is not set" then
            ThemeName = "Wickes"
        else
            ThemeManager.Library:Notify(string.format("Failed to apply default theme: %s", FetchErrorMessage))
            return
        end
    end

    if not ThemeManager:GetCustomTheme(ThemeName) then
        ThemeManager.Library.Options.ThemeManager_ThemeList:SetValue(ThemeName)
        ThemeManager:ApplyTheme(ThemeName)
        return
    end

    local SuccessLoad, LoadErrorMessage = ThemeManager:ApplyTheme(ThemeName)
    if not SuccessLoad then
        ThemeManager.Library:Notify(string.format("Failed to apply default theme: %s", LoadErrorMessage))
        return
    end

    ThemeManager.Library:Notify(string.format("Successfully applied default theme %q", ThemeName))
end

function ThemeManager:DeleteDefaultTheme(): (boolean, string?)
    ThemeManager:CheckFolderTree()

    local DefaultThemePath = GetDefaultThemePath()
    if DefaultThemePath == false then
        return false, "Invalid path provided"
    end

    if not isfile(DefaultThemePath) then
        return false, "Default theme is not set"
    end

    local SuccessDelete, ErrorMessage = pcall(delfile, DefaultThemePath)
    if not SuccessDelete then
        return false, ErrorMessage
    end

    ThemeManager.DefaultThemeName = nil
    return true
end

--// Apply Theme \\--
function ThemeManager:ThemeUpdate()
    local Library = ThemeManager.Library

    for _, SchemeIndex in SchemeIndexes do
        local Element = Library.Options[SchemeIndex]
        if not Element then continue end

        Library.Scheme[SchemeIndex] = Element.Value
    end

    Library:UpdateColorsUsingRegistry()
end

function ThemeManager:ApplyTheme(ThemeName: string)
    if IsStringEmpty(ThemeName) then
        return false, "No theme is selected"
    end

    if ThemeName == "Default" then
        ThemeName = "Wickes"
    end

    local CustomThemeData = ThemeManager:GetCustomTheme(ThemeName)
    local Data = CustomThemeData or ThemeManager.BuiltInThemes[ThemeName]
    
    if not Data then
        return false, "Theme not found"
    end
    
    local Library = ThemeManager.Library
    local SchemeData = Data[2]
    local ThemeData = CustomThemeData or SchemeData

    for Index, Value in ThemeData do
        if Index == "VideoLink" then
            continue
        end

        local Element = Library.Options[Index]
        local FinalValue = Value

        if Index == "FontFace" then
            ThemeManager.Library:SetFont(Enum.Font[FinalValue])

        elseif Index == "BackgroundImage" then
            ThemeManager.Library:SetBackgroundImage(FinalValue)

        else
            FinalValue = Color3.fromHex(Value)
            Library.Scheme[Index] = FinalValue
        end

        if Element then
            Element:SetValue(FinalValue)
        end
    end

    ThemeManager:ThemeUpdate()
    return true
end

--// GUI \\--
local function ShowDialog(
    Condition: () -> boolean,

    Index: string, 
    Title: string, 
    Description: string,

    DestructiveText: string,
    DestructiveAction: () -> nil
)
    if Condition() == false then
        return DestructiveAction()
    end

    return ThemeManager.Library.Window:AddDialog(Index, {
        Title = Title,
        Description = Description,
        AutoDismiss = false,

        FooterButtons = {
            Cancel = {
                Title = "Cancel",
                Variant = "Ghost",
                Order = 1,
                Callback = function(Dialog)
                    Dialog:Dismiss()
                end
            },

            DestructiveAction = {
                Title = DestructiveText,
                Variant = "Destructive",
                Order = 2,
                Callback = function(Dialog)
                    Dialog:Dismiss()
                    DestructiveAction()
                end
            }
        }
    })
end

function ThemeManager:CreateThemeManager(Themesbox: any)
    assert(ThemeManager.Library, "Library is not set, call ThemeManager:SetLibrary(Library) first.")

    local BuiltInThemesNames = {}
    for Name, _ThemeData in ThemeManager.BuiltInThemes do
        table.insert(BuiltInThemesNames, Name)
    end

    local CustomThemeList, CustomThemeName, ThemeList, FontFace, BackgroundImage, DefaultThemeLabel
    local function RefreshList()
        CustomThemeList:SetValues(ThemeManager:ReloadCustomThemes())
        CustomThemeList:SetValue(nil)

        ThemeList:SetValues(BuiltInThemesNames)
    end

    local function RefreshDefaultThemeLabel()
        local DefaultThemeName, _Success, _ErrorMessage = ThemeManager:GetDefaultTheme()

        DefaultThemeLabel:SetText(string.format("Current default theme: %s", DefaultThemeName))
        if CustomThemeList then RefreshList() end
    end

    table.sort(BuiltInThemesNames, function(IndexA, IndexB)
        return ThemeManager.BuiltInThemes[IndexA][1] < ThemeManager.BuiltInThemes[IndexB][1]
    end)

    local function CreateColorOption(Text, SchemeIndex)
        Themesbox:AddLabel(Text):AddColorPicker(SchemeIndex, {
            Default = ThemeManager.Library.Scheme[SchemeIndex]
        })

        return ThemeManager.Library.Options[SchemeIndex]
    end

    local BackgroundColor = CreateColorOption("Background color", "BackgroundColor")
    local MainColor = CreateColorOption("Main color", "MainColor")
    local AccentColor = CreateColorOption("Accent color", "AccentColor")
    local OutlineColor = CreateColorOption("Outline color", "OutlineColor")
    local FontColor = CreateColorOption("Font color", "FontColor")
    
    Themesbox:AddDropdown("FontFace", {
        Text = "Font Face",
        Default = "Code",
        Searchable = true,
        Values = { "AmaticSC", "Antique", "Arcade", "Arial", "ArialBold", "Bangers", "Bodoni", "BuilderSans", "BuilderSansMedium", "BuilderSansBold", "BuilderSansExtraBold", "Cartoon", "Code", "Creepster", "Denim", "Fantasy", "Fondamento", "FrancoisOne", "FredokaOne", "Garamond", "Gotham", "GothamMedium", "GothamBold", "GothamBlack", "GrenzeGotisch", "Highway", "IndieFlower", "JosefinSans", "Jura", "Kalam", "Legacy", "LuckiestGuy", "Merriweather", "Michroma", "Nunito", "Oswald", "PatrickHand", "PermanentMarker", "Roboto", "RobotoMono", "Sarpanch", "SciFi", "SourceSans", "SourceSansLight", "SourceSansSemibold", "SourceSansBold", "SourceSansItalic", "SpecialElite", "TitilliumWeb", "Ubuntu" },
        AllowNull = false,
        Multi = false
    })
    
    Themesbox:AddInput("BackgroundImage", { 
        Text = "Background Image",

        Default = "",
        Finished = true,
        ClearTextOnFocus = false,
        ClearTextOnBlur = false
    })

    Themesbox:AddDivider()

    Themesbox:AddDropdown("ThemeManager_ThemeList", { 
        Text = "Theme list", 

        Values = BuiltInThemesNames,
        AllowNull = true,
        Multi = false,

        FormatDisplayValue = function(Value: any)
            if Value ~= "Wickes" and Value == ThemeManager.DefaultThemeName then
                return string.format("%s (default)", Value)
            end

            return Value
        end,
        FormatListValue = function(Value: any)
            if Value ~= "Wickes" and Value == ThemeManager.DefaultThemeName then
                return string.format("%s (default)", Value)
            end

            return Value
        end
    })

    Themesbox:AddButton("Set as default", function()
        local ThemeName = ThemeList.Value
        ThemeManager:SaveDefault(ThemeName)

        ThemeManager.Library:Notify(string.format("Successfully set default theme to %q", ThemeName))
        RefreshDefaultThemeLabel()
    end)

    Themesbox:AddDivider()

    CustomThemeName = Themesbox:AddInput("ThemeManager_CustomThemeName", { 
        Text = "Custom theme name" 
    })

    Themesbox:AddButton("Create theme", function()
        local Name = CustomThemeName.Value
        if IsStringEmpty(Name) then
            ThemeManager.Library:Notify("Theme name cannot be empty.")
            return
        end

        if string.lower(Name) == "default" then
            ThemeManager.Library:Notify("Invalid theme name provided.")
            return
        end

        ShowDialog(
            function(): boolean
                return ThemeManager:GetCustomTheme(Name) ~= nil
            end,

            "ThemeManager_CreateTheme",
            "Theme already exists",
            string.format("A custom theme named %q already exists. Overwriting it will replace it with your current colors.", Name),

            "Overwrite",
            function()
                local Success, ErrorMessage = ThemeManager:SaveCustomTheme(Name)
                if not Success then
                    ThemeManager.Library:Notify(string.format("Failed to create theme %q: %s", Name, ErrorMessage))
                    return
                end

                ThemeManager.Library:Notify(string.format("Successfully created theme %q", Name))
                RefreshList()
            end
        )
    end)

    Themesbox:AddDivider()

    CustomThemeList = Themesbox:AddDropdown("ThemeManager_CustomThemeList", { 
        Text = "Custom themes",

        Values = ThemeManager:ReloadCustomThemes(), 
        AllowNull = true,
        Multi = false,

        FormatDisplayValue = function(Value: any)
            if Value == ThemeManager.DefaultThemeName then
                return string.format("%s (default)", Value)
            end

            return Value
        end,
        FormatListValue = function(Value: any)
            if Value == ThemeManager.DefaultThemeName then
                return string.format("%s (default)", Value)
            end

            return Value
        end
    })

    local GBT1 = Themesbox:AddButton("Load theme", function()
        local Name = CustomThemeList.Value
        if IsStringEmpty(Name) then
            ThemeManager.Library:Notify("Please select a theme first.")
            return
        end

        ThemeManager:ApplyTheme(Name)
        ThemeManager.Library:Notify(string.format("Successfully loaded theme %q", Name))
    end)

    GBT1:AddButton("Overwrite theme", function()
        local Name = CustomThemeList.Value
        if IsStringEmpty(Name) then
            ThemeManager.Library:Notify("Please select a theme first.")
            return
        end

        ShowDialog(
            function(): boolean
                return true
            end,

            "ThemeManager_OverwriteTheme",
            "Overwrite theme",
            string.format("Are you sure you want to overwrite %q with your current colors? This cannot be undone.", Name),

            "Overwrite",
            function()
                ThemeManager:SaveCustomTheme(Name)
                ThemeManager.Library:Notify(string.format("Successfully overwrote theme %q", Name))
            end
        )
    end)

    local GBT2 = Themesbox:AddButton("Delete theme", function()
        local Name = CustomThemeList.Value
        if IsStringEmpty(Name) then
            ThemeManager.Library:Notify("Please select a theme first.")
            return
        end

        ShowDialog(
            function(): boolean
                return true
            end,

            "ThemeManager_DeleteTheme",
            "Delete theme",
            string.format("Are you sure you want to delete %q? This cannot be undone.", Name),
            
            "Delete",
            function()
                local Success, ErrorMessage = ThemeManager:Delete(Name)
                if not Success then
                    ThemeManager.Library:Notify(string.format("Failed to delete theme: %s", ErrorMessage))
                    return
                end

                ThemeManager.Library:Notify(string.format("Successfully deleted theme %q", Name))
                RefreshDefaultThemeLabel()
            end
        )
    end)

    GBT2:AddButton("Refresh list", RefreshList)

    local GBT3 = Themesbox:AddButton("Set as default", function()
        local Name = CustomThemeList.Value
        if IsStringEmpty(Name) then
            ThemeManager.Library:Notify("Please select a theme first.")
            return
        end

        ThemeManager:SaveDefault(Name)
        ThemeManager.Library:Notify(string.format("Successfully set default theme to %q", Name))
        RefreshDefaultThemeLabel()
    end)

    GBT3:AddButton("Reset default", function()
        ShowDialog(
            function(): boolean
                return true
            end,

            "ThemeManager_ResetDefault",
            "Reset default theme",
            "Are you sure you want to clear the default theme? The library will revert to its built-in default on next load.",
            
            "Reset",
            function()
                local Success, ErrorMessage = ThemeManager:DeleteDefaultTheme()
                if not Success then
                    ThemeManager.Library:Notify(string.format("Failed to reset default theme: %s", ErrorMessage))
                    return
                end

                ThemeManager.Library:Notify("Successfully reset default theme.")
                RefreshDefaultThemeLabel()
            end
        )
    end)

    DefaultThemeLabel = Themesbox:AddLabel("Current default theme: ...", true)

    CustomThemeList, CustomThemeName, ThemeList, FontFace, BackgroundImage =
        ThemeManager.Library.Options.ThemeManager_CustomThemeList,
        ThemeManager.Library.Options.ThemeManager_CustomThemeName,
        ThemeManager.Library.Options.ThemeManager_ThemeList,
        ThemeManager.Library.Options.FontFace,
        ThemeManager.Library.Options.BackgroundImage

    ThemeList:OnChanged(function()
        ThemeManager:ApplyTheme(ThemeList.Value)
    end)

    local function UpdateTheme()
        ThemeManager:ThemeUpdate()
    end

    BackgroundColor:OnChanged(UpdateTheme)
    MainColor:OnChanged(UpdateTheme)
    AccentColor:OnChanged(UpdateTheme)
    OutlineColor:OnChanged(UpdateTheme)
    FontColor:OnChanged(UpdateTheme)
    FontFace:OnChanged(function(Value) ThemeManager.Library:SetFont(Enum.Font[Value]) end)
    BackgroundImage:OnChanged(function(Value) ThemeManager.Library:SetBackgroundImage(Value) end)

    ThemeManager:LoadDefault()
    ThemeManager.AppliedToTab = true
    RefreshDefaultThemeLabel()

    return Themesbox
end

function ThemeManager:CreateGroupBox(Tab: any, IconName: string)
    return Tab:AddLeftGroupbox("Themes", IconName or "paintbrush")
end

function ThemeManager:ApplyToTab(Tab: any, IconName: string)
    local Groupbox = ThemeManager:CreateGroupBox(Tab, IconName)
    return ThemeManager:CreateThemeManager(Groupbox)
end

function ThemeManager:ApplyToGroupbox(Groupbox: any)
    return ThemeManager:CreateThemeManager(Groupbox)
end

getgenv().ObsidianThemeManager = ThemeManager
return ThemeManager
