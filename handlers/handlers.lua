global["backup_inventories"] = global["backup_inventories"] or {}
global["armor_bonus"] = global["armor_bonus"] or {}


local function on_inventory_grow(player, old_armor_bonus, new_armor_bonus)
    local new_bonus = new_armor_bonus - old_armor_bonus
    player.character_inventory_slots_bonus = player.character_inventory_slots_bonus + new_bonus
    local player_backup_inventory = global["backup_inventories"][player.name]
    if player_backup_inventory and player_backup_inventory.get_item_count() ~= 0 then
        local main_inventory = player.get_main_inventory()
        for i=1,#player_backup_inventory do
            local items = player_backup_inventory[i]
            if main_inventory.can_insert(items) then
                local num_inserted = main_inventory.insert(items)
                if num_inserted == items.count then
                    player_backup_inventory.remove(items)
                else
                    items.count = items.count - num_inserted
                end
            end
        end
        if player_backup_inventory.get_item_count() == 0 then
            player_backup_inventory.destroy()
            global["backup_inventories"][player.name] = nil
        end
    end
end

local function on_inventory_shrink(player, old_armor_bonus, new_armor_bonus)
    local lost_size = old_armor_bonus - new_armor_bonus
    local player_backup_inventory = global["backup_inventories"][player.name]
    if player_backup_inventory == nil then
        global["backup_inventories"][player.name] = game.create_inventory(lost_size)
        player_backup_inventory = global["backup_inventories"][player.name]
    else
        player_backup_inventory.resize(#player_backup_inventory + lost_size)
    end
    local main_inventory = player.get_main_inventory()
    local inventory_size = #main_inventory
    local start_index = inventory_size - lost_size + 1
    for i=start_index,inventory_size do
        local main_stack = main_inventory[i]
        player_backup_inventory.insert(main_stack)
        main_inventory.remove(main_stack)
    end
    player_backup_inventory.sort_and_merge()
    player.character_inventory_slots_bonus = player.character_inventory_slots_bonus - lost_size
end

function on_armor_changed(evt)
    local player = game.players[evt.player_index]
    local armor_bonuses = global["armor_bonus"]
    local armor_stack = player.get_inventory(defines.inventory.character_armor)[1]
    local old_armor_bonus = armor_bonuses[player.name]
    if player.character then
        if armor_stack.is_armor then
            local armor_ref_name = armor_stack.name .. "-ref"
            local armor_ref_proto = game.item_prototypes[armor_ref_name]
            local new_armor_bonus = 0
            if armor_ref_proto then
                new_armor_bonus = armor_ref_proto.inventory_size_bonus
            end
            if old_armor_bonus == nil then
                armor_bonuses[player.name] = new_armor_bonus
                on_inventory_grow(player, 0, new_armor_bonus)
            elseif old_armor_bonus ~= new_armor_bonus then
                armor_bonuses[player.name] = new_armor_bonus
                if old_armor_bonus > new_armor_bonus then
                    armor_bonuses[player.name] = new_armor_bonus
                    on_inventory_shrink(player, old_armor_bonus, new_armor_bonus)
                elseif old_armor_bonus < new_armor_bonus then
                    armor_bonuses[player.name] = new_armor_bonus
                    on_inventory_grow(player, old_armor_bonus, new_armor_bonus)
                end
            end
        else
            if old_armor_bonus ~= nil and old_armor_bonus ~= 0 then
                armor_bonuses[player.name] = 0
                on_inventory_shrink(player, old_armor_bonus, 0)
            end
        end
    end
end

function on_player_respawn(evt)
    local player = game.players[evt.player_index]
    local armor_bonuses = global["armor_bonus"]
    local old_armor_bonus = armor_bonuses[player.name]
    local armor_stack = player.get_inventory(defines.inventory.character_armor)[1]
    if player.character then
        if armor_stack.is_armor then
            local armor_ref_name = armor_stack.name .. "-ref"
            local armor_ref_proto = game.item_prototypes[armor_ref_name]
            local new_armor_bonus = 0
            if armor_ref_proto then
                new_armor_bonus = armor_ref_proto.inventory_size_bonus
                armor_bonuses[player.name] = new_armor_bonus
                on_inventory_grow(player, 0, new_armor_bonus)
            else
                armor_bonuses[palyer.name] = 0
            end
        else
            armor_bonuses[player.name] = 0
        end
    end
end

function on_load()
    if script.active_mods['space-exploration'] then
        if (remote.call("space-exploration", "get_on_player_respawned_event")) then
            script.on_event(remote.call("space-exploration", "get_on_player_respawned_event"), on_player_respawn)
        end
    end
end
