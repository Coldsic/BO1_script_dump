#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	level.flareVisionEffectRadius = flare_get_dvar_int( "flare_effect_radius", "400" );
	
	level.flareVisionEffectHeight = flare_get_dvar_int( "flare_effect_height", "65" );
	level.flareDuration = flare_get_dvar_int( "flare_duration", "8"); 
	level.flareDistanceScale = flare_get_dvar_int( "flare_distance_scale", "16"); 
	level.flareLookAwayFadeWait = flare_get_dvar( "flareLookAwayFadeWait", "0.45" );
	level.flareBurnOutFadeWait = flare_get_dvar( "flareBurnOutFadeWait", "0.65" );
	
}
watchFlareDetonation( owner )
{
	
	owner endon("disconnect");
	self waittill( "explode", position, surface );
	
	level.flareVisionEffectRadius = flare_get_dvar_int( "flare_effect_radius", level.flareVisionEffectRadius );
	level.flareVisionEffectHeight = flare_get_dvar_int( "flare_effect_height", level.flareVisionEffectHeight );
	durationOfFlare = flare_get_dvar_int( "flare_duration", level.flareDuration );
	level.flareDistanceScale = flare_get_dvar_int( "flare_distance_scale", level.flareDistanceScale); 
	
	if( IsDefined(surface) && surface == "water" )
	{
		level.flareVisionEffectRadius = int(level.flareVisionEffectRadius * 0.5);
		level.flareVisionEffectHeight = int(level.flareVisionEffectHeight * 0.5);
	}
	
	
	flareEffectArea = spawn("trigger_radius", position, 0, level.flareVisionEffectRadius, level.flareVisionEffectHeight);
	loopWaitTime = .5;
	while (durationOfFlare > 0)
	{
		players = get_players();
		for (i = 0; i < players.size; i++)
		{	
			
			
			if ( !level.hardcoreMode )
			{
				if ( players[i] != owner )				
				{
					if( players[i].team == owner.team )
						continue;
				}
			}
			if (!isDefined(players[i].item))
			{
				players[i].item = 0;
			}	
			if ( ( !isDefined ( players[i].inFlareVisionArea ) )  || ( players[i].inFlareVisionArea == false ) )
			{
				if (players[i].sessionstate == "playing" )
				{
					players[i].item = players[i] playersighttrace( position, level.flareVisionEffectRadius, players[i].item);
					if (players[i].item == 0 || players[i].item == -1 )
					{
						players[i].lastFlaredby = owner;
						
						if ( ! players[i] hasPerk ("specialty_shades") )
						{
							thread flareVision( players[i], flareEffectArea, position );
						}
						players[i] thread maps\mp\gametypes\_battlechatter_mp::incomingSpecialGrenadeTracking( "flare" );
					}
				}	
			}
			
		}
		wait (loopWaitTime);
		durationOfFlare -= loopWaitTime;
	}
	
	flareEffectArea delete();	
}
affectedByFlare( player )
{
	if ( player.sessionstate != "playing" )  
		return false;
	
	if ( player.item != 0 && player.item != -1 )
		return false;
		
	
	
	if ( player IsRemoteControlling() )
		return false;
		
	return true;
}
flareVision( player, flareEffectArea, position )
{
	player endon( "disconnect" );
	player notify( "flareVision" );
	player endon( "flareVision" );
	player.inFlareVisionArea = true;
	
	loopWaitTime = 0.05;
	sightTraceTime = 0.3;
	count = 0;
	maxdistance = level.flareVisionEffectRadius;
	while ( (isdefined (flareEffectArea)) && affectedByFlare( player ) )
	{
		wait( loopWaitTime );
		ratio = 1 - ( ( distance ( player.origin, position ) ) / maxdistance );
		player VisionSetLerpRatio( ratio );
		
		if ( count * loopWaitTime > sightTraceTime )
		{			
			player.item = player playersighttrace( position, level.flareVisionEffectRadius, player.item );
			count = 0;
		}
		count++;
	}
		
	if (! isdefined (flareEffectArea) )
		wait( flare_get_dvar( "flareBurnOutFadeWait", level.flareBurnOutFadeWait ) );
	else if (distance( position, player.origin) < level.flareVisionEffectRadius )
		wait( flare_get_dvar( "flareLookAwayFadeWait", level.flareLookAwayFadeWait ) );
	player.inFlareVisionArea = false;	
	player VisionSetLerpRatio( 0 );
}
flare_get_dvar_int( dvar, def )
{
	return int( flare_get_dvar( dvar, def ) );
}
flare_get_dvar( dvar, def )
{
	if ( getdvar( dvar ) != "" )
	{
		return getdvarfloat( dvar );
	}
	else
	{
		setdvar( dvar, def );
		return def;
	}
}  
