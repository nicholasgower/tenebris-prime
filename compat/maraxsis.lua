if data.raw["recipe"]["maraxsis-conduit"] and settings.startup["tenebris-maraxsis-beacon-integration"].value == true then
    data.raw.recipe["maraxsis-conduit"].ingredients = {
        {type = "item", name = "biobeacon",                        amount = 1},	-- changed, other ingredients are left as is.
        {type = "item", name = "maraxsis-glass-panes",             amount = 25},
        {type = "item", name = "processing-unit",                  amount = 25},
        {type = "item", name = "maraxsis-super-sealant-substance", amount = 5},
    }
    table.insert(data.raw.technology["maraxsis-effect-transmission-2"].prerequisites ,"biobeacon")	-- added biobeacon
end
