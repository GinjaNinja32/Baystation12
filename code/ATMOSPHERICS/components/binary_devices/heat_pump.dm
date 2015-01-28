var/global/HEAT_PUMP_MULT = 2.5
/client/verb/SetPumpMultiplier(m as num)
	HEAT_PUMP_MULT = m

/obj/machinery/atmospherics/binary/heat_pump
	name = "heat pump"
	icon = 'icons/obj/heat_pump.dmi'
	icon_state = "heat_pump"
	density = 1

	var/initial_volume = 200

	use_power = 0
	idle_power_usage = 0

	var/max_power_rating = 20000
	var/power_setting = 100
	var/target_temperature = T20C
	var/target_is_output = 0
	var/pumping = 0
	var/opened = 0

/obj/machinery/atmospherics/binary/heat_pump/New()
	..()

	air1.volume = 200
	air2.volume = 200

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/heat_pump(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)

	power_rating = max_power_rating * (power_setting / 100)


/obj/machinery/atmospherics/binary/heat_pump/update_icon()
	var/new_state = icon_state
	if(network1 && network2)
		if(src.use_power && pumping)
			new_state = "heat_pump_active"
		else
			new_state = "heat_pump"
	else
		new_state = "heat_pump_[(network1 ? 1 : 0) | (network2 ? 2 : 0)]"

	if(new_state != icon_state)
		icon_state = new_state

/obj/machinery/atmospherics/binary/heat_pump/attack_ai(mob/user as mob)
	src.ui_interact(user)

/obj/machinery/atmospherics/binary/heat_pump/attack_hand(mob/user as mob)
	src.ui_interact(user)

/obj/machinery/atmospherics/binary/heat_pump/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	// this is the data which will be sent to the ui
	var/data[0]
	data["on"] = use_power ? 1 : 0
	data["input_pressure"] = round(air1.return_pressure())
	data["input_temperature"] = round(air1.temperature)
	data["output_pressure"] = round(air2.return_pressure())
	data["output_temperature"] = round(air2.temperature)
	data["target_output"] = target_is_output
	data["min_temperature"] = 0
	data["max_temperature"] = round(T20C+500)
	data["target_temperature"] = round(target_temperature)
	data["powerSetting"] = power_setting

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "heat_pump.tmpl", "Heat Pump", 440, 300)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/atmospherics/binary/heat_pump/Topic(href, href_list)
	if (href_list["toggleStatus"])
		src.use_power = !src.use_power
		update_icon()
	if(href_list["target"])
		switch(href_list["target"])
			if("in") target_is_output = 0
			if("out") target_is_output = 1
	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.target_temperature = min(src.target_temperature+amount, 1000)
		else
			src.target_temperature = max(src.target_temperature+amount, 0)
	if(href_list["setPower"]) //setting power to 0 is redundant anyways
		var/new_setting = between(0, text2num(href_list["setPower"]), 100)
		set_power_level(new_setting)

	src.add_fingerprint(usr)
	return 1

/obj/machinery/atmospherics/binary/heat_pump/process()
	..()
	if(stat & (NOPOWER|BROKEN) || !use_power)
		pumping = 0
		update_icon()
		return

	if (network1 && network2)
		var/cop = HEAT_PUMP_MULT * air1.temperature/air2.temperature
		if(target_is_output)
			if(air2.temperature < target_temperature) // output temp < target
				pumping = 1
				var/heat_transfer = max(air2.get_thermal_energy_change(target_temperature), 0)
				heat_transfer = min(heat_transfer, cop * power_rating)
				var/removed = air1.add_thermal_energy(-heat_transfer)
				var/added = air2.add_thermal_energy(-removed)
				world << "\The [src] removed [-removed] W of energy from air1, and added [added] W of energy to air2"
				use_power(power_rating)
				network1.update = 1
				network2.update = 1
			else
				pumping = 0
		else
			if(air1.temperature > target_temperature) // input temp > target
				pumping = 1
				var/heat_transfer = max(-air1.get_thermal_energy_change(target_temperature), 0)
				heat_transfer = min(heat_transfer, cop * power_rating)
				var/removed = air1.add_thermal_energy(-heat_transfer)
				var/added = air2.add_thermal_energy(-removed)
				world << "\The [src] removed [-removed] W of energy from air1, and added [added] W of energy to air2"
				use_power(power_rating)
				network1.update = 1
				network2.update = 1
			else
				pumping = 0
	else
		pumping = 0

	update_icon()

//upgrading parts
/obj/machinery/atmospherics/binary/heat_pump/RefreshParts()
	..()
	var/cap_rating = 0
	var/cap_count = 0
	var/manip_rating = 0
	var/manip_count = 0
	var/bin_rating = 0
	var/bin_count = 0

	for(var/obj/item/weapon/stock_parts/P in component_parts)
		if(istype(P, /obj/item/weapon/stock_parts/capacitor))
			cap_rating += P.rating
			cap_count++
		if(istype(P, /obj/item/weapon/stock_parts/manipulator))
			manip_rating += P.rating
			manip_count++
		if(istype(P, /obj/item/weapon/stock_parts/matter_bin))
			bin_rating += P.rating
			bin_count++
	cap_rating /= cap_count
	bin_rating /= bin_count
	manip_rating /= manip_count

	power_rating = initial(power_rating)*cap_rating			//more powerful
	air1.volume = max(initial(initial_volume) - 200, 0) + 200*bin_rating
	air2.volume = max(initial(initial_volume) - 200, 0) + 200*bin_rating
	set_power_level(power_setting)

/obj/machinery/atmospherics/binary/heat_pump/proc/set_power_level(var/new_power_setting)
	power_setting = new_power_setting
	power_rating = max_power_rating * (power_setting/100)

//dismantling code. copied from autolathe
/obj/machinery/atmospherics/binary/heat_pump/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O, /obj/item/weapon/screwdriver))
		opened = !opened
		user << "You [opened ? "open" : "close"] the maintenance hatch of \the [src]."
		return

	if (opened && istype(O, /obj/item/weapon/crowbar))
		dismantle()
		return

	..()

/obj/machinery/atmospherics/binary/heat_pump/examine(mob/user)
	..(user)
	if (opened)
		user << "The maintenance hatch is open."