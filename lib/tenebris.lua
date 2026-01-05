--- Tenebris Prime Central Namespace
--- Provides centralized access to all mod systems and shared constants.
--- Use this for scripting, debugging, and cross-module references.
---
--- NOTE: This module is CONTROL STAGE ONLY (requires defines.events).
--- For data stage, use require("lib.constants") directly.
---
--- @module tenebris

-- Import shared constants (works in both stages)
local constants = require("lib.constants")

local tenebris = {}

--#region Import Shared Constants

-- Re-export all shared constants
tenebris.PLANET = constants.PLANET
tenebris.SPACE_LOCATION = constants.SPACE_LOCATION
tenebris.ALL_TENEBRIS_LOCATIONS = constants.ALL_TENEBRIS_LOCATIONS
tenebris.TICKS = constants.TICKS
tenebris.TINT = constants.TINT
tenebris.ABSORPTION = constants.ABSORPTION
tenebris.SPORE = constants.SPORE
tenebris.CARGO_CORROSION = constants.CARGO_CORROSION
tenebris.PRIORITY = constants.PRIORITY
tenebris.QUARTZ_FOREST = constants.QUARTZ_FOREST
tenebris.CRYSTAL_TYPES = constants.CRYSTAL_TYPES
tenebris.CRYSTAL_TYPES_LIST = constants.CRYSTAL_TYPES_LIST
tenebris.ITEM = constants.ITEM
tenebris.ENTITY = constants.ENTITY

--#endregion

--#region Control-Stage Only: Events

--- Lifecycle event identifiers (for event_manager.subscribe)
--- CONTROL STAGE ONLY - requires defines.events
tenebris.EVENTS = {
    -- Lifecycle events (use strings, not defines.events)
    ON_INIT = "on_init",
    ON_LOAD = "on_load",
    ON_CONFIGURATION_CHANGED = "on_configuration_changed",
    
    -- Tick event
    ON_TICK = defines.events.on_tick,
    
    -- Commonly used standard events (convenience wrappers)
    ON_BUILT_ENTITY = defines.events.on_built_entity,
    ON_ROBOT_BUILT_ENTITY = defines.events.on_robot_built_entity,
    ON_PLAYER_MINED_ENTITY = defines.events.on_player_mined_entity,
    ON_ROBOT_MINED_ENTITY = defines.events.on_robot_mined_entity,
    ON_ENTITY_DIED = defines.events.on_entity_died,
    ON_ENTITY_CLONED = defines.events.on_entity_cloned,
    ON_PLAYER_ROTATED_ENTITY = defines.events.on_player_rotated_entity,
    ON_PLAYER_FLIPPED_ENTITY = defines.events.on_player_flipped_entity,
    ON_POST_ENTITY_DIED = defines.events.on_post_entity_died,
    ON_RESEARCH_FINISHED = defines.events.on_research_finished,
    ON_PLAYER_CREATED = defines.events.on_player_created,
    ON_SURFACE_CREATED = defines.events.on_surface_created,
    ON_PLAYER_CHANGED_SURFACE = defines.events.on_player_changed_surface,
    ON_CARGO_POD_FINISHED_ASCENDING = defines.events.on_cargo_pod_finished_ascending,
    ON_CARGO_POD_FINISHED_DESCENDING = defines.events.on_cargo_pod_finished_descending,
    SCRIPT_RAISED_BUILT = defines.events.script_raised_built,
    SCRIPT_RAISED_DESTROY = defines.events.script_raised_destroy,
    SCRIPT_RAISED_REVIVE = defines.events.script_raised_revive,
    ON_TRIGGER_CREATED_ENTITY = defines.events.on_trigger_created_entity,
    ON_CHUNK_GENERATED = defines.events.on_chunk_generated,
    ON_ENTITY_SPAWNED = defines.events.on_entity_spawned,
    ON_SCRIPT_RAISED_BUILT = defines.events.script_raised_built,
    ON_GUI_OPENED = defines.events.on_gui_opened,
    ON_GUI_CLICK = defines.events.on_gui_click,
    ON_GUI_CLOSED = defines.events.on_gui_closed,
    ON_GUI_TEXT_CHANGED = defines.events.on_gui_text_changed,
    ON_GUI_ELEM_CHANGED = defines.events.on_gui_elem_changed,
    ON_GUI_SWITCH_STATE_CHANGED = defines.events.on_gui_switch_state_changed,
    ON_ENTITY_SETTINGS_PASTED = defines.events.on_entity_settings_pasted,
    ON_SELECTED_ENTITY_CHANGED = defines.events.on_selected_entity_changed,
    ON_PLAYER_SETUP_BLUEPRINT = defines.events.on_player_setup_blueprint,
}

