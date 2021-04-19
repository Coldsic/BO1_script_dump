main()
{
	minefields = getentarray ("minefield", "targetname");
	if (minefields.size > 0)
	{
		level._effect["mine_explosion"] = loadfx ("explosions/fx_grenadeExp_dirt");
	}
	for (i=0;i<minefields.size;i++)
	{
		minefields[i] thread minefield_think();
	}
}
minefield_think()
{
	while (1)
	{
		self waittill ("trigger",other);
		if(isSentient(other))
			other thread minefield_kill(self);
	}
}
minefield_kill(trigger)
{
	if(isDefined(self.minefield))
		return;
	self.minefield = true;
	self playsound ("minefield_click");
	wait(.5);
	wait(randomFloat(.2));
	
	if (!(isdefined(self)))
		return;
	if(self istouching(trigger))
	{
		
		
		if (isplayer(self))
		{
			level notify ("mine death");
			self playsound ("explo_mine");
		}
		else
			level thread maps\_utility::play_sound_in_space("explo_mine",self.origin);
		
		origin = self getorigin();
		range = 300;
		maxdamage = 2000;
		mindamage = 50;
		
		playfx ( level._effect["mine_explosion"], origin);
		playsoundatposition("mortar_dirt", origin);
		
		
		self enableHealthShield( false );
		radiusDamage(origin, range, maxdamage, mindamage);
		
		
		
		self enableHealthShield( true );
		
		
		
		
		
		
			
			
		
	}
	self.minefield = undefined;
}  
