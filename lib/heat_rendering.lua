--- Heat Rendering Utilities
--- Shared rendering functions for heat pipe endpoints.
--- Creates both heat pipe endings and heat exchange indicators.

local heat_rendering = {}

-- Heat pipe ending sprite names by defines.direction
heat_rendering.ENDING_SPRITES = {
    [defines.direction.north] = "tenebris-heat-pipe-ending-up",
    [defines.direction.south] = "tenebris-heat-pipe-ending-down",
    [defines.direction.west] = "tenebris-heat-pipe-ending-left",
    [defines.direction.east] = "tenebris-heat-pipe-ending-right",
}

--- Destroys a render object if it exists and is valid.
--- @param render_obj LuaRenderObject|nil The render object to destroy
function heat_rendering.destroy(render_obj)
    if render_obj and render_obj.valid then
        render_obj.destroy()
    end
end

--- Destroys all render objects in a table (handles nested tables and direct render objects).
--- @param renders table Array or table of render objects
function heat_rendering.destroy_all(renders)
    if not renders then return end
    for _, item in pairs(renders) do
        if type(item) == "table" then
            -- Could be { ending = ..., indicator = ... } or nested array
            if item.valid then
                -- It's a render object (userdata with valid property accessed via table)
                item.destroy()
            else
                -- Recurse into nested table
                heat_rendering.destroy_all(item)
            end
        elseif item and item.valid then
            -- Direct render object (LuaRenderObject userdata)
            item.destroy()
        end
    end
end

--- Creates a heat connection visual (ending + indicator) at an offset.
--- @param entity LuaEntity The entity to attach the render to
--- @param offset table The offset {x, y} or {0, 0} format
--- @param direction defines.direction The direction the ending points
--- @param indicator_visible boolean Whether the indicator starts visible
--- @return table renders { ending = LuaRenderObject, indicator = LuaRenderObject }
function heat_rendering.create_connection(entity, offset, direction, indicator_visible)
    local sprite = heat_rendering.ENDING_SPRITES[direction] or heat_rendering.ENDING_SPRITES[defines.direction.south]
    
    local ending = rendering.draw_sprite{
        sprite = sprite,
        target = {entity = entity, offset = offset},
        surface = entity.surface,
        render_layer = "lower-object",
    }
    
    local indicator = rendering.draw_sprite{
        sprite = "utility/heat_exchange_indication",
        target = {entity = entity, offset = offset},
        surface = entity.surface,
        visible = indicator_visible or false,
    }
    
    return { ending = ending, indicator = indicator }
end

--- Creates heat connections from a connections array.
--- @param entity LuaEntity The entity to attach renders to
--- @param connections table Array of { offset = {x, y}, direction = defines.direction }
--- @param indicator_visible boolean Whether indicators start visible
--- @return table renders Array of { ending, indicator } tables
function heat_rendering.create_connections(entity, connections, indicator_visible)
    local renders = {}
    for i, conn in ipairs(connections) do
        renders[i] = heat_rendering.create_connection(entity, conn.offset, conn.direction, indicator_visible)
    end
    return renders
end

--- Sets visibility of all indicators in a renders table.
--- @param renders table The renders table from create_connections
--- @param visible boolean Whether to show indicators
function heat_rendering.set_indicators_visible(renders, visible)
    if not renders then return end
    
    for _, conn in pairs(renders) do
        if conn.indicator and conn.indicator.valid then
            conn.indicator.visible = visible
        end
    end
end

-- =============================================================================
-- FLOW ARROWS
-- =============================================================================

--- Creates a flow arrow at an offset.
--- @param entity LuaEntity The entity to attach the arrow to
--- @param offset table The offset {x, y}
--- @param orientation number Arrow orientation (0=north, 0.25=east, 0.5=south, 0.75=west)
--- @param only_in_alt_mode boolean Whether to only show in alt mode
--- @return LuaRenderObject arrow
function heat_rendering.create_arrow(entity, offset, orientation, only_in_alt_mode)
    return rendering.draw_sprite{
        sprite = "utility/indication_arrow",
        target = {entity = entity, offset = offset},
        surface = entity.surface,
        orientation = orientation,
        only_in_alt_mode = only_in_alt_mode ~= false,  -- default true
    }
end

--- Creates flow arrows from an arrows array.
--- @param entity LuaEntity The entity to attach arrows to
--- @param arrows table Array of { offset = {x, y}, orientation = number }
--- @param only_in_alt_mode boolean Whether to only show in alt mode
--- @return table arrows Array of LuaRenderObject
function heat_rendering.create_arrows(entity, arrows, only_in_alt_mode)
    local renders = {}
    for i, arrow in ipairs(arrows) do
        renders[i] = heat_rendering.create_arrow(entity, arrow.offset, arrow.orientation, only_in_alt_mode)
    end
    return renders
end

return heat_rendering
