#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\_airsupport;
init()
{
	
	
	
	
	
	
	
	
	level.artilleryDangerMaxRadius = 750;
	level.artilleryDangerMinRadius = 300;
	level.artilleryDangerForwardPush = 1.5;
	level.artilleryDangerOvalScale = 6.0;
	level.artilleryCanonShellCount =  maps\mp\gametypes\_tweakables::getTweakableValue( "killstreak", "artilleryCanonShellCount" );
	level.artilleryCanonCount = maps\mp\gametypes\_tweakables::getTweakableValue( "killstreak", "artilleryCanonCount" );
	level.artilleryShellsInAir = 0;
	level.artilleryMapRange = level.artilleryDangerMinRadius * .3 + level.artilleryDangerMaxRadius * .7;
	level.artilleryDangerMaxRadiusSq = level.artilleryDangerMaxRadius * level.artilleryDangerMaxRadius;
	level.artilleryDangerCenters = [];
	
	
	
	
	
	
	
	
	
	
	
	
	
}
useKillstreakArtillery( hardpointType )
{
	if ( self maps\mp\_killstreakrules::isKillstreakAllowed( hardpointType, self.team ) == false )
		return false;
		
	result = self maps\mp\_artillery::selectArtilleryLocation( hardpointType );
	
	if ( !isDefined( result ) || !result )
		return false;
	return true;
}
artilleryWaiter()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	while(1)
	{
		self waittill( "artillery_status_change", owner );
		
		if( !isDefined(level.artilleryInProgress) )
		{
			pos = ( 0, 0, 0 );
			clientNum = -1;
			if ( isdefined ( owner ) )
				clientNum = owner getEntityNumber();
			artilleryiconlocation( pos, 0, 0, 0, clientNum );
		}
	}
}
useArtillery( pos )
{
	if ( self maps\mp\_killstreakrules::killstreakStart( "artillery_mp", self.team ) == false )
		return false;
	level.artilleryInProgress = true;
	trace = bullettrace( self.origin + (0,0,10000), self.origin, false, undefined );
	pos = (pos[0], pos[1], trace["position"][2] - 514);
	if ( maps\mp\gametypes\_tweakables::getTweakableValue( "team", "allowHardpointStreakAfterDeath" ) )
	{
		ownerDeathCount = self.deathCount;
	}
	else
	{
		ownerDeathCount = self.pers["hardPointItemDeathCountartillery_mp"];
	}
	
	if (level.teambased)
		teamType = self.team;
	else
		teamType = "none";
		
	thread doArtillery( pos, self, teamType, ownerDeathCount );
	return true;
}
selectArtilleryLocation( hardpointType )
{
	self beginLocationArtillerySelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
	self.selectingLocation = true;
	self thread endSelectionThink();
	self waittill( "confirm_location", location );
	if ( !IsDefined( location ) )
	{
		
		return false;
	}
	if ( self maps\mp\_killstreakrules::isKillstreakAllowed( hardpointType, self.team ) == false )
	{
		return false;
	}
	
	
	return self finishHardpointLocationUsage( location, ::useArtillery );
}
startArtilleryCanon(  owner, coord, yaw, distance, initial_delay, ownerDeathCount)
{
	owner endon("disconnect");
	wait ( initial_delay );
	
	cannonAccuracyRadiusMin = 0;	 
	cannonAccuracyRadiusMax = 500; 
	shellAccuracyRadiusMin = 0;	 
	shellAccuracyRadiusMax = 520; 
	volleyCount = 1;
	volleyWaitMin = 1.2;
	volleyWaitMax = 1.6;
	shellWaitMin = 2;
	shellWaitMax = 4;
	requiredDeathCount = ownerDeathCount;
	
	for( volley = 0; volley < volleyCount; volley++ )
	{		
		volleyCoord = randPointRadiusAway( coord, randomfloatrange( cannonAccuracyRadiusMin, cannonAccuracyRadiusMax ) );
		for( shell = 0; shell < level.artilleryCanonShellCount; shell++ )
		{
			wait randomFloatRange( shellWaitMin, shellWaitMax );
			strikePos = randPointRadiusAway( volleyCoord, randomintrange( shellAccuracyRadiusMin, shellAccuracyRadiusMax ) );
			level thread doArtilleryStrike( owner, requiredDeathCount, strikePos, yaw, distance );
		}
		
		cannonAccuracyRadiusMin -= cannonAccuracyRadiusMin / (volleyCount - volley + 1);
		cannonAccuracyRadiusMax -= cannonAccuracyRadiusMax / (volleyCount - volley + 1);
		wait randomFloatRange( volleyWaitMin, volleyWaitMax );
	}
}
callArtilleryStrike( owner, coord, yaw, distance, ownerDeathCount )
{	
	owner endon("disconnect");
	level.artilleryDamagedEnts = [];
	level.artilleryDamagedEntsCount = 0;
	level.artilleryDamagedEntsIndex = 0;
	
	volleyCoord = coord;
	level.artilleryKillcamModelCounts = 0;
	
	minInitialDelay = 0;
	maxInitialDelay = 1;
	minDistanceRandom = -100;
	maxDistanceRandom = 100;
	minYawRandom = 1;
	maxYawRandom = 3;	
	thread startArtilleryCanon( owner, coord, yaw - RandomIntRange( minYawRandom, maxYawRandom ) , distance - RandomFloatRange( minDistanceRandom, maxDistanceRandom ), RandomFloatRange( minInitialDelay, maxInitialDelay ),ownerDeathCount);
	thread startArtilleryCanon( owner, coord, yaw, distance, RandomFloatRange( minInitialDelay, maxInitialDelay ),ownerDeathCount);
	thread startArtilleryCanon( owner, coord, yaw + RandomIntRange( minYawRandom, maxYawRandom ) , distance - RandomFloatRange( minDistanceRandom, maxDistanceRandom ), RandomFloatRange( minInitialDelay, maxInitialDelay ),ownerDeathCount);
}
getBestFlakDirection( hitpos, team )
{
	targetname = "artillery_"+team;
	spawns = getentarray(targetname,"targetname");
	
	if ( !isdefined(spawns) || spawns.size == 0 )
	{
		origins = get_random_artillery_origins();
	}
	else
	{
		origins = get_origin_array( spawns );
	}
	
	closest_dist = 99999999*99999999;
	closest_index = randomint(origins.size);
	negative_t = false;
	
	for ( i = 0; i < origins.size; i++)
	{
		result = closest_point_on_line_to_point( hitpos, level.mapcenter, origins[i] );
		
		
		
		
		if ( result.t > 0 && negative_t )
			continue;
			
		if ( result.distsqr < closest_dist || (!negative_t && result.t < 0 ) )
		{
			closest_dist = result.distsqr;
			closest_index = i;
			
			if ( result.t < 0 )
			{
				negative_t = true;
			}
		}
	}
	spot = origins[closest_index];
	
	
	
  direction = level.mapcenter - spot ;
  
  angles = vectortoangles(direction);
  
  return angles[1];
} 
get_random_artillery_origins()
{
	
	
	
	maxs = level.spawnMaxs + ( 1000, 1000, 0);
	mins = level.spawnMins - ( 1000, 1000, 0);
	origins = [];
	
	x_length = abs( maxs[0] - mins[0] );
	y_length = abs( maxs[1] - mins[1]);
	major_axis = 0;
	minor_axis = 1;
	if ( y_length > x_length )
	{
		major_axis = 1;
		minor_axis = 0;
	}
	for ( i = 0; i < 3; i++ )
	{
		major_value = mins[major_axis] - randomfloatrange( mins[major_axis], level.mapcenter[major_axis]) * ( 2.0 );
		minor_value = randomfloatrange( mins[minor_axis], maxs[minor_axis]);
		 
		if ( major_axis == 0)
		{
			origins[origins.size] = ( major_value, minor_value, level.mapCenter[2] );
		}
		else
		{
			origins[origins.size] = ( minor_value, major_value, level.mapCenter[2] );
		}
		
		major_value = maxs[major_axis] + randomfloatrange( level.mapcenter[major_axis], maxs[major_axis]) * ( 2.0 );
		minor_value = randomfloatrange( mins[minor_axis], maxs[minor_axis]);
		 
		if ( major_axis == 0)
		{
			origins[origins.size] = ( major_value, minor_value, level.mapCenter[2] );
		}
		else
		{
			origins[origins.size] = ( minor_value, major_value, level.mapCenter[2] );
		}
	}
			
	return origins;
}
artilleryImpactEffects( )
{
	self endon("disconnect");
	self endon( "artillery_status_change" );
	while ( level.artilleryShellsInAir )
	{
		self waittill("projectile_impact", weapon, position, radius );
		
		if ( weapon == "artillery_mp" )
		{
			radiusArtilleryShellshock( position, radius * 1.1, 3, 1.5, self );
			maps\mp\gametypes\_shellshock::artillery_earthquake( position );
		}
	}
}
callStrike_artilleryBombEffect( spawnPoint, bombdir, velocity, owner, requiredDeathCount, distance )
{
 	bomb_velocity = vector_scale(anglestoforward(bombdir), velocity);
	bomb = owner launchbomb( "artillery_mp", spawnPoint, bomb_velocity );
	
	bomb.requiredDeathCount = requiredDeathCount;
	
	
	
	airTime = distance / ( velocity * cos( bombdir[0] ) );
	bomb thread referenceCounter();
	
	bombsite = spawnPoint + vector_scale( anglestoforward( (0,bombdir[1],0) ), distance );
	
	bomb thread debug_draw_bomb_path();
}
doArtilleryStrike( owner, requiredDeathCount, bombsite, yaw, distance )
{
	if ( !isDefined( owner ) ) 
		return;
		
	
	fireAngle = ( 0, yaw, 0 );
	firePos = bombsite + vector_scale( anglestoforward( fireAngle ), -1 * distance );
	
	
	
	pitch = GetDvarFloat( #"scr_artilleryAngle");
	if( pitch != 0 )
	{
		pitch *= -1;
	}
	else
	{
		pitch = -75;
	}
	pitch += randomintrange( -3, 3 );
	
	fireAngle += (pitch,0,0);
	
	
	
	gravity = GetDvarInt( #"bg_gravity" );
	velocity = sqrt( (gravity * distance) / sin( -2 * pitch ) );
	thread callStrike_ArtilleryBombEffect( firePos, fireAngle, velocity, owner, requiredDeathCount, distance );
}
artilleryShellshock(type, duration)
{
	if (isdefined(self.beingArtilleryShellshocked) && self.beingArtilleryShellshocked)
		return;
	self.beingArtilleryShellshocked = true;
	
	self shellshock(type, duration);
	wait(duration + 1);
	
	self.beingArtilleryShellshocked = false;
}
radiusArtilleryShellshock(pos, radius, maxduration, minduration, owner )
{
	players = level.players;
	for (i = 0; i < players.size; i++)
	{
		if (!isalive(players[i]))
			continue;
		
		playerpos = players[i].origin + (0,0,32);
		dist = distance(pos, playerpos);
		if (dist < radius) 
		{
			duration = int(maxduration + (minduration-maxduration)*dist/radius);
			
			
			{
				shock = "artilleryblast_enemy";
				players[i] thread artilleryShellshock(shock, duration);
			}
		}
	}
}
artilleryDamageEntsThread()
{
	self notify ( "artilleryDamageEntsThread" );
	self endon ( "artilleryDamageEntsThread" );
	for ( ; level.artilleryDamagedEntsIndex < level.artilleryDamagedEntsCount; level.artilleryDamagedEntsIndex++ )
	{
		if ( !isDefined( level.artilleryDamagedEnts[level.artilleryDamagedEntsIndex] ) )
			continue;
		ent = level.artilleryDamagedEnts[level.artilleryDamagedEntsIndex];
		
		if ( !isDefined( ent.entity ) )
			continue; 
			
		if ( ( !ent.isPlayer && !ent.isActor ) || isAlive( ent.entity ) )
		{
			ent maps\mp\gametypes\_weapons::damageEnt(
				ent.eInflictor, 
				ent.damageOwner, 
				ent.damage, 
				"MOD_PROJECTILE_SPLASH", 
				"artillery_mp", 
				ent.pos, 
				vectornormalize(ent.damageCenter - ent.pos) 
			);			
			level.artilleryDamagedEnts[level.artilleryDamagedEntsIndex] = undefined;
			
			if ( ent.isPlayer || ent.isActor )
				wait ( 0.05 );
		}
		else
		{
			level.artilleryDamagedEnts[level.artilleryDamagedEntsIndex] = undefined;
		}
	}
}
pointIsInArtilleryArea( point, targetpos )
{
	return distance2d( point, targetpos ) <= level.artilleryDangerMaxRadius * 1.25;
}
getSingleArtilleryDanger( point, origin, forward )
{
	center = origin + level.artilleryDangerForwardPush * level.artilleryDangerMaxRadius * forward;
	
	diff = point - center;
	diff = (diff[0], diff[1], 0);
	
	forwardPart = vectorDot( diff, forward ) * forward;
	perpendicularPart = diff - forwardPart;
	
	circlePos = perpendicularPart + forwardPart / level.artilleryDangerOvalScale;
	
	distsq = lengthSquared( circlePos );
	
	if ( distsq > level.artilleryDangerMaxRadius * level.artilleryDangerMaxRadius )
		return 0;
	
	if ( distsq < level.artilleryDangerMinRadius * level.artilleryDangerMinRadius )
		return 1;
	
	dist = sqrt( distsq );
	distFrac = (dist - level.artilleryDangerMinRadius) / (level.artilleryDangerMaxRadius - level.artilleryDangerMinRadius);
	
	assertEx( distFrac >= 0 && distFrac <= 1, distFrac );
	
	return 1 - distFrac;
}
getArtilleryDanger( point )
{
	danger = 0;
	for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
	{
		origin = level.artilleryDangerCenters[i].origin;
		forward = level.artilleryDangerCenters[i].forward;
		
		danger += getSingleArtilleryDanger( point, origin, forward );
	}
	return danger;
}
doArtillery(origin, owner, team, ownerDeathCount )
{	
	self notify( "artillery_status_change", owner );
	trace = bullettrace(origin, origin + (0,0,-1000), false, undefined);
	targetpos = trace["position"];
	
	
	if ( targetpos[2] < origin[2] - 999 )
	{
		if ( isdefined( owner ) )
		{
			targetpos = ( targetpos[0], targetpos[1], owner.origin[2]);
		}
		else
		{
			targetpos = ( targetpos[0], targetpos[1], 0);
		}		
	}
	
	clientNum = -1;
	if ( isdefined ( owner ) )
		clientNum = owner getEntityNumber();
	artilleryiconlocation( targetpos, team, 1, 0, clientNum );
	
	
	uncertaintyRadiusMin = 0;
	uncertaintyRadiusMax = 10;
	targetpos = randPointRadiusAway(targetpos,RandomIntRange(uncertaintyRadiusMin,uncertaintyRadiusMax));
	
	
	yaw = getBestFlakDirection( targetpos, team );
	direction = ( 0, yaw, 0 );
	
	flakDistance = GetDvarFloat( #"scr_artilleryDistance");
	if( flakDistance == 0 )
	{
		flakDistance = 10000;
	}
	flakCenter = targetPos + vector_scale( anglestoforward( direction ), -1 * flakDistance );
	
	if ( level.teambased )
	{
		players = level.players;
		if ( !level.hardcoreMode )
		{
			for(i = 0; i < players.size; i++)
			{
				if(isalive(players[i]) && (isdefined(players[i].team)) && (players[i].team == team)) 
				{
					if ( pointIsInArtilleryArea( players[i].origin, targetpos ) )
						players[i] iprintlnbold(&"MP_WAR_ARTILLERY_INBOUND_NEAR_YOUR_POSITION");
				}
			}
		}
		
		thread maps\mp\gametypes\_battlechatter_mp::onKillstreakUsed( "artillery", level.otherTeam[team] );
		
		thread air_raid_audio();
		
		
		
		
		
		
		
		
		
		
	}
	else
	{
		if ( !level.hardcoreMode )
		{
			if ( pointIsInArtilleryArea( owner.origin, targetpos ) )
				owner iprintlnbold(&"MP_WAR_ARTILLERY_INBOUND_NEAR_YOUR_POSITION");
		}
	}
	
	owner maps\mp\gametypes\_hardpoints::playKillstreakStartDialog( "artillery_mp", team );
	owner maps\mp\gametypes\_persistence::statAdd( "ARTILLERY_USED", 1, false );
	level.globalKillstreaksCalled++;
	self maps\mp\gametypes\_globallogic_score::incItemStatByReference( "killstreak_artillery", 1, "used" );
	if ( !isDefined( owner ) )
	{
		level.artilleryInProgress = undefined;
		level.artilleryShellsInAir = undefined;
		maps\mp\_killstreakrules::killstreakStop( "artillery_mp", team );
		
		self notify( "artillery_status_change", owner );
		return;
	}
	
	owner notify ( "begin_artillery" );
	
	dangerCenter = spawnstruct();
	dangerCenter.origin = targetpos;
	dangerCenter.forward = (0,0,0);
	level.artilleryDangerCenters[ level.artilleryDangerCenters.size ] = dangerCenter;
	danger_influencer_id = maps\mp\gametypes\_spawning::create_artillery_influencers( targetpos, -1 );	
	
	
	
	level.artilleryShellsInAir = level.artilleryCanonCount * level.artilleryCanonShellCount;
	owner thread artilleryImpactEffects( );
	callArtilleryStrike( owner, targetpos, yaw, flakDistance, ownerDeathCount );
	
	max_safety_wait = gettime() + 45000;
	while ( level.artilleryShellsInAir && gettime() < max_safety_wait)
	{
		wait(0.1);
	}
	
	found = false;
	newarray = [];
	for ( i = 0; i < level.artilleryDangerCenters.size; i++ )
	{
		if ( !found && level.artilleryDangerCenters[i].origin == targetpos )
		{
			found = true;
			continue;
		}
		
		newarray[ newarray.size ] = level.artilleryDangerCenters[i];
	}
	assert( found );
	assert( newarray.size == level.artilleryDangerCenters.size - 1 );
	level.artilleryDangerCenters = newarray;
	removeinfluencer( danger_influencer_id );
	
	level.artilleryInProgress = undefined;
	maps\mp\_killstreakrules::killstreakStop( "artillery_mp", team );
	self notify( "artillery_status_change", owner );
}
referenceCounter()
{
	self waittill( "death" );
	
	level.artilleryShellsInAir = level.artilleryShellsInAir - 1;
}
randPointRadiusAway( origin, accuracyRadius )
{
	randVec = ( 0, randomint( 360 ), 0 );
	newPoint = origin + vector_scale( anglestoforward( randVec ), accuracyRadius );
	return newPoint;
}
get_origin_array( from_array )
{
	origins = [];
	
	for ( i = 0; i < from_array.size; i++ )
	{
		origins[origins.size] = from_array[i].origin;
	}
	return origins;
}
closest_point_on_line_to_point( Point, LineStart, LineEnd )
{
	result = spawnstruct();
	
	LineMagSqrd = lengthsquared(LineEnd - LineStart);
 
    t =	( ( ( Point[0] - LineStart[0] ) * ( LineEnd[0] - LineStart[0] ) ) +
				( ( Point[1] - LineStart[1] ) * ( LineEnd[1] - LineStart[1] ) ) +
				( ( Point[2] - LineStart[2] ) * ( LineEnd[2] - LineStart[2] ) ) ) /
				( LineMagSqrd );
 
 	result.t = t;
	start_x = LineStart[0] + t * ( LineEnd[0] - LineStart[0] );
	start_y = LineStart[1] + t * ( LineEnd[1] - LineStart[1] );
	start_z = LineStart[2] + t * ( LineEnd[2] - LineStart[2] );
		
	result.point = (start_x,start_y,start_z);
	result.distsqr = distancesquared( result.point, point );
	
	return result;
}
air_raid_audio()
{
	air_raid_1 = getent( "air_raid_1", "targetname" );
	if(isdefined(air_raid_1))
	{
		air_raid_1 playsound("air_raid_a");
	}
}  
