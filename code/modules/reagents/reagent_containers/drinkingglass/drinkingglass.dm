#define DRINK_ICON_FILE 'icons/procedural_drink.dmi'

/obj/item/weapon/reagent_containers/drinking/verb/ptest()
	set src in view()
	usr << "*----*"
	if(leftitem) usr << leftitem
	if(rightitem) usr << rightitem
	
	if(reagents.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!((R.id == "ice") || ("ice" in R.glass_special))) // if it's not a cup of ice, and it's not already supposed to have ice in, see if the bartender's put ice in it
			if(reagents.has_reagent("ice", reagents.total_volume / 10)) // 10% ice by volume
				usr << "ice"
		
		if(!("fizz" in R.glass_special))
			var/totalfizzy = 0
			for(var/datum/reagent/re in reagents.reagent_list)
				usr << "[re.name]: [english_list(re.glass_special)]"
				if("fizz" in re.glass_special)
					usr << "[re.name] is fizzy, adding [re.volume]"
					totalfizzy += re.volume
			usr << "totalfizz = [totalfizzy]; 20% is [reagents.total_volume / 5]"
	usr << "*----*"

/obj/item/weapon/reagent_containers/drinking
	name = "glass" // Name when empty
	var/base_name = "glass" // Name to put in front of drinks, i.e. "[base_name] of [contents]"
	desc = "A generic drinking glass." // Description when empty
	icon = DRINK_ICON_FILE
	var/base_icon = "square" // Base icon name
	volume = 30
	var/gulp_size = 5
	
	var/list/filling_states
	
	var/obj/item/weapon/glass_extra/leftitem = null
	var/obj/item/weapon/glass_extra/rightitem = null
	
	var/list/center_of_mass = list("x"=16, "y"=8)
	
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(5,10,15,30)
	flags = FPRINT | TABLEPASS | OPENCONTAINER

/obj/item/weapon/reagent_containers/drinking/examine(mob/M as mob)
	..()
	
	if(leftitem)
		M << leftitem.glass_desc
	
	if(rightitem)
		M << rightitem.glass_desc
	
	if(reagents.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		if(!((R.id == "ice") || ("ice" in R.glass_special))) // if it's not a cup of ice, and it's not already supposed to have ice in, see if the bartender's put ice in it
			if(reagents.has_reagent("ice", reagents.total_volume / 10)) // 10% ice by volume
				M << "There is some ice floating in the drink."
		
		if(!("fizz" in R.glass_special))
			var/totalfizzy = 0
			for(var/datum/reagent/re in reagents.reagent_list)
				if("fizz" in re.glass_special)
					totalfizzy += re.volume
			if(totalfizzy >= reagents.total_volume / 5) // 20% fizzy by volume
				M << "It is fizzing slightly."

/obj/item/weapon/reagent_containers/drinking/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity) return
	
	// Placing on tables
	if(params && istype(A, /obj/structure/table) && center_of_mass.len)
		//Places the item on a grid
		var/list/mouse_control = params2list(params)
		var/cellnumber = 4

		var/mouse_x = text2num(mouse_control["icon-x"])
		var/mouse_y = text2num(mouse_control["icon-y"])

		var/grid_x = round(mouse_x, 32/cellnumber)
		var/grid_y = round(mouse_y, 32/cellnumber)

		if(mouse_control["icon-x"])
			var/sign = mouse_x - grid_x != 0 ? sign(mouse_x - grid_x) : -1 //positive if rounded down, else negative
			pixel_x = grid_x - center_of_mass["x"] + sign*16/cellnumber //center of the cell
		if(mouse_control["icon-y"])
			var/sign = mouse_y - grid_y != 0 ? sign(mouse_y - grid_y) : -1
			pixel_y = grid_y - center_of_mass["y"] + sign*16/cellnumber
	else if(istype(A, /obj))
		var/obj/target = A
		// Reagent transfers
		if(istype(target, /obj/structure/reagent_dispensers)) //A dispenser. Transfer FROM it TO us.
		
			if(!target.reagents.total_volume)
				user << "\red [target] is empty."
				return

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "\red [src] is full."
				return

			var/trans = target.reagents.trans_to(src, target:amount_per_transfer_from_this)
			user << "\blue You fill [src] with [trans] units of the contents of [target]."

		else if(target.is_open_container()) //Something like a glass. Player probably wants to transfer TO it.
			if(!reagents.total_volume)
				user << "\red [src] is empty."
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "\red [target] is full."
				return

			var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "\blue You transfer [trans] units of the solution to [target]."

		return ..()

