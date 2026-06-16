-- Commands.lua
-- Slash-command handling for /hm and /hoardermate.
--
-- AceConsole-3.0 registers the slash commands and parses arguments (the Ace3 way);
-- a small dispatch table routes each subcommand to its handler. Adding a new
-- command is a single RegisterCommand(name, handler, help) call -- see the
-- "Command handlers" section near the bottom. (Pattern modelled on AllTheThings'
-- ChatCommands dispatch table.)

LibStub("AceConsole-3.0"):Embed(HoarderMate)

-- Slash aliases that open the command parser (e.g. /hm, /hoardermate).
-- Add or edit entries here -- no leading slash.
local SLASH_ALIASES = { "hm", "hoardermate" }

-- subcommand name (lowercase) -> { handler = function(args), help = "..." }
local commands     = {}
local commandOrder = {}

--- Register a subcommand handler.
-- @param names   command string, or a list of {alias1, alias2, ...}
-- @param handler function(args) -- args is the remaining input after the command
-- @param help    short description shown in the help listing
local function RegisterCommand(names, handler, help)
    if type(names) ~= "table" then names = { names } end
    local entry = { handler = handler, help = help }
    for _, name in ipairs(names) do
        commands[name:lower()] = entry
    end
    commandOrder[#commandOrder + 1] = names[1]:lower()
end

-- Builds e.g. "|cffffd100/hm|r, |cffffd100/homa|r, or |cffffd100/hoardermate|r"
-- from SLASH_ALIASES, with an Oxford "or" before the last entry.
local function FormatAliases()
    local parts = {}
    for _, alias in ipairs(SLASH_ALIASES) do
        parts[#parts + 1] = "|cffffd100/" .. alias .. "|r"
    end
    local n = #parts
    if n <= 1 then
        return parts[1] or ""
    elseif n == 2 then
        return parts[1] .. " or " .. parts[2]
    end
    return table.concat(parts, ", ", 1, n - 1) .. ", or " .. parts[n]
end

local function PrintHelp()
    print("|cffffd100HoarderMate|r usage:")
    print(FormatAliases() .. " |cff00ff00<command>|r |cff00ffff<args>|r")
    print("|cffffd100Available commands:|r")
    local prefix = "/" .. SLASH_ALIASES[1]
    for _, name in ipairs(commandOrder) do
        print(("  |cffffd100%s|r |cff00ff00%s|r - %s"):format(prefix, name, commands[name].help or ""))
    end
end

--- Dispatcher registered with AceConsole: split off the first word and route it.
function HoarderMate:ChatCommand(input)
    local cmd, nextPos = self:GetArgs(input, 1)
    local entry = cmd and commands[cmd:lower()]
    if entry then
        entry.handler(input:sub(nextPos))
    else
        PrintHelp()
    end
end

-------------------------------------------------------------------------------
-- Command handlers -- add new commands here
-------------------------------------------------------------------------------
RegisterCommand("config", function(args)
    HoarderMate.ToggleConfigWindow()
end, "open the banker configuration")

RegisterCommand({ "help", "?" }, function(args)
    PrintHelp()
end, "show this help")

-------------------------------------------------------------------------------
for _, alias in ipairs(SLASH_ALIASES) do
    HoarderMate:RegisterChatCommand(alias, "ChatCommand")
end
