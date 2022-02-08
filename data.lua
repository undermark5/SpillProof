local armors = data.raw.armor
local inventory_bonus_armors = {}
for key, value in pairs(armors) do
    local inventory_bonus = value.inventory_size_bonus
    if inventory_bonus then
        if inventory_bonus ~= 0 then
            inventory_bonus_armors[key] = value
        end
    end
end

for key, value in pairs(inventory_bonus_armors) do
    local copy = table.deepcopy(value)
    copy.name = value.name .. "-ref"
    value.inventory_size_bonus = 0
    data:extend{copy}
end