/obj/item/weapon/reagent_containers/drinking/New()
	..()
		
	icon_state = base_icon
	
/obj/item/weapon/reagent_containers/drinking/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/drinking/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/drinking/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/drinking/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/drinking/proc/can_add_extra(obj/item/weapon/glass_extra/GE, side)
	if("[base_icon]_[GE.glass_addition][side]" in icon_states(DRINK_ICON_FILE))
		return 1
	
	return 0

/obj/item/weapon/reagent_containers/drinking/update_icon()
	overlays.Cut()
		
	if (reagents.reagent_list.len > 0)
		var/datum/reagent/R = reagents.get_master_reagent()
		name = "[base_name] of [R.glass_name ? R.glass_name : "something"]"
		desc = R.glass_desc ? R.glass_desc : initial(desc)
		
		var/list/under_liquid = list()
		var/list/over_liquid = list()
		
		var/amnt = 100
		var/percent = round((reagents.total_volume / volume) * 100)
		for(var/k in filling_states)
			if(percent <= k)
				amnt = k
				break
		
		if(!("ice" in R.glass_special))
			if(reagents.has_reagent("ice", reagents.total_volume / 10)) // 10% ice by volume
				over_liquid += "[base_icon][amnt]_ice"
		
		if(!("fizz" in R.glass_special))
			var/totalfizzy = 0
			for(var/datum/reagent/re in reagents.reagent_list)
				if("fizz" in re.glass_special)
					totalfizzy += re.volume
			if(totalfizzy >= (reagents.total_volume / 5)) // 20% fizzy by volume
				over_liquid += "[base_icon][amnt]_fizz"
		
		for(var/S in R.glass_special)
			if("[base_icon]_[S]" in icon_states(DRINK_ICON_FILE))
				under_liquid += "[base_icon]_[S]"
			else if("[base_icon][amnt]_[S]" in icon_states(DRINK_ICON_FILE))
				over_liquid += "[base_icon][amnt]_[S]"
		
		for(var/k in under_liquid)
			var/image/I = image(DRINK_ICON_FILE, src, k)
			overlays += I
			
		var/image/filling
		// if the fancy icon's available, use it, otherwise fall back on solid color
		if("[R.glass_iconmod][base_icon][amnt]" in icon_states(DRINK_ICON_FILE))
			filling = image(DRINK_ICON_FILE, src, "[R.glass_iconmod][base_icon][amnt]")
		else
			filling = image(DRINK_ICON_FILE, src, "[base_icon][amnt]")
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling
		
		for(var/k in over_liquid)
			var/image/I = image(DRINK_ICON_FILE, src, k)
			overlays += I
	else
		name = initial(name)
		desc = initial(desc)
	
	if(leftitem)
		var/image/I = image(DRINK_ICON_FILE, src, "[base_icon]_[leftitem.glass_addition]left")
		overlays += I
		
	if(rightitem)
		var/image/I = image(DRINK_ICON_FILE, src, "[base_icon]_[rightitem.glass_addition]right")
		overlays += I

/obj/item/weapon/reagent_containers/drinking/attack(mob/M as mob, mob/user as mob, def_zone)
	var/datum/reagents/R = src.reagents

	if(!R.total_volume || !R)
		user << "\red \The [src] is empty!"
		return 0

	if(M == user)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				H << "\red You have a monitor for a head, where do you think you're going to put that?"
				return

		M << "\blue You swallow a gulp from \the [src]."
		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		update_icon()
		return 1
	else if( istype(M, /mob/living/carbon/human) )

		var/mob/living/carbon/human/H = M
		if(H.species.flags & IS_SYNTHETIC)
			H << "\red They have a monitor for a head, where do you think you're going to put that?"
			return

		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] attempts to feed [M] [src].", 1)
		if(!do_mob(user, M)) return
		for(var/mob/O in viewers(world.view, user))
			O.show_message("\red [user] feeds [M] [src].", 1)

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey]) Reagents: [reagentlist(src)]</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] to [M.name] ([M.ckey]) Reagents: [reagentlist(src)]</font>")
		msg_admin_attack("[key_name(user)] fed [key_name(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

		if(reagents.total_volume)
			reagents.trans_to_ingest(M, gulp_size)

		playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
		update_icon()
		return 1

	return 0

#undef DRINK_ICON_FILE