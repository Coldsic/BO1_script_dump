#include common_scripts\utility;
#include maps\mp\_utility;

main( bScriptgened, bCSVgened, bsgenabled )
{	
	if ( !isdefined( level.script_gen_dump_reasons ) )
		level.script_gen_dump_reasons = [];
	if ( !isdefined( bsgenabled ) )
		level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "First run";
		
	if ( !isdefined( bCSVgened ) )
		bCSVgened = false;
	level.bCSVgened = bCSVgened;
	
	if ( !isdefined( bScriptgened ) )
		bScriptgened = false;
	else
		bScriptgened = true;
	level.bScriptgened = bScriptgened;

	level._loadStarted = true;

	delete_special_ops_entities();

	struct_class_init();

	level.clientscripts = (GetDvar( #"cg_usingClientScripts") != "" );;

	if ( !isdefined( level.flag ) )
	{
		level.flag = [];
		level.flags_lock = [];
	}
	
	// time of day, used for client side night specific FX
	if(!isDefined(level.timeofday))
	{
		level.timeofday = "day";
	}

	// for script gen
	flag_init( "scriptgen_done" );
	level.script_gen_dump_reasons = [];
	if ( !isdefined( level.script_gen_dump ) )
	{
		level.script_gen_dump = [];
		level.script_gen_dump_reasons[ 0 ] = "First run";
	}

	if ( !isdefined( level.script_gen_dump2 ) )
		level.script_gen_dump2 = [];
		
	if ( isdefined( level.createFXent ) )
		script_gen_dump_addline( "maps\\mp\\createfx\\" + level.script + "_fx::main();", level.script + "_fx" ); // adds to scriptgendump
		
	if ( isdefined( level.script_gen_dump_preload ) )
		for ( i = 0;i < level.script_gen_dump_preload.size;i ++ )
			script_gen_dump_addline( level.script_gen_dump_preload[ i ].string, level.script_gen_dump_preload[ i ].signature );

	if (GetDvar( #"scr_RequiredMapAspectratio") == "")
		setDvar("scr_RequiredMapAspectratio", "1");
	
	// AE 10-29-09: added this to turn off the water fog
	SetDvar("r_waterFogTest", 0);
	
	// AE 11-17-09: added this to have reload rumbles
	PrecacheRumble( "reload_small" ); 
	PrecacheRumble( "reload_medium" ); 
	PrecacheRumble( "reload_large" ); 
	PrecacheRumble( "reload_clipin" ); 
	PrecacheRumble( "reload_clipout" ); 
	PrecacheRumble( "reload_rechamber" ); 
	PrecacheRumble( "pullout_small" ); 

	// used for when a sticky grenade sticks to a player
	PrecacheRumble( "buzz_high" );

	// register client system for ClientNotify
	registerClientSys( "levelNotify" );
	
	level.aiTriggerSpawnFlags = getaitriggerflags();
	level.vehicleTriggerSpawnFlags = getvehicletriggerflags();
	
	level.PhysicsTraceMaskPhysics = (1 << 0); // translated in the physicstrace code function
	level.PhysicsTraceMaskVehicle = (1 << 1); // translated in the physicstrace code function
	level.PhysicsTraceMaskWater = (1 << 2); // translated in the physicstrace code function
	
	thread maps\mp\gametypes\_spawning::init();
	thread maps\mp\_deployable_weapons::init();
	thread maps\mp\gametypes\_tweakables::init();
	thread maps\mp\_minefields::init();
	thread maps\mp\_rotating_object::init();
	thread maps\mp\_shutter::main();
	thread maps\mp\_destructible::init();
	thread maps\mp\_elevator::init();
	thread maps\mp\_flare::init();
	thread maps\mp\_interactive_objects::init();
	//thread maps\mp\_pipes::main();
	thread maps\mp\_vehicles::init();
	thread maps\mp\_dogs::init();
	thread maps\mp\_tutorial::init();
	maps\mp\_audio::init();
	thread maps\mp\_busing::busInit();
	thread maps\mp\_music::music_init();
	
	VisionSetNight( "default_night" );

	lanterns = getentarray("lantern_glowFX_origin","targetname");
	array_thread(lanterns, ::lanterns);
		
	setup_traversals();

	//Bloodlust 20 May 2008 - Zero Scripting MP Dynamic Lights
	flicker_lights = getEntArray("flicker_light", "targetname");
	array_thread(flicker_lights, maps\mp\_lights::flicker_light);
	
	strobe_lights = getEntArray("strobe_light", "targetname");
	array_thread(strobe_lights, maps\mp\_lights::flicker_light);

	level.createFX_enabled = ( GetDvar( #"createfx" ) != "" );
	maps\mp\_art::main();
	setupExploders();

	parse_structs();

 	thread footsteps();
 	
	// Dale - 4/20/2009 -- force MP CreateFX to get proper map center (copied from SP)
	thread maps\mp\_createfx::fx_init();
	if( level.createFX_enabled )
	{
		//maps\_callbackglobal::init(); // <<------------------------ SP-specific
		calculate_map_center(); 
		//maps\_loadout::init_loadout(); // MikeD: Just to set the level.campaign	// <<------------------------ SP-specific
		maps\mp\_createfx::createfx();
	}

	if ( GetDvar( #"r_reflectionProbeGenerate" ) == "1" )
	{
		maps\mp\_global_fx::main();
		level waittill( "eternity" );
	}

	thread maps\mp\_global_fx::main();
	
	maps\mp\_demo::init();

	// Do various things on triggers
	for ( p = 0;p < 6;p ++ )
	{
		switch( p )
		{
			case 0:
				triggertype = "trigger_multiple";
				break;

			case 1:
				triggertype = "trigger_once";
				break;

			case 2:
				triggertype = "trigger_use";
				break;
				
			case 3:	
				triggertype = "trigger_radius";
				break;
			
			case 4:	
				triggertype = "trigger_lookat";
				break;

			default:
				assert( p == 5 );
				triggertype = "trigger_damage";
				break;
		}

		triggers = getentarray( triggertype, "classname" );

		for ( i = 0;i < triggers.size;i ++ )
		{
			if( isdefined( triggers[ i ].script_prefab_exploder) )
				triggers[i].script_exploder = triggers[ i ].script_prefab_exploder;

			if( isdefined( triggers[ i ].script_exploder) )
				level thread maps\mp\_load::exploder_load( triggers[ i ] );
		}
	}
	
}

footsteps()
{
  maps\mp\animscripts\utility::setFootstepEffect( "asphalt",   LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "brick",       LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "carpet",     LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "cloth",       LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "concrete", LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "dirt",         LoadFx( "bio/player/fx_footstep_sand" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "foliage",    LoadFx( "bio/player/fx_footstep_sand" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "gravel",     LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "grass",      LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "metal",      LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "mud",       LoadFx( "bio/player/fx_footstep_mud" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "paper",      LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "plaster",    LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "rock",       LoadFx( "bio/player/fx_footstep_dust" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "sand",       LoadFx( "bio/player/fx_footstep_sand" ) ); 
   maps\mp\animscripts\utility::setFootstepEffect( "water",      LoadFx( "bio/player/fx_footstep_water" ) ); 
  maps\mp\animscripts\utility::setFootstepEffect( "wood",      LoadFx( "bio/player/fx_footstep_dust" ) ); 
}


//Bloodlust - 21 May 2008 - Client Side Scripted FX
//Get all script_structs, setup their related FX
parse_structs()
{
	for(i = 0; i < level.struct.size; i++)
	{
		if(isDefined(level.struct[i].targetname))
		{
			if(level.struct[i].targetname == "flak_fire_fx")
			{
				level._effect["flak20_fire_fx"] = loadFX("weapon/tracer/fx_tracer_flak_single_noExp");
				level._effect["flak38_fire_fx"] = loadFX("weapon/tracer/fx_tracer_quad_20mm_Flak38_noExp");
				level._effect["flak_cloudflash_night"] 	= loadFX("weapon/flak/fx_flak_cloudflash_night");
				level._effect["flak_burst_single"] 		= loadFX("weapon/flak/fx_flak_single_day_dist");
			}
			
			if(level.struct[i].targetname == "fake_fire_fx")
			{
				level._effect["distant_muzzleflash"] = loadFX("weapon/muzzleflashes/heavy");
			}
			
			if(level.struct[i].targetname == "spotlight_fx")
			{
				level._effect["spotlight_beam"] = loadFX( "env/light/fx_ray_spotlight_md" );
			}
		}
	}
}

exploder_load( trigger )
{
	level endon( "killexplodertridgers" + trigger.script_exploder );
	trigger waittill( "trigger" );
	if ( isdefined( trigger.script_chance ) && randomfloat( 1 ) > trigger.script_chance )
	{
		if ( isdefined( trigger.script_delay ) )
			wait trigger.script_delay;
		else
			wait 4;
		level thread exploder_load( trigger );
		return;
	}
	maps\mp\_utility::exploder( trigger.script_exploder );
	level notify( "killexplodertridgers" + trigger.script_exploder );
}


setupExploders()
{
	// Hide exploder models.
	ents = getentarray( "script_brushmodel", "classname" );
	smodels = getentarray( "script_model", "classname" );
	for ( i = 0;i < smodels.size;i ++ )
		ents[ ents.size ] = smodels[ i ];

	for ( i = 0;i < ents.size;i ++ )
	{
		if ( isdefined( ents[ i ].script_prefab_exploder ) )
			ents[ i ].script_exploder = ents[ i ].script_prefab_exploder;

		if ( isdefined( ents[ i ].script_exploder ) )
		{
			if ( ( ents[ i ].model == "fx" ) && ( ( !isdefined( ents[ i ].targetname ) ) || ( ents[ i ].targetname != "exploderchunk" ) ) )
				ents[ i ] hide();
			else if ( ( isdefined( ents[ i ].targetname ) ) && ( ents[ i ].targetname == "exploder" ) )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
				//if ( isdefined( ents[ i ].script_disconnectpaths ) )
					//ents[ i ] connectpaths();
			}
			else if ( ( isdefined( ents[ i ].targetname ) ) && ( ents[ i ].targetname == "exploderchunk" ) )
			{
				ents[ i ] hide();
				ents[ i ] notsolid();
				//if ( isdefined( ents[ i ].spawnflags ) && ( ents[ i ].spawnflags & 1 ) )
					//ents[ i ] connectpaths();
			}
		}
	}

	script_exploders = [];

	potentialExploders = getentarray( "script_brushmodel", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;
			
		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = getentarray( "script_model", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}

	potentialExploders = getentarray( "item_health", "classname" );
	for ( i = 0;i < potentialExploders.size;i ++ )
	{
		if ( isdefined( potentialExploders[ i ].script_prefab_exploder ) )
			potentialExploders[ i ].script_exploder = potentialExploders[ i ].script_prefab_exploder;

		if ( isdefined( potentialExploders[ i ].script_exploder ) )
			script_exploders[ script_exploders.size ] = potentialExploders[ i ];
	}
	
	if ( !isdefined( level.createFXent ) )
		level.createFXent = [];
	
	acceptableTargetnames = [];
	acceptableTargetnames[ "exploderchunk visible" ] = true;
	acceptableTargetnames[ "exploderchunk" ] = true;
	acceptableTargetnames[ "exploder" ] = true;
	
	for ( i = 0; i < script_exploders.size; i ++ )
	{
		exploder = script_exploders[ i ];
		ent = createExploder( exploder.script_fxid );
		ent.v = [];
		ent.v[ "origin" ] = exploder.origin;
		ent.v[ "angles" ] = exploder.angles;
		ent.v[ "delay" ] = exploder.script_delay;
		ent.v[ "firefx" ] = exploder.script_firefx;
		ent.v[ "firefxdelay" ] = exploder.script_firefxdelay;
		ent.v[ "firefxsound" ] = exploder.script_firefxsound;
		ent.v[ "firefxtimeout" ] = exploder.script_firefxtimeout;
		ent.v[ "earthquake" ] = exploder.script_earthquake;
		ent.v[ "damage" ] = exploder.script_damage;
		ent.v[ "damage_radius" ] = exploder.script_radius;
		ent.v[ "soundalias" ] = exploder.script_soundalias;
		ent.v[ "repeat" ] = exploder.script_repeat;
		ent.v[ "delay_min" ] = exploder.script_delay_min;
		ent.v[ "delay_max" ] = exploder.script_delay_max;
		ent.v[ "target" ] = exploder.target;
		ent.v[ "ender" ] = exploder.script_ender;
		ent.v[ "type" ] = "exploder";
// 		ent.v[ "worldfx" ] = true;
		if ( !isdefined( exploder.script_fxid ) )
			ent.v[ "fxid" ] = "No FX";
		else
			ent.v[ "fxid" ] = exploder.script_fxid;
		ent.v[ "exploder" ] = exploder.script_exploder;
		assertEx( isdefined( exploder.script_exploder ), "Exploder at origin " + exploder.origin + " has no script_exploder" );

		if ( !isdefined( ent.v[ "delay" ] ) )
			ent.v[ "delay" ] = 0;
			
		if ( isdefined( exploder.target ) )
		{
			org = getent( ent.v[ "target" ], "targetname" ).origin;
			ent.v[ "angles" ] = vectortoangles( org - ent.v[ "origin" ] );
// 			forward = anglestoforward( angles );
// 			up = anglestoup( angles );
		}
			
		// this basically determines if its a brush / model exploder or not
		if ( exploder.classname == "script_brushmodel" || isdefined( exploder.model ) )
		{
			ent.model = exploder;
			ent.model.disconnect_paths = exploder.script_disconnectpaths;
		}
		
		if ( isdefined( exploder.targetname ) && isdefined( acceptableTargetnames[ exploder.targetname ] ) )
			ent.v[ "exploder_type" ] = exploder.targetname;
		else
			ent.v[ "exploder_type" ] = "normal";
		
		ent maps\mp\_createfx::post_entity_creation_function();
	}
}

lanterns()
{
	if (!isdefined(level._effect["lantern_light"]))
	{
		level._effect["lantern_light"]	= loadfx("props/glow_latern");
	}
	
	maps\mp\_fx::loopfx("lantern_light", self.origin, 0.3, self.origin + (0,0,1));
}

script_gen_dump_checksaved()
{
	signatures = getarraykeys( level.script_gen_dump );
	for ( i = 0;i < signatures.size;i ++ )
		if ( !isdefined( level.script_gen_dump2[ signatures[ i ] ] ) )
		{
			level.script_gen_dump[ signatures[ i ] ] = undefined;
			level.script_gen_dump_reasons[ level.script_gen_dump_reasons.size ] = "Signature unmatched( removed feature ): " + signatures[ i ];
			
		}
}

script_gen_dump()
{
	// initialize scriptgen dump
	 /#

	script_gen_dump_checksaved();// this checks saved against fresh, if there is no matching saved value then something has changed and the dump needs to happen again.
	
	if ( !level.script_gen_dump_reasons.size )
	{
		flag_set( "scriptgen_done" );
		return;// there's no reason to dump the file so exit
	}
	
	firstrun = false;
	if ( level.bScriptgened )
	{
		println( " " );
		println( " " );
		println( " " );
		println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( "^3Dumping scriptgen dump for these reasons" );
		println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		for ( i = 0;i < level.script_gen_dump_reasons.size;i ++ )		
		{
			if ( issubstr( level.script_gen_dump_reasons[ i ], "nowrite" ) )
			{
				substr = getsubstr( level.script_gen_dump_reasons[ i ], 15 );// I don't know why it's 15, maybe investigate - nate
				println( i + ". ) " + substr );
				
			}
			else
				println( i + ". ) " + level.script_gen_dump_reasons[ i ] );
			if ( level.script_gen_dump_reasons[ i ] == "First run" )
				firstrun = true;
		}
		println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( " " );
		if ( firstrun )
		{
			println( "for First Run make sure you delete all of the vehicle precache script calls, createart calls, createfx calls( most commonly placed in maps\\" + level.script + "_fx.gsc ) " );
			println( " " );
			println( "replace:" );
			println( "maps\\\_load::main( 1 );" );
			println( " " );
			println( "with( don't forget to add this file to P4 ):" );
			println( "maps\\scriptgen\\" + level.script + "_scriptgen::main();" );
			println( " " );
		}
// 		println( "make sure this is in your " + level.script + ".csv:" );
// 		println( "rawfile, maps / scriptgen/" + level.script + "_scriptgen.gsc" );
		println( "^2 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- " );
		println( " " );
		println( "^2 / \\ / \\ / \\" );
		println( "^2scroll up" );
		println( "^2 / \\ / \\ / \\" );
		println( " " );
	}
	else
	{
 /* 		println( " " );
		println( " " );
		println( "^3for legacy purposes I'm printing the would be script here, you can copy this stuff if you'd like to remain a dinosaur:" );
		println( "^3otherwise, you should add this to your script:" );
		println( "^3maps\\\_load::main( 1 );" );
		println( " " );
		println( "^3rebuild the fast file and the follow the assert instructions" );
		println( " " );
		
		 */ 
		return;
	}
	
	filename = "scriptgen/" + level.script + "_scriptgen.gsc";
	csvfilename = "zone_source/" + level.script + ".csv";
	
	if ( level.bScriptgened )
		file = openfile( filename, "write" );
	else
		file = 0;

	assertex( file != -1, "File not writeable( check it and and restart the map ): " + filename );

	script_gen_dumpprintln( file, "// script generated script do not write your own script here it will go away if you do." );
	script_gen_dumpprintln( file, "main()" );
	script_gen_dumpprintln( file, "{" );
	script_gen_dumpprintln( file, "" );
	script_gen_dumpprintln( file, "\tlevel.script_gen_dump = [];" );
	script_gen_dumpprintln( file, "" );

	signatures = getarraykeys( level.script_gen_dump );
	for ( i = 0;i < signatures.size;i ++ )
		if ( !issubstr( level.script_gen_dump[ signatures[ i ] ], "nowrite" ) )
			script_gen_dumpprintln( file, "\t" + level.script_gen_dump[ signatures[ i ] ] );

	for ( i = 0;i < signatures.size;i ++ )
		if ( !issubstr( level.script_gen_dump[ signatures[ i ] ], "nowrite" ) )
			script_gen_dumpprintln( file, "\tlevel.script_gen_dump[ " + "\"" + signatures[ i ] + "\"" + " ] = " + "\"" + signatures[ i ] + "\"" + ";" );
		else
			script_gen_dumpprintln( file, "\tlevel.script_gen_dump[ " + "\"" + signatures[ i ] + "\"" + " ] = " + "\"nowrite\"" + ";" );

	script_gen_dumpprintln( file, "" );
	
	keys1 = undefined;
	keys2 = undefined;
	// special animation threading to capture animtrees
	if ( isdefined( level.sg_precacheanims ) )
		keys1 = getarraykeys( level.sg_precacheanims );
	if ( isdefined( keys1 ) )
		for ( i = 0;i < keys1.size;i ++ )
			script_gen_dumpprintln( file, "\tanim_precach_" + keys1[ i ] + "();" );

	
	script_gen_dumpprintln( file, "\tmaps\\\_load::main( 1, " + level.bCSVgened + ", 1 );" );
	script_gen_dumpprintln( file, "}" );
	script_gen_dumpprintln( file, "" );
	
	///animations section
	
// 	level.sg_precacheanims[ animtree ][ animation ]
	if ( isdefined( level.sg_precacheanims ) )
		keys1 = getarraykeys( level.sg_precacheanims );
	if ( isdefined( keys1 ) )
	for ( i = 0;i < keys1.size;i ++ )
	{
		// first key being the animtree
		script_gen_dumpprintln( file, "#using_animtree( \"" + keys1[ i ] + "\" );" );
		script_gen_dumpprintln( file, "anim_precach_" + keys1[ i ] + "()" ); // adds to scriptgendump
		script_gen_dumpprintln( file, "{" );
		script_gen_dumpprintln( file, "\tlevel.sg_animtree[ \"" + keys1[ i ] + "\" ] = #animtree;" ); // adds to scriptgendump get the animtree without having to put #using animtree everywhere.

		keys2 = getarraykeys( level.sg_precacheanims[ keys1[ i ] ] );
		if ( isdefined( keys2 ) )
		for ( j = 0;j < keys2.size;j ++ )
		{
			script_gen_dumpprintln( file, "\tlevel.sg_anim[ \"" + keys2[ j ] + "\" ] = %" + keys2[ j ] + ";" ); // adds to scriptgendump
		
		}
		script_gen_dumpprintln( file, "}" );
		script_gen_dumpprintln( file, "" );
	}
	
	
	if ( level.bScriptgened )
		saved = closefile( file );
	else
		saved = 1; // dodging save for legacy levels
	
	// CSV section	
		
	if ( level.bCSVgened )
		csvfile = openfile( csvfilename, "write" );
	else
		csvfile = 0;
	
	assertex( csvfile != -1, "File not writeable( check it and and restart the map ): " + csvfilename );
	
	signatures = getarraykeys( level.script_gen_dump );
	for ( i = 0;i < signatures.size;i ++ )
		script_gen_csvdumpprintln( csvfile, signatures[ i ] );

	if ( level.bCSVgened )
		csvfilesaved = closefile( csvfile );
	else
		csvfilesaved = 1;// dodging for now

	// check saves
		
	assertex( csvfilesaved == 1, "csv not saved( see above message? ): " + csvfilename );
	assertex( saved == 1, "map not saved( see above message? ): " + filename );

	#/ 
	
	// level.bScriptgened is not set on non scriptgen powered maps, keep from breaking everything
	assertex( !level.bScriptgened, "SCRIPTGEN generated: follow instructions listed above this error in the console" );
	if ( level.bScriptgened )
		assertmsg( "SCRIPTGEN updated: Rebuild fast file and run map again" );
		
	flag_set( "scriptgen_done" );
	
}


script_gen_csvdumpprintln( file, signature )
{
	
	prefix = undefined;
	writtenprefix = undefined;
	path = "";
	extension = "";
	
	
	if ( issubstr( signature, "ignore" ) )
		prefix = "ignore";
	else
	if ( issubstr( signature, "col_map_sp" ) )
		prefix = "col_map_sp";
	else
	if ( issubstr( signature, "gfx_map" ) )
		prefix = "gfx_map";
	else
	if ( issubstr( signature, "rawfile" ) )
		prefix = "rawfile";
	else
	if ( issubstr( signature, "sound" ) )
		prefix = "sound";
	else
	if ( issubstr( signature, "xmodel" ) )
		prefix = "xmodel";
	else
	if ( issubstr( signature, "xanim" ) )
		prefix = "xanim";
	else
	if ( issubstr( signature, "item" ) )
	{
		prefix = "item";
		writtenprefix = "weapon";
		path = "sp/";
	}
	else
	if ( issubstr( signature, "fx" ) )
	{
		prefix = "fx";
	}
	else
	if ( issubstr( signature, "menu" ) )
	{
		prefix = "menu";
		writtenprefix = "menufile";
		path = "ui / scriptmenus/";
		extension = ".menu";
	}
	else
	if ( issubstr( signature, "rumble" ) )
	{
		prefix = "rumble";
		writtenprefix = "rawfile";
		path = "rumble/";
	}
	else
	if ( issubstr( signature, "shader" ) )
	{
		prefix = "shader";
		writtenprefix = "material";
	}
	else
	if ( issubstr( signature, "shock" ) )
	{
		prefix = "shock";
		writtenprefix = "rawfile";
		extension = ".shock";
		path = "shock/";
	}
	else
	if ( issubstr( signature, "string" ) )
	{
		prefix = "string";
		assertmsg( "string not yet supported by scriptgen" ); // I can't find any instances of string files in a csv, don't think we've enabled localization yet
	}
	else
	if ( issubstr( signature, "turret" ) )
	{
		prefix = "turret";
		writtenprefix = "weapon";
		path = "sp/";
	}
	else
	if ( issubstr( signature, "vehicle" ) )
	{
		prefix = "vehicle";
		writtenprefix = "rawfile";
		path = "vehicles/";
	}
	
	
 /* 		
sg_precachevehicle( vehicle )
 */ 

		
	if ( !isdefined( prefix ) )
		return;
	if ( !isdefined( writtenprefix ) )
		string = prefix + ", " + getsubstr( signature, prefix.size + 1, signature.size );
	else
		string = writtenprefix + ", " + path + getsubstr( signature, prefix.size + 1, signature.size ) + extension;

	
	 /* 		
	ignore, code_post_gfx
	ignore, common
	col_map_sp, maps / nate_test.d3dbsp
	gfx_map, maps / nate_test.d3dbsp
	rawfile, maps / nate_test.gsc
	sound, voiceovers, rallypoint, all_sp
	sound, us_battlechatter, rallypoint, all_sp
	sound, ab_battlechatter, rallypoint, all_sp
	sound, common, rallypoint, all_sp
	sound, generic, rallypoint, all_sp
	sound, requests, rallypoint, all_sp	
 */ 

	// printing to file is optional	
	if ( file == -1 || !level.bCSVgened )
		println( string );
	else
		fprintln( file, string );
}

script_gen_dumpprintln( file, string )
{
	// printing to file is optional
	if ( file == -1 || !level.bScriptgened )
		println( string );
	else
		fprintln( file, string );
}

setup_traversals()
{
	potential_traverse_nodes = GetAllNodes();
	for (i = 0; i < potential_traverse_nodes.size; i++)
	{
		node = potential_traverse_nodes[i];
		if (node.type == "Begin")
		{
			node maps\mp\animscripts\traverse\shared::init_traverse();
		}
	}
}

delete_special_ops_entities()
{
	allEnts = getentarray();

	for( i = 0; i < allEnts.size; i++ )
	{
		if(	isdefined( allEnts[i] ) &&
			isdefined( allEnts[i].classname ) &&
			isdefined( allEnts[i].script_specialops ) &&
			allEnts[i].script_specialops == 1 )
		{
			allEnts[i] delete();
		}
	}
}

calculate_map_center()
{
	// Dale - 10/19/2009 (based on Gavin's script) -- Do not compute and set the map center if the level script has already done so.
	if( !IsDefined( level.mapCenter ) )
	{
		level.nodesMins = ( 0, 0, 0 ); 
		level.nodesMaxs = ( 0, 0, 0 );
	
		level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.nodesMins, level.nodesMaxs );
		
		/# // do not compile for ship builds
		println( "map center: ", level.mapCenter ); 
		#/
		
		SetMapCenter( level.mapCenter ); 
	}
}
 