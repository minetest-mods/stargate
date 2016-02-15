function swap_gate_node(pos,name,dir)
	local node = core.get_node(pos)
	local meta = core.get_meta(pos)
	local meta0 = meta:to_table()
	node.name = name
	node.param1=0
	node.param2=dir
	core.set_node(pos,node)
	meta:from_table(meta0)
end

function getDir (player)
	local dir=player:get_look_dir()
	if math.abs(dir.x)>math.abs(dir.z) then 
		if dir.x>0 then return 0 end
		return 1
	end
	if dir.z>0 then return 2 end
	return 3
end

function checkNode (pos)
	local node=core.get_node(pos)
	if node.name == "air" then return 0 end
	return 1
end

function addGateNode (gateNodes,i,pos)
	gateNodes[i].pos.x=pos.x
	gateNodes[i].pos.y=pos.y
	gateNodes[i].pos.z=pos.z
end

function placeGate (player,pos)
	local player_name=player:get_player_name()
	local dir=minetest.dir_to_facedir(player:get_look_dir())
	local pos1=pos
	local gateNodes={}
	for i=1,9,1 do
		gateNodes[i]={}
		gateNodes[i].pos={}
	end
	if dir==1 then 
			addGateNode(gateNodes,1,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,2,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,3,pos1)
			pos1.z=pos1.z+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,4,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,5,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,6,pos1)
			pos1.z=pos1.z+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,7,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,8,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,9,pos1)
	end
	if dir==3 then 
			addGateNode(gateNodes,1,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,3,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,2,pos1)
			pos1.z=pos1.z+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,4,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,6,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,5,pos1)
			pos1.z=pos1.z+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,7,pos1)
			pos1.z=pos1.z+1
			addGateNode(gateNodes,9,pos1)
			pos1.z=pos1.z-2
			addGateNode(gateNodes,8,pos1)
	end
	if dir==2 then  
			addGateNode(gateNodes,1,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,2,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,3,pos1)
			pos1.x=pos1.x+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,4,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,5,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,6,pos1)
			pos1.x=pos1.x+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,7,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,8,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,9,pos1)
			end
	if dir==0 then  
			addGateNode(gateNodes,1,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,3,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,2,pos1)
			pos1.x=pos1.x+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,4,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,6,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,5,pos1)
			pos1.x=pos1.x+1
			pos1.y=pos1.y+1
			addGateNode(gateNodes,7,pos1)
			pos1.x=pos1.x+1
			addGateNode(gateNodes,9,pos1)
			pos1.x=pos1.x-2
			addGateNode(gateNodes,8,pos1)
			end
	for i=1,9,1 do
		local node=core.get_node(gateNodes[i].pos)
		if node.name ~= "air" then return false end
	end
	core.set_node(gateNodes[1].pos,{name="stargate:gatenode_off", param1=0, param2=dir})
	local meta = core.get_meta(gateNodes[1].pos)
	meta:set_string("infotext", "Stargate\nOwned by: "..player_name)
	meta:set_string("gateNodes",minetest.serialize(gateNodes))
	meta:set_int("gateActive",0)
	meta:set_string("owner",player_name)
	meta:set_string("dont_destroy","false")
	stargate.registerGate(player_name,gateNodes[1].pos,dir)
	return true
end

function removeGate (pos)
	local meta = core.get_meta(pos)
	if meta:get_string("dont_destroy") == "true" then return end
	local player_name=meta:get_string("owner")
	local gateNodes=minetest.deserialize(meta:get_string("gateNodes"))
	if gateNodes ~= nil then
		stargate.unregisterGate(player_name,gateNodes[1].pos)
	end
end

function activateGate (pos)
	local node = core.get_node(pos)
	local dir=node.param2
	local meta = core.get_meta(pos)
	local gateNodes=minetest.deserialize(meta:get_string("gateNodes"))
	meta:set_int("gateActive",1)
	meta:set_string("dont_destroy","true")
	minetest.sound_play("gateOpen", {pos = pos, gain = 1.0,loop = false, max_hear_distance = 72,})
	swap_gate_node(gateNodes[1].pos,"stargate:gatenode_on",dir)
	meta:set_string("dont_destroy","false")
end

function deactivateGate (pos)
	local node = core.get_node(pos)
	local dir=node.param2
	local meta = core.get_meta(pos)
	local gateNodes=minetest.deserialize(meta:get_string("gateNodes"))
	meta:set_int("gateActive",0)
	meta:set_string("dont_destroy","true")
	minetest.sound_play("gateClose", {pos = pos, gain = 1.0,loop = false, max_hear_distance = 72,})
	swap_gate_node(gateNodes[1].pos,"stargate:gatenode_off",dir)
	meta:set_string("dont_destroy","false")
end

gateCanDig = function(pos,player)
	local player_name = player:get_player_name()
	local meta = core.get_meta(pos)
	if meta:get_string("dont_destroy") == "true" then return end
	local owner=meta:get_string("owner")
	if player_name==owner then return true
	else return false end
end

sg_collision_box = {
	type = "fixed",
	fixed={{-1.5,-0.5,-3/20,1.5,2.5,3/20},},
}

sg_selection_box = {
	type = "fixed",
	fixed={{-1.5,-0.5,-3/20,1.5,2.5,3/20},},
}

sg_groups = {snappy=2,choppy=2,oddly_breakable_by_hand=2,not_in_creative_inventory=1}
sg_groups1 = {snappy=2,choppy=2,oddly_breakable_by_hand=2}

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
	on_destruct = function (pos)
		removeGate(pos)
	end,
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
	on_destruct = function (pos)
		removeGate(pos)
	end,
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
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = core.get_meta(pos)
		for _,object in ipairs(core.get_objects_inside_radius(pos, 1)) do
			if object:is_player() then 
				local player_name = object:get_player_name()
				local owner=meta:get_string("owner")
				local gate=stargate.findGate (pos)
				if gate==nil then print("Gate is not registered!") return end
				local pos1={}
				pos1.x=gate["destination"].x
				pos1.y=gate["destination"].y
				pos1.z=gate["destination"].z
				local dest_gate=stargate.findGate (pos1)
				if dest_gate==nil then 
					gate["destination"]=nil
					deactivateGate(pos)
					stargate.save_data(owner)
					return
				end
				if player_name~=owner and gate["type"]=="private" then return end
				local dir1=gate["destination_dir"]
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
				core.sound_play("enterEventHorizon", {pos = pos, gain = 1.0,loop = false, max_hear_distance = 72,})
			end
		end
	end
}) 
