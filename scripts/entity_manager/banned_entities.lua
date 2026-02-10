--- Tenebris Banned Entities
--- Lists of entity types and names that cannot exist on Tenebris.
--- These entities are destroyed on placement and their ghosts are removed.
---
--- @module tenebris_entity_manager.banned_entities

local banned = {}

--- Entity types that are completely banned on Tenebris (all entities of this type)
--- EXCEPTION: Entities in ALLOWED_NAMES are exempt from type bans
--- @type table<string, boolean>
banned.TYPES = {
    ["electric-pole"] = true,
}

--- Specific entity names that are ALLOWED despite their type being banned
--- Used for hidden composite components that must exist (e.g., piezoelectric poles)
--- @type table<string, boolean>
banned.ALLOWED_NAMES = {
    -- Hidden piezoelectric generator poles (composite components)
    ["tenebris-piezoelectric-pole-hidden-tier-1"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-2"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-3"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-4"] = true,
}

--- Entities immune to spore tracking and damage
--- These entities should never be disabled or take acid damage from spores
--- @type table<string, boolean>
banned.SPORE_IMMUNE = {
    -- Hidden piezoelectric generator components (composite)
    ["tenebris-piezoelectric-generator-hidden-tier-1"] = true,
    ["tenebris-piezoelectric-generator-hidden-tier-2"] = true,
    ["tenebris-piezoelectric-generator-hidden-tier-3"] = true,
    ["tenebris-piezoelectric-generator-hidden-tier-4"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-1"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-2"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-3"] = true,
    ["tenebris-piezoelectric-pole-hidden-tier-4"] = true,
    
    -- Piezoelectric buildings (not heated, but use piezoelectric power)
    ["tenebris-crystal-resonance-chamber"] = true,
    ["piezoelectric-inserter"] = true,
    
    -- Biopipes (organic, resistant to acid)
    ["tenebris-biopipe"] = true,
    ["tenebris-biopipe-to-ground"] = true,
    
    -- Heated agricultural tower (heat-powered, immune to spores)
    ["tenebris-heated-agricultural-tower"] = true,
    
    -- Spidertrons (sealed vehicles, immune to spore effects)
    ["spidertron"] = true,
    
    -- Thermal battery (heat storage, immune to spores)
    ["tenebris-thermal-battery"] = true,
    ["tenebris-thermal-battery-hidden"] = true,
    ["tenebris-thermal-battery-hidden-uncommon"] = true,
    ["tenebris-thermal-battery-hidden-rare"] = true,
    ["tenebris-thermal-battery-hidden-epic"] = true,
    ["tenebris-thermal-battery-hidden-legendary"] = true,
    
    -- Thermal diode (heat control, immune to spores)
    ["tenebris-thermal-diode"] = true,
    ["tenebris-thermal-diode-endpoint"] = true,
    ["tenebris-thermal-diode-bridge"] = true,
}

--- Specific entity names that are banned on Tenebris (for selective bans within a type)
--- Use this when you want to ban vanilla entities but allow modded variants
--- @type table<string, boolean>
banned.NAMES = {
    -- Vanilla pipes (chitosan and other modded pipes are allowed)
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    
    -- Belts below express tier (express and turbo are allowed)
    ["transport-belt"] = true,
    ["fast-transport-belt"] = true,
    ["underground-belt"] = true,
    ["fast-underground-belt"] = true,
    ["splitter"] = true,
    ["fast-splitter"] = true,
    
    -- Basic inserters (long-handed, fast, bulk, stack are allowed)
    ["inserter"] = true,
    ["burner-inserter"] = true,
    
    -- Basic assembler (assembling-machine-2 and above are allowed)
    ["assembling-machine-1"] = true,
    
    -- Basic storage (steel chest and above are allowed)
    ["iron-chest"] = true,
    
    -- Basic power generation
    ["steam-engine"] = true,
}

return banned

