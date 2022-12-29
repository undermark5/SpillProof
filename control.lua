require("handlers.handlers")

script.on_event(defines.events.on_player_armor_inventory_changed, on_armor_changed)
script.on_event(defines.events.on_player_respawned, on_player_respawn)