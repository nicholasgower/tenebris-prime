--- Tenebris Prime Data Stage Constants
--- Shared constants for use in prototypes (data stage)

local constants = {}

--- Crystal types (quartz variants) - suffix only, add "tenebris-" prefix for item names
constants.CRYSTAL_TYPES = {
    "citrine",
    "onyx",
    "prasiolite",
    "amethyst",
    "ruby-agate",
    "sapphire-agate"
}

--- Exposed Lichen Deposit composite icon (shared between entity and technology)
constants.LICHEN_DEPOSIT_ICONS = {
    -- Center: Spoilage (main drop)
    { icon = "__space-age__/graphics/icons/spoilage.png", icon_size = 64, scale = 0.4 },
    -- Top-left: Tenecap spore
    { icon = "__tenebris-prime__/graphics/icons/tenecap-spore.png", icon_size = 64, scale = 0.25, shift = {-10, -10} },
    -- Top-right: Stone
    { icon = "__base__/graphics/icons/stone.png", icon_size = 64, scale = 0.25, shift = {10, -10} },
    -- Bottom-left: Carbon
    { icon = "__space-age__/graphics/icons/carbon.png", icon_size = 64, scale = 0.25, shift = {-10, 10} },
    -- Bottom-right: Calcite
    { icon = "__space-age__/graphics/icons/calcite.png", icon_size = 64, scale = 0.25, shift = {10, 10} },
    -- Right: Chitin (rare)
    { icon = "__tenebris-prime__/graphics/icons/chitin.png", icon_size = 64, scale = 0.2, shift = {12, 0} },
}

return constants

