if not mods["canal-excavator"] then return end

local excavator = data.raw["mining-drill"]["bioluminescent-canex-excavator"]
local index
for i, category in pairs(excavator.resource_categories) do
  if category == "canex-rsc-cat-digable" then
    index = i
    break
  end
end
if index then
  table.remove(excavator.resource_categories, index)
end