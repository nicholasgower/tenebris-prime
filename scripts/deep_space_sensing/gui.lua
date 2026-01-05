--- Deep Space Sensing GUI Module
--- Provides button to open the planetary discovery interface.
---
--- @module deep_space_sensing.gui

local constants = require("scripts.deep_space_sensing.constants")
local discovery_gui = require("scripts.deep_space_sensing.planetary_discovery_gui")

local gui = {}

local BUTTON_NAME = constants.GUI.BUTTON_NAME

--- Creates or updates the deep space sensing button
--- @param player LuaPlayer The player to create the GUI for
function gui.create_button(player)
    local button_flow = player.gui.top
    
    -- Don't create if it already exists
    if button_flow[BUTTON_NAME] then
        return
    end
    
    -- Only show if deep-space-sensing is researched
    if not player.force.technologies[constants.UNLOCK_TECHNOLOGY] or 
       not player.force.technologies[constants.UNLOCK_TECHNOLOGY].researched then
        return
    end
    
    button_flow.add{
        type = "sprite-button",
        name = BUTTON_NAME,
        sprite = "item/radar",
        tooltip = {"deep-space-sensing.open-planetary-discovery"},
        style = "slot_button"
    }
end

--- Removes the deep space sensing button for a player
--- @param player LuaPlayer The player to remove the GUI for
function gui.destroy_button(player)
    local button = player.gui.top[BUTTON_NAME]
    if button and button.valid then
        button.destroy()
    end
end

--- Handler for GUI click events
--- @param event EventData The GUI click event
function gui.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end
    if event.element.name == BUTTON_NAME then
        discovery_gui.toggle_gui(game.players[event.player_index])
    end
end

--- Handler for player creation - sets up GUI
--- @param event EventData The player created event
function gui.on_player_created(event)
    local player = game.players[event.player_index]
    gui.create_button(player)
end

--- Handler for research finished - creates GUI when tech is researched
--- @param event EventData The research finished event
function gui.on_research_finished(event)
    if event.research.name == constants.UNLOCK_TECHNOLOGY then
        for _, player in pairs(event.research.force.players) do
            gui.create_button(player)
        end
    end
end

--- Initialize GUI for all existing players (on_configuration_changed)
function gui.initialize_all_players()
    for _, player in pairs(game.players) do
        gui.create_button(player)
    end
end

return gui

