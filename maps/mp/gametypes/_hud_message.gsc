#include maps\mp\gametypes\_hud_util;
#include maps\mp\_laststand;
init()
{
	precacheString( &"MENU_POINTS" );
	precacheString( &"MP_FIRSTPLACE_NAME" );
	precacheString( &"MP_SECONDPLACE_NAME" );
	precacheString( &"MP_THIRDPLACE_NAME" );
	precacheString( &"MP_WAGER_PLACE_NAME" );
	precacheString( &"MP_MATCH_BONUS_IS" );
	precacheString( &"MP_CODPOINTS_MATCH_BONUS_IS" );
	precacheString( &"MP_WAGER_WINNINGS_ARE" );
	precacheString( &"MP_WAGER_SIDEBET_WINNINGS_ARE" );
	precacheString( &"MP_WAGER_IN_THE_MONEY" );
	game["strings"]["draw"] = &"MP_DRAW_CAPS";
	game["strings"]["round_draw"] = &"MP_ROUND_DRAW_CAPS";
	game["strings"]["round_win"] = &"MP_ROUND_WIN_CAPS";
	game["strings"]["round_loss"] = &"MP_ROUND_LOSS_CAPS";
	game["strings"]["victory"] = &"MP_VICTORY_CAPS";
	game["strings"]["defeat"] = &"MP_DEFEAT_CAPS";
	game["strings"]["game_over"] = &"MP_GAME_OVER_CAPS";
	game["strings"]["halftime"] = &"MP_HALFTIME_CAPS";
	game["strings"]["overtime"] = &"MP_OVERTIME_CAPS";
	game["strings"]["roundend"] = &"MP_ROUNDEND_CAPS";
	game["strings"]["intermission"] = &"MP_INTERMISSION_CAPS";
	game["strings"]["side_switch"] = &"MP_SWITCHING_SIDES_CAPS";
	game["strings"]["match_bonus"] = &"MP_MATCH_BONUS_IS";
	game["strings"]["codpoints_match_bonus"] = &"MP_CODPOINTS_MATCH_BONUS_IS";
	game["strings"]["wager_winnings"] = &"MP_WAGER_WINNINGS_ARE";
	game["strings"]["wager_sidebet_winnings"] = &"MP_WAGER_SIDEBET_WINNINGS_ARE";
	game["strings"]["wager_inthemoney"] = &"MP_WAGER_IN_THE_MONEY_CAPS";
	game["strings"]["wager_loss"] = &"MP_WAGER_LOSS_CAPS";
	game["strings"]["wager_topwinners"] = &"MP_WAGER_TOPWINNERS";
	
	game["menu_endgameupdate"] = "endgameupdate";
	precacheMenu(game["menu_endgameupdate"]);
	level thread onPlayerConnect();
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connecting", player );
		player thread hintMessageDeathThink();
		player thread lowerMessageThink();
		
		player thread initNotifyMessage();
		player thread initCustomGametypeHeader();
		
	}
}
initCustomGametypeHeader()
{
	
	font = "default";
	titleSize = 2.5;
	self.customGametypeHeader = createFontString( font, titleSize );
	self.customGametypeHeader setPoint( "TOP", undefined, 0, 30 );
	self.customGametypeHeader.glowAlpha = 1;
	self.customGametypeHeader.hideWhenInMenu = true;
	self.customGametypeHeader.archived = false;
	self.customGametypeHeader.color = ( 1, 1, 0.6 );
	self.customGametypeHeader.alpha = 1;
	
	
	titleSize = 2.0;
	self.customGametypeSubHeader = createFontString( font, titleSize );
	self.customGametypeSubHeader setParent( self.customGametypeHeader );
	self.customGametypeSubHeader setPoint( "TOP", "BOTTOM", 0, 0 );
	self.customGametypeSubHeader.glowAlpha = 1;
	self.customGametypeSubHeader.hideWhenInMenu = true;
	self.customGametypeSubHeader.archived = false;
	self.customGametypeSubHeader.color = ( 1, 1, 0.6 );
	self.customGametypeSubHeader.alpha = 1;
}
hintMessage( hintText, duration )
{
	notifyData = spawnstruct();
	
	notifyData.notifyText = hintText;
	notifyData.duration = duration;
	
	notifyMessage( notifyData );
}
hintMessagePlayers( players, hintText, duration )
{
	notifyData = spawnstruct();
	notifyData.notifyText = hintText;
	notifyData.duration = duration;
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] notifyMessage( notifyData );
	}
}
initNotifyMessage()
{
	if ( self IsSplitscreen() )
	{
		titleSize = 2.0;
		textSize = 1.4;
		iconSize = 24;
		font = "extrabig";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 30;
		xOffset = 30;
	}
	else
	{
		titleSize = 2.0;
		textSize = 1.4;
		iconSize = 30;
		font = "extrabig";
		point = "TOP";
		relativePoint = "BOTTOM";
		yOffset = 0;
		xOffset = 0;
	}
	
	self.notifyTitle = createFontString( font, titleSize );
	self.notifyTitle setPoint( point, undefined, xOffset, yOffset );
	self.notifyTitle.glowAlpha = 1;
	self.notifyTitle.hideWhenInMenu = true;
	self.notifyTitle.archived = false;
	self.notifyTitle.alpha = 0;
	self.notifyText = createFontString( font, textSize );
	self.notifyText setParent( self.notifyTitle );
	self.notifyText setPoint( point, relativePoint, 0, 0 );
	self.notifyText.glowAlpha = 1;
	self.notifyText.hideWhenInMenu = true;
	self.notifyText.archived = false;
	self.notifyText.alpha = 0;
	self.notifyText2 = createFontString( font, textSize );
	self.notifyText2 setParent( self.notifyTitle );
	self.notifyText2 setPoint( point, relativePoint, 0, 0 );
	self.notifyText2.glowAlpha = 1;
	self.notifyText2.hideWhenInMenu = true;
	self.notifyText2.archived = false;
	self.notifyText2.alpha = 0;
	self.notifyIcon = createIcon( "white", iconSize, iconSize );
	self.notifyIcon setParent( self.notifyText2 );
	self.notifyIcon setPoint( point, relativePoint, 0, 0 );
	self.notifyIcon.hideWhenInMenu = true;
	self.notifyIcon.archived = false;
	self.notifyIcon.alpha = 0;
	self.doingNotify = false;
	self.notifyQueue = [];
}
oldNotifyMessage( titleText, notifyText, iconName, glowColor, sound, duration )
{
	if ( level.wagerMatch && !level.teamBased )
		return;
		
	notifyData = spawnstruct();
	
	notifyData.titleText = titleText;
	notifyData.notifyText = notifyText;
	notifyData.iconName = iconName;
	notifyData.sound = sound;
	notifyData.duration = duration;
	self.startMessageNotifyQueue[ self.startMessageNotifyQueue.size ] = notifyData;
	self notify( "received award" );
}
notifyMessage( notifyData )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self.messageNotifyQueue[ self.messageNotifyQueue.size ] = notifyData;
	self notify( "received award" );
}
showNotifyMessage( notifyData, duration )
{
	self endon("disconnect");
	
	self.doingNotify = true;
	waitRequireVisibility( 0 );
	self notify ( "notifyMessageBegin", duration );
	
	self thread resetOnCancel();
	if ( isDefined( notifyData.sound ) )
		self playLocalSound( notifyData.sound );
		
	if ( isDefined( notifyData.musicState ) )		
		self maps\mp\_music::setmusicstate( notifyData.music );	
	if ( isDefined( notifyData.leaderSound ) )
		self maps\mp\gametypes\_globallogic_audio::leaderDialogOnPlayer( notifyData.leaderSound );
	
	if ( isDefined( notifyData.glowColor ) )
		glowColor = notifyData.glowColor;
	else
		glowColor = (0.0, 0.0, 0.0);
	anchorElem = self.notifyTitle;
	if ( isDefined( notifyData.titleText ) )
	{
		if ( isDefined( notifyData.titleLabel ) )
			self.notifyTitle.label = notifyData.titleLabel;
		else
			self.notifyTitle.label = &"";
		if ( isDefined( notifyData.titleLabel ) && !isDefined( notifyData.titleIsString ) )
			self.notifyTitle setValue( notifyData.titleText );
		else
			self.notifyTitle setText( notifyData.titleText );
		self.notifyTitle setCOD7DecodeFX( 200, int(duration*1000), 600 );
		self.notifyTitle.glowColor = glowColor;	
		self.notifyTitle.alpha = 1;
	}
	if ( isDefined( notifyData.notifyText ) )
	{
		if ( isDefined( notifyData.textLabel ) )
			self.notifyText.label = notifyData.textLabel;
		else
			self.notifyText.label = &"";
		if ( isDefined( notifyData.textLabel ) && !isDefined( notifyData.textIsString ) )
			self.notifyText setValue( notifyData.notifyText );
		else
			self.notifyText setText( notifyData.notifyText );
		self.notifyText setCOD7DecodeFX( 100, int(duration*1000), 600 );
		self.notifyText.glowColor = glowColor;	
		self.notifyText.alpha = 1;
		anchorElem = self.notifyText;
	}
	if ( isDefined( notifyData.notifyText2 ) )
	{
		if ( self IsSplitscreen() )
		{
			if ( isDefined( notifyData.text2Label ) )
				self iPrintLnBold( notifyData.text2Label, notifyData.notifyText2 );
			else
				self iPrintLnBold( notifyData.notifyText2 );
		}
		else
		{
			self.notifyText2 setParent( anchorElem );
			
			if ( isDefined( notifyData.text2Label ) )
				self.notifyText2.label = notifyData.text2Label;
			else
				self.notifyText2.label = &"";
	
			self.notifyText2 setText( notifyData.notifyText2 );
			self.notifyText2 setPulseFX( 100, int(duration*1000), 1000 );
			self.notifyText2.glowColor = glowColor;	
			self.notifyText2.alpha = 1;
			anchorElem = self.notifyText2;
		}
	}
	if ( isDefined( notifyData.iconName ) )
	{
		iconWidth= 60;
		iconHeight= 60;
		
		if (IsDefined(notifyData.iconWidth))
		{
			iconWidth= notifyData.iconWidth;
		}
		if (IsDefined(notifyData.iconHeight))
		{
			iconHeight= notifyData.iconHeight;
		}
		
		self.notifyIcon setParent( anchorElem );
		self.notifyIcon setShader( notifyData.iconName, iconWidth, iconHeight );
		self.notifyIcon.alpha = 0;
		self.notifyIcon fadeOverTime( 1.0 );
		self.notifyIcon.alpha = 1;
		
		waitRequireVisibility( duration );
		self.notifyIcon fadeOverTime( 0.75 );
		self.notifyIcon.alpha = 0;
	}
	else
	{
		waitRequireVisibility( duration );
	}
	self notify ( "notifyMessageDone" );
	self.doingNotify = false;
}
waitRequireVisibility( waitTime )
{
	interval = .05;
	
	while ( !self canReadText() )
		wait interval;
	
	while ( waitTime > 0 )
	{
		wait interval;
		if ( self canReadText() )
			waitTime -= interval;
	}
}
canReadText()
{
	if ( self maps\mp\_flashgrenades::isFlashbanged() )
		return false;
	
	return true;
}
resetOnDeath()
{
	self endon ( "notifyMessageDone" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );
	self waittill ( "death" );
	resetNotify();
}
resetOnCancel()
{
	self notify ( "resetOnCancel" );
	self endon ( "resetOnCancel" );
	self endon ( "notifyMessageDone" );
	self endon ( "disconnect" );
	level waittill ( "cancel_notify" );
	
	resetNotify();
}
resetNotify()
{
	self.notifyTitle.alpha = 0;
	self.notifyText.alpha = 0;
	self.notifyIcon.alpha = 0;
	self.doingNotify = false;
}
hintMessageDeathThink()
{
	self endon ( "disconnect" );
	for ( ;; )
	{
		self waittill ( "death" );
		
		if ( isDefined( self.hintMessage ) )
			self.hintMessage destroyElem();
	}
}
lowerMessageThink()
{
	self endon ( "disconnect" );
	
	self.lowerMessage = createFontString( "default", level.lowerTextFontSize );
	self.lowerMessage setPoint( "CENTER", level.lowerTextYAlign, 0, level.lowerTextY );
	self.lowerMessage setText( "" );
	self.lowerMessage.archived = false;
	
	timerFontSize = 1.5;
	if ( self IsSplitscreen() )
		timerFontSize = 1.4;
	
	self.lowerTimer = createFontString( "default", timerFontSize );
	self.lowerTimer setParent( self.lowerMessage );
	self.lowerTimer setPoint( "TOP", "BOTTOM", 0, 0 );
	self.lowerTimer setText( "" );
	self.lowerTimer.archived = false;
}
teamOutcomeNotify( winner, isRound, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );
	team = self.pers["team"];
	if ( !isDefined( team ) || (team != "allies" && team != "axis") )
		team = "allies";
	
	while ( self.doingNotify )
		wait 0.05;
	self endon ( "reset_outcome" );
	
	headerFont = "extrabig";
	font = "default";
	if ( self IsSplitscreen() )
	{
		titleSize = 2.0;
		textSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3.0;
		textSize = 2.0;
		iconSize = 70;
		spacing = 25;
	}
	duration = 60000;
	outcomeTitle = createFontString( headerFont, titleSize );
	outcomeTitle setPoint( "TOP", undefined, 0, 30 );
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeText = createFontString( font, 2.0 );
	outcomeText setParent( outcomeTitle );
	outcomeText setPoint( "TOP", "BOTTOM", 0, 0 );
	outcomeText.glowAlpha = 1;
	outcomeText.hideWhenInMenu = false;
	outcomeText.archived = false;
	
	if ( winner == "halftime" )
	{
		
		outcomeTitle setText( game["strings"]["halftime"] );
		outcomeTitle.color = (1, 1, 1);
		
		winner = "allies";
	}
	else if ( winner == "intermission" )
	{
		
		outcomeTitle setText( game["strings"]["intermission"] );
		outcomeTitle.color = (1, 1, 1);
		
		winner = "allies";
	}
	else if ( winner == "roundend" )
	{
		
		outcomeTitle setText( game["strings"]["roundend"] );
		outcomeTitle.color = (1, 1, 1);
		
		winner = "allies";
	}
	else if ( winner == "overtime" )
	{
		
		outcomeTitle setText( game["strings"]["overtime"] );
		outcomeTitle.color = (1, 1, 1);
		
		winner = "allies";
	}
	else if ( winner == "tie" )
	{
		
		if ( isRound )
			outcomeTitle setText( game["strings"]["round_draw"] );
		else
			outcomeTitle setText( game["strings"]["draw"] );
		outcomeTitle.color = (0.29, 0.61, 0.7);
		
		winner = "allies";
	}
	else if ( isDefined( self.pers["team"] ) && winner == team )
	{
		
		if ( isRound )
			outcomeTitle setText( game["strings"]["round_win"] );
		else
			outcomeTitle setText( game["strings"]["victory"] );
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else
	{
		
		if ( isRound )
			outcomeTitle setText( game["strings"]["round_loss"] );
		else
			outcomeTitle setText( game["strings"]["defeat"] );
		outcomeTitle.color = (0.73, 0.29, 0.19);
	}
	
	
	outcomeText setText( endReasonText );
	
	outcomeTitle setCOD7DecodeFX( 200, duration, 600 );
	outcomeText setPulseFX( 100, duration, 1000 );
	
	leftIcon = createIcon( game["icons"][team], iconSize, iconSize );
	leftIcon setParent( outcomeText );
	leftIcon setPoint( "TOP", "BOTTOM", -60, spacing );
	leftIcon.hideWhenInMenu = false;
	leftIcon.archived = false;
	leftIcon.alpha = 0;
	leftIcon fadeOverTime( 0.5 );
	leftIcon.alpha = 1;
	rightIcon = createIcon( game["icons"][level.otherTeam[team]], iconSize, iconSize );
	rightIcon setParent( outcomeText );
	rightIcon setPoint( "TOP", "BOTTOM", 60, spacing );
	rightIcon.hideWhenInMenu = false;
	rightIcon.archived = false;
	rightIcon.alpha = 0;
	rightIcon fadeOverTime( 0.5 );
	rightIcon.alpha = 1;
	leftScore = createFontString( headerFont, titleSize );
	leftScore setParent( leftIcon );
	leftScore setPoint( "TOP", "BOTTOM", 0, spacing );
	
	leftScore.glowAlpha = 1;
	leftScore setValue( getTeamScore( team ) );
	leftScore.hideWhenInMenu = false;
	leftScore.archived = false;
	leftScore setCOD7DecodeFX( 200, duration, 600 );
	rightScore = createFontString( headerFont, titleSize );
	rightScore setParent( rightIcon );
	rightScore setPoint( "TOP", "BOTTOM", 0, spacing );
	
	rightScore.glowAlpha = 1;
	rightScore setValue( getTeamScore( level.otherTeam[team] ) );
	rightScore.hideWhenInMenu = false;
	rightScore.archived = false;
	rightScore setCOD7DecodeFX( 200, duration, 600 );
	font = "objective";
	matchBonus = undefined;
	if ( isDefined( self.matchBonus ) )
	{
		matchBonus = createFontString( font, 2.0 );
		matchBonus setParent( outcomeText );
		matchBonus setPoint( "TOP", "BOTTOM", 0, iconSize + (spacing * 3) + leftScore.height );
		matchBonus.glowAlpha = 1;
		matchBonus.hideWhenInMenu = false;
		matchBonus.archived = false;
		matchBonus.label = game["strings"]["match_bonus"];
		matchBonus setValue( self.matchBonus );
		
	}
	
	self thread resetOutcomeNotify( outcomeTitle, outcomeText, leftIcon, rightIcon, leftScore, rightScore );
}
outcomeNotify( winner, isRoundEnd, endReasonText )
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
	duration = 60000;
	players = level.placement["all"];
		
	outcomeTitle = createFontString( headerFont, titleSize );
	outcomeTitle setPoint( "TOP", undefined, 0, spacing );
	if ( !maps\mp\_utility::isOneRound() && !isRoundEnd )
	{
		outcomeTitle setText( game["strings"]["game_over"] );
	}
	else if ( isDefined( players[1] ) && players[0].score == players[1].score && players[0].deaths == players[1].deaths && (self == players[0] || self == players[1]) )
	{
		outcomeTitle setText( game["strings"]["tie"] );
		
	}
	else if ( isDefined( players[2] ) && players[0].score == players[2].score && players[0].deaths == players[2].deaths && self == players[2] )
	{
		outcomeTitle setText( game["strings"]["tie"] );
		
	}
	else if ( isDefined( players[0] ) && self == players[0] )
	{
		outcomeTitle setText( game["strings"]["victory"] );
		outcomeTitle.color = (0.42, 0.68, 0.46);
		
	}
	else
	{
		outcomeTitle setText( game["strings"]["defeat"] );
		outcomeTitle.color = (0.73, 0.29, 0.19);
		
	}
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeTitle setCOD7DecodeFX( 200, duration, 600 );
	outcomeText = createFontString( font, 2.0 );
	outcomeText setParent( outcomeTitle );
	outcomeText setPoint( "TOP", "BOTTOM", 0, 0 );
	outcomeText.glowAlpha = 1;
	outcomeText.hideWhenInMenu = false;
	outcomeText.archived = false;
	
	outcomeText setText( endReasonText );
	firstTitle = createFontString( font, winnerSize );
	firstTitle setParent( outcomeText );
	firstTitle setPoint( "TOP", "BOTTOM", 0, spacing );
	
	firstTitle.glowAlpha = 1;
	firstTitle.hideWhenInMenu = false;
	firstTitle.archived = false;
	if ( isDefined( players[0] ) )
	{
		firstTitle.label = &"MP_FIRSTPLACE_NAME";
		firstTitle setPlayerNameString( players[0] );
		firstTitle setCOD7DecodeFX( 175, duration, 600 );
	}
	secondTitle = createFontString( font, otherSize );
	secondTitle setParent( firstTitle );
	secondTitle setPoint( "TOP", "BOTTOM", 0, spacing );
	
	secondTitle.glowAlpha = 1;
	secondTitle.hideWhenInMenu = false;
	secondTitle.archived = false;
	if ( isDefined( players[1] ) )
	{
		secondTitle.label = &"MP_SECONDPLACE_NAME";
		secondTitle setPlayerNameString( players[1] );
		secondTitle setCOD7DecodeFX( 175, duration, 600 );
	}
	
	thirdTitle = createFontString( font, otherSize );
	thirdTitle setParent( secondTitle );
	thirdTitle setPoint( "TOP", "BOTTOM", 0, spacing );
	thirdTitle setParent( secondTitle );
	
	thirdTitle.glowAlpha = 1;
	thirdTitle.hideWhenInMenu = false;
	thirdTitle.archived = false;
	if ( isDefined( players[2] ) )
	{
		thirdTitle.label = &"MP_THIRDPLACE_NAME";
		thirdTitle setPlayerNameString( players[2] );
		thirdTitle setCOD7DecodeFX( 175, duration, 600 );
	}
	
	matchBonus = createFontString( font, 2.0 );
	matchBonus setParent( thirdTitle );
	matchBonus setPoint( "TOP", "BOTTOM", 0, spacing );
	matchBonus.glowAlpha = 1;
	matchBonus.hideWhenInMenu = false;
	matchBonus.archived = false;
	if ( isDefined( self.matchBonus ) )
	{
		matchBonus.label = game["strings"]["match_bonus"];
		matchBonus setValue( self.matchBonus );
	}
	self thread updateOutcome( firstTitle, secondTitle, thirdTitle );
	self thread resetOutcomeNotify( outcomeTitle, outcomeText, firstTitle, secondTitle, thirdTitle, matchBonus );
}
wagerOutcomeNotify( winner, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );
	
	while ( self.doingNotify )
		wait 0.05;
		
	setMatchFlag( "enable_popups", 0 );
	self endon ( "reset_outcome" );
	headerFont = "extrabig";
	font = "objective";
	if ( self IsSplitscreen() )
	{
		titleSize = 2.0;
		winnerSize = 1.5;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 2;
	}
	else
	{
		titleSize = 3.0;
		winnerSize = 2.0;
		otherSize = 1.5;
		iconSize = 30;
		spacing = 20;
	}
	
	halftime = false;
	if ( isDefined( level.sidebet ) && level.sidebet )
		halftime = true;
	duration = 60000;
	players = level.placement["all"];
		
	outcomeTitle = createFontString( headerFont, titleSize );
	outcomeTitle setPoint( "TOP", undefined, 0, spacing );
	if( halftime )
	{
		outcomeTitle setText( game["strings"]["intermission"] );
		outcomeTitle.color = (1.0, 1.0, 0.0);
		outcomeTitle.glowColor = (1.0, 0.0, 0.0);
	}
	else if( isDefined(level.dontCalcWagerWinnings) && level.dontCalcWagerWinnings == true )
	{
		outcomeTitle setText( game["strings"]["wager_topwinners"] );
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else
	{
		if ( IsDefined( self.wagerWinnings ) && ( self.wagerWinnings > 0 ) )
		{
			outcomeTitle setText( game["strings"]["wager_inthemoney"] );
			outcomeTitle.color = (0.42, 0.68, 0.46);
		}
		else
		{
			outcomeTitle setText( game["strings"]["wager_loss"] );
			outcomeTitle.color = (0.73, 0.29, 0.19);
		}
	}
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeTitle setCOD7DecodeFX( 200, duration, 600 );
	outcomeText = createFontString( font, 2.0 );
	outcomeText setParent( outcomeTitle );
	outcomeText setPoint( "TOP", "BOTTOM", 0, 0 );
	outcomeText.glowAlpha = 1;
	outcomeText.hideWhenInMenu = false;
	outcomeText.archived = false;
	
	outcomeText setText( endReasonText );
	playerNameHudElems = [];
	playerCPHudElems = [];
	numPlayers = players.size;
	for ( i = 0 ; i < numPlayers ; i++ )
	{
		if ( !halftime && isDefined( players[i] ) )
		{
			secondTitle = createFontString( font, otherSize );
			if ( playerNameHudElems.size == 0 )
			{
				secondTitle setParent( outcomeText );
				secondTitle setPoint( "TOP_LEFT", "BOTTOM", -175, spacing*3 );
			}
			else
			{
				secondTitle setParent( playerNameHudElems[playerNameHudElems.size-1] );
				secondTitle setPoint( "TOP_LEFT", "BOTTOM_LEFT", 0, spacing );
			}
			
			secondTitle.glowAlpha = 1;
			secondTitle.hideWhenInMenu = false;
			secondTitle.archived = false;
			secondTitle.label = &"MP_WAGER_PLACE_NAME";
			secondTitle.playerNum = i;
			secondTitle setPlayerNameString( players[i] );
			playerNameHudElems[playerNameHudElems.size] = secondTitle;
		
			secondCP = createFontString( font, otherSize );
			secondCP setParent( secondTitle );
			secondCP setPoint( "TOP_RIGHT", "TOP_LEFT", 350, 0 );
			secondCP.glowAlpha = 1;
			secondCP.hideWhenInMenu = false;
			secondCP.archived = false;
			secondCP.label = &"MENU_POINTS";
			secondCP.currentValue = 0;
			if ( IsDefined( players[i].wagerWinnings ) )
				secondCP.targetValue = players[i].wagerWinnings;
			else
				secondCP.targetValue = 0;
			if ( secondCP.targetValue > 0 )
				secondCP.color = (0.42, 0.68, 0.46);
			secondCP setValue( 0 );
			playerCPHudElems[playerCPHudElems.size] = secondCP;
		}
	}
	
	
	self thread updateWagerOutcome( playerNameHudElems, playerCPHudElems );
	self thread resetWagerOutcomeNotify( playerNameHudElems, playerCPHudElems, outcomeTitle, outcomeText );
	
	if ( halftime )
		return;
	
	stillUpdating = true;
	countUpDuration = 2;
	CPIncrement = 9999;
	if ( IsDefined( playerCPHudElems[0] ) )
	{
		CPIncrement = int( playerCPHudElems[0].targetValue / ( countUpDuration / 0.05 ) );
		if ( CPIncrement < 1 )
			CPIncrement = 1;
	}
	while( stillUpdating )
	{
		stillUpdating = false;
		for ( i = 0 ; i < playerCPHudElems.size ; i++ )
		{				
			if ( IsDefined( playerCPHudElems[i] ) && ( playerCPHudElems[i].currentValue < playerCPHudElems[i].targetValue ) )
			{
				playerCPHudElems[i].currentValue += CPIncrement;
				if ( playerCPHudElems[i].currentValue > playerCPHudElems[i].targetValue )
					playerCPHudElems[i].currentValue = playerCPHudElems[i].targetValue;
				playerCPHudElems[i] SetValue( playerCPHudElems[i].currentValue );
				stillUpdating = true;
			}
		}
		wait 0.05;
	}
}
teamWagerOutcomeNotify( winner, isRoundEnd, endReasonText )
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );
	team = self.pers["team"];
	if ( !isDefined( team ) || (team != "allies" && team != "axis") )
		team = "allies";
	wait 0.05;
	
	while ( self.doingNotify )
		wait 0.05;
	self endon ( "reset_outcome" );
	
	headerFont = "extrabig";
	font = "objective";
	if ( self IsSplitscreen() )
	{
		titleSize = 2.0;
		textSize = 1.5;
		iconSize = 30;
		spacing = 10;
	}
	else
	{
		titleSize = 3.0;
		textSize = 2.0;
		iconSize = 70;
		spacing = 15;
	}
	halftime = false;
	if ( isDefined( level.sidebet ) && level.sidebet )
		halftime = true;
	duration = 60000;
	outcomeTitle = createFontString( headerFont, titleSize );
	outcomeTitle setPoint( "TOP", undefined, 0, spacing );
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeText = createFontString( font, 2.0 );
	outcomeText setParent( outcomeTitle );
	outcomeText setPoint( "TOP", "BOTTOM", 0, 0 );
	outcomeText.glowAlpha = 1;
	outcomeText.hideWhenInMenu = false;
	outcomeText.archived = false;
	
	if ( winner == "tie" )
	{
		
		if ( isRoundEnd )
			outcomeTitle setText( game["strings"]["round_draw"] );
		else
			outcomeTitle setText( game["strings"]["draw"] );
		outcomeTitle.color = (1, 1, 1);
		
		winner = "allies";
	}
	else if ( winner == "overtime" )
	{
		outcomeTitle setText( game["strings"]["overtime"] );
		outcomeTitle.color = (1, 1, 1);
	}
	else if ( isDefined( self.pers["team"] ) && winner == team )
	{
		
		if ( isRoundEnd )
			outcomeTitle setText( game["strings"]["round_win"] );
		else
			outcomeTitle setText( game["strings"]["victory"] );
		outcomeTitle.color = (0.42, 0.68, 0.46);
	}
	else
	{
		
		if ( isRoundEnd )
			outcomeTitle setText( game["strings"]["round_loss"] );
		else
			outcomeTitle setText( game["strings"]["defeat"] );
		outcomeTitle.color = (0.73, 0.29, 0.19);
	}
	if( !isDefined( level.dontShowEndReason ) || !level.dontShowEndReason )
	{
		outcomeText setText( endReasonText );
	}
	
	outcomeTitle setPulseFX( 100, duration, 1000 );
	outcomeText setPulseFX( 100, duration, 1000 );
	leftIcon = createIcon( game["icons"][team], iconSize, iconSize );
	leftIcon setParent( outcomeText );
	leftIcon setPoint( "TOP", "BOTTOM", -60, spacing );
	leftIcon.hideWhenInMenu = false;
	leftIcon.archived = false;
	leftIcon.alpha = 0;
	leftIcon fadeOverTime( 0.5 );
	leftIcon.alpha = 1;
	rightIcon = createIcon( game["icons"][level.otherTeam[team]], iconSize, iconSize );
	rightIcon setParent( outcomeText );
	rightIcon setPoint( "TOP", "BOTTOM", 60, spacing );
	rightIcon.hideWhenInMenu = false;
	rightIcon.archived = false;
	rightIcon.alpha = 0;
	rightIcon fadeOverTime( 0.5 );
	rightIcon.alpha = 1;
	score = getTeamScore( team );
	otherScore = getTeamScore( level.otherTeam[team] );
	leftScore = createFontString( font, titleSize );
	leftScore setParent( leftIcon );
	leftScore setPoint( "TOP", "BOTTOM", 0, spacing );
	
	leftScore.glowAlpha = 1;
	leftScore setValue( score );
	leftScore.hideWhenInMenu = false;
	leftScore.archived = false;
	leftScore setPulseFX( 100, duration, 1000 );
	rightScore = createFontString( font, titleSize );
	rightScore setParent( rightIcon );
	rightScore setPoint( "TOP", "BOTTOM", 0, spacing );
	
	rightScore.glowAlpha = 1;
	rightScore setValue( otherScore );
	rightScore.hideWhenInMenu = false;
	rightScore.archived = false;
	rightScore setPulseFX( 100, duration, 1000 );
	matchBonus = undefined;
	sidebetWinnings = undefined;
	if ( !isRoundEnd && !halftime && isDefined( self.wagerWinnings ) )
	{
		matchBonus = createFontString( font, 2.0 );
		matchBonus setParent( outcomeText );
		matchBonus setPoint( "TOP", "BOTTOM", 0, iconSize + (spacing * 3) + leftScore.height );
		matchBonus.glowAlpha = 1;
		matchBonus.hideWhenInMenu = false;
		matchBonus.archived = false;
		matchBonus.label = game["strings"]["wager_winnings"];
		matchBonus setValue( self.wagerWinnings );
		if ( isDefined( game["side_bets"] ) && game["side_bets"] )
		{
			sidebetWinnings = createFontString( font, 2.0 );
			sidebetWinnings setParent( matchBonus );
			sidebetWinnings setPoint( "TOP", "BOTTOM", 0, spacing );
			sidebetWinnings.glowAlpha = 1;
			sidebetWinnings.hideWhenInMenu = false;
			sidebetWinnings.archived = false;
			sidebetWinnings.label = game["strings"]["wager_sidebet_winnings"];
			sidebetWinnings setValue( self.pers["wager_sideBetWinnings"] );
		}
	}
	self thread resetOutcomeNotify( outcomeTitle, outcomeText, leftIcon, rightIcon, leftScore, rightScore, matchBonus, sidebetWinnings );
}
destroyHudElem( hudElem )
{
	if( isDefined( hudElem ) )
		hudElem destroyElem();
}
resetOutcomeNotify( hudElem1, hudElem2, hudElem3, hudElem4, hudElem5, hudElem6, hudElem7, hudElem8, hudElem9, hudElem10, hudElem11, hudElem12 )
{
	self endon ( "disconnect" );
	self waittill ( "reset_outcome" );
	
	destroyHudElem( hudElem1 );
	destroyHudElem( hudElem2 );
	destroyHudElem( hudElem3 );
	destroyHudElem( hudElem4 );
	destroyHudElem( hudElem5 );
	destroyHudElem( hudElem6 );
	destroyHudElem( hudElem7 );
	destroyHudElem( hudElem8 );
	destroyHudElem( hudElem9 );
	destroyHudElem( hudElem10 );
	destroyHudElem( hudElem11 );
	destroyHudElem( hudElem12 );
}
resetWagerOutcomeNotify( playerNameHudElems, playerCPHudElems, outcomeTitle, outcomeText )
{
	self endon( "disconnect" );
	self waittill( "reset_outcome" );
	
	for ( i = playerNameHudElems.size - 1 ; i >= 0 ; i-- )
	{
		if ( IsDefined( playerNameHudElems[i] ) )
			playerNameHudElems[i] destroy();
	}
		
	for ( i = playerCPHudElems.size - 1 ; i >= 0 ; i-- )
	{
		if ( IsDefined( playerCPHudElems[i] ) )
			playerCPHudElems[i] destroy();
	}
	
	if ( IsDefined( outcomeText ) )
		outcomeText destroy();
	
	if ( IsDefined( outcomeTitle ) )
		outcomeTitle destroy();
}
updateOutcome( firstTitle, secondTitle, thirdTitle )
{
	self endon( "disconnect" );
	self endon( "reset_outcome" );
	
	while( true )
	{
		self waittill( "update_outcome" );
		players = level.placement["all"];
		if ( isDefined( firstTitle ) && isDefined( players[0] ) )
			firstTitle setPlayerNameString( players[0] );
		else if ( isDefined( firstTitle ) )
			firstTitle.alpha = 0;
		
		if ( isDefined( secondTitle ) && isDefined( players[1] ) )
			secondTitle setPlayerNameString( players[1] );
		else if ( isDefined( secondTitle ) )
			secondTitle.alpha = 0;
		
		if ( isDefined( thirdTitle ) && isDefined( players[2] ) )
			thirdTitle setPlayerNameString( players[2] );
		else if ( isDefined( thirdTitle ) )
			thirdTitle.alpha = 0;
	}	
}
updateWagerOutcome( playerNameHudElems, playerCPHudElems )
{
	self endon( "disconnect" );
	self endon( "reset_outcome" );
	
	while ( true )
	{
		self waittill( "update_outcome" );
		
		players = level.placement["all"];
		
		for ( i = 0 ; i < playerNameHudElems.size ; i++ )
		{
			if ( IsDefined( playerNameHudElems[i] ) && IsDefined( players[playerNameHudElems[i].playerNum] ) )
				playerNameHudElems[i] SetPlayerNameString( players[playerNameHudElems[i].playerNum] );
			else
			{
				if ( IsDefined( playerNameHudElems[i] ) )
					playerNameHudElems[i].alpha = 0;
				if ( IsDefined( playerCPHudElems[i] ) )
					playerCPHudElems[i].alpha = 0;
			}
		}
	}
}