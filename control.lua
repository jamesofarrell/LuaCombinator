require("defines")
require("util")
require("new_class")
require("output")
require("lc")


local LONG_TICK = 60
local MEDIUM_TICK = 30
local SHORT_TICK = 15

on_built_entity = function (event)
	if is_valid(event.created_entity) and event.created_entity.name == "lua-combinator" then
		
		if global.lamps == nil then 
			global.lamps = {} 
		end
		local player = game.players[event.player_index]
		if player == nil then
			player = game.players[1]
		end
		lamp = {}
		lamp.repeat_command = false
		lamp.ignore_condition = false
		lamp.loop = false
		lamp.clear_output = false
		lamp.post = false
		lamp.command = ""
		lamp.lua_state = {}
		lamp.player = player
		lamp.position = event.created_entity.position
		lamp.lua_lamp = event.created_entity
		lamp.last_entity_update = 0
		lamp.force = player.force
		
		lamp.last_condition_state = false
		lamp.condition_state = false
		
		player = lamp.player
		surface = player.surface
		
		lamp.lc = lc:new(lamp.lua_lamp,lamp.player)
		
		lamp.output = output:new(lc.output_combinator)
		lamp.output.entity.connect_neighbour{ wire=defines.circuitconnector.red, target_entity=lamp.lua_lamp}
		lamp.output.entity.connect_neighbour{ wire=defines.circuitconnector.green, target_entity=lamp.lua_lamp}
		
		lamp = update_lamp_entities(lamp,0)
		
		--defines.circuitconnector.red or defines.circuitconnector.green
		table.insert(global.lamps,lamp)
	end
	
end




on_tick = function (event)
	if global.lamps == nil then return end
	if not global.queue_length then global.queue_length = 0 end
	
	if event.tick%10==7 then
		for _,player in pairs(game.players) do
			if is_valid(player.opened) and player.opened.name == "lua-combinator" then
				if not player.gui.left.lua_lamp then
					new_gui(player, find_lamp(global.lamps,player.opened))
				end
			elseif player.gui.left.lua_lamp ~= nil then
				player.gui.left.lua_lamp.destroy()
			end
		end
	end

	
	if event.tick%LONG_TICK==59 then
		global.queue = table_or_new(global.queue)
		global.queue_length = global.queue_length + add_to_queue(global.queue,global.lamps,LONG_TICK)
	elseif event.tick % MEDIUM_TICK==29 then
		global.queue = table_or_new(global.queue)
		global.queue_length = global.queue_length + add_to_queue(global.queue,global.lamps,MEDIUM_TICK)
	elseif event.tick%SHORT_TICK==13 then
		global.queue = table_or_new(global.queue)
		global.queue_length = global.queue_length + add_to_queue(global.queue,global.lamps,SHORT_TICK)
	end
	
	if global.queue then
		if global.queue_length == 0 then
			global.queue = nil
		else
			number_to_process = math.floor(global.queue_length / SHORT_TICK) + 1
			processed = 0
			to_delete = {}
			clean_table = false
			while processed < number_to_process do
				lamp = global.queue[global.queue_length - processed]
				processed = processed + 1
				if lamp and is_valid(lamp.lua_lamp) then
					update_condition_state(lamp)
					if (lamp.condition_state and (lamp.repeat_command or not lamp.last_condition_state)) or (not lamp.condition_state and lamp.post and lamp.last_condition_state) then
						lamp = update_lamp_entities(lamp, event.tick)
						--debug_log("Lamp: " .. lamp.command, 0)
						if lamp.loop then
							lamp = run_loop_command(lamp)
						else
							lamp = run_command(lamp)
						end
					end
					lamp.last_condition_state = lamp.condition_state
				else
					clean_table = true
				end
			end
			deleted = 0
			while deleted < processed do
				deleted = deleted + 1
				table.remove(global.queue,global.queue_length)
				global.queue_length = global.queue_length - 1
			end
			debug_log("##p: " .. processed .. " d: " .. deleted,4)
			if clean_table then
				global.lamps = cleanup_lamps(global.lamps)
			end
		end
	end
	
	-- if event.tick%30==23 then
		-- to_delete = {}
		-- for i,lamp in ipairs(global.lamps) do
			
		-- end
		-- for i,j in ipairs(to_delete) do
			-- 
		-- end
	-- end
end

on_gui_click = function (event)
	player = game.players[event.player_index]
	element = event.element
	local entity
	if is_valid(player.opened) and player.opened.name == "lua-combinator" then
		entity = player.opened
	else
		return
	end
	
	if element.name == "lua_save" then
		lamp = find_lamp(global.lamps,entity)
		update_lamp(player.gui.left.lua_lamp,lamp)
		lamp.last_condition_state = false
		--debug_log("Arrr " .. lamp.command)
		--lamp = find_lamp(global.lamps,entity)
		--debug_log("Arrasdasdasdr " .. lamp.command)
		--update_gui(player.gui.left.lua_lamp,lamp)
	end
	
