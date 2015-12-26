
#include "use_map.dm"

var/datum/map/using_map
var/list/all_maps = list()

/hook/startup/proc/initialise_map_list()
	for(var/type in typesof(/datum/map) - /datum/map)
		var/datum/map/M = new type
		if(type == USING_MAP_DATUM)
			using_map = M
			M.setup_map()
		if(!M.path)
			world << "<span class=danger>Map '[M]' does not have a defined path, not adding to map list!</span>"
			world.log << "Map '[M]' does not have a defined path, not adding to map list!"
		else
			all_maps[M.path] = M
	return 1

/datum/map
	var/name = "Unnamed Map"
	var/full_name = "Unnamed Map"

	var/path

	proc/setup_map()
