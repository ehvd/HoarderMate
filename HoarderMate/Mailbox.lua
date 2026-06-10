HoarderMate.mailPanel = HoarderMatePanel

-- MailFrameTab3 properties that cannot be set in XML
MailFrameTab3.index = 3
PanelTemplates_SetNumTabs(MailFrame, 3)

local hmPanelOpen = false

local function ShowNativeContent()
    HoarderMatePanel:Hide()
    HoarderMateConfigButton:Hide()
end

local function ShowHMPanel()
    SendMailFrame:Hide()
    InboxFrame:Hide()
    HoarderMatePanel:Show()
    HoarderMateConfigButton:Show()
end

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

MailFrameTab3:SetScript("OnClick", function()
    SetTabActive(true)
end)


HoarderMateConfigButton:SetScript("OnClick", function()
    HoarderMate.ToggleConfigWindow()
end)

SendMailFrame:HookScript("OnShow", function()
    if hmPanelOpen then SetTabActive(false) end
end)
InboxFrame:HookScript("OnShow", function()
    if hmPanelOpen then SetTabActive(false) end
end)

local function OnMailboxOpen()
    MailFrameTab3:Show()
    SetTabActive(false)
end

local function OnMailboxClose()
    MailFrameTab3:Hide()
    hmPanelOpen = false
    HoarderMatePanel:Hide()
    HoarderMateConfigButton:Hide()
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
