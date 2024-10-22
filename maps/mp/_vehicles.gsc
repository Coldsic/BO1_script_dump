#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#using_animtree ( "mp_vehicles" );
init()
{
	PreCacheVehicle( get_default_vehicle_name() );
	setdvar( "scr_veh_cleanupdebugprint", "0" );
	
	
	setdvar( "scr_veh_driversarehidden", "1" );
	setdvar( "scr_veh_driversareinvulnerable", "1" );
	
	
	
	setdvar( "scr_veh_alive_cleanuptimemin", "119" );
	setdvar( "scr_veh_alive_cleanuptimemax", "120" );
	setdvar( "scr_veh_dead_cleanuptimemin", "20" );
	setdvar( "scr_veh_dead_cleanuptimemax", "30" );
	
	
	
	
	setdvar( "scr_veh_cleanuptime_dmgfactor_min", "0.33" );
	setdvar( "scr_veh_cleanuptime_dmgfactor_max", "1.0" );
	setdvar( "scr_veh_cleanuptime_dmgfactor_deadtread", "0.25" ); 
	setdvar( "scr_veh_cleanuptime_dmgfraction_curve_begin", "0.0" ); 
	setdvar( "scr_veh_cleanuptime_dmgfraction_curve_end", "1.0" ); 
	
	setdvar( "scr_veh_cleanupabandoned", "1" ); 
	setdvar( "scr_veh_cleanupdrifted", "1" ); 
	setdvar( "scr_veh_cleanupmaxspeedmph", "1" ); 
	setdvar( "scr_veh_cleanupmindistancefeet", "75" ); 
	setdvar( "scr_veh_waittillstoppedandmindist_maxtime", "10" );
	setdvar( "scr_veh_waittillstoppedandmindist_maxtimeenabledistfeet", "5" );
	
	
	
	
	setdvar( "scr_veh_respawnafterhuskcleanup", "1" ); 
	setdvar( "scr_veh_respawntimemin", "50" );
	setdvar( "scr_veh_respawntimemax", "90" );
	setdvar( "scr_veh_respawnwait_maxiterations", "30" );
	setdvar( "scr_veh_respawnwait_iterationwaitseconds", "1" );
	
	setdvar( "scr_veh_disablerespawn", "0" );
	setdvar( "scr_veh_disableoverturndamage", "0" );
	
	
	setdvar( "scr_veh_explosion_spawnfx", "1" ); 
	setdvar( "scr_veh_explosion_doradiusdamage", "1" ); 
	setdvar( "scr_veh_explosion_radius", "256" );
	setdvar( "scr_veh_explosion_mindamage", "20" );
	setdvar( "scr_veh_explosion_maxdamage", "200" );
	
	setdvar( "scr_veh_ondeath_createhusk", "1" ); 
	setdvar( "scr_veh_ondeath_usevehicleashusk", "1" ); 
	setdvar( "scr_veh_explosion_husk_forcepointvariance", "30" ); 
	setdvar( "scr_veh_explosion_husk_horzvelocityvariance", "25" );
	setdvar( "scr_veh_explosion_husk_vertvelocitymin", "100" );
	setdvar( "scr_veh_explosion_husk_vertvelocitymax", "200" );
	
	
	setdvar( "scr_veh_explode_on_cleanup", "1" ); 
	setdvar( "scr_veh_disappear_maxwaittime", "60" ); 
	setdvar( "scr_veh_disappear_maxpreventdistancefeet", "30" ); 
	setdvar( "scr_veh_disappear_maxpreventvisibilityfeet", "150" ); 
	
	setdvar( "scr_veh_health_tank", "1350" ); 
	
	level.vehicle_drivers_are_invulnerable = GetDvarInt( #"scr_veh_driversareinvulnerable" );
	level.onEjectOccupants = ::vehicle_eject_all_occupants;
	
	level.vehicleHealths[ "panzer4_mp" ] = 2600;
	level.vehicleHealths[ "t34_mp" ] = 2600;
	
	setdvar( "scr_veh_health_jeep", "700" ); 
	if ( init_vehicle_entities() )
	{
		level.vehicle_explosion_effect= loadFX("explosions/fx_large_vehicle_explosion"); 
		initialize_vehicle_damage_effects_for_level();
	
	
	
		{
			level.veh_husk_models = [];
			
			if ( IsDefined( level.use_new_veh_husks ) )
			{
				level.veh_husk_models[ "t34_mp" ] = "veh_t34_destroyed_mp";
				
			}
			
			if ( IsDefined( level.onAddVehicleHusks) )
			{
				[[level.onAddVehicleHusks]]();
			}
			
			keys = GetArrayKeys( level.veh_husk_models );
			
			for ( i = 0; i < keys.size; i++ )
			{
				precacheModel( level.veh_husk_models[ keys[ i ] ] );
			}
		}
		
		
		precacheRumble( "tank_damage_light_mp" );
		precacheRumble( "tank_damage_heavy_mp" );
		level._effect["tanksquish"] = loadfx("maps/see2/fx_body_blood_splat");
	}
	
	
	chopper_player_get_on_gun = %int_huey_gunner_on;
	chopper_door_open = %v_huey_door_open;
	chopper_door_open_state = %v_huey_door_open_state;
	chopper_door_closed_state = %v_huey_door_close_state;
	return;
}
initialize_vehicle_damage_effects_for_level()
{
	
	
	
	
	
	k_mild_damage_index= 0;
	k_moderate_damage_index= 1;
	k_severe_damage_index= 2;
	k_total_damage_index= 3;
	
	
	k_mild_damage_health_percentage= 0.85;
	k_moderate_damage_health_percentage= 0.55;
	k_severe_damage_health_percentage= 0.35;
	k_total_damage_health_percentage= 0;
	level.k_mild_damage_health_percentage = k_mild_damage_health_percentage;
	level.k_moderate_damage_health_percentage = k_moderate_damage_health_percentage;
	level.k_severe_damage_health_percentage = k_severe_damage_health_percentage;
	level.k_total_damage_health_percentage = k_total_damage_health_percentage;
	
	level.vehicles_damage_states= [];
	level.vehicles_husk_effects = [];
	level.vehicles_damage_treadfx = [];
	
	
	vehicle_name= get_default_vehicle_name();
	{
		level.vehicles_damage_states[vehicle_name]= [];
		level.vehicles_damage_treadfx[vehicle_name] = [];
		
		{
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].health_percentage= k_mild_damage_health_percentage;
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array= [];
			
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].damage_effect= loadFX("vehicle/vfire/fx_tank_sherman_smldr"); 
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].sound_effect= undefined;
			level.vehicles_damage_states[vehicle_name][k_mild_damage_index].effect_array[0].vehicle_tag= "tag_origin";
		}
		
		{
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].health_percentage= k_moderate_damage_health_percentage;
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array= [];
			
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].damage_effect= loadFX("vehicle/vfire/fx_vfire_med_12"); 
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].sound_effect= undefined;
			level.vehicles_damage_states[vehicle_name][k_moderate_damage_index].effect_array[0].vehicle_tag= "tag_origin";
		}
		
		{
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].health_percentage= k_severe_damage_health_percentage;
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array= [];
			
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].damage_effect= loadFX("vehicle/vfire/fx_vfire_sherman"); 
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].sound_effect= undefined;
			level.vehicles_damage_states[vehicle_name][k_severe_damage_index].effect_array[0].vehicle_tag= "tag_origin";
		}
		
		{
			level.vehicles_damage_states[vehicle_name][k_total_damage_index]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].health_percentage= k_total_damage_health_percentage;
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array= [];
			
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0]= SpawnStruct();
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].damage_effect= loadFX("explosions/fx_large_vehicle_explosion");
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].sound_effect= "vehicle_explo"; 
			level.vehicles_damage_states[vehicle_name][k_total_damage_index].effect_array[0].vehicle_tag= "tag_origin";
		}
		
		
		{
			default_husk_effects = SpawnStruct();
			default_husk_effects.damage_effect = undefined;
			default_husk_effects.sound_effect = undefined;
			default_husk_effects.vehicle_tag = "tag_origin";
			
			level.vehicles_husk_effects[ vehicle_name ] = default_husk_effects;
		}
	}
	
	return;
}
get_vehicle_name(
	vehicle)
{
	name= "";
	
	if (IsDefined(vehicle))
	{
		if (IsDefined(vehicle.vehicletype))
		{
			name= vehicle.vehicletype;
		}
	}
	
	return name;
}
get_default_vehicle_name()
{
	return "defaultvehicle_mp";
}
get_vehicle_name_key_for_damage_states(
	vehicle)
{
	vehicle_name= get_vehicle_name(vehicle);
	
	if (!IsDefined(level.vehicles_damage_states[vehicle_name]))
	{
		vehicle_name= get_default_vehicle_name();
	}
	
	return vehicle_name;
}
get_vehicle_damage_state_index_from_health_percentage(
	vehicle)
{
	damage_state_index= -1;
	vehicle_name= get_vehicle_name_key_for_damage_states();
	
	for (test_index= 0; test_index<level.vehicles_damage_states[vehicle_name].size; test_index++)
	{
		if (vehicle.current_health_percentage<=level.vehicles_damage_states[vehicle_name][test_index].health_percentage)
		{
			damage_state_index= test_index;
		}
		else
		{
			break;
		}
	}
	
	return damage_state_index;
}
update_damage_effects(
	vehicle,
	attacker)
{
	if (vehicle.initial_state.health>0)
	{
		previous_damage_state_index= get_vehicle_damage_state_index_from_health_percentage(vehicle);
		vehicle.current_health_percentage= vehicle.health/vehicle.initial_state.health;
		current_damage_state_index= get_vehicle_damage_state_index_from_health_percentage(vehicle);
		
		if (previous_damage_state_index!=current_damage_state_index)
		{
			vehicle notify ( "damage_state_changed" );
			if (previous_damage_state_index<0)
			{
				start_damage_state_index= 0;
			}
			else
			{
				start_damage_state_index= previous_damage_state_index+1;
			}
			play_damage_state_effects(vehicle, start_damage_state_index, current_damage_state_index);
			if ( vehicle.health <= 0 )
			{
				vehicle kill_vehicle(attacker);
			}
		}
	}
	
	return;
}
play_damage_state_effects(
	vehicle,
	start_damage_state_index,
	end_damage_state_index)
{
	vehicle_name= get_vehicle_name_key_for_damage_states( vehicle );
	
	
	for (damage_state_index= start_damage_state_index; damage_state_index<=end_damage_state_index; damage_state_index++)
	{
		for (effect_index= 0;
			effect_index<level.vehicles_damage_states[vehicle_name][damage_state_index].effect_array.size;
			effect_index++)
		{
			effects = level.vehicles_damage_states[ vehicle_name ][ damage_state_index ].effect_array[ effect_index ];
			vehicle thread play_vehicle_effects( effects );
		}
	}
	
	return;
}
play_vehicle_effects( effects, isDamagedTread )
{
	self endon( "delete" );
	self endon( "removed" );
	
	if ( !isdefined( isDamagedTread ) || isDamagedTread == 0 )
	{
		self endon( "damage_state_changed" );
	}
	
	if ( IsDefined( effects.sound_effect ) )
	{
		self PlaySound( effects.sound_effect );
	}
	waitTime = 0;
	if ( isdefined ( effects.damage_effect_loop_time ) )
	{
		waitTime = effects.damage_effect_loop_time;
	}
	while ( waitTime > 0 )
	{
		
		if ( IsDefined( effects.damage_effect ) )
		{
			PlayFxOnTag( effects.damage_effect, self, effects.vehicle_tag );
		}
		wait( waitTime );
	}
}
init_vehicle_entities()
{
	vehicles = getentarray( "script_vehicle", "classname" );
	array_thread( vehicles, ::init_original_vehicle );
	
	if ( isdefined( vehicles ) )
	{
		return vehicles.size;
	}
	
	return 0;
}
precache_vehicles()
{
	
}
register_vehicle()
{
	
	if ( !IsDefined( level.vehicles_list ) )
	{
		level.vehicles_list = [];
	}
	
	level.vehicles_list[ level.vehicles_list.size ] = self;
}
manage_vehicles()
{
	if ( !IsDefined( level.vehicles_list ) )
	{
		return true;
	}
	else
	{
		MAX_VEHICLES = GetMaxVehicles();
		
		{
			
			
			newArray = [];
			
			for ( i = 0; i < level.vehicles_list.size; i++ )
			{
				if ( IsDefined( level.vehicles_list[ i ] ) )
				{
					newArray[ newArray.size ] = level.vehicles_list[ i ];
				}
			}
			
			level.vehicles_list = newArray;
		}
		
		
		
		vehiclesToDelete = ( level.vehicles_list.size + 1 ) - MAX_VEHICLES;
		
		
		if ( vehiclesToDelete > 0 )
		{
			newArray = [];
			
			for ( i = 0; i < level.vehicles_list.size; i++ )
			{
				vehicle = level.vehicles_list[ i ];
				
				if ( vehiclesToDelete > 0 )
				{
					
					if ( IsDefined( vehicle.is_husk ) && !IsDefined( vehicle.permanentlyRemoved ) )
					{
						deleted = vehicle husk_do_cleanup();
						
						if ( deleted )
						{
							vehiclesToDelete--;
							continue;
						}
					}
				}
				
				newArray[ newArray.size ] = vehicle;
			}
			
			level.vehicles_list = newArray;
		}
		
		return level.vehicles_list.size < MAX_VEHICLES;
	}
}
 