end 

on_load = function(event)
	if global.lamps ~= nil then
		for _,lamp in pairs(global.lamps) do
			lamp.output = output:new(lamp.output.entity)
			new_lc = lc:new(lamp.lua_lamp,lamp.player)
			if lamp.lc then
				new_lc.banner = lamp.lc.banner
				new_lc.map_text = lamp.lc.map_text
				if lamp.lc.output_combinator then
					new_lc.output_combinator.set_circuit_condition(1,lamp.lc.output_combinator.get_circuit_condition(1))
					lamp.lc.output_combinator.destroy()
				end
			end
			lamp.lc = new_lc
			lamp = update_lamp_entities(lamp,0)
		end
	end
end


game.on_event(defines.events.on_gui_click, on_gui_click)

game.on_event(defines.events.on_tick, on_tick)

game.on_load(on_load)

game.on_event(defines.events.on_built_entity, on_built_entity)
game.on_event(defines.events.on_robot_built_entity, on_built_entity)

function cleanup_lamps(lamps)
	to_deleter = {}
	for i,lamp in pairs(lamps) do
		if not lamp and not is_valid(lamp) then
			table.insert(to_delete,1)
		end
	end
	for i,delete in ipairs(to_delete) do
		val = delete - i + 1
		temp_lamp = lamps[val]
		cleanup_lamp_entities(temp_lamp)
		table.remove(lamps,val)
	end
	return lamps
end

function add_to_queue(queue,lamps,tick_speed)
	count = 0
	if queue and lamps and tick_speed then
		for _,lamp in pairs(lamps) do
			if not lamp.tick_speed or lamp.tick_speed == 0 then 
				lamp.tick_speed = LONG_TICK 
			end
			
			if lamp.tick_speed <= tick_speed then
				count = count + 1
				table.insert(queue, lamp)
			end
		end
	end
	return count
end

function cleanup_lamp_entities(lamp)
	local surface 
	if is_valid(lamp.output.entity) then
		surface = lamp.output.entity.surface
	elseif lamp.player then
		surface = lamp.player.surface
	else
		surface = game.players[1].surface
	end
	entities = surface.find_entities({{lamp.position.x - 1, lamp.position.y - 1}, {lamp.position.x + 1, lamp.position.y + 1}})
	for _,entity in pairs(entities) do
		if is_valid(entity) and string.sub(entity.name,-4)=="_lua" then 
			entity.destroy()
		end
	end
	-- if lamp.output and .
	-- is_valid(lamp.output.entity) then
		-- temp_lamp.output.entity.destroy()
	-- end
	-- if lamp.output and is_valid(lamp.output.entity) then
		-- temp_lamp.output.entity.destroy()
	-- end
	-- if is_valid(temp_lamp.chest) then
		-- temp_lamp.chest.destroy()
	-- end
end

function update_lamp_entities(lamp,tick)
	if lamp ~= nil then
		lamp_entities = {}
		lamp.entities = table_or_new(lamp.entities)
		if not lamp.last_entity_update then lamp.last_entity_update = 0 end
		if tick ~= 0 and not (lamp.last_entity_update < tick - 60) then 
			for _,entity in pairs(lamp.entities) do
				if is_valid(entity) and (entity.position.x ~= lamp.position.x or entity.position.y ~= lamp.position.y) then
					table.insert(lamp_entities, entity)
				end
			end
			
		else
			temp_entities = lamp.player.surface.find_entities({{lamp.position.x - 1, lamp.position.y - 1}, {lamp.position.x + 1, lamp.position.y + 1}})
			for _,entity in pairs(temp_entities) do
				if is_valid(entity) and (entity.position.x ~= lamp.position.x or entity.position.y ~= lamp.position.y) then
					table.insert(lamp_entities, entity)
				end
			end
			lamp.last_entity_update = tick
		end
		lamp.entities = lamp_entities
	end
	return lamp
end

function update_condition_state(lamp)
	lamp.condition_state = get_condition(lamp.lua_lamp,1)
end

function get_condition(lua_lamp,colour)
	return lua_lamp.get_circuit_condition(colour).fulfilled
end

script_headder = "lamp = global.variable.lua_lamp; condition = global.variable.condition; lc = global.variable.lamp.lc; output = global.variable.lamp.output;  player = global.variable.lamp.player; local state = global.variable.lamp.lua_state; local global = global.variable.global; local game = game;"

function run_command(lamp) -- player.print("Hello World!")
	if lamp.command ~= nil and lamp.command ~= "" then
		
		--game.makefile("lua_command.txt", "lua-command: " .. "entities = global.variable.lamp.entities;" .. script_headder .. lamp.command)
		global.variable = get_variable(lamp)
		funct, err = loadstring("entities = global.variable.lamp.entities;" .. script_headder ..  lamp.command)
		if err then
			lamp.player.print(err)
		else
			empty,err = pcall(funct)
			if err then 
				lamp.player.print(err)
			end
		end
		global.variable = nil
	end
	return lamp
