#include maps\mp\_utility; 
#include common_scripts\utility; 
main()
{
	
	
	
	if( GetDvar( #"mg42" ) == "" )
	{
		SetDvar( "mgTurret", "off" ); 
	}
	level.magic_distance = 24; 
	turretInfos = getEntArray( "turretInfo", "targetname" );
	for( index = 0; index < turretInfos.size; index++ )
	{
		turretInfos[index] Delete();
	}
	
}
set_difficulty( difficulty )
{
	init_turret_difficulty_settings();
	turrets = GetEntArray( "misc_turret", "classname" ); 
	for( index = 0; index < turrets.size; index++ )
	{
		if( IsDefined( turrets[index].script_skilloverride ) )
		{
			switch( turrets[index].script_skilloverride )
			{
			case "easy":
				difficulty = "easy"; 
				break; 
			case "medium":
				difficulty = "medium"; 
				break; 
			case "hard":
				difficulty = "hard"; 
				break; 
			case "fu":
				difficulty = "fu"; 
				break; 
			default:
				continue; 
			}
		}
		turret_set_difficulty( turrets[index], difficulty ); 
	}
}
init_turret_difficulty_settings()
{
	level.mgTurretSettings["easy"]["convergenceTime"] = 2.5; 
	level.mgTurretSettings["easy"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["easy"]["accuracy"] = 0.38; 
	level.mgTurretSettings["easy"]["aiSpread"] = 2; 
	level.mgTurretSettings["easy"]["playerSpread"] = 0.5; 	
	level.mgTurretSettings["medium"]["convergenceTime"] = 1.5; 
	level.mgTurretSettings["medium"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["medium"]["accuracy"] = 0.38; 
	level.mgTurretSettings["medium"]["aiSpread"] = 2; 
	level.mgTurretSettings["medium"]["playerSpread"] = 0.5; 	
	level.mgTurretSettings["hard"]["convergenceTime"] = .8; 
	level.mgTurretSettings["hard"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["hard"]["accuracy"] = 0.38; 
	level.mgTurretSettings["hard"]["aiSpread"] = 2; 
	level.mgTurretSettings["hard"]["playerSpread"] = 0.5; 	
	level.mgTurretSettings["fu"]["convergenceTime"] = .4; 
	level.mgTurretSettings["fu"]["suppressionTime"] = 3.0; 
	level.mgTurretSettings["fu"]["accuracy"] = 0.38; 
	level.mgTurretSettings["fu"]["aiSpread"] = 2; 
	level.mgTurretSettings["fu"]["playerSpread"] = 0.5; 	
}
turret_set_difficulty( turret, difficulty )
{
	turret.convergenceTime = level.mgTurretSettings[difficulty]["convergenceTime"]; 
	turret.suppressionTime = level.mgTurretSettings[difficulty]["suppressionTime"]; 
	turret.accuracy = level.mgTurretSettings[difficulty]["accuracy"]; 
	turret.aiSpread = level.mgTurretSettings[difficulty]["aiSpread"]; 
	turret.playerSpread = level.mgTurretSettings[difficulty]["playerSpread"]; 	
}
turret_suppression_fire( targets ) 
{
	self endon( "death" ); 
	self endon( "stop_suppression_fire" ); 
	if( !IsDefined( self.suppresionFire ) )
	{
		self.suppresionFire = true; 
	}
	for( ;; )
	{
		while( self.suppresionFire )
		{
			self SetTargetEntity( targets[RandomInt( targets.size )] ); 
			wait( 2 + RandomFloat( 2 ) ); 
		}
		self ClearTargetEntity(); 
		while( !self.suppresionFire )
		{
			wait( 1 ); 
		}
	}
}
burst_fire_settings( setting )
{
	if( setting == "delay" )
	{
		return 0.2; 
	}
	else if( setting == "delay_range" )
	{
		return 0.5; 
	}
	else if( setting == "burst" )
	{
		return 0.5; 
	}
	else if( setting == "burst_range" )
	{
		return 4; 
	}
}
burst_fire( turret, manual_target )
{
	turret endon( "death" ); 
	turret endon( "stopfiring" ); 
	self endon( "stop_using_built_in_burst_fire" ); 
	if( IsDefined( turret.script_delay_min ) )
	{
		turret_delay = turret.script_delay_min; 
	}
	else
	{
		turret_delay = burst_fire_settings( "delay" ); 
	}
	if( IsDefined( turret.script_delay_max ) ) 
	{
		turret_delay_range = turret.script_delay_max - turret_delay; 
	}
	else
	{
		turret_delay_range = burst_fire_settings( "delay_range" ); 
	}
	if( IsDefined( turret.script_burst_min ) )
	{
		turret_burst = turret.script_burst_min; 
	}
	else
	{
		turret_burst = burst_fire_settings( "burst" ); 
	}
	if( IsDefined( turret.script_burst_max ) ) 
	{
		turret_burst_range = turret.script_burst_max - turret_burst; 
	}
	else
	{
		turret_burst_range = burst_fire_settings( "burst_range" ); 
	}
	while( 1 )
	{	
		turret StartFiring(); 
		
		if( IsDefined( manual_target ) )
		{
			turret thread random_spread( manual_target ); 
		}
		turret do_shoot();
		wait( turret_burst + RandomFloat( turret_burst_range ) ); 
		turret StopShootTurret();
		turret StopFiring(); 
		wait( turret_delay + RandomFloat( turret_delay_range ) ); 
	}
}
burst_fire_unmanned() 
{
	self notify( "stop_burst_fire_unmanned" );
	self endon( "stop_burst_fire_unmanned" );
	self endon( "death" ); 
	level endon( "game_ended" );
	if( IsDefined( self.script_delay_min ) )
	{
		turret_delay = self.script_delay_min; 
	}
	else
	{
		turret_delay = burst_fire_settings( "delay" ); 
	}
	if( IsDefined( self.script_delay_max ) ) 
	{
		turret_delay_range = self.script_delay_max - turret_delay; 
	}
	else
	{
		turret_delay_range = burst_fire_settings( "delay_range" ); 
	}
	if( IsDefined( self.script_burst_min ) )
	{
		turret_burst = self.script_burst_min; 
	}
	else
	{
		turret_burst = burst_fire_settings( "burst" ); 
	}
	if( IsDefined( self.script_burst_max ) ) 
	{
		turret_burst_range = self.script_burst_max - turret_burst; 
	}
	else
	{
		turret_burst_range = burst_fire_settings( "burst_range" ); 
	}
	pauseUntilTime = GetTime(); 
	turretState = "start";
	
	
	self.script_shooting = false;
	for( ;; )
	{
		if( IsDefined( self.manual_targets ) )
		{
			self ClearTargetEntity();
			self SetTargetEntity( self.manual_targets[RandomInt( self.manual_targets.size )] );
		}
		duration = ( pauseUntilTime - GetTime() ) * 0.001; 
		if( self IsFiringTurret() && (duration <= 0) )
		{
			if( turretState != "fire" )
			{
				turretState = "fire";
				self playsound ("mpl_turret_alert"); 
				self thread do_shoot();
				self.script_shooting = true;
			}
			duration = turret_burst + RandomFloat( turret_burst_range ); 
			
			self thread turret_timer( duration );
			self waittill( "turretstatechange" ); 
			self.script_shooting = false;
			duration = turret_delay + RandomFloat( turret_delay_range ); 
			
			pauseUntilTime = GetTime() + Int( duration * 1000 ); 
		}
		else
		{
			if( turretState != "aim" )
			{
				turretState = "aim"; 
			}
			
			self thread turret_timer( duration );
			
			self waittill( "turretstatechange" ); 
		}
	}
}
do_shoot()
{
	self endon( "death" ); 
	self endon( "turretstatechange" ); 
	for( ;; )
	{
		self ShootTurret();
		wait( 0.112 ); 
	}
}
turret_timer( duration )
{
	if( duration <= 0 )
	{
		return; 
	}
	self endon( "turretstatechange" ); 
	
	wait( duration ); 
	if( IsDefined( self ) )
	{
		self notify( "turretstatechange" ); 
	}
	
}
random_spread( ent )
{
	self endon( "death" ); 
	self notify( "stop random_spread" ); 
	self endon( "stop random_spread" ); 
	self endon( "stopfiring" ); 
	self SetTargetEntity( ent ); 
	self.manual_target = ent;
	while( 1 )
	{
		
		
		
		
		
		
		if( IsPlayer( ent ) )
		{
			ent.origin = self.manual_target GetOrigin(); 
		}
		else
		{
			ent.origin = self.manual_target.origin; 
		}
		ent.origin += ( 20 - RandomFloat( 40 ), 20 - RandomFloat( 40 ), 20 - RandomFloat( 60 ) ); 
		wait( 0.2 ); 
	}
}