local ROW_H = 22

-- Local aliases for XML-defined frames
local win           = HoarderMateConfigWindow
local bankerContent = HoarderMateConfigBankerContent
local itemScroll    = HoarderMateConfigItemScroll
local itemContent   = HoarderMateConfigItemContent
local noSelection   = HoarderMateConfigNoSelection
local addBankerBox  = HoarderMateConfigAddBankerBox
local addBankerBtn  = HoarderMateConfigAddBankerBtn
local addItemBox    = HoarderMateConfigAddItemBox
local addItemBtn    = HoarderMateConfigAddItemBtn
local itemPreview   = HoarderMateConfigItemPreview

-- Placeholder texts (SearchBoxTemplate.Instructions can only be set via Lua)
addBankerBox.Instructions:SetText("Name-Realm")
addItemBox.Instructions:SetText("Item ID or link")

-- Icon texture for the item preview (created via Lua; XML Frame child can't have bare Textures)
local itemPreviewIcon = HoarderMateConfigItemPreviewIcon:CreateTexture(nil, "ARTWORK")
itemPreviewIcon:SetAllPoints()
local itemPreviewName = HoarderMateConfigItemPreviewName

local PREVIEW_EMPTY_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function UpdateItemPreview(raw)
    raw = strtrim(raw or "")
    local itemID = tonumber(raw) or tonumber(raw:match("item:(%d+)"))
    if not itemID and raw ~= "" then
        local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, id = GetItemInfo(raw)
        if name then itemID = id end
    end

    if itemID then
        local name    = C_Item.GetItemNameByID(itemID)
        local icon    = C_Item.GetItemIconByID(itemID)
        local quality = select(3, GetItemInfo(itemID))
        local color   = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]
        if name and icon then
            itemPreviewIcon:SetTexture(icon)
            itemPreviewName:SetText(name)
            itemPreviewName:SetTextColor(color.r, color.g, color.b)
            return
        end
    end

    itemPreviewIcon:SetTexture(PREVIEW_EMPTY_ICON)
    itemPreviewName:SetText("|cff808080No item selected|r")
end

-------------------------------------------------------------------------------
-- DB helpers
-------------------------------------------------------------------------------
local function DB()
    HoarderMateDB.bankers = HoarderMateDB.bankers or {}
    return HoarderMateDB.bankers
end

local function AddBanker(name)
    if name == "" then return end
    DB()[name] = DB()[name] or { items = {} }
end

local function RemoveBanker(name)
    DB()[name] = nil
end

local function AddItem(banker, itemID)
    if DB()[banker] then DB()[banker].items[itemID] = true end
end

local function RemoveItem(banker, itemID)
    if DB()[banker] then DB()[banker].items[itemID] = nil end
end

-------------------------------------------------------------------------------
-- Toggle
-------------------------------------------------------------------------------
function HoarderMate.ToggleConfigWindow()
    if win:IsShown() then
        win:Hide()
    else
        HoarderMateDB = HoarderMateDB or {}
        win:Show()
    end
end

-------------------------------------------------------------------------------
-- Dynamic row builders
-------------------------------------------------------------------------------
local selectedBanker = nil
local bankerRows     = {}
local itemRows       = {}

local function RefreshItems()
    for _, r in ipairs(itemRows) do r:Hide() end
    itemRows = {}

    if not selectedBanker or not DB()[selectedBanker] then
        noSelection:Show()
        itemContent:SetHeight(1)
        return
    end
    noSelection:Hide()

    local idx = 0
    for itemID in pairs(DB()[selectedBanker].items) do
        idx = idx + 1
        local row = CreateFrame("Frame", nil, itemContent)
        row:SetSize(itemContent:GetWidth() - 24, ROW_H)
        row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_H)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(ROW_H - 2, ROW_H - 2)
        icon:SetPoint("LEFT", 1, 0)
        icon:SetTexture(C_Item.GetItemIconByID(itemID))

        local quality = select(3, GetItemInfo(itemID))
        local color   = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        label:SetWidth(row:GetWidth() - ROW_H - 28)
        label:SetJustifyH("LEFT")
        label:SetText(C_Item.GetItemNameByID(itemID) or "Item #" .. itemID)
        label:SetTextColor(color.r, color.g, color.b)

        local remove = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        remove:SetSize(18, 18)
        remove:SetPoint("RIGHT", 0, 0)
        remove:SetScript("OnClick", function()
            RemoveItem(selectedBanker, itemID)
            RefreshItems()
        end)

        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. itemID)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", GameTooltip_Hide)

        row:Show()
        itemRows[idx] = row
    end
    itemContent:SetHeight(math.max(idx * ROW_H, 1))
