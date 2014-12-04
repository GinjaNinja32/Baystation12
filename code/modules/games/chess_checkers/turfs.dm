/turf/simulated/floor/holofloor/gameboard
	icon_state="chessboard"
	proc/valid(px, py)
		return 1
/turf/simulated/floor/holofloor/gameboard/edge
	icon_state= "chessboard_e"
	valid(px, py)
		switch(dir)
			if(EAST, WEST)
				// if we're checking the right-hand-side of the tile (px > 0) XOR this tile's left half is board (dir & EAST), return 1
				// !! is necessary because (dir & EAST) will be 0 or EAST, we need 0 or 1
				return (px > 0) ^ !!(dir & EAST)
			else
				return 0

/turf/simulated/floor/holofloor/gameboard/edge/E
	dir=EAST
/turf/simulated/floor/holofloor/gameboard/edge/W
	dir=WEST
/turf/simulated/floor/holofloor/gameboard/edge/N
	dir=NORTH
/turf/simulated/floor/holofloor/gameboard/edge/S
	dir=SOUTH
/turf/simulated/floor/holofloor/gameboard/edge/NE
	dir=NORTHEAST
/turf/simulated/floor/holofloor/gameboard/edge/NW
	dir=NORTHWEST
/turf/simulated/floor/holofloor/gameboard/edge/SE
	dir=SOUTHEAST
/turf/simulated/floor/holofloor/gameboard/edge/SW
	dir=SOUTHWEST