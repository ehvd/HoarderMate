local ADDON_NAME = ...

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        print("HoarderMate loaded.")
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
