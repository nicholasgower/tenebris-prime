require("__tenebris-prime__.util")

local meld = require("meld")

local unique_subgroups = {}

local function build_item_icons(item)
    local icons = {
        {
            icon = "__tenebris-prime__/graphics/icons/item-glow.png",
            icon_size = 64,
        }
    }

    if item.icon then
        table.insert(icons, {
            icon = item.icon,
            icon_size = item.icon_size or 64,
        })
    end

    if item.icons then
        meld(icons, item.icons)
    end

    return icons
end

local function icons_to_layers(item)
    local layers = {
        {
            filename = "__tenebris-prime__/graphics/icons/item-glow.png",
            size = 64,
            scale = 0.5,
            draw_as_light = true,
        }
    }

    if item.icon then
        table.insert(layers, {
            filename = item.icon,
            scale = 0.5,
            size = item.icon_size or 64,
        })
    end

    if item.icons then
        for _, icon in pairs(item.icons) do
            table.insert(layers, {
                filename = icon.icon,
                tint = icon.tint,
                scale = 0.5,
                size = icon.icon_size or 64,
            })
        end
    end

    return layers
end

local function create_bioluminescent_entity(entities, cost, entity_mod, exclude, light_scale, light_pollution)
    local result = {}
    for _, entity in pairs(entities) do
        if entity.bioluminescent or
            (entity.energy_source and entity.energy_source.type == "void") then
            goto skip
        end

        if not contains(exclude or {}, entity.name) and entity.minable and entity.minable.result and entity.minable.result == entity.name then
            local item = data.raw["item"][entity.minable.result] or
                data.raw["item-with-entity-data"][entity.minable.result]

            if not item then goto skip end

            local name = "bioluminescent-" .. entity.name
            result[name] =
                meld(table.deepcopy(entity), {
                    name = name,
                    bioluminescent = true,
                    localised_name = { "entity-name.bioluminescent-entity", entity.localised_name or { "entity-name." .. entity.name } },
                    energy_source = meld({ 
                        type = "void",   
                    }, light_pollution or {}),
                    integration_patch_render_layer = "collision-selection-box",
                    integration_patch = {
                        filename = "__tenebris-prime__/graphics/icons/item-glow.png",
                        size = 64,
                        scale = light_scale or 8,
                        draw_as_light = true,
                    },
                    minable = { mining_time = 0.2, result = "bioluminescent-" .. entity.minable.result },
                    
                })

            if entity_mod then
                result[name] = meld(result[name], entity_mod(result[name]))
            end

            unique_subgroups[item.subgroup or "default"] = true

            data:extend({
                meld(table.deepcopy(item), {
                    name = "bioluminescent-" .. item.name,
                    icon = meld.delete(),
                    subgroup = "bioluminescent-" .. (item.subgroup or "default"),
                    order = "z[bioluminescent-" .. item.name .. "]",
                    place_result = "bioluminescent-" .. item.name,
                    icons = meld.overwrite(build_item_icons(item)),
                    pictures = meld.overwrite {
                        layers = icons_to_layers(item)
                    },
                    spoil_result = item.name,
                    spoil_ticks = 1296000
                }),
                {
                    type = "recipe",
                    name = "bioluminescent-" .. item.name,
                    localised_name = { "recipe-name.bioinfuse-item", item.localised_name or { "entity-name." .. item.name } },
                    order = "x",
                    enabled = false,
                    category = "bioinfusion",
                    ingredients = {
                        { type = "item", name = item.name, amount = 1 },
                    },
                    results = { { type = "item", name = "bioluminescent-" .. item.name, amount = 1 } },
                    energy_required = cost or 10.0,
                    allow_productivity = false,
                    allow_quality = false,
                }
            })

            table.insert(data.raw["technology"]["tenebris-bioinfusor"].effects, {
                type = "unlock-recipe",
                recipe = "bioluminescent-"..item.name
            })
        end

        ::skip::
    end

    return result
end

local function create_light_emissions(light_pollution)
    return {
        emissions_per_minute = {
            light = light_pollution
        }
    }
end

local biolum_types = flatten {
    create_bioluminescent_entity(table.deepcopy(data.raw["inserter"]), 10.0, function(entity)
        return {
            rotation_speed = entity.rotation_speed * 1.5
        }
    end),
    create_bioluminescent_entity(table.deepcopy(data.raw["assembling-machine"]), 15.0, function(entity)
        return {
            crafting_speed = entity.crafting_speed * 1.5
        }
    end, {"crusher"}, nil, create_light_emissions(6)),
    create_bioluminescent_entity(table.deepcopy(data.raw["furnace"]), 15.0, function(entity)
        return {
            crafting_speed = entity.crafting_speed * 1.5
        }
    end, nil, nil, create_light_emissions(4)),
    create_bioluminescent_entity(table.deepcopy(data.raw["mining-drill"]), 10.0, function(entity)
        return {
            mining_speed = entity.mining_speed * 1.5
        }
    end, nil, nil, create_light_emissions(6)),
    create_bioluminescent_entity(table.deepcopy(data.raw["agricultural-tower"]), 15.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["roboport"]), 30.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["constant-combinator"]), 3.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["arithmetic-combinator"]), 3.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["decider-combinator"]), 3.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["selector-combinator"]), 3.0),
    create_bioluminescent_entity(table.deepcopy(data.raw["rocket-silo"]), 100.0, function(entity)
        return {
            crafting_speed = entity.crafting_speed * 2
        }
    end, nil, nil, create_light_emissions(10)),
    create_bioluminescent_entity(table.deepcopy(data.raw["locomotive"]), 30.0, function(entity)
        return {
            max_speed = entity.max_speed * 2
        }
    end),
    create_bioluminescent_entity(table.deepcopy(data.raw["cargo-wagon"]), 0.1, function(entity)
        return {
            max_speed = entity.max_speed * 2
        }
    end),
    create_bioluminescent_entity(table.deepcopy(data.raw["fluid-wagon"]), 0.1, function(entity)
        return {
            max_speed = entity.max_speed * 2
        }
    end),
    create_bioluminescent_entity(table.deepcopy(data.raw["transport-belt"]), 0.1, nil, nil, 2, create_light_emissions(2)),
}

data:extend(biolum_types)

for subgroup, _ in pairs(unique_subgroups) do
    local old = data.raw["item-subgroup"][subgroup]

    data:extend({
        {
            type = "item-subgroup",
            name = "bioluminescent-" .. subgroup,
            group = "bioluminescent",
            order = "z[bioluminescent-" .. subgroup .. "]"
        }
    })
end
