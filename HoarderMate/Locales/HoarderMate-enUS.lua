local L = LibStub("AceLocale-3.0"):NewLocale("HoarderMate", "enUS", true, true)
if not L then return end

-- Core
L["Loaded"] = "HoarderMate loaded."

-- Slash commands
L["CmdUsage"] = "usage:"
L["CmdAvailable"] = "Available commands:"
L["CmdPlaceholderCommand"] = "<command>"
L["CmdPlaceholderArgs"] = "<args>"
L["CmdConfigHelp"] = "open the banker configuration"
L["CmdHelpHelp"] = "show this help"

-- Mail panel
L["SendButton"] = "Send"
L["ConfigHint"] = "Click the cogwheel to configure\nbankers and items."
L["NothingToSend"] = "Nothing to send to any banker."
L["SettingsTooltip"] = "Settings"

-- New items popup
L["NewItemsMessage"] = "Items sent to %s not in their config:"
L["RemoveTooltip"] = "Remove"
L["AddAllButton"] = "Add All"
L["DismissButton"] = "Dismiss"

-- Banker config window
L["BankerConfigTitle"] = "Banker Configuration"
L["SelectBankerHint"] = "Select a banker\nto see their items."
L["NoItemSelected"] = "No item selected"
L["BankerPlaceholder"] = "Name-Realm"
L["ItemPlaceholder"] = "Item ID or link"

-- Shared
L["ItemFallback"] = "Item #%d"
