
/datum/map/exodus
	name = "Exodus"
	full_name = "NSS Exodus"
	path = "exodus"

	station_levels = list(1,5)
	admin_levels = list(2)
	contact_levels = list(1,5)
	player_levels = list(1,3,4,5,6)

#ifdef UNIT_TEST
	exempt_areas = list(
		/area/medical/genetics = NO_APC,
		/area/engineering/atmos/storage = NO_SCRUBBER | NO_VENT,
		/area/server = NO_SCRUBBER
	)
#endif
