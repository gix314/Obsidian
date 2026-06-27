local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

if typeof(clonefunction) == "function" then
    -- Fix is_____ functions for shitsploits, those functions should never error, only return a boolean.
    local isfolder_copy, isfile_copy, listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

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

local SaveManager = {} do
    SaveManager.Folder = "ObsidianLibSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.UseLoadingOrder = false
    SaveManager.LoadingOrder = {}
    SaveManager.CurrentConfig = nil
    SaveManager.AutoSaveConfigCached = nil

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = "Toggle", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = "ColorPicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = "KeyPicker", idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == "string" then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    --// Logging System (Commented out to prevent disk writes, uncomment print for debugging) \\--
    function SaveManager:Log(...)
        --[[
        local args = {...}
        local str = ""
        for i, v in ipairs(args) do
            str = str .. tostring(v) .. (i < #args and " " or "")
        end
        local timestamp = os.date("[%Y-%m-%d %H:%M:%S]")
        print(timestamp .. " " .. str)
        --]]
    end

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:SetLoadingOrder(enabled, order)
        self.UseLoadingOrder = enabled

        if typeof(order) == "table" then
            self.LoadingOrder = order
        end
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace", -- themes
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName", -- themes
        })
    end

    --// Folders \\--
    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end

        if createFolder == true then
            if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then
                makefolder(self.Folder .. "/settings/" .. self.SubFolder)
            end
        end

        return true
    end

    function SaveManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            local path = table.concat(parts, "/", 1, idx)
            if not table.find(paths, path) then paths[#paths + 1] = path end
        end

        paths[#paths + 1] = self.Folder .. "/themes"
        paths[#paths + 1] = self.Folder .. "/settings"

        if self:CheckSubFolder(false) then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
            parts = subFolder:split("/")

            for idx = 1, #parts do
                local path = table.concat(parts, "/", 1, idx)
                if not table.find(paths, path) then paths[#paths + 1] = path end
            end
        end

        return paths
    end

    function SaveManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if isfolder(str) then continue end

            makefolder(str)
        end
    end

    function SaveManager:CheckFolderTree()
        if isfolder(self.Folder) then return end
        SaveManager:BuildFolderTree()

        task.wait(0.1)
    end

    function SaveManager:SetIgnoreIndexes(list)
        for _, key in pairs(list) do
            self.Ignore[key] = true
        end
    end

    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self.AutoSaveConfigCached = nil -- Invalidate cache when directory changes
        self:BuildFolderTree()
    end

    function SaveManager:SetSubFolder(folder)
        self.SubFolder = folder
        self.AutoSaveConfigCached = nil -- Invalidate cache when subdirectory changes
        self:BuildFolderTree()
    end

    --// Save, Load, Delete, Refresh \\--
    function SaveManager:Save(name)
        if not name then
            return false, "no config file is selected"
        end
        self.CurrentConfig = name
        SaveManager:CheckFolderTree()
        local fullPath = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            fullPath = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end
        local data = {
            objects = {}
        }
        for idx, toggle in pairs(self.Library.Toggles) do
            if not toggle.Type then continue end
            if not self.Parser[toggle.Type] then continue end
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
        end
        for idx, option in pairs(self.Library.Options) do
            if not option.Type then continue end
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, "failed to encode data"
        end
        local writeOk, writeErr = pcall(writefile, fullPath, encoded)
        return writeOk, writeErr or "success"
    end

    function SaveManager:Load(name)
        if not name then
            return false, "no config file is selected"
        end
        self.CurrentConfig = name
        self.LoadingConfig = true
        SaveManager:CheckFolderTree()
        local file = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end
        if not isfile(file) then 
            self.LoadingConfig = false
            return false, "invalid file" 
        end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then 
            self.LoadingConfig = false
            return false, "decode error" 
        end
        if self.UseLoadingOrder == true and typeof(decoded.objects) == "table" and typeof(self.LoadingOrder) == "table" then
            table.sort(decoded.objects, function(a, b)
                local aIndex = table.find(self.LoadingOrder, a.type) or math.huge
                local bIndex = table.find(self.LoadingOrder, b.type) or math.huge
                return aIndex < bIndex
            end)
        end
        if decoded.objects then
            for _, option in decoded.objects do
                if not option.type then continue end
                if not self.Parser[option.type] then continue end
                if self.Ignore[option.idx] then continue end
                task.spawn(self.Parser[option.type].Load, option.idx, option)
            end
        end
        task.delay(1, function()
            self.LoadingConfig = false
        end)
        return true
    end

    function SaveManager:Delete(name)
        if (not name) then
            return false, "no config file is selected"
        end

        if self:GetAutoSaveConfig() == name then
            if self.Library.Options.SaveManager_AutoSave then
                self.Library.Options.SaveManager_AutoSave:SetValue(false)
            end
        end

        local file = self.Folder .. "/settings/" .. name .. ".json"
        if SaveManager:CheckSubFolder(true) then
            file = self.Folder .. "/settings/" .. self.SubFolder .. "/" .. name .. ".json"
        end

        if not isfile(file) then return false, "invalid file" end

        local success = pcall(delfile, file)
        if not success then return false, "delete file error" end

        return true
    end

    function SaveManager:RefreshConfigList()
        local success, data = pcall(function()
            SaveManager:CheckFolderTree()

            local list = {}
            local out = {}

            if SaveManager:CheckSubFolder(true) then
                list = listfiles(self.Folder .. "/settings/" .. self.SubFolder)
            else
                list = listfiles(self.Folder .. "/settings")
            end
            if typeof(list) ~= "table" then list = {} end

            for i = 1, #list do
                local file = list[i]
                if file:sub(-5) == ".json" then
                    local pos = file:find(".json", 1, true)
                    local start = pos

                    local char = file:sub(pos, pos)
                    while char ~= "/" and char ~= "\\" and char ~= "" do
                        pos = pos - 1
                        char = file:sub(pos, pos)
                    end

                    if char == "/" or char == "\\" then
                        table.insert(out, file:sub(pos + 1, start - 1))
                    end
                end
            end

            return out
        end)

        if (not success) then
            if self.Library then
                self.Library:Notify("Failed to load config list: " .. tostring(data))
            else
                warn("Failed to load config list: " .. tostring(data))
            end

            return {}
        end

        return data
    end

    -- // Auto Save \\ --
    function SaveManager:GetAutoSaveConfig()
        if self.AutoSaveConfigCached ~= nil then
            return self.AutoSaveConfigCached
        end

        SaveManager:CheckFolderTree()
        local autoSavePath = self.Folder .. "/settings/autosave.txt"
        if SaveManager:CheckSubFolder(true) then
            autoSavePath = self.Folder .. "/settings/" .. self.SubFolder .. "/autosave.txt"
        end
        if isfile(autoSavePath) then
            local successRead, name = pcall(readfile, autoSavePath)
            if not successRead then
                self.AutoSaveConfigCached = "none"
                return "none"
            end
            name = tostring(name)
            local result = if name == "" then "none" else name
            self.AutoSaveConfigCached = result
            return result
        end
        self.AutoSaveConfigCached = "none"
        return "none"
    end
    
    function SaveManager:SaveAutoSaveConfig(name)
        self.AutoSaveConfigCached = name
        SaveManager:CheckFolderTree()
        local autoSavePath = self.Folder .. "/settings/autosave.txt"
        if SaveManager:CheckSubFolder(true) then
            autoSavePath = self.Folder .. "/settings/" .. self.SubFolder .. "/autosave.txt"
        end
        local success = pcall(writefile, autoSavePath, name)
        if not success then return false, "write file error" end
        return true, ""
    end
    
    function SaveManager:DeleteAutoSaveConfig()
        self.AutoSaveConfigCached = "none"
        SaveManager:CheckFolderTree()
        local autoSavePath = self.Folder .. "/settings/autosave.txt"
        if SaveManager:CheckSubFolder(true) then
            autoSavePath = self.Folder .. "/settings/" .. self.SubFolder .. "/autosave.txt"
        end
        local success = pcall(delfile, autoSavePath)
        if not success then return false, "delete file error" end
        return true, ""
    end
    
    function SaveManager:HookElementChanges()
        local saveDebounce = nil

        local function triggerAutoSave()
            if self.LoadingConfig then
                return
            end
            local activeConfig = self:GetAutoSaveConfig()
            if not activeConfig or activeConfig == "none" then
                return
            end

            if saveDebounce then
                task.cancel(saveDebounce)
            end

            -- Fast 0.05 second delay to protect system disk I/O while maintaining instant responsiveness
            saveDebounce = task.delay(0.05, function()
                saveDebounce = nil
                local name = self:GetAutoSaveConfig()
                if name ~= "none" and self.CurrentConfig == name then
                    self:Save(name)
                end
            end)
        end

        local function hookElement(idx, element)
            if not element or type(element) ~= "table" or not element.SetValue then return end
            if element.HookedForAutoSave then return end
            element.HookedForAutoSave = true

            local originalSetValue = element.SetValue
            element.SetValue = function(selfObj, ...)
                originalSetValue(selfObj, ...)
                if SaveManager:GetAutoSaveConfig() ~= "none" then
                    triggerAutoSave()
                end
            end
        end

        -- Hook all existing toggles and options
        for idx, toggle in pairs(self.Library.Toggles) do
            hookElement(idx, toggle)
        end
        for idx, option in pairs(self.Library.Options) do
            hookElement(idx, option)
        end

        -- Establish metatable observers so any elements registered dynamically/late are auto-hooked
        local function setupObserver(tbl)
            local mt = getmetatable(tbl) or {}
            local originalNewIndex = mt.__newindex or rawset
            
            mt.__newindex = function(t, k, v)
                originalNewIndex(t, k, v)
                if typeof(v) == "table" then
                    hookElement(k, v)
                end
            end
            setmetatable(tbl, mt)
        end

        setupObserver(self.Library.Toggles)
        setupObserver(self.Library.Options)
    end

    function SaveManager:StartAutoSaveLoop(name)
        self.CurrentConfig = name
        self.LoadingConfig = false
        self:HookElementChanges()
    end

    function SaveManager:StopAutoSaveLoop()
    end
    --// Auto Load \\--
    function SaveManager:GetAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                return "none"
            end

            name = tostring(name)
            return if name == "" then "none" else name
        end

        return "none"
    end

    function SaveManager:LoadAutoloadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        if isfile(autoLoadPath) then
            local successRead, name = pcall(readfile, autoLoadPath)
            if not successRead then
                self.Library:Notify("Failed to load autoload config: write file error")
                return
            end

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify("Failed to load autoload config: " .. err)
                return
            end

            self.Library:Notify(string.format("Auto loaded config %q", name))
        end
    end

    function SaveManager:SaveAutoloadConfig(name)
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(writefile, autoLoadPath, name)
        if not success then return false, "write file error" end

        return true, ""
    end

    function SaveManager:DeleteAutoLoadConfig()
        SaveManager:CheckFolderTree()

        local autoLoadPath = self.Folder .. "/settings/autoload.txt"
        if SaveManager:CheckSubFolder(true) then
            autoLoadPath = self.Folder .. "/settings/" .. self.SubFolder .. "/autoload.txt"
        end

        local success = pcall(delfile, autoLoadPath)
        if not success then return false, "delete file error" end

        return true, ""
    end

    --// GUI \\--
    function SaveManager:BuildConfigSection(tab)
        assert(self.Library, "Must set SaveManager.Library")

        self.AutoSaveConfigLabel = nil
        self.AutoloadConfigLabel = nil

        local section = tab:AddRightGroupbox("Configuration", "folder-cog")

        section:AddInput("SaveManager_ConfigName", { Text = "Config name" })
        section:AddButton("Create config", function()
            local name = self.Library.Options.SaveManager_ConfigName.Value

            if name:gsub(" ", "") == "" then
                self.Library:Notify("Invalid config name (empty)", 2)
                return
            end

            local success, err = self:Save(name)
            if not success then
                self.Library:Notify("Failed to create config: " .. err)
                return
            end

            self.Library:Notify(string.format("Created config %q", name))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        section:AddDivider()

        section:AddDropdown("SaveManager_ConfigList", { Text = "Config list", Values = self:RefreshConfigList(), AllowNull = true })
        local ButtonG1 = section:AddButton("Save", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Save(name)
            if not success then
                self.Library:Notify("Failed to save config: " .. err)
                return
            end

            self.Library:Notify(string.format("Saved config %q", name))
        end)
        ButtonG1:AddButton("Load", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Load(name)
            if not success then
                self.Library:Notify("Failed to load config: " .. err)
                return
            end

            self.Library:Notify(string.format("Loaded config %q", name))
        end)

        section:AddToggle("SaveManager_AutoSave", {
            Text = "Auto Save Config",
            Default = self:GetAutoSaveConfig() ~= "none",
            Callback = function(state)
                if state then
                    local name = self:GetAutoSaveConfig()
                    if name == "none" then
                        name = self.Library.Options.SaveManager_ConfigList.Value
                    end
                    if not name or name == "" or name == "none" then
                        self.Library:Notify("Please select a config to auto-save.")
                        task.defer(function()
                            local opt = self.Library.Options.SaveManager_AutoSave
                            if opt then
                                opt:SetValue(false)
                            end
                        end)
                        return
                    end
                    self:SaveAutoSaveConfig(name)
                    if self.AutoSaveConfigLabel then
                        self.AutoSaveConfigLabel:SetText("Current auto-save config: " .. name)
                    end
                    self:StartAutoSaveLoop(name)
                else
                    self:DeleteAutoSaveConfig()
                    if self.AutoSaveConfigLabel then
                        self.AutoSaveConfigLabel:SetText("Current auto-save config: none")
                    end
                    self:StopAutoSaveLoop()
                end
            end
        })

        local ButtonG2 = section:AddButton("Refresh", function()
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)
        ButtonG2:AddButton("Delete", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:Delete(name)
            if not success then
                self.Library:Notify("Failed to delete config: " .. err)
                return
            end

            self.Library:Notify(string.format("Deleted config %q", name))
            self.Library.Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
            self.Library.Options.SaveManager_ConfigList:SetValue(nil)
        end)

        local ButtonG3 = section:AddButton("Set Autoload", function()
            local name = self.Library.Options.SaveManager_ConfigList.Value

            local success, err = self:SaveAutoloadConfig(name)
            if not success then
                self.Library:Notify("Failed to set autoload config: " .. err)
                return
            end

            self.Library:Notify(string.format("Set %q to auto load", name))
            if self.AutoloadConfigLabel then
                self.AutoloadConfigLabel:SetText("Current autoload config: " .. name)
            end
        end)
        ButtonG3:AddButton("Reset Autoload", function()
            local success, err = self:DeleteAutoLoadConfig()
            if not success then
                self.Library:Notify("Failed to set autoload config: " .. err)
                return
            end

            self.Library:Notify("Set autoload to none")
            if self.AutoloadConfigLabel then
                self.AutoloadConfigLabel:SetText("Current autoload config: none")
            end
        end)

        self.AutoSaveConfigLabel = section:AddLabel("Current auto-save config: " .. self:GetAutoSaveConfig(), true)
        self.AutoloadConfigLabel = section:AddLabel("Current autoload config: " .. self:GetAutoloadConfig(), true)

        local initialAutoSave = self:GetAutoSaveConfig()
        if initialAutoSave ~= "none" then
            self:StartAutoSaveLoop(initialAutoSave)
        end

        self:SetIgnoreIndexes({ "SaveManager_ConfigList", "SaveManager_ConfigName", "SaveManager_AutoSave" })
    end

    SaveManager:BuildFolderTree()
end

return SaveManager
