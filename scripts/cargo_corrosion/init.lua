--- Cargo Corrosion System
--- Converts basic components to waste when cargo pods land on Tenebris.
--- Batteries cause the cargo pod to explode.
---
--- @module cargo_corrosion

local tenebris = require("lib.tenebris")

local cargo_corrosion = {}

--#region Corrosion Mappings

--- Items that convert to ferric-waste (iron-based)
--- Values are the amount of waste produced per item (based on iron plate cost)
local FERRIC_CORROSION = {
    ["iron-plate"] = 1,
    ["iron-gear-wheel"] = 2,      -- 2 iron plates
    ["iron-stick"] = 1,           -- 0.5 iron plates, round up
    ["steel-plate"] = 5,          -- 5 iron plates
    ["barrel"] = 1,               -- 1 steel plate = 5 iron, but barrel is 1:1
    ["pipe"] = 1,                 -- 1 iron plate
    ["pipe-to-ground"] = 10,      -- 10 iron + 10 pipes
}

--- Items that convert to cupric-waste (copper-based)
--- Values are the amount of waste produced per item (based on copper plate cost)
local CUPRIC_CORROSION = {
    ["copper-plate"] = 1,
    ["copper-cable"] = 1,         -- 0.5 copper plates, round up
}

--- Items that convert to circuit-waste (circuit-based)
--- Values are the amount of waste produced per item (based on electronic circuit cost)
local CIRCUIT_CORROSION = {
    ["electronic-circuit"] = 1,
    ["advanced-circuit"] = 2,     -- 2 electronic circuits
    ["processing-unit"] = 20,     -- 20 electronic circuits
}

--- Items that convert to stone
--- Values are the amount of stone produced per item
local STONE_CONVERSION = {
    ["iron-ore"] = 1,
    ["copper-ore"] = 1,
    ["metallic-asteroid-chunk"] = 10,  -- Large amount of stone
}

--- Items that cause the cargo pod to explode
--- Values represent explosion power multiplier (battery = 1.0, scrap = 0.5)
local EXPLOSIVE_ITEMS = {
    ["battery"] = 1.0,
    ["scrap"] = 0.5,
}

--#endregion

--#region Corrosion Logic

--- Checks if the cargo contains any explosive items (iterates slots for quality support)
--- @param inventory LuaInventory
--- @return boolean has_explosives
--- @return table explosive_items Map of item name to count
function cargo_corrosion.check_for_explosives(inventory)
    local explosive_items = {}
    local has_explosives = false
    
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack and stack.valid_for_read and EXPLOSIVE_ITEMS[stack.name] then
            explosive_items[stack.name] = (explosive_items[stack.name] or 0) + stack.count
            has_explosives = true
        end
    end
    return has_explosives, explosive_items
end

--- Processes a single corrosion category (iterates slots for quality support)
--- @param inventory LuaInventory
--- @param corrosion_map table<string, number> Map of item name to waste amount
--- @param waste_item string Name of the waste item to insert
--- @return number total_waste The total waste produced
local function process_corrosion_category(inventory, corrosion_map, waste_item)
    local total_waste = 0
    -- Track waste by quality level
    local waste_by_quality = {}
    
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack and stack.valid_for_read then
            local waste_per_item = corrosion_map[stack.name]
            if waste_per_item then
                local waste_amount = stack.count * waste_per_item
                local quality_name = stack.quality and stack.quality.name or "normal"
                
                waste_by_quality[quality_name] = (waste_by_quality[quality_name] or 0) + waste_amount
                total_waste = total_waste + waste_amount
                stack.clear()
            end
        end
    end
    
    -- Insert waste for each quality level
    for quality_name, amount in pairs(waste_by_quality) do
        if amount > 0 then
            inventory.insert({ name = waste_item, count = amount, quality = quality_name })
        end
    end
    
    return total_waste
end

--- Processes stone conversions (iterates slots for quality support)
--- @param inventory LuaInventory
--- @return number total_stone The total stone produced
local function process_stone_conversions(inventory)
    local total_stone = 0
    -- Track stone by quality level
    local stone_by_quality = {}
    
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack and stack.valid_for_read then
            local stone_per_item = STONE_CONVERSION[stack.name]
            if stone_per_item then
                local stone_amount = stack.count * stone_per_item
                local quality_name = stack.quality and stack.quality.name or "normal"
                
                stone_by_quality[quality_name] = (stone_by_quality[quality_name] or 0) + stone_amount
                total_stone = total_stone + stone_amount
                stack.clear()
            end
        end
    end
    
    -- Insert stone for each quality level
    for quality_name, amount in pairs(stone_by_quality) do
        if amount > 0 then
            inventory.insert({ name = "stone", count = amount, quality = quality_name })
        end
    end
    
    return total_stone
