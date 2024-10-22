
#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	if ( !isdefined( level.ChallengesCallbacks ) )
	{
		level.ChallengesCallbacks = [];
	}		
	
	registerChallengesCallback( "playerKilled", ::challengeKills );	
	registerChallengesCallback( "roundEnd", ::challengeRoundEnd );
	registerChallengesCallback( "gameEnd", ::challengeGameEnd );
	level thread onPlayerConnect();
	initTeamChallenges( "axis" );
	initTeamChallenges( "allies" );
}
canProcessChallenges()
{
	if ( level.rankedMatch || level.wagerMatch  ) 
	{
		return true;
	}
	
	return false;
}
initTeamChallenges( team )
{
	if ( !isdefined( game["challenge"] ) ) 
	{
		game["challenge"] = [];
	}
	
	if ( !isdefined ( game["challenge"][team] ) )
	{
		game["challenge"][team] = [];
		game["challenge"][team]["plantedBomb"] = false;
		game["challenge"][team]["destroyedBombSite"] = false;
		game["challenge"][team]["capturedFlag"] = false;
	}
	game["challenge"][team]["allAlive"] = true;
}
monitorFallDistance()
{
	self endon("disconnect");
	
	while(1)
	{
		if ( !isAlive( self ) )
		{
			self waittill("spawned_player");
			continue;
		}
		
		if ( !self isOnGround() )
		{
			highestPoint = self.origin[2];
			while( !self isOnGround() )
			{
				if ( self.origin[2] > highestPoint )
					highestPoint = self.origin[2];
				wait .05;
			}
			falldist = highestPoint - self.origin[2];
			if ( falldist < 0 )
				falldist = 0;
			
			self maps\mp\gametypes\_persistence::statAdd( "TOTAL_FALL_DISTANCE_FEET", int(falldist/12), false );
			level.globalFeetFallen += falldist/12;
				
			if ( falldist / 12.0 > 15 && isAlive( self ) )
				self maps\mp\gametypes\_persistence::statAdd( "BASIC_FALL_LIVE", 1, false );
				
			if ( falldist / 12.0 > 30 && !isAlive( self ) )
				self maps\mp\gametypes\_persistence::statAdd( "BASIC_FALL_DIE", 1, false );
						
			
		}
		wait .05;
	}
}
fellOffTheMap()
{
	if ( !canProcessChallenges() ) 
		return;	
		
	self maps\mp\gametypes\_persistence::statAdd( "BASIC_FALL_DIE", 1, false );
}
registerChallengesCallback(callback, func)
{
	if (!isdefined(level.ChallengesCallbacks[callback]))
		level.ChallengesCallbacks[callback] = [];
	level.ChallengesCallbacks[callback][level.ChallengesCallbacks[callback].size] = func;
}
doChallengeCallback( callback, data )
{
	if ( !isDefined( level.ChallengesCallbacks ) )
		return;		
			
	if ( !isDefined( level.ChallengesCallbacks[callback] ) )
		return;
	
	if ( isDefined( data ) ) 
	{
		for ( i = 0; i < level.ChallengesCallbacks[callback].size; i++ )
			thread [[level.ChallengesCallbacks[callback][i]]]( data );
	}
	else 
	{
		for ( i = 0; i < level.ChallengesCallbacks[callback].size; i++ )
			thread [[level.ChallengesCallbacks[callback][i]]]();
	}
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );
		player thread initChallengeData();
		player thread dtpWatcher();
		player thread dtpThroughGlassWatcher();
		player thread spawnWatcher();		
		player thread monitorFallDistance();
	}
}
initChallengeData()
{	
	self.pers["bulletStreak"] = 0;
}
challengeKills( data, time )
{
	victim = 		data.victim;
	player = 		data.attacker;
	attacker = 		data.attacker;
	time = 			data.time;
	victim = 		data.victim;
	weapon = 		data.sWeapon;
	time = 			data.time;
	inflictor =		data.eInflictor;
	meansOfDeath = 	data.sMeansOfDeath;
	wasPlanting = 	data.wasPlanting;
	wasDefusing = 	data.wasDefusing;
	
	if ( !canProcessChallenges() ) 
		return;
	if ( !isdefined( data.sWeapon ))
		return;
	
	if ( !isdefined( player ) || !isplayer( player ) )
		return;
		
	player thread checkFinalKillcamKill( weapon, victim, meansOfDeath );
		
	
	if( maps\mp\gametypes\_hardpoints::isKillstreakWeapon( data.sWeapon )  )
	 	return;
		
		
	game["challenge"][victim.team]["allAlive"] = false;
		
	if ( level.teambased ) 
	{
		if ( player.team == victim.team )
			return;
	}
	else 
	{
		if ( player == victim )
			return;
	}
	
	if ( isdefined ( victim.lastTacticalSpawnTime ) && ( victim.lastTacticalSpawnTime + 5000) > time )
	{
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_VICTIM_TACTICAL_INSERTED", 1, false, weapon );
	}
	
	if ( isdefined ( player.lastTacticalSpawnTime ) && ( player.lastTacticalSpawnTime + 5000)  > time )
	{
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_KILLER_TACTICAL_INSERTED1", 1, false, weapon );
	}
	
	if ( level.teambased )
	{
		if ( maps\mp\_radar::teamHasSpyplane( player.team ) ) 
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_U2", 1, false, weapon );
		}
		if ( maps\mp\_radar::teamHasSatellite( player.team ) ) 
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_SATELLITE", 1, false, weapon );
		}
		if ( level.activeCounterUAVs[player.team] > 0 )
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_COUNTER_U2", 1, false, weapon );
		} 
		
	}
	else
	{
		if ( isdefined( player.hasSpyplane) && player.hasSpyplane == true ) 
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_U2", 1, false, weapon );
		}
		if ( isdefined( player.hasSatellite ) && player.hasSatellite == true ) 
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_SATELLITE", 1, false, weapon );
		}
		if ( isdefined( player.entnum ) && isdefined( level.activeCounterUAVs[player.entnum] ) && level.activeCounterUAVs[player.entnum] > 0 ) 
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_KILLS_COUNTER_U2", 1, false, weapon );
		}
	}
	if ( victim maps\mp\_flashgrenades::isFlashbanged() 
	|| ( isdefined( victim.concussionEndTime ) && victim.concussionEndTime > gettime() )
	|| ( isdefined( victim.inPoisonArea ) &&  victim.inPoisonArea ) )
	{
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_STUNNED_PLAYER", 1, false, weapon );		
	}
	
	player notify( "challenge_killed", victim );
	if ( weapon == "hatchet_mp" )
	{
		player notify( "hatchet_kill" );
	}
	else if ( weapon == "knife_ballistic_mp" )
	{
		player notify( "ballistic_knife_kill" );
	}
	
	
	if ( isdefined( player.tookweaponfrom ) && isdefined( player.tookweaponfrom[weapon] ) )
	{
		if ( level.teambased )
		{
			if ( player.tookweaponfrom[weapon].team != player.team )
			{
				player maps\mp\gametypes\_persistence::statAdd( "BASIC_STOLEN_WEAPON_KILLS", 1, false, weapon );
			}
		}
		else
		{
			player maps\mp\gametypes\_persistence::statAdd( "BASIC_STOLEN_WEAPON_KILLS", 1, false, weapon );
		}
		
		
	}
	
	if ( isStrStart( weapon, "frag_" ) || isStrStart( weapon, "sticky_" ))
	{		
		
		if ( isdefined( data.victim.explosiveInfo["originalowner"] ) && isplayer( data.victim.explosiveInfo["originalowner"] ) ) 
		{
			originalOwner = data.victim.explosiveInfo["originalowner"];
			if ( level.teambased ) 
			{
				if ( originalOwner.team != attacker.team ) 
				{
					player maps\mp\gametypes\_persistence::statAdd( "KILLS_THROWBACK", 1, false, weapon );
				}
				
			}
			else
			{
				if( originalOwner != attacker ) 
				{
					player maps\mp\gametypes\_persistence::statAdd( "KILLS_THROWBACK", 1, false, weapon );
				}
			}
		}
		
		if ( isdefined ( data.victim.explosiveInfo["cookedKill"] ) && data.victim.explosiveInfo["cookedKill"] )
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_COOKED", 1, false, weapon );
		}
	}
	if ( ( data.sMeansOfDeath != "MOD_GRENADE" && data.sMeansOfDeath != "MOD_GRENADE_SPLASH" && data.sMeansOfDeath != "MOD_GAS" )
		|| ( weapon != "satchel_charge_mp" && weapon != "sticky_grenade_mp" && weapon != "explosive_bolt_mp" && weapon != "frag_grenade_mp" && weapon != "claymore_mp" && weapon != "tabun_gas_mp" ) )
	{
		if ( data.attackerInLastStand )
		{
		}
		else if ( data.attackerStance == "crouch" )
		{
			player maps\mp\gametypes\_persistence::statAdd( "BASIC_CROUCH_KILLS", 1, false, weapon );
		}
		else if ( data.attackerStance == "prone" )
		{
			player maps\mp\gametypes\_persistence::statAdd( "BASIC_PRONE_KILLS", 1, false, weapon );
		}
	}
	if ( data.sMeansOfDeath == "MOD_HEAD_SHOT" || data.sMeansOfDeath == "MOD_PISTOL_BULLET" || data.sMeansOfDeath == "MOD_RIFLE_BULLET" )
	{
		player genericBulletKill( data, victim, weapon );
	}
		
	if ( level.teamBased )
	{
		if ( level.playerCount[data.victim.pers["team"]] > 3 && player.pers["killed_players"].size >= level.playerCount[data.victim.pers["team"]] )
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_ENTIRE_TEAM", 1, false );
			player.pers["killed_players"] = [];
		}
	}
	
	if ( isHighestScoringPlayer( victim ) && victim.score > 1 )
	{
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_MVP", 1, false, weapon );
	}
	
	if ( weapon == "destructible_car_mp" )
	{
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_CAR", 1, false, weapon );
	}
	
	if ( isdefined( wasDefusing ) && wasDefusing == true )
	{
		switch ( level.gameType )
		{
		case "sab":
			{
				player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_DEFUSER_KILLS", 1, false, weapon );
			}
		break;
		case "sd":
			{
				if ( level.hardcoreMode ) 
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_DEFUSER_KILLS", 1, false, weapon );
				}
				else
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_SD_DEFUSER_KILLS", 1, false, weapon );
				}
			}
			break;
		case "dem":
			{
				player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_DEFUSER_KILLS", 1, false, weapon );
			}
			break;
		}
	}
	
	if ( isdefined( wasPlanting ) && wasPlanting == true )
	{
		switch ( level.gameType )
		{
		case "sab":
			{
				player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_PLANTER_KILLS", 1, false, weapon );
			}
		break;
		case "sd":
			{
				if ( level.hardcoreMode ) 
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_PLANTER_KILLS", 1, false, weapon );
				}
				else
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_SD_PLANTER_KILLS", 1, false, weapon );
				}
			}
			break;
		case "dem":
			{
				player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_PLANTER_KILLS", 1, false, weapon );
			}
			break;
		}
	}
}
genericBulletKill( data, victim, weapon ) 
{
	if ( !canProcessChallenges() ) 
		return;
	player = self;
	time = data.time;
	
	if ( player.pers["lastBulletKillTime"] == time )
		player.pers["bulletStreak"]++;
	else
		player.pers["bulletStreak"] = 1;
	
	player.pers["lastBulletKillTime"] = time;
	if ( player.pers["bulletStreak"] == 2 )
		player maps\mp\gametypes\_persistence::statAdd( "KILLS_BULLET_MULTI", 1, false, weapon );		
	if ( data.victim.iDFlagsTime == time )
	{
		if ( data.victim.iDFlags & level.iDFLAGS_PENETRATION )
			player maps\mp\gametypes\_persistence::statAdd( "BASIC_PENETRATION_KILLS", 1, false, weapon );		
	}
	
}
dtpThroughGlassWatcher()
{
	self endon( "disconnect" );
	while(1)
	{
		self waittill( "dtp_through_glass" );
		self maps\mp\gametypes\_persistence::statAdd( "BASIC_DTP_GLASS", 1, false );
		dtpTime = getTime();
		self thread dtpGlassKills(dtpTime);
	}
}
dtpWatcher()
{
	self endon( "disconnect" );
	while(1)
	{
		self waittill( "dtp_end" );
		dtpTime = getTime();
		self thread dtpKills(dtpTime);
	}
}
dtpKills(mutex)
{
	self endon( "death" );
	self endon( "dtpTimeOut" + mutex );
	self thread DtpKillTimeout( 5, mutex );
	while ( 1 )
	{
		self waittill( "challenge_killed", victim );
		if ( !isdefined( victim ) ) 
			continue;
		if ( level.teambased ) 
		{
			if ( victim.team == self.team ) 
				continue;
		}
		else
		{
			if ( victim == self ) 
				continue;
		}
		self maps\mp\gametypes\_persistence::statAdd( "BASIC_DTP_KILLS", 1, false );
	}
}
DtpKillTimeout( time, mutex )
{
	self endon( "death" );
	wait ( time );
	self notify( "dtpTimeOut" + mutex );
}
dtpGlassKills(mutex)
{
	self endon( "death" );
	self endon( "dtpGlassTimeOut" + mutex );
	self thread DtpGlassKillTimeout( 5, mutex );
	while ( 1 )
	{
		self waittill( "challenge_killed", victim );
		if ( !isdefined( victim ) ) 
			continue;
		if ( level.teambased ) 
		{
			if ( victim.team == self.team ) 
				continue;
		}
		else
		{
			if ( victim == self ) 
				continue;
		}
		self maps\mp\gametypes\_persistence::statAdd( "KILLS_DTP_GLASS", 1, false );
	}
	
}
DtpGlassKillTimeout( time, mutex )
{
	self endon( "death" );
	wait ( time );
	self notify( "dtpGlassTimeOut" + mutex );
}
	
