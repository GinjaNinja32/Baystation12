/obj/structure/chess
	icon = 'icons/obj/chess.dmi'

/obj/structure/chess/piece
	name = "chess piece"
	desc = "It's a chess piece"
	icon_state = "pawn_w"
	var/iswhite

	proc/smoothMove(turf/simulated/floor/holofloor/T, px, py)
		var/dX = T.x - x
		var/dY = T.y - y
		
		var/dist = get_dist(src.loc, T)
		if(Move(T))
			if(dist <= 1) // animate normally if we're going to be using smooth Move()
				animate(src, pixel_x=px, pixel_y=py, 8, 1, LINEAR_EASING)
			else // otherwise, jump to our old location then animate
				pixel_x -= dX * 32
				pixel_y -= dY * 32
				animate(src, pixel_x=px, pixel_y=py, 8, 1, LINEAR_EASING)

	proc/kill(obj/structure/chess/piece/P)
		visible_message("\The [usr] takes \the [src] with \the [P].")
		return

	MouseDrop(atom/over, src_loc, over_loc, src_control, over_control, params)
		// No ghost-chess.
		if(!istype(usr, /mob/living))
			usr << "You must be alive to do this!"
			return
		// AI always has control of pieces; borgs, other mobs etc must stand on the control pads
		if(!(istype(usr, /mob/living/silicon/ai) || has_control(usr)))
			usr << "You need to stand on the control pad!"
			return
		// If we're dragging to a chessboard
		if(istype(over, /turf/simulated/floor/holofloor/chess))
			var/list/L = params2list(params)
			var/pxX = (text2num(L["icon-x"]) <= 16) ? -8 : 8
			var/pxY = (text2num(L["icon-y"]) <= 16) ? -8 : 8
			var/turf/simulated/floor/holofloor/chess/C = over
			if(C.valid(pxX, pxY)) // make sure we're moving to a point on the board
				visible_message("\The [usr] moves \the [src].")
				smoothMove(over, pxX, pxY)
			else
				smoothMove(over, 0, 0)
		// If we're dragging to a piece (to take it)
		else if(istype(over, /obj/structure/chess/piece))
			var/obj/structure/chess/piece/C = over
			if(iswhite ^ C.iswhite) // XOR
				smoothMove(C.loc, C.pixel_x, C.pixel_y)
				sleep(8) // wait for our smoothMove() to finish
				C.kill(src)
			else
				usr << "You can't take your own pieces!"
		// Otherwise
		else if(istype(over, /turf/simulated/floor/holofloor))
			smoothMove(over, 0, 0)
		else
			usr << "You can't move that there!"

	proc/has_control(mob/M)
		return 0

/obj/structure/chess/piece/white
	iswhite = 1
	has_control(mob/M)
		return (locate(/obj/structure/chess/cpad/white) in M.loc) != null
	kill()
		..()
		var/obj/structure/chess/dzone/D = locate(/obj/structure/chess/dzone/white) in src.loc.loc
		src.loc = D.loc
		pixel_x = 0
		pixel_y = 0

/obj/structure/chess/piece/black
	iswhite = 0
	has_control(mob/M)
		return (locate(/obj/structure/chess/cpad/black) in M.loc) != null
	kill()
		..()
		var/obj/structure/chess/dzone/D = locate(/obj/structure/chess/dzone/black) in src.loc.loc
		src.loc = D.loc
		pixel_x = 0
		pixel_y = 0

/obj/structure/chess/dzone/white
	name = "white deadzone"
	icon_state = "dzone_w"
/obj/structure/chess/dzone/black
	name = "black deadzone"
	icon_state = "dzone_b"

/obj/structure/chess/cpad/white
	name = "white control pad"
	icon_state = "cpad_w"
/obj/structure/chess/cpad/black
	name = "black control pad"
	icon_state = "cpad_b"

/obj/structure/chess/piece/white/pawn
	name = "white pawn"
	icon_state = "pawn_w"
/obj/structure/chess/piece/white/rook
	name = "white rook"
	icon_state = "rook_w"
