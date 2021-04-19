#include maps\mp\_utility;
init()
{	
	
	thread sessionAdvertisementCheck();
	
	
	
	
}
setAdvertisedStatus( onOff )
{
	
	changeAdvertisedStatus( onOff );
}
sessionAdvertisementCheck()
{
	if( GetDvarInt( #"xblive_privatematch" ) )
		return;
		
	if ( GetDvarInt( #"xblive_wagermatch" ) )
	{
		setAdvertisedStatus( false );
		return;
	}
		
	level endon( "game_end" );
	
	level waittill( "prematch_over" );
	while( true )
	{
		sessionAdvertCheckwait = getDvarIntDefault( #"sessionAdvertCheckwait", 1 );
		sessionAdvertScorePercent = getDvarIntDefault( #"sessionAdvertScorePercent", 10 );
		sessionAdvertTimeLeft = getDvarIntDefault( #"sessionAdvertTimeLeft", 30 ) * 1000;
		
		wait( sessionAdvertCheckwait );
		
		
		if ( level.scoreLimit )
		{
			if ( level.teamBased == false ) 
			{
				highestScore = 0;
				players = get_players();
				for( i = 0; i < players.size; i++)
				{
					if( players[i].score > highestScore )
						highestScore = players[i].score;
				}
				scorePercentageLeft = 100 - (( highestScore / level.scoreLimit ) * 100);
				if( sessionAdvertScorePercent >= scorePercentageLeft )
				{	
					setAdvertisedStatus( false ); 	
					continue;
				}
			}
			else 
			{			
				if( isRoundBased() == false )
				{
					scorePercentageLeft = 100 - (( game["teamScores"]["allies"] / level.scoreLimit ) * 100);
					if( sessionAdvertScorePercent >= scorePercentageLeft )
					{	
						setAdvertisedStatus( false ); 	
						continue;
					}
				
					scorePercentageLeft = 100 - (( game["teamScores"]["axis"] / level.scoreLimit ) * 100);
					if( sessionAdvertScorePercent >= scorePercentageLeft )
					{	
						setAdvertisedStatus( false ); 	
						continue;
					}
				}
			}
		}
		
		
		
		maxTime = GetDvarInt( #"scr_" + level.gameType + "_timelimit" );
		
		if( maxTime != 0 )
		{		
			
			timeLeft = maps\mp\gametypes\_globallogic_utils::getTimeRemaining();
			if( isRoundBased() == false )
			{
				if( sessionAdvertTimeLeft >= timeLeft )
				{	
					setAdvertisedStatus( false ); 	
					continue;
				}	
			}
			else
			{
				if( sessionAdvertTimeLeft >= timeLeft && true == isLastRound() )
				{	
					setAdvertisedStatus( false ); 	
					continue;
				}
			}
		}
		
		
		
		
		
		
		
		
		
		
		
		
		setAdvertisedStatus( true );	
	}
}
teamScoreLimitSoon( isTrue )
{
	if( isTrue == true )
		setAdvertisedStatus( false );	
}
playerScoreLimitSoon( isTrue )
{
	if( isTrue == true )
		setAdvertisedStatus( false );	
}
resetSessionQoSData()
{
	level waittill("game_ended");
	
	
}
getMatchType()
{
	if( 1 == GetDvarInt( #"xblive_theater" ) )
	{
		return 4;
	}
	else if( 1 == GetDvarInt( #"xblive_basictraining" ) )
	{
		return 3;
	}
	else if( 1 == GetDvarInt( #"xblive_wagermatch" ) )
	{
		return 2;
	}
	else if( 1 == GetDvarInt( #"xblive_privatematch" ) )
	{
		return 1;
	}
	return 0; 
}
setSessionQoSData()
{
	level endon( "game_end" );
	
	teamTypeNonTeamBased = 0;
	teamTypeTeamBased = 1;
	teamTypeRoundTeamBased = 2;
		
	gameType = maps\mp\gametypes\_persistence::getGameTypeName();	
	mapName = getdvar( "mapname" );
	
	matchType = getMatchType();	
	
	partyPrivacy = GetDvarInt( #"party_privacyStatus" );
					
	level waittill( "prematch_over" );
	
	while( true )
	{
		sessionQosUpdate = getDvarIntDefault( #"sessionQosUpdate", 5 );
		
		wait( sessionQosUpdate );
		timeLeft = int( maps\mp\gametypes\_globallogic_utils::getTimeRemaining() + 0.5 );
			
		highestScore = -9999;
		players = get_players();
		for( i = 0; i < players.size; i++)
		{
			if( players[i].score > highestScore )
				highestScore = players[i].score;
		}
		
		if ( level.teamBased == false )
		{
			setQosGameDataPayload( gameType, mapName, matchType, partyPrivacy, teamTypeNonTeamBased, timeLeft, highestScore );
			continue;
		}
		
		alliesTeamScore = game["teamScores"]["allies"];
		axisTeamScore = game["teamScores"]["axis"];
			
		if( isRoundBased() == false )
		{
			setQosGameDataPayload( gameType, mapName, matchType, partyPrivacy, teamTypeTeamBased, timeLeft, highestScore, alliesTeamScore, axisTeamScore );
			continue;
		}	
		
		alliesRoundsWon = getRoundsWon( "allies" );
		axisRoundsWon = getRoundsWon( "axis" );
			
		
		roundLimit = level.scoreLimit;
		
		setQosGameDataPayload( gameType, mapName, matchType, partyPrivacy, teamTypeRoundTeamBased, timeLeft, highestScore, alliesTeamScore, axisTeamScore, alliesRoundsWon, axisRoundsWon, roundLimit );
	}
}  