init_vehicle()
{
	self register_vehicle();
	
	
	
	if ( isdefined( level.vehicleHealths ) && isdefined( level.vehicleHealths[ self.vehicletype ] ) )
	{
		self.maxhealth = level.vehicleHealths[ self.vehicletype ];
	}
	else
	{
		self.maxhealth = GetDvarInt( #"scr_veh_health_tank");
	}
	self.health = self.maxhealth;
		
	self vehicle_record_initial_values();
	
	self init_vehicle_threads();
	
	self maps\mp\gametypes\_spawning::create_vehicle_influencers();
	
	self thread monitorTankDeath();
}
initialize_vehicle_damage_state_data()
{
	if (self.initial_state.health>0)
	{
		self.current_health_percentage= self.health/self.initial_state.health;
		self.previous_health_percentage= self.health/self.initial_state.health;
	}
	else
	{
		self.current_health_percentage= 1;
		self.previous_health_percentage= 1;
	}
	
	return;
}
init_original_vehicle()
{
	
	
	
	self.original_vehicle = true;
	
	self init_vehicle();
}
monitorTankDeath()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill ("death", attacker, damageFromUnderneath, weaponName ); 
		
		if ( isdefined ( attacker )  && isdefined ( weaponName ) )
		{
			if ( attacker.health < 100 && isDefined ( attacker.lastTankThatAttacked ) ) 
			{
				if (self == attacker.lastTankThatAttacked ) 
					attacker maps\mp\gametypes\_missions::doMissionCallback( "youtalkintome", attacker ); 
			}
			if ( isdefined ( damageFromUnderneath ) && isdefined( attacker.pers ) && vehicle_get_occupant_team() != attacker.team || game["dialog"]["gametype"] == "ffa_start" )
			{
				if ( damageFromUnderneath && weaponName == "satchel_charge_mp")
					attacker maps\mp\gametypes\_missions::doMissionCallback( "trapper", attacker ); 
			}
		}
	}
}
vehicle_wait_player_enter_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	while( 1 )
	{
		self waittill( "enter_vehicle", player );
		player thread player_wait_exit_vehicle_t();
		player player_update_vehicle_hud( true, self );
	}
}
player_wait_exit_vehicle_t()
{
	
	
	self endon( "disconnect" );
	
	self waittill( "exit_vehicle", vehicle );
	self player_update_vehicle_hud( false, vehicle );
}
vehicle_wait_damage_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	while( 1 )
	{
		self waittill ( "damage" );
		occupants = self GetVehOccupants();
		if( isDefined( occupants ) )
		{
			for( i = 0; i < occupants.size; i++ )
			{
				occupants[i] player_update_vehicle_hud( true, self );
			}
		}
	}
}
player_update_vehicle_hud( show, vehicle )
{
	if( show )
	{
		if ( !isDefined( self.vehicleHud ) )
		{
			self.vehicleHud = createBar( (1, 1, 1), 64, 16 );
			self.vehicleHud setPoint( "CENTER", "BOTTOM", 0, -40 );
			self.vehicleHud.alpha = 0.75;
		}
		self.vehicleHud updateBar( vehicle.health / vehicle.initial_state.health );
	}
	else
	{
		if ( isDefined( self.vehicleHud ) )
		{
			self.vehicleHud destroyElem();
		}
	}
	if ( GetDvar( #"scr_vehicle_healthnumbers" )!= "" )
	{
		if ( GetDvarInt( #"scr_vehicle_healthnumbers" )!= 0 )
		{
			if( show )
			{
				if ( !isDefined( self.vehicleHudHealthNumbers ) )
				{
					self.vehicleHudHealthNumbers = createFontString( "default", 2.0 );
					self.vehicleHudHealthNumbers setParent( self.vehicleHud );
					self.vehicleHudHealthNumbers setPoint( "LEFT", "RIGHT", 8, 0 );
					self.vehicleHudHealthNumbers.alpha = 0.75;
					self.vehicleHudHealthNumbers.hideWhenInMenu = false;
					self.vehicleHudHealthNumbers.archived = false;
				}
				self.vehicleHudHealthNumbers setValue( vehicle.health );
			}
			else
			{
				if ( isDefined( self.vehicleHudHealthNumbers ) )
				{
					self.vehicleHudHealthNumbers destroyElem();
				}
			}
		}
	}
}
init_vehicle_threads()
{
	self thread vehicle_fireweapon_t();
	self thread vehicle_abandoned_by_drift_t();
	self thread vehicle_abandoned_by_occupants_t();
	self thread vehicle_damage_t();
	self thread vehicle_ghost_entering_occupants_t();
	
	self thread vehicle_recycle_spawner_t();
	self thread vehicle_disconnect_paths();
	
	
	if( isdefined( level.enableVehicleHealthbar ) && level.enableVehicleHealthbar )
	{
		self thread vehicle_wait_player_enter_t();
		self thread vehicle_wait_damage_t();
	}
	
	self thread vehicle_wait_tread_damage();
	self thread vehicle_overturn_eject_occupants();
	
	if (GetDvarInt( #"scr_veh_disableoverturndamage") == 0)
	{
		self thread vehicle_overturn_suicide();
	}
	
	
}
  
build_template( type, model, typeoverride )
{
	if( isdefined( typeoverride ) )
		type = typeoverride; 
	
	if( !isdefined( level.vehicle_death_fx ) )
		level.vehicle_death_fx = []; 
	if( 	!isdefined( level.vehicle_death_fx[ type ] ) )
		level.vehicle_death_fx[ type ] = []; 
	
	level.vehicle_compassicon[ type ] = false; 
	level.vehicle_team[ type ] = "axis"; 
	level.vehicle_life[ type ] = 999; 
	level.vehicle_hasMainTurret[ model ] = false; 
	level.vehicle_mainTurrets[ model ] = [];
	level.vtmodel = model; 
	level.vttype = type; 
}
  
build_rumble( rumble, scale, duration, radius, basetime, randomaditionaltime )
{
	if( !isdefined( level.vehicle_rumble ) )
		level.vehicle_rumble = []; 
	struct = build_quake( scale, duration, radius, basetime, randomaditionaltime );
	assert( isdefined( rumble ) );
	precacherumble( rumble );
	struct.rumble = rumble; 
	level.vehicle_rumble[ level.vttype ] = struct; 
	precacherumble( "tank_damaged_rumble_mp" );
}
build_quake( scale, duration, radius, basetime, randomaditionaltime )
{
	struct = spawnstruct();
	struct.scale = scale; 
	struct.duration = duration; 
	struct.radius = radius; 
	if( isdefined( basetime ) )
		struct.basetime = basetime; 
	if( isdefined( randomaditionaltime ) )
		struct.randomaditionaltime = randomaditionaltime; 
	return struct; 
}
  
build_exhaust( effect )
{
	level.vehicle_exhaust[ level.vtmodel ] = loadfx( effect );
}
cleanup_debug_print_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	
}
cleanup_debug_print_clearmsg_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	
}
cleanup_debug_print( message )
{
	
}
vehicle_abandoned_by_drift_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	self wait_then_cleanup_vehicle( "Drift Test", "scr_veh_cleanupdrifted" );
}
vehicle_abandoned_by_occupants_timeout_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	self wait_then_cleanup_vehicle( "Abandon Test", "scr_veh_cleanupabandoned" );
}
wait_then_cleanup_vehicle( test_name, cleanup_dvar_name )
{
	self endon( "enter_vehicle" );
	
	self wait_until_severely_damaged();
	self do_alive_cleanup_wait( test_name );
	self wait_for_vehicle_to_stop_outside_min_radius(); 
	self cleanup( test_name, cleanup_dvar_name, ::vehicle_recycle );
}
wait_until_severely_damaged()
{
	while ( 1 )
	{
		health_percentage = self.health / self.initial_state.health;
		
		if ( IsDefined( level.k_severe_damage_health_percentage ) ) 
		{
			self cleanup_debug_print( "Damage Test: Still healthy - (" + health_percentage + " >= " + level.k_severe_damage_health_percentage + ") and working treads");
		}
		else
		{
			self cleanup_debug_print( "Damage Test: Still healthy and working treads");
		}
		
		
		self waittill( "damage" );
		
		health_percentage = self.health / self.initial_state.health;
		
		if ( ( health_percentage < level.k_severe_damage_health_percentage )
			|| ( ( self GetTreadHealth( 0 ) ) <= 0.0 )
			|| ( ( self GetTreadHealth( 1 ) ) <= 0.0 ) )
			break;
	}
}
get_random_cleanup_wait_time( state )
{
	varnamePrefix = "scr_veh_" + state + "_cleanuptime";
	minTime = getdvarfloat( varnamePrefix + "min" );
	maxTime = getdvarfloat( varnamePrefix + "max" );	
	
	if ( maxTime > minTime )
	{
		return RandomFloatRange( minTime, maxTime );
	}
	else
	{
		return maxTime;
	}
}
do_alive_cleanup_wait( test_name )
{
	initialRandomWaitSeconds = get_random_cleanup_wait_time( "alive" );
		
	secondsWaited = 0.0;
	seconds_per_iteration = 1.0;
	
	while ( true )
	{	
		curve_begin = GetDvarFloat( #"scr_veh_cleanuptime_dmgfraction_curve_begin" );
		curve_end = GetDvarFloat( #"scr_veh_cleanuptime_dmgfraction_curve_end" );
		
		factor_min = GetDvarFloat( #"scr_veh_cleanuptime_dmgfactor_min" );
		factor_max = GetDvarFloat( #"scr_veh_cleanuptime_dmgfactor_max" );
		
		treadDeadDamageFactor = GetDvarFloat( #"scr_veh_cleanuptime_dmgfactor_deadtread" );
		
	
		damageFraction = 0.0;
	
		if ( self is_vehicle() )
		{
			damageFraction = ( self.initial_state.health - self.health ) / self.initial_state.health;	
		}
		else 
		{
			damageFraction = 1.0;
		}
	
		damageFactor = 0.0;
	
		if ( damageFraction <= curve_begin )
		{
			damageFactor = factor_max;
		}
		else if ( damageFraction >= curve_end )
		{
			damageFactor = factor_min;
		}
		else
		{
			dydx = ( factor_min - factor_max ) / ( curve_end - curve_begin );
			damageFactor = factor_max + ( damageFraction - curve_begin ) * dydx;
		}
		
		
		{
			
			
			
			for ( i = 0; i < 2; i++ )
			{
				if ( ( self GetTreadHealth( i ) ) <= 0 )
				{
					damageFactor -= treadDeadDamageFactor;
				}
			}
		}
		
	
		totalSecsToWait = initialRandomWaitSeconds * damageFactor;
		
		if ( secondsWaited >= totalSecsToWait )
		{
			break;
		}
		
		self cleanup_debug_print( test_name + ": Waiting " + ( totalSecsToWait - secondsWaited ) + "s" );
		
		wait seconds_per_iteration;
		secondsWaited = secondsWaited + seconds_per_iteration;
	}
}
do_dead_cleanup_wait( test_name )
{
	total_secs_to_wait = get_random_cleanup_wait_time( "dead" );
		
	seconds_waited = 0.0;
	seconds_per_iteration = 1.0;
	
	while ( seconds_waited < total_secs_to_wait )
	{	
		self cleanup_debug_print( test_name + ": Waiting " + ( total_secs_to_wait - seconds_waited ) + "s" );
		wait seconds_per_iteration;
		seconds_waited = seconds_waited + seconds_per_iteration;
	}
}
cleanup( test_name, cleanup_dvar_name, cleanup_func )
{
	keep_waiting = true;
	while ( keep_waiting )
	{
		cleanupEnabled = !IsDefined( cleanup_dvar_name )
			|| getdvarint( cleanup_dvar_name ) != 0;
		
		if ( cleanupEnabled != 0 )
		{
			self [[cleanup_func]]();
			break;
		}
		
		keep_waiting = false;
		
		
	}
}
vehicle_wait_tread_damage()
{
	self endon( "death" );
	self endon( "delete" );
	vehicle_name= get_vehicle_name(self);
	
	while ( 1 )
	{
		self waittill ( "broken", brokenNotify );
		if ( brokenNotify == "left_tread_destroyed" )
		{
			if ( isdefined( level.vehicles_damage_treadfx[vehicle_name] ) && isdefined( level.vehicles_damage_treadfx[vehicle_name][0] ) )
			{
				self thread play_vehicle_effects( level.vehicles_damage_treadfx[vehicle_name][0], true );
			}
		}
		else if ( brokenNotify == "right_tread_destroyed" )
		{
			if ( isdefined( level.vehicles_damage_treadfx[vehicle_name] ) && isdefined( level.vehicles_damage_treadfx[vehicle_name][1] ) )
			{
				self thread play_vehicle_effects( level.vehicles_damage_treadfx[vehicle_name][1], true );
			}
		}
	}
}
wait_for_vehicle_to_stop_outside_min_radius()
{
	maxWaitTime = GetDvarFloat( #"scr_veh_waittillstoppedandmindist_maxtime" );
	iterationWaitSeconds = 1.0;
	
	maxWaitTimeEnableDistInches = 12 * GetDvarFloat( #"scr_veh_waittillstoppedandmindist_maxtimeenabledistfeet" );
	
	initialOrigin = self.initial_state.origin;
	
	for ( totalSecondsWaited = 0.0; totalSecondsWaited < maxWaitTime; totalSecondsWaited += iterationWaitSeconds )
	{
		
		
		speedMPH = self GetSpeedMPH();
		cutoffMPH = GetDvarFloat( #"scr_veh_cleanupmaxspeedmph" );
		
		if ( speedMPH > cutoffMPH )
		{
			cleanup_debug_print( "(" + ( maxWaitTime - totalSecondsWaited ) + "s) Speed: " + speedMPH + ">" + cutoffMPH );
		}
		else
		{
			break;
			
			
		}
		
		wait iterationWaitSeconds;
	}
}
vehicle_abandoned_by_occupants_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	while ( 1 )
	{
		self waittill( "exit_vehicle" );
		
		occupants = self GetVehOccupants();
		
		if ( occupants.size == 0 )
		{
			self play_start_stop_sound( "tank_shutdown_sfx" );
			self thread vehicle_abandoned_by_occupants_timeout_t();
		}
	}
}
play_start_stop_sound( sound_alias, modulation )
{
	if ( IsDefined( self.start_stop_sfxid ) )
	{
		
	}
	
	self.start_stop_sfxid = self playSound( sound_alias );
}
vehicle_ghost_entering_occupants_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	
	{
		while ( 1 )
		{
			self waittill( "enter_vehicle", player, seat );
			
			isDriver = seat == 0;
			
			if ( GetDvarInt( #"scr_veh_driversarehidden" ) != 0
				&& isDriver )
			{
				player Ghost();
			}
			
			
			{
				occupants = self GetVehOccupants();
				
				if ( occupants.size == 1 )
				{
					self play_start_stop_sound( "tank_startup_sfx" );
				}
			}
			
			
			player thread player_change_seat_handler_t( self );
			player thread player_leave_vehicle_cleanup_t( self );
		}
	}
}
player_is_occupant_invulnerable( sMeansOfDeath )
{
	if ( self IsRemoteControlling() )
		return false;
		
	if (!isdefined(level.vehicle_drivers_are_invulnerable))
		level.vehicle_drivers_are_invulnerable = false;
		
	invulnerable = ( level.vehicle_drivers_are_invulnerable	&& ( self player_is_driver() ) );
	
	return invulnerable;
}
player_is_driver()
{
	if ( !isalive(self) )
		return false;
		
	vehicle = self GetVehicleOccupied();
	
	if ( IsDefined( vehicle ) )
	{
		seat = vehicle GetOccupantSeat( self );
		
		if ( isdefined(seat) && seat == 0 )
			return true;
	}
	
	return false;
}
player_change_seat_handler_t( vehicle )
{
	self endon( "disconnect" );
	self endon( "exit_vehicle" );
	while ( 1 ) 
	{
		self waittill( "change_seat", vehicle, oldSeat, newSeat );
		
		isDriver = newSeat == 0;
		
		if ( isDriver )
		{
			if ( GetDvarInt( #"scr_veh_driversarehidden" ) != 0 )
			{
				self Ghost();
			}
		}
		else
		{
			self Show();
		}
	}
}
player_leave_vehicle_cleanup_t( vehicle )
{
	self endon( "disconnect" );
	self waittill( "exit_vehicle" );
	currentWeapon = self getCurrentWeapon();
	
	if( self.lastWeapon != currentWeapon && self.lastWeapon != "none" )
		self switchToWeapon( self.lastWeapon );
	self Show();
}
vehicle_is_tank()
{
	return self.vehicletype == "sherman_mp"
		|| self.vehicletype == "panzer4_mp"
		|| self.vehicletype == "type97_mp"
		|| self.vehicletype == "t34_mp";
}
vehicle_record_initial_values()
{
	if ( !IsDefined( self.initial_state ) )
	{
		self.initial_state= SpawnStruct();
	}
	
	if ( IsDefined( self.origin ) )
	{
		self.initial_state.origin= self.origin;
	}
	
	if ( IsDefined( self.angles ) )
	{
		self.initial_state.angles= self.angles;
	}
	
	if ( IsDefined( self.health ) )
	{
		self.initial_state.health= self.health;
	}
	self initialize_vehicle_damage_state_data();
	
	return;
}
vehicle_fireweapon_t()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	for( ;; )
	{
		self waittill( "turret_fire", player );
		
		if ( isdefined(player) && isalive(player) && player isinvehicle() )
			self fireweapon();
	}
}
vehicle_should_explode_on_cleanup()
{
	return GetDvarInt( #"scr_veh_explode_on_cleanup" ) != 0;
}
vehicle_recycle()
{
	self wait_for_unnoticeable_cleanup_opportunity();
	self.recycling = true;
	self suicide();
}
wait_for_vehicle_overturn()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	worldup = anglestoup((0,90,0));
	
	overturned = 0;
	
	while (!overturned)	
	{
		if ( IsDefined( self.angles ) )
		{
			up = AnglesToUp( self.angles );
			dot = vectordot(up, worldup);
			if (dot <= 0.0)
				overturned = 1;
		}
		
		if (!overturned)
			wait (1.0);
	}
}
vehicle_overturn_eject_occupants()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	for(;;)
	{
		self waittill( "veh_ejectoccupants" );
		if ( isDefined( level.onEjectOccupants ) )
		{
			[[level.onEjectOccupants]]();
		}
		wait .25;
	}
}
vehicle_eject_all_occupants()
{
	occupants = self GetVehOccupants();
	if ( IsDefined( occupants ) )
	{
		for ( i = 0; i < occupants.size; i++ )
		{
			if ( isDefined( occupants[i] ) )
			{
				occupants[i] Unlink();
			}
		}
	}
}
vehicle_overturn_suicide()
{
	self endon( "transmute" );
	self endon( "death" );
	self endon( "delete" );
	
	self wait_for_vehicle_overturn();
	seconds = RandomFloatRange( 5, 7 );
	wait seconds;
	
	damageOrigin = self.origin + (0,0,25);
	self finishVehicleRadiusDamage(self, self, 32000, 32000, 32000, 0, "MOD_EXPLOSIVE", "defaultweapon_mp",  damageOrigin, 400, -1, (0,0,1), 0);
}
suicide()
{
	self kill_vehicle( self );
}
kill_vehicle( attacker )
{
	damageOrigin = self.origin + (0,0,1);
	self finishVehicleRadiusDamage(attacker, attacker, 32000, 32000, 10, 0, "MOD_EXPLOSIVE", "defaultweapon_mp",  damageOrigin, 400, -1, (0,0,1), 0);
}
value_with_default( preferred_value, default_value )
{
	if ( IsDefined( preferred_value ) )
	{
		return preferred_value;
	}
	
	return default_value;
}
vehicle_transmute( attacker )
{
	deathOrigin = self.origin;
	deathAngles = self.angles;
	
	
	modelname = self VehGetModel();
	vehicle_name = get_vehicle_name_key_for_damage_states( self );
	
	
	respawn_parameters = SpawnStruct();
	respawn_parameters.origin = self.initial_state.origin;
	respawn_parameters.angles = self.initial_state.angles;
	respawn_parameters.health = self.initial_state.health;
	respawn_parameters.modelname = modelname;
	respawn_parameters.targetname = value_with_default( self.targetname, "" );
	respawn_parameters.vehicletype = value_with_default( self.vehicletype, "" );
	respawn_parameters.destructibledef = self.destructibledef; 
	
	
	vehicleWasDestroyed = !IsDefined( self.recycling );
	if ( vehicleWasDestroyed
		|| vehicle_should_explode_on_cleanup() )
	{
		_spawn_explosion( deathOrigin );
		
		if ( vehicleWasDestroyed
			&& GetDvarInt( #"scr_veh_explosion_doradiusdamage" ) != 0 )
		{
			
			
			
			
			explosionRadius = GetDvarInt( #"scr_veh_explosion_radius" );
			explosionMinDamage = GetDvarInt( #"scr_veh_explosion_mindamage" );
			explosionMaxDamage = GetDvarInt( #"scr_veh_explosion_maxdamage" );
			self kill_vehicle(attacker);
			self RadiusDamage( deathOrigin, explosionRadius, explosionMaxDamage, explosionMinDamage, attacker, "MOD_EXPLOSIVE", self.vehicletype+"_explosion_mp" );
		}
	}
	
	
	self notify( "transmute" );
	
		
	respawn_vehicle_now = true;
	
	if ( vehicleWasDestroyed
		&& GetDvarInt( #"scr_veh_ondeath_createhusk" ) != 0 )
	{
		
		
		if ( GetDvarInt( #"scr_veh_ondeath_usevehicleashusk" ) != 0 )
		{
			husk = self;
			self.is_husk = true;
		}
		else
		{
			husk = _spawn_husk( deathOrigin, deathAngles, modelname );
		}
			
		husk _init_husk( vehicle_name, respawn_parameters );
		
		if ( GetDvarInt( #"scr_veh_respawnafterhuskcleanup" ) != 0 )
		{
			respawn_vehicle_now = false;
		}
	}
	
	
	if ( !IsDefined( self.is_husk ) )
	{
		self remove_vehicle_from_world();
	}
	if ( GetDvarInt( #"scr_veh_disablerespawn" ) != 0 ) 
	{
		respawn_vehicle_now = false;
	}
	if ( respawn_vehicle_now )
	{
		respawn_vehicle( respawn_parameters );
	}
}
respawn_vehicle( respawn_parameters )
{	
	{
		minTime = GetDvarInt( #"scr_veh_respawntimemin" );
		maxTime = GetDvarInt( #"scr_veh_respawntimemax" );
		seconds = RandomFloatRange( minTime, maxTime );
		wait seconds;
	}
	
	
	wait_until_vehicle_position_wont_telefrag( respawn_parameters.origin );
	
			
	if ( !manage_vehicles() ) 
	{
		
	}
	else
	{		
		if ( IsDefined( respawn_parameters.destructibledef ) ) 
		{
			vehicle = SpawnVehicle(
				respawn_parameters.modelname,
				respawn_parameters.targetname,
				respawn_parameters.vehicletype,
				respawn_parameters.origin,
				respawn_parameters.angles,
				respawn_parameters.destructibledef );
		}
		else
		{
			vehicle = SpawnVehicle(
				respawn_parameters.modelname,
				respawn_parameters.targetname,
				respawn_parameters.vehicletype,
				respawn_parameters.origin,
				respawn_parameters.angles );
		}
		
		vehicle.vehicletype = respawn_parameters.vehicletype;
		vehicle.destructibledef = respawn_parameters.destructibledef;
		vehicle.health = respawn_parameters.health;
		
		vehicle init_vehicle();
	
		vehicle vehicle_telefrag_griefers_at_position( respawn_parameters.origin );
	}
}
remove_vehicle_from_world()
{
	
	
	
	self notify ( "removed" );
	
	if ( IsDefined( self.original_vehicle ) )
	{
		if ( !IsDefined( self.permanentlyRemoved ) )
		{
			self.permanentlyRemoved = true; 
			self thread hide_vehicle(); 
		}
		
		return false;
	}
	else 
	{
		self _delete_entity();
		return true;
	}
}
_delete_entity()
{
	
	
	self Delete();
}
hide_vehicle()
{
	under_the_world = ( self.origin[0], self.origin[1], self.origin[2] - 10000 );
	self.origin = under_the_world;
	wait 0.1;
	self Hide();
	
	self notify( "hidden_permanently" );
}
wait_for_unnoticeable_cleanup_opportunity()
{	
	maxPreventDistanceFeet = GetDvarInt( #"scr_veh_disappear_maxpreventdistancefeet" );
	maxPreventVisibilityFeet = GetDvarInt( #"scr_veh_disappear_maxpreventvisibilityfeet" );
	
	maxPreventDistanceInchesSq = 144 * maxPreventDistanceFeet * maxPreventDistanceFeet;
	maxPreventVisibilityInchesSq = 144 * maxPreventVisibilityFeet * maxPreventVisibilityFeet;
	
	maxSecondsToWait = GetDvarFloat( #"scr_veh_disappear_maxwaittime" );	
	iterationWaitSeconds = 1.0;
	
	for ( secondsWaited = 0.0; secondsWaited < maxSecondsToWait; secondsWaited += iterationWaitSeconds )
	{
		players_s = get_all_alive_players_s();
		
		okToCleanup = true;
		
		for ( j = 0; j < players_s.a.size && okToCleanup; j++ )
		{
			player = players_s.a[ j ];
			distInchesSq = DistanceSquared( self.origin, player.origin );
			
			if ( distInchesSq < maxPreventDistanceInchesSq )
			{
				self cleanup_debug_print( "(" + ( maxSecondsToWait - secondsWaited ) + "s) Player too close: " + distInchesSq + "<" + maxPreventDistanceInchesSq );
				okToCleanup = false;
			}
			else if ( distInchesSq < maxPreventVisibilityInchesSq )
			{
				vehicleVisibilityFromPlayer = self SightConeTrace( player.origin, player, AnglesToForward( player.angles ) );
				
				if ( vehicleVisibilityFromPlayer > 0 )
				{
					self cleanup_debug_print( "(" + ( maxSecondsToWait - secondsWaited ) + "s) Player can see" );
					okToCleanup = false;
				}
			}
		}
		
		if ( okToCleanup )
		{
			return;
		}
	
		wait iterationWaitSeconds;
	}
}
wait_until_vehicle_position_wont_telefrag( position )
{
	maxIterations = GetDvarInt( #"scr_veh_respawnwait_maxiterations" );
	iterationWaitSeconds = GetDvarInt( #"scr_veh_respawnwait_iterationwaitseconds" );
	
	for ( i = 0; i < maxIterations; i++ )
	{
		if ( !vehicle_position_will_telefrag( position ) )
		{
			return;
		}
		
		wait iterationWaitSeconds;
	}
}
vehicle_position_will_telefrag( position )
{
	players_s = get_all_alive_players_s();
	
	for ( i = 0; i < players_s.a.size; i++ )
	{
		if ( players_s.a[ i ] player_vehicle_position_will_telefrag( position ) )
		{
			return true;
		}
	}
	
	return false;
}
vehicle_telefrag_griefers_at_position( position )
{
	attacker = self;
	inflictor = self;
	doDamageToHead = 0;
	
	players_s = get_all_alive_players_s();
	
	for ( i = 0; i < players_s.a.size; i++ )
	{
		player = players_s.a[ i ];
		
		if ( player player_vehicle_position_will_telefrag( position ) )
		{
			player DoDamage( 20000, player.origin + ( 0, 0, 1 ), attacker, inflictor, doDamageToHead );
		}
	}
}
player_vehicle_position_will_telefrag( position )
{
	distanceInches = 20 * 12; 
	minDistInchesSq = distanceInches * distanceInches;
	
	distInchesSq = DistanceSquared( self.origin, position );
	
	return distInchesSq < minDistInchesSq;
}
vehicle_recycle_spawner_t()
{
	self endon( "delete" );
	
	self waittill( "death", attacker ); 
	
	if ( IsDefined( self ) )
	{
		self vehicle_transmute( attacker );
	}
}
vehicle_play_explosion_sound()
{
	self playSound( "car_explo_large" );
}
vehicle_damage_t()
{
	self endon( "delete" );
	self endon( "removed" );
	
	for( ;; )
	{
		self waittill ( "damage", damage, attacker );
		players = get_players();
		for ( i = 0 ; i < players.size ; i++ )
		{
			if ( !isalive(players[i]) )
				continue;
				
			vehicle = players[i] GetVehicleOccupied();
			if ( isdefined( vehicle) && self == vehicle && players[i] player_is_driver() )
			{
				if (damage>0)
				{
					
					earthquake( damage/400, 1.0, players[i].origin, 512, players[i] );
				}
				
				if ( damage > 100.0 )
				{
					players[i] PlayRumbleOnEntity( "tank_damage_heavy_mp" );
				}
				else if ( damage > 10.0 )
				{
					players[i] PlayRumbleOnEntity( "tank_damage_light_mp" );
				}
			}
		}
		
		update_damage_effects(self, attacker);
		if ( self.health <= 0 )
		{
			return;
		}
	}
}
	
_spawn_husk( origin, angles, modelname )
{	
	husk = Spawn( "script_model", origin );
	husk.angles = angles;
	husk SetModel( modelname );
	
	husk.health = 1;
	husk SetCanDamage( false ); 
	
	return husk;
}
is_vehicle()
{
	
	return IsDefined( self.vehicletype );
}
swap_to_husk_model()
{
	if ( IsDefined( self.vehicletype ) )
	{
		husk_model = level.veh_husk_models[ self.vehicletype ];
		
		if ( IsDefined( husk_model ) )
		{
			self SetModel( husk_model );
		}
	}
}
_init_husk( vehicle_name, respawn_parameters )
{
	self swap_to_husk_model();
	effects = level.vehicles_husk_effects[ vehicle_name ];
	self play_vehicle_effects( effects );
	
	
	self.respawn_parameters = respawn_parameters;
	
	
	forcePointVariance = GetDvarInt( #"scr_veh_explosion_husk_forcepointvariance" );
	horzVelocityVariance = GetDvarInt( #"scr_veh_explosion_husk_horzvelocityvariance" );
	vertVelocityMin = GetDvarInt( #"scr_veh_explosion_husk_vertvelocitymin" );
	vertVelocityMax = GetDvarInt( #"scr_veh_explosion_husk_vertvelocitymax" );
	
	
	forcePointX = RandomFloatRange( 0-forcePointVariance, forcePointVariance );
	forcePointY = RandomFloatRange( 0-forcePointVariance, forcePointVariance );
	forcePoint = ( forcePointX, forcePointY, 0 );
	forcePoint += self.origin;
	
	initialVelocityX = RandomFloatRange( 0-horzVelocityVariance, horzVelocityVariance );
	initialVelocityY = RandomFloatRange( 0-horzVelocityVariance, horzVelocityVariance );
	initialVelocityZ = RandomFloatRange( vertVelocityMin, vertVelocityMax );
	initialVelocity = ( initialVelocityX, initialVelocityY, initialVelocityZ );
	
	
	if ( self is_vehicle() )
	{
		self LaunchVehicle( initialVelocity, forcePoint );
	}
	else
	{
		self PhysicsLaunch( forcePoint, initialVelocity );
	}
	
	
	self thread husk_cleanup_t();
	
	
}
husk_cleanup_t()
{
	self endon( "death" ); 
	self endon( "delete" );
	self endon( "hidden_permanently" );
	
	
	respawn_parameters = self.respawn_parameters;
	
	
	self do_dead_cleanup_wait( "Husk Cleanup Test" );
	
	self wait_for_unnoticeable_cleanup_opportunity();
	
	
	self thread final_husk_cleanup_t( respawn_parameters ); 
}
final_husk_cleanup_t( respawn_parameters )
{
	self husk_do_cleanup(); 
	
	if ( GetDvarInt( #"scr_veh_respawnafterhuskcleanup" ) != 0 )
	{
		if ( GetDvarInt( #"scr_veh_disablerespawn" ) == 0 ) 
		{
			respawn_vehicle( respawn_parameters );
		}	
	}
}
husk_do_cleanup()
{
	
	
	
	
	self _spawn_explosion( self.origin );
	
	
	if ( self is_vehicle() )
	{
		return self remove_vehicle_from_world();
	}
	else
	{
		self _delete_entity();
		return true;
	}
}
	
_spawn_explosion( origin )
{
	if ( GetDvarInt( #"scr_veh_explosion_spawnfx" ) == 0 )
	{
		return;
	}
	
	if ( IsDefined( level.vehicle_explosion_effect ) )
	{
		forward = ( 0, 0, 1 );
		
		rot = randomfloat( 360 );
		up = ( cos( rot ), sin( rot ), 0 );
		
		PlayFX( level.vehicle_explosion_effect, origin, forward, up );
	}
	
	thread _play_sound_in_space( "vehicle_explo", origin );
}
_play_sound_in_space( soundEffectName, origin )
{
	org = Spawn( "script_origin", origin );
	org.origin = origin;
	org playSound( soundEffectName  );
	wait 10; 
	org delete();
}
vehicle_get_occupant_team()
{
	occupants = self GetVehOccupants();
	
	if ( occupants.size != 0 )
	{
		
		occupant = occupants[0];
		
		if ( isplayer(occupant) )
		{
			return occupant.team;
		}
	}
	return "free";
}
vehicleDeathWaiter()
{
	self notify ("vehicleDeathWaiter");
	self endon ( "vehicleDeathWaiter" );
	self endon ( "disconnect" );
	while ( true )
	{
		self waittill( "vehicle_death", vehicle_died );
		if( vehicle_died )
		{
			self.diedOnVehicle = true;
		}
		else
		{
			
			self.diedOnTurret = true;
		}
	}
}
turretDeathWaiter()
{
	
}
vehicle_kill_disconnect_paths_forever()
{
	self notify( "kill_disconnect_paths_forever" );
}
vehicle_disconnect_paths()
{
	
	self endon( "death" );
	self endon( "kill_disconnect_paths_forever" );
	if ( isdefined( self.script_disconnectpaths ) && !self.script_disconnectpaths )
	{
		self.dontDisconnectPaths = true;
		return;		
	}
	wait( randomfloat( 1 ) );
	while( isdefined( self ) )
	{
		if( self getspeed() < 1 )
		{
			if ( !isdefined( self.dontDisconnectPaths ) )
			self disconnectpaths();
			self notify( "speed_zero_path_disconnect" );
			while( self getspeed() < 1 )
				wait .05; 
		}
		self connectpaths();
		wait 1; 
	}
}
follow_path( node )
{
	self endon("death");
	
	assertex( IsDefined( node ), "vehicle_path() called without a path" );
	self notify( "newpath" );
	 
	if( IsDefined( node ) )
	{
		self.attachedpath = node; 
	}
	
	pathstart = self.attachedpath; 
	self.currentNode = self.attachedpath; 
	if( !IsDefined( pathstart ) )
	{
		return; 
	}
	self AttachPath( pathstart );
	self StartPath();
	self endon( "newpath" );
	nextpoint = pathstart;
	while ( IsDefined( nextpoint ) )
	{
		self waittill( "reached_node", nextpoint );	
		
		nextpoint notify( "trigger", self );
		if ( IsDefined( nextpoint.script_noteworthy ) )
		{
			self notify( nextpoint.script_noteworthy );
			self notify( "noteworthy", nextpoint.script_noteworthy );
		}
		
		waittillframeend; 
	}
}