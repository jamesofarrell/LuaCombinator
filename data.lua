data:extend({
  	{
		type = "item",
		name = "lua-combinator",
		icon = "__LuaCombinator__/lua-combinator-icon.png",
		flags = {"goes-to-quickbar"},
		subgroup = "circuit-network",
		order = "b[combinators]-l[lua-combinator]",
		place_result = "lua-combinator",
		stack_size = 50
	},
	
	{
		type = "recipe",
		name = "lua-combinator",
		enabled = "false",
		ingredients =
		{
			{"constant-combinator", 1},
			{"small-lamp", 1},
			{"advanced-circuit", 5}
		},
		result = "lua-combinator"
	},
	
	{
    type = "technology",
    name = "lua-combinator",
    icon = "__LuaCombinator__/lua-combinator-tech.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "lua-combinator"
      }
    },
    prerequisites = {"circuit-network", "advanced-electronics"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1}
      },
      time = 15
    },
    order = "a-d-d-z",
  },

	{
		type = "lamp",
		name = "lua-combinator",
		icon = "__LuaCombinator__/lua-combinator-icon.png",
		flags = {"placeable-neutral", "player-creation"},
		minable = {hardness = 0.2, mining_time = 0.5, result = "lua-combinator"},
		max_health = 55,
		corpse = "small-remnants",
		collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
		  type = "electric",
		  usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "1KW",
		light = {intensity = 0, size = 0},
		picture_off =
		{
		  filename = "__LuaCombinator__/lua-combinator-off.png",
		  priority = "high",
		  frame_count = 1,
		  axially_symmetrical = false,
		  direction_count = 1,
		  width = 61,
		  height = 50,
		  shift = {0.078125, 0.15625},
		},
		picture_on =
		{
		  filename = "__LuaCombinator__/lua-combinator-on.png",
		  priority = "high",
		  frame_count = 1,
		  axially_symmetrical = false,
		  direction_count = 1,
		  width = 61,
		  height = 50,
		  shift = {0.078125, 0.15625},
		},
		
	
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.828125, 0.328125},
        green = {0.828125, -0.078125},
      },
      wire =
      {
        red = {0.515625, -0.078125},
        green = {0.515625, -0.484375},
      }
    },

		circuit_wire_max_distance = 7.5
	},

	{
    type = "constant-combinator",
    name = "constant-combinator-trans_lua",
    icon = "__base__/graphics/icons/constant-combinator.png",
    flags = {"placeable-neutral"},
    max_health = 50,

    collision_box = {{0.0, 0.0}, {0.0, 0}},
	collision_mask = { "ghost-layer"},

    item_slot_count = 40,

    sprite =
    {
      filename = "__LuaCombinator__/trans.png",
      x = 0,
      width = 61,
	  height = 50,
      shift = {0.078125, 0.15625},
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0, 0.1},
        green = {0, -0.2},
      },
      wire =
      {
        red = {0, -0.1},
        green = {0, -0.2},
      }
    },
    circuit_wire_max_distance = 3,
	order="z"
  },
  
  {
    type = "flying-text",
    name = "flying-text-banner_lua",
    flags = {"not-on-map"},
    time_to_live = 30,
    speed = 0.0
  },
  
   {
    type = "flying-text",
    name = "flying-text-banner-forever_lua",
    flags = {"not-on-map"},
    time_to_live = -1, --2147483647,
    speed = 0.0
  },
  
  {
    type = "train-stop",
    name = "train-stop-trans_lua",
    icon = "__base__/graphics/icons/train-stop.png",
    flags = {"placeable-neutral", "player-creation", "filter-directions"},
    minable = {mining_time = 1, result = "train-stop"},
    max_health = 150,
    corpse = "medium-remnants",
    collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selection_box = {{-0.6, -0.6}, {0.6, 0.6}},
    drawing_box = {{-0.5, -3}, {0.5, 0.5}},
    tile_width = 2,
    tile_height = 2,
    animation_ticks_per_frame = 20,
    animations =
    {
      north =
      {
        filename = "__LuaCombinator__/trans.png",
        priority = "high",
        width = 0,
        height = 0,
        frame_count = 1,
        shift = {1.65, -0.9}
      },
      east =
      {
        filename = "__LuaCombinator__/trans.png",
        priority = "high",
        width = 0,
        height = 0,
        frame_count = 1,
        shift = {1.7, -1.5}
      },
      south =
      {
        filename = "__LuaCombinator__/trans.png",
        priority = "high",
        width = 0,
        height = 0,
        frame_count = 1,
        shift = {1.7, -1.4}
      },
      west =
      {
        filename = "__LuaCombinator__/trans.png",
        priority = "high",
        width = 0,
        height = 0,
        frame_count = 1,
        shift = {2, -0.8}
      }
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/train-stop.ogg", volume = 0.8 }
    },
	order = "zzz"
  },
})

data.raw["gui-style"].default["wide_textbox_style_lua"] =
    {
      type = "textfield_style",
      parent = "textfield_style",      
	  minimal_width = 300,
      maximal_width = 300,  
	}