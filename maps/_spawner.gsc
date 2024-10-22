#include maps\_utility; 
#include maps\_anim;
#include maps\_serverfaceanim;
#include common_scripts\utility; 

// .script_delete	a group of guys, only one of which spawns
// .script_patroller	follow your targeted patrol
// .script_followmin
// .script_followmax
// .script_radius
// .script_friendname
// .script_startinghealth
// .script_accuracy
// .script_grenades
// .script_sightrange
// .script_ignoreme

main()
{
	/#
	debug_replay("File: _spawner.gsc. Function: main()\n");
	#/

	// create default threatbiasgroups; 
	CreateThreatBiasGroup( "allies" ); 
	CreateThreatBiasGroup( "axis" ); 


	if (level.script!="frontend" && !isDefined(level.zombietron_mode) )
		precachemodel("grenade_bag");

	level._nextcoverprint = 0; 
	level._ai_group = []; 
	level.killedaxis = 0; 
	level.ffpoints = 0; 
	level.missionfailed = false; 
	level.gather_delay = []; 
	level.smoke_thrown = []; 
	level.deathflags = [];
	level.spawner_number = 0;
	level.go_to_node_arrays = [];

	level.next_health_drop_time = 0; 
	level.guys_to_die_before_next_health_drop = RandomIntRange( 1, 4 ); 
	level.default_goalradius = 2048; 
	level.default_goalheight = 80; 
	level.portable_mg_gun_tag = "J_Shoulder_RI"; // need to get J_gun back to make it work properly
	level.mg42_hide_distance = 1024; 
	
	if( !IsDefined( level.maxFriendlies ) )
	{
		level.maxFriendlies = 11; 
	}

	ai = GetAISpeciesArray("all");
	array_thread( ai, ::living_ai_prethink );

	level.ai_classname_in_level = [];

	spawners = GetSpawnerArray(); 
	for( i = 0; i < spawners.size; i++ )
	{
		spawners[i].is_spawner = true;
		spawners[i] thread spawn_prethink(); 
	}

	thread process_deathflags();

	array_thread( ai, ::spawn_think );

	precache_player_weapon_drops( array("rpg", "panzerschreck") );
	
	// the callback is set up by calling maps\_hiding_door::main() in the level script
	if( IsDefined( level.hiding_door_spawner ) )
	{
		run_thread_on_noteworthy( "hiding_door_spawner", level.hiding_door_spawner );
	}
	
	
	/#
	debug_replay("File: _spawner.gsc. Function: main() - COMPLETE\n");
	#/
	
//	level thread flood_spawner_monitor();
	level thread trigger_spawner_monitor();
}

precache_player_weapon_drops( weapon_names )
{
	level.ai_classname_in_level_keys = getarraykeys( level.ai_classname_in_level );
	for ( i = 0 ; i < level.ai_classname_in_level_keys.size ; i++ )
	{
		if( weapon_names.size <= 0 )
		{
			break;
		}

		for( j = 0 ; j < weapon_names.size ; j++ )
		{
			weaponName = weapon_names[j];

			if ( !issubstr( tolower( level.ai_classname_in_level_keys[ i ] ), weaponName ) )
			{
				continue;
			}

			precacheItem( weaponName + "_player_sp" );

			weapon_names = array_remove( weapon_names, weaponName );
			break;
		}
	}
	level.ai_classname_in_level_keys = undefined;
}

process_deathflags()
{
	keys = getarraykeys( level.deathflags );
	level.deathflags = [];
	for ( i=0; i < keys.size; i++ )
	{
		deathflag = keys[ i ];
		level.deathflags[ deathflag ] = [];
		level.deathflags[ deathflag ][ "spawners" ] = [];
		level.deathflags[ deathflag ][ "ai" ] = [];
		
		if ( !IsDefined( level.flag[ deathflag ] ) )
		{
			flag_init( deathflag );
		}
	}
	
}

spawn_guys_until_death_or_no_count()
{
	self endon( "death" );
	self waittill( "count_gone" );
}

deathflag_check_count()
{
	self endon( "death" );
	
	// wait until the end of the frame, so other scripts have a chance to reincrement the spawners count
	waittillframeend;
	if ( self.count > 0 )
	{
		return;
	}

	self notify( "count_gone" );
}

ai_deathflag()
{
	level.deathflags[ self.script_deathflag ][ "ai" ][ self.ai_number ] = self;
	ai_number = self.ai_number;
	deathflag = self.script_deathflag;

	if ( IsDefined( self.script_deathflag_longdeath ) )
	{
		self waittillDeathOrPainDeath();
	}
	else
	{
		self waittill( "death" );
	}

	level.deathflags[ deathflag ][ "ai" ][ ai_number ] = undefined;
	update_deathflag( deathflag );
}


spawner_deathflag()
{
	level.deathflags[ self.script_deathflag ] = true;
	
	// wait for the process_deathflags script to run and setup the arrays
	waittillframeend;
	
	if ( !IsDefined( self ) || self.count == 0 )
	{
		// the spawner was removed on the first frame
		return;
	}

	// give each spawner a unique id
	self.spawner_number = level.spawner_number;
	level.spawner_number++;

	// keep an array of spawner entities that have this deathflag
	level.deathflags[ self.script_deathflag ][ "spawners" ][ self.spawner_number ] = self;
	deathflag = self.script_deathflag;
	id = self.spawner_number;

	spawn_guys_until_death_or_no_count();
	
	level.deathflags[ deathflag ][ "spawners" ][ id ] = undefined;

	update_deathflag( deathflag );
}

update_deathflag( deathflag )
{
	level notify( "updating_deathflag_" + deathflag );
	level endon( "updating_deathflag_" + deathflag );
	
	// notify and endon and waittill so we only do this a max of once per frame
	// even if multiple spawners or ai are killed in the same frame
	// also gives ai a chance to spawn and be added to the ai deathflag array
	waittillframeend;
	
	spawnerKeys = getarraykeys( level.deathflags[ deathflag ][ "spawners" ] );
	if ( spawnerKeys.size > 0 )
	{
		return;
	}

	aiKeys = getarraykeys( level.deathflags[ deathflag ][ "ai" ] );
	if ( aiKeys.size > 0 )
	{
		return;
	}
		
	// all the spawners and ai are gone
	flag_set( deathflag );
}

outdoor_think( trigger )
{
	assert( trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_AXIS)
		|| trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_ALLIES)
		|| trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_NEUTRAL),
		"trigger_outdoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );

	trigger endon( "death" );

	for ( ;; )
	{
		trigger waittill( "trigger", guy );

		if ( !IsAI( guy ) )
		{
			continue;
		}
		
		guy thread ignore_triggers( 0.15 );
		
		guy disable_cqbwalk();
		guy.wantShotgun = false;
	}	
}

indoor_think( trigger )
{
	assert( trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_AXIS)
			|| trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_ALLIES)
			|| trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_AI_NEUTRAL),
			"trigger_indoor at " + trigger.origin + " is not set up to trigger AI! Check one of the AI checkboxes on the trigger." );

	trigger endon( "death" );

	for ( ;; )
	{
		trigger waittill( "trigger", guy );

		if ( !IsAI( guy ) )
		{
			continue;
		}
		
		guy thread ignore_triggers( 0.15 );
		
		guy enable_cqbwalk();
		guy.wantShotgun = true;
	}	
}


trigger_spawner_monitor()
{
	println("Trigger spawner monitor running...");
	level._numTriggerSpawned = 0;
	
	while(1)
	{
		wait_network_frame();
		wait_network_frame();
		level._numTriggerSpawned = 0;
	}
}

ok_to_trigger_spawn(forceChoke)
{
	
	if(IsDefined(forceChoke))
	{
		choked = forceChoke;
	}
	else
	{
		choked = false;
	}

	if(IsDefined(self.script_trigger) && NumRemoteClients())
	{
		trigger = self.script_trigger;

		if(IsDefined(trigger.targetname) && (trigger.targetname == "flood_spawner"))
		{
			choked = true;
			
			if(IsDefined(trigger.script_choke) && !trigger.script_choke)
			{
				choked = false;
			}
		}
		else if(trigger has_spawnflag(level.SPAWNFLAG_TRIGGER_SPAWN))
		{

			if(IsDefined(trigger.script_choke) && trigger.script_choke)
			{
				choked = true;
			}
		}
	}
	
	if(IsDefined(self.targetname) && (self.targetname == "drone_axis" || self.targetname == "drone_allies"))
	{
		choked = true;
	}
	
			//TODO - TFLAME - 10/25/09 - Temp solution to spawn text spam mess in quagmire
	if( IsDefined(level._forcechoke) && level._numTriggerSpawned > 2 ) 
	{
		return false;
	}
	
	
	if(choked && NumRemoteClients())
	{
		if(level._numTriggerSpawned > 2)
		{
			println("Triggerspawn choke.");
			return false;
		}
	}
	return true;
}

trigger_spawner( trigger )
{
	assertEx( IsDefined( trigger.target ), "Triggers with flag TRIGGER_SPAWN at " + trigger.origin + " must target at least one spawner." );
	trigger endon( "death" );
	trigger waittill( "trigger" );
	spawners = getentarray( trigger.target, "targetname" );
	
	for(i = 0; i < spawners.size; i++)
	{
		spawners[i].script_trigger = trigger;
	}
	
	array_thread( spawners, ::trigger_spawner_spawns_guys );
}

trigger_spawner_spawns_guys()
{
	self endon( "death" );

	if ( IsSubStr( self.classname, "actor" ) )
	{
		self script_delay();

		while(!self ok_to_trigger_spawn())
		{
			wait_network_frame();
		}

		if ( IsDefined( self.script_drone ) )
		{
			spawned = dronespawn( self );
			level._numTriggerSpawned ++;
			assertEx( IsDefined( level.drone_spawn_func ), "You need to put maps\_drone::init(); in your level script!" );
			spawned thread [[ level.drone_spawn_func ]]();
			return;
		}
		
		self spawn_ai();
		level._numTriggerSpawned ++;
	}
}

flood_spawner_scripted( spawners )
{
	assertex( IsDefined( spawners ) && spawners.size, "Script tried to flood spawn without any spawners" ); 

	array_thread( spawners, ::flood_spawner_init );
	
/*	if(NumRemoteClients())
	{
		spread_array_thread(spawners, ::flood_spawner_think);
	}
	else */
	{
		array_thread( spawners, ::flood_spawner_think );
	}
}


reincrement_count_if_deleted( spawner )
{
	spawner endon( "death" ); 

	self waittill( "death" ); 
	if( !IsDefined( self ) )
	{
		spawner.count++; 
	}
}

kill_trigger( trigger )
{
	if( !IsDefined( trigger ) )
	{
		return; 
	}
		
	if( ( IsDefined( trigger.targetname ) ) &&( trigger.targetname != "flood_spawner" ) )
	{
		return; 
	}
		
	trigger Delete();
}

