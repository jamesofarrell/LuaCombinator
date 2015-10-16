require("defines")
require("util")
require("new_class")
require("output")


on_built_entity = function (event)
	if is_valid(event.created_entity) and event.created_entity.name == "lua-combinator" then
		
		if global.lamps == nil then 
			global.lamps = {} 
		end
		
		lamp = {}
		lamp.repeat_command = false
		lamp.loop = false
		lamp.post = false
		lamp.command = ""
		lamp.lua_state = {}
		lamp.player = game.players[event.player_index]
		lamp.position = event.created_entity.position
		lamp.lua_lamp = event.created_entity
		
		
		lamp.last_condition_state = false
		lamp.condition_state = false
		
		player = lamp.player
		surface = player.surface
		lamp.output = output:new(player.surface.create_entity{name = "constant-combinator-trans_lua", position = event.created_entity.position, force=player.force})
		lamp.output.entity.connect_neighbour{ wire=defines.circuitconnector.red, target_entity=lamp.lua_lamp}
		lamp.output.entity.connect_neighbour{ wire=defines.circuitconnector.green, target_entity=lamp.lua_lamp}
		
		update_lamp_entities(lamp)
		
		--defines.circuitconnector.red or defines.circuitconnector.green
		table.insert(global.lamps,lamp)
	end
	
end

on_tick = function (event)
	if global.lamps == nil then return end
	
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
	if event.tick%30==23 then
		to_delete = {}
		for i,lamp in ipairs(global.lamps) do
			if not is_valid(lamp.lua_lamp) then
				table.insert(to_delete,i)
			else
				update_condition_state(lamp)
				if (lamp.condition_state and (lamp.repeat_command or not lamp.last_condition_state)) or (not lamp.condition_state and lamp.post and lamp.last_condition_state) then
					debug_log("lamp go!", 3)
					update_lamp_entities(lamp)
					
					if lamp.loop then
						run_loop_command(lamp)
					else
						run_command(lamp)
					end
				end
				lamp.last_condition_state = lamp.condition_state
			end
		end
		for i,j in ipairs(to_delete) do
			temp_lamp = global.lamps[j-i+1]
			if temp_lamp.output and is_valid(temp_lamp.output.entity) then
				temp_lamp.output.entity.destroy()
			end
			if is_valid(temp_lamp.chest) then
				temp_lamp.chest.destroy()
			end
			table.remove(global.lamps,j-i+1)
		end
	end
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
		end
	end
end

game.on_event(defines.events.on_gui_click, on_gui_click)

game.on_event(defines.events.on_tick, on_tick)

game.on_load(on_load)

game.on_event(defines.events.on_built_entity, on_built_entity)
game.on_event(defines.events.on_robot_built_entity, on_built_entity)


function update_lamp_entities(lamp)
	if lamp ~= nil then
		lamp.entities = {}
		temp_entities = lamp.player.surface.find_entities({{lamp.position.x - 1, lamp.position.y - 1}, {lamp.position.x + 1, lamp.position.y + 1}})
		for _,entity in pairs(temp_entities) do
			if is_valid(entity) and (entity.position.x ~= lamp.position.x or entity.position.y ~= lamp.position.y) then
				table.insert(lamp.entities, entity)
			end
		end
	end
end

function update_condition_state(lamp)
	lamp.condition_state = get_condition(lamp.lua_lamp,1)
end

function get_condition(lua_lamp,colour)
	return lua_lamp.get_circuit_condition(colour).fulfilled
end

script_headder = "condition = global.variable.condition; output = global.variable.lamp.output;  player = global.variable.lamp.player; local state = global.variable.lamp.lua_state; local global = global.variable.global; "

function run_command(lamp) -- player.print("Hello World!")
	if lamp.command ~= nil and lamp.command ~= "" then
		debug_log("Run " .. lamp.command, 3)
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
end


function run_loop_command(lamp) -- if (entity.name == "rocket-silo") then player.print("lift off!"); entity.launch_rocket() end
	global.variable = get_variable(lamp)
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
end
function banner(text,position,color,player)
	player.surface.create_entity{name="flying-text-banner_lua", position=position, text="Hello", color=color}
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
	if global.debug_level == nil then set_debug(0) end
	if global.debug_level >= level then
		if message == nil then
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