--#endregion

--#region Control-Stage Only: Settings Helpers

--- Get spore check interval from settings (startup setting, in ticks)
--- @return number interval The check interval in ticks
function tenebris.get_spore_check_interval()
    local seconds = settings.startup["tenebris-spore-damage-interval-seconds"].value
    return seconds * 60
end

--#endregion

--#region Control-Stage Only: External Constants

--- Piezoelectric generator constants (shared with data stage)
--- See lib/piezoelectric_constants.lua for tier definitions
tenebris.PIEZOELECTRIC = require("lib.piezoelectric_constants")

--- Centipede (Pentapod) constants (shared with data stage)
--- See lib/centipede_constants.lua for variant definitions
tenebris.CENTIPEDE = require("lib.centipede_constants")

--#endregion

--#region Core Systems

--- Event management system
tenebris.event_manager = require("lib.event_manager.init")

--- Composite entity lifecycle management
tenebris.composite_entity = {
    registry = require("lib.composite_entity.registry"),
    lifecycle = require("lib.composite_entity.lifecycle"),
    storage = require("lib.composite_entity.storage")
}

--#endregion

--#region Utility Functions

--- Checks if a surface is on Tenebris planet
--- @param surface LuaSurface
--- @return boolean
function tenebris.is_tenebris_surface(surface)
    if not surface or not surface.planet then
        return false
    end
    return surface.planet.name == tenebris.PLANET.TENEBRIS
end

--- Checks if an entity is on Tenebris planet
--- @param entity LuaEntity
--- @return boolean
function tenebris.is_on_tenebris(entity)
    if not entity or not entity.valid or not entity.surface then
        return false
    end
    return tenebris.is_tenebris_surface(entity.surface)
end

--- Gets a player safely
--- @param player_index uint
--- @return LuaPlayer|nil
function tenebris.get_player(player_index)
    if not player_index then
        return nil
    end
    return game.get_player(player_index)
end

--#endregion

--#region Debug Commands

--- Prints comprehensive debug information
--- @usage /c require("lib.tenebris").debug()
function tenebris.debug()
    if not game then
        log("Debug called outside of game context")
        return
    end
    
    game.print("=== Tenebris Prime Debug Info ===")
    
    -- Event manager stats
    local event_stats = tenebris.event_manager.get_stats()
    game.print(string.format("Events: %d registered, %d subscribers total",
        event_stats.total_events, event_stats.total_subscribers))
    
    -- Composite entity stats
    local composite_stats = tenebris.composite_entity.storage.get_stats()
    game.print(string.format("Composites: %d active, %d components",
        composite_stats.total_composites, composite_stats.total_components))
    
    game.print("=== End Debug Info ===")
end

--- Validates all systems are working correctly
--- @usage /c require("lib.tenebris").validate()
function tenebris.validate()
    if not game then
        log("Validate called outside of game context")
        return
    end
    
    game.print("=== Validating Tenebris Systems ===")
    
    -- Check composite entities
    local invalid_count = tenebris.composite_entity.storage.cleanup_invalid_entities()
    if invalid_count == 0 then
        game.print("✓ All composite entities valid")
    else
        game.print("⚠ Cleaned up " .. invalid_count .. " invalid composites")
    end
    
    game.print("=== Validation Complete ===")
end

--- Repairs all systems (use with caution)
--- @usage /c require("lib.tenebris").repair()
function tenebris.repair()
    if not game then
        log("Repair called outside of game context")
        return
    end
    
    game.print("=== Repairing Tenebris Systems ===")
    
    -- Cleanup composites
    local cleaned = tenebris.composite_entity.storage.cleanup_invalid_entities()
    if cleaned > 0 then
        game.print("Cleaned " .. cleaned .. " invalid composites")
    end
    
    game.print("=== Repair Complete ===")
end

--#endregion

-- Export to global namespace for console access
_G.tenebris = tenebris

return tenebris
