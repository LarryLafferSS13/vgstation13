/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

	var/obj/effect/blob/core/Blob
	var/list/datum/mind/infected_crew=list()


/datum/event/blob/announce()
	burst_blobs()

/datum/event/blob/start()
	var/list/possible_blobs = ticker.GetAllGoodMinds()
	if (!possible_blobs.len)
		return
	for(var/mob/living/G in possible_blobs)
		if(G.client && !G.client.holder && !G.client.is_afk() && G.client.prefs.be_special & BE_ALIEN)
			var/datum/mind/blob = pick(possible_blobs)
			infected_crew += blob
			blob.special_role = "Blob"
			log_game("[blob.key] (ckey) has been selected as a Blob")
			possible_blobs -= blob
			greetblob(blob)
			return

	//Blob = new /obj/effect/blob/core(T, 200)
	//for(var/i = 1; i < rand(3, 6), i++)
	//	Blob.process()

/datum/event/blob/proc/burst_blobs()
	spawn(0)
		for(var/datum/mind/blob in infected_crew)
			blob.current.show_message("<span class='alert'>You feel tired and bloated.</span>")

		sleep(600) // 60s

		for(var/datum/mind/blob in infected_crew)
			blob.current.show_message("<span class='alert'>You feel like you are about to burst.</span>")

		sleep(300) // 30s

		for(var/datum/mind/blob in infected_crew)

			var/client/blob_client = null
			var/turf/location = null

			if(iscarbon(blob.current))
				var/mob/living/carbon/C = blob.current
				if(directory[ckey(blob.key)])
					blob_client = directory[ckey(blob.key)]
					location = get_turf(C)
					if(location.z != 1 || istype(location, /turf/space))
						location = null
					C.gib()


			if(blob_client && location)
				var/obj/effect/blob/core/core = new(location, 200, blob_client, 3)
				if(core.overmind && core.overmind.mind)
					core.overmind.mind.name = blob.name
					infected_crew -= blob
					infected_crew += core.overmind.mind

		sleep(100) // 10s
		command_alert("Confirmed outbreak of level 7 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
		world << sound('sound/AI/outbreak7.ogg')

/datum/event/blob/proc/greetblob(user)
	user << {"<B>\red You are infected by the Blob!</B>
<b>Your body is ready to give spawn to a new blob core which will eat this station.</b>
<b>Find a good location to spawn the core and then take control and overwhelm the station!</b>
<b>When you have found a location, wait until you spawn; this will happen automatically and you cannot speed up the process.</b>
<b>If you go outside of the station level, or in space, then you will die; make sure your location has lots of ground to cover.</b>"}

/datum/event/blob/tick()
	if(!Blob && infected_crew.len == 0)
		kill()
		return
	if(IsMultiple(activeFor, 3))
		Blob.process()