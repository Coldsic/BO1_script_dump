
init()
{
	precacheShader( "progress_bar_bg" );
	precacheShader( "progress_bar_fg" );
	precacheShader( "progress_bar_fill" );
	precacheShader( "score_bar_bg" );
	precacheShader( "score_bar_allies" );
	precacheShader( "score_bar_opfor" );
	
	level.uiParent = spawnstruct();
	level.uiParent.horzAlign = "left";
	level.uiParent.vertAlign = "top";
	level.uiParent.alignX = "left";
	level.uiParent.alignY = "top";
	level.uiParent.x = 0;
	level.uiParent.y = 0;
	level.uiParent.width = 0;
	level.uiParent.height = 0;
	level.uiParent.children = [];
	
	level.fontHeight = 12;
	
	level.hud["allies"] = spawnstruct();
	level.hud["axis"] = spawnstruct();
	
	
	
	level.primaryProgressBarY = -61; 
	level.primaryProgressBarX = 0;
	level.primaryProgressBarHeight = 9; 
	level.primaryProgressBarWidth = 120;
	level.primaryProgressBarTextY = -75;
	level.primaryProgressBarTextX = 0;
	level.primaryProgressBarFontSize = 1.4;
	
	if ( level.splitscreen )
	{
		
		level.primaryProgressBarX = 20;
		level.primaryProgressBarTextX = 20;
		
		level.primaryProgressBarY = 15;
		level.primaryProgressBarTextY = 0;
		level.primaryProgressBarHeight = 2;
	}
	
	level.secondaryProgressBarY = -85; 
	level.secondaryProgressBarX = 0;
	level.secondaryProgressBarHeight = 9; 
	level.secondaryProgressBarWidth = 120;
	level.secondaryProgressBarTextY = -100;
	level.secondaryProgressBarTextX = 0;
	level.secondaryProgressBarFontSize = 1.4;
	
	if ( level.splitscreen )
	{
		
		level.secondaryProgressBarX = 20;
		level.secondaryProgressBarTextX = 20;
		
		level.secondaryProgressBarY = 15;
		level.secondaryProgressBarTextY = 0;
		level.secondaryProgressBarHeight = 2;
	}
	level.teamProgressBarY = 32; 
	level.teamProgressBarHeight = 14;
	level.teamProgressBarWidth = 192;
	level.teamProgressBarTextY = 8; 
	level.teamProgressBarFontSize = 1.65;
	if ( GetDvar( #"ui_score_bar" ) == "" )
		setDvar( "ui_score_bar", 0 );
	setDvar( "ui_generic_status_bar", 0 );
	if ( level.splitscreen )
	{
		level.lowerTextYAlign = "BOTTOM";
		level.lowerTextY = -42;
		level.lowerTextFontSize = 1.4;
	}
	else
	{
		level.lowerTextYAlign = "CENTER";
		level.lowerTextY = 70;
		level.lowerTextFontSize = 2;
	}
}
showClientScoreBar( time )
{
	self notify ( "showClientScoreBar" );
	self endon ( "showClientScoreBar" );
	self endon ( "death" );
	self endon ( "disconnect" );
	
	self setClientDvar( "ui_score_bar", 1 );
	wait ( time );
	self setClientDvar( "ui_score_bar", 0 );
}
showClientGenericMessageBar( time, message )
{
	self notify ( "showClientGenericMessageBar" );
	self endon ( "showClientGenericMessageBar" );
	self endon ( "disconnect" );
	
	if ( isDefined( time ) && isDefined( message ) )
	{
		self setClientDvar( "ui_generic_status_bar", 1 );
		self setClientDvar( "generic_status_bar_message", message );
		wait ( time );
		self setClientDvar( "ui_generic_status_bar", 0 );
	}
	else
	{
		self setClientDvar( "ui_generic_status_bar", 0 );
	}
}
fontPulseInit()
{
	self.baseFontScale = self.fontScale;
	self.maxFontScale = self.fontScale * 2;
	self.inFrames = 3;
	self.outFrames = 5;
}
fontPulse(player)
{
	self notify ( "fontPulse" );
	self endon ( "fontPulse" );
	self endon( "death" );
	
	player endon("disconnect");
	player endon("joined_team");
	player endon("joined_spectators");
	
	scaleRange = self.maxFontScale - self.baseFontScale;
	
	while ( self.fontScale < self.maxFontScale )
	{
		self.fontScale = min( self.maxFontScale, self.fontScale + (scaleRange / self.inFrames) );
		wait 0.05;
	}
		
	while ( self.fontScale > self.baseFontScale )
	{
		self.fontScale = max( self.baseFontScale, self.fontScale - (scaleRange / self.outFrames) );
		wait 0.05;
	}
}
fadeToBlackForXSec( startwait, blackscreenwait, fadeintime, fadeouttime )
{
	
	wait( startwait );
	
	
	if( !isdefined(self.blackscreen) )
		self.blackscreen = newclienthudelem( self );
	
	self.blackscreen.x = 0;
	self.blackscreen.y = 0; 
	self.blackscreen.horzAlign = "fullscreen";
	self.blackscreen.vertAlign = "fullscreen";
	self.blackscreen.foreground = false;
	self.blackscreen.hidewhendead = false;
	self.blackscreen.hidewheninmenu = true;
	self.blackscreen.sort = 50; 
	self.blackscreen SetShader( "black", 640, 480 ); 
	self.blackscreen.alpha = 0; 
	
	
	if( fadeintime>0 )
		self.blackscreen FadeOverTime( fadeintime ); 
	self.blackscreen.alpha = 1; 
	wait( fadeintime );
	if( !isdefined(self.blackscreen) )
		return;		
	
	
	wait( blackscreenwait );
	if( !isdefined(self.blackscreen) )
		return;		
	
	
	if( fadeouttime>0 )
		self.blackscreen FadeOverTime( fadeouttime ); 
	self.blackscreen.alpha = 0; 
	wait( fadeouttime );
	
	if( isdefined(self.blackscreen) )			
	{
		self.blackscreen destroy();
		self.blackscreen = undefined;
	}
} 
