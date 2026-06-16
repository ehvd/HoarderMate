local ADDON_NAME = ...

HoarderMate = {}

-- Shared localization table (registered in Locales\; available to all modules and
-- to XML scripts via HoarderMate.L).
HoarderMate.L = LibStub("AceLocale-3.0"):GetLocale("HoarderMate")
local L = HoarderMate.L

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        print(L["Loaded"])
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