end

local function RefreshBankers()
    for _, r in ipairs(bankerRows) do r:Hide() end
    bankerRows = {}

    local idx = 0
    for name in pairs(DB()) do
        idx = idx + 1
        local row = CreateFrame("Button", nil, bankerContent)
        row:SetSize(bankerContent:GetWidth(), ROW_H)
        row:SetPoint("TOPLEFT", 0, -(idx - 1) * ROW_H)

        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", 4, 0)
        label:SetPoint("RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        label:SetText(name)

        local function UpdateHighlight()
            if selectedBanker == name then
                bg:SetColorTexture(0.2, 0.5, 1, 0.3)
            elseif row:IsMouseOver() then
                bg:SetColorTexture(1, 1, 1, 0.1)
            else
                bg:SetColorTexture(0, 0, 0, 0)
            end
        end

        row:SetScript("OnClick", function()
            selectedBanker = name
            RefreshBankers()
            RefreshItems()
        end)
        row:SetScript("OnEnter", UpdateHighlight)
        row:SetScript("OnLeave", UpdateHighlight)
        UpdateHighlight()

        bankerRows[idx] = row
    end
    bankerContent:SetHeight(math.max(idx * ROW_H, 1))
end

-------------------------------------------------------------------------------
-- Scripts
-------------------------------------------------------------------------------
win:HookScript("OnShow", function()
    selectedBanker = nil
    noSelection:Show()
    UpdateItemPreview("")
    RefreshBankers()
    RefreshItems()
end)

addBankerBtn:SetScript("OnClick", function()
    local name = strtrim(addBankerBox:GetText())
    AddBanker(name)
    addBankerBox:SetText("")
    RefreshBankers()
end)

local function TryAddItemByText(raw)
    if not selectedBanker or raw == "" then return end
    local itemID = tonumber(raw) or tonumber(raw:match("item:(%d+)"))
    if not itemID then
        -- Try resolving by name — works if the item is in the client cache
        local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, id = GetItemInfo(raw)
        if name then itemID = id end
    end
    if itemID then
        AddItem(selectedBanker, itemID)
        addItemBox:SetText("")
        RefreshItems()
    end
end

HoarderMateConfigItemPreviewIcon:SetScript("OnReceiveDrag", function()
    local dragType, itemID = GetCursorInfo()
    if dragType == "item" then
        addItemBox:SetText(tostring(itemID))
        ClearCursor()
    end
end)
HoarderMateConfigItemPreviewIcon:SetScript("OnMouseDown", function()
    local dragType, itemID = GetCursorInfo()
    if dragType == "item" then
        addItemBox:SetText(tostring(itemID))
        ClearCursor()
    end
end)

addItemBox:HookScript("OnTextChanged", function(self)
    UpdateItemPreview(self:GetText())
end)

addItemBox:SetScript("OnReceiveDrag", function(self)
    local dragType, itemID = GetCursorInfo()
    if dragType == "item" then
        self:SetText(itemID)
        ClearCursor()
    end
end)

addItemBox:SetScript("OnEnterPressed", function(self)
    TryAddItemByText(strtrim(self:GetText()))
end)

addItemBtn:SetScript("OnClick", function()
    TryAddItemByText(strtrim(addItemBox:GetText()))
end)

-- Intercept ctrl-clicks on bag items while the add-item box is focused
local origHandleModifiedItemClick = HandleModifiedItemClick
function HandleModifiedItemClick(link)
    if addItemBox:HasFocus() and IsControlKeyDown() and link then
        local itemID = tonumber(link:match("item:(%d+)"))
        if itemID then
            addItemBox:SetText(tostring(itemID))
            return
        end
    end
    return origHandleModifiedItemClick(link)
end
