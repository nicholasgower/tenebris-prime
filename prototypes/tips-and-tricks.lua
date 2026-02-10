-- Tips and Tricks entries for Tenebris Prime

data:extend({
    -- Tenebris category
    {
        type = "tips-and-tricks-item-category",
        name = "tenebris",
        order = "z-[tenebris]"
    },

    -- Tenebris Briefing - shows when the planet is discovered
    {
        type = "tips-and-tricks-item",
        name = "tenebris-briefing",
        tag = "[planet=tenebris]",
        category = "tenebris",
        order = "a",
        trigger = {
            type = "research",
            technology = "planet-discovery-tenebris"
        },
    },

    -- Banned Entities - shows after viewing the briefing
    {
        type = "tips-and-tricks-item",
        name = "tenebris-banned-entities",
        tag = "[img=utility/warning_icon]",
        category = "tenebris",
        order = "b",
        indent = 1,
        trigger = {
            type = "dependencies-met",
        },
        dependencies = {"tenebris-briefing"},
    },

    -- Spore Clearance - shows after viewing banned entities
    {
        type = "tips-and-tricks-item",
        name = "tenebris-spore-clearance",
        tag = "[item=tenecap-spore]",
        category = "tenebris",
        order = "c",
        indent = 1,
        trigger = {
            type = "dependencies-met",
        },
        dependencies = {"tenebris-banned-entities"},
    },

    -- Cargo Safety - shows after viewing spore clearance
    {
        type = "tips-and-tricks-item",
        name = "tenebris-cargo-safety",
        tag = "[entity=cargo-pod]",
        category = "tenebris",
        order = "d",
        indent = 1,
        trigger = {
            type = "dependencies-met",
        },
        dependencies = {"tenebris-spore-clearance"},
    },

    -- Ortet Capture - shows after cargo safety tip is viewed
    {
        type = "tips-and-tricks-item",
        name = "tenebris-ortet-capture",
        tag = "[item=piezoelectric-converter-capture-bot-rocket]",
        category = "tenebris",
        order = "e",
        indent = 1,
        trigger = {
            type = "dependencies-met",
        },
        dependencies = {"tenebris-cargo-safety"},
    },
})
