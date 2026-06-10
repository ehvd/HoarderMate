local ADDON_NAME = ...

-- Loaded message
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == ADDON_NAME then
        print("HoarderMate loaded.")
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Panel that replaces the mail content area
local hmPanel = CreateFrame("Frame", "HoarderMatePanel", MailFrame)
hmPanel:SetAllPoints(MailFrameInset)
hmPanel:Hide()

local title = hmPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -16)
title:SetText("HoarderMate")

local subtitle = hmPanel:CreateFontString(nil, "OVERLAY", "GameFontDisable")
subtitle:SetPoint("TOP", title, "BOTTOM", 0, -6)
subtitle:SetText("Addon features coming soon.")

local function ShowNativeContent()
    hmPanel:Hide()
end

local function ShowHMPanel()
    SendMailFrame:Hide()
    InboxFrame:Hide()
    hmPanel:Show()
end

-- Tab button on the mailbox
local mailTab = CreateFrame("Button", "MailFrameTab3", MailFrame, "CharacterFrameTabButtonTemplate")
mailTab:SetText("HoarderMate")
mailTab:SetPoint("LEFT", MailFrameTab2, "RIGHT", -8, 0)
mailTab.index = 3
PanelTemplates_SetNumTabs(MailFrame, 3)

local hmPanelOpen = false

local function SetTabActive(active)
    hmPanelOpen = active
    if active then
        PanelTemplates_SetTab(MailFrame, 3)
        ShowHMPanel()
    else
        PanelTemplates_SetTab(MailFrame, MailFrame.selectedTab or 1)
        ShowNativeContent()
    end
end

mailTab:SetScript("OnClick", function()
    SetTabActive(true)
end)

-- Restore native content when a native tab is clicked
SendMailFrame:HookScript("OnShow", function()
    if hmPanelOpen then SetTabActive(false) end
end)
InboxFrame:HookScript("OnShow", function()
    if hmPanelOpen then SetTabActive(false) end
end)

local function OnMailboxOpen()
    mailTab:Show()
    SetTabActive(false)
end

local function OnMailboxClose()
    mailTab:Hide()
    hmPanelOpen = false
    hmPanel:Hide()
end

local mailEvents = CreateFrame("Frame")
mailEvents:RegisterEvent("MAIL_SHOW")
mailEvents:RegisterEvent("MAIL_CLOSED")
mailEvents:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" then
        OnMailboxOpen()
    elseif event == "MAIL_CLOSED" then
        OnMailboxClose()
    end
end)
