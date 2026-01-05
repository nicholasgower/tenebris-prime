--- Planetary Discovery GUI Module
--- Provides an interactive interface for discovering planets via observation satellites.
--- Players select target planets and the satellite network attempts to discover them.
---
--- @module deep_space_sensing.planetary_discovery_gui

local constants = require("scripts.deep_space_sensing.constants")
local deep_space_sensing = require("scripts.deep_space_sensing.init")

local GUI_PREFIX = constants.GUI.PREFIX
local FRAME_NAME = constants.GUI.FRAME_NAME
local CONTENT_PANE_NAME = constants.GUI.CONTENT_PANE_NAME
local KEYS = constants.STORAGE_KEYS

--- Cache of GUI element references per player to avoid recursive search every tick
local element_cache = {}

local gui = {}

--- Creates the main planetary discovery GUI
--- @param player LuaPlayer The player to create the GUI for
function gui.create_gui(player)
    -- Don't create if it already exists
    if player.gui.screen[FRAME_NAME] then
        return
    end
    
    local frame = player.gui.screen.add{
        type = "frame",
        name = FRAME_NAME,
        direction = "vertical"
    }
    frame.auto_center = true
    
    -- Title bar
    local title_flow = frame.add{
        type = "flow",
        direction = "horizontal"
    }
    title_flow.style.horizontal_spacing = 8
    title_flow.add{
        type = "label",
        caption = {"deep-space-sensing.planetary-discovery-title"},
        style = "frame_title"
    }
    
    local drag_handle = title_flow.add{
        type = "empty-widget",
        style = "draggable_space_header"
    }
    drag_handle.style.height = 32
    drag_handle.style.horizontally_stretchable = true
    drag_handle.drag_target = frame
    
    -- Close button
    title_flow.add{
        type = "sprite-button",
        name = GUI_PREFIX .. "_close",
        sprite = "utility/close",
        style = "frame_action_button"
    }
    
    -- Content scroll pane
    local scroll_pane = frame.add{
        type = "scroll-pane",
        name = CONTENT_PANE_NAME,
        direction = "vertical"
    }
    scroll_pane.style.maximal_height = 600
    scroll_pane.style.minimal_width = 500
    
    gui.refresh_content(player)
    
    player.opened = frame
end

