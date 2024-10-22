#include maps\mp\_utility;
getTweakableDVarValue( category, name )
{
	switch( category )
	{
		case "rule":
			dVar = level.rules[name].dVar;
			break;
		case "game":
			dVar = level.gameTweaks[name].dVar;
			break;
		case "team":
			dVar = level.teamTweaks[name].dVar;
			break;
		case "player":
			dVar = level.playerTweaks[name].dVar;
			break;
		case "class":
			dVar = level.classTweaks[name].dVar;
			break;
		case "weapon":
			dVar = level.weaponTweaks[name].dVar;
			break;
		case "killstreak":
			dVar = level.hardpointTweaks[name].dVar;
			break;
		case "hud":
			dVar = level.hudTweaks[name].dVar;
			break;
		default:
			dVar = undefined;
			break;
	}
	
	assert( isDefined( dVar ) );
	
	value = getDvarInt( dVar );
	
	return value;
}
getTweakableDVar( category, name )
{
	switch( category )
	{
		case "rule":
			value = level.rules[name].dVar;
			break;
		case "game":
			value = level.gameTweaks[name].dVar;
			break;
		case "team":
			value = level.teamTweaks[name].dVar;
			break;
		case "player":
			value = level.playerTweaks[name].dVar;
			break;
		case "class":
			value = level.classTweaks[name].dVar;
			break;
		case "weapon":
			value = level.weaponTweaks[name].dVar;
			break;
		case "killstreak":
			value = level.hardpointTweaks[name].dVar;
			break;
		case "hud":
			value = level.hudTweaks[name].dVar;
			break;
		default:
			value = undefined;
			break;
	}
	
	assert( isDefined( value ) );
	return value;
}
getTweakableValue( category, name )
{
	switch( category )
	{
		case "rule":
			value = level.rules[name].value;
			break;
		case "game":
			value = level.gameTweaks[name].value;
			break;
		case "team":
			value = level.teamTweaks[name].value;
			break;
		case "player":
			value = level.playerTweaks[name].value;
			break;
		case "class":
			value = level.classTweaks[name].value;
			break;
		case "weapon":
			value = level.weaponTweaks[name].value;
			break;
		case "killstreak":
			value = level.hardpointTweaks[name].value;
			break;
		case "hud":
			value = level.hudTweaks[name].value;
			break;
		default:
			value = undefined;
			break;
	}
	
	overrideDvar = "scr_" + level.gameType + "_" + category + "_" + name;	
	if ( getDvar( overrideDvar ) != "" )
		return getDvarInt( overrideDvar );
	assert( isDefined( value ) );
	return value;
}
getTweakableLastValue( category, name )
{
	switch( category )
	{
		case "rule":
			value = level.rules[name].lastValue;
			break;
		case "game":
			value = level.gameTweaks[name].lastValue;
			break;
		case "team":
			value = level.teamTweaks[name].lastValue;
			break;
		case "player":
			value = level.playerTweaks[name].lastValue;
			break;
		case "class":
			value = level.classTweaks[name].lastValue;
			break;
		case "weapon":
			value = level.weaponTweaks[name].lastValue;
			break;
		case "killstreak":
			value = level.hardpointTweaks[name].lastValue;
			break;
		case "hud":
			value = level.hudTweaks[name].lastValue;
			break;
		default:
			value = undefined;
			break;
	}
	
	assert( isDefined( value ) );
	return value;
}
setTweakableValue( category, name, value )
{
	switch( category )
	{
		case "rule":
			dVar = level.rules[name].dVar;
			break;
		case "game":
			dVar = level.gameTweaks[name].dVar;
			break;
		case "team":
			dVar = level.teamTweaks[name].dVar;
			break;
		case "player":
			dVar = level.playerTweaks[name].dVar;
			break;
		case "class":
			dVar = level.classTweaks[name].dVar;
			break;
		case "weapon":
			dVar = level.weaponTweaks[name].dVar;
			break;
		case "killstreak":
			dVar = level.hardpointTweaks[name].dVar;
			break;
		case "hud":
			dVar = level.hudTweaks[name].dVar;
			break;
		default:
			dVar = undefined;
			break;
	}
	
	setDvar( dVar, value );
}
setTweakableLastValue( category, name, value )
{
	switch( category )
	{
		case "rule":
			level.rules[name].lastValue = value;
			break;
		case "game":
			level.gameTweaks[name].lastValue = value;
			break;
		case "team":
			level.teamTweaks[name].lastValue = value;
			break;
		case "player":
			level.playerTweaks[name].lastValue = value;
			break;
		case "class":
			level.classTweaks[name].lastValue = value;
			break;
		case "weapon":
			level.weaponTweaks[name].lastValue = value;
			break;
		case "killstreak":
			level.hardpointTweaks[name].lastValue = value;
			break;
		case "hud":
			level.hudTweaks[name].lastValue = value;
			break;
		default:
			break;
	}
}
registerTweakable( category, name, dvar, value )
{
	if ( isString( value ) )
	{
		if( getDvar( dvar ) == "" )
			setDvar( dvar, value );
		else
			value = getDvar( dvar );
	}
	else
	{
		if( getDvar( dvar ) == "" )
			setDvar( dvar, value );
		else
			value = getDvarInt( dvar );
	}
	switch( category )
	{
		case "rule":
			if ( !isDefined( level.rules[name] ) )
				level.rules[name] = spawnStruct();				
			level.rules[name].value = value;
			level.rules[name].lastValue = value;
			level.rules[name].dVar = dvar;
			break;
		case "game":
			if ( !isDefined( level.gameTweaks[name] ) )
				level.gameTweaks[name] = spawnStruct();
			level.gameTweaks[name].value = value;
			level.gameTweaks[name].lastValue = value;			
			level.gameTweaks[name].dVar = dvar;
			break;
		case "team":
			if ( !isDefined( level.teamTweaks[name] ) )
				level.teamTweaks[name] = spawnStruct();
			level.teamTweaks[name].value = value;
			level.teamTweaks[name].lastValue = value;			
			level.teamTweaks[name].dVar = dvar;
			break;
		case "player":
			if ( !isDefined( level.playerTweaks[name] ) )
				level.playerTweaks[name] = spawnStruct();
			level.playerTweaks[name].value = value;
			level.playerTweaks[name].lastValue = value;			
			level.playerTweaks[name].dVar = dvar;
			break;
		case "class":
			if ( !isDefined( level.classTweaks[name] ) )
				level.classTweaks[name] = spawnStruct();
			level.classTweaks[name].value = value;
			level.classTweaks[name].lastValue = value;			
			level.classTweaks[name].dVar = dvar;
			break;
		case "weapon":
			if ( !isDefined( level.weaponTweaks[name] ) )
				level.weaponTweaks[name] = spawnStruct();
			level.weaponTweaks[name].value = value;
			level.weaponTweaks[name].lastValue = value;			
			level.weaponTweaks[name].dVar = dvar;
			break;
		case "killstreak":
			if ( !isDefined( level.hardpointTweaks[name] ) )
				level.hardpointTweaks[name] = spawnStruct();
			level.hardpointTweaks[name].value = value;
			level.hardpointTweaks[name].lastValue = value;			
			level.hardpointTweaks[name].dVar = dvar;
			break;
		case "hud":
			if ( !isDefined( level.hudTweaks[name] ) )
				level.hudTweaks[name] = spawnStruct();
			level.hudTweaks[name].value = value;
			level.hudTweaks[name].lastValue = value;			
			level.hudTweaks[name].dVar = dvar;
			break;
	}
}
init()
{
	level.clientTweakables = [];
	level.tweakablesInitialized = true;
	level.rules = [];
	level.gameTweaks = [];
	level.teamTweaks = [];
	level.playerTweaks = [];
	level.classTweaks = [];
	level.weaponTweaks = [];
	level.hardpointTweaks = [];
	level.hudTweaks = [];
	
	
	registerTweakable( "game", 			"prematchperiod", 			"scr_game_prematchperiod", 			15 ); 
	registerTweakable( "game", 			"onlyheadshots", 		"scr_game_onlyheadshots", 			0 ); 
	registerTweakable( "game", 			"allowkillcam", 		"scr_game_allowkillcam", 			1 ); 
	registerTweakable( "game", 			"allowfinalkillcam", 		"scr_game_allowfinalkillcam", 			1 ); 
	registerTweakable( "game", 			"spectatetype", 		"scr_game_spectatetype", 			2 ); 
	registerTweakable( "game", 			"arcadescoring", 		"scr_game_arcadescoring", 			0 ); 
	registerTweakable( "game", 			"difficulty",	 		"scr_game_difficulty", 				1 ); 
	registerTweakable( "game", 			"pinups",	 			"scr_game_pinups",	 				0 ); 
	registerTweakable( "game", 			"deathpointloss", 		"scr_game_deathpointloss", 			0 ); 
	registerTweakable( "game", 			"suicidepointloss", 	"scr_game_suicidepointloss", 		0 ); 
	registerTweakable( "team", 			"teamkillpointloss", 	"scr_team_teamkillpointloss", 		0 ); 
	registerTweakable( "team", 			"allowHardpointStreakAfterDeath", 	"scr_team_allowHardpointStreakAfterDeath", 		0 ); 
	
	registerTweakable( "team", 			"fftype", 				"scr_team_fftype", 					0 ); 
	registerTweakable( "team", 			"teamkillspawndelay", 	"scr_team_teamkillspawndelay", 		0 );
	registerTweakable( "team", 			"kickteamkillers", 	"scr_team_kickteamkillers", 		0 );
	registerTweakable( "team", 			"teamkillerplaylistbanquantum", 	"scr_team_teamkillerplaylistbanquantum", 		0 );
	registerTweakable( "team", 			"teamkillerplaylistbanpenalty", 	"scr_team_teamkillerplaylistbanpenalty", 		0 );
	registerTweakable( "team", 			"artilleryTeamKillPenalty", 	"scr_team_artilleryTeamKillPenalty", 		0.25 );
	registerTweakable( "team", 			"mortarTeamKillPenalty", 	"scr_team_mortarTeaTeamKillPenalty", 		0.25 );
	
	registerTweakable( "player", 		"maxhealth", 			"scr_player_maxhealth", 			100 ); 
	registerTweakable( "player", 		"healthregentime", 		"scr_player_healthregentime", 		5 ); 
	registerTweakable( "player", 		"forcerespawn", 		"scr_player_forcerespawn", 			1 ); 
	registerTweakable( "player", 		"allowrevive", 		"scr_player_allowrevive", 			1 ); 
	registerTweakable( "weapon", 	"allowfrag", 		"scr_weapon_allowfrags", 1 );
	registerTweakable( "weapon", 	"allowsmoke", 		"scr_weapon_allowsmoke", 1 );
	registerTweakable( "weapon", 	"allowflash", 		"scr_weapon_allowflash", 1 );
	registerTweakable( "weapon", 	"allowc4", 			"scr_weapon_allowc4", 1 );
	registerTweakable( "weapon", 	"allowsatchel", 	"scr_weapon_allowsatchel", 1 );
	registerTweakable( "weapon", 	"allowbetty", 		"scr_weapon_allowbetty", 1 );
	registerTweakable( "weapon", 	"allowrpgs", 		"scr_weapon_allowrpgs", 1 );
	registerTweakable( "weapon", 	"allowmines", 		"scr_weapon_allowmines", 1 );
	registerTweakable( "killstreak", "allowsupply", 		"scr_hardpoint_allowsupply", 1 );
	registerTweakable( "killstreak", "airstrikecount", 			"scr_hardpoint_airstrikecount", 3 );
	registerTweakable( "killstreak", "artilleryCanonCount", 		"scr_hardpoint_artilleryCanonCount", 3 );
	registerTweakable( "killstreak", "artilleryCanonShellCount", "scr_hardpoint_artilleryCanonShellCount", 5 );
    registerTweakable( "killstreak", "mortarCanonCount", 		"scr_hardpoint_mortarCanonCount", 3 );
	registerTweakable( "killstreak", "mortarCanonShellCount", "scr_hardpoint_mortarCanonShellCount", 2 );
	
	registerTweakable( "hud", 		"showobjicons", 	"ui_hud_showobjicons", 						1 ); 
	setClientTweakable( "hud", 		"showobjicons" );
	
	registerTweakable( "killstreak", "allowradar", 				"scr_hardpoint_allowradar", 1 );
	registerTweakable( "killstreak", "allowradartime", 			"scr_hardpoint_allowradartime", 1 );
	registerTweakable( "killstreak", "allowradarupdate", 		"scr_hardpoint_allowradarupdate", 1 );
	registerTweakable( "killstreak", "allowradardirection", 		"scr_hardpoint_allowradardirection", 1 );
	registerTweakable( "killstreak", "allowcounteruav", 		"scr_hardpoint_allowcounteruav", 1 );
	registerTweakable( "killstreak", "allowartillery", 			"scr_hardpoint_allowartillery", 1 );
	registerTweakable( "killstreak", "allowmortar", 				"scr_hardpoint_allowmortar", 1 );
	registerTweakable( "killstreak", "allowairstrike", 			"scr_hardpoint_allowairstrike", 1 );
	registerTweakable( "killstreak", "allowbomber", 			"scr_hardpoint_allowbomber", 1 );
	registerTweakable( "killstreak", "allownapalm", 				"scr_hardpoint_allownapalm", 1 );
	registerTweakable( "killstreak", "allowdogs", 				"scr_hardpoint_allowdogs", 1 );
	registerTweakable( "killstreak", "allowhelicopter", 			"scr_hardpoint_allowhelicopter", 1 );
	registerTweakable( "killstreak", "allowhelicopter_x2", 		"scr_hardpoint_allowhelicopter_x2", 1 );
	registerTweakable( "killstreak", "allowhelicopter_comlink", 	"scr_hardpoint_allowhelicopter_comlink", 1 );
	registerTweakable( "killstreak", "allowrcbomb", 				"scr_hardpoint_allowrcbomb", 1 );
	registerTweakable( "killstreak", "allowauto_turret", 				"scr_hardpoint_allowauto_turret", 1 );
	registerTweakable( "killstreak", "allowhelicopter_player", 	"scr_hardpoint_allowhelicopter_player", 1 );
	registerTweakable( "killstreak", "allowhelicopter_player_firstperson", 	"scr_hardpoint_allowhelicopter_player_firstperson", 1 );
	registerTweakable( "killstreak", "allowhelicopter_gunner", 	"scr_hardpoint_allowhelicopter_gunner", 1 );
	level thread updateUITweakables();
}
setClientTweakable( category, name )
{
	level.clientTweakables[level.clientTweakables.size] = name;
}
updateUITweakables()
{
	for ( ;; )
	{
		for ( index = 0; index < level.clientTweakables.size; index++ )
		{
			clientTweakable = level.clientTweakables[index];
			curValue = getTweakableDVarValue( "hud", clientTweakable );
			lastValue = getTweakableLastValue( "hud", clientTweakable );
			
			if ( curValue != lastValue )
			{
				updateServerDvar( getTweakableDvar( "hud", clientTweakable ), curValue );
				setTweakableLastValue( "hud", clientTweakable, curValue );
			}
		}
			
		wait ( 1.0 );
	}
}
updateServerDvar( dvar, value )
{
	makeDVarServerInfo( dvar, value );
} 