isHighestScoringPlayer( player )
{
	if ( !isDefined( player.score ) || player.score < 1 )
		return false;
	players = level.players;
	if ( level.teamBased )
		team = player.pers["team"];
	else
		team = "all";
	highScore = player.score;
	for( i = 0; i < players.size; i++ )
	{
		if ( !isDefined( players[i].score ) )
			continue;
			
		if ( players[i] == player )
			continue;
		if ( players[i].score < 1 )
			continue;
		if ( team != "all" && players[i].pers["team"] != team )
			continue;
		
		if ( players[i].score >= highScore )
			return false;
	}
	
	return true;
}
spawnWatcher()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("spawned_player");
		self thread watchForBallisticKnifeKills();
		self thread watchForHatchetKills();
	}
}
watchForHatchetKills()
{
	self endon("disconnect");
	self endon("death");
	self.hatchetKills = 0;
	while( self.hatchetKills < 2 )
	{
		self waittill( "hatchet_kill" );
		self.hatchetKills++;
	}
	self maps\mp\gametypes\_persistence::statAdd( "KILLS_HATCHET", 1, false );
}
watchForBallisticKnifeKills()
{
	self endon("disconnect");
	self endon("death");
	self.ballisticKnifeKills = 0;
	while( self.ballisticKnifeKills < 2 )
	{
		self waittill( "ballistic_knife_kill" );
		self.ballisticKnifeKills++;
	}
	self maps\mp\gametypes\_persistence::statAdd( "KILLS_BALLISTIC_KNIFE", 1, false );
}
destroyed_car()
{
	if ( !canProcessChallenges() ) 
		return;
	if ( !isdefined( self ) || !isplayer( self ) )
		return;
	self maps\mp\gametypes\_persistence::statAdd( "BASIC_VANDALISM", 1, false );	
}
challengeRoundEnd( data )
{
	if ( !canProcessChallenges() ) 
		return;
	player = data.player;
	winner = data.winner;
	
		
	if ( endedEarly( winner ) )
		return;
	
	loser = "allies";
	if ( level.teambased ) 
	{
		if ( winner == "allies" )
			loser = "axis";	
	}
	
	switch ( level.gameType )
	{
		case "tdm":
			{
				if ( level.hardcoreMode ) 
				{
					if ( player.team == winner )
					{
						if ( game["teamScores"][winner] >= game["teamScores"][loser] + 2000 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_HCTDM_CRUSH", 1, false );	
						}
						
						if ( game["teamScores"][winner] >= game["teamScores"][loser] + 3000 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_HCTDM_ANNIHILATE", 1, false );	
						}
					}				
				}
				else
				{
					if ( player.team == winner )
					{
						if ( game["teamScores"][winner] >= game["teamScores"][loser] + 2000 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_TDM_CRUSH", 1, false );	
						}
						
						if ( game["teamScores"][winner] >= game["teamScores"][loser] + 3000 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_TDM_ANNIHILATE", 1, false );	
						}
					}
				}
			}
			break;
		case "dm":
			{
				if ( level.hardcoreMode ) 
				{
					if ( player == winner )
					{
						if ( level.placement["all"].size >= 2 )
						{
							secondPlace = level.placement["all"][1];
							if ( player.kills >= ( secondPlace.kills + 7 ) )
							{
								player maps\mp\gametypes\_persistence::statAdd( "GM_HCDM_CRUSH", 1, false );	
							}
							
							if ( player.kills >= ( secondPlace.kills + 12 ) )
							{
								player maps\mp\gametypes\_persistence::statAdd( "GM_HCDM_ANNIHILATE", 1, false );	
							}
						}	
					}
				}
				else
				{
					if ( player == winner )
					{
						if ( level.placement["all"].size >= 2 )
						{
							secondPlace = level.placement["all"][1];
							if ( player.kills >= ( secondPlace.kills + 7 ) )
							{
								player maps\mp\gametypes\_persistence::statAdd( "GM_DM_CRUSH", 1, false );	
							}
							
							if ( player.kills >= ( secondPlace.kills + 12 ) )
							{
								player maps\mp\gametypes\_persistence::statAdd( "GM_DM_ANNIHILATE", 1, false );	
							}
						}	
					}
				}
			}
			break;
		case "sab":
			{
				if ( player.team == winner )
				{	
					if ( data.time <= level.startTime + ( 5 * 60 ) )
						player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_CRUSH", 1, false );	
					if ( data.time <= level.startTime + ( 2 * 60 ) )
						player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_ANNIHILATE", 1, false );	
				}
			}
			break;
		case "sd":
			{
				if ( level.hardcoreMode )
				{
					if ( player.team == winner )
					{
						if ( isdefined( player.lastManSD ) && player.lastManSD == true )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_LAST_MAN_STANDING", 1, false );	
						}
						
						if ( game["challenge"][winner]["allAlive"] ) 
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_SHUT_OUT", 1, false );	
						}	
					}
					
					if ( data.place == 0 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_MVP", 1, false );	
					}
				}
				else
				{
					if ( player.team == winner )
					{
						if ( isdefined( player.lastManSD ) && player.lastManSD == true )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_SD_LAST_MAN_STANDING", 1, false );	
						}
						
						if ( game["challenge"][winner]["allAlive"] ) 
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_SD_SHUT_OUT", 1, false );	
						}	
					}
					
					if ( data.place == 0 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_SD_MVP", 1, false );	
					}
				}
			}
			break;
		case "ctf":
			{
				if ( data.place == 0 )
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_CTF_MVP", 1, false );	
				}
				
				if ( player.team == winner )
				{
					if ( game["teamScores"][loser] == 0 )
					{	
						player maps\mp\gametypes\_persistence::statAdd( "GM_CTF_SHUT_OUT", 1, false );
					}	
				}
			}
			break;
		case "dom":
			{
				if ( player.team == winner )
				{
					if ( game["teamScores"][winner] >= game["teamScores"][loser] + 70 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_DOM_CRUSH", 1, false );	
					}
					
					if ( game["teamScores"][winner] >= game["teamScores"][loser] + 110 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_DOM_ANNIHILATE", 1, false );	
					}
				}	
			}
			break;
		case "koth":
			{
				if ( player.team == winner && game["teamScores"][winner] > 0 )
				{
					if ( game["teamScores"][winner] >= game["teamScores"][loser] + 70 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_KOTH_CRUSH", 1, false );	
					}
					
					if ( game["teamScores"][loser] == 0 )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_KOTH_ANNIHILATE", 1, false );	
					}
				}
			}
			break;
		case "dem":
			{
				if ( data.place == 0 )
				{
					player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_MVP", 1, false );	
				}
				
				if ( player.team == game["defenders"] && player.team == winner )
				{
					if ( game["teamScores"][loser] == 0 )
					{	
						player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_SHUT_OUT", 1, false );
					}	
				}
			}
			break;
		default:
			break;
	}
}
roundEnd( winner )
{
	if ( !canProcessChallenges() ) 
		return;
	wait(0.05);
	data = spawnstruct();
	data.time = getTime();
	if ( level.teamBased )
	{
		if ( isdefined( winner ) && winner == "axis" || winner == "allies" ) 
		{
			data.winner = winner;
		}
	}
	else
	{
		if ( isdefined( winner ) ) 
		{
			data.winner = winner;
		}
	}
	
	
	for ( index = 0; index < level.placement["all"].size; index++ )
	{
		data.player = level.placement["all"][index];
		data.place = index;
		doChallengeCallback( "roundEnd", data );
	}		
}
gameEnd(winner )
{
	if ( !canProcessChallenges() ) 
		return;
	wait(0.05);
	data = spawnstruct();
	data.time = getTime();
	if ( level.teamBased )
	{
		if ( isdefined( winner ) && winner == "axis" || winner == "allies" ) 
		{ 
			data.winner = winner;
		}
	}
	else
	{
		if ( isdefined( winner ) && isplayer( winner) ) 
		{
			data.winner = winner;
		}
	}
	
	
	for ( index = 0; index < level.placement["all"].size; index++ )
	{
		data.player = level.placement["all"][index];
		data.place = index;
		doChallengeCallback( "gameEnd", data );
	}		
}
killedFlagCarrier()
{
	if ( !canProcessChallenges() ) 
		return;
	self maps\mp\gametypes\_persistence::statAdd( "GM_CTF_FLAG_CARRIER_KILLS", 1, false );
}
killedBombCarrier()
{
	if ( !canProcessChallenges() ) 
		return;
	switch ( level.gameType )
	{
			case "sab":
				self maps\mp\gametypes\_persistence::statAdd( "GM_SAB_BOMB_CARRIER_KILLS", 1, false );
				break;
			case "sd":
				{	
					if ( level.hardcoreMode ) 
					{
						self maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_BOMB_CARRIER_KILLS", 1, false );							
					}
					else
					{
						self maps\mp\gametypes\_persistence::statAdd( "GM_SD_BOMB_CARRIER_KILLS", 1, false );
					}
				}
				break;
	}
	
}
dominated( team )
{
	if ( !canProcessChallenges() ) 
		return;
	teamCompletedChallenge( team, "GM_DOM_DOMINATE" );
}
teamCompletedChallenge( team, challenge ) 
{	
	if ( !canProcessChallenges() ) 
		return;
	players = get_players();
	for ( i = 0; i < players.size; i++ )
	{
		if (isdefined( players[i].team ) && players[i].team == team )
		{		
			players[i] maps\mp\gametypes\_persistence::statAdd( challenge, 1, false );
		}
	}	
}
endedEarly( winner )
{
	if ( !canProcessChallenges() ) 
		return;
	if ( level.hostForcedEnd )
		return true;
	
	if ( !isdefined( winner ) ) 
		return true;
	if ( level.teambased ) 
	{	
		if ( winner == "tie" )
			return true;
	}
	return false;
}
challengeGameEnd( data )
{
	if ( !canProcessChallenges() ) 
		return;
	player = data.player;
	winner = data.winner;
	
	if ( endedEarly( winner ) )
		return;
	player maps\mp\gametypes\_persistence::statAdd( "BASIC_COMPLETE_MATCHES_PLAYED", 1, false );
	if ( !level.teambased ) 
		return;
	loser = "allies";
	if ( level.teambased ) 
	{
		if ( winner == "allies" )
			loser = "axis";	
	}
	
	gameLength = game["timepassed"] / 1000;
	roundsWon = maps\mp\_utility::getRoundsWon( winner );
	roundsWonLosers = maps\mp\_utility::getRoundsWon( loser );
	roundsPlayed = maps\mp\_utility::getRoundsPlayed();
	
	winnerScore = game["teamScores"][winner];
	loserScore = game["teamScores"][loser];
	switch ( level.gameType )
	{
		case "ctf":
		{
			if ( player.team == winner )
			{
				if ( game["challenge"][loser]["capturedFlag"] == false )
				{
					if ( roundsPlayed == 2 && roundsWon == 2 ) 
					{
						if ( loserScore == 0 ) 
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_CTF_CRUSH", 1, false );
								
							if ( gameLength <= ( 4 * 60 ) )
							{
								player maps\mp\gametypes\_persistence::statAdd( "GM_CTF_ANNIHILATE", 1, false );
							}
						}
					}
				}
			}
		}
		break;
		case "sab":
		{
			if ( player.team == winner )
			{
				if ( !game["challenge"][loser]["plantedBomb"] )
				{
					if ( gameLength <= ( 5 * 60 ) )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_CRUSH", 1, false );
						
						if ( gameLength <= ( 2 * 60 ) )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_SAB_ANNIHILATE", 1, false );
						}	
					}
				}
			}
		}
		break;
		case "sd":
		{
			if ( player.team == winner )
			{
				if ( roundsWon == 4 && roundsWonLosers <= 1)
				{
					if ( level.hardcoreMode ) 
					{					
						player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_CRUSH", 1, false );
						
						if ( roundsWonLosers == 0 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_HCSD_ANNIHILATE", 1, false );	
						}
					}
					else 
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_SD_CRUSH", 1, false );	
						
						if ( roundsWonLosers == 0 )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_SD_ANNIHILATE", 1, false );	
						}
					}
				}
			}
		}
		break;
		case "dem":
		{
			if ( player.team == winner )
			{
				if ( roundsPlayed == 2 && roundsWon == 2 ) 
				{
					if ( !game["challenge"][loser]["destroyedBombSite"] )
					{
						player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_CRUSH", 1, false );	
						if ( !game["challenge"][loser]["plantedBomb"] )
						{
							player maps\mp\gametypes\_persistence::statAdd( "GM_DEM_ANNIHILATE", 1, false );	
						}
					}
				}
			}
		}	
		break;
		default:
			break;
	}	
}
getGameLength()
{
	if ( !level.timeLimit || level.forcedEnd )
	{
		gameLength = maps\mp\gametypes\_globallogic_utils::getTimePassed() / 1000;		
		
		gameLength = min( gameLength, 1200 );
		
		if ( level.gameType == "twar" && game["roundsplayed"] > 0 )
			gameLength += level.timeLimit * 60;
	}
	else
	{
		gameLength = level.timeLimit * 60;
	}
	
	return gameLength;
}
multiKill( weapon )
{
	if ( !canProcessChallenges() ) 
		return;
	self maps\mp\gametypes\_persistence::statAdd( "BASIC_MULTI_KILLS", 1, false, weapon );
}
fullClipNoMisses( weaponClass, weapon )
{
	if ( !canProcessChallenges() ) 
		return;
	player = self;
	switch( weaponClass )
	{
		case "weapon_pistol":
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_PISTOL", 1, false, weapon );
		}
		break;
		case "weapon_smg":
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_SMG", 1, false, weapon );
		}
		break;
		case "weapon_assault":
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_ASSAULT", 1, false, weapon );
		}
		break;
		case "weapon_lmg":
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_LMG", 1, false, weapon );
		}
		break;
		case "weapon_sniper":
		{
			player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_SNIPER", 1, false, weapon );
		}
		break;
		case "weapon_cqb":
		{
			clipSize = WeaponClipSize(weapon);
			if ( isdefined ( clipSize ) && clipSize == 2 )
			{
				player maps\mp\gametypes\_persistence::statAdd( "KILLS_NO_MISSES_CQB", 1, false, weapon );
			}
		}
		break;
	}
}
checkFinalKillcamKill( weapon, victim, meansOfDeath )
{
	if ( !canProcessChallenges() ) 
		return;
	player = self;
	player endon( "disconnect" );
	player notify( "finalKillCamWaiter" );
	player endon( "finalKillCamWaiter" );
	player waittill( "finalKillCamKiller" );
	
	player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM", 1, false, weapon );
	
	if ( isStrStart( meansOfDeath, "MOD_MELEE" )  )
	{
		vAngles = victim.anglesOnDeath[1];
		pAngles = player.anglesOnKill[1];
		angleDiff = AngleClamp180( vAngles - pAngles );
		if ( abs(angleDiff) < 30 )
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_BACKSTABBER", 1, false, weapon );
		}
	}
	
	switch( weapon )
	{
		case "hatchet_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_HATCHET", 1, false, weapon );
		}
		break;
		case "sticky_grenade_mp":
		{
			if ( isdefined( victim.explosiveInfo["stuckToPlayer"] ) && victim.explosiveInfo["stuckToPlayer"] == victim ) 
			{
				player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_SEMTEX", 1, false, weapon );
			}
		}
		break;
		case "explosive_crossbow_mp":
		case "explosive_bolt_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_STUCK_BOLT", 1, false, weapon );
		}
		break;
		case "knife_ballistic_mp":
		{
			if( IsSubStr( meansOfDeath, "MOD_IMPACT" ) || 
			IsSubStr( meansOfDeath, "MOD_HEAD_SHOT" ) ||
			IsSubStr( meansOfDeath, "MOD_PISTOL_BULLET" ) )
			{
				player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_BALLISTIC_KNIFE", 1, false, weapon );
			}
		}
		break;
		case "satchel_charge_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_C4", 1, false, weapon );
		}
		break;
		case "minigun_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_MINIGUN", 1, false, weapon );
		}
		break;	
		case "supplydrop_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_SUPPLYDROP", 1, false, weapon );
		}
		break;	
		case "rcbomb_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_RCBOMB", 1, false, weapon );
		}
		break;		
		case "auto_gun_turret_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_SENTRY", 1, false, weapon );
		}
		break;			
		case "mortar_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_MORTAR", 1, false, weapon );
		}
		break;		
		case "napalm_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_NAPALM", 1, false, weapon );
		}
		break;		
		case "airstrike_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_AIRSTRIKE", 1, false, weapon );
		}
		break;		
		case "dog_bite_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_DOG", 1, false, weapon );
		}
		break;		
		case "m202_flash_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_M202_FLASH", 1, false, weapon );
		}
		break;		
		case "cobra_20mm_comlink_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_COMLINK", 1, false, weapon );
		}
		break;
		case "hind_rockets_mp":
		case "hind_rockets_firstperson_mp":
		case "hind_minigun_pilot_firstperson_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_GUNSHIP", 1, false, weapon );
		}
		break;		
		case "huey_minigun_gunner_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_CHOPPER_GUNNER", 1, false, weapon );
		}
		break;			
		case "tabun_gas_mp":
		{
			player maps\mp\gametypes\_persistence::statAdd( "FINAL_KILLCAM_GAS", 1, false, weapon );
		}
		break;				
	}
		
}
earnedKillstreak( killstreak )
{
	statNameForKillstreak = "";
	switch( killstreak )
	{
		case "killstreak_spyplane":
			statNameForKillstreak = "KILLSTREAK_EARNED_U2";
		break;
		case "killstreak_supply_drop":
			statNameForKillstreak = "KILLSTREAK_EARNED_SUPPLY_DROP";
		break;
		case "killstreak_auto_turret_drop":
			statNameForKillstreak = "KILLSTREAK_EARNED_SENTRY_GUN";
		break;
		case "killstreak_tow_turret_drop":
			statNameForKillstreak = "KILLSTREAK_EARNED_SAM_TURRET";
		break;
		case "killstreak_mortar":
			statNameForKillstreak = "KILLSTREAK_EARNED_MORTAR";
		break;
		case "killstreak_napalm":
			statNameForKillstreak = "KILLSTREAK_EARNED_NAPALM";
		break;
		case "killstreak_spyplane_direction":
			statNameForKillstreak = "KILLSTREAK_EARNED_SATELLITE";
		break;
		case "killstreak_helicopter_comlink":
			statNameForKillstreak = "KILLSTREAK_EARNED_COMLINK";
		break;
		case "killstreak_helicopter_gunner":
			statNameForKillstreak = "KILLSTREAK_EARNED_CHOPPER_GUNNER";
		break;
		case "killstreak_counteruav":
			statNameForKillstreak = "KILLSTREAK_EARNED_COUNTER_U2";
		break;
		case "killstreak_airstrike":
			statNameForKillstreak = "KILLSTREAK_EARNED_AIRSTRIKE";
		break;
		case "killstreak_helicopter_player_firstperson":
			statNameForKillstreak = "KILLSTREAK_EARNED_GUNSHIP";
		break;
		case "killstreak_dogs":
			statNameForKillstreak = "KILLSTREAK_EARNED_DOGS";
		break;
		case "killstreak_m220_tow_drop":
			statNameForKillstreak = "KILLSTREAK_EARNED_M220";
		break;
		case "killstreak_rcbomb":
			statNameForKillstreak = "KILLSTREAK_EARNED_RCBOMB";
		break;			
	}
	
	if ( statNameForKillstreak != "" )
	{
		self maps\mp\gametypes\_persistence::statAdd( "KILLSTREAK_EARNED", 1, false );
		self maps\mp\gametypes\_persistence::statAdd( statNameForKillstreak, 1, false );
	}
} 
 
  