--- Refreshes the planet list in the GUI
--- @param player LuaPlayer The player whose GUI to refresh
function gui.refresh_content(player)
    local sensing = deep_space_sensing
    
    local frame = player.gui.screen[FRAME_NAME]
    if not frame then
        return
    end
    
    local scroll_pane = frame[CONTENT_PANE_NAME]
    if not scroll_pane then
        return
    end
    
    scroll_pane.clear()
    
    -- Get discoverable planets from deep space sensing
    local discoverable_planets = sensing.get_discoverable_planets()
    
    if not player.force.technologies[constants.UNLOCK_TECHNOLOGY] or 
       not player.force.technologies[constants.UNLOCK_TECHNOLOGY].researched then
        scroll_pane.add{
            type = "label",
            caption = {"deep-space-sensing.tech-required"}
        }
        return
    end
    
    -- Get current target
    local current_target = sensing.get_discovery_target(player.force)
    
    -- Show satellite network status
    local network_flow = scroll_pane.add{
        type = "flow",
        direction = "vertical"
    }
    network_flow.style.bottom_margin = 12
    
    network_flow.add{
        type = "label",
        caption = {"deep-space-sensing.satellite-network-status"},
        style = "caption_label"
    }
    
    -- Show scan progress bar if scanning
    if current_target then
        local progress = sensing.get_scan_progress()
        local seconds_remaining = sensing.get_seconds_until_scan()
        
        local progress_flow = network_flow.add{
            type = "flow",
            direction = "horizontal"
        }
        progress_flow.style.vertical_align = "center"
        progress_flow.style.horizontal_spacing = 8
        
        progress_flow.add{
            type = "label",
            caption = {"deep-space-sensing.next-scan"}
        }
        
        local progress_bar = progress_flow.add{
            type = "progressbar",
            name = GUI_PREFIX .. "_scan_progress",
            value = progress
        }
        progress_bar.style.width = 200
        
        local countdown = progress_flow.add{
            type = "label",
            name = GUI_PREFIX .. "_scan_countdown",
            caption = string.format("%ds", seconds_remaining)
        }
        
        -- Cache element references for fast updates
        element_cache[player.index] = {
            progress_bar = progress_bar,
            countdown = countdown
        }
    else
        -- Clear cache when not scanning
        element_cache[player.index] = nil
        
        network_flow.add{
            type = "label",
            caption = {"deep-space-sensing.select-target-to-scan"}
        }
    end
    
    -- Show satellite strength per planet (quality-adjusted)
    local has_satellites = false
    local satellite_strength = sensing.get_satellite_counts(player.force)
    if satellite_strength then
        for planet_name, strength in pairs(satellite_strength) do
            if strength > 0 then
                has_satellites = true
                -- Format strength to 1 decimal place for clean display
                local formatted_strength = string.format("%.1f", strength)
                network_flow.add{
                    type = "label",
                    caption = {"deep-space-sensing.satellite-strength", planet_name, formatted_strength}
                }
            end
        end
    end
    
    if not has_satellites then
        network_flow.add{
            type = "label",
            caption = {"deep-space-sensing.no-satellites-in-orbit"}
        }
    end
    
    scroll_pane.add{
        type = "line",
        direction = "horizontal"
    }
    
    -- List discoverable planets
    for planet_name, planet_config in pairs(discoverable_planets) do
        local discovery_tech_name = planet_config.tech_name
        local display_name = planet_config.display_name or planet_name
        local tech = player.force.technologies[discovery_tech_name]
        
        if tech then
            -- Create planet entry
            local planet_frame = scroll_pane.add{
                type = "frame",
                direction = "vertical",
                style = "inside_shallow_frame"
            }
            planet_frame.style.padding = 8
            planet_frame.style.margin = 4
            
            local header_flow = planet_frame.add{
                type = "flow",
                direction = "horizontal"
            }
            header_flow.style.vertical_align = "center"
            header_flow.style.horizontal_spacing = 8
            
            -- Technology icon
            header_flow.add{
                type = "sprite",
                sprite = "technology/" .. discovery_tech_name,
                resize_to_sprite = false
            }.style.size = {32, 32}
            
            -- Planet name (display name)
            header_flow.add{
                type = "label",
                caption = display_name,
                style = "heading_2_label"
            }
            
            -- Status with color coding
            if tech.researched then
                local label = header_flow.add{
                    type = "label",
                    caption = {"deep-space-sensing.planet-discovered"}
                }
                label.style.font_color = {0.3, 0.9, 0.3}  -- Green
            elseif current_target == planet_name then
                local label = header_flow.add{
                    type = "label",
                    caption = {"deep-space-sensing.planet-scanning"}
                }
                label.style.font_color = {1, 0.85, 0.2}  -- Yellow/gold
            else
                local label = header_flow.add{
                    type = "label",
                    caption = {"deep-space-sensing.planet-undiscovered"}
                }
                label.style.font_color = {0.6, 0.6, 0.6}  -- Gray
            end
            
            -- Prerequisites check
            local prereqs_met = true
            if tech.prerequisites then
                for _, prereq_tech in pairs(tech.prerequisites) do
                    if not prereq_tech.researched then
                        prereqs_met = false
                        break
                    end
                end
            end
            
            if not prereqs_met then
                planet_frame.add{
                    type = "label",
                    caption = {"deep-space-sensing.prerequisites-not-met"}
                }
            elseif not tech.researched then
                -- Check if force has any satellites
                local force_has_satellites = sensing.has_any_satellites(player.force)
                
                -- Show discovery chance
                local discovery_chance = sensing.calculate_discovery_chance(player.force, planet_name)
                
                planet_frame.add{
                    type = "label",
                    caption = {"deep-space-sensing.discovery-chance", string.format("%.4f", discovery_chance * 100)}
                }
                
                -- Scan button (only enabled if satellites exist)
                if current_target == planet_name then
                    planet_frame.add{
                        type = "button",
                        name = GUI_PREFIX .. "_stop_scan",
                        caption = {"deep-space-sensing.stop-scanning"},
                        style = "red_back_button"
                    }
                elseif force_has_satellites then
                    planet_frame.add{
                        type = "button",
                        name = GUI_PREFIX .. "_start_scan_" .. planet_name,
                        caption = {"deep-space-sensing.start-scanning"},
                        style = "green_button"
                    }
                else
                    planet_frame.add{
                        type = "label",
                        caption = {"deep-space-sensing.launch-satellites-to-scan"}
                    }
                end
            end
        end
    end
