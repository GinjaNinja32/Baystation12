/obj/structure/game/button
	icon_state = "button"
	proc/activate()
		return
	attack_hand()
		activate()
	attack_ai()
		activate()

/obj/structure/game/button/icontoggle
	name = "piece appearance switcher"
	var/current = 1
	var/list/possible = list("", "holo_")
	activate()
		current = (current % possible.len) + 1
		var/C = possible[current]
		for(var/obj/structure/game/piece/P in src.loc.loc)
			P.style = C
			P.update_icon()

/obj/structure/game/button/clearboard
	name = "clear board button"
	activate()
		var/obj/whiteDead = locate(/obj/structure/game/dzone/white) in src.loc.loc
		var/obj/blackDead = locate(/obj/structure/game/dzone/black) in src.loc.loc
		for(var/obj/structure/game/piece/P in src.loc.loc)
			if(P.iswhite)
				P.loc = whiteDead.loc
			else
				P.loc = blackDead.loc
			P.pixel_x = 0
			P.pixel_y = 0

/obj/structure/game/button/spawner
	var/piecetype = null

	New()
		..()
		var/obj/structure/game/piece/P = piecetype
		name = "[initial(P.name)] spawner button"

	activate()
		var/obj/machinery/computer/HolodeckControl/HC = locate(/obj/machinery/computer/HolodeckControl) in view()
		HC.holographic_items += new piecetype(loc)

// Chess piece spawn buttons (for pawn promotion)
/obj/structure/game/button/spawner/black
	icon_state = "button_b"
/obj/structure/game/button/spawner/black/queen/piecetype = /obj/structure/game/piece/chess/black/queen
/obj/structure/game/button/spawner/black/bishop/piecetype = /obj/structure/game/piece/chess/black/bishop
/obj/structure/game/button/spawner/black/knight/piecetype = /obj/structure/game/piece/chess/black/knight
/obj/structure/game/button/spawner/black/rook/piecetype = /obj/structure/game/piece/chess/black/rook

/obj/structure/game/button/spawner/white
	icon_state = "button_w"
/obj/structure/game/button/spawner/white/queen/piecetype = /obj/structure/game/piece/chess/white/queen
/obj/structure/game/button/spawner/white/bishop/piecetype = /obj/structure/game/piece/chess/white/bishop
/obj/structure/game/button/spawner/white/knight/piecetype = /obj/structure/game/piece/chess/white/knight
/obj/structure/game/button/spawner/white/rook/piecetype = /obj/structure/game/piece/chess/white/rook

/obj/structure/game/button/spawner/white/checker/piecetype = /obj/structure/game/piece/checker/white
/obj/structure/game/button/spawner/black/checker/piecetype = /obj/structure/game/piece/checker/black