kill_spawner_trigger( trigger )
{
	trigger waittill( "trigger" );
	kill_spawnernum(trigger.script_killspawner);
}

empty_spawner( trigger )
{
	emptyspawner = trigger.script_emptyspawner;

	trigger waittill( "trigger" );
	spawners = GetSpawnerArray();
	for( i = 0; i < spawners.size; i++ )
	{
		if( !IsDefined( spawners[i].script_emptyspawner ) )
		{
			continue;
		}

		if( emptyspawner != spawners[i].script_emptyspawner )
		{
			continue;
		}

		if( IsDefined( spawners[i].script_flanker ) )
		{
			level notify( "stop_flanker_behavior" + spawners[i].script_flanker ); 
		}

		spawners[i].count = 0; 
		spawners[i] notify( "emptied spawner" ); 
	}
	trigger notify( "deleted spawners" ); 
}

waittillDeathOrPainDeath()
{
	self endon( "death" ); 
	self waittill( "pain_death" ); // pain that ends in death
}

drop_gear()
{
	team = self.team; 
	waittillDeathOrPainDeath(); 

	if( !IsDefined( self ) )
	{
		return; 
	}

	self.ignoreForFixedNodeSafeCheck = true;

	if( self.grenadeAmmo <= 0 )
	{
		return; 
	}

	if( IsDefined( self.dropweapon ) && !self.dropweapon )
	{
		return;
	}
	
	level.nextGrenadeDrop--; 
	if( level.nextGrenadeDrop > 0 )
	{
		return; 
	}

	level.nextGrenadeDrop = 2 + RandomInt( 2 ); 
	max = 25; 
	min = 12; 
	spawn_grenade_bag( self.origin +( RandomInt( max )-min, RandomInt( max )-min, 2 ) +( 0, 0, 42 ), ( 0, RandomInt( 360 ), 0 ), self.team ); 
	
}

random_tire( start, end )
{
    model = spawn( "script_model", (0,0,0) );
    model.angles = ( 0, randomint( 360 ), 0 );

    dif = randomfloat( 1 );
    model.origin = start * dif + end * ( 1 - dif );
    model setmodel( "com_junktire" );
    vel = randomvector( 15000 );
    vel = ( vel[ 0 ], vel[ 1 ], abs( vel[ 2 ] ) );
    model physicslaunch( model.origin, vel );
    
    wait ( randomintrange ( 8, 12 ) );
    model delete();
}
	
spawn_grenade_bag( origin, angles, team )
{
	// delete oldest grenade
	if( !IsDefined( level.grenade_cache ) || !IsDefined( level.grenade_cache[team] ) )
	{
		level.grenade_cache_index[team] = 0; 
		level.grenade_cache[team] = []; 
	}

	index = level.grenade_cache_index[team]; 
	grenade = level.grenade_cache[team][index]; 
	if( IsDefined( grenade ) )
	{
		grenade Delete(); 
	}

	count = self.grenadeammo;
	grenade = Spawn( "weapon_" + self.grenadeWeapon, origin ); 
	level.grenade_cache[team][index] = grenade; 
	level.grenade_cache_index[team] = ( index + 1 ) % 16;

	grenade.angles = angles;
	grenade.count = count;

	grenade SetModel( "grenade_bag" );
}

// This spawns the AI and then deletes him
dronespawn_setstruct( spawner )
{
	// spawn a guy, grab his info, delete him. Poor guy
	if ( dronespawn_check() )
	{
		return;
	}
		
	guy = spawner stalingradspawn(); // first frame everybody spawns and spawn_failed isn't effective yet
// 	failed = spawn_failed( guy );
// 	assert( !failed );
	if (isDefined(guy) )
	{
		spawner.count++ ; // replenish the spawner
		dronespawn_setstruct_from_guy( guy );
		guy delete();
	}
}

dronespawn_check()
{
	//spawn a guy, grab his info. delete him. Poor guy
	if(IsDefined(level.dronestruct[self.classname]))
	{
		return true;
	}
	return false;
	
}

// This creates the struct of models from the AI and remembers it
dronespawn_setstruct_from_guy ( guy )
{
	//spawn a guy, grab his info. delete him. Poor guy
	if (!isDefined(guy))
	{
		return;
	}	
	if(dronespawn_check())
	{
		return;
	}
	struct = spawnstruct();
	size = guy getattachsize();
	struct.attachedmodels = []; 
	for( i = 0; i < size; i++ )
	{
		struct.attachedmodels[i] = guy GetAttachModelName( i ); 
		struct.attachedtags[i] = guy GetAttachTagName( i ); 
	}
	struct.model = guy.model; 
	struct.weapon = guy.weapon;
//	return struct;
	level.dronestruct[guy.classname] = struct;
}

empty()
{
}

spawn_prethink()
{
	assert( self != level ); 

	level.ai_classname_in_level[ self.classname ] = true;
	
	/#
	if (getdvar ("noai") != "off")
	{
		// NO AI in the level plz
		self.count = 0; 
		return; 
	}
	#/
	
	prof_begin( "spawn_prethink" ); 

	if( IsDefined( self.script_drone ) )
	{
        self thread dronespawn_setstruct(self); //threaded because spawn_failed is weird
	}
			
	if( IsDefined( self.script_aigroup ) )
	{
		aigroup = self.script_aigroup; 
		aigroup_init( aigroup, self ); 			
	}

	if( IsDefined( self.script_delete ) )
	{
		array_size = 0; 
		if( IsDefined( level._ai_delete ) )
		{
			if( IsDefined( level._ai_delete[self.script_delete] ) )
			{
				array_size = level._ai_delete[self.script_delete].size; 
			}
		}

		level._ai_delete[self.script_delete][array_size] = self; 
	}
	
	deathflag_func = ::empty;
	if ( IsDefined( self.script_deathflag ) )
	{
		deathflag_func = ::deathflag_check_count;
		// sets this flag when all the spawners or ai with this flag are gone
		thread spawner_deathflag();
	}
	
	if ( IsDefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}
	
	/*
	// all guns are setup by default now
	// portable mg42 guys
	if( IsSubStr( self.classname, "mgportable" ) || IsSubStr( self.classname, "30cal" ) )
	{
		thread mg42setup_gun(); 
	}
	*/

	for( ;; )
	{
		prof_begin( "spawn_prethink" ); 

		self waittill( "spawned", spawn ); 

        [[ deathflag_func ]]();
		
		if( !IsAlive( spawn ) )
		{
			continue; 
		}
		
		if( IsDefined( self.script_delete ) )
		{
			for( i = 0; i < level._ai_delete[self.script_delete].size; i++ )
			{
				if( level._ai_delete[self.script_delete][i] != self )
				{
					level._ai_delete[self.script_delete][i] Delete(); 
				}
			}
		}

		spawn.spawn_funcs = self.spawn_funcs;
		spawn thread spawn_think( self ); 
	}
}