end


function run_loop_command(lamp) -- if (entity.name == "rocket-silo") then player.print("lift off!"); entity.launch_rocket() end
	global.variable = get_variable(lamp)
	--game.makefile("lua_command.txt", "LUA COMMAND: entity = global.variable.entity; "  .. script_headder .. lamp.command)
	funct,err = loadstring("entity = global.variable.entity; "  .. script_headder .. lamp.command)
	if err then
			lamp.player.print(err)
	else
		
		for _,entity in pairs(lamp.entities) do
			global.variable.entity = entity
			empty,err = pcall(funct)
			if err then 
				lamp.player.print(err)
			end
		end
	end
	--debug_log(lamp.chest.get_inventory(1)[1].name)
	global.variable = nil
	return lamp
end
function banner(text,position,color,player,forever)
	if forever then
		return player.surface.create_entity{name="flying-text-banner-forever_lua", position=position, text=text, color=color}
	else
		return player.surface.create_entity{name="flying-text-banner_lua", position=position, text=text, color=color}
	end	
end

function get_variable(lamp)
	variable = {}
	variable.lamp = lamp
	variable.condition = {}
	variable.condition.value = lamp.condition_state
	variable.condition.changed = lamp.condition_state == not lamp.last_condition_state
	variable.lua_state = lamp.lua_state
	global.lamp_global = table_or_new(global.lamp_global)
	variable.global = global.lamp_global
	return variable
end

function find_lamp(lamps,lampA)
	for _,lampB in pairs(lamps) do
		if is_valid(lampA) and is_valid(lampB.lua_lamp) and lampB.lua_lamp == lampA then
			return lampB
		end
	end
end

function new_gui(player,lamp)
	player_gui = player.gui.left
	gui = gui_or_new(player_gui,"lua_lamp",{type="frame", name="lua_lamp", caption={"msg-window-title"}, direction="vertical" })
	checkboxes = gui_or_new(gui,"checkboxes",{type="flow", name="checkboxes",direction="horizontal"})
	lua_repeat = gui_or_new(checkboxes,"lua_repeat",{type="checkbox", name="lua_repeat",caption={"msg-checkbox-repeat"}, state = lamp.repeat_command})
	lua_repeat = lamp.repeat_command
	lua_loop = gui_or_new(checkboxes,"lua_loop",{type="checkbox", name="lua_loop", caption={"msg-checkbox-loop"}, state = lamp.loop })
	lua_loop = lamp.loop
	lua_post = gui_or_new(checkboxes,"lua_post",{type="checkbox", name="lua_post", caption={"msg-checkbox-post"}, state = lamp.post })
	lua_post = lamp.post
	command = gui_or_new(gui,"command",{type="flow", name="command",direction="horizontal"})
	lua_command = gui_or_new(command,"lua_command",{type="textfield", name="lua_command", text=lamp.command , style="wide_textbox_style_lua"})
	lua_command.text = lamp.command
	lua_save = gui_or_new(gui,"lua_save",{type="button", name="lua_save", caption={"msg-button-save"}, })
	return gui
end

function update_gui(gui,lamp)
	if gui ~= nil and is_valid(lamp) then
		gui.checkboxes.lua_repeat.state = lamp.repeat_command
		gui.checkboxes.lua_loop.state = lamp.loop
		gui.checkboxes.lua_post.state = lamp.post
		gui.command.lua_command.text = lamp.command
	end
end

function update_lamp(gui,lamp)
	if gui ~= nil then
		lamp.repeat_command = gui.checkboxes.lua_repeat.state
		lamp.loop = gui.checkboxes.lua_loop.state
		lamp.post = gui.checkboxes.lua_post.state
		debug_log(gui.command.lua_command.text, 3)
		lamp.command = gui.command.lua_command.text
	end
end

function gui_or_new(parent,name,new_element)
	if parent[name] == nil then
		debug_log(name, 3)
		parent.add(new_element)
	end
	
	return parent[name]
end

function table_or_new(table_a)
	if table_a == nil then
		return {}
	else
		return table_a
	end
end
	
function is_valid(entity)
	return (entity ~= nil and entity.valid)
end

function set_debug(value)
	global.debug_level = value
end

function debug_log(message, level)

	if not level then
		level = 0
	end
	if global.debug_level == nil then set_debug(0) end
	if global.debug_level >= level then
		if not message then
			 message = "nil"
		elseif message == true then
			message = "true"
		elseif message == false then
			message = "false"
		end
		for _,player in pairs(game.players) do
			player.print(game.tick .. ": " .. message)
		end
	end
end