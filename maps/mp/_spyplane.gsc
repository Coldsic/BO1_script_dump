#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include maps\mp\_airsupport;
init()
{
	level.spyplanemodel = "t5_veh_jet_u2";
	
	level.u2_maxhealth = 700;
	
	level.spyplane = [];
	level.spyplaneEntranceTime = 5;
	level.spyplaneExitTime = 20;
	
	level.counteruavWeapon = "counteruav_mp";	
	level.counteruavLength = 25.0;
	
	precachemodel( level.spyplanemodel );
	level.counteruavplaneEntranceTime = 5;
	level.counteruavplaneExitTime = 20;
	
	level.fx_sr71_trail = loadfx("misc/fx_equip_sr71_contrail");
	level.fx_sr71_glint = loadfx("misc/fx_equip_sr71_sky_glint");
	
	level.fx_spyplane_afterburner = loadfx("vehicle/exhaust/fx_exhaust_u2_spyplane_afterburner");
	
	level.satelliteHeight = 10000;
	level.satelliteFlyDistance = 10000;
	
	level.fx_u2_damage_trail = loadfx("trail/fx_trail_u2_plane_damage_mp");
	level.fx_u2_explode = loadfx("vehicle/vexplosion/fx_vexplode_u2_exp_mp");
	minimapOrigins = getEntArray( "minimap_corner", "targetname" );
	if ( miniMapOrigins.size )
		uavOrigin = maps\mp\gametypes\_spawnlogic::findBoxCenter( miniMapOrigins[0].origin, miniMapOrigins[1].origin );
	else
		uavOrigin = (0,0,0);
	if ( level.teamBased )
	{
		level.activeUAVs["allies"] = 0;
		level.activeUAVs["axis"] = 0;
		level.activeCounterUAVs["allies"] = 0;
		level.activeCounterUAVs["axis"] = 0;
		level.activeSatellites["allies"] = 0;
		level.activeSatellites["axis"] = 0;
	}
	else
	{	
		level.activeUAVs = [];	
		level.activeCounterUAVs = [];	
		level.activeSatellites = [];
	}
	level.UAVRig = spawn( "script_model", uavOrigin );
	level.UAVRig setModel( "tag_origin" );
	level.UAVRig.angles = (0,115,0);
	level.UAVRig hide();
	level.UAVRig thread rotateUAVRig(true);
	
	level.CounterUAVRig = spawn( "script_model", uavOrigin );
	level.CounterUAVRig setModel( "tag_origin" );
	level.CounterUAVRig.angles = (0,115,0);
	level.CounterUAVRig hide();
	level.CounterUAVRig thread rotateUAVRig(false);
	
	level thread UAVTracker();
	level thread onPlayerConnect();
	
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player.entnum = player getEntityNumber();
		level.activeUAVs[ player.entnum ] = 0;
		level.activeCounterUAVs[ player.entnum ] = 0;
		level.activeSatellites[ player.entnum ] = 0;
		if ( level.teambased == false )
		{
			player thread watchFFASpawn();
		}
	}
}
watchFFASpawn()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "spawned_player" );
		level notify( "uav_update" );
	}	
}
rotateUAVRig( clockwise )
{
	turn = 360;
	if ( clockwise )
		turn = -360;
	
	for (;;)
	{
		self rotateyaw( turn, 60 );
		wait ( 60 );
	}
}
callcounteruav( type, displayMessage )
{
	timeInAir = self maps\mp\_radar::useRadarItem( type, self.team, displayMessage);
	isCounter = 1;
	
	counteruavplane = generatePlane( self, timeInAir, isCounter );
	if ( !isdefined( counteruavplane ) )
	{
		return false;
	}
	counteruavplane SetClientFlag( level.const_flag_counteruav );			
	counteruavplane addActiveCounterUAV();
	counteruavplane thread counteruavplane_death_waiter();	
	counteruavplane thread counteruavplane_timeout( timeInAir );
	counteruavplane thread plane_damage_monitor( false );
	counteruavplane thread plane_health();
	return true;
}
callspyplane( type, displayMessage )
{
	timeInAir = self maps\mp\_radar::useRadarItem( type, self.team, displayMessage);	
 	isCounter = 0;
	spyplane = generatePlane( self, timeInAir, isCounter );
	if ( !isdefined( spyplane ) )
		return false;
	spyplane addActiveUAV();
	spyplane thread spyplane_timeout( timeInAir );
	spyplane thread spyplane_death_waiter();	
	spyplane thread plane_damage_monitor( true );
	spyplane thread plane_health();
	return true;
}
callsatellite( type, displayMessage )
{
	timeInAir = self maps\mp\_radar::useRadarItem( type, self.team, displayMessage);	
	satellite = Spawn( "script_model", level.mapcenter + ( ( 0 - level.satelliteFlyDistance ), 0, level.satelliteHeight ) ); 
	satellite setModel( "tag_origin" );
	satellite moveto( level.mapcenter + ( level.satelliteFlyDistance, 0, level.satelliteHeight ), timeInAir );
	satellite.owner = self;
	satellite.team = self.team;
	satellite.otherteam = "axis";
	if (satellite.team == "axis")
		satellite.otherteam = "allies";
	satellite setTeam(self.team);
	satellite setOwner( self );
	satellite addActiveSatellite();
	satellite thread satellite_timeout( timeInAir );
	if ( level.teambased ) 
	{
		satellite thread updateVisibility();
		satellite thread playSatelliteFX();
	}
	return true;
}
addActiveCounterUAV()
{
	if ( level.teamBased )
		level.activeCounterUAVs[self.team]++;	
	else
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		level.activeCounterUAVs[self.owner.entnum]++;
	}
	level notify ( "uav_update" );
}
addActiveUAV()
{
	if ( level.teamBased )
		level.activeUAVs[self.team]++;	
	else
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		level.activeUAVs[self.owner.entnum]++;
	}
	level notify ( "uav_update" );
}
addActiveSatellite()
{
	if ( level.teamBased )
		level.activeSatellites[self.team]++;	
	else
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		level.activeSatellites[self.owner.entnum]++;
	}
	level notify ( "uav_update" );
}
removeActiveUAV()
{
	if ( level.teamBased )
	{
		level.activeUAVs[self.team]--;
		assert( level.activeUAVs[self.team] >= 0 );
		if ( level.activeUAVs[self.team] < 0 ) 
			level.activeUAVs[self.team] = 0;
	}
	else if ( isDefined( self.owner ) )
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		
		level.activeUAVs[self.owner.entnum]--;
		assert( level.activeUAVs[self.owner.entnum] >= 0 );
		if ( level.activeUAVs[self.owner.entnum] < 0 ) 
			level.activeUAVs[self.owner.entnum] = 0;
	}
	
	maps\mp\_killstreakrules::killstreakStop( "radar_mp", self.team );
	level notify ( "uav_update" );
}
removeActiveCounterUAV()
{
	if ( level.teamBased )
	{
		level.activeCounterUAVs[self.team]--;
		assert( level.activeCounterUAVs[self.team] >= 0 );
		if ( level.activeCounterUAVs[self.team] < 0 ) 
			level.activeCounterUAVs[self.team] = 0;
	}
	else if ( isDefined( self.owner ) )
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		
		level.activeCounterUAVs[self.owner.entnum]--;
		assert( level.activeCounterUAVs[self.owner.entnum] >= 0 );
		if ( level.activeCounterUAVs[self.owner.entnum] < 0 ) 
			level.activeCounterUAVs[self.owner.entnum] = 0;
	}
	maps\mp\_killstreakrules::killstreakStop( "counteruav_mp", self.team );
	level notify ( "uav_update" );
}
removeActiveSatellite()
{
	if ( level.teamBased )
	{
		level.activeSatellites[self.team]--;
		assert( level.activeSatellites[self.team] >= 0 );
		if ( level.activeSatellites[self.team] < 0 ) 
			level.activeSatellites[self.team] = 0;
	}
	else if ( isDefined( self.owner ) )
	{
		assert( isdefined( self.owner.entnum ) );
		if ( !isdefined( self.owner.entnum ) )
			self.owner.entnum = self.owner getEntityNumber();
		level.activeSatellites[self.owner.entnum]--;
		assert( level.activeSatellites[self.owner.entnum] >= 0 );
		if ( level.activeSatellites[self.owner.entnum] < 0 ) 
			level.activeSatellites[self.owner.entnum] = 0;
	}
	maps\mp\_killstreakrules::killstreakStop( "radardirection_mp", self.team );
	level notify ( "uav_update" );
}
playSpyplaneFX()
{
	wait( 0.1 );
	PlayFXOnTag( level.fx_spyplane_afterburner, self, "tag_origin" );
}
playSatelliteFX()
{
	wait( 0.1 );
	PlayFXOnTag( level.fx_sr71_trail, self, "tag_origin" );
	PlayFXOnTag( level.fx_sr71_glint, self, "tag_origin" );
}
generatePlane( owner, timeInAir, isCounter )
{
	UAVRig = level.UAVRig;
	attach_angle = -90;
	
	if ( isCounter )
	{
		UAVRig = level.CounterUAVRig;
		attach_angle = 90;
	}
		
	plane = spawn( "script_model", UAVRig getTagOrigin( "tag_origin" ) );
	
	plane setModel( level.spyplanemodel );
	plane SetTeam( owner.team );
	plane SetOwner( owner );
	Target_Set( plane );
	plane.owner = owner;
	plane.team = owner.team;
	plane.otherteam = "axis";
	if (plane.team == "axis")
		plane.otherteam = "allies";
	
	plane thread updateVisibility( );
	plane thread handleIncomingMissile();
	
	level.plane[self.team] = plane;
	plane.health_low = level.u2_maxhealth*0.5;		
	plane.maxhealth = level.u2_maxhealth;
	plane.health = 99999;
	plane.rocketDamageOneShot = level.u2_maxhealth + 1;			
	plane.rocketDamageTwoShot = (level.u2_maxhealth / 2) + 1;	
	zOffset = randomIntRange( 3000, 5000 );
	angle = randomInt( 360 );
	radiusOffset = randomInt( 2000 ) + 5000;
	xOffset = cos( angle ) * radiusOffset;
	yOffset = sin( angle ) * radiusOffset;
	angleVector = vectorNormalize( (xOffset,yOffset,zOffset) );
	angleVector = vector_multiply( angleVector, randomIntRange( 6000, 7000 ) );
	plane linkTo( UAVRig, "tag_origin", angleVector, (0,angle + attach_angle,0) );
	
	return plane;
}
updateVisibility()
{
	self endon ( "death" );
	
	for ( ;; )
	{
		if( level.teambased )
		{
			self SetVisibleToTeam( self.otherteam );
		}
		else
		{
			self SetVisibleToAll();
			self SetInvisibleToPlayer( self.owner );
		}
		level waittill( "joined_team" );
	}	
}
plane_damage_monitor( isSpyPlane )
{
	self endon( "death" );
	self endon( "crashing" );
	self endon( "delete" );
	
	self SetCanDamage( true );
	
	self.damageTaken = 0;
	
	for( ;; )
	{
		
		self waittill( "damage", damage, attacker, direction, point, type, tagName, modelName, partname, weapon );		
		if( !isdefined( attacker ) || !isplayer( attacker ) )
			continue;
		
		friendlyfire = maps\mp\gametypes\_weaponobjects::friendlyFireCheck( self.owner, attacker );
		
		if( !friendlyfire )
			continue;			
			
		if(	isDefined( self.owner ) && attacker == self.owner )
			continue;
		
		isValidAttacker = true;
		if( level.teambased )
			isValidAttacker = (isdefined( attacker.team ) && attacker.team != self.team);
		if ( !isValidAttacker )
			continue;
		if( maps\mp\gametypes\_globallogic_player::doDamageFeedback( weapon, attacker ) )
			attacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( false );
		
		self.attacker = attacker;
		
		attacker thread maps\mp\_properks::shotAirplane( self.owner, weapon, type );
		
		
		
		
		
		
		switch( type )
		{
		case "MOD_RIFLE_BULLET":
		case "MOD_PISTOL_BULLET":
			{
				if ( attacker HasPerk( "specialty_armorpiercing" ) )
				{
					self.damageTaken += int( damage * level.cac_armorpiercing_data );
				}
				else
				{
					self.damageTaken += damage;
				}
			}
			break;
		case "MOD_PROJECTILE":
			
			self.damageTaken += self.rocketDamageOneShot;
			break;
		default:
			self.damageTaken += damage;
			break;
		}
		
		self.health += damage;
		
		if( self.damageTaken > self.maxhealth )
		{
			killstreakReference = "killstreak_spyplane";
			if( !isSpyPlane )
				killstreakReference = "killstreak_counteruav";
			
			attacker notify( "destroyed_spyplane" );
			value = maps\mp\gametypes\_rank::getScoreInfoValue( "spyplanekill" );
			attacker maps\mp\_medals::destroyerUAV( isSpyPlane, weapon );
				
			
			
			
			attacker maps\mp\_properks::destroyedKillstreak();
			weaponStatName = "destroyed";
			switch( weapon )
			{
			
			case "auto_tow_mp":
			case "tow_turret_mp":
			case "tow_turret_drop_mp":
				weaponStatName = "kills";
				break;
			}
			attacker maps\mp\gametypes\_globallogic_score::setWeaponStat( weapon, 1, weaponStatName );
			level.globalKillstreaksDestroyed++;
			
			attacker maps\mp\gametypes\_globallogic_score::incItemStatByReference( killstreakReference, 1, "destroyed" );
			
			attacker thread maps\mp\gametypes\_rank::giveRankXP( "spyplanekill", value );
			if ( isSpyPlane )
			{
				level thread maps\mp\_popups::DisplayTeamMessageToAll( &"KILLSTREAK_DESTROYED_UAV", attacker ); 
				spyplane_death();
			}
			else 
			{
				level thread maps\mp\_popups::DisplayTeamMessageToAll( &"KILLSTREAK_DESTROYED_COUNTERUAV", attacker ); 
				counteruavplane_death();
			}
		}
	}
}
plane_health()
{
	self endon( "death" );
	self endon( "crashing" );
	
	self.currentstate = "ok";
	self.laststate = "ok";
	
	while ( self.currentstate != "leaving" )
	{
		if ( self.damageTaken >= self.health_low )
			self.currentstate = "damaged";
		if ( self.currentstate == "damaged" && self.laststate != "damaged" )
		{
			
			self.laststate = self.currentstate;
			self thread playDamageFX();
		}
			
		
			
		
		wait 1;
	}
}
playDamageFX()
{
	self endon( "death" );
	self endon( "crashing" );
	while (1)
	{
		playfxontag( level.fx_u2_damage_trail, self, "tag_origin" );
		wait (10);
	}
	
}
u2_crash()
{
	self notify( "crashing" );
	playfxontag( level.fx_u2_explode, self, "tag_origin" );
	wait (0.1);
	self setModel( "tag_origin" );
	wait(0.2);
	self notify( "delete" );
	self delete();
}
counteruavplane_death_waiter()
{
	self endon( "delete" );
	self endon ( "leaving");
	
	self waittill( "death" );
	
	counteruavplane_death();
}
spyplane_death_waiter()
{
	self endon( "delete" );
	self endon ( "leaving");
	
	self waittill( "death" );
	
	spyplane_death();
}
counteruavplane_death()
{
	self ClearClientFlag( level.const_flag_counteruav );
	self removeActiveCounterUAV();
	Target_Remove( self );
	self thread u2_crash();	
}
spyplane_death()
{
	self removeActiveUAV();
	Target_Remove( self );
	self thread u2_crash();	
}
counteruavplane_timeout( timeInAir )
{
	self endon ( "death" );
	self endon ( "delete" );
	
	endTime = gettime() + timeInAir * 1000 ;
	
	self.endTime = endTime;
	wait( timeInAir );
	self ClearClientFlag( level.const_flag_counteruav );
	self plane_leave();
	wait (level.counteruavplaneExitTime);
	self removeActiveCounterUAV();
	Target_Remove( self );
	self delete();
}
satellite_timeout( timeInAir )
{
	self endon ( "death" );
	self endon ( "delete" );
	
	endTime = gettime() + timeInAir * 1000 ;
	self.endTime = endTime;
	
	wait( timeInAir );
	
	self removeActiveSatellite();
	self delete();
}
spyplane_timeout( timeInAir )
{
	self endon ( "death" );
	self endon ( "delete" );
	
	endTime = gettime() + timeInAir * 1000 ;
	self.endTime = endTime;
	self thread completeTimeInAir( timeInAir );
	self waittill( "spyplaneShouldLeave" );
	self plane_leave();
	wait (level.spyplaneExitTime);	
	self removeActiveUAV();	
	Target_Remove( self );
	self delete();
}
completeTimeInAir( duration )
{
	self endon( "spyplaneShouldLeave" );
	wait( duration );
	self notify( "spyplaneShouldLeave" );
}
plane_leave()
{	
	self unlink();
	self thread playSpyplaneFX();
	self.currentstate = "leaving";
	
	mult = getDvarIntDefault( #"scr_spymult", 20000 );
	
	exitVector = vector_multiply( anglestoforward( self.angles ), 20000 );
	
	exitPoint = ( self.origin[0] + exitVector[0], self.origin[1] + exitVector[1], self.origin[2] - 2500);
	exitPoint = self.origin + exitVector;
	self.angles = (self.angles[0], self.angles[1], 0);
	self moveto( exitPoint, level.spyplaneExitTime, 0, 0 );
	self notify ( "leaving");
}
handleIncomingMissile()
{
	level endon ( "game_ended" );
	self endon ( "death" );
	
	for ( ;; )
	{
		level waittill ( "missile_fired", player, missile, lockTarget, fullyAquired );
		
		if ( !IsDefined( lockTarget ) || (lockTarget != self) || !fullyAquired )
			continue;
			
		missile thread missileProximityDetonate( lockTarget, player );
	}
}
missileDetonate( player )
{
	self endon ( "death" );
	radiusDamage( self.origin, 1536, 600, 600, player );
	wait( 0.05 );
	self detonate();
	wait( 0.05 );
	self delete();
}
missileProximityDetonate( targetEnt, player )
{
	self endon ( "death" );
	targetEnt endon( "crashing" );
	minDist = distance( self.origin, targetEnt.origin );
	lastCenter = targetEnt.origin;
	for ( ;; )
	{
		
		if ( !isDefined( targetEnt ) )
			center = lastCenter;
		else
			center = targetEnt.origin;
			
		lastCenter = center;		
		
		curDist = distance( self.origin, center );
		
		if ( curDist < minDist )
			minDist = curDist;
		
		if ( curDist > minDist )
		{
			if ( curDist > 1536 )
				return;
				
			self thread missileDetonate( player );
		}
		
		wait ( 0.05 );
	}	
}
UAVTracker()
{
	level endon ( "game_ended" );
	
	for ( ;; )
	{
		level waittill ( "uav_update" );
		
		if ( level.teamBased )
		{
			updateTeamUAVStatus( "allies" );
			updateTeamUAVStatus( "axis" );		
		}
		else
		{
			updatePlayersUAVStatus();
		}
	}
}
updateTeamUAVStatus( team )
{
	activeUAVs = level.activeUAVs[team];
	activeSatellites = level.activeSatellites[team];
	radarMode = 1;
	
	if ( activeSatellites > 0 ) 
	{
		maps\mp\_radar::setTeamSpyplaneWrapper( team, 0 );
		maps\mp\_radar::setTeamSatelliteWrapper( team, 1 );
		return;
	}
	
	maps\mp\_radar::setTeamSatelliteWrapper( team, 0 );
	
	if ( !activeUAVs )
	{
		maps\mp\_radar::setTeamSpyplaneWrapper( team, 0 );
		return;
	}
	
	if ( activeUAVs > 1 )
		radarMode = 2;
	maps\mp\_radar::setTeamSpyplaneWrapper( team, radarMode );	
}
updatePlayersUAVStatus()
{
	for(i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		assert( isdefined( player.entnum ) );
		if ( !isdefined( player.entnum ) )
			player.entnum = player getEntityNumber();
		activeUAVs = level.activeUAVs[ player.entnum ];
		activeSatellites = level.activeSatellites[ player.entnum ];
		
		if ( activeSatellites > 0 )
		{
			player.hasSatellite = true;
			player.hasSpyplane = 0;
			player setClientUIVisibilityFlag( "radar_client", 1 );
			continue;
		}
		
		player.hasSatellite = false;
		
		if ( ( activeUAVs == 0 ) && !( isDefined( player.pers["hasRadar"] ) && player.pers["hasRadar"] ) )
		{
			player.hasSpyplane = 0;
			player setClientUIVisibilityFlag( "radar_client", 0 );
			continue;
		}
		
		if ( activeUAVs > 1 )
			spyplaneUpdateSpeed = 2;
		else
			spyplaneUpdateSpeed = 1;
						
		player setClientUIVisibilityFlag( "radar_client", 1 );
		player.hasSpyplane = spyplaneUpdateSpeed;
	}
} 
 
 
  
