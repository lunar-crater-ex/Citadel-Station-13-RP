//
// Tanks - These are implemented as pipes with large volume
//
/obj/machinery/atmospherics/pipe/tank
	icon = 'icons/atmos/tank_vr.dmi'
	icon_state = "air_map"

	name = "Pressure Tank"
	desc = "A large vessel containing pressurized gas."

	volume = 10000 //in liters, 1 meters by 1 meters by 2 meters ~tweaked it a little to simulate a pressure tank without needing to recode them yet
	var/start_pressure = 75*ONE_ATMOSPHERE

	layer = ATMOS_LAYER
	level = 1
	dir = SOUTH
	initialize_directions = SOUTH
	pipe_flags = PIPING_DEFAULT_LAYER_ONLY
	density = 1

/obj/machinery/atmospherics/pipe/tank/Initialize(mapload, newdir)
	. = ..()
	icon_state = "air"

/obj/machinery/atmospherics/pipe/tank/init_dir()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/tank/Destroy()
	if(node1)
		node1.disconnect(src)
		node1 = null

	. = ..()

/obj/machinery/atmospherics/pipe/tank/pipeline_expansion()
	return list(node1)

/obj/machinery/atmospherics/pipe/tank/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, dir)

/obj/machinery/atmospherics/pipe/tank/hide()
	update_underlays()

/obj/machinery/atmospherics/pipe/tank/atmos_init()
	var/connect_direction = dir

	for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
		if (can_be_node(target, 1))
			node1 = target
			break

	update_underlays()

/obj/machinery/atmospherics/pipe/tank/disconnect(obj/machinery/atmospherics/reference)
	if(reference == node1)
		if(istype(node1, /obj/machinery/atmospherics/pipe))
			qdel(parent)
		node1 = null

	update_underlays()

	return null

/obj/machinery/atmospherics/pipe/tank/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/pipe_painter))
		return

	if(istype(W, /obj/item/analyzer) && in_range(user, src))
		var/obj/item/analyzer/A = W
		A.analyze_gases(src, user)

/obj/machinery/atmospherics/pipe/tank/air
	name = "Pressure Tank (Air)"
	icon_state = "air_map"

/obj/machinery/atmospherics/pipe/tank/air/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_multi(/datum/gas/oxygen,  (start_pressure*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature), \
	                           /datum/gas/nitrogen,(start_pressure*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "air"

/obj/machinery/atmospherics/pipe/tank/oxygen
	name = "Pressure Tank (Oxygen)"
	icon_state = "o2_map"

/obj/machinery/atmospherics/pipe/tank/oxygen/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_gas(/datum/gas/oxygen, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))
	. = ..()
	icon_state = "o2"

/obj/machinery/atmospherics/pipe/tank/nitrogen
	name = "Pressure Tank (Nitrogen)"
	icon_state = "n2_map"
	volume = 40000

/obj/machinery/atmospherics/pipe/tank/nitrogen/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_gas(/datum/gas/nitrogen, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "n2"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide
	name = "Pressure Tank (Carbon Dioxide)"
	icon_state = "co2_map"

/obj/machinery/atmospherics/pipe/tank/carbon_dioxide/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_gas(/datum/gas/carbon_dioxide, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "co2"

/obj/machinery/atmospherics/pipe/tank/phoron
	name = "Pressure Tank (Phoron)"
	icon_state = "phoron_map"
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL

/obj/machinery/atmospherics/pipe/tank/phoron/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_gas(/datum/gas/phoron, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "phoron"

/obj/machinery/atmospherics/pipe/tank/nitrous_oxide
	name = "Pressure Tank (Nitrous Oxide)"
	icon_state = "n2o_map"

/obj/machinery/atmospherics/pipe/tank/nitrous_oxide/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T0C

	air_temporary.adjust_gas(/datum/gas/nitrous_oxide, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "n2o"

//Big tanks of hazardous gases can be put here.
/obj/machinery/atmospherics/pipe/tank/chlorine
	name = "Pressure Tank (Chlorine)"
	icon_state = "hazard_map"

/obj/machinery/atmospherics/pipe/tank/chlorine/Initialize(mapload, newdir)
	air_temporary = new
	air_temporary.volume = volume
	air_temporary.temperature = T20C

	air_temporary.adjust_gas(/datum/gas/chlorine, (start_pressure)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature))

	. = ..()
	icon_state = "hazard"
