local deep_space_sensing = require("scripts.deep_space_sensing")


local function on_research_finished(event)
    if event.research.name ~= "deep-space-sensing" then
        return
    end

    deep_space_sensing.setup_deep_space_sensing_satellites_counter()
    deep_space_sensing.setup_deep_space_sensing_planetary_contribution()
end


script.on_event(defines.events.on_research_finished, on_research_finished)