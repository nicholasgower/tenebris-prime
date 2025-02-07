function flatten(tables)
    local result = {}
    for _, inner_table in pairs(tables) do
        for _, value in pairs(inner_table) do
            table.insert(result, value)
        end
    end
    return result
end

function contains_any(target, list)
    for _, type_str in pairs(list) do
        if string.find(target, type_str) then
            return true
        end
    end

    return false
end

function contains(target, val)
    for _, value in pairs(target) do
        if value == val then
            return true
        end
    end

    return false
end