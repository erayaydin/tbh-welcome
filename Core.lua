-- Initialize TBHWelcome addon with Ace3 support and AceConsole-3.0, AceEvent-3.0 modules
---@class TBHWelcome: AceAddon
---@class TBHWelcome: AceConsole-3.0
---@class TBHWelcome: AceEvent-3.0
TBHWelcome = LibStub("AceAddon-3.0"):NewAddon("TBHWelcome", "AceConsole-3.0", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ADB = LibStub("AceDB-3.0")
local ADBO = LibStub("AceDBOptions-3.0")

local defaults = {
    profile = {
        debugMode = false,
        zoneMessage = "Welcome to $zone!",
        zoneShowOnScreen = true,
        homeMessage = "Home sweet home $home.",
        homeShowOnScreen = true,
    },
}

local options = {
    name = "TBHWelcome",
    handler = TBHWelcome,
    type = "group",
    args = {
        debugMode = {
            type = "toggle",
            name = "Debug",
            desc = "Enables debug mode.",
            get = "IsDebugMode",
            set = "ToggleDebugMode",
        },
        zone = {
            name = "Zone Change",
            type = "group",
            args = {
                zoneMessage = {
                    type = "input",
                    name = "Zone Message",
                    desc = "The message to be displayed when changing zone.",
                    usage = "Welcome to $zone!",
                    get = "GetZoneMessage",
                    set = "SetZoneMessage",
                },
                zoneShowOnScreen = {
                    type = "toggle",
                    name = "Show on Screen",
                    desc = "Toggles the display of the message on the screen.",
                    get = "IsZoneShowOnScreen",
                    set = "ToggleZoneShowOnScreen",
                },
            },
        },
        home = {
            name = "Home Zone",
            type = "group",
            args = {
                homeMessage = {
                    type = "input",
                    name = "Home Message",
                    desc = "The message to be displayed when you get to home (hearthstone) zone.",
                    usage = "Home sweet home $home!",
                    get = "GetHomeMessage",
                    set = "SetHomeMessage",
                },
                homeShowOnScreen = {
                    type = "toggle",
                    name = "Show on Screen",
                    desc = "Toggles the display of the message on the screen.",
                    get = "IsHomeShowOnScreen",
                    set = "ToggleHomeShowOnScreen",
                },
            },
        },
    },
}

-- Called when the addon is loaded
function TBHWelcome:OnInitialize()
    self.db = ADB:New("TBHWelcomeDB", defaults, true)

    AC:RegisterOptionsTable("TBHWelcome_Options", options)
    self.optionsFrame = ACD:AddToBlizOptions("TBHWelcome_Options", "TBHWelcome")

    local profiles = ADBO:GetOptionsTable(self.db)
    AC:RegisterOptionsTable("TBHWelcome_Profiles", profiles)
    ACD:AddToBlizOptions("TBHWelcome_Profiles", "Profiles", "TBHWelcome")

    if self.db.profile.debugMode then
        self:Print("Options registered!")
    end

    self:RegisterChatCommand("welcome", "MainCommand")

    if self.db.profile.debugMode then
        self:Print("/welcome command registered!")
    end
end

-- Called when the addon is enabled
function TBHWelcome:OnEnable()
    -- Register for `ZONE_CHANGED` event which trigger when player changing zone in world
	self:RegisterEvent("ZONE_CHANGED")

    if self.db.profile.debugMode then
        self:Print("Addon registered for ZONE_CHANGED event!")
    end
end

-- Called when the player changing zone in world
function TBHWelcome:ZONE_CHANGED()
    if self.db.profile.debugMode then
        self:Print("ZONE_CHANGED event triggered!")
    end

    -- Get current sub zone name
    local subzone = GetMinimapZoneText()
    if self.db.profile.debugMode then
        self:Print("Subzone:", subzone)
    end

    -- Get current hearthstone zone location
    local home = GetBindLocation()
    if self.db.profile.debugMode then
        self:Print("Home:", home)
    end

    local homeMessage = self.db.profile.homeMessage
    local zoneMessage = self.db.profile.zoneMessage
    if self.db.profile.debugMode then
        self:Print("Home Message:", self.db.profile.homeMessage)
        self:Print("Zone Message:", self.db.profile.zoneMessage)
    end

    -- Prepare message
    local message = (subzone == home and homeMessage:gsub("$home", home) or zoneMessage:gsub("$zone", subzone))
    if self.db.profile.debugMode then
        self:Print("Prepared Message:", message)
    end

    -- Check alert status
    local showInAlert = (subzone == home and self.db.profile.homeShowOnScreen) or (subzone ~= home and self.db.profile.zoneShowOnScreen)
    if self.db.profile.debugMode then
        self:Print("Show In Alert:", showInAlert)
    end

    -- Show message
    if showInAlert then
        UIErrorsFrame:AddMessage(message, 1, 1, 1)
    else
        self:Print(message)
    end
end

-- Called when the player used `/wa3` or `/welcomeace3` chat command
function TBHWelcome:MainCommand(args)
    if args == "current" then
        self:Print("Current zone message", self.db.profile.zoneMessage)
        self:Print("Current home message", self.db.profile.homeMessage)
    elseif not args or args:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        self:Print("Not a valid command!")
    end
end

-- Check debug mode
function TBHWelcome:IsDebugMode(_)
    return self.db.profile.debugMode
end

-- Toggle debug mode
function TBHWelcome:ToggleDebugMode(_, value)
    self.db.profile.debugMode = value
end

-- Get current stored zone message
function TBHWelcome:GetZoneMessage(_)
    return self.db.profile.zoneMessage
end

-- Set zone message
function TBHWelcome:SetZoneMessage(_, value)
    self.db.profile.zoneMessage = value
end

-- Get current stored home message
function TBHWelcome:GetHomeMessage(_)
    return self.db.profile.homeMessage
end

-- Set home message
function TBHWelcome:SetHomeMessage(_, value)
    self.db.profile.homeMessage = value
end

-- Check show on screen enabled for zone messages
function TBHWelcome:IsZoneShowOnScreen(_)
    return self.db.profile.zoneShowOnScreen
end

-- Toggle show on screen value for zone message
function TBHWelcome:ToggleZoneShowOnScreen(_, value)
    self.db.profile.zoneShowOnScreen = value
end

-- Check show on screen enabled for home messages
function TBHWelcome:IsHomeShowOnScreen(_)
    return self.db.profile.homeShowOnScreen
end

-- Toggle show on screen value for home message
function TBHWelcome:ToggleHomeShowOnScreen(_, value)
    self.db.profile.homeShowOnScreen = value
end