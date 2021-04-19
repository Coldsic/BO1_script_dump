#include common_scripts\utility;
#include maps\mp\_utility;
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
	}
}
findBoxCenter( mins, maxs )
{
	center = ( 0, 0, 0 );
	center = maxs - mins;
	center = ( center[0]/2, center[1]/2, center[2]/2 ) + mins;
	return center;
}
expandMins( mins, point )
{
	if ( mins[0] > point[0] )
		mins = ( point[0], mins[1], mins[2] );
	if ( mins[1] > point[1] )
		mins = ( mins[0], point[1], mins[2] );
	if ( mins[2] > point[2] )
		mins = ( mins[0], mins[1], point[2] );
	return mins;
}
expandMaxs( maxs, point )
{
	if ( maxs[0] < point[0] )
		maxs = ( point[0], maxs[1], maxs[2] );
	if ( maxs[1] < point[1] )
		maxs = ( maxs[0], point[1], maxs[2] );
	if ( maxs[2] < point[2] )
		maxs = ( maxs[0], maxs[1], point[2] );
	return maxs;
}
addSpawnPointsInternal( team, spawnPointName )
{	
	oldSpawnPoints = [];
	if ( level.teamSpawnPoints[team].size )
		oldSpawnPoints = level.teamSpawnPoints[team];
	
	level.teamSpawnPoints[team] = getSpawnpointArray( spawnPointName );
	
	if ( !isDefined( level.spawnpoints ) )
		level.spawnpoints = [];
	
	for ( index = 0; index < level.teamSpawnPoints[team].size; index++ )
	{
		spawnpoint = level.teamSpawnPoints[team][index];
		
		if ( !isdefined( spawnpoint.inited ) )
		{
			spawnpoint spawnPointInit();
			level.spawnpoints[ level.spawnpoints.size ] = spawnpoint;
		}
	}
	
	for ( index = 0; index < oldSpawnPoints.size; index++ )
	{
		origin = oldSpawnPoints[index].origin;
		
		
		level.spawnMins = expandMins( level.spawnMins, origin );
		level.spawnMaxs = expandMaxs( level.spawnMaxs, origin );
		
		level.teamSpawnPoints[team][ level.teamSpawnPoints[team].size ] = oldSpawnPoints[index];
	}
	
	if ( !level.teamSpawnPoints[team].size )
	{
		println( "^1No " + spawnPointName + " spawnpoints found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		wait 1; 
		return;
	}
}
clearSpawnPoints()
{
	level.teamSpawnPoints["allies"] = [];
	level.teamSpawnPoints["axis"] = [];
	level.spawnpoints = [];
	level.unified_spawn_points = undefined;
}
addSpawnPoints( team, spawnPointName )
{
	addSpawnPointClassName( spawnPointName );
	addSpawnPointTeamClassName( team, spawnPointName );
	
	addSpawnPointsInternal( team, spawnPointName );
}
rebuildSpawnPoints( team )
{
	level.teamSpawnPoints[team] = [];
	
	for ( index = 0; index < level.spawn_point_team_class_names[team].size; index++ )
	{
		addSpawnPointsInternal( team, level.spawn_point_team_class_names[team][index] );
	}
}
placeSpawnPoints( spawnPointName )
{
	addSpawnPointClassName( spawnPointName );
	spawnPoints = getSpawnpointArray( spawnPointName );
	
	
	
	if ( !spawnPoints.size )
	{
		println( "^1No " + spawnPointName + " spawnpoints found in level!" );
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		wait 1; 
		return;
	}
	
	for( index = 0; index < spawnPoints.size; index++ )
	{
		spawnPoints[index] spawnPointInit();
		
		
		
		
	}
}
dropSpawnPoints( spawnPointName )
{
		spawnPoints = getSpawnpointArray( spawnPointName );
	if ( !spawnPoints.size )
	{
		println( "^1No " + spawnPointName + " spawnpoints found in level!" );
		return;
	}
	
	for( index = 0; index < spawnPoints.size; index++ )
	{
		spawnPoints[index] placeSpawnpoint();
	}
}
addSpawnPointClassName( spawnPointClassName )
{
	if ( !IsDefined( level.spawn_point_class_names ) )
	{
		level.spawn_point_class_names = [];
	}
	
	level.spawn_point_class_names[ level.spawn_point_class_names.size ] = spawnPointClassName;
}
	
addSpawnPointTeamClassName( team, spawnPointClassName )
{
	level.spawn_point_team_class_names[team][ level.spawn_point_team_class_names[team].size ] = spawnPointClassName;
}
getSpawnpointArray( classname )
{
	spawnPoints = getEntArray( classname, "classname" );
	
	if ( !isdefined( level.extraspawnpoints ) || !isdefined( level.extraspawnpoints[classname] ) )
		return spawnPoints;
	
	for ( i = 0; i < level.extraspawnpoints[classname].size; i++ )
	{
		spawnPoints[ spawnPoints.size ] = level.extraspawnpoints[classname][i];
	}
	
	return spawnPoints;
}
spawnPointInit()
{
	spawnpoint = self;
	origin = spawnpoint.origin;
	
	
	
	if ( !level.spawnMinsMaxsPrimed )
	{
		level.spawnMins = origin;
		level.spawnMaxs = origin;
		level.spawnMinsMaxsPrimed = true;
	}
	else
	{
		level.spawnMins = expandMins( level.spawnMins, origin );
		level.spawnMaxs = expandMaxs( level.spawnMaxs, origin );
	}
	
	spawnpoint placeSpawnpoint();
	spawnpoint.forward = anglesToForward( spawnpoint.angles );
	spawnpoint.sightTracePoint = spawnpoint.origin + (0,0,50);
	
	
	
	spawnpoint.inited = true;
}
getTeamSpawnPoints( team )
{
	return level.teamSpawnPoints[team];
}
getSpawnpoint_Final( spawnpoints, useweights )
{
	
	
	bestspawnpoint = undefined;
	
	if ( !isdefined( spawnpoints ) || spawnpoints.size == 0 )
		return undefined;
	
	if ( !isdefined( useweights ) )
		useweights = true;
	
	if ( useweights )
	{
		
		
		bestspawnpoint = getBestWeightedSpawnpoint( spawnpoints );
		thread spawnWeightDebug( spawnpoints );
	}
	else
	{
		
		
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if( isdefined( self.lastspawnpoint ) && self.lastspawnpoint == spawnpoints[i] )
				continue;
			
			if ( positionWouldTelefrag( spawnpoints[i].origin ) )
				continue;
			
			bestspawnpoint = spawnpoints[i];
			break;
		}
		if ( !isdefined( bestspawnpoint ) )
		{
			
			
			if ( isdefined( self.lastspawnpoint ) && !positionWouldTelefrag( self.lastspawnpoint.origin ) )
			{
				
				for ( i = 0; i < spawnpoints.size; i++ )
				{
					if ( spawnpoints[i] == self.lastspawnpoint )
					{
						bestspawnpoint = spawnpoints[i];
						break;
					}
				}
			}
		}
	}
	
	if ( !isdefined( bestspawnpoint ) )
	{
		
		if ( useweights )
		{
			
			bestspawnpoint = spawnpoints[randomint(spawnpoints.size)];
		}
		else
		{
			bestspawnpoint = spawnpoints[0];
		}
	}
	
	self finalizeSpawnpointChoice( bestspawnpoint );
	
	
	
	
	return bestspawnpoint;
}
finalizeSpawnpointChoice( spawnpoint )
{
	time = getTime();
	
	self.lastspawnpoint = spawnpoint;
	self.lastspawntime = time;
	spawnpoint.lastspawnedplayer = self;
	spawnpoint.lastspawntime = time;
}
getBestWeightedSpawnpoint( spawnpoints )
{
	maxSightTracedSpawnpoints = 3;
	for ( try = 0; try <= maxSightTracedSpawnpoints; try++ )
	{
		bestspawnpoints = [];
		bestweight = undefined;
		bestspawnpoint = undefined;
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined( bestweight ) || spawnpoints[i].weight > bestweight ) 
			{
				if ( positionWouldTelefrag( spawnpoints[i].origin ) )
					continue;
				
				bestspawnpoints = [];
				bestspawnpoints[0] = spawnpoints[i];
				bestweight = spawnpoints[i].weight;
			}
			else if ( spawnpoints[i].weight == bestweight ) 
			{
				if ( positionWouldTelefrag( spawnpoints[i].origin ) )
					continue;
				
				bestspawnpoints[bestspawnpoints.size] = spawnpoints[i];
			}
		}
		if ( bestspawnpoints.size == 0 )
			return undefined;
		
		
		bestspawnpoint = bestspawnpoints[randomint( bestspawnpoints.size )];
		
		if ( try == maxSightTracedSpawnpoints )
			return bestspawnpoint;
		
		if ( isdefined( bestspawnpoint.lastSightTraceTime ) && bestspawnpoint.lastSightTraceTime == gettime() )
			return bestspawnpoint;
		
		if ( !lastMinuteSightTraces( bestspawnpoint ) )
			return bestspawnpoint;
		
		penalty = getLosPenalty();
		
		bestspawnpoint.weight -= penalty;
		
		bestspawnpoint.lastSightTraceTime = gettime();
	}
}
getSpawnpoint_Random(spawnpoints)
{
	
	if(!isdefined(spawnpoints))
		return undefined;
	
	for(i = 0; i < spawnpoints.size; i++)
	{
		j = randomInt(spawnpoints.size);
		spawnpoint = spawnpoints[i];
		spawnpoints[i] = spawnpoints[j];
		spawnpoints[j] = spawnpoint;
	}
	
	return getSpawnpoint_Final(spawnpoints, false);
}
getAllOtherPlayers()
{
	aliveplayers = [];
	
	for(i = 0; i < level.players.size; i++)
	{
		if ( !isdefined( level.players[i] ) )
			continue;
		player = level.players[i];
		
		if ( player.sessionstate != "playing" || player == self )
			continue;
		aliveplayers[aliveplayers.size] = player;
	}
	return aliveplayers;
}
getAllAlliedAndEnemyPlayers( obj )
{
	if ( level.teambased )
	{
		if ( self.pers["team"] == "allies" )
		{
			obj.allies = level.alivePlayers["allies"];
			obj.enemies = level.alivePlayers["axis"];
		}
		else
		{
			assert( self.pers["team"] == "axis" );
			obj.allies = level.alivePlayers["axis"];
			obj.enemies = level.alivePlayers["allies"];
		}
	}
	else
	{
		obj.allies = [];
		obj.enemies = level.activePlayers;
	}
}
initWeights(spawnpoints)
{
	for (i = 0; i < spawnpoints.size; i++)
		spawnpoints[i].weight = 0;
	
	
}
getSpawnpoint_NearTeam( spawnpoints, favoredspawnpoints )
{
	
	
	
	if(!isdefined(spawnpoints))
		return undefined;
	
	
		
	
	
	if ( GetDvarInt( #"scr_spawnsimple") > 0 )
		return getSpawnpoint_Random( spawnpoints );
	
	Spawnlogic_Begin();
	
	k_favored_spawn_point_bonus= 25000;
	
	initWeights(spawnpoints);
	
	
	obj = spawnstruct();
	getAllAlliedAndEnemyPlayers(obj);
	
	
	numplayers = obj.allies.size + obj.enemies.size;
	
	alliedDistanceWeight = 2;
	
	
	myTeam = self.pers["team"];
	enemyTeam = getOtherTeam( myTeam );
	for (i = 0; i < spawnpoints.size; i++)
	{
		spawnpoint = spawnpoints[i];
		
		if (!IsDefined(spawnpoint.numPlayersAtLastUpdate))
		{
			spawnpoint.numPlayersAtLastUpdate= 0;
		}
		
		if ( spawnpoint.numPlayersAtLastUpdate > 0 )
		{
			allyDistSum = spawnpoint.distSum[ myTeam ];
			enemyDistSum = spawnpoint.distSum[ enemyTeam ];
			
			
			spawnpoint.weight = (enemyDistSum - alliedDistanceWeight*allyDistSum) / spawnpoint.numPlayersAtLastUpdate;
			
			
		}
		else
		{
			spawnpoint.weight = 0;
			
		}
	}
	
	
	if (IsDefined(favoredspawnpoints))
	{
		for (i= 0; i < favoredspawnpoints.size; i++)
		{
			if (IsDefined(favoredspawnpoints[i].weight))
			{
				favoredspawnpoints[i].weight+= k_favored_spawn_point_bonus;
			}
			else
			{
				favoredspawnpoints[i].weight= k_favored_spawn_point_bonus;
			}
		}
	}
	
	
	
	avoidSameSpawn(spawnpoints);
	avoidSpawnReuse(spawnpoints, true);
	
	
	avoidWeaponDamage(spawnpoints);
	avoidVisibleEnemies(spawnpoints, true);
	
	
	result = getSpawnpoint_Final(spawnpoints);
	
	
	
	return result;
}
getSpawnpoint_DM(spawnpoints)
{
	
	
	
	if(!isdefined(spawnpoints))
		return undefined;
	
	Spawnlogic_Begin();
	initWeights(spawnpoints);
	
	aliveplayers = getAllOtherPlayers();
	
	
	
	idealDist = 1600;
	badDist = 1200;
	
	if (aliveplayers.size > 0)
	{
		for (i = 0; i < spawnpoints.size; i++)
		{
			totalDistFromIdeal = 0;
			nearbyBadAmount = 0;
			for (j = 0; j < aliveplayers.size; j++)
			{
				dist = distance(spawnpoints[i].origin, aliveplayers[j].origin);
				
				if (dist < badDist)
					nearbyBadAmount += (badDist - dist) / badDist;
				
				distfromideal = abs(dist - idealDist);
				totalDistFromIdeal += distfromideal;
			}
			avgDistFromIdeal = totalDistFromIdeal / aliveplayers.size;
			
			wellDistancedAmount = (idealDist - avgDistFromIdeal) / idealDist;
			
			
			
			
			
			
			spawnpoints[i].weight = wellDistancedAmount - nearbyBadAmount * 2 + randomfloat(.2);
		}
	}
	
	avoidSameSpawn(spawnpoints);
	avoidSpawnReuse(spawnpoints, false);
	
	avoidWeaponDamage(spawnpoints);
	avoidVisibleEnemies(spawnpoints, false);
	
	return getSpawnpoint_Final(spawnpoints);
}
Spawnlogic_Begin()
{
	
	
}
init()
{
	
	
	level.spawnlogic_deaths = [];
	
	level.spawnlogic_spawnkills = [];
	level.players = [];
	level.grenades = [];
	level.pipebombs = [];
	level thread onPlayerConnect();
	level thread trackGrenades();
	
	level.spawnMins = (0,0,0);
	level.spawnMaxs = (0,0,0);
	level.spawnMinsMaxsPrimed = false;	
	if ( isdefined( level.safespawns ) )
	{
		for( i = 0; i < level.safespawns.size; i++ )
		{
			level.safespawns[i] spawnPointInit();
		}
	}
	
	if ( GetDvar( #"scr_spawn_enemyavoiddist") == "" )
		setdvar("scr_spawn_enemyavoiddist", "800");
	if ( GetDvar( #"scr_spawn_enemyavoidweight") == "" )
		setdvar("scr_spawn_enemyavoidweight", "0");
	
	
	
}
showDeathsDebug()
{
	while(1)
	{
		if (GetDvar( #"scr_spawnpointdebug") == "0") {
			wait(3);
			continue;
		}
		time = getTime();
		
		for (i = 0; i < level.spawnlogic_deaths.size; i++)
		{
			if (isdefined(level.spawnlogic_deaths[i].los))
				line(level.spawnlogic_deaths[i].org, level.spawnlogic_deaths[i].killOrg, (1,0,0)); 
			else
				line(level.spawnlogic_deaths[i].org, level.spawnlogic_deaths[i].killOrg, (1,1,1));
			killer = level.spawnlogic_deaths[i].killer;
			if (isdefined(killer) && isalive(killer))
				line(level.spawnlogic_deaths[i].killOrg, killer.origin, (.4,.4,.8));
		}
		
		for (p = 0; p < level.players.size; p++)
		{
			if ( !isdefined( level.players[p] ) )
				continue;
			if (isdefined(level.players[p].spawnlogic_killdist))
				print3d(level.players[p].origin + (0,0,64), level.players[p].spawnlogic_killdist, (1,1,1));
		}
		
		oldspawnkills = level.spawnlogic_spawnkills;
		level.spawnlogic_spawnkills = [];
		for (i = 0; i < oldspawnkills.size; i++)
		{
			spawnkill = oldspawnkills[i];
			
			
			
			if (spawnkill.dierwasspawner) {
				line(spawnkill.spawnpointorigin, spawnkill.dierorigin, (.4,.5,.4));
				line(spawnkill.dierorigin, spawnkill.killerorigin, (0,1,1));
				print3d(spawnkill.dierorigin + (0,0,32), "SPAWNKILLED!", (0,1,1));
			}
			else {
				line(spawnkill.spawnpointorigin, spawnkill.killerorigin, (.4,.5,.4));
				line(spawnkill.killerorigin, spawnkill.dierorigin, (0,1,1));
				print3d(spawnkill.dierorigin + (0,0,32), "SPAWNDIED!", (0,1,1));
			}
			
			if (time - spawnkill.time < 60*1000)
				level.spawnlogic_spawnkills[level.spawnlogic_spawnkills.size] = oldspawnkills[i];
		}
		wait(.05);
	}
}
updateDeathInfoDebug()
{
	while(1)
	{
		if (GetDvar( #"scr_spawnpointdebug") == "0") {
			wait(3);
			continue;
		}
		updateDeathInfo();
		wait(3);
	}
}
spawnWeightDebug(spawnpoints)
{
	level notify("stop_spawn_weight_debug");
	level endon("stop_spawn_weight_debug");
	while(1)
	{
		if (GetDvar( #"scr_spawnpointdebug") == "0") {
			wait(3);
			continue;
		}
		textoffset = (0,0,-12);
		for (i = 0; i < spawnpoints.size; i++)
		{
			amnt = 1 * (1 - spawnpoints[i].weight / (-100000));
			if (amnt < 0) amnt = 0;
			if (amnt > 1) amnt = 1;
			
			orig = spawnpoints[i].origin + (0,0,80);
			
			print3d(orig, int(spawnpoints[i].weight), (1,amnt,.5));
			orig += textoffset;
			
			if (isdefined(spawnpoints[i].spawnData))
			{
				for (j = 0; j < spawnpoints[i].spawnData.size; j++)
				{
					print3d(orig, spawnpoints[i].spawnData[j], (.5,.5,.5));
					orig += textoffset;
				}
			}
			if (isdefined(spawnpoints[i].sightChecks))
			{
				for (j = 0; j < spawnpoints[i].sightChecks.size; j++)
				{
					if ( spawnpoints[i].sightChecks[j].penalty == 0 )
						continue;
					print3d(orig, "Sight to enemy: -" + spawnpoints[i].sightChecks[j].penalty, (.5,.5,.5));
					orig += textoffset;
				}
			}
		}
		wait(.05);
	}
}
profileDebug()
{
	while(1)
	{
		if (GetDvar( #"scr_spawnpointprofile") != "1") {
			wait(3);
			continue;
		}
		
		for (i = 0; i < level.spawnpoints.size; i++)
			level.spawnpoints[i].weight = randomint(10000);
		if (level.players.size > 0)
			level.players[randomint(level.players.size)] getSpawnpoint_NearTeam(level.spawnpoints);
		
		wait(.05);
	}
}
debugNearbyPlayers(players, origin)
{
	if (GetDvar( #"scr_spawnpointdebug") == "0") {
		return;
	}
	starttime = gettime();
	while(1)
	{
		for (i = 0; i < players.size; i++)
			line(players[i].origin, origin, (.5,1,.5));
		if (gettime() - starttime > 5000)
			return;
		wait .05;
	}
}
deathOccured(dier, killer)
{
	
}
checkForSimilarDeaths(deathInfo)
{
	
	for (i = 0; i < level.spawnlogic_deaths.size; i++)
	{
		if (level.spawnlogic_deaths[i].killer == deathInfo.killer)
		{
			dist = distance(level.spawnlogic_deaths[i].org, deathInfo.org);
			if (dist > 200) continue;
			dist = distance(level.spawnlogic_deaths[i].killOrg, deathInfo.killOrg);
			if (dist > 200) continue;
			
			level.spawnlogic_deaths[i].remove = true;
		}
	}
}
updateDeathInfo()
{
	
	
	time = getTime();
	for (i = 0; i < level.spawnlogic_deaths.size; i++)
	{
		
		deathInfo = level.spawnlogic_deaths[i];
		
		if (time - deathInfo.time > 1000*90 || 
			!isdefined(deathInfo.killer) ||
			!isalive(deathInfo.killer) ||
			(deathInfo.killer.pers["team"] != "axis" && deathInfo.killer.pers["team"] != "allies") ||
			distance(deathInfo.killer.origin, deathInfo.killOrg) > 400) {
			level.spawnlogic_deaths[i].remove = true;
		}
	}
	
	
	oldarray = level.spawnlogic_deaths;
	level.spawnlogic_deaths = [];
	
	
	start = 0;
	if (oldarray.size - 1024 > 0) start = oldarray.size - 1024;
	
	for (i = start; i < oldarray.size; i++)
	{
		if (!isdefined(oldarray[i].remove))
			level.spawnlogic_deaths[level.spawnlogic_deaths.size] = oldarray[i];
	}
	
}
trackGrenades()
{
	while ( 1 )
	{
		level.grenades = getentarray("grenade", "classname");
		wait .05;
	}
}
isPointVulnerable(playerorigin)
{
	pos = self.origin + level.bettymodelcenteroffset;
	playerpos = playerorigin + (0,0,32);
	distsqrd = distancesquared(pos, playerpos);
	
	forward = anglestoforward(self.angles);
	
	if (distsqrd < level.bettyDetectionRadius*level.bettyDetectionRadius)
	{
		playerdir = vectornormalize(playerpos - pos);
		angle = acos(vectordot(playerdir, forward));
		if (angle < level.bettyDetectionConeAngle) {
			return true;
		}
	}
	return false;
}
avoidWeaponDamage(spawnpoints)
{
	if (GetDvar( #"scr_spawnpointnewlogic") == "0") 
	{
		return;
	}
	
	
	weaponDamagePenalty = 100000;
	if (GetDvar( #"scr_spawnpointweaponpenalty") != "" && GetDvar( #"scr_spawnpointweaponpenalty") != "0")
		weaponDamagePenalty = GetDvarFloat( #"scr_spawnpointweaponpenalty");
	mingrenadedistsquared = 250*250; 
	for (i = 0; i < spawnpoints.size; i++)
	{
		for (j = 0; j < level.grenades.size; j++)
		{
			if ( !isdefined( level.grenades[j] ) )
				continue;
			
			if (distancesquared(spawnpoints[i].origin, level.grenades[j].origin) < mingrenadedistsquared)
			{
				spawnpoints[i].weight -= weaponDamagePenalty;
				
			}
		}
		
		if ( !isDefined( level.artilleryDangerCenters ) )
			continue;
		
		airstrikeDanger = maps\mp\_artillery::getArtilleryDanger( spawnpoints[i].origin ); 
		
		if ( airstrikeDanger > 0 )
		{
			worsen = airstrikeDanger * weaponDamagePenalty;
			spawnpoints[i].weight -= worsen;
			
		}
	}
	
}
spawnPerFrameUpdate()
{
	spawnpointindex = 0;
		
	
	
	while(1)
	{
		wait .05;
		
		
		
		
		
		if ( !isDefined( level.spawnPoints ) )
			return;
		
		spawnpointindex = (spawnpointindex + 1) % level.spawnPoints.size;
		spawnpoint = level.spawnPoints[spawnpointindex];
		
		spawnPointUpdate( spawnpoint );
		
		
	}
}
spawnPointUpdate( spawnpoint )
{
		if ( level.teambased )
		{
			spawnpoint.sights["axis"] = 0;
			spawnpoint.sights["allies"] = 0;
			
			spawnpoint.nearbyPlayers["axis"] = [];
			spawnpoint.nearbyPlayers["allies"] = [];
		}
		else
		{
			spawnpoint.sights = 0;
			
			spawnpoint.nearbyPlayers["all"] = [];
		}
		
		spawnpointdir = spawnpoint.forward;
		
	debug = false;
		
		
		spawnpoint.distSum["all"] = 0;
		spawnpoint.distSum["allies"] = 0;
		spawnpoint.distSum["axis"] = 0;
		
	spawnpoint.minDist["all"] = 9999999;
	spawnpoint.minDist["allies"] = 9999999;
	spawnpoint.minDist["axis"] = 9999999;
	
		spawnpoint.numPlayersAtLastUpdate = 0;
		
		for (i = 0; i < level.players.size; i++)
		{
			player = level.players[i];
			
			if ( player.sessionstate != "playing" )
				continue;
			
			diff = player.origin - spawnpoint.origin;
		diff = (diff[0], diff[1], 0);
			dist = length( diff ); 
			
			team = "all";
			if ( level.teambased )
				team = player.pers["team"];
			
			if ( dist < 1024 )
			{
				spawnpoint.nearbyPlayers[team][spawnpoint.nearbyPlayers[team].size] = player;
			}
			
		if ( dist < spawnpoint.minDist[team] )
			spawnpoint.minDist[team] = dist;
		
			spawnpoint.distSum[ team ] += dist;
			spawnpoint.numPlayersAtLastUpdate++;
			
			pdir = anglestoforward(player.angles);
			if (vectordot(spawnpointdir, diff) < 0 && vectordot(pdir, diff) > 0)
				continue; 
			
			
			losExists = bullettracepassed(player.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined);
			
			spawnpoint.lastSightTraceTime = gettime();
			
			if (losExists)
			{
				if ( level.teamBased )
					spawnpoint.sights[player.pers["team"]]++;
				else
					spawnpoint.sights++;
				
				
				
				
				
				
				
			}
			
			
		}
}
getLosPenalty()
{
	if (GetDvar( #"scr_spawnpointlospenalty") != "" && GetDvar( #"scr_spawnpointlospenalty") != "0")
		return GetDvarFloat( #"scr_spawnpointlospenalty");
	return 100000;
}
lastMinuteSightTraces( spawnpoint )
{
	
	
	team = "all";
	if ( level.teambased )
		team = getOtherTeam( self.pers["team"] );
	
	if ( !isdefined( spawnpoint.nearbyPlayers ) )
		return false;
	
	closest = undefined;
	closestDistsq = undefined;
	secondClosest = undefined;
	secondClosestDistsq = undefined;
	for ( i = 0; i < spawnpoint.nearbyPlayers[team].size; i++ )
	{
		player = spawnpoint.nearbyPlayers[team][i];
		
		if ( !isdefined( player ) )
			continue;
		if ( player.sessionstate != "playing" )
			continue;
		if ( player == self )
			continue;
		
		distsq = distanceSquared( spawnpoint.origin, player.origin );
		if ( !isdefined( closest ) || distsq < closestDistsq )
		{
			secondClosest = closest;
			secondClosestDistsq = closestDistsq;
			
			closest = player;
			closestDistSq = distsq;
		}
		else if ( !isdefined( secondClosest ) || distsq < secondClosestDistSq )
		{
			secondClosest = player;
			secondClosestDistSq = distsq;
		}
	}
	
	if ( isdefined( closest ) )
	{
		if ( bullettracepassed( closest.origin       + (0,0,50), spawnpoint.sightTracePoint, false, undefined) )
			return true;
	}
	if ( isdefined( secondClosest ) )
	{
		if ( bullettracepassed( secondClosest.origin + (0,0,50), spawnpoint.sightTracePoint, false, undefined) )
			return true;
	}
	
	return false;
}
avoidVisibleEnemies(spawnpoints, teambased)
{
	if (GetDvar( #"scr_spawnpointnewlogic") == "0") 
	{
		return;
	}
	
	
	
	lospenalty = getLosPenalty();
	
	otherteam = "axis";
	if ( self.pers["team"] == "axis" )
		otherteam = "allies";
	minDistTeam = otherteam;
	
	if ( teambased )
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined(spawnpoints[i].sights) )
				continue;
			
			penalty = lospenalty * spawnpoints[i].sights[otherteam];
			spawnpoints[i].weight -= penalty;
			
			
		}
	}
	else
	{
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			if ( !isdefined(spawnpoints[i].sights) )
				continue;
			penalty = lospenalty * spawnpoints[i].sights;
			spawnpoints[i].weight -= penalty;
			
		}
		
		minDistTeam = "all";
	}
	
	avoidWeight = GetDvarFloat( #"scr_spawn_enemyavoidweight");
	if ( avoidWeight != 0 )
	{
		nearbyEnemyOuterRange = GetDvarFloat( #"scr_spawn_enemyavoiddist");
		nearbyEnemyOuterRangeSq = nearbyEnemyOuterRange * nearbyEnemyOuterRange;
		nearbyEnemyPenalty = 1500 * avoidWeight; 
		nearbyEnemyMinorPenalty = 800 * avoidWeight; 
		
		lastAttackerOrigin = (-99999,-99999,-99999);
		lastDeathPos = (-99999,-99999,-99999);
		if ( isAlive( self.lastAttacker ) )
			lastAttackerOrigin = self.lastAttacker.origin;
		if ( isDefined( self.lastDeathPos ) )
			lastDeathPos = self.lastDeathPos;
		
		for ( i = 0; i < spawnpoints.size; i++ )
		{
			
			mindist = spawnpoints[i].minDist[minDistTeam];
			if ( mindist < nearbyEnemyOuterRange*2 )
			{
				penalty = nearbyEnemyMinorPenalty * (1 - mindist / (nearbyEnemyOuterRange*2));
				if ( mindist < nearbyEnemyOuterRange )
					penalty += nearbyEnemyPenalty * (1 - mindist / nearbyEnemyOuterRange);
				if ( penalty > 0 )
				{
					spawnpoints[i].weight -= penalty;
					
				}
			}
			
			
			
			
		}
	}
				
	
	
}
avoidSpawnReuse(spawnpoints, teambased)
{
	
	if (GetDvar( #"scr_spawnpointnewlogic") == "0") {
		return;
	}
	
	
	time = getTime();
	
	maxtime = 10*1000;
	maxdistSq = 1024 * 1024;
	for (i = 0; i < spawnpoints.size; i++)
	{
		spawnpoint = spawnpoints[i];
		
		if (!isdefined(spawnpoint.lastspawnedplayer) || !isdefined(spawnpoint.lastspawntime) ||
			!isalive(spawnpoint.lastspawnedplayer))
			continue;
		if (spawnpoint.lastspawnedplayer == self) 
			continue;
		if (teambased && spawnpoint.lastspawnedplayer.pers["team"] == self.pers["team"]) 
			continue;
		
		timepassed = time - spawnpoint.lastspawntime;
		if (timepassed < maxtime)
		{
			distSq = distanceSquared(spawnpoint.lastspawnedplayer.origin, spawnpoint.origin);
			if (distSq < maxdistSq)
			{
				worsen = 5000 * (1 - distSq/maxdistSq) * (1 - timepassed/maxtime);
				spawnpoint.weight -= worsen;
				
			}
			else
				spawnpoint.lastspawnedplayer = undefined; 
		}
		else
			spawnpoint.lastspawnedplayer = undefined; 
	}
	
}
avoidSameSpawn(spawnpoints)
{
	
	if (GetDvar( #"scr_spawnpointnewlogic") == "0") {
		return;
	}
	
	
	if (!isdefined(self.lastspawnpoint))
		return;
	
	for (i = 0; i < spawnpoints.size; i++)
	{
		if (spawnpoints[i] == self.lastspawnpoint) 
		{
			spawnpoints[i].weight -= 50000; 
			
			break;
		}
	}
	
	
}
getRandomIntermissionPoint()
{
		spawnpoints = getentarray("mp_global_intermission", "classname");
		assert( spawnpoints.size );
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	
		return spawnpoint;
}