// Wrapper for spawn_think
// should change this so run_spawn_functions() can also work on drones
// currently assumes AI
spawn_think( spawner )
{
	assert( self != level );

	level.ai_classname_in_level[ self.classname ] = true;

	if (IsDefined(spawner))
	{
		spawn_think_action( spawner.targetname );
	}
	else
	{
		spawn_think_action();
	}

	assert( IsAlive( self ) );
	self endon( "death" );

	//MM (3/18/10) This is messing up dog spawns
	if ( GetDvar( #"zombiemode") != "1" && !IsDefined(self.name) && (self.type != "dog"))
	{
		self waittill( "set name and rank" );
	}

	self.finished_spawning = true;
	self notify("finished spawning");

	self thread run_spawn_functions(spawner);

	assert( IsDefined( self.team ) );
}

run_spawn_functions(spawner)
{
	self endon( "death" );

 	waittillframeend;	// spawn functions should override default settings, so they need to be last

	if( IsDefined(spawner) && IsDefined( level.spawnerCallbackThread ) )
	{
		spawner thread [[level.spawnerCallbackThread]]( self ); 
	}

	for (i = 0; i < level.spawn_funcs[ self.team ].size; i++)
	{
		func = level.spawn_funcs[ self.team ][ i ];
		single_thread(self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
	}

	self thread maps\_audio::missile_audio_watcher();

	if (!IsDefined( self.spawn_funcs ))
	{
		return;
	}

	for (i = 0; i < self.spawn_funcs.size; i++)
	{
		func = self.spawn_funcs[ i ];
		single_thread(self, func[ "function" ], func[ "param1" ], func[ "param2" ], func[ "param3" ], func[ "param4" ] );
	}


	/#
		self.saved_spawn_functions = self.spawn_funcs;
	#/

	self.spawn_funcs = undefined;

	/#
		// keep them around in developer mode, for debugging
		self.spawn_funcs = self.saved_spawn_functions;
		self.saved_spawn_functions = undefined;
	#/

	self.spawn_funcs = undefined;
}


living_ai_prethink()
{
	if ( IsDefined( self.script_deathflag ) )
	{
		// later this is turned into the real ddeathflag array
		level.deathflags[ self.script_deathflag ] = true;
	}
	
	if ( IsDefined( self.target ) )
	{
		crawl_through_targets_to_init_flags();
	}
}

crawl_through_targets_to_init_flags()
{
	// need to initialize flags on the path chain if need be
	array = get_node_funcs_based_on_target();
	if ( IsDefined( array ) )
	{
		targets = array[ "node" ];
		get_func = array[ "get_target_func" ];
		for ( i = 0; i < targets.size; i++ )
		{
			crawl_target_and_init_flags( targets[ i ], get_func );	
		}
	}
}

// Actually do the spawn_think
spawn_think_action( spawner_targetname )
{
	if ( GetDvar( #"zombiemode" ) == "0" )
	{
		self thread maps\_serverfaceanim::init_serverfaceanim();
	}

	// Don't override the targetname if already defined (i.e. passed into DoSpawn)
	if (IsDefined(spawner_targetname) && !IsDefined(self.targetname))
	{
		self.targetname = spawner_targetname + "_ai";
	}
	
	// handle default ai flags for ent_flag * functions
	self thread maps\_utility::ent_flag_init_ai_standards();
	
	self thread tanksquish();

	// ai get their values from spawners and theres no need to have this value on ai
	self.spawner_number = undefined;

	/#
//	if( GetDebugDvar( "debug_misstime" ) == "start" )
//	{
//		self thread maps\_debug::debugMisstime(); 
//	}
		
	thread show_bad_path(); 
	#/

	if( !IsDefined( self.ai_number ) )
	{
		set_ai_number(); 
	}

	if ( IsDefined( self.script_dontshootwhilemoving ) )
	{
		self.dontshootwhilemoving = true;
	}

	if ( IsDefined( self.script_deathflag ) )
	{
		thread ai_deathflag();
	}

	// MikeD (4/12/2008): Added the ability to set script_animname which will be the animname for the AI
	if( IsDefined( self.script_animname ) )
	{
		self.animname = self.script_animname;
	}

	if ( IsDefined( self.script_forceColor ) )
	{
		// send all forcecolor through a centralized function
		set_force_color( self.script_forceColor );

		// MikeD (9/5/2007): All AI spawned will do "replace_on_death" unless told not to.
		if( (!IsDefined( self.script_no_respawn ) || self.script_no_respawn < 1) && !IsDefined(level.no_color_respawners_sm) )
		{
			self thread replace_on_death();
		}
	}

	if ( IsDefined( self.script_fixednode ) )
	{
		// force the fixednode setting on an ai
		self.fixednode = ( self.script_fixednode == 1 );
	}
	else
	{
		// allies use fixednode by default
		self.fixednode = self.team == "allies";
	}

	set_default_covering_fire();

	if( ( IsDefined( self.script_moveoverride ) ) &&( self.script_moveoverride == 1 ) )
	{
		override = true; 
	}
	else
	{
		override = false; 
	}

	if( IsDefined( self.script_noteworthy ) && self.script_noteworthy == "mgpair" )
	{
		// mgpair guys get angry when their fellow buddy dies
		thread maps\_mg_penetration::create_mg_team(); 
	}
	
	if ( GetDvar( #"zombiemode" ) == "0" )
	{
		level thread maps\_friendlyfire::friendly_fire_think( self ); 
	}
	
	// create threatbiasgroups
	if( IsDefined( self.script_threatbiasgroup ) )
	{
		self SetThreatBiasGroup( self.script_threatbiasgroup ); 
	}
	else if( self.team == "allies" )
	{
		self SetThreatBiasGroup( "allies" ); 
	}
	else
	{
		self SetThreatBiasGroup( "axis" ); 
	}
	
	/#	
	if ( self.type == "human" && IsDefined(self.export))
	{
		assertEx( self.pathEnemyLookAhead == 0 && self.pathEnemyFightDist == 0, "Tried to change pathenemyFightDist or pathenemyLookAhead on an AI before running spawn_failed on guy with export " + self.export );
	}
	#/

	set_default_pathenemy_settings(); 

	self.heavy_machine_gunner = 	IsSubStr( self.classname, "mgportable" );

// ALEXP 6/8/09: disabled lmg shoulder run anims because they break locomotion by not having complete anim set
//	self.heavy_machine_gunner = 	IsSubStr( self.classname, "mgportable" ) 	|| 
//									IsSubStr( self.classname, "rpd" ) 			||
//									IsSubStr( self.classname, "saw" ) 			|| 
//									IsSubStr( self.classname, "dp28" ); 
	
	maps\_gameskill::grenadeAwareness(); 

	//if( IsDefined( self.script_bcdialog ) )
	//{
	//	self set_battlechatter( self.script_bcdialog ); 
	//}

	self.walkdist = 16; 

	if( IsDefined( self.script_ignoreme ) )
	{
		assertEx( self.script_ignoreme == true, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
		self.ignoreme = true; 
	}

	if ( IsDefined( self.script_ignore_suppression ) )
	{
		assertEx( self.script_ignore_suppression == true, "Tried to set self.script_ignore_suppresion to false, not allowed. Just set it to undefined." );
		self.ignoreSuppression = true;
	}

	if( IsDefined( self.script_hero ) )
	{
		AssertEx( self.team == "allies", "Only use script_hero kvp on friendly AI, else use magic_bullet_shield directly." );
		AssertEx( self.script_hero == 1, "Tried to set script_hero to something other than 1" );

		self make_hero();
	}

	if ( IsDefined( self.script_ignoreall ) )
	{
		assertEx( self.script_ignoreall == true, "Tried to set self.script_ignoreme to false, not allowed. Just set it to undefined." );
		self.ignoreall = true;
		self clearenemy();
	}

	// AI revive feature
	if( GetDvar( #"zombiemode") != "1" && IsDefined( self.script_disable_bleeder ) )
	{
		// If this is set then this AI will not be a bleeder. He will die straight.
		assertEx( self.script_disable_bleeder == true, "self.script_disable_bleeder can only be set to true. To set to true, leave it undefined." );
		self disable_ai_bleeder();
	}

	if( GetDvar( #"zombiemode") != "1" && IsDefined( self.script_disable_reviver ) )
	{
		// If this is set then this AI will not be a reviver. Use this for a scripted AI in the level to avoid conflicts.
		assertEx( self.script_disable_reviver == true, "self.script_disable_reviver can only be set to true. To set to true, leave it undefined." );
		self disable_ai_reviver();
	}

	// disable reaction feature if needed
	if( IsDefined( self.script_disablereact ) )	
	{
		self disable_react();
	}

	// disable pain if needed
	if( IsDefined( self.script_disablepain ) )	
	{
		self disable_pain();
	}

	// disable pain if needed
	if( IsDefined( self.script_disableturns ) )	
	{
		self.disableTurns = true;
	}	

	if( IsDefined( self.script_sightrange ) )
	{
		self.maxSightDistSqrd = self.script_sightrange; 
	}
	else if( WeaponClass( self.weapon ) == "gas" )
	{
		self.maxSightDistSqrd = 1024 * 1024; 
	}

	if( self.team != "axis" )
	{
		// Set the followmin for friendlies
		if( IsDefined( self.script_followmin ) )
		{
			self.followmin = self.script_followmin; 
		}

		// Set the followmax for friendlies
		if( IsDefined( self.script_followmax ) )
		{
			self.followmax = self.script_followmax; 
		}
	}

	if ( self.team == "axis" )
	{
		if ( self.type == "human" )
		{
			self thread drop_gear();
			//self thread drophealth();
		}

		/#
			self thread maps\_damagefeedback::monitorDamage();
		#/

		// SCRIPTER_MOD: JesseS (4/14/2008): Need to add this back in, used for arcade mode.
		self thread maps\_gameskill::auto_adjust_enemy_death_detection();
	}

	if( IsDefined( self.script_fightdist ) )
	{
		self.pathenemyfightdist = self.script_fightdist; 
	}
	
	if( IsDefined( self.script_maxdist ) )
	{
		self.pathenemylookahead = self.script_maxdist; 	
	}

	// disable long death like dying pistol behavior
	if ( IsDefined( self.script_longdeath ) )
	{
		assertex( !self.script_longdeath, "Long death is enabled by default so don't set script_longdeath to true, check ai with export " + self.export );
		self.a.disableLongDeath = true;	
		assertEX( self.team != "allies", "Allies can't do long death, so why disable it on guy with export " + self.export );
	}

	// Gives AI grenades (defaults for each cod5 aitype are specified in aitypes_charactersettings.gdt)
	if( IsDefined( self.script_grenades ) )
	{
		self.grenadeAmmo = self.script_grenades; 
	}
		
	// Puts AI in pacifist mode
	if( IsDefined( self.script_pacifist ) )
	{
		self.pacifist = true; 
	}

	// Set the health for special cases
	if( IsDefined( self.script_startinghealth ) )
	{
		self.health = self.script_startinghealth; 
	}

	// GLocke [8/30] allow the AI to be killed during animations (like traversals)
	if( IsDefined(self.script_allowdeath) )
	{
		self.allowdeath = self.script_allowdeath;
	}
	
	// SCRIPTER_MOD: JesseS (1/11/2008): turn off weapon drops. ask a lead before using!
	if( IsDefined(self.script_nodropweapon) )
	{
		self.dropweapon = 0;
	}

	// Force gib support on KVP
	if( IsDefined( self.script_forcegib ) )
	{
		self.force_gib = 1;
		
		// use the string as gib ref
		if( call_overloaded_func( "animscripts\death", "isValidGibRef", self.script_forcegib ) )
		{
			self.custom_gib_refs[0] = self.script_forcegib;
		}
	}

	// starth stealth if needed
	if( IsDefined( self.script_stealth ) )
	{
		self thread call_overloaded_func( "maps\_stealth_logic", "stealth_ai" );
	}

	// The AI will spawn and follow a patrol
	if( IsDefined( self.script_patroller ) )
	{
		self thread maps\_patrol::patrol(); 
		return; 
	}
	else if( IsDefined( self.script_contextual_melee ) )
	{
		self contextual_melee(self.script_contextual_melee);
	}

	// MikeD: New spiderhole feature
	if( IsDefined( self.script_spiderhole ) )
	{
		self thread maps\_spiderhole::spiderhole(); 
		return;
	}

	if (is_true(self.script_rusher))
	{
		self call_overloaded_func( "maps\_rusher", "rush" );
		return;
	}
	
	if( IsDefined( self.script_enable_cqbwalk ) )
	{
		self maps\_utility::enable_cqbwalk();
	}

	if( IsDefined( self.script_enable_heat ) )
	{
		self maps\_utility::enable_heat();
	}

	if( IsDefined( self.script_disable_idle_strafe ) && self.script_disable_idle_strafe )
	{
		self.disableIdleStrafing = true;
	}

	// Setup playerseek	
	if( IsDefined( self.script_playerseek ) )
	{
		if( self.script_playerseek == 1 )
		{
			self thread player_seek(); // direct player seek
			return;
		}
		else
		{
			self thread player_seek( self.script_playerseek ); // delayed player seek
		}
	}

	// MikeD: New Banzai feature
	if( IsDefined( self.script_banzai ) )
	{
		self thread maps\_banzai::spawned_banzai_dynamic(); 
	}
	else if( IsDefined( self.script_banzai_spawn ) )
	{
		self thread maps\_banzai::spawned_banzai_immediate();
	}
	
	if( self.heavy_machine_gunner )
	{
		thread maps\_mgturret::portable_mg_behavior(); 
	}

	if( IsDefined( self.used_an_mg42 ) ) // This AI was called upon to use an MG42 so he's not going to run to his node.
	{
		return; 
	}	
	
	assertEx( (self.goalradius == 8 || self.goalradius == 4), "Changed the goalradius on guy without waiting for spawn_failed. Note that this change will NOT show up by putting a breakpoint on the actors goalradius field because breakpoints don't properly handle the first frame an actor exists." );

	if( override )
	{
		self thread set_goalradius_based_on_settings();
		self SetGoalPos( self.origin ); 
		return; 
	}

	if( IsDefined( self.target ) )
	{
		self thread go_to_node(); 
	}
	else
	{
		self thread set_goalradius_based_on_settings();

		if (IsDefined(self.script_spawner_targets))
		{
			// New way of sending guys to nodes using "script_spawner_targets" key on the spawner
			self thread go_to_spawner_target(StrTok(self.script_spawner_targets," "));
		}
	}

	// set the goal volume after the goal position has been set
	if( IsDefined( self.script_goalvolume ) )
	{
		thread set_goal_volume(); 
	}

	// override for the default turnrate (ai_turnrate dvar). Degrees per second (360 = one complete turn)
	if( IsDefined( self.script_turnrate ) )
	{
		self.turnrate = self.script_turnrate;
	}

	self maps\_dds::dds_ai_init();
}

set_default_covering_fire()
{
	// allies use "provide covering fire" mode in fixednode mode.
	self.provideCoveringFire = self.team == "allies" && self.fixedNode;
}

flag_turret_for_use( ai )
{
	self endon( "death" );
	if( !self.flagged_for_use )
	{
		ai.used_an_mg42 = true;
		self.flagged_for_use = true;
		ai waittill( "death" );
		self.flagged_for_use = false;
		self notify( "get new user" );
		return;
	}

	println( "Turret was already flagged for use" );
}

set_goal_volume()
{
	self endon( "death" );
	// wait until frame end so that the AI's goal has a chance to get set
	waittillframeend;
	self SetGoalVolume( level.goalVolumes[self.script_goalvolume] );
}

get_target_ents( target )
{
	return getentarray( target, "targetname" );
}

get_target_nodes( target )
{
	return getnodearray( target, "targetname" );
}

get_target_structs( target )
{
	return getstructarray( target, "targetname" );
}

node_has_radius( node )
{
	return IsDefined( node.radius ) && node.radius != 0;
}

go_to_origin( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "origin", optional_arrived_at_node_func );
}

go_to_struct( node, optional_arrived_at_node_func )
{
	self go_to_node( node, "struct", optional_arrived_at_node_func );
}

go_to_node( node, goal_type, optional_arrived_at_node_func )
{
	self endon("death");

	if ( IsDefined( self.used_an_mg42 ) )// This AI was called upon to use an MG42 so he's not going to run to his node.
	{
		return;
	}

	array = get_node_funcs_based_on_target( node, goal_type );
	if ( !IsDefined( array ) )
	{
		self notify( "reached_path_end" );
		// no goal type
		return;
	}
	
	if ( !IsDefined( optional_arrived_at_node_func ) )
	{
		optional_arrived_at_node_func = ::empty_arrived_func;
	}
	
	go_to_node_using_funcs( array[ "node" ], array[ "get_target_func" ], array[ "set_goal_func_quits" ], optional_arrived_at_node_func );
}

//////////////////////////////////////////////////////////////////////
/////////// Handling of script_spawner_targets ///////////////////////
//																	//
// This was new functionality for Spawn Manager.  Now works for		//
// any spawner regardless of how it is spawned.  Sends AI to a		//
// random node that is in the same 'script_spawner_targets' group.	//
//////////////////////////////////////////////////////////////////////

//-- Makes a global array of nodes that is then processed by the spawner targets system
spawner_targets_init()
{
	allnodes = GetAllNodes(); 
	level.script_spawner_targets_nodes = [];
	for( i = 0; i < allnodes.size; i++)
	{
		if(IsDefined(allnodes[i].script_spawner_targets)) 
		{
			level.script_spawner_targets_nodes[level.script_spawner_targets_nodes.size] = allnodes[i];
		}		
	}
}

go_to_spawner_target(target_names)
{
	self endon("death");

	self notify("go_to_spawner_target");
	self endon("go_to_spawner_target");

	nodes = [];
	occupied_nodes = [];
	nodesPresent = false;
			
	for ( i = 0; i < target_names.size; i++)
	{
		target_nodes = get_spawner_target_nodes(target_names[i]);
		if( target_nodes.size > 0 )
		{
			nodesPresent = true;
		}

		for ( i = 0; i < target_nodes.size; i++)
		{
			if ( IsNodeOccupied(target_nodes[i]) || is_true(target_nodes[i].node_claimed) ) 
			{
				// store all the occupied nodes for later use.
				occupied_nodes = array_add(occupied_nodes, target_nodes[i]);
			}
			else
			{
				nodes = array_add(nodes, target_nodes[i]);
			}
		}

	}

	// if not a single node is unoccupied then wait until one is.
	if( nodes.size == 0 )
	{
		while( nodes.size == 0 )
		{
			for ( i = 0; i < occupied_nodes.size; i++)
			{
				if( !IsNodeOccupied(occupied_nodes[i]) && !is_true(occupied_nodes[i].node_claimed))
				{
					nodes = array_add(nodes, occupied_nodes[i]);
					break;
				}
			}

			wait( 0.1 );
		}
	}
	
	AssertEx(nodesPresent, "No spawner target nodes for AI.");

	goal = undefined;
	if( nodes.size > 0 )
	{	
		goal = random(nodes);
	}		
	
	if (IsDefined(goal))
	{
		// If script has set the goalradius then use it to go to the spawner target
		if( IsDefined( self.script_radius ) )
		{
			self.goalradius = self.script_radius;
		}
		else	
		{
			self.goalradius = 400;  // TODO: this is temp
		}
		
		goal.node_claimed = true;
		self SetGoalNode(goal);
		
		self thread release_spawner_target_node(goal);

		self waittill("goal");
	}
	
	self set_goalradius_based_on_settings(goal);
}

release_spawner_target_node(node)
{
	self waittill_any("death", "goal_changed");
	node.node_claimed = undefined;	
}

// GLocke: 5/26/10 - changed this to use a global level array instead of recreating
// the node array everytime an AI is told to go_to_spawner_target
get_spawner_target_nodes(group)
{
	if(group == "")
	{
		return [];
	}	

	nodes = [];
	for ( i = 0; i < level.script_spawner_targets_nodes.size; i++)
	{		
		groups = strtok(level.script_spawner_targets_nodes[i].script_spawner_targets," ");

		for ( j = 0; j < groups.size; j++)
		{
			if (groups[j] == group)
			{
				nodes[nodes.size] = level.script_spawner_targets_nodes[i];
			}
		}		
	}

	return nodes;
}

//////////////////////////////////////////////////////////////////
/////////// End of script_spawner_targets handling ///////////////
//////////////////////////////////////////////////////////////////

empty_arrived_func( node )
{
}

get_least_used_from_array( array )
{
	assertex( array.size > 0, "Somehow array had zero entrees" );
	if ( array.size == 1 )
	{
		return array[ 0 ];
	}
		
	targetname = array[ 0 ].targetname;
	if ( !IsDefined( level.go_to_node_arrays[ targetname ] ) )
	{
		level.go_to_node_arrays[ targetname ] = array;
	}
	
	array = level.go_to_node_arrays[ targetname ];
	
	// return the node at the front of the array and move it to the back of the array.
	first = array[ 0 ];
	newarray = [];
	for ( i = 0; i < array.size - 1; i++ )
	{
		newarray[ i ] = array[ i + 1 ];
	}
	newarray[ array.size - 1 ] = array[ 0 ];
	level.go_to_node_arrays[ targetname ] = newarray;
		
	return first;
}


go_to_node_using_funcs( node, get_target_func, set_goal_func_quits, optional_arrived_at_node_func, require_player_dist )
{
	// AI is moving to a goal node
	self endon( "stop_going_to_node" );
	self endon( "death" );

	for ( ;; )
	{
		// node should always be an array at this point, so lets get just 1 out of the array
		node = get_least_used_from_array( node );

		player_wait_dist = require_player_dist;
		if( isdefined( node.script_requires_player ) )
		{
			if( node.script_requires_player > 1 )
				player_wait_dist = node.script_requires_player;
			else
				player_wait_dist = 256;		
		
			node.script_requires_player = false;
		}

		self set_goalradius_based_on_settings( node );
	
		if ( IsDefined( node.height ) )
		{
			self.goalheight = node.height;
		}
		else
		{	
			self.goalheight = level.default_goalheight;
		}
		
		[[ set_goal_func_quits ]]( node );
		self waittill( "goal" );

		[[ optional_arrived_at_node_func ]]( node );

		if ( IsDefined( node.script_flag_set ) )
		{
			flag_set( node.script_flag_set );
		}
	
		if ( IsDefined( node.script_flag_clear ) )
		{
			flag_set( node.script_flag_clear );
		}
			
		if ( IsDefined( node.script_ent_flag_set ) )
		{
			if( !self flag_exists( node.script_ent_flag_set ) )
				AssertEx( "Tried to set a ent flag  "+ node.script_ent_flag_set +"  on a node, but it doesnt exist." );

			self ent_flag_set( node.script_ent_flag_set );
		}		

		if ( IsDefined( node.script_ent_flag_clear ) )
		{
			if( !self flag_exists( node.script_ent_flag_clear ) )
				AssertEx( "Tried to clear a ent flag  "+ node.script_ent_flag_clear +"  on a node, but it doesnt exist." );

			self ent_flag_clear( node.script_ent_flag_clear );
		}

		if ( targets_and_uses_turret( node ) )
		{
			return true;
		}

		if( IsDefined( node.script_enable_cqbwalk ) )
		{
			self enable_cqbwalk();
		}
		
		if( IsDefined( node.script_disable_cqbwalk ) )
		{
			self disable_cqbwalk();
		}
	
		if( IsDefined( node.script_enable_heat ) )
		{
			self enable_heat();
		}
		
		if( IsDefined( node.script_disable_heat ) )
		{
			self disable_heat();
		}
	
		if( IsDefined( node.script_sprint ) )
		{
			if( node.script_sprint )
			{
				self.sprint = true;
			}
			else
			{
				self.sprint = false;
			}
		}

		if( IsDefined( node.script_walk ) )
		{
			if( node.script_walk )
			{
				self.walk = true;
			}
			else
			{
				self.walk = false;
			}
		}
	
		if ( IsDefined( node.script_flag_wait ) )
		{
			flag_wait( node.script_flag_wait );
		}

		while ( isdefined( node.script_requires_player ) )
		{
			node.script_requires_player = false;
			if ( self go_to_node_wait_for_player( node, get_target_func, player_wait_dist ) )
			{
				node.script_requires_player = true;
				node notify( "script_requires_player" );
				break;
			}

			wait 0.1;
		}
		
		if( IsDefined( node.script_aigroup ) )
		{
			waittill_ai_group_cleared(  node.script_aigroup  );
		}

		node script_delay();

		if ( !IsDefined( node.target ) )
		{
			break;
		}

		nextNode_array = [[ get_target_func ]]( node.target );
		if ( !nextNode_array.size )
		{
			break;
		}

		node = nextNode_array;
	}


	if( IsDefined( self.arrived_at_end_node_func ) )
		[[ self.arrived_at_end_node_func ]]( node );

	self notify( "reached_path_end" );

	if( IsDefined( self.delete_on_path_end ) )
		self Delete();

	self set_goalradius_based_on_settings( node );
}


go_to_node_wait_for_player( node, get_target_func, dist )
{
	//are any of the players closer to the node than we are?
	players = get_players();		

	for( i=0; i< players.size; i++ )
	{
		player = players[i];

		if ( distancesquared( player.origin, node.origin ) < distancesquared( self.origin, node.origin ) )
			return true;
	}

	//are any of the player ahead of us based on our forward angle?
	vec = anglestoforward( self.angles );
	if ( isdefined( node.target ) )
	{
		temp = [[ get_target_func ]]( node.target );

		//if we only have one node then we can get the forward from that one to us
		if ( temp.size == 1 )
			vec = vectornormalize( temp[ 0 ].origin - node.origin );
		//otherwise since we dont know which one we're taking yet the next best thing to do is to take the forward of the node we're on
		else if ( isdefined( node.angles ) )
			vec = anglestoforward( node.angles );
	}
	//also if there is no target since we're at the end of the chain, the next best thing to do is to take the forward of the node we're on
	else if ( isdefined( node.angles ) )
		vec = anglestoforward( node.angles );

	vec2 = [];

	for( i=0; i< players.size; i++ )
	{
		player = players[i];

		vec2[ vec2.size ] = vectornormalize( ( player.origin - self.origin ) );
	}

	//i just created a vector which is in the direction i want to
	//go, lets see if the player is closer to our goal than we are			
	for( i=0; i< vec2.size; i++ )
	{
		value = vec2[i];

		if ( vectordot( vec, value ) > 0 )
			return true;
	}

	//ok so that just checked if he was a mile away but more towards the target
	//than us...but we dont want him to be right on top of us before we start moving
	//so lets also do a distance check to see if he's close behind
	dist2rd = dist * dist;
	for( i=0; i< players.size; i++ )
	{
		player = players[i];

		if ( distancesquared( player.origin, self.origin ) < dist2rd )
			return true;
	}

	//ok guess he's not here yet	
	return false;
}


go_to_node_set_goal_pos( ent )
{
	self set_goal_pos( ent.origin );
}

go_to_node_set_goal_node( node )
{
	self set_goal_node( node );
}

targets_and_uses_turret( node )
{
	if ( !IsDefined( node.target ) )
	{
		return false;
	}
		
	turrets = getentarray( node.target, "targetname" );
	if ( !turrets.size )
	{
		return false;
	}
	
	turret = turrets[ 0 ];
	if ( turret.classname != "misc_turret" )
	{
		return false;
	}
	
	thread use_a_turret( turret );
	return true;
}

remove_crawled( ent )
{
	waittillframeend;
	if ( IsDefined( ent ) )
	{
		ent.crawled = undefined;
	}
}

crawl_target_and_init_flags( ent, get_func )
{
	oldsize = 0;
	targets = [];
	index = 0;
	for ( ;; )
	{
		if ( !IsDefined( ent.crawled ) )
		{
			ent.crawled = true;
			level thread remove_crawled( ent );
			
			if ( IsDefined( ent.script_flag_set ) )
			{
				if ( !IsDefined( level.flag[ ent.script_flag_set ] ) )
				{
					flag_init( ent.script_flag_set );
				}
			}
		
			if ( IsDefined( ent.script_flag_wait ) )
			{
				if ( !IsDefined( level.flag[ ent.script_flag_wait ] ) )
				{
					flag_init( ent.script_flag_wait );
				}
			}

			if ( IsDefined( ent.target ) )
			{
				new_targets = [[ get_func ]]( ent.target );
				targets = add_to_array( targets, new_targets );
			}
		}
			
		index++ ;
		if ( index >= targets.size )
		{
			break;
		}
			
		ent = targets[ index ];		
	}
}

get_node_funcs_based_on_target( node, goal_type )
{
	// figure out if its a node or script origin and set the goal_type index based on that.

	// true is for script_origins, false is for nodes
	get_target_func[ "origin" ] = ::get_target_ents;
	get_target_func[ "node" ] = ::get_target_nodes;
	get_target_func[ "struct" ] = ::get_target_structs;

	set_goal_func_quits[ "origin" ] = ::go_to_node_set_goal_pos;
	set_goal_func_quits[ "struct" ] = ::go_to_node_set_goal_pos;
	set_goal_func_quits[ "node" ] = ::go_to_node_set_goal_node;
	
	// if you pass a node, we'll assume you actually passed a node. We can make it find out if its a script origin later if we need that functionality.
	if ( !IsDefined( goal_type ) )
	{
		goal_type = "node";
	}
	
	array = [];
	if ( IsDefined( node ) )
	{
		array[ "node" ][ 0 ] = node;
	}
	else
	{
		// if you dont pass a node then we need to figure out what type of target it is
		node = getentarray( self.target, "targetname" );
	
		if ( node.size > 0 )
		{
			goal_type = "origin";
		}

		if ( goal_type == "node" )
		{
			node = getnodearray( self.target, "targetname" );
			if ( !node.size )
			{
				node = getstructarray( self.target, "targetname" );
				if ( !node.size )
				{
					// Targetting neither
					return;
				}
				goal_type = "struct";
			}
		}
	
		array[ "node" ] = node;
	}

	array[ "get_target_func" ] = get_target_func[ goal_type ];
	array[ "set_goal_func_quits" ] = set_goal_func_quits[ goal_type ];
	return array;
}


set_goalradius_based_on_settings( node )
{
	self endon( "death" );
	waittillframeend;
	if( IsDefined( self.script_radius ) )
	{
		// use the override from radiant
		self.goalradius = self.script_radius;
	}
	else if( IsDefined( self.script_banzai_spawn ) )
	{
		self.goalradius = 64;
	}
	else if ( IsDefined( node ) && node_has_radius( node ) )
	{
		self.goalradius = node.radius;
	}
	else
	{
		// otherwise use the script default
		self.goalradius = level.default_goalradius;
	}

	if (is_true(self.script_forcegoal))
	{
		self thread force_goal();
	}
}

reachPathEnd()
{
	self waittill( "goal" ); 
	self notify( "reached_path_end" ); 
}

autoTarget( targets )
{
	for( ;; )
	{
		user = self GetTurretOwner(); 
		if( !IsAlive( user ) )
		{
			wait( 1.5 ); 
			continue; 
		}
		
		if( !IsDefined( user.enemy ) )
		{
			self SetTargetEntity( random( targets ) ); 
			self notify( "startfiring" ); 
			self StartFiring(); 
		}

		wait( 2 + RandomFloat( 1 ) ); 
	}
}

manualTarget( targets )
{
	for( ;; )
	{
		self SetTargetEntity( random( targets ) ); 
		self notify( "startfiring" ); 
		self StartFiring(); 

		wait( 2 + RandomFloat( 1 ) ); 
	}
}

// this is called from two places w/ generally identical code... maybe larger scale cleanup is called for.
use_a_turret( turret )
{
	if( self.team == "axis" && self.health == 150 )
	{
		self.health = 100; // mg42 operators aren't going to do long death
		self.a.disableLongDeath = true; 
	}

	unmanned = false;

//	thread maps\_mg_penetration::gunner_think( turret ); 
		
	self Useturret( turret ); // dude should be near the mg42
//	turret SetMode( "auto_ai" ); // auto, auto_ai, manual
//	turret SetMode( "manual" ); // auto, auto_ai, manual
	if( ( IsDefined( turret.target ) ) &&( turret.target != turret.targetname ) )
	{
		ents = GetEntArray( turret.target, "targetname" ); 
		targets = []; 
		for( i = 0; i < ents.size; i++ )
		{
			if( ents[i].classname == "script_origin" )
			{
				targets[targets.size] = ents[i]; 
			}
		}
		

		// MikeD (4/7/2008): Updated manual targets
		if( targets.size > 0 )
		{
			turret.manual_targets = targets;
			turret SetMode( "auto_nonai" );
			turret thread maps\_mgturret::burst_fire_unmanned();

			unmanned = true;
		}
	}

	if( !unmanned )
	{
		self thread maps\_mgturret::mg42_firing( turret ); 
	}

	turret notify( "startfiring" ); 
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_spawner_think( num, node_array, ignoreWhileFallingBack )
{
	self endon( "death" ); 
		
	level.max_fallbackers[num]+= self.count; 
	firstspawn = true; 
	while( self.count > 0 )
	{
		self waittill( "spawned", spawn ); 
		if( firstspawn )
		{
			if( GetDvar( #"fallback" ) == "1" )
			{
				println( "^a First spawned: ", num ); 
			}
			level notify( ( "fallback_firstspawn" + num ) ); 
			firstspawn = false; 
		}
		
		maps\_spawner::waitframe(); // Wait until he does all his usual spawned logic so he will run to his node
		if( spawn_failed( spawn ) )
		{
			level notify( ( "fallbacker_died" + num ) ); 
			level.max_fallbackers[num]--; 
			continue; 
		}

		spawn thread fallback_ai_think( num, node_array, "is spawner", ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back 
	}

//	level notify( ( "fallbacker_died" + num ) ); 
}

fallback_ai_think_death( ai, num )
{
	ai waittill( "death" ); 
	level.current_fallbackers[num]--; 

	level notify( ( "fallbacker_died" + num ) ); 
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_ai_think( num, node_array, spawner, ignoreWhileFallingBack )
{
	if( ( !IsDefined( self.fallback ) ) ||( !IsDefined( self.fallback[num] ) ) )
	{
		self.fallback[num] = true; 
	}
	else
	{
		return; 
	}

	self.script_fallback = num; 
	if( !IsDefined( spawner ) )
	{
		level.current_fallbackers[num]++; 
	}

	if( ( IsDefined( node_array ) ) &&( level.fallback_initiated[num] ) )
	{
		self thread fallback_ai( num, node_array, ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
	}

	level thread fallback_ai_think_death( self, num ); 
}

fallback_death( ai, num )
{
	ai waittill( "death" ); 
	
	if (IsDefined(ai.fallback_node))
	{
		ai.fallback_node.fallback_occupied = false;
	}
			
	level notify( ( "fallback_reached_goal" + num ) ); 
//	ai notify( "fallback_notify" ); 
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_goal( ignoreWhileFallingBack )
{
	self waittill( "goal" ); 
	self.ignoresuppression = false;
	
	if( IsDefined( ignoreWhileFallingBack ) && ignoreWhileFallingBack )
	{
		self.ignoreall = false;
	}

	self notify( "fallback_notify" ); 
	self notify( "stop_coverprint" ); 
}

fallback_interrupt()
{
	self notify( "stop_fallback_interrupt" );   
    self endon( "stop_fallback_interrupt" ); 
    
	self endon( "stop_going_to_node" ); 
	self endon ("goto next fallback");
	self endon ("fallback_notify");
	self endon( "death" );  
	
	while(1)
	{
		origin = self.origin;
		wait 2;
		if ( self.origin == origin )
		{
			self.ignoreall  = false;
			return;
		}
	}
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_ai( num, node_array, ignoreWhileFallingBack )
{
	self notify( "stop_going_to_node" ); 
	self endon( "stop_going_to_node" ); 
	self endon ("goto next fallback");
	self endon( "death" );  // SRS 5/21/2008: bugfix - this kept running after AIs were dead

	node = undefined;
	// set the goalnode
	while( 1 )
	{
		ASSERTEX((node_array.size >= level.current_fallbackers[num]), "Number of fallbackers exceeds number of fallback nodes for fallback # " + num + ". Add more fallback nodes or reduce possible fallbackers.");
		
		node = node_array[RandomInt( node_array.size )];
		if (!IsDefined(node.fallback_occupied) || !node.fallback_occupied)
		{
			// set the node occupied so we know to find another one
			node.fallback_occupied = true;
			self.fallback_node = node;
			break;
		}

		wait( 0.1 );
	}
	
	self StopUseTurret();
	self.ignoresuppression = true;
	
	if( self.ignoreall == false && IsDefined( ignoreWhileFallingBack ) && ignoreWhileFallingBack )
	{
		self.ignoreall = true;
		self thread fallback_interrupt();
	}
		
	self SetGoalNode( node );
	if( node.radius != 0 )
	{
		self.goalradius = node.radius;
	}

	self endon( "death" ); 
	level thread fallback_death( self, num ); 
	self thread fallback_goal( ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back

	if( GetDvar( #"fallback" ) == "1" )
	{
		self thread coverprint( node.origin ); 
	}

	self waittill( "fallback_notify" ); 
	level notify( ( "fallback_reached_goal" + num ) ); 
}

coverprint( org )
{
	self endon( "fallback_notify" ); 
	self endon( "stop_coverprint" ); 
	self endon ("death");
	while( 1 )
	{
		line( self.origin +( 0, 0, 35 ), org, ( 0.2, 0.5, 0.8 ), 0.5 ); 
		print3d( ( self.origin +( 0, 0, 70 ) ), "Falling Back", ( 0.98, 0.4, 0.26 ), 0.85 ); 
		maps\_spawner::waitframe(); 
	}
}

// This gets set up on each fallback trigger
// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_overmind( num, group, ignoreWhileFallingBack, percent )
{
	fallback_nodes = undefined; 
	nodes = GetAllNodes(); 
	for( i = 0; i < nodes.size; i++ )
	{
		if( ( IsDefined( nodes[i].script_fallback ) ) &&( nodes[i].script_fallback == num ) )
		{
			fallback_nodes = add_to_array( fallback_nodes, nodes[i] ); 
		}
	}

	if( IsDefined( fallback_nodes ) )
	{
		level thread fallback_overmind_internal( num, group, fallback_nodes, ignoreWhileFallingBack, percent );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
	}
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_overmind_internal( num, group, fallback_nodes, ignoreWhileFallingBack, percent )
{
	// SCRIPTER_MOD: JesseS (7/13/200): fixed up current vs max fallbackers, added a level max per
	// script_fallback
	level.current_fallbackers[num] = 0;			// currently alive fallbackers
	level.max_fallbackers[num] = 0;					// maximum fallbackers 
	level.spawner_fallbackers[num] = 0; 		// number of fallback spawners
	level.fallback_initiated[num] = false; 	// has fallback started? 


	spawners = GetSpawnerArray(); 
	for( i = 0; i < spawners.size; i++ )
	{
		if( ( IsDefined( spawners[i].script_fallback ) ) &&( spawners[i].script_fallback == num ) )
		{
			if( spawners[i].count > 0 )
			{
				spawners[i] thread fallback_spawner_think( num, fallback_nodes, ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back 
				level.spawner_fallbackers[num]++; 
			}
		}
	}

	assertex ( level.spawner_fallbackers[num] <= fallback_nodes.size, "There are more fallback spawners than fallback nodes. Add more node or remove spawners from script_fallback: "+ num );

	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		if( ( IsDefined( ai[i].script_fallback ) ) &&( ai[i].script_fallback == num ) )
		{
			ai[i] thread fallback_ai_think( num, undefined, undefined, ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
		}
	}

	if( ( !level.current_fallbackers[num] ) &&( !level.spawner_fallbackers[num] ) )
	{
		return; 
	}

	spawners = undefined; 
	ai = undefined; 

	thread fallback_wait( num, group, ignoreWhileFallingBack, percent );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
	level waittill( ( "fallbacker_trigger" + num ) ); 
	
	fallback_add_previous_group(num, fallback_nodes);
	
	if( GetDvar( #"fallback" ) == "1" )
	{
		println( "^a fallback trigger hit: ", num ); 
	}
	level.fallback_initiated[num] = true; 

	fallback_ai = undefined; 
	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		if( ( ( IsDefined( ai[i].script_fallback ) ) &&( ai[i].script_fallback == num ) ) || ( ( IsDefined( ai[i].script_fallback_group ) ) &&( IsDefined( group ) ) &&( ai[i].script_fallback_group == group ) ) )
		{
			fallback_ai = add_to_array( fallback_ai, ai[i] ); 
		}
	}
	ai = undefined; 

	if( !IsDefined( fallback_ai ) )
	{
		return; 
	}

	if( !IsDefined( percent ) )
	{
		percent = 0.4;
	}

	first_half = fallback_ai.size * percent;
	first_half = Int( first_half ); 

	level notify( "fallback initiated " + num ); 

	fallback_text( fallback_ai, 0, first_half ); 
	
	first_half_ai = [];
	for( i = 0; i < first_half; i++ )
	{
		fallback_ai[i] thread fallback_ai( num, fallback_nodes, ignoreWhileFallingBack ); 
		first_half_ai[i] = fallback_ai[i];
	}

	// waits until everyone as at their goalnode
	for( i = 0; i < first_half; i++ )
	{
		level waittill( ( "fallback_reached_goal" + num ) ); 
	}

	fallback_text( fallback_ai, first_half, fallback_ai.size ); 

	// SCRIPTER_MOD: JesseS (7/13/2007): added some stuff to check to make sure both halves get to go to nodes
	// turns out that someone else is getting other guys' nodes, so we gotta pick a new one 
	for( i = 0; i < fallback_ai.size; i++ )
	{
		if( IsAlive( fallback_ai[i] ) )
		{
			set_fallback = true;
			for (p = 0; p < first_half_ai.size; p++)
			{
				if ( isalive(first_half_ai[p]))
				{
					if (fallback_ai[i] == first_half_ai[p])
					{
						set_fallback = false;
					}
				}
			}
			
			if (set_fallback)
			{
				fallback_ai[i] thread fallback_ai( num, fallback_nodes, ignoreWhileFallingBack ); 
			}
		}
	}
}

fallback_text( fallbackers, start, end )
{


	if( GetTime() <= level._nextcoverprint )
	{
		return; 
	}

	for( i = start; i < end; i++ )
	{
		if( !IsAlive( fallbackers[i] ) )
		{
			continue; 
		}
			
		level._nextcoverprint = GetTime() + 2500 + RandomInt( 2000 ); 

		return; 
	}
}

// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
fallback_wait( num, group, ignoreWhileFallingBack, percent )
{
	level endon( ( "fallbacker_trigger" + num ) ); 
	if( GetDvar( #"fallback" ) == "1" )
	{
		println( "^a Fallback wait: ", num ); 
	}
	for( i = 0; i < level.spawner_fallbackers[num]; i++ )
	{
		if( GetDvar( #"fallback" ) == "1" )
		{
			println( "^a Waiting for spawners to be hit: ", num, " i: ", i ); 
		}
		level waittill( ( "fallback_firstspawn" + num ) ); 
	}
	if( GetDvar( #"fallback" ) == "1" )
	{
		println( "^a Waiting for AI to die, fall backers for group ", num, " is ", level.current_fallbackers[num] ); 
	}

//	total_fallbackers = 0; 
	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		if( ( ( IsDefined( ai[i].script_fallback ) ) &&( ai[i].script_fallback == num ) ) || ( ( IsDefined( ai[i].script_fallback_group ) ) &&( IsDefined( group ) ) &&( ai[i].script_fallback_group == group ) ) )
		{
			ai[i] thread fallback_ai_think( num, undefined, undefined, ignoreWhileFallingBack );  // SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
		}
	}
	ai = undefined; 

//	if( !total_fallbackers )
//		return; 

	deadfallbackers = 0; 

	while( deadfallbackers < level.max_fallbackers[num] * percent )
	{
		if( GetDvar( #"fallback" ) == "1" )
		{
			println( "^cwaiting for " + deadfallbackers + " to be more than " +( level.max_fallbackers[num] * 0.5 ) ); 
		}
		level waittill( ( "fallbacker_died" + num ) ); 
		deadfallbackers++; 
	}

	println( deadfallbackers , " fallbackers have died, time to retreat" ); 
	level notify( ( "fallbacker_trigger" + num ) ); 
}

// for fallback trigger
// SRS 5/3/2008: updated to allow AIs to ignoreall while falling back
//  Note: multiple triggers will need to have script_ignoreall set identically on all triggers
//  for consistency when AIs decide to ignore while falling back or not.
fallback_think( trigger )
{
	ignoreWhileFallingBack = false;
	if( IsDefined( trigger.script_ignoreall ) && trigger.script_ignoreall )
	{
		ignoreWhileFallingBack = true;
	}
	
	if( ( !IsDefined( level.fallback ) ) ||( !IsDefined( level.fallback[trigger.script_fallback] ) ) )
	{
		// MikeD (5/7/2008): Added the ability to determine the percent of guys that will fallback
		// when this trigger is hit.
		percent = 0.5;
		if( IsDefined( trigger.script_percent ) )
		{
			percent = trigger.script_percent / 100;
		}

		level thread fallback_overmind( trigger.script_fallback, trigger.script_fallback_group, ignoreWhileFallingBack, percent ); 
	}

	trigger waittill( "trigger" );
		
	level notify( ( "fallbacker_trigger" + trigger.script_fallback ) ); 
//	level notify( ( "fallback" + trigger.script_fallback ) ); 

	// Maybe throw in a thing to kill triggers with the same fallback? God my hands are cold.
	kill_trigger( trigger ); 
}

// This is for allowing guys to fallback more than once
fallback_add_previous_group(num, node_array)
{
	// check to see if its the first time or not
	if (!IsDefined (level.current_fallbackers[num - 1]))
	{
		return;
	}
	
	// max fallbackers for next group add stragglers from previous group
	for (i = 0; i < level.current_fallbackers[num - 1]; i++)
	{
			level.max_fallbackers[num]++;
	}
	
	// current fallbackers from previous group should be added to next group as well
	for (i = 0; i < level.current_fallbackers[num - 1]; i++)
	{
			level.current_fallbackers[num]++;
	}

	ai = GetAiArray(); 
	for( i = 0; i < ai.size; i++ )
	{
		if( ( ( IsDefined( ai[i].script_fallback ) ) && ( ai[i].script_fallback == (num - 1) ) ) )
		{
				//ai[i] notify( "stop_going_to_node" );
				ai[i].script_fallback++; 
				
				if (IsDefined (ai[i].fallback_node))
				{
					ai[i].fallback_node.fallback_occupied = false;
					ai[i].fallback_node = undefined;
				}
				
				//ai[i] thread fallback_ai( num, node_array );
		}
	}
}

delete_me()
{
	maps\_spawner::waitframe(); 
	self Delete(); 
}

waitframe()
{
	wait( 0.05 ); 
}

friendly_mg42_death_notify( guy, mg42 )
{
	mg42 endon( "friendly_finished_using_mg42" ); 
	guy waittill( "death" ); 
	mg42 notify( "friendly_finished_using_mg42" ); 
	println( "^a guy using gun died" ); 
}

friendly_mg42_wait_for_use( mg42 )
{
	mg42 endon( "friendly_finished_using_mg42" ); 
	self.useable = true; 
	self setcursorhint("HINT_NOICON");
	self setHintString(&"PLATFORM_USEAIONMG42");
	self waittill( "trigger" ); 
	println( "^a was used by player, stop using turret" ); 
	self.useable = false; 
	self SetHintString( "" ); 
	self StopUSeturret(); 
	self notify( "stopped_use_turret" ); // special hook for decoytown guys -nate
	mg42 notify( "friendly_finished_using_mg42" ); 
}

friendly_mg42_useable( mg42, node )
{
	if( self.useable )
	{
		return false; 
	}
		
	if( ( IsDefined( self.turret_use_time ) ) &&( GetTime() < self.turret_use_time ) )
	{
//		println( "^a Used gun too recently" ); 
		return false; 
	}

	// check to see if any player is too close.
	players = get_players(); 
	for( q = 0; q < players.size; q++ )
	{
		if( Distancesquared( players[q].origin, node.origin ) < 100 * 100 )
		{
//			println( "^a player too close" ); 
			return false; 
		}
	}

	if( IsDefined( self.chainnode ) )
	{
		// check to see if all players are too far
		player_count = 0; 
		for( q = 0; q < players.size; q++ )
		{
			if( Distancesquared( players[q].origin, self.chainnode.origin ) > 1100 * 1100 )
			{
				player_count++; 
			}
		}

		if( player_count == players.size )
		{
	//		println( "^a too far from chain node" ); 
			return false; 
		}
	}

	return true; 
}

friendly_mg42_endtrigger( mg42, guy )
{
	mg42 endon( "friendly_finished_using_mg42" ); 
	self waittill( "trigger" ); 
	println( "^a Told friendly to leave the MG42 now" ); 
//	guy StopUSeturret(); 

	mg42 notify( "friendly_finished_using_mg42" ); 
}

noFour()
{
	self endon( "death" ); 
	self waittill( "goal" ); 
	self.goalradius = self.oldradius; 
	if( self.goalradius < 32 )
	{
		self.goalradius = 400; 
	}
}

friendly_mg42_think( mg42, node )
{
	self endon( "death" ); 
	mg42 endon( "friendly_finished_using_mg42" ); 

	level thread friendly_mg42_death_notify( self, mg42 ); 

	self.oldradius = self.goalradius; 
	self.goalradius = 28; 
	self thread noFour(); 
	self SetGoalNode( node ); 

	self.ignoresuppression = true; 

	self waittill( "goal" ); 
	self.goalradius = self.oldradius; 
	if( self.goalradius < 32 )
	{
		self.goalradius = 400; 
	}

	self.ignoresuppression = false; 

	self.goalradius = self.oldradius; 

	// check to see if any play is too close
	players = get_players(); 
	for( q = 0; q < players.size; q++ )
	{
		if( Distancesquared( players[q].origin, node.origin ) < 32 * 32 )
		{
			mg42 notify( "friendly_finished_using_mg42" ); 
			return; 
		}
	}

	self.friendly_mg42 = mg42; // For making him stop using the mg42 from another script
	self thread friendly_mg42_wait_for_use( mg42 ); 
	self thread friendly_mg42_cleanup( mg42 ); 
	self USeturret( mg42 ); // dude should be near the mg42
//	println( "^a Told AI to use mg42" ); 

	if( IsDefined( mg42.target ) )
	{
		stoptrigger = GetEnt( mg42.target, "targetname" ); 
		if( IsDefined( stoptrigger ) )
		{
			stoptrigger thread friendly_mg42_endtrigger( mg42, self ); 
		}
	}

	while( 1 )
	{
		if( Distance( self.origin, node.origin ) < 32 )
		{
			self USeturret( mg42 ); // dude should be near the mg42
		}
		else
		{
			break; // a friendly is too far from mg42, stop using turret
		}

		if( IsDefined( self.chainnode ) )
		{
			if( Distance( self.origin, self.chainnode.origin ) > 1100 )
			{
				break; // friendly node is too far, stop using turret
			}
		}

		wait( 1 ); 
	}

	mg42 notify( "friendly_finished_using_mg42" ); 
}

friendly_mg42_cleanup( mg42 )
{
	self endon( "death" ); 
	mg42 waittill( "friendly_finished_using_mg42" ); 
	self friendly_mg42_doneUsingTurret(); 
}

friendly_mg42_doneUsingTurret()
{
	self endon( "death" ); 
	turret = self.friendly_mg42; 
	self.friendly_mg42 = undefined; 
	self StopUSeturret(); 
	self notify( "stopped_use_turret" ); // special hook for decoytown guys -nate
	self.useable = false; 
	self.goalradius = self.oldradius; 
	if( !IsDefined( turret ) )
	{
		return; 
	}

	if( !IsDefined( turret.target ) )
	{
		return; 
	}

	node = GetNode( turret.target, "targetname" ); 
	oldradius = self.goalradius; 
	self.goalradius = 8; 
	self SetGoalNode( node ); 
	wait( 2 ); 
	self.goalradius = 384; 
	return; 
	self waittill( "goal" ); 
	if( IsDefined( self.target ) )
	{
		node = GetNode( self.target, "targetname" ); 
		if( IsDefined( node.target ) )
		{
			node = GetNode( node.target, "targetname" ); 
		}
			
		if( IsDefined( node ) )
		{
			self SetGoalNode( node ); 
		}
	}
	self.goalradius = oldradius; 
}


tanksquish()
{
	if ( IsDefined( level.noTankSquish ) )
	{
		assertex( level.noTankSquish, "level.noTankSquish must be true or undefined" );
		return;
	}
	
	if ( IsDefined( level.levelHasVehicles ) && !level.levelHasVehicles )
	{
		return;
	}
	
	while ( 1 )
	{
		self waittill( "damage", amt, who, force, b, mod, d, e );
		
		if ( !isDefined(mod) )
		{
			continue;
		}
		
		if ( mod != "MOD_CRUSH" ) //GLocke: used to be "MOD_CRUSHED"
		{
			continue;
		}

		if ( !IsDefined( self ) )
		{
			// deleted?
			return;
		}
		
		if ( isalive( self ) )
		{
			continue;
		}
			
		if ( !isalive( who ) )
		{
			return;
		}
		
		//Glocke: 8/21/08 removed this and I hope that doesn't cause a problem
		//if ( !IsDefined( who.vehicletype ) )
		//	return;
					
		force = vector_scale( force, 50000 );
		force = ( force[ 0 ], force[ 1 ], abs( force[ 2 ] ) );

		// GLocke: 8/21/08 if level._effect["tanksquish"] is defined then play it, didn't want to add this fx to every level
		if(IsDefined( level._effect ) && IsDefined( level._effect["tanksquish"] ) )
		{
			PlayFX( level._effect["tanksquish"], self.origin + (0, 0, 30));
		}

		self startRagdoll();
		// CODER MOD: Lucas - This could cause destructibles to run out of memory by shooting it out of the level
/*		org = self.origin;
		for ( i = 0; i < 5; i++ )
		{
			if ( IsDefined( self ) )
				org = self.origin;
			PhysicsJolt( org, 250, 250, force );
//			Print3d( org, ".", (1,1,1) );
			wait( 0.05 );
		}*/
		self playsound( "chr_crunch" );
		return;
	}
}

spawnWaypointFriendlies()
{
	self.count = 1;
	spawn = self spawn_ai();
		
	if ( spawn_failed( spawn ) )
	{
		return;
	}
	
	spawn.friendlyWaypoint = true;
}

goalVolumes()
{
	volumes = GetEntArray( "info_volume", "classname" ); 
	level.deathchain_goalVolume = []; 
	level.goalVolumes = []; 
	
	for( i = 0; i < volumes.size; i++ )
	{
		volume = volumes[i]; 
		if( IsDefined( volume.script_deathChain ) )
		{
			level.deathchain_goalVolume[volume.script_deathChain] = volume; 
		}
		if( IsDefined( volume.script_goalvolume ) )
		{
			level.goalVolumes[volume.script_goalVolume] = volume; 
		}
	}
}

aigroup_init( aigroup, spawner )
{
	if( !IsDefined( level._ai_group[aigroup] ) )
	{
		level._ai_group[aigroup] = SpawnStruct(); 
		level._ai_group[aigroup].aigroup = aigroup;
		level._ai_group[aigroup].aicount = 0; 
		level._ai_group[aigroup].spawnercount = 0; 
		level._ai_group[aigroup].killed_count = 0;
		level._ai_group[aigroup].ai = []; 
		level._ai_group[aigroup].spawners = [];
		level._ai_group[aigroup].cleared_count = 0;

		if (!IsDefined(level.flag[aigroup + "_cleared"]))	// may already be set by flag_spawn or somewhere else
		{
			flag_init(aigroup + "_cleared");
		}

		level thread set_ai_group_cleared_flag(level._ai_group[aigroup]);
	}

	if (IsDefined(spawner))
	{
		spawner thread aigroup_spawnerthink( level._ai_group[aigroup] ); 
	}
}

aigroup_spawnerthink( tracker )
{
	self endon( "death" ); 

	self.decremented = false; 
	tracker.spawnercount++; 

	self thread aigroup_spawnerdeath( tracker ); 
	self thread aigroup_spawnerempty( tracker ); 

	while( self.count )
	{
		self waittill( "spawned", soldier );
		
		if( spawn_failed( soldier ) )
		{
			continue; 
		}

		soldier.aigroup = tracker.aigroup;
		soldier thread aigroup_soldierthink( tracker ); 
	}
	waittillframeend; 

	if( self.decremented )
	{
		return; 
	}

	self.decremented = true; 
	tracker.spawnercount--;
}

aigroup_spawnerdeath( tracker )
{
	self waittill( "death" ); 

	if( self.decremented )
	{
		return; 
	}

	tracker.spawnercount--; 
}

aigroup_spawnerempty( tracker )
{
	self endon( "death" ); 

	self waittill( "emptied spawner" ); 

	waittillframeend; 
	if( self.decremented )
	{
		return; 
	}

	self.decremented = true; 
	tracker.spawnercount--; 
}

aigroup_soldierthink( tracker )
{
	tracker.aicount++; 
	tracker.ai[tracker.ai.size] = self; 
	if ( IsDefined( self.script_deathflag_longdeath ) )
	{
		self waittillDeathOrPainDeath();
	}
	else
	{
		self waittill( "death" );
	}

	tracker.aicount--; 
	tracker.killed_count++;
}

set_ai_group_cleared_flag(tracker)
{
	waittillframeend;

	while (true)
	{
		if ((tracker.aicount + tracker.spawnercount) <= tracker.cleared_count)
		{
			flag_set(tracker.aigroup + "_cleared");
			break;
		}

		wait .05;
	}
}

// flood_spawner

flood_trigger_think( trigger )
{
	assertEX( IsDefined( trigger.target ), "flood_spawner at " + trigger.origin + " without target" );
	
	floodSpawners = GetEntArray( trigger.target, "targetname" ); 
	assertex( floodSpawners.size, "flood_spawner at with target " + trigger.target + " without any targets" ); 
	
	for(i = 0; i < floodSpawners.size; i++)
	{
		floodSpawners[i].script_trigger = trigger;
	}
	
/*	choke = true;
	
	if(IsDefined(trigger.script_choke) && !trigger.script_choke)
	{
		choke = true;
	}	

	for(i = 0; i < floodSpawners.size; i++)
	{
		floodSpawners[i].script_choke = choke;
	}

	*/
	array_thread( floodSpawners, ::flood_spawner_init ); 
	
	trigger waittill( "trigger" ); 
	// reget the target array since targets may have been deletes, etc... between initialization and triggering
	floodSpawners = GetEntArray( trigger.target, "targetname" ); 
/*	if(choke && NumRemoteClients())
	{
		spread_array_thread(floodSpawners, ::flood_spawner_think, trigger);
	}
	else*/
	{
		array_thread( floodSpawners, ::flood_spawner_think, trigger ); 
	}
}


flood_spawner_init( spawner )
{
	assertex(self has_spawnflag(level.SPAWNFLAG_ACTOR_SPAWNER), "Spawner at origin" + self.origin + "/" +( self GetOrigin() ) + " is not a spawner!");
}

trigger_requires_player( trigger )
{
	if( !IsDefined( trigger ) )
	{
		return false; 
	}
		
	return IsDefined( trigger.script_requires_player ); 
}

flood_spawner_think( trigger )
{
	self endon( "death" ); 
	self notify( "stop current floodspawner" ); 
	self endon( "stop current floodspawner" ); 
		
	requires_player = trigger_requires_player( trigger ); 

	script_delay(); 
	
	while( self.count > 0 )
	{
		// see if any player is touching the trigger.
// AlexL (6/26/2007): This line asserts when trigger is undefined. New version accomodated undefined trigger.
//		while( requires_player && !any_player_IsTouching( trigger ) )
		if( requires_player ) // 0 if trigger is undefined
		{
			while( !any_player_IsTouching( trigger ) )
			{
				wait( 0.5 ); 
			}
		}

		while(!(self ok_to_trigger_spawn()))
		{
			wait_network_frame();
		}

		soldier = self spawn_ai();

		if( spawn_failed( soldier ) )
		{
			wait( 2 ); 
			continue; 
		}

		level._numTriggerSpawned ++;

		soldier thread reincrement_count_if_deleted( self ); 

		soldier waittill( "death", attacker );
		if ( !player_saw_kill( soldier, attacker ) )
		{
			self.count++;
		}

		// soldier was deleted, not killed
		if( !IsDefined( soldier ) )
		{
			continue; 
		}

		if( !script_wait( true ) )
		{
			players = get_players();

			if (players.size == 1)
			{
				wait( RandomFloatrange( 5, 9 ) ); 
			}
			else if (players.size == 2)
			{
				wait( RandomFloatrange( 3, 6 ) ); 
			}	
			else if (players.size == 3)
			{
				wait( RandomFloatrange( 1, 4 ) ); 
			}		
			else if (players.size == 4)
			{
				wait( RandomFloatrange( 0.5, 1.5 ) ); 
			}	
		}
	}
}

player_saw_kill( guy, attacker )
{
	if ( IsDefined( self.script_force_count ) )
	{
		if ( self.script_force_count )
		{
			return true;
		}
	}

	if ( !IsDefined( guy ) )
	{
		return false;
	}
	
	if ( IsAlive( attacker ) )
	{
		if ( IsPlayer( attacker ) )
		{
			return true;
		}

		players = get_players();

		for( q = 0; q < players.size; q++ )
		{
			if ( DistanceSquared( attacker.origin, players[q].origin ) < 200 * 200 )
			{
				// player was near the guy that killed the ai?
				return true;
			}
		}
	}
	else
	{
		if ( IsDefined( attacker ) )
		{
			if ( attacker.classname	== "worldspawn" )
			{
				return false;
			}
				
			player = get_closest_player( attacker.origin );
			if ( IsDefined( player ) && distance( attacker.origin, player.origin ) < 200 )
			{
				// player was near the guy that killed the ai?
				return true;
			}
		}
	}
	
	// get the closest player
	closest_player = get_closest_player( guy.origin ); 
	if (  IsDefined( closest_player ) && distance( guy.origin, closest_player.origin ) < 200 )
	{
		// player was near the guy that got killed?
		return true;
	}

	// did the player see the guy die?
	return bulletTracePassed( closest_player geteye(), guy geteye(), false, undefined );
}

show_bad_path()
{
	 /#
	if ( getdebugdvar( "debug_badpath" ) == "" )
		setdvar( "debug_badpath", "" );

	self endon( "death" );
	last_bad_path_time = -5000;
	bad_path_count = 0;
	for ( ;; )
	{
		self waittill( "bad_path", badPathPos );
		
		if ( !IsDefined(level.debug_badpath) || !level.debug_badpath )
		{
			continue;
		}

		if ( gettime() - last_bad_path_time > 5000 )
		{
			bad_path_count = 0;
		}
		else
		{
			bad_path_count++;
		}

		last_bad_path_time = gettime();

		if ( bad_path_count < 10 )
		{
			continue;
		}
		
		for ( p = 0; p < 10 * 20; p++ )
		{
			line( self.origin, badPathPos, ( 1, 0.4, 0.1 ), 0, 10 * 20 );
			wait( 0.05 );
		}
	}		
	#/ 
}


objective_event_init( trigger )
{
	flag = trigger get_trigger_flag(); 
	assertex( IsDefined( flag ), "Objective event at origin " + trigger.origin + " does not have a script_flag. " ); 
	flag_init( flag ); 
		
	assertex( IsDefined( level.deathSpawner[trigger.script_deathChain] ), "The objective event trigger for deathchain " + trigger.script_deathchain + " is not associated with any AI." ); 
	/#
	if( !IsDefined( level.deathSpawner[trigger.script_deathChain] ) )
	{
		return; 
	}
	#/
	while( level.deathSpawner[trigger.script_deathChain] > 0 )
	{
		level waittill( "spawner_expired" + trigger.script_deathChain ); 
	}
		
	flag_set( flag ); 
}

#using_animtree( "generic_human" );
spawner_dronespawn( spawner )
{
	assert( IsDefined( level.dronestruct[ spawner.classname ] ) );
	struct = level.dronestruct[ spawner.classname ];
	drone = spawn( "script_model", spawner.origin );
	drone.angles = spawner.angles;
	drone setmodel( struct.model );
// 	drone hide();
	drone UseAnimTree( #animtree );
	drone makefakeai();
	attachedmodels = struct.attachedmodels;
	attachedtags = struct.attachedtags;
	
	
	for ( i = 0;i < attachedmodels.size;i++ )
	{
		drone attach( attachedmodels[ i ], attachedtags[ i ], true );
	}
	if ( IsDefined( struct.weapon ) )
	{
		drone.weapon = struct.weapon;
		self call_overloaded_func( "animscripts\init", "initWeapon", drone.weapon );
		drone useweaponhidetags( drone.weapon );
	}
	if ( IsDefined( spawner.script_startingposition ) )
	{
		drone.script_startingposition = spawner.script_startingposition;
	}
	if ( IsDefined( spawner.script_noteworthy ) )
	{
		drone.script_noteworthy = spawner.script_noteworthy;
	}
	if ( IsDefined( spawner.script_deleteai ) )
	{
		drone.script_deleteai = spawner.script_deleteai;
	}
	if ( IsDefined( spawner.script_linkto ) )
	{
		drone.script_linkto = spawner.script_linkto;
	}
	if ( IsDefined( spawner.script_moveoverride ) )
	{
		drone.script_moveoverride = spawner.script_moveoverride;
	}
	// for later use to makerealai
	if ( issubstr( spawner.classname, "ally" ) )
	{
		drone.team = "allies";
	}
	else if ( issubstr( spawner.classname, "enemy" ) )
	{
		drone.team = "axis";
	}
	else
	{
		drone.team = "neutral";
	}
	
	if ( IsDefined( spawner.target ) )
	{
		drone.target = spawner.target;
	}
	
	drone.spawner = spawner;
	assert( IsDefined( drone ) );
	if ( IsDefined( spawner.script_noteworthy ) && spawner.script_noteworthy == "drone_delete_on_unload" )
	{
		drone.drone_delete_on_unload = true; 
	}
	else 
	{
		drone.drone_delete_on_unload = false;
	}
	
	spawner notify( "drone_spawned", drone );
	return drone;
}

spawner_make_real_ai( drone )
{
	if(!IsDefined(drone.spawner))
	{
		println("----failed dronespawned guy info----");
		println("drone.classname: "+drone.classname);
		println("drone.origin   : "+drone.origin); 
		assertmsg("makerealai called on drone does with no .spawner");
	}
	orgorg = drone.spawner.origin; 
	organg = drone.spawner.angles; 
	drone.spawner.origin = drone.origin; 
	drone.spawner.angles = drone.angles; 
	guy = drone.spawner stalingradspawn();
	failed = spawn_failed(guy);
	if(failed)
	{
		println("----failed dronespawned guy info----");
		println("failed guys spawn position : "+drone.origin);
		println("failed guys spawner export key: "+drone.spawner.export);
		println("getaiarray size is: "+getaiarray().size);
		println("------------------------------------");
		assertMSG("failed to make real ai out of drone (see console for more info)");
	}
	drone.spawner.origin = orgorg; 
	drone.spawner.angles = organg; 
	drone Delete(); 
	return guy; 
} 