HoarderMate.mailPanel = HoarderMatePanel

-- MailFrameTab3 properties that cannot be set in XML
MailFrameTab3.index = 3
PanelTemplates_SetNumTabs(MailFrame, 3)

local hmPanelOpen = false

-------------------------------------------------------------------------------
-- Send list
-------------------------------------------------------------------------------
local SEND_ROW_H = 20
local sendRows   = {}

local function ClearSendRows()
    for _, r in ipairs(sendRows) do r:Hide() end
    sendRows = {}
end

local function GetSendableItems()
    if not HoarderMateDB or not HoarderMateDB.bankers then return {} end
    local result = {}
    for bankerName, bankerData in pairs(HoarderMateDB.bankers) do
        for itemID in pairs(bankerData.items) do
            local count = 0
            for bag = 0, 4 do
                local slots = C_Container.GetContainerNumSlots(bag)
                for slot = 1, slots do
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    if info and info.itemID == itemID then
                        count = count + (info.stackCount or 1)
                    end
                end
            end
            if count > 0 then
                result[bankerName] = result[bankerName] or {}
                result[bankerName][itemID] = count
            end
        end
    end
    return result
end

local function StageMailForBanker(bankerName, items)
    -- Switch to Send Mail tab
    hmPanelOpen = false
    HoarderMatePanel:Hide()
    HoarderMateConfigButton:Hide()
    PanelTemplates_SetTab(MailFrame, 1)
    SendMailFrame:Show()
    InboxFrame:Hide()

    -- Pre-fill recipient
    SendMailNameEditBox:SetText(bankerName)

    -- Attach items from bags (up to max attachment slots)
    local attachSlot = 1
    for itemID in pairs(items) do
        if attachSlot > ATTACHMENTS_MAX_SEND then break end
        for bag = 0, 4 do
            if attachSlot > ATTACHMENTS_MAX_SEND then break end
            local slots = C_Container.GetContainerNumSlots(bag)
            for slot = 1, slots do
                if attachSlot > ATTACHMENTS_MAX_SEND then break end
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info and info.itemID == itemID then
                    C_Container.PickupContainerItem(bag, slot)
                    ClickSendMailItemButton(attachSlot)
                    attachSlot = attachSlot + 1
                    break
                end
            end
        end
    end
end

