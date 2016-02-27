/obj/light
	simulated = 0
	mouse_opacity = 0
	plane = DARK_PLANE
	appearance_flags = KEEP_TOGETHER
	icon = null
	icon_state = ""
	invisibility = SEE_INVISIBLE_NOLIGHTING
	pixel_x = -32
	pixel_y = -32
	blend_mode = BLEND_ADD

	var/image/light_overlay
	var/current_power = 1
	var/atom/movable/holder

/obj/light/New(var/newholder)
	holder = newholder
	light_overlay = image(icon = 'icons/planar_lighting/lighting_overlays.dmi', icon_state = "soft")
	light_overlay.blend_mode = BLEND_ADD
	light_overlay.mouse_opacity = 0
	light_overlay.plane = DARK_PLANE
	..()

/obj/light/Destroy()
	if(holder)
		moved_event.unregister(holder, src)
		dir_set_event.unregister(holder, src)
		destroyed_event.unregister(holder, src)
		if(holder.light_obj == src)
			holder.light_obj = null
		holder = null
	return .. ()

/obj/light/initialize()
	if(!istype(holder, /atom/movable))
		world << "DEBUG: [src] has holder [holder], is [holder.type]."
		qdel(src)
		return
	follow_holder()
	moved_event.register(holder, src, /obj/light/proc/follow_holder)
	dir_set_event.register(holder, src, /obj/light/proc/follow_holder_dir)
	destroyed_event.register(holder, src, /obj/light/proc/destroy_self)

/obj/light/proc/destroy_self()
	qdel(src)

/obj/light/proc/follow_holder_dir()
	if(istype(holder.loc, /mob))
		if(dir != holder.loc.dir) set_dir(holder.loc.dir)
	else
		if(dir != holder.dir) set_dir(holder.dir)

/obj/light/proc/follow_holder(var/force_update_bleed)
	var/prevloc = loc
	if(istype(holder.loc, /mob))
		loc = get_turf(holder)
	else
		loc = holder.loc
	follow_holder_dir()
	if((force_update_bleed || loc != prevloc) && istype(loc, /turf))
		update_bleed_masking()

/obj/light/proc/update_bleed_masking()

	overlays.Cut()
	overlays += light_overlay
	var/effective_range = ceil(current_power*0.75) // Value that the overlay is scaled by.
	if(effective_range <= 1)
		return
	var/turf/origin = get_turf(src)
	if(!istype(origin))
		return

	// We're using dview in a context it wasn't written for so gotta hardcode this.
	dview_mob.loc = origin
	dview_mob.see_invisible = 0
	var/list/visible_turfs = view(effective_range, dview_mob)
	dview_mob.loc = null

	// Get our general operating ranges.
	var/list/concealed_turfs = (range(effective_range, origin) - visible_turfs)

	// Mask off stuff that we 100% cannot see.
	for(var/turf/check in concealed_turfs)
		var/image/I = image(icon = 'icons/planar_lighting/over_dark.dmi')
		I.blend_mode = BLEND_SUBTRACT
		I.mouse_opacity = 0
		I.plane = DARK_PLANE
		I.pixel_x = ((check.x-origin.x)+1) * 32
		I.pixel_y = ((check.y-origin.y)+1) * 32
		overlays += I

	/* Working but unfinished.
	// Work out our ranges for corner/angled masking.
	var/list/corner_turfs = list()
	for(var/turf/check in visible_turfs)

		// Check if this is a turf we want to use in corner masking checks. Apply masking if needed.
		if(!check.blocks_light())
			continue

		for(var/checkdir in alldirs)
			var/turf/neighbor = get_step(check, checkdir)
			if(istype(neighbor) && (neighbor in concealed_turfs))
				var/edgecount = 0
				var/edgedirs = 0
				for(var/secondcheckdir in cardinal)
					var/turf/cardinal_neighbor = get_step(check, secondcheckdir)
					if(istype(cardinal_neighbor) && (cardinal_neighbor in visible_turfs) && !cardinal_neighbor.blocks_light())
						edgedirs |= secondcheckdir
						edgecount++
				if(edgecount >= 2) // Corner, apply mask.
					if(check.x == x)
						edgedirs &= ~(NORTH|SOUTH)
					if(check.y == y)
						edgedirs &= ~(EAST|WEST)
					if(edgedirs)
						// Calculate the needed angle for the mask.
						;
						// Determine which side it should be on.
						;
				break
	*/