end

--- Destroys the planetary discovery GUI
--- @param player LuaPlayer The player whose GUI to destroy
function gui.destroy_gui(player)
    local frame = player.gui.screen[FRAME_NAME]
    if frame and frame.valid then
        frame.destroy()
    end
    -- Clear element cache
    element_cache[player.index] = nil
end

--- Toggles the planetary discovery GUI
--- @param player LuaPlayer The player to toggle for
function gui.toggle_gui(player)
    if player.gui.screen[FRAME_NAME] then
        gui.destroy_gui(player)
    else
        gui.create_gui(player)
    end
end

--- Handler for GUI click events
--- @param event EventData The GUI click event
function gui.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end
    
    local sensing = deep_space_sensing
    local player = game.players[event.player_index]
    local element_name = event.element.name
    
    -- Close button
    if element_name == GUI_PREFIX .. "_close" then
        gui.destroy_gui(player)
        return
    end
    
    -- Stop scanning button
    if element_name == GUI_PREFIX .. "_stop_scan" then
        sensing.set_discovery_target(player.force, nil)
        player.print({"deep-space-sensing.scanning-stopped"})
        gui.refresh_content(player)
        return
    end
    
    -- Start scanning button
    local start_prefix = GUI_PREFIX .. "_start_scan_"
    if element_name:sub(1, #start_prefix) == start_prefix then
        local planet_name = element_name:sub(#start_prefix + 1)
        
        sensing.set_discovery_target(player.force, planet_name)
        
        -- Use display name in the message
        local display_name = sensing.get_display_name(planet_name)
        player.print({"deep-space-sensing.now-scanning-for", display_name})
        gui.refresh_content(player)
        return
    end
end

--- Handler for GUI closed events
--- @param event EventData The GUI closed event
function gui.on_gui_closed(event)
    if not event.element or not event.element.valid then
        return
    end
    if event.element.name == FRAME_NAME then
        gui.destroy_gui(game.players[event.player_index])
    end
end

--- Refresh all open planetary discovery GUIs
function gui.refresh_all_guis()
    for _, player in pairs(game.players) do
        if player.gui.screen[FRAME_NAME] then
            gui.refresh_content(player)
        end
    end
end

--- Updates progress bars WITHOUT rebuilding the GUI
--- This allows button clicks to work properly
function gui.update_progress_bars()
    local sensing = deep_space_sensing
    
    for _, player in pairs(game.players) do
        local frame = player.gui.screen[FRAME_NAME]
        if not frame or not frame.valid then
            element_cache[player.index] = nil
            goto continue
        end
        
        -- Only update if this force is actively scanning
        local current_target = sensing.get_discovery_target(player.force)
        if not current_target then
            goto continue
        end
        
        -- Use cached references if available and valid
        local cache = element_cache[player.index]
        if cache and cache.progress_bar and cache.progress_bar.valid 
               and cache.countdown and cache.countdown.valid then
            cache.progress_bar.value = sensing.get_scan_progress(player.force)
            cache.countdown.caption = string.format("%ds", sensing.get_seconds_until_scan(player.force))
        end
        
        ::continue::
    end
end

--- Registers the refresh callback with the sensing module
--- Called after the module is fully loaded
function gui.register_refresh_callback()
    deep_space_sensing.register_refresh_callback(gui.refresh_all_guis)
end

return gui

