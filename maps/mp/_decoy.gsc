#include common_scripts\utility;
#include maps\mp\_utility;
init()
{
	loadfx( "weapon/grenade/fx_nightingale_grenade_mp" );
	
	level.decoyWeapons = [];
	level.decoyWeapons["fullauto"] = [];
	level.decoyWeapons["semiauto"] = [];
	
	level.decoyWeapons["fullauto"][level.decoyWeapons["fullauto"].size] = "uzi_mp";
	
	level.decoyWeapons["semiauto"][level.decoyWeapons["semiauto"].size] = "m1911_mp";
	level.decoyWeapons["semiauto"][level.decoyWeapons["semiauto"].size] = "python_mp";
	level.decoyWeapons["semiauto"][level.decoyWeapons["semiauto"].size] = "cz75_mp";
	level.decoyWeapons["semiauto"][level.decoyWeapons["semiauto"].size] = "m14_mp";
	level.decoyWeapons["semiauto"][level.decoyWeapons["semiauto"].size] = "fnfal_mp";
}
createDecoyWatcher()
{
	watcher = self maps\mp\gametypes\_weaponobjects::createUseWeaponObjectWatcher( "nightingale", "nightingale_mp", self.team );
	watcher.onSpawn = ::onSpawnDecoy;
	watcher.detonate = ::decoyDetonate;
	watcher.deleteOnDifferentObjectSpawn = false;
	watcher.headicon = false;
}
onSpawnDecoy(watcher, owner)
{
	owner endon("disconnect");
	self endon( "death" );
	
	maps\mp\gametypes\_weaponobjects::onSpawnUseWeaponObject(watcher, owner);
	
	self.initial_velocity = self GetVelocity();
	delay = 1;
	
	wait (delay );
	decoy_time = 30;
	spawn_time = GetTime();
    owner maps\mp\gametypes\_globallogic_score::setWeaponStat( "nightingale_mp", 1, "used" );
	
	self thread simulateWeaponFire(owner);
	while( 1 )
	{
		if ( GetTime() > spawn_time + ( decoy_time * 1000 ))
		{
			self destroyDecoy(watcher,owner);
			return;
		}
		
		wait(0.05);
	}
}
moveDecoy( owner, count, fire_time, main_dir, max_offset_angle )
{
	self endon( "death" );
	self endon( "done" );
	
	if ( !(self IsOnGround() ) )
		return;
		
	min_speed = 100;
	max_speed = 200;
	
	min_up_speed = 100;
	max_up_speed = 200;
	
	current_main_dir = RandomIntRange(main_dir - max_offset_angle,main_dir + max_offset_angle);
	
	avel = ( RandomFloatRange( 800, 1800) * (RandomIntRange( 0, 2 ) * 2 - 1), 0, RandomFloatRange( 580, 940) * (RandomIntRange( 0, 2 ) * 2 - 1));
	intial_up = RandomFloatRange( min_up_speed, max_up_speed );
	
	start_time = GetTime();
	gravity = GetDvarInt( #"bg_gravity" );
	
	for ( i = 0; i < 1; i++ )
	{		
		angles = ( 0,RandomIntRange(current_main_dir - max_offset_angle,current_main_dir + max_offset_angle), 0 );
		dir = AnglesToForward( angles );
		
		dir = vector_scale( dir, RandomFloatRange( min_speed, max_speed ) );
		
		deltaTime = ( GetTime() - start_time ) * 0.001;
		
		
		up = (0,0, (intial_up) - (800 * deltaTime)  );
		
		self Launch( dir + up, avel ); 
		
		wait( fire_time );
	}
}
destroyDecoy(watcher,owner)
{
	self notify( "done" );
	self maps\mp\_entityheadicons::setEntityHeadIcon("none");
	
	
}
decoyDetonate( attacker )
{
	
	self notify( "done" );
	self maps\mp\_entityheadicons::setEntityHeadIcon("none");
}
getWeaponForDecoy( owner )
{
	
	weapon = pickRandomWeapon();
	
	return weapon;
}
simulateWeaponFire( owner )
{
	owner endon("disconnect");
	self endon( "death" );
	self endon( "done" );
	
	weapon = getWeaponForDecoy( owner );
	
	if ( weapon == "none" )
		return;
		
	self thread watchForExplosion(owner, weapon);
	self thread trackMainDirection();
	
	self.max_offset_angle = 30;
	
	weapon_class = maps\mp\gametypes\_missions::getWeaponClass( weapon );
	
	switch ( weapon_class )
	{
		case "weapon_cqb":
		case "weapon_smg":
		case "weapon_hmg":
		case "weapon_lmg":
		case "weapon_assault":
			simulateWeaponFireMachineGun( owner, weapon );
			break;
		case "weapon_sniper":
			simulateWeaponFireSniper( owner, weapon );
			break;
		case "weapon_pistol":
			simulateWeaponFirePistol( owner, weapon );
			break;
		case "weapon_shotgun":
			simulateWeaponFireShotgun( owner, weapon );
			break;
		
		default:
			simulateWeaponFireMachineGun( owner, weapon );
			break;
	}
}
simulateWeaponFireMachineGun( owner, weapon )
{
	if ( WeaponIsSemiAuto( weapon ) )
	{
		simulateWeaponFireMachineGunSemiAuto( owner, weapon );
	}
	else
	{
		simulateWeaponFireMachineGunFullAuto( owner, weapon );
	}
}
simulateWeaponFireMachineGunSemiAuto( owner, weapon )
{
	fireTime = WeaponFireTime(weapon);
	clipSize = WeaponClipSize(weapon);
	reloadTime = WeaponReloadTime(weapon);
		
	burst_spacing_min = 4;
	burst_spacing_max = 10;
	while( 1 )
	{
		if ( clipSize <= 1 )
			burst_count = 1;
		else
			burst_count = RandomIntRange( 1, clipSize );
		self thread moveDecoy( owner, burst_count, fireTime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, fireTime, burst_count, true );
		finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max);
	}
}
simulateWeaponFirePistol( owner, weapon )
{
	fireTime = WeaponFireTime(weapon);
	clipSize = WeaponClipSize(weapon);
	reloadTime = WeaponReloadTime(weapon);
	burst_spacing_min = 0.5;
	burst_spacing_max = 4;
	while( 1 )
	{
		burst_count = RandomIntRange( 1, clipSize );
		self thread moveDecoy( owner, burst_count, fireTime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, fireTime, burst_count, false );
		finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max);
	}
}
simulateWeaponFireShotgun( owner, weapon )
{
	fireTime = WeaponFireTime(weapon);
	clipSize = WeaponClipSize(weapon);
	reloadTime = WeaponReloadTime(weapon);
	if ( clipSize  > 2 )
		clipSize = 2;
	burst_spacing_min = 0.5;
	burst_spacing_max = 4;
	while( 1 )
	{
		burst_count = RandomIntRange( 1, clipSize );
		self thread moveDecoy( owner, burst_count, fireTime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, fireTime, burst_count, false );
		finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max);
	}
}
simulateWeaponFireMachineGunFullAuto( owner, weapon )
{
	fireTime = WeaponFireTime(weapon);
	clipSize = WeaponClipSize(weapon);
	reloadTime = WeaponReloadTime(weapon);
	if ( clipSize  > 30 )
		clipSize = 30;
		
	burst_spacing_min = 2;
	burst_spacing_max = 6;
	while( 1 )
	{
		burst_count = RandomIntRange( Int(clipSize * 0.6), clipSize );
		interrupt = false; 
		self thread moveDecoy( owner, burst_count, fireTime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, fireTime, burst_count, interrupt );
		finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max);
	}
}
simulateWeaponFireSniper( owner, weapon )
{
	fireTime = WeaponFireTime(weapon);
	clipSize = WeaponClipSize(weapon);
	reloadTime = WeaponReloadTime(weapon);
	
	if ( clipSize  > 2 )
		clipSize = 2;
		
	burst_spacing_min = 3;
	burst_spacing_max = 5;
	while( 1 )
	{
		burst_count = RandomIntRange( 1, clipSize );
		self thread moveDecoy( owner, burst_count, fireTime, self.main_dir, self.max_offset_angle );
		self fireburst( owner, weapon, fireTime, burst_count, false );
		finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max);
	}
}
fireburst( owner, weapon, fireTime, count, interrupt )
{
	interrupt_shot = count;
	
	if ( interrupt )
	{
		interrupt_shot = Int( count * RandomFloatRange( 0.6, 0.8 ) ); 
	}
	
	self FakeFire( owner, self.origin, weapon, interrupt_shot );
	wait ( fireTime * interrupt_shot );
	
	if ( interrupt )
	{
		self FakeFire( owner, self.origin, weapon, count - interrupt_shot );
		wait ( fireTime * (count - interrupt_shot) );
	}
}
finishWhileLoop(weapon, reloadTime, burst_spacing_min, burst_spacing_max)
{
		if ( ShouldPlayReloadSound() )
		{
			playreloadsounds( weapon, reloadTime );
		}
		else
		{
			wait ( RandomFloatRange(burst_spacing_min, burst_spacing_max) );
		}
}
playreloadsounds(weapon, reloadTime)
{
	divy_it_up = (reloadTime - 0.1) / 2;
	wait (0.1);
	self PlaySound("fly_assault_reload_npc_mag_out");
	wait (divy_it_up);
	self PlaySound("fly_assault_reload_npc_mag_in");
	wait (divy_it_up);
}
watchForExplosion( owner, weapon )
{
	self thread watchForDeathBeforeExplosion( );
	owner endon( "disconnect");
	self endon( "death_before_explode");
	self waittill("explode", pos);
	level thread doExplosion( owner, pos, weapon, RandomIntRange( 5, 10 ) );
}
watchForDeathBeforeExplosion( )
{
	self waittill("death");
	wait(0.1);
	self notify("death_before_explode");
}
doExplosion( owner, pos, weapon, count )
{
	min_offset = 100;
	max_offset = 500;
	
	for ( i = 0 ; i < count; i++ )
	{
		wait(RandomFloatRange(0.1,0.5));
		offset = ( RandomFloatRange(min_offset,max_offset)* (RandomIntRange( 0, 2 ) * 2 - 1), RandomFloatRange(min_offset,max_offset)* (RandomIntRange( 0, 2 ) * 2 - 1), 0 );
		owner FakeFire( owner, pos+offset, weapon, 1 );
	}
}
pickRandomWeapon()
{
	type = "fullauto";
	
	if ( RandomIntRange( 0, 10 ) < 3 )
	{
		type = "semiauto";
	}
	
	randomval = RandomIntRange(0,level.decoyWeapons[type].size);
	
	PrintLn( "Decoy type: " + type + " weapon: " + level.decoyWeapons[type][randomval] );
	
	return level.decoyWeapons[type][randomval];
}
ShouldPlayReloadSound()
{
 	if( RandomIntRange(0,5) == 1 )
 	{
 		return true;
 	}
 	
 	return false;
}
trackMainDirection()
{
	self endon( "death" );
	self endon( "done" );
	self.main_dir = Int(VectorToAngles((self.initial_velocity[0], self.initial_velocity[1], 0 ))[1]);
	
	up = (0,0,1);
	while( 1 )
	{
		self waittill( "grenade_bounce", pos, normal );
		
		dot = VectorDot( normal, up );
		
		
		if ( dot < 0.5 && dot > -0.5 ) 
		{
			self.main_dir = Int(VectorToAngles((normal[0], normal[1], 0 ))[1]);
		}
	}
} 
  
