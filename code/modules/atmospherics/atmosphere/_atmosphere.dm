/datum/atmosphere
	/// Don't initialize abstract datums.
	abstract_type = /datum/atmosphere

	/// Gas string. Do not modify directly. Generated by [generate_gas_string()]
	var/gas_string
	/// Unique ID. MUST be different for every atmosphere! Defaults to typepath.
	var/id

	/// A list of gases to always have. Associative gas datum typepath:mols
	var/list/base_gases
	/// A list of allowed gases. Associative gas datum typepath:mols. Is randomized on generation.
	var/list/normal_gases
	/// A list of allowed gases that can only be picked once. Associative gas datum typepath:mols. Is randomized on generation.
	var/list/restricted_gases
	/// Chance per iteration to take from restricted gases
	var/restricted_chance = 10

	/// Pressure to fill base_gases to, if it isn't there. For lazy coders who don't want to pv=nrt.
	var/base_target_pressure
	/// Minimum pressure in kPa this atmosphere can be
	var/minimum_pressure
	/// Maximum pressure in kPa this atmosphere can be
	var/maximum_pressure

	/// Minimum temperature this atmosphere can be
	var/minimum_temp
	/// Maximum temperature this atmosphere can be
	var/maximum_temp

/datum/atmosphere/New()
	if(!id)
		id = "[type]"
	generate_gas_string()

/datum/atmosphere/proc/generate_gas_string()
	var/target_pressure = max(base_target_pressure, rand(minimum_pressure, maximum_pressure))
	var/pressure_scalar = target_pressure / maximum_pressure

	// First let's set up the gasmix and base gases for this template
	// We make the string from a gasmix in this proc because gases need to calculate their pressure
	var/datum/gas_mixture/gasmix = new
	gasmix.volume = CELL_VOLUME
	var/list/gaslist = gasmix.gas
	gasmix.temperature = rand(minimum_temp, maximum_temp)
	for(var/gaspath in base_gases)
		gaslist[gaspath] = base_gases[gaspath]

	// Make sure base gases are at target pressure if it isn't already
	if(gasmix.return_pressure() < base_target_pressure)
		// yeah you screwed up, redo the whole thing.
		// screw lazy coders
		var/moles = (base_target_pressure * CELL_VOLUME) / (R_IDEAL_GAS_EQUATION * gasmix.temperature)
		gaslist.Cut()
		var/total_moles_base
		TOTAL_MOLES(base_gases, total_moles_base)
		for(var/i in base_gases)
			var/amount = base_gases[i]
			var/ratio = amount / total_moles_base
			var/actual = moles * ratio
			gaslist[i] = actual

	// Now let the random choices begin
	if(length(normal_gases) && length(restricted_gases))
		var/datum/gas/gastype
		var/amount
		var/safety = 254
		while(gasmix.return_pressure() < target_pressure)
			if(!safety--)
				stack_trace("[type] ran out of safety in its while loop in generate_gas_string. Something has gone horribly wrong!")
				break
			if(!prob(restricted_chance))
				gastype = pick(normal_gases)
				amount = normal_gases[gastype]
			else
				gastype = pick(restricted_gases)
				amount = restricted_gases[gastype]
				if(gaslist[gastype])
					continue

			amount *= rand(50, 200) / 100	// Randomly modifes the amount from half to double the base for some variety
			amount *= pressure_scalar		// If we pick a really small target pressure we want roughly the same mix but less of it all
			amount = CEILING(amount, 0.01)

			gaslist[gastype] += amount

		if(gastype)
			// That last one put us over the limit, remove some of it
			while(gasmix.return_pressure() > target_pressure)
				gaslist[gastype] -= gaslist[gastype] * 0.01
			gaslist[gastype] = FLOOR(gaslist[gastype], 0.01)
	GAS_GARBAGE_COLLECT(gasmix.gas)

	// Now finally lets make that string
	var/list/gas_string_builder = list()
	for(var/i in gaslist)
		gas_string_builder += "[GLOB.meta_gas_ids[i]]=[gaslist[i]]"
	gas_string_builder += "TEMP=[gasmix.temperature]"
	gas_string = gas_string_builder.Join(";")
