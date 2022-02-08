require("handlers.handlers")

for index, player in pairs(game.players) do
    if global["armor_bonus"][player.name] == nil and player.get_inventory(defines.inventory.character_armor) ~= nil then
        local armor_stack = player.get_inventory(defines.inventory.character_armor)[1]
        if armor_stack ~= nil and armor_stack.is_armor then
            local evt = {}
            evt.player_index = index
            on_armor_changed(evt)
        end
    end
end