#include maps\mp\_utility;
init()
{
	
	level.bookmark["kill"] = 0; 
	level.bookmark["event"] = 1; 
	
	if( !level.console )
		demoOnce();
}
bookmark( type, time, ent1, ent2 )
{
	assertex( isdefined( level.bookmark[type] ), "Unable to find a bookmark type for type - " + type );
	client1 = 255;
	client2 = 255;
	if ( isDefined( ent1 ) )
		client1 = ent1 getEntityNumber();
	if ( isDefined( ent2 ) )
		client2 = ent2 getEntityNumber();
	addDemoBookmark( level.bookmark[type], time, client1, client2 );
}
demoOnce()
{
	if( !isDemoEnabled() )
			return;
			
	if( isPregame() )
		return;
	if ( !GetDvarInt( #"scr_demorecord_minplayers" ) )
	{
		SetDvar( "scr_demorecord_minplayers", 1 );
	}
	
	level.demorecord_minplayers = max( 1, GetDvarInt( #"scr_demorecord_minplayers" ) );
	level thread demoThink();
}
demoThink()
{
	level endon ( "game_ended" );
	wait( 0.5 );	
	
	for( ;; )
	{		
		wait 5.0;
		
		if ( game["state"] == "postgame" )
			return;
			
		if( isPregame() )
		{
			StopDemoRecording();			
			return;
		}
		
		bots = level.botsCount["allies"] +	level.botsCount["axis"];
		humans = level.playerCount["allies"] + level.playerCount["axis"] - bots;
		
	
		
		if( humans < level.demorecord_minplayers )
		{
			
			StopDemoRecording();
			continue;
		}		
		
		if( isDemoRecording() )
			continue;
			
		if( humans >= level.demorecord_minplayers )
		{
						
			StartDemoRecording();
			continue;
		}					
		
	}
	
}