local spore_clearance = require("__tenebris-prime__.scripts.spore_clearance")


local function on_init()
    spore_clearance.on_init()
end


script.on_init(on_init)