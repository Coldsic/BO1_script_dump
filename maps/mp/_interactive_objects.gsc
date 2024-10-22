#include maps\mp\_utility;
#include common_scripts\utility;
init()
{
	level.barrelExplodingThisFrame = false;
	
	
	qBarrels = false;
	all_barrels = [];
	
	barrels = getentarray ("explodable_barrel","targetname");
	if((isdefined(barrels)) && (barrels.size > 0))
	{
		qBarrels = true;
		
		for(i = 0; i < barrels.size; i++)
		{
			all_barrels[all_barrels.size] = barrels[i];
		}
	}
	
	barrels = getentarray ("explodable_barrel","script_noteworthy");
	if((isdefined(barrels)) && (barrels.size > 0))
	{
		qBarrels = true;
		
		for(i = 0; i < barrels.size; i++)
		{
			all_barrels[all_barrels.size] = barrels[i];
		}
	}
	
	if(qBarrels)
	{
		precacheModel("global_explosive_barrel");
		level.barrelBurn = 100;
		level.barrelHealth = 250;
		
		level.barrelIngSound = "exp_redbarrel_ignition";
		level.barrelExpSound = "exp_redbarrel";
		
		level.breakables_fx["barrel"]["burn_start"]	= loadfx ("destructibles/fx_barrel_ignite");
		level.breakables_fx["barrel"]["burn"]	 	= loadfx ("destructibles/fx_barrel_fire_top");
		level.breakables_fx["barrel"]["explode"] 	= loadfx ("destructibles/fx_barrelexp_mp");
		
		array_thread(all_barrels, ::explodable_barrel_think);
	}
	
	
	qCrates = false;
	all_crates = [];
	
	crates = getentarray ("flammable_crate","targetname");
	if((isdefined(crates)) && (crates.size > 0))
	{
		qCrates = true;
		
		for(i = 0; i < crates.size; i++)
		{
			all_crates[all_crates.size] = crates[i];
		}
	}
	
	crates = getentarray ("flammable_crate","script_noteworthy");
	if((isdefined(crates)) && (crates.size > 0))
	{
		qCrates = true;
		
		for(i = 0; i < crates.size; i++)
		{
			all_crates[all_crates.size] = crates[i];
		}
	}
	
	if(qCrates)
	{
		precacheModel("global_flammable_crate_jap_piece01_d");
		
		level.crateBurn = 100;
		level.crateHealth = 200;
	
		level.breakables_fx["ammo_crate"]["burn_start"]	= loadfx ("destructibles/fx_ammobox_ignite");
		level.breakables_fx["ammo_crate"]["burn"] = loadfx ("destructibles/fx_ammobox_fire_top");
		level.breakables_fx["ammo_crate"]["explode"] = loadfx ("destructibles/fx_ammoboxExp");
		
		level.crateIgnSound  = "Ignition_ammocrate";
		level.crateExpSound  = "Explo_ammocrate";
		
		array_thread(all_crates, ::flammable_crate_think);
	}
	
	if(!qBarrels && !qCrates)
	{
		return;
	}
}
explodable_barrel_think()
{	
	if(self.classname != "script_model")
	{
		return;
	}
	self endon ("exploding");
	
	self breakable_clip();
	self.health = level.barrelHealth;
	self setcandamage(true);
	self.targetname = "explodable_barrel";
	
	for(;;)
	{
		self waittill("damage", amount ,attacker, direction_vec, P, type);
		
		
		if(type == "MOD_MELEE" || type == "MOD_IMPACT")
		{
			continue;
		}
		
		
		if( IsDefined( self.script_requires_player ) && self.script_requires_player && !IsPlayer( attacker ) )
		{
			continue;
		}
		
		
		if( IsDefined( self.script_selfisattacker ) && self.script_selfisattacker )
		{
			self.damageOwner = self;
		}
		else
		{
			self.damageOwner = attacker;
		}
		
		self.health -= amount;
		
		if (self.health <= level.barrelBurn)
		{
			self thread explodable_barrel_burn();
		}
	}
}
explodable_barrel_burn()
{
	count = 0;
	startedfx = false;
	
	up = anglestoup((0, 90, 0));
	worldup = anglestoup((0, 90, 0));
	dot = vectordot(up, worldup);
	
	offset1 = (0, 0, 0);
	offset2 =  vector_multiply(up, (0, 0, 44));
	
	if(dot < .5)
	{	
		offset1 = vector_multiply(up, (0, 0, 22)) - (0, 0, 30);
		offset2 = vector_multiply(up, (0, 0, 22)) + (0, 0, 14);	
	}
	
	level thread maps\mp\gametypes\_battlechatter_mp::onPlayerNearExplodable( self, "barrel" );
	
	while(self.health > 0)
	{
		if(!startedfx)
		{
			playfx (level.breakables_fx["barrel"]["burn_start"], self.origin + offset1);
			level thread play_sound_in_space(level.barrelIngSound, self.origin);
			startedfx = true;
		}
		
		if(count > 20)
		{
			count = 0;
		}
		
		playfx(level.breakables_fx["barrel"]["burn"], self.origin + offset2);
		self playloopsound("barrel_fuse");
		
		if(count == 0)
		{
			self.health -= (10 + randomInt(10));
		}
		
		count++;
		wait 0.05;
	}
	level notify( "explosion_started" );
	
	self thread explodable_barrel_explode();
	
}
explodable_barrel_explode()
{
	self notify("exploding");
	self death_notify_wrapper();
	
	up = anglestoup((0, 90, 0));
	worldup = anglestoup((0, 90, 0));
	dot = vectordot(up, worldup);
	offset = (0, 0, 0);
	
	if(dot < .5)
	{
		start = (self.origin + vector_scale(up, 22));
		trace  = physicstrace(start, (start + (0, 0, -64)));
		end = trace["position"];
		offset = end - self.origin;
	}
	
	offset += (0,0,4);
	
	minDamage = 1;
	maxDamage = 250;
	blastRadius = 250;
	
	level thread play_sound_in_space(level.barrelExpSound, self.origin);
	playfx (level.breakables_fx["barrel"]["explode"], self.origin + offset);
	physicsexplosionsphere( self.origin + offset, 100, 80, 1, maxDamage, minDamage );
	
	level.barrelExplodingThisFrame = true;
	
	if (isdefined (self.remove))
	{
		self.remove delete();
	}
	
	if(isdefined(self.radius))
	{
		blastRadius = self.radius;
	}
	
	self radiusDamage(self.origin + (0, 0, 56), blastRadius, maxDamage, minDamage, self.damageOwner);
	
	attacker = undefined;
	
	if(isdefined(self.damageOwner))
	{
		attacker = self.damageOwner;
	}
		
	level.lastExplodingBarrel[ "time" ] = getTime();
	level.lastExplodingBarrel[ "origin" ] = self.origin + (0, 0, 30);
	
	self setModel("global_explosive_barrel");
			
	if(dot < .5)
	{
		start = (self.origin + vector_scale(up, 22));
		trace = physicstrace(start, (start + (0, 0, -64)));
		pos = trace["position"];
		
		self.origin = pos;
		self.angles += (0, 0, 90);	
	}
	
	wait 0.05;
	
	level.barrelExplodingThisFrame = false;
}
flammable_crate_think()
{	
	if(self.classname != "script_model")
		return;
	self endon ("exploding");
	
	self breakable_clip();
	self.health = level.crateHealth;
	self setcandamage(true);
	
	for (;;)
	{
		self waittill("damage", amount ,attacker, direction_vec, P, type);
		
		if( IsDefined( self.script_requires_player ) && self.script_requires_player && !IsPlayer( attacker ) )
		{
			continue;
		}
		
		
		if( IsDefined( self.script_selfisattacker ) && self.script_selfisattacker )
		{
			self.damageOwner = self;
		}
		else
		{
			self.damageOwner = attacker;
		}
		
		if(level.barrelExplodingThisFrame)
		{
			wait randomfloat(1);
		}
		
		self.health -= amount;
		
		if(self.health <= level.crateBurn)
		{
			self thread flammable_crate_burn();
		}
	}
}
flammable_crate_burn()
{
	count = 0;
	startedfx = false;
	
	up = anglestoup((0, 90, 0));
	worldup = anglestoup((0, 90, 0));
	dot = vectordot(up, worldup);
	
	offset1 = (0, 0, 0);
	offset2 =  vector_multiply(up, (0, 0, 44));
	
	if(dot < .5)
	{	
		offset1 = vector_multiply(up, (0, 0, 22)) - (0, 0, 30);
		offset2 = vector_multiply(up, (0, 0, 22)) + (0, 0, 14);	
	}
	
	while(self.health > 0)
	{
		if(!startedfx)
		{
			playfx (level.breakables_fx["ammo_crate"]["burn_start"], self.origin);
			level thread play_sound_in_space(level.crateIgnSound, self.origin);
			
			startedfx = true;
		}
		
		if(count > 20)
		{
			count = 0;
		}
		
		playfx (level.breakables_fx["ammo_crate"]["burn"], self.origin);
		
		if(count == 0)
		{
			self.health -= (10 + randomInt(10));
		}
		
		count++;
		wait 0.05;
	}
	
	self thread flammable_crate_explode();
}
flammable_crate_explode()
{
	self notify("exploding");
	self death_notify_wrapper();
	
	up = anglestoup((0, 90, 0));
	worldup = anglestoup((0, 90, 0));
	dot = vectordot(up, worldup);
	offset = (0, 0, 0);
	
	if(dot < .5)
	{
		start = (self.origin + vector_scale(up, 22));
		trace  = physicstrace(start, (start + (0, 0, -64)));
		end = trace["position"];
		offset = end - self.origin;
	}
	
	offset += (0, 0, 4);
	
	minDamage = 1;
	maxDamage = 250;
	blastRadius = 250;
	
	level thread play_sound_in_space(level.crateExpSound, self.origin);
	playfx (level.breakables_fx["ammo_crate"]["explode"], self.origin);
	physicsexplosionsphere( self.origin + offset, 100, 80, 1, maxDamage, minDamage );
	
	level.barrelExplodingThisFrame = true;
	
	if (isdefined (self.remove))
	{
		self.remove delete();
	}
	
	if (isdefined(self.radius))
	{
		blastRadius = self.radius;
	}
	
	attacker = undefined;
	
	if(isdefined(self.damageOwner))
	{
		attacker = self.damageOwner;
	}
	
	self radiusDamage(self.origin + (0, 0, 30), blastRadius, maxDamage, minDamage, attacker);
	
	self setModel("global_flammable_crate_jap_piece01_d");		
			
	if(dot < .5)
	{
		start = (self.origin + vector_scale(up, 22));
		trace = physicstrace(start, (start + (0, 0, -64)));
		pos = trace["position"];
		
		self.origin = pos;
		self.angles += (0, 0, 90);	
	}
	
	wait 0.05;
	
	level.barrelExplodingThisFrame = false;
}
breakable_clip()
{
	
	if(isdefined(self.target))
	{
		targ = getent(self.target,"targetname");
		
		if(targ.classname == "script_brushmodel")
		{
			self.remove = targ;
			return;
		}
	}
	
	
	if((isdefined (level.breakables_clip)) && (level.breakables_clip.size > 0))
	{
		self.remove = getClosestEnt(self.origin , level.breakables_clip);
	}
	
	if(isdefined (self.remove))
	{
		level.breakables_clip = array_remove (level.breakables_clip , self.remove);
	}
}
getClosestEnt(org, array)
{
	if(array.size < 1)
		return;
	
	dist = 256;
	ent = undefined;
	
	for(i=0;i<array.size;i++)
	{
		newdist = distance(array[i] getorigin(), org);
		if (newdist >= dist)
			continue;
		dist = newdist;
		ent = array[i];
	}
	
	return ent;
} 
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
