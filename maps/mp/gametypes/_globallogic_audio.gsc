#include maps\mp\_utility;
init()
{
		game["music"]["defeat"] = "mus_defeat";
		game["music"]["victory_spectator"] = "mus_defeat";
		game["music"]["winning"] = "mus_time_running_out_winning";
		game["music"]["losing"] = "mus_time_running_out_losing";
		game["music"]["match_end"] = "mus_match_end";
		game["music"]["victory_tie"] = "mus_defeat";
		
		game["music"]["suspense"] = [];
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_01";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_02";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_03";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_04";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_05";
		game["music"]["suspense"][game["music"]["suspense"].size] = "mus_suspense_06";
		game["dialog"]["mission_success"] = "mission_success";
		game["dialog"]["mission_failure"] = "mission_fail";
		game["dialog"]["mission_draw"] = "draw";
		game["dialog"]["round_success"] = "encourage_win";
		game["dialog"]["round_failure"] = "encourage_lost";
		game["dialog"]["round_draw"] = "draw";
		
		
		game["dialog"]["timesup"] = "timesup";
		game["dialog"]["winning"] = "winning";
		game["dialog"]["losing"] = "losing";
		game["dialog"]["min_draw"] = "min_draw";
		game["dialog"]["lead_lost"] = "lead_lost";
		game["dialog"]["lead_tied"] = "tied";
		game["dialog"]["lead_taken"] = "lead_taken";
		game["dialog"]["last_alive"] = "lastalive";
		game["dialog"]["boost"] = "generic_boost";
		if ( !isDefined( game["dialog"]["offense_obj"] ) )
			game["dialog"]["offense_obj"] = "generic_boost";
		if ( !isDefined( game["dialog"]["defense_obj"] ) )
			game["dialog"]["defense_obj"] = "generic_boost";
		
		game["dialog"]["hardcore"] = "hardcore";
		game["dialog"]["oldschool"] = "oldschool";
		game["dialog"]["highspeed"] = "highspeed";
		game["dialog"]["tactical"] = "tactical";
		game["dialog"]["challenge"] = "challengecomplete";
		game["dialog"]["promotion"] = "promotion";
		game["dialog"]["bomb_acquired"] = "sd_bomb_taken_acquired";
		game["dialog"]["bomb_taken"] = "sd_bomb_taken_taken";
		game["dialog"]["bomb_lost"] = "sd_bomb_drop";
		game["dialog"]["bomb_defused"] = "sd_bomb_defused";
		game["dialog"]["bomb_planted"] = "sd_bomb_planted";
		game["dialog"]["obj_taken"] = "securedobj";
		game["dialog"]["obj_lost"] = "lostobj";
		game["dialog"]["obj_defend"] = "defend_start";
		game["dialog"]["obj_destroy"] = "destroy_start";
		game["dialog"]["obj_capture"] = "capture_obj";
		game["dialog"]["objs_capture"] = "capture_objs";
		game["dialog"]["hq_located"] = "hq_located";
		game["dialog"]["hq_enemy_captured"] = "hq_capture";
		game["dialog"]["hq_enemy_destroyed"] = "hq_defend";
		game["dialog"]["hq_secured"] = "hq_secured";
		game["dialog"]["hq_offline"] = "hq_offline";
		game["dialog"]["hq_online"] = "hq_online";
		game["dialog"]["move_to_new"] = "new_positions";
		game["dialog"]["attack"] = "attack";
		game["dialog"]["defend"] = "defend";
		game["dialog"]["offense"] = "offense";
		game["dialog"]["defense"] = "defense";
		game["dialog"]["halftime"] = "halftime";
		game["dialog"]["overtime"] = "overtime";
		game["dialog"]["side_switch"] = "switchingsides";
		game["dialog"]["flag_taken"] = "ourflag";
		game["dialog"]["flag_dropped"] = "ourflag_drop";
		game["dialog"]["flag_returned"] = "ourflag_return";
		game["dialog"]["flag_captured"] = "ourflag_capt";
		game["dialog"]["enemy_flag_taken"] = "enemyflag";
		game["dialog"]["enemy_flag_dropped"] = "enemyflag_drop";
		game["dialog"]["enemy_flag_returned"] = "enemyflag_return";
		game["dialog"]["enemy_flag_captured"] = "enemyflag_capt";
		
		game["dialog"]["securing_a"] = "dom_securing_a";
		game["dialog"]["securing_b"] = "dom_securing_b";
		game["dialog"]["securing_c"] = "dom_securing_c";
		game["dialog"]["securing_d"] = "dom_securing_d";
		game["dialog"]["securing_e"] = "dom_securing_e";
		game["dialog"]["securing_f"] = "dom_securing_f";
		game["dialog"]["secured_a"] = "dom_secured_a";
		game["dialog"]["secured_b"] = "dom_secured_b";
		game["dialog"]["secured_c"] = "dom_secured_c";
		game["dialog"]["secured_d"] = "dom_secured_d";
		game["dialog"]["secured_e"] = "dom_secured_e";
		game["dialog"]["secured_f"] = "dom_secured_f";
		game["dialog"]["losing_a"] = "dom_losing_a";
		game["dialog"]["losing_b"] = "dom_losing_b";
		game["dialog"]["losing_c"] = "dom_losing_c";
		game["dialog"]["losing_d"] = "dom_losing_d";
		game["dialog"]["losing_e"] = "dom_losing_e";
		game["dialog"]["losing_f"] = "dom_losing_f";
		game["dialog"]["lost_a"] = "dom_lost_a";
		game["dialog"]["lost_b"] = "dom_lost_b";
		game["dialog"]["lost_c"] = "dom_lost_c";
		game["dialog"]["lost_d"] = "dom_lost_d";
		game["dialog"]["lost_e"] = "dom_lost_e";
		game["dialog"]["lost_f"] = "dom_lost_f";
		
		
		game["dialog"]["secure_flag"] = "secure_flag";
		game["dialog"]["securing_flag"] = "securing_flag";
		game["dialog"]["losing_flag"] = "losing_flag";
		game["dialog"]["lost_flag"] = "lost_flag";
		game["dialog"]["oneflag_enemy"] = "oneflag_enemy";
		game["dialog"]["oneflag_friendly"] = "oneflag_friendly";
		game["dialog"]["lost_all"] = "dom_lock_theytake";
		game["dialog"]["secure_all"] = "dom_lock_wetake";
		
		game["dialog"]["squad_move"] = "squad_move";
		game["dialog"]["squad_30sec"] = "squad_30sec";
		game["dialog"]["squad_winning"] = "squad_onemin_vic";
		game["dialog"]["squad_losing"] = "squad_onemin_loss";
		game["dialog"]["squad_down"] = "squad_down";
		game["dialog"]["squad_bomb"] = "squad_bomb";
		game["dialog"]["squad_plant"] = "squad_plant";
		game["dialog"]["squad_take"] = "squad_takeobj";
		
		game["dialog"]["kicked"] = "player_kicked";
		
		game["dialog"]["sentry_destroyed"] = "dest_sentry";
		game["dialog"]["sam_destroyed"] = "dest_sam";
		game["dialog"]["tact_destroyed"] = "dest_tact";
		game["dialog"]["equipment_destroyed"] = "dest_equip";
		
		level thread suspenseMusic();
}
suspenseMusicForPlayer()
{
	self endon("disconnect");
	
	self thread set_music_on_player( "SILENT", false );		
	
	wait (1);
	
	self thread set_music_on_player( "UNDERSCORE", false );		
	if( getdvarint( #"debug_music" ) > 0 )
	{
		println ("Music System - Setting Music State Random Underscore " + self.pers["music"].returnState + " On player " + self getEntityNumber());	
	}
}
suspenseMusic()
{
	level endon ( "game_ended" );
	level endon ( "match_ending_soon" );
	
	wait 20;
	
	while (1)
	{	
		wait( randomintrange( 60, 85 ) );
		
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
	
			if ( !IsDefined( player.pers["music"].inque ) )	
			{
				
				player.pers["music"].inque = false;
			}	
			
			if ( player.pers["music"].inque)
			{
				if( getdvarint( #"debug_music" ) > 0 )
				{
					println ("Music System - Inque no random underscore" );	
				}				
				return;
			}
			
			if ( !IsDefined( player.pers["music"].currentState ) )	
			{
				
				player.pers["music"].currentState = "SILENT";
			}	
			
			if( randomintrange( 0, 20 ) > 15 && player.pers["music"].currentState != "ACTION" && player.pers["music"].currentState != "TIME_OUT" )
			{
				player thread suspenseMusicForPlayer(); 
			}
		}
	}
}
announceRoundWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;
	if ( !isDefined( winner ) || isPlayer( winner ) )
		return;
	if ( winner == "allies" )
	{
		
		
		leaderDialog( "round_success", "allies" );
		leaderDialog( "round_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		
		
		leaderDialog( "round_success", "axis" );
		leaderDialog( "round_failure", "allies" );
	}
	else
	{
		thread playSoundOnPlayers( "mus_round_draw"+"_"+level.teamPostfix["allies"] );
		thread playSoundOnPlayers( "mus_round_draw"+"_"+level.teamPostfix["axis"] );
		leaderDialog( "round_draw" );
	}
}
announceGameWinner( winner, delay )
{
	if ( delay > 0 )
		wait delay;
	if ( !isDefined( winner ) || isPlayer( winner ) )
		return;
	if ( winner == "allies" )
	{
		leaderDialog( "mission_success", "allies" );
		leaderDialog( "mission_failure", "axis" );
	}
	else if ( winner == "axis" )
	{
		leaderDialog( "mission_success", "axis" );
		leaderDialog( "mission_failure", "allies" );
	}
	else
	{
		leaderDialog( "mission_draw" );
	}
}
doFlameAudio()
{
	self endon("disconnect");
	waittillframeend;
	
	if (!isdefined ( self.lastFlameHurtAudio ) )
		self.lastFlameHurtAudio = 0;
		
	currentTime = gettime();
	
	if ( self.lastFlameHurtAudio + level.fire_audio_repeat_duration + RandomInt( level.fire_audio_random_max_duration ) < currentTime )
	{
		self playLocalSound("vox_pain_small");
		self.lastFlameHurtAudio = currentTime;
	} 
}
leaderDialog( dialog, team, group, excludeList, squadDialog )
{
	assert( isdefined( level.players ) );
	if ( level.splitscreen )
		return;
		
	if ( level.wagerMatch )
		return;
		
	if ( !isDefined( team ) )
	{
		leaderDialogBothTeams( dialog, "allies", dialog, "axis", group, excludeList );
		return;
	}
	
	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog, group );
		return;
	}
	
	
	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( (isDefined( player.pers["team"] ) && (player.pers["team"] == team )) && !maps\mp\gametypes\_globallogic_utils::isExcluded( player, excludeList ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
				player leaderDialogOnPlayer( dialog, group );
		}
	}
}
leaderDialogBothTeams( dialog1, team1, dialog2, team2, group, excludeList )
{
	assert( isdefined( level.players ) );
	
	if ( level.splitscreen )
		return;
	if ( level.splitscreen )
	{
		if ( level.players.size )
			level.players[0] leaderDialogOnPlayer( dialog1, group );
		return;
	}
	if ( isDefined( excludeList ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];
			
			if ( !isDefined( team ) )
				continue;
			
			if ( maps\mp\gametypes\_globallogic_utils::isExcluded( player, excludeList ) )
				continue;
			
			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
	else
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];
			team = player.pers["team"];
			
			if ( !isDefined( team ) )
				continue;
			
			if ( team == team1 )
				player leaderDialogOnPlayer( dialog1, group );
			else if ( team == team2 )
				player leaderDialogOnPlayer( dialog2, group );
		}
	}
}
leaderDialogOnPlayer( dialog, group )
{
	if( isPregame() )
		return;
		
	team = self.pers["team"];
	if ( level.splitscreen )
		return;
	
	if ( !isDefined( team ) )
		return;
	
	if ( team != "allies" && team != "axis" )
		return;
	
	if ( isDefined( group ) )
	{
		
		if ( self.leaderDialogGroup == group )
			return;
		hadGroupDialog = isDefined( self.leaderDialogGroups[group] );
		self.leaderDialogGroups[group] = dialog;
		dialog = group;		
		
		
		if ( hadGroupDialog )
			return;
	}
	if ( !self.leaderDialogActive )
		self thread playLeaderDialogOnPlayer( dialog, team );
	else
		self.leaderDialogQueue[self.leaderDialogQueue.size] = dialog;
}
playLeaderDialogOnPlayer( dialog, team )
{
	self endon ( "disconnect" );
	
	self.leaderDialogActive = true;
	if ( isDefined( self.leaderDialogGroups[dialog] ) )
	{
		group = dialog;
		dialog = self.leaderDialogGroups[group];
		self.leaderDialogGroups[group] = undefined;
		self.leaderDialogGroup = group;
	}
	if( level.allowAnnouncer )
	{
		if ( level.wagerMatch )
			faction = "vox_wm_";
		else
			faction = game["voice"][team];
		
		self playLocalSound( faction+game["dialog"][dialog] );
	}
	wait ( 3.0 );
	self.leaderDialogActive = false;
	self.leaderDialogGroup = "";
	if ( self.leaderDialogQueue.size > 0 )
	{
		nextDialog = self.leaderDialogQueue[0];
		
		for ( i = 1; i < self.leaderDialogQueue.size; i++ )
			self.leaderDialogQueue[i-1] = self.leaderDialogQueue[i];
		self.leaderDialogQueue[i-1] = undefined;
		
		self thread playLeaderDialogOnPlayer( nextDialog, team );
	}
}
musicController()
{
	level endon ( "game_ended" );
	
	level thread musicTimesOut();
	
	if( isPregame() )
		return;
	
	
	
	level waittill ( "match_ending_soon" );
	if ( isLastRound() || isOneRound() )
	{	
		if ( !level.splitScreen )
		{
			if( level.teamBased && game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			{
				leaderDialog( "min_draw" );
			}
			else if( level.teamBased && game["teamScores"]["allies"] > game["teamScores"]["axis"] )
			{
				
		
				leaderDialog( "winning", "allies", undefined, undefined, "squad_winning" );
				leaderDialog( "losing", "axis", undefined, undefined , "squad_losing" );
			}
			else if ( level.teamBased && game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			{
				
					
				leaderDialog( "winning", "axis", undefined, undefined, "squad_winning" );
				leaderDialog( "losing", "allies", undefined, undefined , "squad_losing" );
			}
			else if( level.teamBased )
			{
				
				leaderDialog( "timesup", "axis", undefined, undefined , "squad_30sec" );
				leaderDialog( "timesup", "allies", undefined, undefined , "squad_30sec" );
			}
			
			
			
	
			level waittill ( "match_ending_very_soon" );
			leaderDialog( "timesup", "axis", undefined, undefined , "squad_30sec" );
			leaderDialog( "timesup", "allies", undefined, undefined , "squad_30sec" );
		}
	}
	else
	{
		
			
		level waittill ( "match_ending_vox" );
		
		
		leaderDialog( "timesup" );
	}
}
musicTimesOut()
{
    level endon( "game_ended" );
    
    level waittill ( "match_ending_very_soon" );
    
 
 
  
	
	
    thread maps\mp\gametypes\_globallogic_audio::set_music_on_team( "TIME_OUT", "both" , true, false );
}
actionMusicSet()
{
    level endon( "game_ended" );
    level.playingActionMusic = true;
    wait(45);
    level.playingActionMusic = false;
}
play_2d_on_team( alias, team )
{
	assert( isdefined( level.players ) );
	
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player playLocalSound( alias );
		}	
	}
}
set_music_on_team( state, team, save_state, return_state, wait_time )
{
	
	assert( isdefined( level.players ) );
	
	if ( !IsDefined( team ) )	
	{
		team = "both";
		if( getdvarint( #"debug_music" ) > 0 )
		{		
			println ("Music System - team undefined: Setting to both");
		}
	}
	if ( !IsDefined( save_state ) )	
	{
		save_sate = false;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - save_sate undefined: Setting to false");
		}
	}
	if ( !IsDefined( return_state ) )	
	{
		return_state = false;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - Music System - return_state undefined: Setting to false");			
		}	
	}	
	if ( !IsDefined( wait_time ) )	
	{
		wait_time = 0;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - wait_time undefined: Setting to 0");		
		}
	}
		
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( team == "both" )
		{
			
			player thread set_music_on_player ( state, save_state, return_state, wait_time );			
		}	
		else if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player thread set_music_on_player ( state, save_state, return_state, wait_time );
	
			if( getdvarint( #"debug_music" ) > 0 )
			{
				println ("Music System - Setting Music State " + state + " On player " + player getEntityNumber());	
			}
		}
	}
}
set_music_on_player( state, save_state, return_state, wait_time )
{
	
	self endon( "disconnect" );
	
	assert( isplayer (self) );
	
	if ( !IsDefined( save_state ) )	
	{
		save_state = false;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - Music System - save_sate undefined: Setting to false");
		}
	}
	if ( !IsDefined( return_state ) )	
	{
		return_state = false;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - Music System - return_state undefined: Setting to false");		
		}
	}	
	if ( !IsDefined( wait_time ) )	
	{
		wait_time = 0;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - wait_time undefined: Setting to 0");			
		}
	}	
		if ( !IsDefined( state ) )	
	{
		state = "UNDERSCORE";
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - state undefined: Setting to UNDERSCORE");			
		}
	}	
	maps\mp\_music::setmusicstate( state, self );
	
	if ( isdefined ( self.pers["music"].currentState ) && save_state  )
	{
		
		self.pers["music"].returnState = state; 			
		
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - Saving Music State " + self.pers["music"].returnState + " On " + self getEntityNumber() );
		}
	}
	
	
	self.pers["music"].previousState = self.pers["music"].currentState;
	
	self.pers["music"].currentState = state;
	
	if( getdvarint( #"debug_music" ) > 0 )
	{
		println ("Music System - Setting Music State " + state + " On player " + self getEntityNumber());
	}
	if ( isdefined ( self.pers["music"].returnState ) && return_state )
	{
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - Starting Return State " + self.pers["music"].returnState + " On " + self getEntityNumber() );
		}
		self set_next_music_state ( self.pers["music"].returnState, wait_time);
	}
		
}
return_music_state_player( wait_time )
{
	if ( !IsDefined( wait_time ) )	
	{
		wait_time = 0;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - wait_time undefined: Setting to 0");			
		}
	}	
	
	self set_next_music_state ( self.pers["music"].returnState, wait_time);
}
return_music_state_team( team, wait_time )
{
	if ( !IsDefined( wait_time ) )	
	{
		wait_time = 0;
		if( getdvarint( #"debug_music" ) > 0 )
		{
			println ("Music System - wait_time undefined: Setting to 0");			
		}
	}	
	for ( i = 0; i < level.players.size; i++ )
	{
		player = level.players[i];
		if ( team == "both" )
		{
			
			player thread set_next_music_state ( self.pers["music"].returnState, wait_time);
		}	
		else if ( isDefined( player.pers["team"] ) && (player.pers["team"] == team ) )
		{
			player thread set_next_music_state ( self.pers["music"].returnState, wait_time);
	
			if( getdvarint( #"debug_music" ) > 0 )
			{
				println ("Music System - Setting Music State " + self.pers["music"].returnState + " On player " + player getEntityNumber());	
			}
		}
	}	
}		
set_next_music_state ( nextstate, wait_time )
{
	
	
	
	self endon( "disconnect" );
	
	self.pers["music"].nextstate = nextstate;	
	
	if( getdvarint( #"debug_music" ) > 0 )
	{
		println ("Music System - Setting next Music State " + self.pers["music"].nextstate + " On " + self getEntityNumber() );
	}
	if ( !IsDefined( self.pers["music"].inque ) )	
	{
		
		self.pers["music"].inque = false;
	}	
	if ( self.pers["music"].inque )
	{
		
		return;
		
		println ("Music System - Music state in que" );
	}
	else
	{			
		
		self.pers["music"].inque = true;	
		
		
		if ( wait_time )
		{
			wait wait_time;
		}
		
		self set_music_on_player ( self.pers["music"].nextstate, false );
		
		
		self.pers["music"].inque = false;	
	}
}
getRoundSwitchDialog( switchType )
{
	switch( switchType )
	{
		case "halftime":
			return "halftime";
		case "overtime":
			return "overtime";
		default:
			return "side_switch";
	}
}