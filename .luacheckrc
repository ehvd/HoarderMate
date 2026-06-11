std = "lua51"
max_line_length = false
ignore = {
    "212", -- unused argument (self in callbacks)
    "213", -- unused loop variable
}

-- Globals written by this addon
globals = {
    "HoarderMate",
    "HoarderMateDB",
    "HandleModifiedItemClick",
    "OnMailSent",
}

-- WoW API and frame globals (read-only from luacheck's perspective)
read_globals = {
    -- Core API
    "CreateFrame",
    "UIParent",
    "GetItemInfo",
    "GetCursorInfo",
    "ClearCursor",
    "strtrim",
    "IsControlKeyDown",
    "GameTooltip_Hide",
    "GameTooltip",
    -- Mail API
    "GetSendMailItem",
    "ClickSendMailItemButton",
    "ATTACHMENTS_MAX_SEND",
    -- Panel templates
    "PanelTemplates_SetTab",
    "PanelTemplates_SetNumTabs",
    -- Item
    "ITEM_QUALITY_COLORS",
    "C_Container",
    "C_Item",
    -- Native mail frames
    "MailFrame",
    "MailFrameInset",
    "MailFrameCloseButton",
    "MailFrameTab2",
    "MailFrameTab3",
    "SendMailFrame",
    "SendMailNameEditBox",
    "SendMailMailButton",
    "InboxFrame",
    -- HoarderMate mailbox frames
    "HoarderMatePanel",
    "HoarderMatePanelLabel",
    "HoarderMatePanelSublabel",
    "HoarderMatePanelSendScroll",
    "HoarderMatePanelSendContent",
    "HoarderMateConfigButton",
    "HoarderMateConfigButtonGear",
    -- HoarderMate config window frames
    "HoarderMateConfigWindow",
    "HoarderMateConfigBankerScroll",
    "HoarderMateConfigBankerContent",
    "HoarderMateConfigItemScroll",
    "HoarderMateConfigItemContent",
    "HoarderMateConfigNoSelection",
    "HoarderMateConfigAddBankerBox",
    "HoarderMateConfigAddBankerBtn",
    "HoarderMateConfigAddItemBox",
    "HoarderMateConfigAddItemBtn",
    "HoarderMateConfigItemPreview",
    "HoarderMateConfigItemPreviewIcon",
    "HoarderMateConfigItemPreviewName",
    -- HoarderMate new items popup frames
    "HoarderMateNewItemsPopup",
    "HoarderMateNewItemsPopupContent",
    "HoarderMateNewItemsPopupMessage",
    "HoarderMateNewItemsPopupAddBtn",
    "HoarderMateNewItemsPopupDismissBtn",
}
