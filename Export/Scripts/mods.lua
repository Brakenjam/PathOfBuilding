if not loadStatFile then
	dofile("statdesc.lua")
end
loadStatFile("stat_descriptions.txt")

function table.containsId(table, element)
  for _, value in pairs(table) do
    if value.Id == element then
      return true
    end
  end
  return false
end

local function writeMods(outName, condFunc)
	local out = io.open(outName, "w")
	out:write('-- This file is automatically generated, do not edit!\n')
	out:write('-- Item data (c) Grinding Gear Games\n\nreturn {\n')
	for mod in dat("Mods"):Rows() do
		if condFunc(mod) then
			if mod.Domain == 16 and string.match(outName, "Item") then
				if mod.SpawnTags[1].Id == "abyss_jewel" and mod.SpawnTags[2].Id == "jewel" and #mod.SpawnTags == 3 then
					goto continue
				end
			elseif mod.Domain == 16 and string.match(outName, "JewelAbyss") then
				if not table.containsId(mod.SpawnTags, "abyss_jewel") then
					print("baz")
					goto continue
				end
			elseif mod.Domain == 16 and string.match(outName, "Jewel") then
				if not table.containsId(mod.SpawnTags, "jewel") then
					print("qux")
					goto continue
				end
			end
			local stats, orders = describeMod(mod)
			if #orders > 0 then
				out:write('\t["', mod.Id, '"] = { ')
				if mod.GenerationType == 1 then
					out:write('type = "Prefix", ')
				elseif mod.GenerationType == 2 then
					out:write('type = "Suffix", ')
				elseif mod.GenerationType == 5 then
					out:write('type = "Corrupted", ')
				end
				out:write('affix = "', mod.Name, '", ')
				out:write('"', table.concat(stats, '", "'), '", ')
				out:write('statOrderKey = "', table.concat(orders, ','), '", ')
				out:write('statOrder = { ', table.concat(orders, ', '), ' }, ')
				out:write('level = ', mod.Level, ', group = "', mod.Family, '", ')
				out:write('weightKey = { ')
				for _, tag in ipairs(mod.SpawnTags) do
					out:write('"', tag.Id, '", ')
				end
				out:write('}, ')
				out:write('weightVal = { ', table.concat(mod.SpawnWeights, ', '), ' }, ')
				out:write('weightMultiplierKey = { ')
				for _, tag in ipairs(mod.GenerationWeightTags) do
					out:write('"', tag.Id, '", ')
				end
				out:write('}, ')
				out:write('weightMultiplierVal = { ', table.concat(mod.GenerationWeightValues, ', '), ' }, ')
				if mod.Tags[1] then
					out:write('tags = { ')
					for _, tag in ipairs(mod.Tags) do
						out:write('"', tag.Id, '", ')
					end
					out:write('}, ')
				end
				out:write('},\n')
			else
				print("Mod '"..mod.Id.."' has no stats")
			end
		end
		::continue::
	end
	out:write('}')
	out:close()
end

writeMods("../Data/3_0/ModItem.lua", function(mod)
	return (mod.Domain == 1 or mod.Domain == 16) and (mod.GenerationType == 1 or mod.GenerationType == 2 or mod.GenerationType == 5)
end)
writeMods("../Data/3_0/ModFlask.lua", function(mod)
	return mod.Domain == 2 and (mod.GenerationType == 1 or mod.GenerationType == 2)
end)
writeMods("../Data/3_0/ModJewel.lua", function(mod)
	return (mod.Domain == 10 or mod.Domain == 16) and (mod.GenerationType == 1 or mod.GenerationType == 2 or mod.GenerationType == 5)
end)
writeMods("../Data/3_0/ModJewelAbyss.lua", function(mod)
	return (mod.Domain == 13 or mod.Domain == 16) and (mod.GenerationType == 1 or mod.GenerationType == 2 or mod.GenerationType == 5)
end)
writeMods("../Data/3_0/ModJewelCluster.lua", function(mod)
	return mod.Domain == 21 and (mod.GenerationType == 1 or mod.GenerationType == 2 or mod.GenerationType == 5)
end)

print("Mods exported.")