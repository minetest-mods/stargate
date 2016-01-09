local function swap_gate_node(pos,name,dir)
	local node = core.get_node(pos)
	local meta = core.get_meta(pos)
	local meta0 = meta:to_table()
	node.name = name
	node.param2=dir
	core.set_node(pos,node)
	meta:from_table(meta0)
end

local function addGateNode(gateNodes, pos)
	gateNodes[#gateNodes+1] = vector.new(pos)
end

local function placeGate(player,pos)
	local dir = minetest.dir_to_facedir(player:get_look_dir())
	local pos1 = vector.new(pos)
	local gateNodes = {}
	addGateNode(gateNodes, pos1)
	if dir == 1
	or dir == 3 then
		pos1.z=pos1.z+1
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z-2
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z+1
		pos1.y=pos1.y+1
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z+1
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z-2
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z+1
		pos1.y=pos1.y+1
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z+1
		addGateNode(gateNodes, pos1)
		pos1.z=pos1.z-2
		addGateNode(gateNodes, pos1)
	else
		pos1.x=pos1.x+1
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x-2
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x+1
		pos1.y=pos1.y+1
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x+1
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x-2
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x+1
		pos1.y=pos1.y+1
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x+1
		addGateNode(gateNodes, pos1)
		pos1.x=pos1.x-2
		addGateNode(gateNodes, pos1)
	end
	for i=1,9 do
		if core.get_node(gateNodes[i]).name ~= "air" then
			print("not enough space")
			return false
		end
	end
	core.set_node(pos, {name="stargate:gatenode_off", param2=dir})
	local player_name = player:get_player_name()
	local meta = core.get_meta(pos)
	meta:set_string("infotext", "Stargate\rOwned by: "..player_name)
	meta:set_int("gateActive", 0)
	meta:set_string("owner", player_name)
	meta:set_string("dont_destroy", "false")
	stargate.registerGate(player_name, pos, dir)
	return true
end

local function removeGate(pos)
	local meta = core.get_meta(pos)
	if meta:get_string("dont_destroy") == "true" then
		-- when swapping it
		return
	end
	stargate.unregisterGate(meta:get_string("owner"), pos)
end

function stargate.activateGate(pos)
	local node = core.get_node(pos)
	local dir=node.param2
	local meta = core.get_meta(pos)
	meta:set_int("gateActive",1)
	meta:set_string("dont_destroy","true")
	minetest.sound_play("gateOpen", {pos = pos, max_hear_distance = 72,})
	swap_gate_node(pos,"stargate:gatenode_on",dir)
	meta:set_string("dont_destroy","false")
end

function stargate.deactivateGate(pos)
	local node = core.get_node(pos)
	local dir=node.param2
	local meta = core.get_meta(pos)
	meta:set_int("gateActive",0)
	meta:set_string("dont_destroy","true")
	minetest.sound_play("gateClose", {pos = pos, gain = 1.0,loop = false, max_hear_distance = 72,})
	swap_gate_node(pos,"stargate:gatenode_off",dir)
	meta:set_string("dont_destroy","false")
end

local function gateCanDig(pos, player)
	local meta = core.get_meta(pos)
	return meta:get_string("dont_destroy") ~= "true"
		and player:get_player_name() == meta:get_string("owner")
end

local sg_collision_box = {
	type = "fixed",
	fixed={{-1.5,-0.5,-3/20,1.5,2.5,3/20},},
}

local sg_selection_box = {
	type = "fixed",
	fixed={{-1.5,-0.5,-3/20,1.5,2.5,3/20},},
}

local sg_groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1}
local sg_groups1 = {snappy=2,choppy=2,oddly_breakable_by_hand=2}

minetest.register_node("stargate:gatenode_on",{
	tiles = {
		{name = "gray.png"},
		{
		name = "puddle_animated2.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 2.0,
			},
		},
		{name = "0003.png"},
		{name = "0002.png"},
		{name = "0001.png"},
		{name = "null.png"},
	},
	drawtype = "mesh",
	mesh = "stargate.obj",
	visual_scale = 3.0,
	groups = sg_groups,
	drop="stargate:gatenode_off",
	paramtype2 = "facedir",
	paramtype = "light",
	light_source = 10,
	selection_box = sg_selection_box,
	collision_box = sg_collision_box,
	can_dig = gateCanDig,
	on_destruct = removeGate,
	on_rightclick=stargate.gateFormspecHandler,
})

minetest.register_node("stargate:gatenode_off",{
	description = "Stargate",
	inventory_image = "stargate.png",
	wield_image = "stargate.png",
	tiles = {
		{name = "gray.png"},
		{name = "null.png"},
		{name = "0003.png"},
		{name = "0002.png"},
		{name = "0001.png"},
		{name = "null.png"},
	},
	groups = sg_groups1,
	paramtype2 = "facedir",
	paramtype = "light",
	drawtype = "mesh",
	mesh = "stargate.obj",
	visual_scale = 3.0,
	selection_box = sg_selection_box,
	collision_box = sg_collision_box,
	can_dig = gateCanDig,
	on_destruct = removeGate,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if placeGate(placer,pos)==true then
			itemstack:take_item(1)
			return itemstack
		else
			return
		end
	end,
	on_rightclick=stargate.gateFormspecHandler,
})

minetest.register_abm({
	nodenames = {"stargate:gatenode_on"},
	interval = 1,
	chance = 1,
	action = function(pos)
		--local owner
		for _,object in pairs(core.get_objects_inside_radius(pos, 1)) do
			if object:is_player() then
				local player_name = object:get_player_name()
				local gate = stargate.findGate(pos)
				if not gate then
					print("Gate is not registered!")
					return
				end
				--owner = owner or core.get_meta(pos):get_string("owner")
				if gate.type == "private"
				and player_name ~= core.get_meta(pos):get_string("owner") then
					return
				end
				local pos1 = vector.new(gate.destination)
				if not stargate.findGate(pos1) then
					gate.destination = nil
					stargate.deactivateGate(pos)
					stargate.save_data(core.get_meta(pos):get_string("owner"))
					return
				end
				local dir1 = gate.destination_dir
				local dest_angle
				if dir1 == 0 then
					pos1.z = pos1.z-2
					dest_angle = 180
				elseif dir1 == 1 then
					pos1.x = pos1.x-2
					dest_angle = 90
				elseif dir1 == 2 then
					pos1.z=pos1.z+2
					dest_angle = 0
				elseif dir1 == 3 then
					pos1.x = pos1.x+2
					dest_angle = -90
				end
				object:moveto(pos1,false)
				object:set_look_yaw(math.rad(dest_angle))
				core.sound_play("enterEventHorizon", {pos = pos, max_hear_distance = 72})
			end
		end
	end
})
