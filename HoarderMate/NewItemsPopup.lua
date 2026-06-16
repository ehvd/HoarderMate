local ROW_H = 22
local popupRows = {}

local L = HoarderMate.L

-- XML defines the button labels in English; localize them here.
HoarderMateNewItemsPopupAddBtn:SetText(L["AddAllButton"])
HoarderMateNewItemsPopupDismissBtn:SetText(L["DismissButton"])

local function ClearPopupRows()
    for _, r in ipairs(popupRows) do r:Hide() end
    popupRows = {}
end

function HoarderMate.ShowNewItemsPopup(bankerName, items)
    local popup   = HoarderMateNewItemsPopup
    local content = HoarderMateNewItemsPopupContent

    HoarderMateNewItemsPopupMessage:SetText(
        L["NewItemsMessage"]:format("|cffffd100" .. bankerName .. "|r"))

    -- (Re)builds the item rows from the current list. Each row has a remove "X"
    -- (styled like the RaidSummon name-list remove button) that drops the item so
    -- it won't be added to the banker config.
    local function RebuildRows()
        ClearPopupRows()
        local y = 0
        for i, itemID in ipairs(items) do
            local row = CreateFrame("Frame", nil, content)
            row:SetSize(content:GetWidth(), ROW_H)
            row:SetPoint("TOPLEFT", 0, -y)

            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(ROW_H - 2, ROW_H - 2)
            icon:SetPoint("LEFT", 0, 0)
            icon:SetTexture(C_Item.GetItemIconByID(itemID))

            local quality = select(3, GetItemInfo(itemID))
            local color   = ITEM_QUALITY_COLORS[quality or 1] or ITEM_QUALITY_COLORS[1]

            -- remove button: same style as RaidSummon's per-row remove "X"
            local removeBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            removeBtn:SetSize(20, 18)
            removeBtn:SetText("|TInterface\\Buttons\\UI-StopButton:0|t")
            removeBtn:SetNormalFontObject("GameFontNormalSmall")
            removeBtn:SetHighlightFontObject("GameFontHighlightSmall")
            removeBtn:SetDisabledFontObject("GameFontDisableSmall")
            removeBtn:SetPoint("RIGHT", 0, 0)
            removeBtn:SetScript("OnClick", function()
                table.remove(items, i)
                if #items == 0 then
                    popup:Hide()
                else
                    RebuildRows()
                end
            end)
            removeBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["RemoveTooltip"])
                GameTooltip:Show()
            end)
            removeBtn:SetScript("OnLeave", GameTooltip_Hide)

            local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            label:SetPoint("LEFT", icon, "RIGHT", 4, 0)
            label:SetPoint("RIGHT", removeBtn, "LEFT", -4, 0)
            label:SetJustifyH("LEFT")
            label:SetText(C_Item.GetItemNameByID(itemID) or L["ItemFallback"]:format(itemID))
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
    end

    RebuildRows()

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
