local deep_space_sensing = require("scripts.deep_space_sensing")


local function on_cargo_pod_finished_ascending(event)
    local cargo_pod = event.cargo_pod 

    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if inventory == nil then
        return
    end

    if inventory.find_item_stack(_OBSERVATION_SATELLITE) == nil then
        deep_space_sensing.on_satellite_launched(cargo_pod)
        return
    end
end


script.on_event(defines.events.on_cargo_pod_finished_ascending, on_cargo_pod_finished_ascending)