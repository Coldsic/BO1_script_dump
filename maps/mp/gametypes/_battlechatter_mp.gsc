#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
init()
{
	if ( level.createFX_enabled )
		return;
	
	Assert( IsDefined( level.teamPrefix["allies"] ) );
	Assert( IsDefined( level.teamPostfix["allies"] ) );
	Assert( IsDefined( level.teamPrefix["axis"] ) );
	Assert( IsDefined( level.teamPostfix["axis"] ) );
	
	level.isTeamSpeaking["allies"] = false;
	level.isTeamSpeaking["axis"] = false;
	
	level.speakers["allies"] = [];
	level.speakers["axis"] = [];
	
	level.bcSounds = [];
	level.bcSounds["reload"] = "inform_reloading";
	level.bcSounds["frag_out"] = "inform_attack_grenade";
	level.bcSounds["smoke_out"] = "inform_attack_smoke";
	level.bcSounds["conc_out"] = "inform_attack_stun";
	level.bcSounds["satchel_plant"] = "inform_attack_throwsatchel";
	level.bcSounds["kill"] = "inform_kill";
	level.bcSounds["casualty"] = "inform_casualty_gen";
	level.bcSounds["flare_out"] = "inform_attack_flare";
	level.bcSounds["gas_out"] = "inform_attack_gas";
	level.bcSounds["betty_plant"] = "inform_plant";
	level.bcSounds["landmark"] = "landmark";
	level.bcSounds["taunt"] = "taunt";
	level.bcSounds["killstreak_enemy"] = "kls_enemy";
	level.bcSounds["killstreak_taunt"] = "taunt_kls";
	level.bcSounds["kill_killstreak"] = "kill_killstreak";
	level.bcSounds["destructible"] = "destructible_near";
	level.bcSounds["teammate"] = "teammate_near";
	level.bcSounds["grenade_incoming"] = "inform_incoming";
	level.bcSounds["gametype"] = "gametype";
	level.bcSounds["squad"] = "squad";
	level.bcSounds["enemy"] = "threat";
	level.bcSounds["sniper"] = "sniper";
	level.bcSounds["gametype"] = "gametype";
	level.bcSounds["perk"] = "perk_equip";
	level.bcSounds["pain"] = "pain";
	level.bcSounds["death"] = "death";
	level.bcSounds["breathing"] = "breathing";
	level.bcSounds["inform_attack"] = "inform_attack";
	level.bcSounds["inform_need"] = "inform_need";	
	level.bcSounds["revive"] = "revive";
	level.bcSounds["scream"] = "scream";
	level.bcSounds["fire"] = "fire";
	
	setdvar ( "bcmp_weapon_delay", "2000" );				
	setdvar ( "bcmp_weapon_fire_probability", "80" );		
	setdvar ( "bcmp_weapon_reload_probability", "60" );
	setdvar ( "bcmp_weapon_fire_threat_probability", "80" );
	setdvar ( "bcmp_sniper_kill_probability", "20" );
	setdvar ( "bcmp_ally_kill_probability", "60" );	
	setdvar ( "bcmp_killstreak_incoming_probability", "100" );
	setdvar ( "bcmp_perk_call_probability", "100" );
	setdvar ( "bcmp_incoming_grenade_probability", "5" ); 
	setdvar ( "bcmp_toss_grenade_probability", "20" ); 
	setdvar ( "bcmp_kill_inform_probability", "40" );
	setdvar ( "bcmp_pain_small_probability", "0" );
	setdvar ( "bcmp_breathing_probability", "0" );	
	setdvar ( "bcmp_pain_delay", ".5" );	
	setdvar ( "bcmp_last_stand_delay", "3");
	setdvar ( "bcmp_breathing_delay", "3");
	setdvar ( "bcmp_enemy_contact_delay", "30");
	setdvar ( "bcmp_enemy_contact_level_delay", "15");	
	level.bcWeaponDelay = GetDvarInt( #"bcmp_weapon_delay" );
	level.bcWeaponFireProbability = GetDvarInt( #"bcmp_weapon_fire_probability" );
	level.bcWeaponReloadProbability = GetDvarInt( #"bcmp_weapon_reload_probability" );	
	level.bcWeaponFireThreatProbability = GetDvarInt( #"bcmp_weapon_fire_threat_probability" );	
	level.bcSniperKillProbability = GetDvarInt( #"bcmp_sniper_kill_probability" );
	level.bcAllyKillProbability = GetDvarInt( #"bcmp_ally_kill_probability" );
	level.bcKillstreakIncomingProbability = GetDvarInt( #"bcmp_killstreak_incoming_probability" );
	level.bcPerkCallProbability = GetDvarInt( #"bcmp_perk_call_probability" );
	level.bcIncomingGrenadeProbability = GetDvarInt( #"bcmp_incoming_grenade_probability" );
	level.bcTossGrenadeProbability = GetDvarInt( #"bcmp_toss_grenade_probability" );
	level.bcKillInformProbability = GetDvarInt( #"bcmp_kill_inform_probability" );
	level.bcPainSmallProbability = GetDvarInt( #"bcmp_pain_small_probability" );
	level.bcPainDelay = GetDvarInt( #"bcmp_pain_delay" );	
	level.bcLastStandDelay = GetDvarInt ( #"bcmp_last_stand_delay" );
	level.bcmp_breathing_delay = GetDvarInt ( #"bcmp_breathing_delay" );	
	level.bcmp_enemy_contact_delay = GetDvarInt ( #"bcmp_enemy_contact_delay" );		
	level.bcmp_enemy_contact_level_delay = GetDvarInt ( #"bcmp_enemy_contact_level_delay" );			
	level.bcmp_breathing_probability = GetDvarInt( #"bcmp_breathing_probability" );
	level.bcGlobalProbability = GetDvarInt( #"scr_"+level.gametype+"_globalbattlechatterprobability" );
	level.allowBattleChatter = GetDvarInt( #"scr_allowbattlechatter" );
	level.landmarks = getentarray ("trigger_landmark", "targetname");
	level.enemySpottedDialog = true;
	level thread enemyContactLevelDelay();
	level thread onPlayerConnect();	
	level thread UpdateBCDvars();
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill ( "connecting", player );
		player thread onJoinedTeam();		
		player thread onPlayerSpawned();
	}
}
UpdateBCDvars()
{
	level endon( "game_ended" );
	for(;;)
	{
		level.bcWeaponDelay = getdvarint ( "bcmp_weapon_delay" );
		level.bcKillInformProbability = getdvarint ( "bcmp_kill_inform_probability" );
		level.bcWeaponFireProbability = getdvarint ( "bcmp_weapon_fire_probability" );
		level.bcSniperKillProbability = getdvarint ( "bcmp_sniper_kill_probability" );
		level thread maps\mp\gametypes\_globallogic::updateTeamStatus();
		wait( 2.0 );
	}
}
onJoinedTeam()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "joined_team" );
		self.pers["bcVoiceNumber"] = randomIntRange( 0, 3 );
	}
}
onJoinedSpectators()
{
	self endon( "disconnect" );
	
	for(;;)
	{
		self waittill( "joined_spectators" );
	}
}
onPlayerSpawned()
{
	self endon( "disconnect" );
	for(;;)
	{
		self waittill( "spawned_player" );
		self.lastBCAttemptTime = 0;
		self.heartbeatsnd = false; 
		
		self.bcVoiceNumber = self.pers["bcVoiceNumber"];
		
		
		if ( level.splitscreen )
			continue;
		
		self thread reloadTracking();
		self thread grenadeTracking();
		
		self thread enemyThreat();		
		self thread StickyGrenadeTracking();
		self thread painVox();
		self thread allyRevive();		
		
		self thread breathingHurtVox();		
		self thread breathingBetterVox();	
		self thread onFireScream();
		self thread deathVox();												
	}
}
enemyContactLevelDelay()
{
	while (1)
	{
		level waittill ( "level_enemy_spotted");
		level.enemySpottedDialog = false;
		wait (level.bcmp_enemy_contact_level_delay);
		level.enemySpottedDialog = true;
	}	
}	
breathingHurtVox()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	
	for( ;; )
	{
		self waittill ( "snd_breathing_hurt" );		
		
		if( randomIntRange( 0, 100 ) >= level.bcmp_breathing_probability )
		{	  		
			wait (.5);
			if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "breathing", "hurt", false, true );
	
		}
		wait (level.bcmp_breathing_delay);
	
	}	
}
onFireScream()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	
	for( ;; )
	{
		self waittill ( "snd_burn_scream" );		
		
		if( randomIntRange( 0, 100 ) >= level.bcmp_breathing_probability )
		{	  		
			wait (.5);
			if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "fire", "scream" );
		}
		wait (level.bcmp_breathing_delay);
	
	}	
}		
breathingBetterVox()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	
	
	for( ;; )
	{
		self waittill ( "snd_breathing_better" );		
		
		if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "breathing", "better", false, true );
		
		
	
	}	
}	
lastStandVox()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	self waittill ( "snd_last_stand" );
	
	for( ;; )
	{
		
		
		
		
		self waittill ( "weapon_fired" );		
		
		if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "perk", "laststand" );
		
		wait (level.bcLastStandDelay);
	
	}	
}	
allyRevive()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	for( ;; )
	{
		
		self waittill ( "snd_ally_revive" );
		if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "inform_attack", "revive" );
		
		wait (level.bcLastStandDelay);
	
	}	
}	
painVox ()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	for( ;; )
	{
		
		self waittill ( "snd_pain_player" );
		if( randomIntRange( 0, 100 ) >= level.bcPainSmallProbability )
		{
			if ( IsAlive( self ) )
					level thread mpSayLocalSound( self, "pain", "small" );
		}
		
		wait (level.bcPainDelay);
	
	}
}
deathVox ()
{
	self endon ( "disconnect" );	
	self waittill ( "death" );
	
	
	
	if( self.team != "spectator" )
	{
		soundAlias = level.teamPrefix[self.team] + "_" + self.bcVoiceNumber + "_" + level.bcSounds["pain"] + "_" + "death";
		self thread doSound( soundAlias );
	}
	
}		
StickyGrenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "sticky_explode" );
	for( ;; )
	{
		self waittill ( "grenade_stuck", grenade );
		if ( IsDefined( grenade ) )
		{
			grenade.stuckToPlayer = self;
		}
		if ( IsAlive( self ) )
				level thread mpSayLocalSound( self, "grenade_incoming", "sticky" );
		self notify( "sticky_explode" );
	}
}
onPlayerSuicideOrTeamKill( player, type )
{
	self endon ("disconnect");
	
	
	waittillframeend;
	if( !level.teamBased )
		return;
	
	myTeam = player.team;
	if( level.alivePlayers[myTeam].size )
	{
		index = CheckDistanceToEvent( player, 1000 * 1000 );
		if( isDefined( index ) )
		{
			
			wait( 1.0 );
			if ( IsAlive( level.alivePlayers[myTeam][index] ) )
				level thread mpSayLocalSound( level.alivePlayers[myTeam][index], "teammate", type );
		}
	}
}
onPlayerKillstreak( player )
{
	player endon ("disconnect");
	
}
onKillstreakUsed( killstreak, team )
{
	
}
onPlayerNearExplodable( object,  type )
{
	self endon ( "disconnect" );
	self endon ( "explosion_started" );
}
shoeboxTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	while(1)
	{
		self waittill( "begin_firing" );
		weaponName = self getCurrentWeapon();
		if ( weaponName == "mine_shoebox_mp" )
			level thread mpSayLocalSound( self, "satchel_plant", "shoebox" );
	}
}
reloadTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	for( ;; )
	{
		self waittill ( "reload_start" );
		
		if( randomIntRange( 0, 100 ) >= level.bcWeaponReloadProbability )
		{
			level thread mpSayLocalSound( self, "reload", "gen" );
		}
	}
}
perkSpecificBattleChatter( type, checkDistance )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "perk_done" );
}
enemyThreat()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	
	for( ;; )
	{
		self waittill ( "weapon_fired" );
		
		if (level.enemySpottedDialog)		
		{
			
			if( getTime() - self.lastBCAttemptTime > level.bcmp_enemy_contact_delay )
			{
	
				
				shooter = self;
				myTeam = self.team;
				enemyTeam = getOtherTeam( myTeam );	
				keys = getarraykeys( level.squads[enemyTeam] );
				
				closest_enemy = shooter get_closest_player_enemy();
				
				self.lastBCAttemptTime = getTime();
				
				if (isdefined (closest_enemy))
				{
					if( randomIntRange( 0, 100 ) >= level.bcWeaponFireThreatProbability )
					{
						
						area = 600 * 600;
		
						if ( DistanceSquared( closest_enemy.origin, self.origin ) < area )
						{
							
							level thread mpSayLocalSound( closest_enemy, "enemy", "infantry", false );
							level notify ( "level_enemy_spotted");
						}			
					}	
				}
			}
		}
	}
}	
weaponFired()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	for( ;; )
	{
		self waittill ( "weapon_fired" );
		
		if( getTime() - self.lastBCAttemptTime > level.bcWeaponDelay )
		{
			self.lastBCAttemptTime = getTime();
			
			if( randomIntRange( 0, 100 ) >= level.bcWeaponFireProbability )
			{
				
				self.landmarkEnt = self getLandmark();
				if( isdefined (self.landmarkEnt) )
				{
					myTeam = self.team;
					enemyTeam = getOtherTeam( myTeam );
					
					keys = getarraykeys( level.squads[enemyTeam] );
					
					for( i = 0; i < keys.size; i++ )
					{
						if( level.squads[enemyTeam][keys[i]].size )
						{
							index = randomIntRange( 0, level.squads[enemyTeam][keys[i]].size );
;
							level thread mpSayLocalSound( level.squads[enemyTeam][keys[i]][index], "enemy", "infantry" );
						}
					}
				}
			}
		}
	}
}
KilledBySniper( sniper )
{
	self endon("disconnect");
	sniper endon("disconnect");
	
	
	waittillframeend;
	
	victim = self;
	
	if ( level.hardcoreMode || !level.teamBased )
		return;
		
	
	if( randomIntRange( 0, 100 ) >= level.bcSniperKillProbability )
	{
		sniperTeam = sniper.team;
		victimTeam = getOtherTeam( sniperTeam );
		index = CheckDistanceToEvent( victim, 1000 * 1000 );
		if( isDefined( index ) )
		{
			level thread mpSayLocalSound( level.alivePlayers[victimTeam][index], "enemy", "sniper", false );
		}
	}
}
PlayerKilled(attacker)
{
	self endon("disconnect");
	
	if (!isplayer (attacker))
	{
		return;
	}
	
	waittillframeend;
	
	victim = self;
	
	
	if ( level.hardcoreMode )
		return;
		
	
	if( randomIntRange( 0, 100 ) >= level.bcAllyKillProbability )
	{
		
		attackerTeam = attacker.team;
		victimTeam = getOtherTeam( attackerTeam );
		closest_ally = victim get_closest_player_ally();
		
		area = 1000 * 1000;
		if (isdefined (closest_ally))
		{
			if ( DistanceSquared( closest_ally.origin, self.origin ) < area )		
			{
				
				level thread mpSayLocalSound( closest_ally, "inform_need", "medic", false );
    	}
	}	
	}
}
grenadeTracking()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	for( ;; )
	{
		self waittill ( "grenade_fire", grenade, weaponName );
		if ( weaponName == "frag_grenade_mp" )
		{
			
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
			{
				
				level thread mpSayLocalSound( self, "inform_attack", "grenade" );
			}
			level thread incomingGrenadeTracking( self, grenade, "grenade" );
		}
		
		else if ( weaponName == "c4_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "c4" );
		}
		else if ( weaponName == "claymore_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "claymore" );
		}
		else if ( weaponName == "flash_grenade_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "flash" );
		}
		
		else if ( weaponName == "sticky_grenade_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "sticky" );
		}
		else if ( weaponName == "tabun_gas_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "gas" );
		}
					
		else if ( weaponName == "willy_pete_mp" )
		{
			if( randomIntRange( 0, 100 ) >= level.bcTossGrenadeProbability )
				level thread mpSayLocalSound( self, "inform_attack", "smoke" );
		}	
			
	}
}
incomingGrenadeTracking( thrower, grenade, type )
{
	
	
	{
		
		wait( 1.0 );
		
		if( !isDefined( thrower ) )
		{
			return;
		}
		
		if(thrower.team == "spectator")
		{
			return;
		}
		enemyTeam = thrower.team;
		if( level.teamBased )
			myTeam = getOtherTeam( enemyTeam );
		else
			myTeam = undefined;
		if( ( !level.teamBased && level.players.size ) || level.alivePlayers[myTeam].size )
		{
			player = CheckDistanceToObject( 500 * 500, grenade, myTeam, thrower );
			if( isDefined( player ) )
			{
				
				level thread mpSayLocalSound( player, "grenade_incoming", type );
			}
		}
	}
}
incomingSpecialGrenadeTracking( type )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "grenade_ended" );
	for(;;)
	{
		
		if( randomIntRange( 0, 100 ) >= level.bcIncomingGrenadeProbability )
		{
			if( level.alivePlayers[self.team].size || (!level.teamBased && level.players.size) )
			{
				level thread mpSayLocalSound(  self, "grenade_incoming", type );
				self notify( "grenade_ended" );
			}
		}
		wait( 3.0 );
	}
}
gametypeSpecificBattleChatter( event, team )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon ( "event_ended" );
	for(;;)
	{
		if( isDefined( team ) )
		{
			index = CheckDistanceToEvent( self, 300 * 300 );
			if( isDefined( index ) )
			{
				level thread mpSayLocalSound( level.alivePlayers[team][index], "gametype", event );
				self notify( "event_ended" );
			}
		}
		else
		{
			index = randomIntRange( 0, level.alivePlayers["allies"].size );
			level thread mpSayLocalSound( level.alivePlayers["allies"][index], "gametype", event );
			index = randomIntRange( 0, level.alivePlayers["axis"].size );
			level thread mpSayLocalSound( level.alivePlayers["axis"][index], "gametype", event );
		}
		wait( 1.0 );
	}
}
sayLocalSoundDelayed( player, soundType1, soundType2, delay )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	wait ( delay );
	
	mpSayLocalSound( player, soundType1, soundType2 );
}
sayLocalSound( player, soundType )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	if ( isSpeakerInRange( player ) )
		return;
		
	if( player.team != "spectator" )
	{
		soundAlias = level.teamPrefix[player.team] + "_" + player.bcVoiceNumber + "_" + level.bcSounds[soundType];
		
	}
}
mpSayLocalSound( player, partOne, partTwo, checkSpeakers, is2d )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	if( level.players.size <= 1 )
		return;
		if( !isDefined( checkSpeakers ) )
		{
			if ( isSpeakerInRange( player ) )
			{
				
 				return;
			}	
		}
 
	if ( player HasPerk( "Specialty_loudenemies" ) )
	{
		
		return;
	}
	
			
	if( player.team != "spectator" )
	{
		soundAlias = level.teamPrefix[player.team] + "_" + player.bcVoiceNumber + "_" + level.bcSounds[partOne] + "_" + partTwo;
		if (isdefined(is2d))
		{
			player thread doSound( soundAlias, is2d );
			
		}
		else
		{
			player thread doSound( soundAlias );
			
		}	
	}
}
mpSayLocationalLocalSound( player, prefix, partOne, partTwo )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	if( level.players.size <= 1 )
		return;
	if ( isSpeakerInRange( player ) )
		return;
		
	if( player.team != "spectator" )
	{
		soundAlias1 = level.teamPrefix[player.team] + "_" + player.bcVoiceNumber + "_" + level.bcSounds[prefix];
		soundAlias2 = level.teamPrefix[player.team] + "_" + player.bcVoiceNumber + "_" + level.bcSounds[partOne] + "_" + partTwo;
		player thread doLocationalSound( soundAlias1, soundAlias2 );
	}
}
doSound( soundAlias, is2d  )
{
	team = self.team;
	level addSpeaker( self, team );
	
	if (isdefined(is2d))
	{
		self playLocalSound(soundAlias);
	}	
	else if ( level.allowBattleChatter && randomIntRange( 0, 100 ) >= level.bcGlobalProbability )
	{	
		self playSoundToTeam( soundAlias, team );
	}	
	
	self thread timeHack( soundAlias ); 
	self waittill_any( soundAlias, "death", "disconnect" );
	level removeSpeaker( self, team );
}
doLocationalSound( soundAlias1, soundAlias2 )
{
	team = self.team;
	level addSpeaker( self, team );
	if( level.allowBattleChatter && randomIntRange( 0, 100 ) >= level.bcGlobalProbability )
	{
		self playBattleChatterToTeam( soundAlias1, soundAlias2, team, self );
	}
	self thread timeHack( soundAlias1 ); 
	self waittill_any( soundAlias1, "death", "disconnect" );
	level removeSpeaker( self, team );
}
timeHack( soundAlias )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	wait ( 1.0 );
	self notify ( soundAlias );
}
isSpeakerInRange( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	distSq = 1000 * 1000;
	
	if( isdefined( player ) && isdefined( player.team ) && player.team != "spectator" )
	{
		for ( index = 0; index < level.speakers[player.team].size; index++ )
		{
			teammate = level.speakers[player.team][index];
			if ( teammate == player )
				return true;
				
			if ( distancesquared( teammate.origin, player.origin ) < distSq )
				return true;
		}
	}
	return false;
}
addSpeaker( player, team )
{
	level.speakers[team][level.speakers[team].size] = player;
}
removeSpeaker( player, team )
{
	newSpeakers = [];
	for ( index = 0; index < level.speakers[team].size; index++ )
	{
		if ( level.speakers[team][index] == player )
			continue;
			
		newSpeakers[newSpeakers.size] = level.speakers[team][index]; 
	}
	
	level.speakers[team] = newSpeakers;
}
getLandmark()
{
	landmarks = level.landmarks;
	for (i = 0; i < landmarks.size; i++)
	{
		if (self istouching (landmarks[i]) && isdefined (landmarks[i].script_landmark))
			return (landmarks[i]);
	}
	return (undefined);
}
CheckDistanceToEvent( player, area )
{
	if ( !isDefined( player ) )
		return undefined;
		
	for ( index = 0; index < level.alivePlayers[player.team].size; index++ )
	{
		teammate = level.alivePlayers[player.team][index];
		if ( !isDefined( teammate ) )
			continue;
			
		if( teammate == player )
			continue;
		if ( DistanceSquared( teammate.origin, player.origin ) < area )
			return index;
	}
}
CheckDistanceToEnemy( enemy, area, team )
{
	if ( !isDefined( enemy ) )
		return undefined;
		
	for ( index = 0; index < level.alivePlayers[team].size; index++ )
	{
		player = level.alivePlayers[team][index];
		if ( DistanceSquared( enemy.origin, player.origin ) < area )
				return index;
	}
}
CheckDistanceToObject( area, object, team, ignoreEnt )
{
	if( isDefined( team ) )
	{
		for( i = 0; i < level.alivePlayers[team].size; i++ )
		{
			player = level.alivePlayers[team][i];
			if( isDefined(ignoreEnt) && player == ignoreEnt )
				continue;
			 if ( isDefined( object ) && distancesquared( player.origin, object.origin ) < area )
				 return player;
		}
	}
	else
	{
		for( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			
			if( isDefined(ignoreEnt) && player == ignoreEnt )
				continue;
			if( isAlive( player ) )
			{
				 if ( isDefined( object ) && distancesquared( player.origin, object.origin ) < area )
					 return player;
			}
		}
	}
}
get_closest_player_enemy()
{
  enemies = [];
  players = get_players();
  myteam = self.pers[ "team" ];
  for ( i = 0; i < players.size; i++ )
  {
	  player = players[i];
	
	  if ( !IsDefined( player ) || !IsAlive( player ) )
	  {
      continue;
	  }
	
	  if ( player.sessionstate != "playing" )
	  {
      continue;
	  }
	
	  if ( player == self )
	  {
      continue;
}
	
	  if ( level.teambased )
	  {
	    if ( myteam == player.team )
	    {
        continue;
	    }
	  }
	
	  enemies[ enemies.size ] = player;
  }
  if ( enemies.size <= 0 )
  {
		return undefined;
  }
  closest_enemy = getClosest( self.origin, enemies );
  return closest_enemy;
}
get_closest_player_ally()
{
  allies = [];
  players = get_players();
  myteam = self.pers[ "team" ];
	enemyTeam = getOtherTeam( myTeam );	  
  for ( i = 0; i < players.size; i++ )
  {
	  player = players[i];
	
	  if ( !IsDefined( player ) || !IsAlive( player ) )
	  {
      continue;
	  }
	
	  if ( player.sessionstate != "playing" )
	  {
      continue;
	  }
	
	  if ( player == self )
	  {
      continue;
}
	
	  if ( level.teambased )
	  {
	    if ( enemyTeam == player.team )
	    {
        continue;
	    }
	  }
	
	  allies[ allies.size ] = player;
  }
  if ( allies.size <= 0 )
  {
		return undefined;
  }
  closest_ally = getClosest( self.origin, allies );
  return closest_ally;
}