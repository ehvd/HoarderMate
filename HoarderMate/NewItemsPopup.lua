local ROW_H = 22
local popupRows = {}

local function ClearPopupRows()
    for _, r in ipairs(popupRows) do r:Hide() end
    popupRows = {}
end

function HoarderMate.ShowNewItemsPopup(bankerName, items)
    local popup   = HoarderMateNewItemsPopup
    local content = HoarderMateNewItemsPopupContent

    ClearPopupRows()

    HoarderMateNewItemsPopupMessage:SetText(
        "Items sent to |cffffd100" .. bankerName .. "|r not in their config:")

    local y = 0
    for _, itemID in ipairs(items) do
        local row = CreateFrame("Frame", nil, content)
        row:SetSize(content:GetWidth(), ROW_H)
        row:SetPoint("TOPLEFT", 0, -y)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(ROW_H - 2, ROW_H - 2)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(C_Item.GetItemIconByID(itemID))

        local quality = select(3, GetItemInfo(itemID))
        local color   = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        label:SetPoint("RIGHT", 0, 0)
        label:SetJustifyH("LEFT")
        label:SetText(C_Item.GetItemNameByID(itemID) or "Item #" .. itemID)
        label:SetTextColor(color.r, color.g, color.b)

        row:EnableMouse(true)
        row:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink("item:" .. itemID)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", GameTooltip_Hide)

        row:Show()
        popupRows[#popupRows + 1] = row
        y = y + ROW_H
    end
    content:SetHeight(math.max(y, 1))

    HoarderMateNewItemsPopupAddBtn:SetScript("OnClick", function()
        for _, itemID in ipairs(items) do
            HoarderMate.AddItemToBanker(bankerName, itemID)
        end
        popup:Hide()
    end)

    HoarderMateNewItemsPopupDismissBtn:SetScript("OnClick", function()
        popup:Hide()
    end)

    popup:Show()
    popup:Raise()
end
