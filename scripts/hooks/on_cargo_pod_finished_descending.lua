local mutate_plates_and_chips = require("scripts.mutate_plates_and_chips")

_TENEBRIS = "tenebris"


local function on_cargo_pod_finished_descending(event)
    local cargo_pod = event.cargo_pod 

    if cargo_pod.cargo_pod_destination.surface.planet.name ~= _TENEBRIS then
        return
    end

    local inventory = cargo_pod.get_inventory(defines.inventory.cargo_unit)
    if inventory == nil then
        return
    end

    mutate_plates_and_chips.on_plates_and_circuits_delivered_to_tenebris(inventory)
end


script.on_event(defines.events.on_cargo_pod_finished_descending, on_cargo_pod_finished_descending)