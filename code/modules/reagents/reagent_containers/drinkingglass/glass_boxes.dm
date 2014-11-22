/obj/item/weapon/storage/box/mixedglasses
	name = "glassware box"
	desc = "A box of assorted glassware"
	can_hold = list("/obj/item/weapon/reagent_containers/drinking")
	New()
		..()
		
		new /obj/item/weapon/reagent_containers/drinking/square(src)
		new /obj/item/weapon/reagent_containers/drinking/rocks(src)
		new /obj/item/weapon/reagent_containers/drinking/shake(src)
		new /obj/item/weapon/reagent_containers/drinking/cocktail(src)
		new /obj/item/weapon/reagent_containers/drinking/shot(src)
		new /obj/item/weapon/reagent_containers/drinking/pint(src)
		new /obj/item/weapon/reagent_containers/drinking/mug(src)

/obj/item/weapon/storage/box/glasses
	name = "box of glasses"
	var/glass_type = /obj/item/weapon/reagent_containers/drinking
	can_hold = list("/obj/item/weapon/reagent_containers/drinking")
	New()
		..()
		
		for(var/i = 1 to 7)
			new glass_type(src)

/obj/item/weapon/storage/box/glasses/square
	name = "box of half-pint glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/square

/obj/item/weapon/storage/box/glasses/rocks
	name = "box of rocks glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/rocks
	
/obj/item/weapon/storage/box/glasses/shake
	name = "box of milkshake glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/shake
	
/obj/item/weapon/storage/box/glasses/cocktail
	name = "box of cocktail glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/cocktail

/obj/item/weapon/storage/box/glasses/shot
	name = "box of shot glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/shot

/obj/item/weapon/storage/box/glasses/pint
	name = "box of pint glasses"
	glass_type = /obj/item/weapon/reagent_containers/drinking/pint

/obj/item/weapon/storage/box/glasses/mug
	name = "box of glass mugs"
	glass_type = /obj/item/weapon/reagent_containers/drinking/mug