local function BuildSendRows(sendable)
    local content = HoarderMatePanelSendContent
    local y = 0

    for bankerName, items in pairs(sendable) do
        -- Banker header
        local header = CreateFrame("Frame", nil, content)
        header:SetSize(content:GetWidth(), SEND_ROW_H)
        header:SetPoint("TOPLEFT", 0, -y)

        local headerBg = header:CreateTexture(nil, "BACKGROUND")
        headerBg:SetAllPoints()
        headerBg:SetColorTexture(0.15, 0.15, 0.15, 0.9)

        local headerLabel = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        headerLabel:SetPoint("LEFT", 4, 0)
        headerLabel:SetText(bankerName)

        local sendBtn = CreateFrame("Button", nil, header, "UIPanelButtonTemplate")
        sendBtn:SetSize(50, SEND_ROW_H - 2)
        sendBtn:SetPoint("RIGHT", -2, 0)
        sendBtn:SetText("Send")
        sendBtn:SetScript("OnClick", function()
            StageMailForBanker(bankerName, items)
        end)

        header:Show()
        sendRows[#sendRows + 1] = header
        y = y + SEND_ROW_H

        for itemID, count in pairs(items) do
            local row = CreateFrame("Frame", nil, content)
            row:SetSize(content:GetWidth(), SEND_ROW_H)
            row:SetPoint("TOPLEFT", 0, -y)

            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(SEND_ROW_H - 2, SEND_ROW_H - 2)
            icon:SetPoint("LEFT", 16, 0)
            icon:SetTexture(C_Item.GetItemIconByID(itemID))

            local quality = select(3, GetItemInfo(itemID))
            local color   = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]

            local itemLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            itemLabel:SetPoint("LEFT", icon, "RIGHT", 4, 0)
            itemLabel:SetWidth(content:GetWidth() - 16 - SEND_ROW_H - 40)
            itemLabel:SetJustifyH("LEFT")
            itemLabel:SetText(C_Item.GetItemNameByID(itemID) or "Item #" .. itemID)
            itemLabel:SetTextColor(color.r, color.g, color.b)

            local countLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            countLabel:SetPoint("RIGHT", -4, 0)
            countLabel:SetText("x" .. count)

            row:EnableMouse(true)
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink("item:" .. itemID)
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", GameTooltip_Hide)

            row:Show()
            sendRows[#sendRows + 1] = row
            y = y + SEND_ROW_H
        end
    end

    content:SetHeight(math.max(y, 1))
end

local function RefreshSendList()
    ClearSendRows()

    local hasBankers = HoarderMateDB
        and HoarderMateDB.bankers
        and next(HoarderMateDB.bankers) ~= nil

    if not hasBankers then
        HoarderMatePanelLabel:Show()
        HoarderMatePanelSublabel:SetText("Click the cogwheel to configure\nbankers and items.")
        HoarderMatePanelSublabel:Show()
        HoarderMatePanelSendScroll:Hide()
        return
    end

    local sendable = GetSendableItems()

    if not next(sendable) then
        HoarderMatePanelLabel:Hide()
        HoarderMatePanelSublabel:SetText("Nothing to send to any banker.")
        HoarderMatePanelSublabel:Show()
        HoarderMatePanelSendScroll:Hide()
    else
        HoarderMatePanelLabel:Hide()
        HoarderMatePanelSublabel:Hide()
        BuildSendRows(sendable)
        HoarderMatePanelSendScroll:Show()
    end
end

-------------------------------------------------------------------------------
-- Tab / panel switching
-------------------------------------------------------------------------------
local function ShowNativeContent()
    HoarderMatePanel:Hide()
    HoarderMateConfigButton:Hide()
end

local function ShowHMPanel()
    SendMailFrame:Hide()
    InboxFrame:Hide()
    HoarderMatePanel:Show()
    HoarderMateConfigButton:Show()
    RefreshSendList()
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

-------------------------------------------------------------------------------
-- Unconfigured items detection
-------------------------------------------------------------------------------
local pendingSend     = nil
local sendButtonHooked = false

local function FindBanker(recipient)
    local bankers = HoarderMateDB and HoarderMateDB.bankers
    if not bankers then return nil, nil end
    if bankers[recipient] then return recipient, bankers[recipient] end
    local recipientName = (recipient:match("^([^%-]+)") or recipient):lower()
    for name, data in pairs(bankers) do
        if (name:match("^([^%-]+)") or name):lower() == recipientName then
            return name, data
        end
    end
    return nil, nil
end

local function CapturePendingSend()
    pendingSend = nil

    local recipient = strtrim(SendMailNameEditBox:GetText())
    if recipient == "" then return end

    local bankerName, bankerData = FindBanker(recipient)
    if not bankerData then return end

    local unconfigured = {}
    for slot = 1, ATTACHMENTS_MAX_SEND do
        local _, itemID = GetSendMailItem(slot)
        if itemID and not bankerData.items[itemID] then
            unconfigured[#unconfigured + 1] = itemID
        end
    end

    if #unconfigured > 0 then
        pendingSend = { bankerName = bankerName, items = unconfigured }
    end
end

local function OnMailSent()
    if pendingSend then
        HoarderMate.ShowNewItemsPopup(pendingSend.bankerName, pendingSend.items)
        pendingSend = nil
    end
end

local function HookSendButton()
    if sendButtonHooked then return end
    if SendMailMailButton then
        SendMailMailButton:HookScript("OnClick", CapturePendingSend)
        sendButtonHooked = true
    end
end

-------------------------------------------------------------------------------
-- Mailbox events
-------------------------------------------------------------------------------
local function OnMailboxOpen()
    HookSendButton()
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
mailEvents:RegisterEvent("BAG_UPDATE_DELAYED")
mailEvents:RegisterEvent("MAIL_SEND_SUCCESS")
mailEvents:SetScript("OnEvent", function(self, event)
    if event == "MAIL_SHOW" then
        OnMailboxOpen()
    elseif event == "MAIL_CLOSED" then
        OnMailboxClose()
    elseif event == "BAG_UPDATE_DELAYED" and hmPanelOpen then
        RefreshSendList()
    elseif event == "MAIL_SEND_SUCCESS" then
        OnMailSent()
    end
end)
