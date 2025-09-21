if mods["planet-muluna"] then
    table.insert(data.raw["technology"]["deep-space-sensing"].unit.ingredients, {"interstellar-science-pack",1})
end

if data.raw["technology"]["muluna-satellite-radar"] then
    table.insert(data.raw["technology"]["deep-space-sensing"].prerequisites, "muluna-satellite-radar")
end