end

--- Waste item names
local WASTE_ITEMS = {
    FERRIC = tenebris.ITEM.FERRIC_WASTE,
    CUPRIC = tenebris.ITEM.CUPRIC_WASTE,
    CIRCUIT = tenebris.ITEM.CIRCUIT_WASTE,
}

--- Main corrosion handler for cargo pods landing on Tenebris
--- @param cargo_pod LuaEntity The cargo pod entity
--- @return boolean exploded Whether the cargo pod exploded
function cargo_corrosion.process_cargo_pod(cargo_pod)
    if not cargo_pod or not cargo_pod.valid then
        return false
    end
    
    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if not inventory then
        return false
    end
    
    -- Check for explosives first
    local has_explosives, explosive_items = cargo_corrosion.check_for_explosives(inventory)
    if has_explosives then
        local surface = cargo_pod.surface
        local position = cargo_pod.position
        
        -- Calculate effective explosion power based on all explosive items
        -- Each item type has a power multiplier (battery = 1.0, scrap = 0.5)
        local effective_power = 0
        local explosive_summary = {}
        for item_name, count in pairs(explosive_items) do
            local multiplier = EXPLOSIVE_ITEMS[item_name] or 1.0
            effective_power = effective_power + (count * multiplier)
            table.insert(explosive_summary, string.format("%d %s", count, item_name))
        end
        
        -- Explosion radius and damage scale with effective power
        local config = tenebris.CARGO_CORROSION
        local explosion_radius = math.min(
            config.EXPLOSION_RADIUS_MIN + effective_power * config.EXPLOSION_RADIUS_PER_BATTERY,
            config.EXPLOSION_RADIUS_MAX
        )
        local explosion_damage = math.min(
            config.EXPLOSION_DAMAGE_MIN + effective_power * config.EXPLOSION_DAMAGE_PER_BATTERY,
            config.EXPLOSION_DAMAGE_MAX
        )
        
        -- Create explosion visual effect
        surface.create_entity({
            name = "big-explosion",
            position = position,
        })
        
        -- Damage all entities in radius
        local entities = surface.find_entities_filtered({
            position = position,
            radius = explosion_radius,
        })
        
        for _, entity in pairs(entities) do
            if entity.valid and entity ~= cargo_pod and entity.health then
                entity.damage(explosion_damage, game.forces["neutral"], "explosion")
            end
        end
        
        -- Clear inventory to prevent cargo delivery
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack and stack.valid_for_read then
                stack.clear()
            end
        end
        
        -- Destroy the cargo pod
        cargo_pod.destroy()
        
        log(string.format("[Tenebris] Cargo pod exploded due to %s in corrosive atmosphere (effective power: %.1f, radius: %.1f, damage: %d)", 
            table.concat(explosive_summary, ", "), effective_power, explosion_radius, explosion_damage))
        return true
    end
    
    -- Process corrosion for each category
    local ferric_waste = process_corrosion_category(inventory, FERRIC_CORROSION, WASTE_ITEMS.FERRIC)
    local cupric_waste = process_corrosion_category(inventory, CUPRIC_CORROSION, WASTE_ITEMS.CUPRIC)
    local circuit_waste = process_corrosion_category(inventory, CIRCUIT_CORROSION, WASTE_ITEMS.CIRCUIT)
    local stone_produced = process_stone_conversions(inventory)
    
    if ferric_waste > 0 or cupric_waste > 0 or circuit_waste > 0 or stone_produced > 0 then
        log(string.format(
            "[Tenebris] Cargo corrosion: %d ferric, %d cupric, %d circuit waste, %d stone",
            ferric_waste, cupric_waste, circuit_waste, stone_produced
        ))
    end
    
    -- Update metal-waste-reprocessing tech progress based on circuit waste
    if circuit_waste > 0 then
        local force = cargo_pod.force
        local tech = force.technologies["metal-waste-reprocessing"]
        if tech and not tech.researched then
            -- Only count progress if all prerequisites are researched
            local prerequisites_met = true
            for _, prereq in pairs(tech.prerequisites) do
                if not prereq.researched then
                    prerequisites_met = false
                    break
                end
            end
            
            if prerequisites_met then
                local TARGET_CIRCUIT_WASTE = 10000
                local progress_to_add = circuit_waste / TARGET_CIRCUIT_WASTE
                tech.saved_progress = math.min((tech.saved_progress or 0) + progress_to_add, 1)
                if tech.saved_progress >= 1 then
                    tech.researched = true
                end
            end
        end
    end
    
    return false
end

--#endregion

return cargo_corrosion
