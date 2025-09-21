local deep_space_sensing = require("scripts.deep_space_sensing")
local spore_clearance = require("scripts.spore_clearance")

local _TICKS_PER_SECOND = 60


local function on_3600_tick(event)
    deep_space_sensing.on_progress_deep_space_sensing_tick(event)
end


local function on_1800_tick(_)
    spore_clearance.on_pollution_check_tick()
end


script.on_nth_tick(30 * _TICKS_PER_SECOND, on_1800_tick)
script.on_nth_tick(60 * _TICKS_PER_SECOND, on_3600_tick)