/obj/structure/game/piece/checker
	name = "checkers piece"
	desc = "It's a checkers piece."
	var/isking = 0

/obj/structure/game/piece/checker/update_icon()
	..()
	if(isking)
		icon_state = "[icon_state]_king"

/obj/structure/game/piece/checker/DblClick()
	if(!check_control(usr)) return
	isking = !isking
	if(isking)
		visible_message("\The [usr] converts \the [src] into a king.")
		name = "[initial(name)] king"
	else
		visible_message("\The [usr] converts \the [src] into a standard piece.")
		name = initial(name)
	update_icon()

/obj/structure/game/piece/checker/black
	name = "black checker"
	icon_state = "checker_b"
	iswhite = 0

/obj/structure/game/piece/checker/white
	name = "white checker"
	icon_state = "checker_w"
	iswhite = 1