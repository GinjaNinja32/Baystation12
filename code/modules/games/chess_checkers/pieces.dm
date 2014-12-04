/obj/structure/game/piece
	name = "game piece"
	icon = 'icons/obj/chess_checkers.dmi'
	var/iswhite
	var/style = ""

	update_icon()
		icon_state = "[style][initial(icon_state)]"

	proc/take(obj/structure/game/piece/P)
		visible_message("\The [usr] takes \the [src] with \the [P].")
		moveToDead()

	proc/moveToDead()
		var/obj/structure/game/dzone/D
		if(iswhite)
			D = locate(/obj/structure/game/dzone/white) in src.loc.loc
		else
			D = locate(/obj/structure/game/dzone/black) in src.loc.loc
		src.loc = D.loc
		pixel_x = 0
		pixel_y = 0

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

	proc/check_control(mob/M)
		if(!istype(M, /mob/living))
			M << "You must be alive to do this!"
			return 0
		if(istype(M, /mob/living/silicon/ai))
			return 1
		if(iswhite)
			. = (locate(/obj/structure/game/cpad/white) in M.loc) != null
		else
			. = (locate(/obj/structure/game/cpad/black) in M.loc) != null
		if(!.)
			M << "You need to stand on the control pad!"

	MouseDrop(atom/over, src_loc, over_loc, src_control, over_control, params)
		if(!check_control(usr)) return
		// If we're dragging to a chessboard
		if(istype(over, /turf/simulated/floor/holofloor/gameboard))
			var/list/L = params2list(params)
			var/pxX = (text2num(L["icon-x"]) <= 16) ? -8 : 8
			var/pxY = (text2num(L["icon-y"]) <= 16) ? -8 : 8
			var/turf/simulated/floor/holofloor/gameboard/C = over
			if(C.valid(pxX, pxY)) // make sure we're moving to a point on the board
				visible_message("\The [usr] moves \the [src].")
				smoothMove(over, pxX, pxY)
			else
				smoothMove(over, 0, 0)
		else if(istype(over, /turf/simulated/floor/holofloor))
			smoothMove(over, 0, 0)
		else if(istype(over, /obj/structure/game/piece))
			var/obj/structure/game/piece/C = over
			if(iswhite ^ C.iswhite) // XOR
				smoothMove(C.loc, C.pixel_x, C.pixel_y)
				sleep(8) // wait for our smoothMove() to finish
				C.take(src)
			else
				usr << "You can't take your own pieces!"
		else
			usr << "You can't move that there!"