/obj/structure/chess/piece/white/knight
	name = "white knight"
	icon_state = "knight_w"
/obj/structure/chess/piece/white/bishop
	name = "white bishop"
	icon_state = "bishop_w"
/obj/structure/chess/piece/white/king
	name = "white king"
	icon_state = "king_w"
/obj/structure/chess/piece/white/queen
	name = "white queen"
	icon_state= "queen_w"

/obj/structure/chess/piece/black/pawn
	name = "black pawn"
	icon_state = "pawn_b"
/obj/structure/chess/piece/black/rook
	name = "black rook"
	icon_state = "rook_b"
/obj/structure/chess/piece/black/knight
	name = "black knight"
	icon_state = "knight_b"
/obj/structure/chess/piece/black/bishop
	name = "black bishop"
	icon_state = "bishop_b"
/obj/structure/chess/piece/black/king
	name = "black king"
	icon_state = "king_b"
/obj/structure/chess/piece/black/queen
	name = "black queen"
	icon_state= "queen_b"

/obj/structure/chess/button
	icon_state = "button"
	proc/activate()
		return
	attack_hand()
		activate()
	attack_ai()
		activate()

/obj/structure/chess/button/icontoggle
	name = "piece appearance switcher"
	var/current = 1
	var/list/possible = list("", "holo_")
	activate()
		current = (current % possible.len) + 1
		var/C = possible[current]
		for(var/obj/structure/chess/piece/CP in src.loc.loc)
			CP.icon_state = "[C][initial(CP.icon_state)]"

/obj/structure/chess/button/spawner
	var/piecetype = null

	New()
		..()
		var/obj/structure/chess/piece/P = piecetype
		name = "[initial(P.name)] spawner button"

	activate()
		var/obj/machinery/computer/HolodeckControl/HC = locate(/obj/machinery/computer/HolodeckControl) in view()
		HC.holographic_items += new piecetype(loc)

/obj/structure/chess/button/spawner/black
	icon_state = "button_b"
/obj/structure/chess/button/spawner/black/queen
	piecetype = /obj/structure/chess/piece/black/queen
/obj/structure/chess/button/spawner/black/bishop
	piecetype = /obj/structure/chess/piece/black/bishop
/obj/structure/chess/button/spawner/black/knight
	piecetype = /obj/structure/chess/piece/black/knight
/obj/structure/chess/button/spawner/black/rook
	piecetype = /obj/structure/chess/piece/black/rook

/obj/structure/chess/button/spawner/white
	icon_state = "button_w"
/obj/structure/chess/button/spawner/white/queen
	piecetype = /obj/structure/chess/piece/white/queen
/obj/structure/chess/button/spawner/white/bishop
	piecetype = /obj/structure/chess/piece/white/bishop
/obj/structure/chess/button/spawner/white/knight
	piecetype = /obj/structure/chess/piece/white/knight
/obj/structure/chess/button/spawner/white/rook
	piecetype = /obj/structure/chess/piece/white/rook

/turf/simulated/floor/holofloor/chess
	icon_state="chessboard"
	proc/valid(px, py)
		return 1
/turf/simulated/floor/holofloor/chess/edge
	icon_state= "chessboard_e"
	valid(px, py)
		switch(dir)
			if(EAST, WEST)
				return (px > 0) ^ !!(dir & EAST)
			else
				return 0
/turf/simulated/floor/holofloor/chess/edge/E
	dir=EAST
/turf/simulated/floor/holofloor/chess/edge/W
	dir=WEST
/turf/simulated/floor/holofloor/chess/edge/N
	dir=NORTH
/turf/simulated/floor/holofloor/chess/edge/S
	dir=SOUTH
/turf/simulated/floor/holofloor/chess/edge/NE
	dir=NORTHEAST
/turf/simulated/floor/holofloor/chess/edge/NW
	dir=NORTHWEST
/turf/simulated/floor/holofloor/chess/edge/SE
	dir=SOUTHEAST
/turf/simulated/floor/holofloor/chess/edge/SW
	dir=SOUTHWEST