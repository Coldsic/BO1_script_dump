#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
main()
{
	level.pregame = true;
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	if( level.console )
	{
		maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( "pregame", 0, 0, 1440 );
	}
	else
	{
		maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( "pregame", 5, 0, 1440 );
	}
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( "pregame", 0, 0, 5000 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( "pregame", 1, 0, 1 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( "pregame", 0, 0, 0 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( "pregame", 0, 0, 0 );
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.onEndGame = ::onEndGame;
	level.onTimeLimit = ::onTimeLimit;
	level.teamBased = false;
	
	level.onOutcomeNotify = ::PregameoutcomeNotify;
	game["dialog"]["gametype"] = "pregame_start";
	
	setscoreboardcolumns( "kills", "deaths", "kdratio", "assists" ); 
	
	if ( getDvar( "party_minplayers" ) == "" )
		setDvar( "party_minplayers", 4 );
		
	level.pregame_minplayers = GetDvarInt( "party_minplayers" );
	
	SetMatchTalkFlag( "EveryoneHearsEveryone", 1 );
}
onStartGameType()
{
	setClientNameMode("auto_change");
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"OBJECTIVES_PREGAME" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"OBJECTIVES_PREGAME" );
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_PREGAME" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_PREGAME" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_PREGAME_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_PREGAME_SCORE" );
	}
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"OBJECTIVES_PREGAME_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"OBJECTIVES_PREGAME_HINT" );
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	newSpawns = GetEntArray( "mp_wager_spawn", "classname" );
	if (newSpawns.size > 0)
	{
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_wager_spawn" );
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_wager_spawn" );
	}
	else
	{
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	}
	
	maps\mp\gametypes\_spawning::updateAllSpawnPoints();
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	SetMapCenter( level.mapCenter );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getRandomIntermissionPoint();
	setDemoIntermissionPoint( spawnpoint.origin, spawnpoint.angles );
	
	
	level.useStartSpawns = false;
	level.overrideTeamScore = true;
	
	level.rankEnabled = false;
	level.medalsEnabled = false;
	
	if (newSpawns.size > 0)
	{
		allowed[0] = "shrp";
		maps\mp\gametypes\_gameobjects::main(allowed);
	}
	else
	{
		allowed[0] = "dm";
		maps\mp\gametypes\_gameobjects::main(allowed);
	}
	
	maps\mp\gametypes\_spawning::create_map_placed_influencers();
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 50 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 1 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );	
	
	level.killcam = false;
	level.finalkillcam = false;
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;
	
	StartPreGame();
	
	
}
StartPreGame()
{	
	game["strings"]["waiting_for_players"] = &"MP_WAITING_FOR_X_PLAYERS";
	game["strings"]["pregame"] = &"MP_PREGAME";
	game["strings"]["pregameover"] = &"MP_MATCHSTARTING";
	game["strings"]["pregame_time_limit_reached"] = &"MP_PREGAME_TIME_LIMIT";
	precacheString( game["strings"]["waiting_for_players"] );
	precacheString( game["strings"]["pregame"] );
	precacheString( game["strings"]["pregameover"] );
	precacheString( game["strings"]["pregame_time_limit_reached"] );
	
	thread PregameMain();
}
onSpawnPlayerUnified()
{
	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
}
onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	self spawn( spawnPoint.origin, spawnPoint.angles, "dm" );
}
OnPlayerClassChange( response )
{
	self.pregameClassResponse = response;
}
endPreGame()
{
	
	
	
	
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player maps\mp\gametypes\_globallogic_player::freezePlayerForRoundEnd();
	}
	SetMatchTalkFlag( "EveryoneHearsEveryone", 0 );
	level.pregamePlayerCount 	destroyElem();
	level.pregameSubTitle			destroyElem();
	level.pregameTitle				destroyElem();
}
GetPlayersNeededCount()
{
	players = level.players;
	count = 0;
	
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		team = player.team;
		class = player.class;
	
		if ( team != "spectator" )
			count++;
	}
	return Int(level.pregame_minplayers - count);
}
SavePlayersPreGameInfo()
{
	ResetPregameData();
	players = level.players;
	for ( i = 0; i < players.size; i++ )
	{
		player = players[i];
		team = player.team;
		class = player.pregameClassResponse;
		
		
		if( IsDefined( team ) && team != "" )
			player SetPreGameTeam( team );
		if( IsDefined( class ) && class != "" )
			player SetPregameClass( class );
	}
}
PregameMain()
{	
	level endon ( "game_ended" );
	
	green = (0.6, 0.9, 0.6);
	red = (0.7, 0.3, 0.2);
	yellow = (1, 1, 0);
	white = (1, 1, 1);
		
	
	titleSize = 3.0;
	textSize = 2.0;
	iconSize = 70;
	spacing = 30;
	font = "extrabig";
	level.pregameTitle = createServerFontString( font, titleSize );
	level.pregameTitle setPoint( "TOP", undefined, 0, 100 );
	level.pregameTitle.glowAlpha = 1;
	level.pregameTitle.foreground = true;
	level.pregameTitle.hideWhenInMenu = true;
	level.pregameTitle.archived = false;
	level.pregameTitle setText( game["strings"]["pregame"] );
	level.pregameTitle.color = red;
	level.pregameSubTitle = createServerFontString( font, 2.0 );
	level.pregameSubTitle setParent( level.pregameTitle );
	level.pregameSubTitle setPoint( "TOP", "BOTTOM", 0, 0 );
	level.pregameSubTitle.glowAlpha = 1;
	level.pregameSubTitle.foreground = false;
	level.pregameSubTitle.hideWhenInMenu = true;
	level.pregameSubTitle.archived = true;	
	level.pregameSubTitle setText( game["strings"]["waiting_for_players"] );
	level.pregameSubTitle.color = red;
	
	level.pregamePlayerCount = createServerFontString( font, 2.2 );
	level.pregamePlayerCount setParent( level.pregameTitle );
	level.pregamePlayerCount setPoint( "TOP", "BOTTOM", -11, 0 );
	level.pregameSubTitle.glowAlpha = 1;
	level.pregamePlayerCount.sort = 1001;
	level.pregamePlayerCount.foreground = false;
	level.pregamePlayerCount.hidewheninmenu = true;
	level.pregamePlayerCount.archived = true;	
	level.pregamePlayerCount.color = yellow;
	
	level.pregamePlayerCount maps\mp\gametypes\_hud::fontPulseInit();
	
	oldcount = -1;
	
	for(;;)
	{
		wait( 1 );
		
		count = GetPlayersNeededCount();
		
		if( 0 >= count )
			break;
		if( oldcount != count )
		{
			level.pregamePlayerCount setValue( count );
			level.pregamePlayerCount thread maps\mp\gametypes\_hud::fontPulse( level );
			oldcount = count;
		}
	}
	
	level.pregamePlayerCount 	setText( "" );
	level.pregameSubTitle setText( game["strings"]["pregameover"] );
	
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];
		player freeze_player_controls( true );
		player maps\mp\gametypes\_globallogic_ui::freeGameplayHudElems();
	}
	
	visionSetNaked( "mpIntro", 3 );
	wait( 4 );
	
	endPreGame();	
	
	pregamestartgame();
	SavePlayersPreGameInfo();
	Map_Restart( false );
}
onEndGame( winner )
{
	endPreGame();
}
onTimeLimit()
{
	winner = undefined;
	
	if ( level.teamBased )
	{
		if ( game["teamScores"]["allies"] == game["teamScores"]["axis"] )
			winner = "tie";
		else if ( game["teamScores"]["axis"] > game["teamScores"]["allies"] )
			winner = "axis";
		else
			winner = "allies";
		logString( "time limit, win: " + winner + ", allies: " + game["teamScores"]["allies"] + ", axis: " + game["teamScores"]["axis"] );
	}
	else
	{
		winner = maps\mp\gametypes\_globallogic_score::getHighestScoringPlayer();
		if ( isDefined( winner ) )
			logString( "time limit, win: " + winner.name );
		else
			logString( "time limit, tie" );
	}
	
	
	makeDvarServerInfo( "ui_text_endreason", game["strings"]["pregame_time_limit_reached"] );
	setDvar( "ui_text_endreason", game["strings"]["time_limit_reached"] );
	
	thread maps\mp\gametypes\_globallogic::endGame( winner, game["strings"]["pregame_time_limit_reached"] );
}
get_pregame_class()
{
	pclass = self GetPregameClass();
	if( IsDefined( pclass ) && pclass[0] != "" )
		return pclass;
	else
		return "smg_mp,0";
}
PregameoutcomeNotify( winner, isRoundEnd, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );
	
	while ( self.doingNotify )
		wait 0.05;
	self endon ( "reset_outcome" );
	headerFont = "extrabig";
	font = "default";
	if ( self IsSplitscreen() )
	{
		titleSize = 2.0;
		winnerSize = 1.5;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3.0;
		winnerSize = 2.0;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 20;
	}
	
	green = (0.6, 0.9, 0.6);
	red = (0.7, 0.3, 0.2);
	yellow = (1, 1, 0);
	white = (1, 1, 1);
	duration = 60000;
	
	outcomeTitle = createFontString( headerFont, titleSize );
	outcomeTitle setPoint( "TOP", undefined, 0, spacing );
	outcomeTitle setText( game["strings"]["game_over"] );
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeTitle setPulseFX( 100, duration, 1000 );
	outcomeTitle.color = red;
	outcomeText = createFontString( font, 2.0 );
	outcomeText setParent( outcomeTitle );
	outcomeText setPoint( "TOP", "BOTTOM", 0, 0 );
	outcomeText.glowAlpha = 1;
	outcomeText.hideWhenInMenu = false;
	outcomeText.archived = false;
	outcomeText setText( endReasonText );
	outcomeText.color = red;
	self thread PregameresetOutcomeNotify( outcomeTitle, outcomeText );
}
PregameresetOutcomeNotify( hudElem1, hudElem2 )
{
	self endon ( "disconnect" );
	self waittill ( "reset_outcome" );
	
	hudElem1 destroyElem();
	hudElem2 destroyElem();
}