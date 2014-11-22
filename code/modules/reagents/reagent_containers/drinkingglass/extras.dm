/obj/item/weapon/reagent_containers/drinking/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/glass_extra))
		var/obj/item/weapon/glass_extra/GE = I
		if(!leftitem && can_add_extra(GE, "left"))
			leftitem = GE
			user.remove_from_mob(GE)
			GE.loc = src
			user << "\blue You add \the [I] to \the [src]."
			update_icon()
		else if(!rightitem && can_add_extra(GE, "right"))
			rightitem = GE
			user.remove_from_mob(GE)
			GE.loc = src
			user << "\blue You add \the [I] to \the [src]."
			update_icon()
		else
			user << "\red There's no space to put \the [I] on \the [src]!"
	else
		return ..()

/obj/item/weapon/reagent_containers/drinking/attack_hand(mob/user as mob)
	if(src != user.get_inactive_hand())
		return ..()
	
	if(!leftitem && !rightitem)
		user << "There's nothing on the glass to remove!"
		return
	
	var/choice = input(user, "What would you like to remove from the glass?") as null|anything in list(leftitem, rightitem)
	if(!choice)
		return
	
	if(choice == leftitem)
		if(user.put_in_active_hand(leftitem))
			user << "\blue You remove \the [leftitem] from \the [src]."
			leftitem = null
	else if(choice == rightitem)
		if(user.put_in_active_hand(rightitem))
			user << "\blue You remove \the [rightitem] from \the [src]."
			rightitem = null
	else
		user << "Something went wrong, please try again."
	
	update_icon()

/obj/item/weapon/glass_extra
	name = "generic glass addition"
	desc = "This goes on a glass."
	var/glass_addition
	var/glass_desc
	var/glass_color
	w_class = 1
	icon = 'icons/procedural_drink.dmi'

/obj/item/weapon/glass_extra/stick
	name = "stick"
	desc = "This goes in a glass."
	glass_addition = "stick"
	glass_desc = "There is a stick in the glass."
	icon_state = "stick"

/obj/item/weapon/glass_extra/straw
	name = "straw"
	desc = "This goes in a glass."
	glass_addition = "straw"
	glass_desc = "There is a straw in the glass."
	icon_state = "straw"

/obj/item/weapon/glass_extra/edible/attack(mob/M as mob, mob/user as mob, def_zone)
	if(M == user)
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.species.flags & IS_SYNTHETIC)
				H << "\red You have a monitor for a head, where do you think you're going to put that?"
				return

		M << "\blue You eat \the [src]."
		playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
		del(src)
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

		playsound(M.loc,'sound/items/eatfood.ogg', rand(10,50), 1)
		del(src)

	return 0

/obj/item/weapon/glass_extra/edible/lemonslice
	name = "lemon slice"
	glass_addition = "slice"
	glass_color = "#FFFF00"
	glass_desc = "There is a lemon slice on the rim."
	icon_state = "lemonslice"

/obj/item/weapon/glass_extra/edible/limeslice
	name = "lime slice"
	glass_addition = "slice"
	glass_color = "#00FF00"
	glass_desc = "There is a lime slice on the rim."
	icon_state = "limeslice"

/obj/item/weapon/glass_extra/edible/orangeslice
	name = "orange slice"
	glass_addition = "slice"
	glass_color = "#FF7F00"
	glass_desc = "There is an orange slice on the rim."
	icon_state = "orangeslice"