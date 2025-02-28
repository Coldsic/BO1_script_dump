init()
{
	if ( level.createFX_enabled )
		return;
	
	if(GetDvar( #"scr_drawfriend") == "")
		setdvar("scr_drawfriend", "0");
	level.drawfriend = GetDvarInt( #"scr_drawfriend");
	AssertEx( IsDefined(game["headicon_allies"]), "Allied head icons are not defined.  Check the team set for the level.");
	AssertEx( IsDefined(game["headicon_axis"]), "Axis head icons are not defined.  Check the team set for the level.");
	PreCacheHeadIcon( game["headicon_allies"] );
	precacheHeadIcon( game["headicon_axis"] );
	level thread onPlayerConnect();
	
	for(;;)
	{
		updateFriendIconSettings();
		wait 5;
	}
}
onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}
onPlayerSpawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self thread showFriendIcon();
	}
}
onPlayerKilled()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("killed_player");
		self.headicon = "";
	}
}	
showFriendIcon()
{
	if(level.drawfriend)
	{
		if(self.pers["team"] == "allies")
		{
			self.headicon = game["headicon_allies"];
			self.headiconteam = "allies";
		}
		else
		{
			self.headicon = game["headicon_axis"];
			self.headiconteam = "axis";
		}
	}
}
	
updateFriendIconSettings()
{
	drawfriend = GetDvarFloat( #"scr_drawfriend");
	if(level.drawfriend != drawfriend)
	{
		level.drawfriend = drawfriend;
		updateFriendIcons();
	}
}
updateFriendIcons()
{
	
	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
		{
			if(level.drawfriend)
			{
				if(player.pers["team"] == "allies")
				{
					player.headicon = game["headicon_allies"];
					player.headiconteam = "allies";
				}
				else
				{
					player.headicon = game["headicon_axis"];
					player.headiconteam = "axis";
				}
			}
			else
			{
				players = level.players;
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
	
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
						player.headicon = "";
				}
			}
		}
	}
} 
